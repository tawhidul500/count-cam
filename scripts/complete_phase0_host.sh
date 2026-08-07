#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
INSTALL_PARENT="$ROOT_DIR/.tooling"
ARCHIVE_FILE=''
MANIFEST_FILE=''
SKIP_INSTALL=0

usage() {
  cat <<'EOF'
Usage: ./scripts/complete_phase0_host.sh [options]

Install or verify the pinned Flutter SDK, generate official Android/iOS runners,
run source checks, and capture host-native Phase 0 build evidence.

Options:
  --archive-file PATH   Use a previously downloaded Flutter SDK archive.
  --manifest-file PATH  Use a local official release-manifest snapshot.
  --install-parent PATH Install Flutter under PATH (default: .tooling).
  --skip-install        Use Flutter already available on PATH.
  -h, --help            Show this help.

Offline Linux x64 example:
  ./scripts/complete_phase0_host.sh \
    --archive-file /secure-transfer/flutter_linux_3.44.8-stable.tar.xz \
    --manifest-file tool/fixtures/flutter_releases_linux.json
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --archive-file)
      [ "$#" -ge 2 ] || { echo 'Missing value for --archive-file.' >&2; exit 2; }
      ARCHIVE_FILE=$2
      shift 2
      ;;
    --manifest-file)
      [ "$#" -ge 2 ] || { echo 'Missing value for --manifest-file.' >&2; exit 2; }
      MANIFEST_FILE=$2
      shift 2
      ;;
    --install-parent)
      [ "$#" -ge 2 ] || { echo 'Missing value for --install-parent.' >&2; exit 2; }
      INSTALL_PARENT=$2
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$ROOT_DIR"

if [ "$SKIP_INSTALL" -eq 0 ]; then
  install_args=(--install-parent "$INSTALL_PARENT")
  if [ -n "$ARCHIVE_FILE" ]; then
    install_args+=(--archive-file "$ARCHIVE_FILE")
    if [ -z "$MANIFEST_FILE" ] && [ "$(uname -s)" = 'Linux' ] && [ "$(uname -m)" = 'x86_64' ]; then
      MANIFEST_FILE='tool/fixtures/flutter_releases_linux.json'
    fi
  fi
  if [ -n "$MANIFEST_FILE" ]; then
    install_args+=(--manifest-file "$MANIFEST_FILE")
  fi

  ./scripts/install_flutter_sdk.sh "${install_args[@]}"
  export PATH="$(cd "$INSTALL_PARENT" && pwd)/flutter/bin:$PATH"
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter is not available on PATH after installation.' >&2
  exit 1
fi

./scripts/environment_doctor.sh
./scripts/bootstrap_platforms.sh
./scripts/capture_phase0_evidence.sh

cat <<'EOF'

Host automation finished.
This host supplies only its native build evidence. P00-T03 still requires:
- an Android launch record,
- an iOS launch record on macOS,
- evidence from both native platforms in docs/PHASE0_EVIDENCE.md.
EOF
