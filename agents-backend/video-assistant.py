import asyncio
from typing import Annotated

from livekit import agents, rtc

from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, tokenize, tts
from livekit.agents.llm import ChatContext, ChatImage, ChatMessage
from livekit.agents.voice_assistant import VoiceAssistant
from livekit.plugins import deepgram, openai, silero

# Use this to store the latest image from a user's video track (if they have one)
latest_video_image = None


class AssistantFunction(agents.llm.FunctionContext):
    """This class is used to define functions that will be called by the assistant."""

    @agents.llm.ai_callable(
        description=(
            "Called when asked to evaluate something that would require vision capabilities,"
            "for example, an image, video, or the webcam feed."
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
        print(f"Function call message for processing image: {user_msg}")
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

    print(f"****** Room: {room}")
    print(f"****** Room remote participants: {room.remote_participants}")
    print(f"****** Room remote participants keys: {room.remote_participants.keys()}")
    print(
        f"****** Room remote participants values: {room.remote_participants.values()}"
    )
    print(f"****** Room remote participants items: {room.remote_participants.items()}")
    print(f"****** Video Track: {video_track}")

    for _, participant in room.remote_participants.items():
        print(f"****** Participant: {participant}")
        for _, track_publication in participant.track_publications.items():
            print(f"****** Track Publication: {track_publication}")
            if track_publication.track is not None and isinstance(
                track_publication.track, rtc.RemoteVideoTrack
            ):
                print("****** Track Publication is a video track")
                video_track.set_result(track_publication.track)
                print(f"******Using video track {track_publication.track.sid}")
                break

    print(f"****** Video Track2: {video_track}")

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

    # print(f"****** latest_image: {latest_image}")

    if latest_image is None:
        # await get_video_track(self.ctx.room)
        print("****** latest_image is None")

    if use_image and latest_image:
        content.append(ChatImage(image=latest_image))

    chat_message = ChatMessage(role="user", content=content)
    chat_context.messages.append(chat_message)

    stream = openai.LLM().chat(chat_ctx=chat_context)
    print(f"Sending message to assistant: {text}")
    
    await assistant.say(stream, allow_interruptions=True)

    # Clear the imageReceived message after the assistant has spoken
    if use_image and latest_image:
        print("Removing message")
        chat_context.messages.remove(chat_message)


async def entrypoint(ctx: JobContext):
    print(f"****** ROOM NAME: {ctx.room.name}")

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

    chat = rtc.ChatManager(ctx.room)

    @chat.on("message_received")
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

    @assistant.on("function_calls_finished")
    def on_function_calls_finished(
        called_functions: list[agents.llm.CalledFunction],
    ) -> None:
        """Triggered when the assistant completes a function call."""
        print(f"Function calls finished: {called_functions}")

        if len(called_functions) == 0:
            print("No function calls finished")
            return

        user_msg = called_functions[0].call_info.arguments.get("user_msg")
        print(f" ** Found User message: {user_msg}")

        if user_msg:
            asyncio.create_task(
                _answer(
                    user_msg,
                    use_image=True,
                    chat_context=chat_context,
                    assistant=assistant,
                    latest_image=latest_video_image,
                )
            )

    assistant.start(ctx.room)

    await asyncio.sleep(1)
    await assistant.say("Hi there! How can I help?", allow_interruptions=True)

    while ctx.room.connection_state == rtc.ConnectionState.CONN_CONNECTED:
        video_track = await get_video_track(ctx.room)

        async for event in rtc.VideoStream(video_track):
            # We'll continually grab the latest image from the video track
            # and store it in a variable.
            latest_video_image = event.frame


if __name__ == "__main__":
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))