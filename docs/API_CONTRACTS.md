# ClearScan Future API Contracts

Updated: 2026-08-06
Status: Contract outline only; no backend is part of Phase 0

## General rules

- Essential app use is local-first and does not require these APIs.
- All network operations require explicit user-visible backup or account state.
- API errors use stable machine codes plus safe user messages.
- Document content is encrypted in transit.
- Storage access is private and time-limited.
- Idempotency is required for upload and mutation requests.

## Authentication

Future operations:

- Register with email
- Sign in
- Sign in with supported identity providers
- Refresh session
- Request password reset
- Sign out
- List active devices/sessions
- Revoke session

Tokens must be stored in secure platform storage.

## Document backup

Minimum metadata:

- document ID
- owner ID
- version
- title
- folder relationship
- page manifest
- timestamps
- deletion state
- content checksum
- encrypted object references

Large page files should use resumable upload and checksum verification.

## Synchronisation

- Client sends last known sync cursor.
- Server returns ordered changes and a new cursor.
- Every entity includes a version or revision token.
- Offline mutations are queued locally.
- Deletions use tombstones for a defined retention period.

## Conflict resolution

- Never silently overwrite two edited document versions.
- Metadata-only conflicts may use deterministic field rules if documented.
- Page-content conflicts require user choice or safe duplication.
- Conflict state is visible in the library and document viewer.

## Account deletion

- Re-authentication may be required.
- User sees what will be deleted and any retention obligations.
- Deletion request returns a trackable state.
- Local-only documents are not deleted unless the user explicitly requests local cleanup.

## Data export

Future account export includes metadata, originals where permitted, processed files, OCR text, and folder structure in a documented portable format.

## Error envelope

Proposed structure:

```json
{
  "error": {
    "code": "SYNC_CONFLICT",
    "message": "A safe user-facing message",
    "requestId": "trace-id",
    "retryable": false,
    "details": {}
  }
}
```

Never include document contents or authentication secrets in error details.
