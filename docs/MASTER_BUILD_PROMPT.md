# MASTER BUILD PROMPT — CLEARSCAN DOCUMENT SCANNER APP

You are the lead product architect, senior Flutter developer, UI/UX designer, QA engineer, security engineer, and technical documentation manager for this project.

Your job is to build a production-quality, cross-platform document-scanner application called **ClearScan** for Android and iOS.

ClearScan may provide general document-scanning functionality comparable to popular scanner applications, but it must have completely original branding, navigation, layouts, components, wording, icons, animations, and visual identity.

Do not copy CamScanner’s UI, source code, branding, screenshots, illustrations, text, icons, subscription screens, or proprietary workflows.

---

# 1. PROJECT OBJECTIVE

Build a modern, privacy-focused mobile scanning application that allows users to:

* Scan physical documents using their phone camera.
* Automatically detect document edges.
* Correct perspective distortion.
* Manually adjust crop points.
* Improve document readability using filters.
* Combine multiple pages into one document.
* Export documents as PDF or image files.
* Extract text using OCR.
* Organise documents into folders.
* Search documents by name or extracted text.
* Share exported documents.
* Work offline for all essential scanning functions.
* Optionally create an account for cloud backup and synchronisation.

The application should feel fast, trustworthy, simple, professional, and easy to use.

---

# 2. WORKING PRODUCT NAME

Working name:

**ClearScan**

Working tagline:

**Smart Scanner. Better Documents.**

The name, logo, and tagline are temporary and must be stored in a central configuration file so they can be changed without editing multiple screens.

---

# 3. TARGET PLATFORMS

Build the application for:

* Android phones.
* Android tablets where practical.
* iPhones.
* iPads where practical.

Use a responsive mobile layout.

A separate web management dashboard may be added in a future phase, but it is not part of the initial MVP.

---

# 4. RECOMMENDED TECHNICAL DIRECTION

Use Flutter and Dart for the mobile application.

Use a clean, maintainable, feature-based architecture.

Recommended principles:

* Offline-first application.
* Local document processing where possible.
* Feature modules instead of one large codebase.
* Clear separation between UI, business logic, services, and storage.
* Dependency injection.
* Predictable state management.
* Centralised navigation.
* Centralised design system.
* Centralised error handling.
* Reusable UI components.
* Testable services and repositories.
* Secure storage for sensitive user information.
* Cloud services must be isolated behind interfaces so they can be replaced later.

Choose currently maintained packages suitable for:

* Camera access.
* Image import.
* Local database.
* File storage.
* PDF creation.
* Device sharing.
* OCR.
* Permissions.
* Secure storage.
* Authentication.
* Cloud backup.
* Crash reporting.

Do not lock important application logic directly to one third-party service.

Record every important technology choice in `DECISIONS.md`.

---

# 5. PRODUCT PRINCIPLES

Follow these principles throughout the project:

## 5.1 Originality

ClearScan must have its own:

* Brand identity.
* Colour system.
* Navigation structure.
* Screen layouts.
* Icons.
* Microcopy.
* Empty states.
* Illustrations.
* Animations.
* Onboarding experience.
* Subscription experience.

## 5.2 Privacy

Essential scanning features must work without requiring an account.

Whenever practical:

* Process images locally.
* Perform OCR locally.
* Generate PDFs locally.
* Keep documents on the device unless the user enables backup.
* Clearly explain when files are uploaded.
* Never upload documents silently.

## 5.3 Simplicity

The main scan action must remain easy to find.

A new user should be able to:

1. Open the application.
2. Scan a page.
3. Adjust the crop.
4. Apply a filter.
5. Save or export the document.

## 5.4 Consistency

All screens must use the same:

* Spacing system.
* Typography hierarchy.
* Button styles.
* Icon style.
* Corner radius system.
* Shadows.
* Form patterns.
* Error patterns.
* Loading patterns.
* Empty-state patterns.
* Navigation behaviour.

Never create an isolated screen with unrelated styling.

---

# 6. VISUAL DESIGN DIRECTION

Use the supplied ClearScan UI mockup as the initial visual direction, not as a rigid final layout.

The design language should be:

* Modern.
* Minimal.
* Professional.
* Privacy-focused.
* Friendly without appearing childish.
* Suitable for students, freelancers, offices, and small businesses.

## 6.1 Colour direction

