"""Configuration and logging setup for the transcriber bot."""

import logging
import os

from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN: str = os.getenv("BOT_TOKEN", "")
ROOT_ID: int = int(os.getenv("ROOT_ID", "0"))
WEBHOOK_URL: str = os.getenv("WEBHOOK_URL", "")
WEBHOOK_PORT: int = int(os.getenv("WEBHOOK_PORT", "8080"))
WEBHOOK_SECRET: str = os.getenv("WEBHOOK_SECRET", "")

if not BOT_TOKEN:
    raise ValueError("BOT_TOKEN environment variable is not set")
if not ROOT_ID:
    raise ValueError("ROOT_ID environment variable is not set")
if not WEBHOOK_URL:
    raise ValueError("WEBHOOK_URL environment variable is not set")
if not WEBHOOK_SECRET:
    raise ValueError("WEBHOOK_SECRET environment variable is not set")

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
