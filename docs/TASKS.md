# ClearScan Ordered Task Backlog

Updated: 2026-08-07

## Workflow rules

- Execute tasks in the order listed unless a dependency or documented decision requires otherwise.
- Status values: BACKLOG, READY, IN_PROGRESS, BLOCKED, REVIEW, DONE.
- Only one main implementation task should normally be active.
- A task is DONE only after implementation, relevant tests, error handling, documentation, and handoff updates are complete.
- Any AI or developer must read `HANDOFF.md` before selecting work.

## Phase 0 - Project Foundation

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P00-T01 | Create repository structure and continuity documentation | None | Root files, `docs/*`, feature directories | Required structure and documentation exist; local structural validator passes | DONE | Created on 2026-08-06 |
| P00-T02 | Implement central configuration, foundation theme tokens, minimal app shell, and startup test source | P00-T01 | `lib/main.dart`, `lib/app/*`, `lib/features/home/*`, `test/*` | Source is complete and internally consistent; test is ready for Flutter execution | DONE | Source and offline contracts pass; runtime execution belongs to P00-T03 |
| P00-T03 | Generate Android/iOS runners and execute Flutter checks | P00-T02, Flutter SDK | `android/*`, `ios/*`, generated metadata | `dart format`, `flutter analyze`, and `flutter test` pass; app launches on Android and iOS target | BLOCKED | 2026-08-07 sandbox probe confirms Flutter/Dart/Android SDK/runners are absent and release storage is DNS-blocked here. Exact Flutter 3.44.8 / Dart 3.12.2 remain centrally pinned. Host/CI build evidence now has manifest/hash/toolchain/identifier/archive verification. Hosted CI also boots an Android API 35 emulator and an available iPhone simulator, installs and launches the real generated apps, captures verified PNG/runtime evidence, and exposes build plus launch digests in the final gate summary. P00-T03 remains BLOCKED until an actual connected/hosted run reports `P00-T03 gate-closing evidence ready: YES`, its exact-run artifacts pass the downloaded-run verifier, and the reviewed run is recorded in PHASE0_EVIDENCE.md. A GitHub dispatch/watch/download/verify script is now checked in for this execution. |
| P00-T04 | Confirm identifiers, signing baseline, and close Phase 0 gate | P00-T03 | Platform configs, docs | App IDs are approved; no foundation high-severity issues remain; Phase 1 marked READY | BACKLOG | None |

## Phase 1 - Design System and Application Shell

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P01-T00 | Build the owner-directed visible UI prototype before native toolchain verification | P00-T02; explicit owner direction | App shell, Home, Documents, Folders, Settings, Scanner UI, mock data, viewer/editor, crop/filter, PDF/OCR, Share, Search, onboarding, document/folder actions, widget-test source | Original visible interface exists in source; unfinished camera, storage, authentication, permissions, OCR, export, sharing, search, folder, and processing actions are clearly labelled; static contracts pass; runtime review remains pending | REVIEW | Slice 1: four-tab shell, Home, Documents, Folders, Settings, scanner. Slice 2: viewer/editor. Slice 3: crop/filter. Slice 4: PDF/OCR. Slice 5: Share and document actions. Slice 6: shared Search and temporary folder create/rename/recolour/safe-remove flow. Slice 7: Settings-launched welcome/features/privacy/camera-education onboarding preview with continue-without-account and sign-in/permission placeholders. Slice 8: Documents Library list/grid switching, sorting, temporary favorites, multi-select, bulk move to Recently Deleted, restore, and preview-only permanent removal. Slice 9: richer Settings choices for scan mode, image quality, PDF size, OCR language, illustrative storage details, simulated cleanup, privacy details, and session status. Slice 10: Help/Feedback, About, draft Privacy Policy, and draft Terms content with non-submitting forms and safe external-action placeholders. Slice 11: camera-ready, permission-needed, denied, permanently-denied, unavailable, import-source, and mock capture-review flows with crop/filter review and explicit no-device-access disclosures. Slice 12: auto-capture on/off education, stability/edge guidance, temporary captured-page count, generated thumbnail selection, review/update, add-another-page, and safe session-only removal. Slice 13: Finish Session completion with temporary title, folder choice, drag and arrow reorder, page summary, save-preview confirmation/result, and safe return to Scanner. Slice 14: reusable loading/empty/error and status patterns, scanner unsaved-exit protection, max-width/adaptive layouts, large-text action stacking, touch-target baseline, and final source audit. Source prototype is complete and awaiting Flutter runtime review. |
| P01-T01 | Review maintained packages and choose state management, DI, and routing | P00-T04 | `pubspec.yaml`, `DECISIONS.md`, `ARCHITECTURE.md` | Choices are tested, documented, and do not couple domain logic to plugins | BACKLOG | None |
| P01-T02 | Finalise colour, typography, spacing, radius, elevation, and motion tokens | P01-T01 | `lib/app/theme/*`, `DESIGN_SYSTEM.md` | Contrast checks pass and no screen-level brand constants are required | BACKLOG | None |
| P01-T03 | Build reusable button and icon-button components | P01-T02 | `lib/core/widgets/*`, widget tests | All variants, loading, disabled, focus, and semantic states pass | BACKLOG | None |
| P01-T04 | Build cards, fields, dialogs, sheets, and status components | P01-T03 | Shared widgets and tests | Components support loading, empty, error, and destructive patterns consistently | BACKLOG | None |
| P01-T05 | Build responsive application navigation shell | P01-T01, P01-T04 | Router, app shell, navigation widgets | Four destinations and prominent scan action work on phone/tablet layouts | BACKLOG | None |
| P01-T06 | Add component showcase and design-system regression tests | P01-T02-P01-T05 | Showcase screen/tests, docs | Components are reviewable in one place and golden strategy is documented | BACKLOG | None |
| P01-T07 | Complete Phase 1 accessibility and consistency gate | P01-T06 | QA records, docs | Text scaling, semantics, focus, contrast, and responsive checks pass | BACKLOG | None |

