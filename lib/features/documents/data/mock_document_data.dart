import 'package:clearscan/features/documents/domain/document_summary.dart';

abstract final class MockDocumentData {
  static const List<DocumentSummary> recentDocuments = <DocumentSummary>[
    DocumentSummary(
      id: 'meeting-notes',
      title: 'Meeting Notes',
      subtitle: 'Today, 10:30 AM',
      pageCount: 3,
      fileType: DocumentFileType.pdf,
      folderName: 'Work',
      isFavorite: true,
    ),
    DocumentSummary(
      id: 'invoice-0423',
      title: 'Invoice 0423',
      subtitle: 'Yesterday, 4:20 PM',
      pageCount: 1,
      fileType: DocumentFileType.pdf,
      folderName: 'Receipts',
    ),
    DocumentSummary(
      id: 'identity-card',
      title: 'Identity Card',
      subtitle: 'Aug 3, 2026',
      pageCount: 2,
      fileType: DocumentFileType.image,
      folderName: 'Personal',
    ),
    DocumentSummary(
      id: 'project-plan',
      title: 'Project Plan',
      subtitle: 'Aug 1, 2026',
      pageCount: 8,
      fileType: DocumentFileType.pdf,
      folderName: 'Work',
    ),
  ];

  static const List<FolderSummary> folders = <FolderSummary>[
    FolderSummary(
      id: 'work',
      name: 'Work',
      documentCount: 18,
      visualIndex: 0,
    ),
    FolderSummary(
      id: 'personal',
      name: 'Personal',
      documentCount: 7,
      visualIndex: 1,
    ),
    FolderSummary(
      id: 'receipts',
      name: 'Receipts',
      documentCount: 24,
      visualIndex: 2,
    ),
    FolderSummary(
      id: 'study',
      name: 'Study',
      documentCount: 12,
      visualIndex: 3,
    ),
  ];
}
