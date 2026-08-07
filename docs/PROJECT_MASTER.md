# ClearScan Project Master

Updated: 2026-08-06
Status: Active
Current release target: MVP 0.1

## Product vision

ClearScan is a fast, trustworthy, privacy-first mobile document scanner for Android and iOS. It helps users turn physical documents and imported images into clean, searchable, shareable digital files while keeping essential processing on the device.

ClearScan may provide common document-scanning capabilities, but it must use original branding, layouts, navigation, icons, illustrations, text, animation, and interaction patterns. It must not copy CamScanner or another competitor's protected interface, source code, assets, or proprietary workflow.

## Working identity

- Product name: ClearScan
- Tagline: Smart Scanner. Better Documents.
- Brand state: Working identity; change through central configuration only
- Design direction: Modern, minimal, professional, friendly, privacy-focused

## Target users

- Students scanning notes, assignments, and study materials
- Freelancers scanning receipts, contracts, and client documents
- Office workers digitising forms and reports
- Small businesses organising operational documents
- Users who prefer offline document processing

## Core user journey

1. Open ClearScan.
2. Capture or import a document.
3. Confirm or adjust the detected boundary.
4. Correct perspective and improve readability.
5. Add, reorder, rotate, or remove pages.
6. Save the document locally.
7. Export as PDF or images, run OCR, organise, search, or share.

## MVP capabilities

- Camera scanning and image import
- Automatic edge detection with manual correction
- Perspective correction
- Original, colour, grayscale, black-and-white, clarity, and low-light filters
- Manual image adjustments
- Multi-page document editing
- Local document and folder library
- PDF and image export
- Native sharing
- On-device OCR where supported
- Search by title, folder, metadata, and OCR text
- Offline-first storage
- Settings, privacy controls, and storage management

## Later capabilities

- Account creation
- Optional encrypted cloud backup and restore
- Cross-device synchronisation
- Advanced OCR and batch tools
- Subscription management
- Password-protected exports
- Electronic signatures, subject to a separate product and legal review

## Non-goals for the initial MVP

- Web dashboard
- Team collaboration
- Real-time co-editing
- Silent cloud upload
- Mandatory account creation
- Copying any competitor interface
- Complex enterprise document management
- Monetisation before core scanning quality is stable

## Platforms

- Android phones
- iPhones
- Android tablets where practical
- iPads where practical

The first implementation uses Flutter and Dart with responsive layouts.

## Technical direction

- Feature-first modular source structure
- Offline-first data ownership
- Clear separation of presentation, domain, and data concerns
- Replaceable service interfaces for edge detection, OCR, storage, export, and cloud sync
- Centralised application configuration
- Centralised design tokens
- Explicit error and loading states
- Background or isolated processing for expensive image operations
- Local database migrations
- Secure storage for authentication material when accounts are introduced

## Design direction

The approved reference image is stored at `assets/reference/clearscan_ui_reference.png`.

Use:

- Light management surfaces for onboarding, home, library, folders, search, account, and settings
- Dark workspaces for camera, crop, filters, editing, and document preview
- Primary teal, deep navy, white, soft neutrals, informational blue, warning orange, and destructive red
- Clear visual hierarchy and large accessible touch targets
- A prominent scan action
- Reusable components instead of one-off styling

The reference is directional, not a rigid screen specification.

## Privacy principles

- Essential scanning works without an account.
- Images, PDFs, and OCR are processed locally whenever practical.
- Documents are not uploaded unless the user explicitly enables or requests it.
- The app clearly explains external processing before any upload.
- Production logs never include document contents or OCR text.
- Sensitive files are not written to public storage without explicit export.
- Data deletion behaviour is transparent and recoverable where practical.

## Quality principles

A screen is not complete merely because it renders. Completion requires realistic data behaviour, error handling, loading states, accessibility, testing, documentation, and consistency with the design system.

## Release acceptance summary

The MVP is acceptable only when a user can reliably complete the full journey from capture through export on supported Android and iOS devices, including permission denial, offline use, low-storage conditions, and multi-page documents.
