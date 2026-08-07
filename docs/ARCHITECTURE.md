# ClearScan Architecture

Updated: 2026-08-06
Status: Foundation baseline

## Architecture pattern

Use a feature-first modular architecture. Each feature may contain `data`, `domain`, and `presentation` layers. Small features do not need empty abstractions merely to match a pattern, but dependencies must remain explicit and testable.

## Top-level structure

- `lib/app`: app configuration, startup, navigation, dependency composition, theme
- `lib/core`: shared errors, logging, permissions, storage abstractions, utilities, widgets
- `lib/features`: user-facing feature modules
- `test`: unit and widget tests
- `integration_test`: cross-feature and device workflows
- `docs`: source of truth for product and delivery continuity

## Dependency rules

- Presentation may depend on domain contracts and shared UI primitives.
- Domain must not depend on Flutter UI or concrete plugins.
- Data implements domain contracts and may depend on plugins or persistence libraries.
- Features should not import another feature's concrete data implementation.
- App composition is responsible for wiring implementations to interfaces.
- Platform-specific logic stays behind services.

## State management

Decision deferred to Phase 1. Selection criteria:

- Predictable state transitions
- Testability
- Good async and cancellation support
- Clear ownership and disposal
- Low coupling to UI
- Maintained Flutter ecosystem support

The Phase 0 shell intentionally uses no external state-management package.

## Dependency injection

Decision deferred to Phase 1. Prefer explicit constructor injection. A lightweight composition root may be used before adopting a container library.

## Navigation

Phase 0 uses a direct home widget. Phase 1 will add a central router with typed route intent, deep-link strategy, and unsaved-editor protection.

## Error handling

Define domain failures rather than exposing raw plugin exceptions. User-facing errors must include:

- Clear description
- Recoverable action where available
- Safe fallback
- Structured non-sensitive logging

Document content and OCR text must never appear in production logs.

## Offline-first strategy

- Local storage is authoritative for essential features.
- Capture, editing, organisation, export, and supported OCR work without an account.
- Cloud sync is optional and isolated behind contracts.
- Sync status is explicit rather than assumed.
- Conflicts never silently overwrite local documents.

## Image-processing strategy

Expensive operations should run outside frame-critical UI work using isolates, native workers, or appropriate asynchronous platform APIs. Original files are immutable after capture; edits are represented by derived files and processing metadata until confirmed.

## Storage boundaries

- App-private storage for source and working files
- Exported files only move to user-accessible destinations through explicit user action
- Database stores metadata and paths, not large image bytes
- Thumbnail and preview files are separate from originals
- Cleanup must understand document, page, OCR, export, and trash relationships

## Testing strategy

- Unit tests for domain rules, transformations, filenames, storage decisions, and repositories
- Widget tests for states, accessibility labels, and navigation
- Integration tests for capture-to-export and persistence flows
- Real-device tests for camera, permissions, image memory, sharing, OCR, and interruption recovery

## Configuration

Product name, tagline, feature flags, and environment are centralised in `lib/app/configuration/app_config.dart`. Secrets must not be compiled from committed source files.