## Phase 2 - Onboarding and Home

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P02-T01 | Define onboarding states and first-run persistence | P01-T07 | Onboarding domain/data files | First-run status is testable and resettable without account dependency | BACKLOG | None |
| P02-T02 | Build splash, welcome, and feature-introduction screens | P02-T01 | Onboarding presentation/tests | Screens match design system and support accessibility/text scaling | BACKLOG | None |
| P02-T03 | Build privacy and permission education flow | P02-T02 | Permission explanation widgets/services | No permission is requested without context; denial paths are clear | BACKLOG | None |
| P02-T04 | Build Home layout, banner, and quick actions | P01-T07 | Home presentation/widgets | Scan is prominent and actions have original labels and layouts | BACKLOG | None |
| P02-T05 | Add isolated mock document repository for Home | P02-T04 | Home data/domain/test files | Sample data never leaks into production repository implementations | BACKLOG | None |
| P02-T06 | Build recent documents, recent folders, and empty states | P02-T05 | Home widgets/tests | Realistic loading, empty, populated, and error states render correctly | BACKLOG | None |
| P02-T07 | Complete onboarding-to-home integration tests | P02-T03, P02-T06 | Integration tests | User can continue without account and reach Home reliably | BACKLOG | None |

## Phase 3 - Local Document Library

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P03-T01 | Select local database and path-management technologies | P02-T07 | `pubspec.yaml`, decisions/docs | Packages are maintained, migration-capable, and suitable for large libraries | BACKLOG | None |
| P03-T02 | Implement Document, DocumentPage, Folder, OCR, and Settings models | P03-T01 | Feature domain/data models | Models are immutable or safely mutable, serialisable, and tested | BACKLOG | None |
| P03-T03 | Implement schema, migrations, and indexes | P03-T02 | Database service/migrations/tests | Fresh install and supported upgrade paths pass | BACKLOG | None |
| P03-T04 | Implement private file-storage service and atomic writes | P03-T01 | Core storage files/tests | Originals and derived files use predictable private paths and safe writes | BACKLOG | None |
| P03-T05 | Implement document and folder repositories | P03-T03, P03-T04 | Repository contracts/implementations/tests | CRUD, reorder, trash, restore, and cleanup rules are transactional | BACKLOG | None |
| P03-T06 | Build document library list/grid and sorting | P03-T05 | Documents presentation/tests | Large mock library scrolls smoothly with thumbnails | BACKLOG | None |
| P03-T07 | Build rename, favourite, trash, restore, and permanent delete | P03-T06 | Actions/dialogs/tests | Destructive behaviour is confirmed and recoverable where promised | BACKLOG | None |
| P03-T08 | Complete persistence and restart integration tests | P03-T07 | Integration tests | Data and page ordering survive restart and interrupted operations | BACKLOG | None |

