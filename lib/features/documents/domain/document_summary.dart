enum DocumentFileType { pdf, image }

final class DocumentSummary {
  const DocumentSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pageCount,
    required this.fileType,
    this.folderName = 'Unfiled',
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final int pageCount;
  final DocumentFileType fileType;
  final String folderName;
  final bool isFavorite;

  DocumentSummary copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? pageCount,
    DocumentFileType? fileType,
    String? folderName,
    bool? isFavorite,
  }) {
    return DocumentSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      pageCount: pageCount ?? this.pageCount,
      fileType: fileType ?? this.fileType,
      folderName: folderName ?? this.folderName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

final class FolderSummary {
  const FolderSummary({
    required this.id,
    required this.name,
    required this.documentCount,
    required this.visualIndex,
  });

  final String id;
  final String name;
  final int documentCount;
  final int visualIndex;

  FolderSummary copyWith({
    String? id,
    String? name,
    int? documentCount,
    int? visualIndex,
  }) {
    return FolderSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      documentCount: documentCount ?? this.documentCount,
      visualIndex: visualIndex ?? this.visualIndex,
    );
  }
}
