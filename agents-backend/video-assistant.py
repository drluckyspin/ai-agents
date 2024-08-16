import asyncio
from typing import Annotated

from livekit import agents, rtc
from livekit.agents import AutoSubscribe, JobContext, JobRequest, WorkerOptions, cli, tokenize, tts
from livekit.agents.llm import (
    ChatContext,
    ChatImage,
    ChatMessage,
    ChatRole,
)
from livekit.agents.voice_assistant import AssistantCallContext, VoiceAssistant
from livekit.plugins import deepgram, openai, silero


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
            agents.llm.TypeInfo(description="The user message that triggered this function"),
        ],
    ):
        print(f"****** Message triggering vision capabilities: {user_msg}")
        context = AssistantCallContext.get_current()
        context.store_metadata("user_msg", user_msg)

        print(f"****** Just stored user_msg: {context.get_metadata('user_msg')}")


async def get_video_track(room: rtc.Room):
    """Get the first video track from the room. We'll use this track to process images."""

    print(f"****** In GET VIDEO TRACK")

    video_track = asyncio.Future[rtc.RemoteVideoTrack]()

    # for _, participant in room.remote_participants.items():
    #     for _, track_publication in participant.tracks.items():
    #         if track_publication.track is not None and isinstance(
    #             track_publication.track, rtc.RemoteVideoTrack
    #         ):
    #             video_track.set_result(track_publication.track)
    #             print(f"Using video track {track_publication.track.sid}")
    #             break

    return await video_track


async def entrypoint(ctx: JobContext):
    print(f"****** ROOM NAME: {ctx.room.name}")

    chat_context = ChatContext().append(
        role="system",
        text=(
            "Your name is Nova. You are a funny, witty bot. Your interface with users will be voice and vision."
            "Respond with short and concise answers. Avoid using unpronouncable punctuation or emojis."
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

    latest_image: rtc.VideoFrame | None = None

    # Connect to the LiveKit room
    # indicating that the agent will only subscribe to all tracks
    await ctx.connect(auto_subscribe=AutoSubscribe.SUBSCRIBE_ALL)

    assistant = VoiceAssistant(
        vad=silero.VAD.load(),  # We'll use Silero's Voice Activity Detector (VAD)
        stt=deepgram.STT(),  # We'll use Deepgram's Speech To Text (STT)
        llm=gpt,
        tts=openai_tts,  # We'll use OpenAI's Text To Speech (TTS)
        fnc_ctx=AssistantFunction(),
        chat_ctx=chat_context,
    )

    chat = rtc.ChatManager(ctx.room)

    async def _answer(text: str, use_image: bool = False):
        """
        Answer the user's message with the given text and optionally the latest
        image captured from the video track.
        """
        args = {}
        if use_image and latest_image:
            args["images"] = [ChatImage(image=latest_image)]

        chat_context.append(role="user", text=text, **args)

        print(f"****** Chatcontext =: {chat_context}")

        stream = await gpt.chat(chat_ctx=chat_context)

        await assistant.say(stream, allow_interruptions=True)
 
        await assistant.say(stream)

    @chat.on("message_received")
    def on_message_received(msg: rtc.ChatMessage):
        """This event triggers whenever we get a new message from the user."""

        if msg.message:
            asyncio.create_task(_answer(msg.message, use_image=False))

    @assistant.on("function_calls_finished")
    # def on_function_calls_finished(ctx: AssistantCallContext):
    def on_function_calls_finished(function: AssistantFunction):
        """This event triggers when an assistant's function call completes."""        

        context = AssistantCallContext.get_current()
        user_msg = context.get_metadata("user_msg")

        print(f"****** Found user_msg: {user_msg}")
        
        
        if user_msg:
            asyncio.create_task(_answer(user_msg, use_image=True))

    assistant.start(ctx.room)

    await asyncio.sleep(1)
    await assistant.say("Hi there! How can I help?", allow_interruptions=True)

    while ctx.room.connection_state == rtc.ConnectionState.CONN_CONNECTED:
        video_track = await get_video_track(ctx.room)

        async for event in rtc.VideoStream(video_track):
            # We'll continually grab the latest image from the video track
            # and store it in a variable.
            latest_image = event.frame


if __name__ == "__main__":
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))