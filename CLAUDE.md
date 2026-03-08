# CLAUDE.md

## Project Overview

Python Telegram bot that transcribes audio/video messages using OpenAI Whisper. Multi-service architecture: bot + whisper gRPC server + optional local Telegram API server.

**Language:** Python 3.11+
**Package manager:** Poetry (`pyproject.toml`)
**Deployment:** Docker Compose

## Key Files

| File | Purpose |
|------|---------|
| `bot/bot.py` | Main bot handlers — voice, video, document messages |
| `bot/whisper_client.py` | gRPC client (50MB max, 120s timeout) |
| `bot/config.py` | Loads `.env`, validates `BOT_TOKEN` and `ROOT_ID` |
| `whisper/server.py` | Whisper model runner — language=ru, VAD, int8, CPU |
| `proto/whisper.proto` | gRPC service definition |
| `docker-compose.yml` | Three services: telegram-bot-api, whisper, bot |
| `Makefile` | All dev and deploy commands |

## Running & Building

```bash
make up       # Build and start (uses docker compose, not docker-compose)
make deploy   # Full rebuild --no-cache
make logs     # Follow logs
make proto    # Regenerate gRPC stubs from proto/whisper.proto
make install  # Poetry install for local dev
make run      # Run bot locally (no Docker)
```

## Architecture Notes

- Bot downloads media → sends bytes via gRPC → Whisper returns text
- gRPC max message size: **50MB**; Telegram local API handles files up to **2GB**
- Bot uses **polling** (not webhooks) — webhook vars in `.env` are unused
- Authorization: only user with `ROOT_ID` can trigger transcription
- Whisper runs on **CPU** with **int8** quantization and **VAD filter**
- `WHISPER_MODEL` env var controls model size (default `base` in compose, `small` in server default)

## Proto / gRPC

When changing `proto/whisper.proto`, regenerate stubs:

```bash
make proto
```

This runs `grpcio-tools` and fixes the import path in the generated `_grpc.py` file via `sed`.

Generated files (do not edit manually):
- `proto/whisper_pb2.py`
- `proto/whisper_pb2_grpc.py`

## Environment Variables

Required in `.env`:
- `BOT_TOKEN` — Telegram bot token
- `ROOT_ID` — authorized Telegram user ID
- `TELEGRAM_API_ID`, `TELEGRAM_API_HASH` — for local Telegram Bot API server

Optional (set in `docker-compose.yml`):
- `WHISPER_MODEL` — model size
- `GRPC_PORT` — default 50053
- `WHISPER_GRPC_HOST` / `WHISPER_GRPC_PORT` — bot → whisper connection

## Common Pitfalls

- Use `docker compose` (not `docker-compose`) — Makefile uses the new syntax
- `.env.example` exists but is empty — fill it in manually
- Whisper model download happens at container start — first run is slow
- Large files require `telegram-bot-api` service to be running; without it, Telegram limits downloads to ~20MB
