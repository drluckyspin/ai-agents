# LiveKit Assistant

First, create a virtual environment, update pip, and install the required packages:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
```

You need to set up the following environment variables in `run.sh`. You can sign up for all accounts with the free tier.

```bash
LIVEKIT_URL=...
LIVEKIT_API_KEY=...
LIVEKIT_API_SECRET=...
DEEPGRAM_API_KEY=...
OPENAI_API_KEY=...
```

Then, run the assistant:

```bash
./run.sh [voice | video]
```

Finally, you want to run the Agent Playground UI:

```bash
cd agents-frontend
npm install
npm run dev
```

Then navigate to <http://localhost:3000>.
