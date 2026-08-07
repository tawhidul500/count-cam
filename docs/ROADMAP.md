# ClearScan Roadmap

Updated: 2026-08-07

Status values: BACKLOG, READY, IN_PROGRESS, BLOCKED, REVIEW, DONE

## Phase 0 - Project Foundation

- Status: BLOCKED
- Objective: Establish the source repository, documentation system, configuration, quality rules, minimal app shell, and startup test.
- Deliverables: Project structure, `/docs`, task IDs, handoff process, theme-token baseline, minimal app, validation scripts, central platform settings, pinned Flutter/Dart toolchain, blocked-host readiness probe, environment doctor, unified verified local installer, offline source-contract check, generated-platform identifier verification, evidence capture, native evidence-bundle integrity verification, failure-log retention, Android/iOS CI build gates, automated Android-emulator/iOS-simulator launch evidence with separate integrity verification, an always-produced hosted P00-T03 gate summary with verified build and launch digests, and a guarded extracted-bundle-to-GitHub bootstrap path that does not require local Flutter.
- Dependencies: Flutter SDK is required for native runner generation and runtime checks.
- Acceptance criteria:
  - Required files exist and are non-empty.
  - Android and iOS runners are generated.
  - `flutter analyze` passes.
  - Startup widget test passes.
  - `HANDOFF.md` identifies the exact next task.

## Phase 1 - Design System and Application Shell

- Status: REVIEW (visible source prototype complete; Flutter/native verification still pending)
- Objective: Convert the visual direction into a reusable, accessible component system and stable app shell.
- Deliverables: Light and dark themes, typography, colour, spacing, radius, shadows, icons, buttons, cards, dialogs, states, navigation, router, plus owner-directed source prototypes for document viewing, multi-page editing, crop adjustment, filter selection, PDF export, OCR, sharing, document actions, Search, temporary folder management, Settings-launched onboarding education, a session-only Documents Library, richer Settings preferences/storage/cleanup/privacy details, and Help/About/draft Privacy Policy/Terms content prototypes, plus scanner permission-state, safe import-source, capture-review, auto-capture education, temporary multi-page capture-session, non-persistent scan-session completion, reusable loading/empty/error states, unsaved-exit education, and source-level responsive/accessibility audit patterns.
- Dependencies: Phase 0 gate. The owner explicitly authorised visible source implementation before native-toolchain verification; this exception does not waive runtime acceptance criteria.
- Acceptance criteria: Component catalogue is documented and tested; navigation shell works on representative phone and tablet sizes.

## Phase 2 - Onboarding and Home

- Status: BACKLOG (a non-persistent Settings preview exists under P01-T00; formal first-run state remains unimplemented)
- Objective: Build the first-use experience and primary document-management entry point.
- Deliverables: Splash, onboarding, privacy explanation, permission education, home, quick actions, recent documents, empty states.
- Dependencies: Phase 1.
- Acceptance criteria: New users can reach Home without an account; mock data is isolated behind a repository interface.

## Phase 3 - Local Document Library

- Status: BACKLOG
- Objective: Persist and manage documents, pages, folders, favourites, and deletion states locally.
- Deliverables: Database, migrations, repositories, list/grid views, rename, favourite, sort, delete, restore.
- Dependencies: Phase 1; data schema approval.
- Acceptance criteria: CRUD operations survive restart and migration tests pass.

## Phase 4 - Camera Scanner

- Status: BACKLOG
- Objective: Capture high-quality document images with safe permission and interruption handling.
- Deliverables: Camera preview, permission states, flash, capture, gallery import, scan modes, processing feedback.
- Dependencies: Phase 1, camera package decision, platform runners.
- Acceptance criteria: Capture/import works on supported Android and iOS devices; denied permissions are recoverable.

## Phase 5 - Edge Detection and Crop Editor