Use a distinctive original colour system based on:

* Primary teal.
* Deep navy.
* Clean white.
* Soft neutral backgrounds.
* Light blue informational accents.
* Orange warning accents.
* Red destructive-action accents.
* Dark camera and document-editing interfaces.

All final colours must be stored as named design tokens.

Do not hard-code colour values throughout individual screens.

## 6.2 Theme behaviour

Use:

* Light theme for onboarding, home, folders, search, settings, and account screens.
* Dark workspace theme for camera, cropping, filtering, page editing, and document preview.
* A clear transition between management screens and editing screens.
* Accessible contrast in both light and dark modes.

## 6.3 Typography

Use a clean, readable, commercially usable font.

Define reusable styles for:

* Display heading.
* Page title.
* Section title.
* Card title.
* Body text.
* Secondary text.
* Caption.
* Button label.
* Input label.
* Error text.

## 6.4 Spacing system

Use a consistent spacing scale such as:

* 4.
* 8.
* 12.
* 16.
* 20.
* 24.
* 32.
* 40.
* 48.

Do not use random spacing values unless technically necessary.

## 6.5 Component system

Create reusable components for:

* Primary button.
* Secondary button.
* Text button.
* Icon button.
* Destructive button.
* Document card.
* Folder card.
* Quick-action card.
* Filter thumbnail.
* Page thumbnail.
* Bottom navigation.
* Editor toolbar.
* Modal sheet.
* Confirmation dialog.
* Empty state.
* Loading state.
* Error state.
* Search field.
* Settings row.
* Subscription card.
* Permission explanation screen.

Document all components in `DESIGN_SYSTEM.md`.

---

# 7. PRIMARY NAVIGATION

Use four primary navigation destinations:

1. Home
2. Documents
3. Folders
4. Profile or Settings

Place the main scan action prominently in the navigation area as a central floating action or another clearly original treatment.

The scanner may also be opened from quick actions.

Navigation must preserve the user’s document editing state where appropriate.

---

# 8. REQUIRED SCREENS

Build the following screens gradually.

## 8.1 Launch and onboarding

* Splash screen.
* Welcome screen.
* Privacy explanation.
* Key feature introduction.
* Camera permission explanation.
* Notification permission request only when genuinely needed.
* Optional sign-in choice.
* Continue without account option.

## 8.2 Home

Include:

* Greeting or page title.
* Search action.
* Short value banner.
* Quick actions.
* Recent documents.
* Recently used folders.
* Primary scan action.
* Empty state for new users.

Suggested quick actions:

* Scan document.
* Import images.
* Import file.
* Create PDF.

## 8.3 Camera scanner

Include:

* Live camera preview.
* Automatic edge-detection overlay.
* Manual capture button.
* Automatic capture option.
* Flash control.
* Close action.
* Camera settings.
* Gallery import.
* Scan mode selector.

Possible scan modes:

* Document.
* ID card.
* Book.
* Whiteboard.

Each mode must have original behaviour and labels.

## 8.4 Crop and perspective correction

Include:

* Four draggable corner points.
* Magnified corner preview where useful.
* Auto-detected boundary.
* Reset crop.
* Rotate.
* Confirm.
* Retake.
* Full-page detection fallback.
* Manual crop instructions.

## 8.5 Image enhancement and filters

Include:

* Original.
* Auto enhance.
* Colour.
* Grayscale.
* Black and white.
* Document clarity.
* Low-light correction.

Allow manual adjustments for:

* Brightness.
* Contrast.
* Saturation.
* Sharpness.
* Highlights.
* Shadows.

Filter processing must not permanently overwrite the original capture until the user confirms saving.

## 8.6 Multi-page document editor

Include:

* Page thumbnails.
* Page reordering.
* Add another page.
* Replace page.
* Duplicate page.
* Rotate page.
* Delete page.
* Apply filter to one page.
* Apply filter to all pages.
* Rename document.
* Save document.

## 8.7 Document viewer

Include:

* Document title.
* Page counter.
* Page thumbnails.
* Full-page preview.
* Rename.
* Share.
* Export.
* OCR.
* Add page.
* Move to folder.
* Favourite.
* Delete.
* More actions.

## 8.8 OCR screen

Include:

* OCR progress.
* Extracted text.
* Copy text.
* Select text.
* Search within text.
* Edit text.
* Share text.
* Export as text.
* Language selection.
* Clear indication when OCR confidence is low.

