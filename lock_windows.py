#!/usr/bin/env python3
"""Send Win+L to the Windows machine connected via GLKVM (PiKVM-compatible)."""

from __future__ import annotations

import logging
import sys
from pathlib import Path

from pikvm_lib import PiKVM

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
log = logging.getLogger("glkvm-autolock")

ENV_PATH = Path(__file__).resolve().parent / ".env"
ENV_KEY = "GLKVM_PASSWORD"


def load_password(env_path: Path, key: str) -> str:
    if not env_path.exists():
        log.error(".env not found at %s — run `make install` first", env_path)
        sys.exit(1)
    for raw in env_path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        name, sep, value = line.partition("=")
        if not sep or name.strip() != key:
            continue
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        return value
    log.error("%s not found in %s", key, env_path)
    sys.exit(1)


def main() -> None:
    password = load_password(ENV_PATH, ENV_KEY)
    log.info("Connecting to GLKVM at localhost as admin")
    kvm = PiKVM(hostname="localhost", username="admin", password=password)
    try:
        kvm.hotkey("win", "l")
    except Exception:
        log.exception("Failed to send Win+L")
        sys.exit(1)
    log.info("Sent Win+L successfully")


if __name__ == "__main__":
    main()
