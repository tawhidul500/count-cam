# ClearScan Development Environment

Updated: 2026-08-07
Status: Phase 0 verification guide

## Purpose

This guide defines the toolchain required to generate the native runners, run the quality gate, and close Phase 0 consistently on another machine or with another AI coding environment.

## Required base tools

- Flutter SDK `3.44.8` on the stable channel, matching `.flutter-version`
- Dart SDK `3.12.2`, supplied by the pinned Flutter release and verified against the official release manifest
- Git
- Python 3 for repository-contract validation
- A working network connection for the first Flutter artifact and package download

## Android requirements

- Supported Java Development Kit
- Android Studio or command-line Android SDK tools
- Android SDK platform and build tools compatible with the installed Flutter release
- An Android emulator or a connected physical device
- Accepted Android SDK licences

Verify Android readiness with:

```sh
flutter doctor -v
adb devices
```

## iOS requirements

Building and launching the iOS application requires macOS with:

- Xcode
- Xcode command-line tools
- CocoaPods when requested by the generated Flutter project
- An iOS simulator or a connected, provisioned physical device

A Linux or Windows machine may generate the iOS template files, but final iOS build, signing, simulator, and device verification must be performed on macOS.

## Central project settings

Platform-generation values are stored in `tool/project.env`.

Current provisional values:

- Flutter channel policy: `stable`
- Pinned Flutter version: `3.44.8`
- Pinned Dart version: `3.12.2`
- Project name: `clearscan`
- Organisation: `com.clearscan`
- Android application ID: `com.clearscan.clearscan`
- iOS bundle ID: `com.clearscan.clearscan`

Do not change these values silently. Record any accepted change in `docs/DECISIONS.md`, `docs/TASKS.md`, and `docs/HANDOFF.md`.

## Install the pinned Flutter SDK

On Linux x64, the repository provides a resumable local installer:

```sh
./scripts/install_flutter_sdk.sh
export PATH="$PWD/.tooling/flutter/bin:$PATH"
```

The shell command delegates to `scripts/install_flutter_sdk.py`, so local, offline, and host-completion paths use the same official-manifest resolution and SHA-256 verification. It also rejects a Flutter release whose bundled Dart version differs from the central `3.12.2` pin. The default install lives under `.tooling/`, which is ignored by Git. macOS developers may use the same verified installer when connected; other platforms must use the exact pinned Flutter release through an approved method.


## Diagnose a blocked host without claiming gate completion

Run:

```sh
python3 scripts/probe_p00_t03.py
```

The probe always captures source-contract results, central Flutter/Dart pins, tool availability, runner presence, and official release-storage connectivity under `artifacts/p00_t03_probe/`. Add `--require-ready` when an automation should fail unless the current host has local prerequisites to execute P00-T03. The probe is diagnostic only and never substitutes for real Flutter format/analyze/test/build/launch evidence.

## Exact continuation procedure

From the repository root:

```sh
./scripts/environment_doctor.sh
./scripts/bootstrap_platforms.sh
```

The bootstrap script will:

1. Validate the repository contract.
2. Generate official Android and iOS Flutter runner templates.
3. Fetch project dependencies.
4. Check formatting.
5. Run static analysis.
6. Run automated tests.
7. Verify the generated Android and iOS identifiers.
8. Print the expected identifiers for manual review.

After it completes, run and record:

```sh
flutter devices
flutter run -d <android-device-id>
```

On macOS, also run:

```sh
flutter run -d <ios-simulator-or-device-id>
```

To capture timestamped format, analysis, test, identifier, and native-build logs, run:

```sh
./scripts/capture_phase0_evidence.sh
```

Follow `docs/PHASE0_EVIDENCE.md` for the permanent evidence record.

## Evidence required to close P00-T03

Record all evidence in `docs/QA_CHECKLIST.md` and `docs/HANDOFF.md`:

- Flutter version `3.44.8` and the bundled Dart version
- `flutter doctor -v` result
- Generated `android/` directory
- Generated `ios/` directory
- Formatting result
- Analysis result
- Test result
- Android launch target and result
- iOS launch target and result
- Any warnings or temporary workarounds

## Continuous integration

`.github/workflows/flutter-ci.yml` provides separate source-quality, Android-build, and iOS-simulator-build jobs after the repository is pushed to GitHub. The native jobs generate official Flutter runners, verify the central identifiers, build debug artifacts, and upload short-retention evidence artifacts.

The workflow does not replace emulator/device launch testing, final native identifier approval, Android signing review, or iOS signing review.

## GitHub-only publishing host (Flutter not required locally)

A machine that only needs to publish the extracted source and dispatch the hosted P00-T03 workflow requires Git, Python 3, GitHub CLI, a configured git author identity, and an authenticated GitHub CLI session. Local Flutter/Android/Xcode are not required for this publication path.

First review the non-mutating plan:

```sh
./scripts/bootstrap_phase0_github_repo.sh \
  --repo OWNER/REPO \
  --visibility private
```

Then explicitly execute:

```sh
./scripts/bootstrap_phase0_github_repo.sh \
  --repo OWNER/REPO \
  --visibility private \
  --execute
```

The helper runs `scripts/check_offline.sh`, pushes the exact commit, and hands off to the hosted build/launch collector. Do not interpret repository creation as native verification evidence.

## Current container limitation

The container used for the latest session has Git, Java, Python, and shell tooling, but it does not contain Flutter, Dart, Android SDK tools, or Xcode. External SDK hosts are also unreachable from the container, including direct-IP connection attempts, so the pinned installer cannot execute here. The container can validate repository and source contracts, but it cannot close the native runtime gate.