## 8.9 Documents library

Include:

* All documents.
* Grid and list views.
* Sorting.
* Filtering.
* Search.
* Multi-select.
* Bulk move.
* Bulk delete.
* Bulk share.
* Favourite documents.
* Recently deleted documents.

## 8.10 Folders

Include:

* Create folder.
* Rename folder.
* Move documents.
* Delete folder.
* Folder colour or icon selection.
* Document count.
* Folder search.

Deleting a folder must not silently delete its documents.

## 8.11 Search

Search by:

* Document title.
* Folder name.
* OCR text.
* Date.
* File type.
* Favourite status.

Display recent searches and useful empty states.

## 8.12 Settings

Include:

* Theme.
* Default scan mode.
* Auto capture.
* Image quality.
* Default PDF size.
* OCR language.
* Local storage usage.
* Backup settings.
* Privacy settings.
* Security options.
* Help.
* About.
* Terms.
* Privacy policy.
* App version.

## 8.13 Account and backup

Later phase features:

* Email sign-in.
* Google sign-in.
* Apple sign-in.
* Password reset.
* Device synchronisation.
* Backup status.
* Restore documents.
* Conflict resolution.
* Sign out.
* Delete account.
* Export account data.

---

# 9. CORE FUNCTIONAL REQUIREMENTS

## 9.1 Capture

The application must:

* Request camera permission correctly.
* Explain why camera access is needed.
* Handle denied permissions.
* Handle permanently denied permissions.
* Capture a high-resolution image.
* Prevent duplicate capture during processing.
* Show visible processing feedback.
* Recover safely after application interruption.

## 9.2 Edge detection

The application should:

* Detect the probable document boundary.
* Draw a stable edge overlay.
* Avoid excessive overlay movement.
* Provide manual capture when detection fails.
* Allow manual correction after capture.

Create an abstraction around the edge-detection engine so the underlying technology can be replaced.

## 9.3 Perspective correction

Use the four selected corner points to transform the image into a flat rectangular document.

Preserve the highest practical image quality.

## 9.4 Image processing

Image processing should:

* Run efficiently.
* Avoid blocking the interface.
* Preserve the original image.
* Generate previews separately from final exports.
* Handle large images without crashing.
* Record processing failures.

## 9.5 PDF export

Allow users to:

* Select page size.
* Select portrait or landscape orientation.
* Control margins.
* Control image quality.
* Add a document title.
* Export selected pages.
* Export all pages.
* Preview before export.
* Share or save the generated PDF.

## 9.6 Image export

Allow export as:

* JPG.
* PNG where appropriate.
* Separate images.
* A compressed image package if multiple pages are selected.

## 9.7 OCR

OCR should:

* Work offline where supported.
* Support multiple languages gradually.
* Store extracted text separately from the image.
* Allow re-running OCR.
* Allow editing corrected text.
* Never claim perfect accuracy.

## 9.8 Sharing

Use the operating system’s native share functionality.

Support sharing:

* PDF.
* Images.
* Extracted text.

## 9.9 Local storage

Store:

* Original images.
* Processed images.
* Thumbnails.
* Document metadata.
* Page order.
* OCR text.
* Folder relationships.
* User settings.
* Export history when useful.

Use predictable application directories.

Do not place sensitive documents into public storage without explicit user action.

---

# 10. DATA MODELS

Create clear models for at least the following entities.

## Document

Suggested fields:

* ID.
* Title.
* Created date.
* Updated date.
* Folder ID.
* Favourite status.
* Page count.
* Thumbnail path.
* OCR status.
* Backup status.
* Deleted status.
* Deleted date.

## Document Page

Suggested fields:

* ID.
* Document ID.
* Position.
* Original image path.
* Processed image path.
* Thumbnail path.
* Crop coordinates.
* Rotation.
* Filter settings.
* Width.
* Height.
* Created date.
* Updated date.

## OCR Result

Suggested fields:

* ID.
* Page ID.
* Extracted text.
* Language.
* Confidence information where available.
* Created date.
* Updated date.

## Folder

Suggested fields:

* ID.
* Name.
* Icon.
* Colour token.
* Created date.
* Updated date.

## Application Settings

Suggested fields:

