#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

./scripts/check_offline.sh

if ! command -v flutter >/dev/null 2>&1; then
  echo "Offline repository checks passed, but Flutter is required for runtime checks." >&2
  echo "See docs/ENVIRONMENT_SETUP.md." >&2
  exit 1
fi

if ! command -v dart >/dev/null 2>&1; then
  echo "Dart is required and should be provided by the Flutter SDK." >&2
  exit 1
fi

if [ -d android ] && [ -d ios ]; then
  python3 scripts/verify_platforms.py
else
  echo "Platform verification skipped because android/ and ios/ are not both present."
fi

flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
