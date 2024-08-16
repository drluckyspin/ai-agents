#!/bin/bash

source env.bash

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