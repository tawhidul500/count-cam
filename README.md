# ClearScan

ClearScan is an original, privacy-first document scanner for Android and iOS. It is designed to scan, enhance, organise, search, export, and share documents without copying the interface, branding, assets, wording, or proprietary workflows of any existing scanner product.

## Current status

- Document viewer, multi-page editor, crop/filter, PDF/OCR, Share, Search, folder management, onboarding, Documents Library, richer Settings, Help/Feedback, About, Privacy Policy, Terms, scanner permission/import/capture-review, auto-capture education, temporary capture-session page-strip, and scan-session completion prototypes are implemented in source. Title, folder, page order, save preview, preferences, storage figures, cleanup, privacy controls, document changes, scanner states, imports, captures, and all service actions remain mock, session-only, and non-persistent.

- Native gate: Phase 0 `P00-T03` is the active task and remains BLOCKED pending real Flutter/Android/iOS verification
- Visible UI prototype track: Phase 1 (`P01-T00`) source is complete and in REVIEW; Flutter runtime evidence is pending
- Source foundation: complete (`P00-T02`)
- Native Android/iOS runners: pending official Flutter generation
- Runtime test: authored; Flutter execution is pending a Flutter-enabled environment or CI run
- Native evidence automation: one-command host execution, GitHub dispatch/watch/download/verify tooling, Android/iOS CI build jobs, hosted Android-emulator/iOS-simulator launch capture, failure-log retention, separate SHA-256 build/launch manifests, completed-bundle verification, and a single hosted P00-T03 gate summary are ready
- CI supply-chain baseline: immutable reviewed action SHAs and repository-owned verified Flutter installation
- Active gate: P00-T03 - native generation and Flutter verification
- Continuation source of truth: `docs/HANDOFF.md`

## Repository map

- `lib/app/`: application configuration, themes, and shell
- `lib/core/`: shared platform-independent utilities, adaptive layout frames, accessible state panels, and status announcements
- `lib/features/`: feature-first modules, including visible scanner permission/import/review/session/completion, viewer, editor, crop, filter, PDF export, OCR, Share, Search, folder-management, onboarding, Documents Library, Settings-detail, support, and legal-content prototypes
- `docs/`: product, architecture, tasks, decisions, QA, UI audit, and handoff records
- `test/`: widget and unit tests
- `integration_test/`: later end-to-end tests
- `scripts/`: environment probe, verified SDK installation, one-command host completion, GitHub workflow dispatch/download verification, platform bootstrap, native build/launch evidence capture and verification, hosted gate-summary generation/recording, and validation commands
- `tool/project.env`: central platform identifiers plus pinned Flutter `3.44.8` and Dart `3.12.2` versions
- `.flutter-version`: editor/toolchain-friendly Flutter version pin
- `.github/workflows/flutter-ci.yml`: source-quality, Android build+emulator launch, iOS simulator build+launch, and end-of-run Phase 0 summary gates
- `.github/dependabot.yml`: controlled GitHub Actions update proposals
- `docs/SIGNING_AND_CI_BASELINE.md`: signing and CI security rules
- `docs/PHASE0_EVIDENCE.md`: permanent Phase 0 evidence index
- `docs/CONNECTED_HOST_RUNBOOK.md`: exact online and offline commands for Android/iOS evidence hosts
- `assets/reference/`: approved visual direction reference

## Bootstrap on a Flutter-enabled machine

Before changing the environment, capture a diagnostic snapshot with `python3 scripts/probe_p00_t03.py`. The probe never closes the gate; it records static checks, exact pins, tool availability, runner presence, and release-storage connectivity.

1. Complete the Android/iOS platform requirements in `docs/ENVIRONMENT_SETUP.md`.
2. Run `./scripts/complete_phase0_host.sh` on a connected evidence host. The command installs the pinned Flutter SDK, generates the native runners, runs the quality gate, builds the host-native artifact, and writes a SHA-256 evidence manifest.
3. For an offline Linux x64 host, pass the transferred SDK archive and the repository fixture as described in `docs/CONNECTED_HOST_RUNBOOK.md`.
4. Review generated identifiers and signing configuration.
5. For local/connected-host evidence, capture launches with `scripts/capture_android_launch_evidence.sh` and `scripts/capture_ios_launch_evidence.sh`; the hosted workflow performs equivalent emulator/simulator launch capture automatically.
6. Update `docs/PHASE0_EVIDENCE.md`, `docs/QA_CHECKLIST.md`, `docs/HANDOFF.md`, and `docs/TASKS.md` with verified build and launch evidence.

For the preferred GitHub-hosted path, use `./scripts/run_phase0_github_gate.sh --repo OWNER/REPO --ref main`. The script requires an authenticated `gh` session and a clean, already-pushed commit; it dispatches/watches the workflow, downloads the exact run artifacts, re-verifies Android/iOS build and launch evidence locally, and writes `P00_T03_VERIFIED_HOSTED_RUN.{json,md}`. Add `--record` only after reviewing the downloaded run; this updates `docs/PHASE0_EVIDENCE.md` but does not mark P00-T03 DONE.

The bootstrap command merges generated platform files into this source repository. Commit or back up the repository before running it so generated changes can be reviewed.

## Product principles

- Essential scanning remains useful without an account.
- Documents stay local unless the user explicitly enables cloud backup.
- Original images are preserved until the user confirms destructive processing.
- Important project decisions are written to the repository, not left only in chat history.
- The app must remain accessible, responsive, and consistent across all screens.

## Fastest connected GitHub bootstrap for P00-T03

If this source was downloaded as a ZIP and therefore has no `.git` metadata, use the guarded bootstrap command from the repository root:

```sh
./scripts/bootstrap_phase0_github_repo.sh \
  --repo OWNER/REPO \
  --visibility private
```

The default is plan-only. After reviewing the target repository, visibility, branch, and gate action, rerun with `--execute` to initialize git when needed, create or attach the GitHub repository, push the exact commit, and dispatch the existing P00-T03 hosted gate. The script requires an already-authenticated GitHub CLI session and never accepts a token argument.

```sh
./scripts/bootstrap_phase0_github_repo.sh \
  --repo OWNER/REPO \
  --visibility private \
  --execute
```

P00-T03 remains BLOCKED until the downloaded build and launch evidence independently verifies and is reviewed.
