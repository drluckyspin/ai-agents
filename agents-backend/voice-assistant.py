import asyncio

from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, tts, tokenize
from livekit.agents.voice_assistant import VoiceAssistant
from livekit.plugins import deepgram, openai, silero
from livekit.agents.llm import ChatContext


# This function is the entrypoint for the agent.
async def entrypoint(ctx: JobContext):

    # Create an initial chat context with a system prompt for our Assistant
    chat_context = ChatContext().append(
        role="system",
        text=(
            "Your name is Nova. You are a funny, witty bot. Your interface with users will be voice."
            "Respond with short and concise answers. Avoid using unpronouncable punctuation."
        ),
    )

    # Connect to the LiveKit room
    # indicating that the agent will only subscribe to audio tracks
    await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)


    # Since GPT-4 is not supported by LiveKit, we'll use it with an LLMAdapter
    gpt = openai.LLM(model="gpt-4o")    

    # Since OpenAI does not support streaming TTS, we'll use it with a StreamAdapter
    # to make it compatible with the VoiceAssistant
    openai_tts = tts.StreamAdapter(
        tts=openai.TTS(voice="nova"),
        sentence_tokenizer=tokenize.basic.SentenceTokenizer(),
    )

    # VoiceAssistant is a class that creates a full conversational AI agent
    assistant = VoiceAssistant(
        vad=silero.VAD.load(),
        stt=deepgram.STT(),
        llm=gpt,
        tts=openai_tts,
        chat_ctx=chat_context,
    )

    # Start the voice assistant with the LiveKit room
    assistant.start(ctx.room)

    await asyncio.sleep(1)

    # Greets the user with an initial message
    await assistant.say("Hey, how can I help you today?", allow_interruptions=True)

    print(f"****** ROOM NAME: {ctx.room.name}")


if __name__ == "__main__":
    # Initialize the worker with the entrypoint
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))