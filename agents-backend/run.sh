#!/bin/bash

# source the env file if it exists
if [ -f env.bash ]; then
    # shellcheck disable=SC1091
    source env.bash
fi

# check for an arg of "video" or "voice" and run the corresponding python assistant
if [ "$1" == "video" ]; then
    python video-assistant.py dev
elif [ "$1" == "voice" ]; then
    python voice-assistant.py dev
else
    echo "Usage: ./run.sh [voice | video] " 
fi