## Phase 4 - Camera Scanner

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P04-T01 | Evaluate camera, gallery, and permission packages on target devices | P03-T08 | Decisions, package config, spike | Chosen packages support required Android/iOS lifecycle and image quality | BACKLOG | None |
| P04-T02 | Implement permission service and all camera denial states | P04-T01 | Core permissions, scanner screens/tests | Allowed, denied, permanently denied, and settings-return flows work | BACKLOG | None |
| P04-T03 | Implement camera controller abstraction and lifecycle handling | P04-T01 | Scanner domain/data/tests | Resume, pause, rotation, interruption, and disposal are reliable | BACKLOG | None |
| P04-T04 | Build original camera workspace and scan-mode selector | P04-T02, P04-T03 | Scanner presentation/widgets | Document, ID, book, and whiteboard modes are accessible and original | BACKLOG | None |
| P04-T05 | Implement high-resolution capture and duplicate-capture prevention | P04-T03 | Capture service/tests | One capture is saved per action and processing state is visible | BACKLOG | None |
| P04-T06 | Implement gallery import and file validation | P04-T01 | Import service/tests | Supported images import safely; unsupported/corrupt files fail clearly | BACKLOG | None |
| P04-T07 | Complete camera real-device test matrix | P04-T02-P04-T06 | QA evidence/docs | Representative Android/iOS devices pass capture and interruption tests | BACKLOG | None |

## Phase 5 - Edge Detection and Crop Editor

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P05-T01 | Prototype and benchmark edge-detection engines | P04-T07 | Spike code, decisions | Accuracy, latency, memory, licensing, and replaceability are documented | BACKLOG | None |
| P05-T02 | Define edge-detection and perspective-correction interfaces | P05-T01 | Scanner/crop domain contracts | UI and storage do not depend directly on the chosen engine | BACKLOG | None |
| P05-T03 | Implement stable live edge overlay and capture guidance | P05-T02 | Scanner presentation/service tests | Overlay is stable and manual capture always remains available | BACKLOG | None |
| P05-T04 | Build four-corner crop editor with reset and magnification | P05-T02 | Crop presentation/tests | Corners are accessible, constrained, and precise on varied aspect ratios | BACKLOG | None |
| P05-T05 | Implement perspective transform and rotation | P05-T04 | Crop data/service/tests | Corrected output preserves practical quality and orientation | BACKLOG | None |
| P05-T06 | Add retake, confirm, failure fallback, and state recovery | P05-T05 | Crop flow/tests | Failed detection never blocks manual completion | BACKLOG | None |
| P05-T07 | Complete representative-document geometry tests | P05-T06 | Fixtures/QA docs | Receipts, A4, books, whiteboards, shadows, and low contrast are covered | BACKLOG | None |

## Phase 6 - Filters and Image Adjustment

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P06-T01 | Define versioned, non-destructive processing settings | P05-T07 | Filter domain models/docs | Settings can reproduce output and support future migration | BACKLOG | None |
| P06-T02 | Implement preview pipeline and background processing | P06-T01 | Filter services/tests | UI remains responsive and previews are lower-cost than final output | BACKLOG | None |
| P06-T03 | Implement original, auto, colour, grayscale, B&W, clarity, and low-light filters | P06-T02 | Processing implementations/tests | Filters improve intended cases without overwriting originals | BACKLOG | None |
| P06-T04 | Implement manual adjustment controls | P06-T02 | Filter UI/tests | Brightness, contrast, saturation, sharpness, highlights, shadows are reversible | BACKLOG | None |
| P06-T05 | Build filter thumbnails and before/after review | P06-T03, P06-T04 | Presentation/tests | Selection, loading, cancellation, and failure states are clear | BACKLOG | None |
| P06-T06 | Complete memory, latency, and quality tests | P06-T05 | Benchmarks/QA docs | Target devices process representative high-resolution images safely | BACKLOG | None |

## Phase 7 - Multi-page Editing

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P07-T01 | Define editor session and unsaved-change model | P03-T08, P06-T06 | Editor domain/tests | Sessions recover safely and do not mutate saved documents prematurely | BACKLOG | None |
| P07-T02 | Build page thumbnail strip and page selection | P07-T01 | Editor presentation/tests | Large page counts remain usable and selected page is clear | BACKLOG | None |
| P07-T03 | Implement add, replace, duplicate, rotate, and delete page | P07-T02 | Editor actions/tests | Operations preserve stable IDs and correct page order | BACKLOG | None |
| P07-T04 | Implement drag reorder and transactional persistence | P07-T03 | Reorder logic/tests | Reordering cannot leave duplicate or missing positions | BACKLOG | None |
| P07-T05 | Implement apply-to-page and apply-to-all processing | P07-T03, P06-T06 | Editor/filter integration tests | Batch changes can be cancelled and originals remain recoverable | BACKLOG | None |
| P07-T06 | Implement rename, save, discard, and interruption recovery | P07-T04, P07-T05 | Editor flow/tests | Back navigation protects unsaved work and saves are atomic | BACKLOG | None |
| P07-T07 | Complete multi-page persistence tests | P07-T06 | Integration tests | Representative 1, 10, and 50-page documents remain consistent | BACKLOG | None |

