#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APK=''
OUTPUT="$ROOT_DIR/artifacts/phase0_launch/android"
DEVICE=''
SETTLE_SECONDS=5

usage() {
  cat <<'EOF'
Usage: ./scripts/capture_android_launch_evidence.sh --apk PATH [options]

Install and launch the real ClearScan Flutter APK on an already-running Android
emulator/device, capture screenshot/runtime evidence, and verify its manifest.

Options:
  --apk PATH            APK to install and launch (required).
  --output PATH         Evidence directory.
  --device SERIAL       Explicit adb device serial. Exactly one ready device is
                        required when omitted.
  --settle-seconds N    Seconds to wait before screenshot (default: 5).
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --apk) APK=${2:?Missing value for --apk}; shift 2 ;;
    --output) OUTPUT=${2:?Missing value for --output}; shift 2 ;;
    --device) DEVICE=${2:?Missing value for --device}; shift 2 ;;
    --settle-seconds) SETTLE_SECONDS=${2:?Missing value for --settle-seconds}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$APK" ] || { echo '--apk is required.' >&2; exit 2; }
APK=$(cd "$(dirname "$APK")" && pwd)/$(basename "$APK")
[ -f "$APK" ] || { echo "APK not found: $APK" >&2; exit 1; }
command -v adb >/dev/null 2>&1 || { echo 'adb is required.' >&2; exit 1; }

# shellcheck disable=SC1091
source "$ROOT_DIR/tool/project.env"
APP_ID=$CLEARSCAN_ANDROID_APPLICATION_ID
mkdir -p "$OUTPUT"
OUTPUT=$(cd "$OUTPUT" && pwd)

if [ -z "$DEVICE" ]; then
  mapfile -t READY_DEVICES < <(adb devices | awk 'NR>1 && $2 == "device" {print $1}')
  if [ "${#READY_DEVICES[@]}" -ne 1 ]; then
    echo "Expected exactly one ready adb device, found ${#READY_DEVICES[@]}." >&2
    adb devices -l >&2
    exit 1
  fi
  DEVICE=${READY_DEVICES[0]}
fi

ADB=(adb -s "$DEVICE")
"${ADB[@]}" get-state >/dev/null

{
  echo "ClearScan Android launch evidence"
  echo "application_id=$APP_ID"
  echo "device_serial=$DEVICE"
  echo "install_command=adb -s $DEVICE install -r <clearscan-debug.apk>"
  "${ADB[@]}" install -r "$APK"
  "${ADB[@]}" shell am force-stop "$APP_ID" || true
  COMPONENT=$("${ADB[@]}" shell cmd package resolve-activity --brief \
    -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$APP_ID" \
    | tr -d '\r' | tail -n 1)
  if [[ "$COMPONENT" != */* ]]; then
    echo "Unable to resolve launcher activity for $APP_ID: $COMPONENT" >&2
    exit 1
  fi
  echo "component=$COMPONENT"
  "${ADB[@]}" shell am start -W -n "$COMPONENT"
} 2>&1 | tee "$OUTPUT/android-launch.log"

sleep "$SETTLE_SECONDS"

{
  echo "serial=$DEVICE"
  echo "manufacturer=$("${ADB[@]}" shell getprop ro.product.manufacturer | tr -d '\r')"
  echo "model=$("${ADB[@]}" shell getprop ro.product.model | tr -d '\r')"
  echo "android_release=$("${ADB[@]}" shell getprop ro.build.version.release | tr -d '\r')"
  echo "sdk=$("${ADB[@]}" shell getprop ro.build.version.sdk | tr -d '\r')"
} > "$OUTPUT/android-device.txt"

"${ADB[@]}" shell dumpsys activity activities > "$OUTPUT/android-activity.txt"
grep -F "$APP_ID" "$OUTPUT/android-activity.txt" >/dev/null || {
  echo "ClearScan is not present in Android activity state after launch." >&2
  exit 1
}

"${ADB[@]}" exec-out screencap -p > "$OUTPUT/android-launch.png"
cp "$APK" "$OUTPUT/clearscan-debug.apk"

TARGET_NAME=$("${ADB[@]}" shell getprop ro.product.model | tr -d '\r')
OS_VERSION=$("${ADB[@]}" shell getprop ro.build.version.release | tr -d '\r')
python3 "$ROOT_DIR/scripts/write_phase0_launch_report.py" \
  --platform android \
  --identifier "$APP_ID" \
  --artifact "$OUTPUT/clearscan-debug.apk" \
  --screenshot "$OUTPUT/android-launch.png" \
  --target-name "$TARGET_NAME" \
  --os-version "$OS_VERSION" \
  --output "$OUTPUT/launch-report.json"

python3 "$ROOT_DIR/scripts/write_artifact_manifest.py" \
  --root "$OUTPUT" \
  --output "$OUTPUT/ARTIFACT_MANIFEST.json"
python3 "$ROOT_DIR/scripts/verify_phase0_launch_evidence.py" \
  --root "$OUTPUT" \
  --platform android

printf 'Android launch evidence captured: %s\n' "$OUTPUT"
