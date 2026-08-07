# ClearScan Database Plan

Updated: 2026-08-06
Status: Proposed; implementation begins in Phase 3

## Storage model

Use an embedded local database for metadata and app-private filesystem storage for images, thumbnails, OCR attachments, and exports. The database technology is not selected yet.

## Document

Proposed fields:

- `id`: stable unique identifier
- `title`: user-editable display title
- `createdAt`
- `updatedAt`
- `folderId`: nullable
- `isFavourite`
- `pageCount`: cached and transactionally maintained
- `thumbnailPath`: nullable derived preview
- `ocrStatus`: none, queued, processing, complete, partial, failed
- `backupStatus`: localOnly, queued, synced, conflict, failed
- `isDeleted`
- `deletedAt`: nullable

Indexes: updated date, title, folder, favourite, deleted state, OCR status.

## DocumentPage

Proposed fields:

- `id`
- `documentId`
- `position`
- `originalImagePath`
- `processedImagePath`: nullable
- `thumbnailPath`: nullable
- `cropCoordinates`: serialised four-point geometry
- `rotationDegrees`
- `filterSettings`: versioned serialised settings
- `pixelWidth`
- `pixelHeight`
- `createdAt`
- `updatedAt`

Constraints: unique `(documentId, position)` after reorder transaction.

## OCRResult

Proposed fields:

- `id`
- `pageId`
- `extractedText`
- `editedText`: nullable
- `languageCode`
- `confidenceSummary`: nullable and engine-dependent
- `engineVersion`
- `createdAt`
- `updatedAt`

Search indexing should use the user-edited text when available.

## Folder

Proposed fields:

- `id`
- `name`
- `iconKey`
- `colourToken`
- `createdAt`
- `updatedAt`

Folder deletion moves documents to no folder unless the user separately chooses document deletion.

## ApplicationSettings

Proposed fields:

- `themeMode`
- `defaultScanMode`
- `autoCaptureEnabled`
- `defaultFilter`
- `pdfQuality`
- `ocrLanguageCodes`
- `backupEnabled`
- `privacyPreferences`
- `schemaVersion`

## Relationships

- One Document has many DocumentPages.
- One Folder has zero or many Documents.
- One DocumentPage has zero or one current OCRResult plus optional history if later required.
- Deleting a Document first marks it as deleted; permanent cleanup cascades to pages and derived local files.

## Migrations

- Every schema change requires a numbered migration.
- Migration tests must cover upgrades from every supported prior release.
- Destructive migration is prohibited for production user data unless explicitly approved with export/recovery guidance.

## Proposed private storage paths

```text
application_support/
  documents/<document-id>/
    originals/<page-id>.<ext>
    processed/<page-id>.<ext>
    thumbnails/<page-id>.jpg
    ocr/<page-id>.json
  exports/
  temp/
```

Exact platform paths must use supported path-provider APIs and remain behind a storage service.