## Phase 8 - PDF and Image Export

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P08-T01 | Evaluate PDF, image, archive, and share packages | P07-T07 | Decisions/package config | Licensing, maintenance, platform support, memory, and output quality are approved | BACKLOG | None |
| P08-T02 | Define export jobs, filenames, destinations, and progress | P08-T01 | Export domain/tests | Jobs are cancellable/recoverable and filenames are sanitised | BACKLOG | None |
| P08-T03 | Implement PDF generation options | P08-T02 | Export service/tests | Page size, orientation, margins, quality, title, selection all work | BACKLOG | None |
| P08-T04 | Implement JPG/PNG and multi-page image export | P08-T02 | Export service/tests | Separate files and supported bundle behaviour are predictable | BACKLOG | None |
| P08-T05 | Build export settings and preview interface | P08-T03, P08-T04 | Export presentation/tests | Preview reflects options and warns about size where practical | BACKLOG | None |
| P08-T06 | Implement native save/share and cancellation handling | P08-T05 | Platform share integration/tests | Share cancellation is not treated as failure and private files stay private | BACKLOG | None |
| P08-T07 | Complete compatibility and interruption tests | P08-T06 | Fixtures/QA docs | Output opens in standard viewers and interrupted jobs clean temporary files | BACKLOG | None |

## Phase 9 - OCR and Searchable Text

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P09-T01 | Evaluate local OCR engines and language support | P03-T08 | Spike/decisions | Privacy, accuracy, language, binary size, and device support are documented | BACKLOG | None |
| P09-T02 | Define replaceable OCR service and result model | P09-T01 | OCR domain/tests | Engine-specific details do not leak into the UI | BACKLOG | None |
| P09-T03 | Implement page/document OCR jobs and progress | P09-T02 | OCR data/service/tests | Jobs can fail partially, retry, and resume safely | BACKLOG | None |
| P09-T04 | Build extracted-text viewer and editor | P09-T03 | OCR presentation/tests | Copy, select, edit, search, and share are accessible | BACKLOG | None |
| P09-T05 | Implement searchable OCR index | P09-T03, P03-T08 | Search/data tests | Edited text is indexed and updates are transactional | BACKLOG | None |
| P09-T06 | Implement language selection and low-confidence states | P09-T04 | OCR settings/UI tests | Accuracy is not overstated and users can rerun with another language | BACKLOG | None |
| P09-T07 | Complete OCR privacy, quality, and logging tests | P09-T06 | QA evidence | No OCR text appears in production logs and target samples are documented | BACKLOG | None |

## Phase 10 - Folders and Advanced Search

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P10-T01 | Build create, rename, colour/icon, and folder search | P03-T08 | Folder presentation/tests | Duplicate/invalid names are handled consistently | BACKLOG | None |
| P10-T02 | Implement move and bulk move operations | P10-T01 | Folder/document actions/tests | Transactions preserve all documents and selection state | BACKLOG | None |
| P10-T03 | Implement safe folder deletion | P10-T02 | Folder repository/UI tests | Documents move to no folder unless separately deleted | BACKLOG | None |
| P10-T04 | Build advanced search filters and recent searches | P09-T07 | Search presentation/data tests | Title, folder, OCR, date, type, favourite filters combine predictably | BACKLOG | None |
| P10-T05 | Implement document bulk selection and actions | P10-T02, P08-T07 | Documents UI/tests | Bulk move, share, favourite, trash have confirmation/progress as needed | BACKLOG | None |
| P10-T06 | Complete large-library performance tests | P10-T04, P10-T05 | Benchmarks/QA docs | Search and scrolling meet agreed targets with realistic data volumes | BACKLOG | None |

