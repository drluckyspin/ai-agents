import asyncio
import os

from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, tts, tokenize
from livekit.agents.voice_assistant import VoiceAssistant
from livekit.plugins import deepgram, openai, silero
from livekit.agents.llm import ChatContext

from log import BasicLogger

# Initialize the logger
logger = BasicLogger()

async def entrypoint(ctx: JobContext):
    """
        This function is the main entrypoint for the agent.
    """

    # Create an initial chat context with a system prompt for our Assistant
    chat_context = ChatContext().append(
        role="system",
        text=(
            "Your name is Nova. You are a funny, witty bot. Your interface with users will be voice."
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

    # Connect to the LiveKit room
    # indicating that the agent will only subscribe to audio tracks
    await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)

    # VoiceAssistant is a class that creates a full conversational AI agent
    assistant = VoiceAssistant(
        vad=silero.VAD.load(),
        stt=deepgram.STT(),
        llm=gpt,
        tts=openai_tts,
        chat_ctx=chat_context,
    )

    # Start the voice assistant with the LiveKit room
    assistant.start(room=ctx.room)
    await asyncio.sleep(delay=1)

    # Greets the user with an initial message
    await assistant.say(
        source="Hey, how can I help you today?", allow_interruptions=True
    )

    


if __name__ == "__main__":

    logger.log_separator()
    logger.log(message="Starting Voice Assistant")
    logger.log_info(message=f"Livekit URL: {os.getenv('LIVEKIT_URL')}")

    # Initialize the worker with the entrypoint
    cli.run_app(opts=WorkerOptions(entrypoint_fnc=entrypoint))