- Status: BACKLOG
- Objective: Detect document boundaries and transform captures into flat document images.
- Deliverables: Edge service abstraction, overlay, manual corner controls, perspective correction, rotate, retake, confirm.
- Dependencies: Phase 4; image-processing spike.
- Acceptance criteria: Manual correction always remains available and representative documents export with correct geometry.

## Phase 6 - Filters and Image Adjustment

- Status: BACKLOG
- Objective: Improve readability without destroying originals.
- Deliverables: Filter previews, enhancement modes, brightness, contrast, saturation, sharpness, highlights, shadows.
- Dependencies: Phase 5.
- Acceptance criteria: Original image is preserved; processing stays responsive on target devices.

## Phase 7 - Multi-page Editing

- Status: BACKLOG
- Objective: Combine and manage pages as one document.
- Deliverables: Add, replace, duplicate, rotate, delete, reorder, batch filter, thumbnails, save.
- Dependencies: Phases 3-6.
- Acceptance criteria: Page order and edits persist reliably across restart.

## Phase 8 - PDF and Image Export

- Status: BACKLOG
- Objective: Produce predictable, shareable output files.
- Deliverables: PDF/image export, page selection, size, orientation, margins, quality, naming, preview, native share.
- Dependencies: Phase 7.
- Acceptance criteria: Exports open in standard viewers and large exports fail safely without corrupting documents.

## Phase 9 - OCR and Searchable Text

- Status: BACKLOG
- Objective: Extract, edit, store, search, and share document text.
- Deliverables: OCR interface, language support, results, confidence states, editing, copy/share, search indexing.
- Dependencies: Phase 3; OCR technology decision.
- Acceptance criteria: OCR can be rerun, edited text persists, and low-confidence results are clearly labelled.

## Phase 10 - Folders and Advanced Search

- Status: BACKLOG
- Objective: Scale organisation and retrieval for larger libraries.
- Deliverables: Folder management, move, bulk actions, filters, date search, recent search.
- Dependencies: Phases 3 and 9.
- Acceptance criteria: Deleting a folder never silently deletes its documents.

## Phase 11 - Settings and Privacy Controls

- Status: BACKLOG
- Objective: Give users control over scan defaults, export, storage, privacy, and cleanup.
- Deliverables: Settings, storage usage, privacy/security, cleanup, help, about, terms, privacy policy.
- Dependencies: Core offline feature set.
- Acceptance criteria: Settings apply predictably and destructive cleanup requires clear confirmation.

## Phase 12 - Authentication and Cloud Backup

- Status: BACKLOG
- Objective: Add optional identity, backup, restore, and synchronisation after offline stability.
- Deliverables: Authentication, secure token handling, backup, restore, sync, conflicts, account deletion, data export.
- Dependencies: Stable offline app, backend contract, privacy/legal review.
- Acceptance criteria: Users understand upload state; conflicts do not silently overwrite documents.

## Phase 13 - Monetisation

- Status: BACKLOG
- Objective: Add sustainable premium value without making basic scanning unusable.
- Deliverables: Entitlement service, purchase restore, premium feature gates, subscription screens.
- Dependencies: Product analytics and stable core quality.
- Acceptance criteria: Purchases restore correctly; essential scan/export remains genuinely useful for free users.

## Phase 14 - QA and Release

- Status: BACKLOG
- Objective: Validate reliability, accessibility, privacy, performance, and store readiness.
- Deliverables: Full test matrix, device coverage, store assets, release builds, support documentation.
- Dependencies: Release candidate feature freeze.
- Acceptance criteria: Release checklist is complete with no unresolved critical or high-severity issues.

### Current P00-T03 execution note - 2026-08-07

Connected GitHub dispatch/download verifier bundle is ready. Extracted ZIPs can now use the plan-first `bootstrap_phase0_github_repo.sh` path to initialise git, create/attach an explicit-visibility GitHub repository, push the exact commit, and dispatch the same hosted gate without requiring Flutter on the publishing machine. P00-T03 remains BLOCKED until an actual run produces locally re-verified Android/iOS build+launch evidence and a recorded gate-ready summary.
