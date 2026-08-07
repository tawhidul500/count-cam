#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PROJECT_ENV="$ROOT_DIR/tool/project.env"

if [ ! -f "$PROJECT_ENV" ]; then
  echo "Missing required project configuration: $PROJECT_ENV" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$PROJECT_ENV"

cd "$ROOT_DIR"
python3 scripts/validate_project.py
python3 scripts/source_contract_test.py
python3 scripts/verify_ci_pins.py

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is required. Install a stable Flutter SDK first." >&2
  echo "See docs/ENVIRONMENT_SETUP.md." >&2
  exit 1
fi

if ! command -v dart >/dev/null 2>&1; then
  echo "Dart is required and should be provided by the Flutter SDK." >&2
  exit 1
fi

installed_flutter_version=$(flutter --version --machine 2>/dev/null | sed -n 's/.*"frameworkVersion":"\([^"]*\)".*/\1/p' | head -n 1)
if [ "$installed_flutter_version" != "$CLEARSCAN_FLUTTER_VERSION" ]; then
  echo "Flutter version mismatch. Expected $CLEARSCAN_FLUTTER_VERSION, found ${installed_flutter_version:-unknown}." >&2
  echo "Run ./scripts/install_flutter_sdk.sh or install the pinned version manually." >&2
  exit 1
fi

if [ -d android ] || [ -d ios ]; then
  echo "Platform directories already exist; generation will merge official Flutter templates."
  echo "Review the working tree before and after this command."
fi

flutter create \
  --org "$CLEARSCAN_ORGANIZATION" \
  --project-name "$CLEARSCAN_PROJECT_NAME" \
  --platforms "$CLEARSCAN_PLATFORMS" \
  --no-pub \
  .

if [ ! -d android ] || [ ! -d ios ]; then
  echo "Flutter did not generate both Android and iOS platform directories." >&2
  exit 1
fi

python3 scripts/verify_platforms.py
flutter pub get
./scripts/check.sh

cat <<SUMMARY

Platform generation completed.

Expected identifiers pending owner approval:
- Android: $CLEARSCAN_ANDROID_APPLICATION_ID
- iOS:     $CLEARSCAN_IOS_BUNDLE_ID

Next actions:
1. Verify generated identifiers in Android and iOS project files.
2. Launch on an Android emulator or device.
3. Launch on an iOS simulator or device from macOS.
4. Record evidence in docs/QA_CHECKLIST.md and docs/HANDOFF.md.
SUMMARY
