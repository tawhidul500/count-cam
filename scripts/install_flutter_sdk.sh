#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if ! command -v python3 >/dev/null 2>&1; then
  echo 'Python 3 is required to run the verified Flutter installer.' >&2
  exit 1
fi

exec python3 "$ROOT_DIR/scripts/install_flutter_sdk.py" "$@"
