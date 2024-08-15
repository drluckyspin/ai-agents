#!/bin/bash

export LIVEKIT_URL="wss://ai-agent-m6yr6kcs.livekit.cloud"
export LIVEKIT_API_KEY="APIf57vseihXhTS"
export LIVEKIT_API_SECRET="SU1w0UxNt3kfqYinQCkuVcGkwX6u0ur3KoQiybQe9mp"

export ELEVEN_API_KEY="sk_be52e2b3b4a0cce8dea0fc2d4af42c93b9e89e3e53c70c73"
export DEEPGRAM_API_KEY="eaa6280196c651d80e7095ab6c5717db6999058e"
export OPENAI_API_KEY="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"

# check for an arg of "video" or "voice" and run the corresponding python script
if [ "$1" == "video" ]; then
    echo "** Running Video assistant **"
    echo -e "\033[31m*** VIDEO ISN'T WORKING YET ***\033[0m"
    python video-assistant.py dev
elif [ "$1" == "voice" ]; then
    echo "** Running voice assistant **"
    python voice-assistant.py dev
else
    echo "Usage: ./run.sh [voice | video] " 
fi