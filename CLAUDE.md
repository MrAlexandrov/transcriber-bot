# CLAUDE.md

## Project Overview

Go Telegram bot that transcribes audio/video messages using a shared Whisper gRPC service.
The Whisper backend lives in a separate project: `backends/transcriber`.

**Language:** Go
**Deployment:** Docker Compose

## Key Files

| File | Purpose |
|------|---------|
| `bot/bot/handler.go` | Telegram handlers — voice, video, document messages; async poll loop |
| `bot/whisper/client.go` | gRPC client — Submit (async) + GetStatus |
| `bot/config/config.go` | Loads env vars, validates `BOT_TOKEN` and `ROOT_ID` |
| `proto/whisper.proto` | gRPC service definition — source of truth for all clients |
| `docker-compose.yml` | Bot + telegram-bot-api services (requires external `whisper-net`) |
| `Makefile` | All dev and deploy commands |

## Running & Building

```bash
# First time — Whisper backend must be running first
docker network create whisper-net        # once, on any machine
# then start backends/transcriber (make up there)

make up            # start bot
make logs          # bot logs
make down          # stop bot
make deploy        # full rebuild --no-cache
make proto-go      # regenerate Go stubs (local dev only, Docker builds them)
```

## Architecture Notes

- Whisper is a **standalone shared service** on Docker network `whisper-net` — not published to host
- Bot submits audio via `Submit` RPC → gets `job_id` immediately → polls `GetStatus` every 5s
- Bot replies to the original message with status, edits it when done
- `pollDeadline = 3h`, `pollInterval = 5s`
- gRPC max message size: **50MB**; Telegram local API handles files up to **2GB**
- Bot uses **polling** (not webhooks)
- Authorization: only user with `ROOT_ID` triggers transcription

## Proto / gRPC API

`proto/whisper.proto` is the source of truth for all clients connecting to the shared whisper service.

| RPC | Type | Description |
|-----|------|-------------|
| `Transcribe` | client-streaming (legacy) | Blocks until done |
| `Submit` | client-streaming | Returns `job_id` + queue position immediately |
| `GetStatus` | unary | Returns `PENDING/RUNNING/DONE/FAILED` + text |

When changing `proto/whisper.proto`, regenerate stubs:

```bash
make proto-go   # Go stubs (also regenerated in bot/Dockerfile)
```

Generated files — do not edit manually:
- `bot/gen/whisper/` (generated during Docker build, empty in repo)

## Environment Variables

Required in `.env`:
- `BOT_TOKEN` — Telegram bot token
- `ROOT_ID` — authorized Telegram user ID
- `TELEGRAM_API_ID`, `TELEGRAM_API_HASH` — for local Telegram Bot API server

Optional (set in compose):
- `WHISPER_GRPC_HOST` / `WHISPER_GRPC_PORT` — bot → whisper connection (default: `whisper:50053`)

## Common Pitfalls

- Use `docker compose` (not `docker-compose`) — Makefile uses the new syntax
- `whisper-net` must exist and Whisper service must be running before `make up`
- Large files require `telegram-bot-api` service; without it Telegram limits downloads to ~20MB
- Go stubs in `bot/gen/whisper/` are intentionally empty in the repo — generated at Docker build time
