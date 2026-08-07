import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/core/widgets/prototype_state_panel.dart';
import 'package:clearscan/core/widgets/status_announcement.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({
    required this.documents,
    required this.onRestore,
    required this.onDeletePermanently,
    super.key,
  });

  final List<DocumentSummary> documents;
  final ValueChanged<DocumentSummary> onRestore;
  final ValueChanged<DocumentSummary> onDeletePermanently;

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  late final List<DocumentSummary> _documents;
  String? _status;

  @override
  void initState() {
    super.initState();
    _documents = List<DocumentSummary>.of(widget.documents);
  }

  void _restore(DocumentSummary document) {
    widget.onRestore(document);
    setState(() {
      _documents.removeWhere((DocumentSummary item) => item.id == document.id);
      _status = '${document.title} restored to the temporary library.';
    });
  }

  Future<void> _confirmPermanentDelete(DocumentSummary document) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('permanent-delete-dialog'),
        title: const Text('Remove this preview entry?'),
        content: const Text(
          'This prototype only removes the mock item from the current app session. No database record or device file is deleted.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: Key('confirm-permanent-delete-${document.id}'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
            ),
            child: const Text('Remove preview'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    widget.onDeletePermanently(document);
    setState(() {
      _documents.removeWhere((DocumentSummary item) => item.id == document.id);
      _status = '${document.title} removed from this preview session only.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('recently-deleted-screen'),
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('close-recently-deleted'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Close recently deleted',
        ),
        title: const Text('Recently Deleted'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: <Widget>[
            Container(
              key: const Key('recently-deleted-prototype-notice'),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.destructiveSoft,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.large),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.delete_outline_rounded,
                      color: AppColors.destructive),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Recently Deleted prototype — restore and permanent-delete actions only change temporary mock state. Device files and database records are unchanged.',
                    ),
                  ),
                ],
              ),
            ),
            if (_status != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              StatusAnnouncement(
                key: const Key('recently-deleted-status'),
                message: _status!,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_documents.isEmpty)
              const _RecentlyDeletedEmptyState()
            else
              ..._documents.map(
                (DocumentSummary document) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _DeletedDocumentCard(
                    key: Key('deleted-document-${document.id}'),
                    document: document,
                    onRestore: () => _restore(document),
                    onDeletePermanently: () =>
                        _confirmPermanentDelete(document),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeletedDocumentCard extends StatelessWidget {
  const _DeletedDocumentCard({
    required this.document,
    required this.onRestore,
    required this.onDeletePermanently,
    super.key,
  });

  final DocumentSummary document;
  final VoidCallback onRestore;
  final VoidCallback onDeletePermanently;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.small),
                  ),
                ),
                child: Icon(
                  document.fileType == DocumentFileType.pdf
                      ? Icons.description_outlined
                      : Icons.image_outlined,
                  color: document.fileType == DocumentFileType.pdf
                      ? AppColors.destructive
                      : AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(document.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${document.pageCount} page${document.pageCount == 1 ? '' : 's'} • ${document.folderName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              FilledButton.tonalIcon(
                key: Key('restore-deleted-${document.id}'),
                onPressed: onRestore,
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restore'),
              ),
              TextButton.icon(
                key: Key('permanently-delete-${document.id}'),
                onPressed: onDeletePermanently,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete permanently'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentlyDeletedEmptyState extends StatelessWidget {
  const _RecentlyDeletedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const PrototypeStatePanel(
      key: Key('recently-deleted-empty'),
      kind: PrototypeStateKind.empty,
      title: 'No temporary deleted documents',
      message:
          'Items moved here during this session will appear in this preview.',
    );
  }
}