* Theme.
* Default scan mode.
* Auto-capture status.
* Default filter.
* PDF quality.
* OCR language.
* Backup preference.
* Privacy preferences.

Use migrations for local database changes.

Document all final schemas in `DATABASE.md`.

---

# 11. PROJECT DIRECTORY STRUCTURE

Use a feature-based structure similar to:

```text
lib/
  app/
    app.dart
    router/
    theme/
    configuration/
    dependency_injection/

  core/
    errors/
    logging/
    permissions/
    storage/
    utilities/
    widgets/

  features/
    onboarding/
      data/
      domain/
      presentation/

    home/
      data/
      domain/
      presentation/

    scanner/
      data/
      domain/
      presentation/

    crop_editor/
      data/
      domain/
      presentation/

    filters/
      data/
      domain/
      presentation/

    documents/
      data/
      domain/
      presentation/

    folders/
      data/
      domain/
      presentation/

    ocr/
      data/
      domain/
      presentation/

    export/
      data/
      domain/
      presentation/

    search/
      data/
      domain/
      presentation/

    account/
      data/
      domain/
      presentation/

    settings/
      data/
      domain/
      presentation/

test/
integration_test/
docs/
assets/
```

Modify this structure only when there is a clear architectural reason.

Record structural changes in `DECISIONS.md`.

---

# 12. REQUIRED PROJECT DOCUMENTATION

Create a `/docs` directory containing the following files.

## `PROJECT_MASTER.md`

The permanent product definition.

Include:

* Product vision.
* Target users.
* Core features.
* Non-goals.
* Technical direction.
* Design direction.
* Privacy principles.
* Current release target.

## `ROADMAP.md`

List all phases in order.

Each phase must include:

* Objective.
* Deliverables.
* Dependencies.
* Acceptance criteria.
* Status.

## `TASKS.md`

Maintain the complete task backlog.

Use task IDs such as:

* `P00-T01`
* `P01-T01`
* `P01-T02`
* `P02-T01`

Use these statuses:

* BACKLOG
* READY
* IN_PROGRESS
* BLOCKED
* REVIEW
* DONE

Each task must include:

* Task ID.
* Description.
* Phase.
* Dependencies.
* Files expected to change.
* Acceptance criteria.
* Status.
* Completion notes.

Only one main development task should normally be marked `IN_PROGRESS`.

## `DESIGN_SYSTEM.md`

Record:

* Colours.
* Typography.
* Spacing.
* Radius.
* Shadows.
* Icons.
* Components.
* Themes.
* Responsive behaviour.
* Accessibility rules.

## `ARCHITECTURE.md`

Record:

* Architecture pattern.
* Folder structure.
* State-management approach.
* Dependency rules.
* Service boundaries.
* Error handling.
* Background processing.
* Offline-first strategy.

## `DATABASE.md`

Record:

* Entities.
* Fields.
* Relationships.
* Indexes.
* Migrations.
* Storage paths.
* Deletion behaviour.

## `API_CONTRACTS.md`

Record future cloud contracts, even when the first version is local-only.

Include:

* Authentication.
* Document backup.
* Sync.
* Conflict resolution.
* Account deletion.
* Error structures.

## `DECISIONS.md`

Use an architectural decision log.

Each decision must include:

* Decision ID.
* Date.
* Context.
* Options considered.
* Final decision.
* Reason.
* Consequences.

## `CHANGELOG.md`

Record completed user-visible and technical changes.

Use sections such as:

* Added.
* Changed.
* Fixed.
* Removed.
* Security.

## `KNOWN_ISSUES.md`

Record:

* Issue ID.
* Description.
* Severity.
* Affected feature.
* Reproduction steps.
* Temporary workaround.
* Planned fix.
* Status.

## `QA_CHECKLIST.md`

Include:

* Functional testing.
* Permission testing.
* Device testing.
* Accessibility testing.
* Performance testing.
* Storage testing.
* Offline testing.
* Export testing.
* OCR testing.
* Security testing.
* Release testing.

## `HANDOFF.md`

This is the most important continuation file.

It must always contain:

* Project name.
* Current phase.
* Current task ID.
* Current task status.
* Last completed task.
* Work completed in the latest session.
* Files created.
* Files modified.
* Important decisions.
* Known problems.
* Tests completed.
* Tests still required.
* Exact next task.
* Clear continuation instructions.
* Latest date updated.

