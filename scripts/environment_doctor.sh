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

status=0

print_tool() {
  tool_name=$1
  required=$2

  if command -v "$tool_name" >/dev/null 2>&1; then
    tool_path=$(command -v "$tool_name")
    printf '[ok] %-12s %s\n' "$tool_name" "$tool_path"
  else
    printf '[%s] %-12s not found\n' "$required" "$tool_name"
    if [ "$required" = 'required' ]; then
      status=1
    fi
  fi
}

printf '%s\n' 'ClearScan environment doctor'
printf 'Repository: %s\n' "$ROOT_DIR"
printf 'Flutter channel policy: %s\n' "$CLEARSCAN_FLUTTER_CHANNEL"
printf 'Pinned Flutter version: %s\n' "$CLEARSCAN_FLUTTER_VERSION"
printf 'Pinned Flutter release: %s\n' "$CLEARSCAN_FLUTTER_RELEASE_HASH"
printf 'Pinned Dart version: %s\n' "$CLEARSCAN_DART_VERSION"
printf 'Android application ID: %s\n' "$CLEARSCAN_ANDROID_APPLICATION_ID"
printf 'iOS bundle ID: %s\n' "$CLEARSCAN_IOS_BUNDLE_ID"
printf '\nTool availability\n'

print_tool python3 required
print_tool flutter required
print_tool dart required
print_tool git required
print_tool tar optional
print_tool unzip optional
print_tool java optional
print_tool adb optional
print_tool sdkmanager optional
print_tool xcodebuild optional
print_tool pod optional

if command -v dart >/dev/null 2>&1; then
  installed_dart_version=$(dart --version 2>&1 | sed -n 's/^Dart SDK version: \([^ ]*\).*/\1/p' | head -n 1)
  if [ "$installed_dart_version" != "$CLEARSCAN_DART_VERSION" ]; then
    printf '[required] Dart version mismatch: expected %s, found %s\n' \
      "$CLEARSCAN_DART_VERSION" \
      "${installed_dart_version:-unknown}" >&2
    status=1
  fi
fi

if command -v flutter >/dev/null 2>&1; then
  printf '\nFlutter version\n'
  flutter --version

  installed_flutter_version=$(flutter --version --machine 2>/dev/null | sed -n 's/.*"frameworkVersion":"\([^"]*\)".*/\1/p' | head -n 1)
  if [ "$installed_flutter_version" != "$CLEARSCAN_FLUTTER_VERSION" ]; then
    printf '[required] Flutter version mismatch: expected %s, found %s\n' \
      "$CLEARSCAN_FLUTTER_VERSION" \
      "${installed_flutter_version:-unknown}" >&2
    status=1
  fi

  printf '\nFlutter doctor\n'
  if ! flutter doctor -v; then
    status=1
  fi
fi

if [ "$status" -ne 0 ]; then
  printf '\nEnvironment is not ready for the complete Phase 0 gate.\n' >&2
  printf 'See docs/ENVIRONMENT_SETUP.md for the exact requirements.\n' >&2
  exit "$status"
fi

printf '\nEnvironment has the required base tools.\n'
