import asyncio
import os

from livekit import agents, rtc
from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, tokenize, tts
from livekit.agents.llm import ChatContext, ChatImage, ChatMessage
from livekit.agents.voice_assistant import VoiceAssistant
from livekit.plugins import deepgram, openai, silero

from typing import Annotated
from log import BasicLogger

# Initialize the logger
logger = BasicLogger()

# Use this to store the latest image from a user's video track (if they have one)
latest_video_image = None

class AssistantFunction(agents.llm.FunctionContext):
    """This class is used to define functions that will be called by the assistant."""

    @agents.llm.ai_callable(
        description=(
            "Called when asked to evaluate something that would require vision capabilities,"
            "for example, analyzing an image, a video, or a webcam feed. Can also be called "
            "to describe an image, or describe what's going on in a video."
        )
    )
    async def image(
        self,
        user_msg: Annotated[
            str,
            agents.llm.TypeInfo(
                description=(
                    "The user message that specifies the request involving image or video analysis tasks. "
                    "This can include tasks related to static images, camera feeds, live video feeds, "
                    "dynamic video streams, webcam feeds, or live video sources. Scenarios may involve "
                    "object detection, motion tracking, anomaly detection, scene recognition, facial analysis, "
                    "or summarization of key events in a scene."
                ),
            ),
        ],
    ) -> None:
        """Process user messages related to image tasks."""
        logger.log_dim(message=f"Image processing triggered with message: {user_msg}")
        return None


async def get_video_track(room: rtc.Room) -> rtc.RemoteVideoTrack:
    """Retrieve the first available video track from a room.

    This function iterates over the remote participants in the room to find and return
    the first available remote video track. This track is used for processing images.

    Args:
        room (rtc.Room): The room object containing remote participants and their tracks.

    Returns:
        rtc.RemoteVideoTrack: The first available remote video track.
    """
    video_track = asyncio.Future[rtc.RemoteVideoTrack]()

    logger.log(message=f"Searching for first video track in room: {room.name}")
    num_participants = len(room.remote_participants)
    logger.log_dim(message=f"Found {num_participants} participants in room {room.name}")

    for _, participant in room.remote_participants.items():
        for _, track_publication in participant.track_publications.items():
            if track_publication.track is not None and isinstance(
                track_publication.track, rtc.RemoteVideoTrack
            ):
                video_track.set_result(track_publication.track)
                logger.log_dim(message=f"Using video track {video_track}")
                break

    return await video_track


async def _answer(
    text: str,
    use_image: bool,
    chat_context: ChatContext,
    assistant: VoiceAssistant,
    latest_image: rtc.VideoFrame | None,
):
    """
    Answer the user's message with the given text and optionally the latest
    image captured from the video track.
    """
    content: list[str | ChatImage] = [text]

    if latest_image is None:
        # await get_video_track(self.ctx.room)
        logger.log_dim(message=" Latest_image is None")

    if use_image and latest_image:
        content.append(ChatImage(image=latest_image))

    chat_message = ChatMessage(role="user", content=content)
    chat_context.messages.append(chat_message)

    stream = openai.LLM().chat(chat_ctx=chat_context)
    logger.log(message=f"Sending message to Assistant: {text}")
    
    await assistant.say(source=stream, allow_interruptions=True)

    # Clear the imageReceived message after the assistant has spoken
    if use_image and latest_image:
        chat_context.messages.remove(chat_message)


async def entrypoint(ctx: JobContext):

    chat_context = ChatContext().append(
        role="system",
        text=(
            "Your name is Nova. You are a funny, witty bot. Your interface with users will be voice and vision."
            "Respond with short and concise answers. Avoid using unpronouncable punctuation. You can use emojis."
        ),
    )

    # Since GPT-4 is not supported by LiveKit, we'll use it with an LLMAdapter
    gpt = openai.LLM(model="gpt-4o")

    # Since OpenAI does not support streaming TTS, we'll use it with a StreamAdapter
    # to make it compatible with the VoiceAssistant
    openai_tts = tts.StreamAdapter(
        tts=openai.TTS(voice="nova"),
        sentence_tokenizer=tokenize.basic.SentenceTokenizer(),
    )

    latest_video_image: rtc.VideoFrame | None = None

    # Connect to the LiveKit room
    # indicating that the agent will only subscribe to all tracks
    await ctx.connect(auto_subscribe=AutoSubscribe.SUBSCRIBE_ALL)

    assistant = VoiceAssistant(
        vad=silero.VAD.load(),  # We'll use Silero's Voice Activity Detector (VAD)
        stt=deepgram.STT(),     # We'll use Deepgram's Speech To Text (STT)
        llm=gpt,
        tts=openai_tts,         # We'll use OpenAI's Text To Speech (TTS)
        fnc_ctx=AssistantFunction(),
        chat_ctx=chat_context,
    )

    chat = rtc.ChatManager(room=ctx.room)

    @chat.on(event="message_received")
    def on_message_received(msg: rtc.ChatMessage):
        """This event triggers whenever we get a new message from the user."""

        if msg.message:
            asyncio.create_task(
                _answer(
                    text=msg.message,
                    use_image=True,
                    chat_context=chat_context,
                    assistant=assistant,
                    latest_image=latest_video_image,
                )
            )

    @assistant.on(event="function_calls_finished")
    def on_function_calls_finished(
        called_functions: list[agents.llm.CalledFunction],
    ) -> None:
        """Triggered when the assistant completes a function call."""

        if len(called_functions) == 0:
            logger.log_warning(message="No function calls finished")
            return

        user_msg = called_functions[0].call_info.arguments.get("user_msg")

        if user_msg:
            asyncio.create_task(
                _answer(
                    text=user_msg,
                    use_image=True,
                    chat_context=chat_context,
                    assistant=assistant,
                    latest_image=latest_video_image,
                )
            )

    assistant.start(room=ctx.room)

    # Wait 1 second to allow the assistant to fully initialize before sending the greeting
    await asyncio.sleep(delay=1)
    await assistant.say(source="Hi there! How can I help?", allow_interruptions=True)

    while ctx.room.connection_state == rtc.ConnectionState.CONN_CONNECTED:

        # Wait 3 seconds before checking for a new video track
        await asyncio.sleep(delay=3)
        video_track = await get_video_track(room=ctx.room)

        async for event in rtc.VideoStream(track=video_track):
            # We'll continually grab the latest image from the video track
            # and store it in a variable.
            latest_video_image = event.frame


if __name__ == "__main__":
    
    logger.log_separator()
    logger.log(message="Starting Video Assistant")
    logger.log_info(message=f"Livekit URL: {os.getenv('LIVEKIT_URL')}")

    
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))