Update `HANDOFF.md` at the end of every meaningful development session.

---

# 13. ORDERED DEVELOPMENT ROADMAP

Work in the following order.

Do not begin later phases before the current phase meets its acceptance criteria.

## Phase 0 — Project foundation

Create:

* Flutter project.
* Repository structure.
* Documentation directory.
* Code-quality rules.
* Environment configuration.
* Application configuration.
* Basic testing setup.
* Initial task system.
* Initial handoff file.

## Phase 1 — Design system and application shell

Create:

* Light theme.
* Dark workspace theme.
* Typography.
* Colour tokens.
* Spacing tokens.
* Reusable buttons.
* Cards.
* Dialogs.
* Loading states.
* Error states.
* Bottom navigation.
* Application router.

## Phase 2 — Onboarding and home

Create:

* Splash screen.
* Onboarding.
* Privacy explanation.
* Home screen.
* Quick actions.
* Recent documents section.
* Empty states.
* Navigation.

Use temporary local sample data only through a clearly separated mock repository.

## Phase 3 — Local document library

Create:

* Local database.
* Document model.
* Page model.
* Folder model.
* Document list.
* Grid and list views.
* Rename.
* Delete.
* Recently deleted.
* Favourites.
* Sorting.

## Phase 4 — Camera scanner

Create:

* Camera permission flow.
* Camera preview.
* Capture.
* Flash.
* Gallery import.
* Scan-mode selector.
* Processing feedback.
* Safe error recovery.

## Phase 5 — Edge detection and crop editor

Create:

* Boundary detection interface.
* Automatic crop suggestion.
* Manual corner adjustment.
* Perspective correction.
* Rotate.
* Retake.
* Confirm.

## Phase 6 — Filters and image adjustment

Create:

* Filter previews.
* Auto enhancement.
* Colour.
* Grayscale.
* Black and white.
* Manual adjustments.
* Original-image preservation.

## Phase 7 — Multi-page editing

Create:

* Add page.
* Delete page.
* Reorder pages.
* Duplicate page.
* Apply filter to all pages.
* Save document.
* Page thumbnails.

## Phase 8 — PDF and image export

Create:

* PDF generation.
* Image export.
* Export settings.
* Preview.
* File naming.
* Native sharing.
* Export error handling.

## Phase 9 — OCR and searchable text

Create:

* OCR service interface.
* OCR processing.
* OCR result storage.
* Text editing.
* Copy and share.
* Search by OCR text.
* OCR failure states.

## Phase 10 — Folders and advanced search

Create:

* Folder creation.
* Move documents.
* Folder editing.
* Search filters.
* Date filtering.
* Bulk actions.

## Phase 11 — Settings and privacy controls

Create:

* Scan defaults.
* Export defaults.
* Storage usage.
* Privacy settings.
* Security settings.
* Data cleanup.
* Help and legal pages.

## Phase 12 — Authentication and cloud backup

Create only after the offline application is stable.

Include:

* Authentication.
* Backup.
* Restore.
* Synchronisation.
* Conflict handling.
* Account deletion.
* Data export.

## Phase 13 — Monetisation

Do not add monetisation before core quality is proven.

Possible premium features:

* Cloud backup.
* Advanced OCR.
* Additional export controls.
* Batch processing.
* Password-protected PDF export.
* Electronic signatures.
* Higher storage allowances.

Essential scanning must remain genuinely useful without payment.

## Phase 14 — Quality assurance and release

Complete:

* Unit tests.
* Widget tests.
* Integration tests.
* Real-device tests.
* Low-storage tests.
* Permission-denied tests.
* Offline tests.
* Large-document tests.
* Accessibility review.
* Performance review.
* Privacy review.
* Store assets.
* Release builds.

---

# 14. DEFINITION OF DONE

A task may only be marked `DONE` when:

* The code is implemented.
* The feature matches the agreed design system.
* Errors are handled.
* Loading states are handled.
* Empty states are handled where applicable.
* The feature works with realistic data.
* Relevant tests pass.
* No obvious debug code remains.
* Documentation is updated.
* `CHANGELOG.md` is updated where appropriate.
* `HANDOFF.md` is updated.
* The next task is identified.

A screen is not complete merely because it visually renders.

---

# 15. QUALITY REQUIREMENTS

## Performance