## Phase 11 - Settings and Privacy Controls

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P11-T01 | Implement settings repository and migration-safe defaults | Core offline phases | Settings domain/data/tests | Defaults are versioned, validated, and restorable | BACKLOG | None |
| P11-T02 | Build scan, filter, OCR, and export defaults | P11-T01 | Settings presentation/tests | Changes apply to new work without altering saved documents unexpectedly | BACKLOG | None |
| P11-T03 | Build storage usage, cache cleanup, trash retention, and data cleanup | P11-T01 | Storage/settings tests | User sees impact and destructive cleanup is confirmed | BACKLOG | None |
| P11-T04 | Build privacy and security controls | P11-T01 | Settings/security tests | Upload and local data behaviour are understandable | BACKLOG | None |
| P11-T05 | Add help, about, version, terms, and privacy pages | P11-T04 | Static content/screens | Content is accessible, versioned, and reviewed before release | BACKLOG | None |
| P11-T06 | Complete offline MVP privacy and settings gate | P11-T02-P11-T05 | QA/docs | Essential flow remains functional without account or network | BACKLOG | None |

## Phase 12 - Authentication and Cloud Backup

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P12-T01 | Approve backend, encryption, privacy, retention, and API contracts | P11-T06 | API/decisions/legal docs | Threat model and data lifecycle are approved | BACKLOG | None |
| P12-T02 | Implement authentication and secure session storage | P12-T01 | Account data/domain/UI/tests | Sign-in/out/reset/provider flows and token protection pass | BACKLOG | None |
| P12-T03 | Implement resumable encrypted backup | P12-T02 | Sync/upload services/tests | Upload state is visible and checksums verify content | BACKLOG | None |
| P12-T04 | Implement restore and device synchronisation | P12-T03 | Sync services/UI/tests | Offline mutations sync safely and progress is recoverable | BACKLOG | None |
| P12-T05 | Implement conflict detection and resolution | P12-T04 | Conflict domain/UI/tests | Conflicting page content is never silently overwritten | BACKLOG | None |
| P12-T06 | Implement account data export and deletion | P12-T02 | Account/API/UI tests | Requests are explicit, trackable, and legally reviewed | BACKLOG | None |
| P12-T07 | Complete backup failure and multi-device tests | P12-T03-P12-T06 | Integration/QA evidence | Network loss, quota, duplicate, conflict, and restore scenarios pass | BACKLOG | None |

## Phase 13 - Monetisation

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P13-T01 | Define free/premium value and entitlement rules | Stable core metrics | Product/decision docs | Basic scanning and export remain genuinely useful for free users | BACKLOG | None |
| P13-T02 | Evaluate and integrate store billing | P13-T01 | Purchase service/config/tests | Purchase, cancellation, pending, refund, and restore states work | BACKLOG | None |
| P13-T03 | Build original subscription and upgrade screens | P13-T02 | Monetisation presentation/tests | Pricing is clear and no deceptive patterns are used | BACKLOG | None |
| P13-T04 | Implement server-verifiable entitlements where required | P13-T02, backend | Entitlement service/tests | Offline grace and cross-device state are documented and safe | BACKLOG | None |
| P13-T05 | Complete store-policy and purchase QA | P13-T03, P13-T04 | QA/docs | Both stores' current billing and disclosure requirements are satisfied | BACKLOG | None |

## Phase 14 - QA and Release

| Task ID | Description | Dependencies | Expected files | Acceptance criteria | Status | Completion notes |
|---|---|---|---|---|---|---|
| P14-T01 | Freeze release scope and complete test inventory | All selected release phases | Roadmap/tasks/QA docs | Every requirement maps to test evidence or documented exclusion | BACKLOG | None |
| P14-T02 | Complete automated unit, widget, integration, and migration suites | P14-T01 | Test suites/coverage reports | Agreed coverage and critical-path tests pass | BACKLOG | None |
| P14-T03 | Complete real-device, accessibility, performance, and low-storage QA | P14-T02 | QA evidence/issues | No unresolved critical/high issues and target performance is met | BACKLOG | None |
| P14-T04 | Complete security, privacy, dependency, and legal review | P14-T02 | Review reports/docs | Findings are resolved or explicitly accepted | BACKLOG | None |
| P14-T05 | Prepare app icons, screenshots, metadata, support, and store listings | P14-T03, P14-T04 | Store assets/docs | Assets are original, accurate, and match the shipping app | BACKLOG | None |
| P14-T06 | Build signed release candidates and run final smoke tests | P14-T05 | Release builds/checksums | Signed builds install, launch, scan, save, export, and recover correctly | BACKLOG | None |
| P14-T07 | Publish, monitor, and document rollback/hotfix process | P14-T06 | Release notes/operations docs | Monitoring and support ownership are active | BACKLOG | None |
