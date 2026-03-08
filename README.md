# Transcriber Bot

Telegram bot for transcribing audio and video messages into text using OpenAI Whisper via gRPC.

## Features

- Voice messages (OGG)
- Video notes / circles (MP4)
- Regular videos (MP4)
- Large video files sent as documents (up to 2GB)
- Russian language transcription
- Authorization — only the configured owner can use the bot

## Architecture

Three Docker services communicate together:

```
Telegram API
     │
     ▼
 [Bot Service]  ──gRPC──►  [Whisper Service]
     │
     ▼
[Telegram Bot API Server]  (optional local server)
```

- **Bot Service** (`bot/`) — receives messages, downloads media, calls Whisper via gRPC, returns text
- **Whisper Service** (`whisper/`) — runs `faster-whisper` model, exposes gRPC API
- **Telegram Bot API Server** — local Telegram API server for handling large files

Inter-service communication is defined in `proto/whisper.proto`.

## Prerequisites

- Docker & Docker Compose
- (For local dev) Python 3.11+, [Poetry](https://python-poetry.org/)

## Setup

1. Copy the example env file and fill in the values:

```bash
cp .env.example .env
```

2. Set the required variables in `.env`:

```env
BOT_TOKEN=<your Telegram bot token>
ROOT_ID=<your Telegram user ID>
TELEGRAM_API_ID=<Telegram API ID>
TELEGRAM_API_HASH=<Telegram API hash>
```

## Running

### Docker (recommended)

```bash
make up       # Build and start all services
make logs     # Follow logs
make down     # Stop all services
```

### Full rebuild

```bash
make deploy   # Rebuild without cache and start
```

### Local development

```bash
make install  # Install dependencies via Poetry
make run      # Run bot locally
```

## Environment Variables

| Variable                | Required | Description                                      |
|-------------------------|----------|--------------------------------------------------|
| `BOT_TOKEN`             | Yes      | Telegram bot token from @BotFather               |
| `ROOT_ID`               | Yes      | Telegram user ID authorized to use the bot       |
| `TELEGRAM_API_ID`       | Yes*     | Telegram API ID (for local API server)           |
| `TELEGRAM_API_HASH`     | Yes*     | Telegram API hash (for local API server)         |
| `WHISPER_MODEL`         | No       | Whisper model size: `tiny`, `base`, `small`, `medium`, `large` (default: `base`) |
| `GRPC_PORT`             | No       | Whisper gRPC port (default: `50053`)             |

*Required for the `telegram-bot-api` service to handle large files.

## Makefile Targets

| Target         | Description                                      |
|----------------|--------------------------------------------------|
| `make install` | Install Python dependencies via Poetry           |
| `make run`     | Run bot locally                                  |
| `make proto`   | Regenerate gRPC code from `.proto` files         |
| `make up`      | Stop, build, and start all Docker services       |
| `make deploy`  | Full rebuild without cache and start             |
| `make restart` | Restart services with rebuild                    |
| `make down`    | Stop all Docker services                         |
| `make logs`    | Follow Docker logs                               |
| `make clean`   | Remove Python cache files                        |
| `make docker-clean` | Remove Docker containers, images, and volumes |

## Project Structure

```
.
├── main.py                  # Entry point
├── bot/
│   ├── bot.py               # Telegram handlers and main logic
│   ├── config.py            # Config and env loading
│   └── whisper_client.py    # gRPC client for Whisper service
├── whisper/
│   ├── main.py              # gRPC server entry point
│   ├── server.py            # Transcription service implementation
│   └── Dockerfile
├── proto/
│   └── whisper.proto        # gRPC service definition
├── Dockerfile               # Bot service image
└── docker-compose.yml       # Multi-service orchestration
```
