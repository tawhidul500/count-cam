# ClearScan Connected Host Runbook

Updated: 2026-08-07
Status: Prepared for P00-T03 build-and-launch execution

## Purpose

This runbook is the supported path for completing ClearScan P00-T03 on connected Flutter/Android/macOS hosts or GitHub Actions. It preserves exact Flutter/Dart pins and generates auditable build and launch evidence rather than trusting a green job label.

## Preflight probe

```sh
python3 scripts/probe_p00_t03.py
```

To fail when the host is not ready:

```sh
python3 scripts/probe_p00_t03.py --require-ready
```

The probe does not mutate runners or install tools.

## Build/quality execution on a connected host

From the repository root:

```sh
./scripts/complete_phase0_host.sh
```

The command installs/verifies Flutter `3.44.8` with bundled Dart `3.12.2`, runs the environment doctor, generates official Android/iOS runners, verifies platform identifiers, and captures the host-native build evidence available on that machine.

For offline Linux x64:

```sh
./scripts/complete_phase0_host.sh \
  --archive-file /secure-transfer/flutter_linux_3.44.8-stable.tar.xz \
  --manifest-file tool/fixtures/flutter_releases_linux.json
```

The offline archive must match the centrally pinned SHA-256. Do not use a different Flutter/Dart version as gate-closing evidence.

## Android launch evidence on a connected target

Prerequisites:

- `adb` available
- one ready Android emulator or physical device
- real ClearScan Flutter debug APK already built

Run:

```sh
./scripts/capture_android_launch_evidence.sh \
  --apk /path/to/clearscan-debug.apk \
  --output artifacts/phase0_launch/android
```

The script installs the APK, resolves/starts the launcher activity, confirms ClearScan appears in Android activity state, captures device metadata and a PNG screenshot, writes a launch report + SHA-256 manifest, and runs `verify_phase0_launch_evidence.py`.

## iOS launch evidence on macOS

Prerequisites:

- Xcode command-line tools
- at least one available iPhone simulator
- real ClearScan iOS simulator ZIP already built

Run:

```sh
./scripts/capture_ios_launch_evidence.sh \
  --archive /path/to/clearscan-ios-simulator.zip \
  --output artifacts/phase0_launch/ios
```

The script selects/boots an available iPhone simulator, extracts Runner.app, installs and launches it with `simctl`, confirms the installed app container, captures simulator metadata and a PNG screenshot, writes a launch report + SHA-256 manifest, and runs the launch verifier.

## Preferred hosted GitHub Actions path

Push the repository to a controlled GitHub repository and run **Flutter quality gate** with `workflow_dispatch` or a protected `main`/`develop` run.

The hosted workflow performs the full sequence automatically:

1. exact pinned Flutter/Dart install
2. repository/source/evidence contract tests
3. `dart format`
4. `flutter analyze`
5. `flutter test`
6. official runner generation
7. Android build evidence verification
8. headless Android API 35 emulator provision + APK install/launch/screenshot + launch verification
9. iOS simulator build evidence verification
10. iPhone simulator install/launch/screenshot + launch verification
11. final combined gate summary

No separate third-party emulator GitHub Action is used. Android relies on the hosted runner's Android SDK tools; iOS relies on Xcode `simctl`.

Expected artifacts:

```text
clearscan-android-phase0
clearscan-ios-phase0
clearscan-phase0-summary
```

Inside the native artifacts, build and launch evidence remain separated so each manifest can be independently verified.


## From extracted ZIP to GitHub and gate run

If the ClearScan bundle is not yet a git clone, use the guarded bootstrap script. It is plan-only unless `--execute` is supplied:

```sh
./scripts/bootstrap_phase0_github_repo.sh \
  --repo OWNER/REPO \
  --visibility private
```

Review the printed plan, then explicitly allow repository initialization/creation/push and hosted gate dispatch:

```sh
./scripts/bootstrap_phase0_github_repo.sh \
  --repo OWNER/REPO \
  --visibility private \
  --branch main \
  --execute
```

For a new extracted source tree, the script requires `git user.name` and `git user.email` to already be configured rather than inventing an author identity. It runs repository-owned offline checks before publication, uses the already-authenticated GitHub CLI credential helper, creates the selected repository with the explicit visibility, pushes the exact commit, verifies that commit through the GitHub API, and then hands off to `run_phase0_github_gate.sh`.

If the target GitHub repository already exists, the script refuses to rewrite an unexpected `origin` remote. Use `--skip-gate` only when the goal is to publish the source without dispatching P00-T03 yet. No token is accepted as a command-line argument.

## One-command GitHub dispatch, download, verify, and record

On a connected git clone with GitHub CLI already authenticated, the preferred execution command is:

```sh
./scripts/run_phase0_github_gate.sh \
  --repo OWNER/REPO \
  --ref main
```

The script refuses to run from a dirty working tree, verifies that the current commit has already been pushed to the selected repository, dispatches `flutter-ci.yml`, watches the exact workflow run, downloads all run artifacts by run ID, and then runs the repository-owned downloaded-run verifier.

A successful collection writes:

```text
artifacts/github_phase0/<run-id>/run.json
artifacts/github_phase0/<run-id>/artifacts/...
artifacts/github_phase0/<run-id>/P00_T03_VERIFIED_HOSTED_RUN.json
artifacts/github_phase0/<run-id>/P00_T03_VERIFIED_HOSTED_RUN.md
```

The hosted summary now includes the full Git commit SHA and Git ref. The downloaded-run verifier requires those fields, independently verifies Android/iOS build bundles and launch bundles, recomputes the four retained SHA-256 values, and confirms the hosted summary contains those exact digests.

After reviewing a verified run, record it without dispatching again:

```sh
./scripts/run_phase0_github_gate.sh \
  --repo OWNER/REPO \
  --run-id RUN_ID \
  --record
```

`--record` updates only `docs/PHASE0_EVIDENCE.md`. It deliberately does not change `docs/TASKS.md`; P00-T03 must be moved to DONE only after the evidence record and warnings are reviewed.

If the workflow fails, the script still retains `run.json`, attempts artifact download, and captures failed logs when GitHub provides them. Do not treat a partial download as gate-closing evidence.

The script never accepts or embeds a GitHub token. Authentication must already exist in the user's `gh` session.

## Gate summary interpretation

`clearscan-phase0-summary/P00_T03_HOSTED_GATE_SUMMARY.md` must report:

```text
Verified hosted build evidence ready: YES
Verified hosted launch evidence ready: YES
P00-T03 gate-closing evidence ready: YES
```

Only an actual run with that final state can satisfy the executable portion of P00-T03. Record the run URL, commit, target details, APK/iOS archive SHA-256 values, launch screenshot SHA-256 values, and warnings in `docs/PHASE0_EVIDENCE.md` before changing task status.

If builds pass but a launch fails, retain the uploaded partial launch diagnostics and retry. Do not downgrade launch verification to a filename check or use the non-Flutter preview APK as evidence.

## Evidence verification after download

Build evidence:

```sh
python3 scripts/verify_phase0_evidence.py \
  --root <build-evidence-directory> \
  --platform android
```

Launch evidence:

```sh
python3 scripts/verify_phase0_launch_evidence.py \
  --root <launch-evidence-directory> \
  --platform android
```

Use `--platform ios` for iOS.

## What Phase 0 launch evidence does not prove

Hosted emulator/simulator launches prove that generated native runners build and launch cross-platform. They do not prove camera permission behaviour, physical-camera capture, storage semantics, performance on low-end devices, TalkBack/VoiceOver usability, or release signing. Those remain later production/release QA work.
