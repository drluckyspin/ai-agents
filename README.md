# Bain Agent Playground

Bain Agent Playground is a real-time Conversational Agent demonstration for testing voice agents. It uses:

- [LiveKit](https://livekit.io) WebRTC as the event major backbone
- [Deepgram](https://deepgram.com) Speech-to-Text API
- [OpenAI](https://openai.com/) ChatGPT API

## TL;DR

```bash
# Copy and add your API keys to env.bash
cp agents-backend/env.example agents-backend/env.bash 

# Copy and add your API keys to env.local
cp agents-frontend/.env.example agents-frontend/.env.local

# Run docker compose
docker-compose up

# Now connect to the frontend
open http://localhost:3000
```

## Manual installation

First, create a virtual environment, update pip, and install the required packages:

```bash
cd agents-backend

python3 -m venv .venv
source .venv/bin/activate

pip install -U pip
pip install -r requirements.txt

cp env.example env.bash
```

You need to set up the following environment variables in `env.bash` and `.env.local.` You can sign up for all accounts with the free tier.

```bash
LIVEKIT_URL=...
LIVEKIT_API_KEY=...
LIVEKIT_API_SECRET=...
DEEPGRAM_API_KEY=...
OPENAI_API_KEY=...
```

Then, run the backend assistant:

```bash
cd agents-backend
./run.sh [voice | video]
```

Finally, you want to run the Agent Playground UI:

```bash
cd agents-frontend
cp .env.example .env.local

npm install
npm run dev
```

Then navigate to <http://localhost:3000>.