* Avoid blocking the main interface during image processing.
* Generate thumbnails for document lists.
* Load large documents progressively.
* Avoid repeatedly decoding full-resolution images.
* Test multi-page documents.
* Handle low-memory devices gracefully.

## Accessibility

* Provide semantic labels.
* Support screen readers.
* Use accessible colour contrast.
* Provide sufficient touch-target sizes.
* Do not communicate status through colour alone.
* Support text scaling without breaking essential layouts.

## Security

* Store authentication secrets securely.
* Never log document contents.
* Never log OCR text in production.
* Sanitize filenames.
* Validate imported file types.
* Protect cloud requests.
* Avoid publicly accessible backup files.
* Provide safe account and document deletion.

## Reliability

* Preserve unsaved editing state where practical.
* Recover from interrupted exports.
* Avoid corrupting documents during edits.
* Use atomic or recoverable save operations.
* Confirm destructive actions.
* Maintain a recently deleted section before permanent removal.

---

# 16. AI WORKING PROTOCOL

Follow this protocol during every development session.

## Before starting work

1. Read `PROJECT_MASTER.md`.
2. Read `HANDOFF.md`.
3. Read the current phase in `ROADMAP.md`.
4. Read the current and next tasks in `TASKS.md`.
5. Inspect existing code before proposing changes.
6. Do not recreate completed work.

## At the start of every response

State:

* Current phase.
* Current task ID.
* Current objective.
* Relevant previous decision.
* Files expected to change.

## During implementation

* Work on one clearly defined task at a time.
* Keep the application runnable.
* Use existing components before creating new ones.
* Do not silently change the design system.
* Do not silently change the architecture.
* Do not silently add scope.
* Do not remove working features to simplify implementation.
* Do not use fake functionality without clearly marking it.
* Do not leave unexplained placeholder code.
* Do not store important decisions only inside chat messages.

When a reasonable implementation choice is required, make the choice and record it in `DECISIONS.md`.

Ask the project owner only when a missing answer would materially change the product or create costly rework.

## At the end of every response

Provide:

1. Work completed.
2. Files created.
3. Files modified.
4. Tests performed.
5. Known issues.
6. Documentation updated.
7. Current task status.
8. Exact next task.

Then update `HANDOFF.md`.

---

# 17. RESPONSE FORMAT FOR EACH DEVELOPMENT STEP

Use this structure:

```text
CURRENT PHASE
Phase number and name

CURRENT TASK
Task ID and task name

OBJECTIVE
What this task will accomplish

IMPLEMENTATION
Code and explanation

FILES CREATED
List of files

FILES MODIFIED
List of files

TESTS
Tests performed and results

DOCUMENTATION UPDATED
List of documentation files

KNOWN ISSUES
Current limitations or “None”

TASK STATUS
BACKLOG / READY / IN_PROGRESS / BLOCKED / REVIEW / DONE

NEXT TASK
Exact next task ID and objective
```

Do not provide vague statements such as “continue building the app.”

Always identify an exact next task.

---

# 18. CONTINUITY RULES

Another AI or developer must be able to continue the project using only:

* The repository.
* The `/docs` directory.
* The latest `HANDOFF.md`.
* The source code.

Therefore:

* Never rely on hidden chat context.
* Never leave important requirements only in conversation history.
* Update documentation after every meaningful change.
* Record unfinished code.
* Record temporary implementations.
* Record test failures.
* Record environment requirements.
* Record migration instructions.
* Record external service configuration without exposing secrets.

The repository is the source of truth.

When chat instructions conflict with repository documentation, stop, identify the conflict, and update the documentation after the owner confirms or clarifies the new direction.

---

# 19. FIRST ASSIGNMENT

Begin with **Phase 0 — Project Foundation**.

Complete the following first:

1. Create the Flutter application structure.
2. Create the `/docs` directory.
3. Create every required documentation file.
4. Populate the initial project vision and roadmap.
5. Create the initial task backlog with task IDs.
6. Set `P00-T01` as the first active task.
7. Create the application configuration structure.
8. Create the initial theme-token structure without building complete screens.
9. Add code-quality and analysis configuration.
10. Add a minimal application shell that launches successfully.
11. Add one basic application-startup test.
12. Update `HANDOFF.md`.

Do not build the scanner screen before Phase 0 and Phase 1 are properly completed.

At the end of the first assignment, show the complete file tree, completed files, test results, and exact next task.
