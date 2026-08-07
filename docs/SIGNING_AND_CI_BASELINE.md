# ClearScan Signing and CI Security Baseline

Updated: 2026-08-06
Status: Prepared for P00-T03 verification and P00-T04 owner approval

## Purpose

This document defines the minimum signing and continuous-integration security rules for the ClearScan foundation. It prepares P00-T04 but does not close that task before P00-T03 has passed on Android and iOS.

## Provisional application identifiers

- Android application ID: `com.clearscan.clearscan`
- iOS bundle ID: `com.clearscan.clearscan`
- Source of truth: `tool/project.env`
- Approval state: Provisional; final owner approval is still required in P00-T04.

Changing either identifier requires:

1. An entry in `DECISIONS.md`.
2. Regeneration or migration of native runner configuration.
3. A successful `scripts/verify_platforms.py` result.
4. Updated build and launch evidence.

## Flutter toolchain provenance

- Flutter version: `3.44.8`
- Flutter release commit: `058e0af2c2b57e369d905a03ac9748b0ebf543c6`
- Bundled Dart version expected from the official manifest: `3.12.2`
- Linux x64 archive SHA-256: `672089e001571a9fbb209a495c583580c0c6c73ef98999264ba07fa93ace332d`

`scripts/install_flutter_sdk.py` resolves the exact version and architecture from Flutter's official HTTPS release manifest, verifies the release commit, verifies the archive SHA-256, and then installs it. CI must not replace this with a mutable or unreviewed setup action.

## Android signing baseline

### Phase 0

- CI may create only debug APKs.
- The generated Flutter debug keystore is development-only and must never be treated as a production credential.
- No production keystore, key password, store password, or signing property file may be committed.
- Files matching `*.jks`, `*.keystore`, and local signing configuration remain ignored.

### Before release

- Select the final Play Console signing model.
- Create or register the upload key outside the repository.
- Store signing credentials only in an approved secret store.
- Document key ownership, backup, rotation, and recovery.
- Add a release-signing verification step without exposing secret values in logs.

## iOS signing baseline

### Phase 0

- CI builds the iOS simulator application with `--no-codesign`.
- No Apple development certificate, distribution certificate, private key, or provisioning profile is committed.
- The Apple Development Team remains unset until an owner-controlled Apple Developer account is available.
- Simulator build success is not evidence of App Store signing readiness.

### Before release

- Approve the final bundle ID in the Apple Developer account.
- Assign the correct development team.
- Configure development and distribution signing through an approved secret-management process.
- Document certificate and provisioning-profile ownership, expiry, rotation, and recovery.
- Validate archive and distribution on an owner-controlled macOS environment.

## CI trust baseline

The Phase 0 workflow must maintain all of the following:

- Default `GITHUB_TOKEN` permission is `contents: read`.
- `pull_request_target` is prohibited.
- Checkout credentials are not persisted.
- Every external action is pinned to a reviewed full commit SHA.
- The Flutter SDK is installed by repository-owned code from the official release manifest.
- No production signing secret is required by Phase 0 CI.
- Generated artifacts have short retention and are not committed to Git.
- Android and iOS build artifacts are evidence only, not release candidates.

Reviewed action pins:

- `actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd` (`v6.0.2`)
- `actions/upload-artifact@b7c566a772e6b6bfb58ed0dc250532a479d7789f` (`v6.0.0`)

`scripts/verify_ci_pins.py` is the executable policy check. Dependabot may propose updates, but a human or authorised project agent must review the new version and commit SHA before merging.

## Evidence required before Phase 0 closes

- Repository validation passes.
- Immutable CI pin validation passes.
- Official Flutter release resolution passes.
- Flutter formatting, analysis, and widget tests pass.
- Android debug APK builds and launches.
- iOS simulator application builds and launches.
- Generated application identifiers match `tool/project.env`.
- Final identifier and signing-baseline approval is recorded in `PHASE0_EVIDENCE.md`.

## Explicitly deferred

The following are not Phase 0 deliverables:

- Production Android app signing.
- App Store distribution signing.
- Store account creation.
- Production cloud credentials.
- Paid-service credentials.
- Release artifact publication.

## Connected GitHub execution security

`scripts/run_phase0_github_gate.sh` relies on an already-authenticated GitHub CLI session and does not accept or embed access tokens. It requires a clean git tree and verifies the tested commit exists in the selected repository before dispatch. Downloaded artifacts are re-verified locally before they can be recorded as Phase 0 evidence.

## Extracted-source publication baseline

When ClearScan is supplied as an artifact ZIP without git metadata, `bootstrap_phase0_github_repo.sh` is the approved Phase 0 publication helper. It is plan-only by default, requires explicit repository visibility and `--execute` for remote mutation, uses an already-authenticated GitHub CLI session, configures Git to use the GitHub CLI credential helper, refuses unexpected existing `origin` remotes, and never accepts a token as a command-line argument.

The helper runs `scripts/check_offline.sh` before publication so the publishing machine does not need Flutter; Flutter/native execution remains the responsibility of the hosted gate. Repository publication is not signing approval and does not close P00-T03 or P00-T04.
