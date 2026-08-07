import 'dart:async';

import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/document_actions_sheet.dart';
import 'package:clearscan/features/documents/presentation/multi_page_editor_screen.dart';
import 'package:clearscan/features/documents/presentation/widgets/mock_document_page.dart';
import 'package:clearscan/features/export/presentation/pdf_export_options_screen.dart';
import 'package:clearscan/features/ocr/presentation/ocr_text_workspace_screen.dart';
import 'package:clearscan/features/share/presentation/share_options_screen.dart';
import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({
    required this.document,
    super.key,
  });

  final DocumentSummary document;

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late final PageController _pageController;
  late bool _isFavorite;
  late String _documentTitle;
  int _selectedPage = 0;
  String _currentFolder = 'No folder';
  bool _isMarkedDeleted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isFavorite = widget.document.isFavorite;
    _documentTitle = widget.document.title;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _hasTemporaryChanges =>
      _documentTitle != widget.document.title ||
      _currentFolder != 'No folder' ||
      _isFavorite != widget.document.isFavorite ||
      _isMarkedDeleted;

  DocumentSummary get _temporaryDocument => DocumentSummary(
        id: widget.document.id,
        title: _documentTitle,
        subtitle: widget.document.subtitle,
        pageCount: widget.document.pageCount,
        fileType: widget.document.fileType,
        isFavorite: _isFavorite,
      );

  void _selectPage(int index) {
    setState(() => _selectedPage = index);
    unawaited(
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _showTemporaryMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openShareOptions() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ShareOptionsScreen(
            document: _temporaryDocument,
            currentPage: _selectedPage + 1,
          ),
        ),
      ),
    );
  }

  void _openPdfExport() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => PdfExportOptionsScreen(
            document: _temporaryDocument,
            currentPage: _selectedPage + 1,
          ),
        ),
      ),
    );
  }

  void _openOcrWorkspace() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => OcrTextWorkspaceScreen(
            document: _temporaryDocument,
            currentPage: _selectedPage + 1,
          ),
        ),
      ),
    );
  }

  void _openEditor() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => MultiPageEditorScreen(
            document: _temporaryDocument,
            initialPage: _selectedPage,
          ),
        ),
      ),
    );
  }

  Future<void> _openDocumentActions() async {
    final DocumentManagementAction? action =
        await showModalBottomSheet<DocumentManagementAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => DocumentActionsSheet(
        document: _temporaryDocument,
        currentTitle: _documentTitle,
        currentFolder: _currentFolder,
        isFavorite: _isFavorite,
        isMarkedDeleted: _isMarkedDeleted,
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case DocumentManagementAction.rename:
        await _renameDocument();
        break;
      case DocumentManagementAction.move:
        await _moveDocument();
        break;
      case DocumentManagementAction.toggleFavorite:
        setState(() => _isFavorite = !_isFavorite);
        _showTemporaryMessage(
          _isFavorite
              ? 'Marked as a favorite in this preview only.'
              : 'Favorite removed in this preview only.',
        );
        break;
      case DocumentManagementAction.info:
        await _showDocumentInfo();
        break;
      case DocumentManagementAction.delete:
        await _toggleDeletionMark();
        break;
    }
  }

  Future<void> _renameDocument() async {
    final TextEditingController controller = TextEditingController(
      text: _documentTitle,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('rename-document-dialog'),
        title: const Text('Rename document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              key: const Key('rename-document-title'),
              controller: controller,
              autofocus: true,
              maxLength: 80,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Document title'),
              onSubmitted: (String value) {
                Navigator.of(context).pop(value.trim());
              },
            ),
            const Text(
              'This title is temporary and is not saved to device storage.',
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('apply-rename-prototype'),
            onPressed: () => Navigator.of(context).pop(
              controller.text.trim(),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted || result == null) {
      return;
    }
    if (result.isEmpty) {
      _showTemporaryMessage('Enter a document title before applying.');
      return;
    }

    setState(() => _documentTitle = result);
    _showTemporaryMessage('Document renamed in this preview only.');
  }

  Future<void> _moveDocument() async {
    const List<String> folders = <String>[
      'No folder',
      'Work',
      'Receipts',
      'Personal',
    ];
    final String? folder = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => SafeArea(
        child: Container(
          key: const Key('move-document-sheet'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: AppColors.navySurface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.extraLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Move to folder',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              const Text(
                'This selection is temporary and does not move a device file.',
                style: TextStyle(color: AppColors.workspaceMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final String item in folders)
                ListTile(
                  key: Key('move-folder-${item.toLowerCase().replaceAll(' ', '-')}'),
                  onTap: () => Navigator.of(context).pop(item),
                  leading: Icon(
                    item == _currentFolder
                        ? Icons.check_circle_rounded
                        : Icons.folder_outlined,
                    color: item == _currentFolder
                        ? AppColors.primary
                        : AppColors.workspaceText,
                  ),
                  title: Text(item),
                  trailing: item == _currentFolder
                      ? const Text(
                          'Current',
                          style: TextStyle(color: AppColors.primary),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || folder == null) {
      return;
    }
    setState(() => _currentFolder = folder);
    _showTemporaryMessage('Folder changed to $folder in this preview only.');
  }

  Future<void> _showDocumentInfo() {
    final String fileType = switch (widget.document.fileType) {
      DocumentFileType.pdf => 'PDF document',
      DocumentFileType.image => 'Image document',
    };

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('document-info-dialog'),
        title: const Text('Document info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _InfoRow(label: 'Title', value: _documentTitle),
            _InfoRow(label: 'Type', value: fileType),
            _InfoRow(
              label: 'Pages',
              value: widget.document.pageCount.toString(),
            ),
            _InfoRow(label: 'Folder', value: _currentFolder),
            _InfoRow(label: 'Source status', value: widget.document.subtitle),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Mock metadata only — no local file properties are being read.',
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ],
        ),
        actions: <Widget>[
          FilledButton(
            key: const Key('close-document-info'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDeletionMark() async {
    if (_isMarkedDeleted) {
      setState(() => _isMarkedDeleted = false);
      _showTemporaryMessage('Temporary deletion mark cleared.');
      return;
    }

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            key: const Key('delete-document-dialog'),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.destructive,
            ),
            title: const Text('Delete document?'),
            content: const Text(
              'This prototype will only mark the viewer as deleted. No device file, page, or database record will be removed.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const Key('confirm-delete-prototype'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.destructive,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Mark deleted'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !confirmed) {
      return;
    }
    setState(() => _isMarkedDeleted = true);
    _showTemporaryMessage('Marked for deletion in this preview only.');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: Scaffold(
        key: const Key('document-viewer'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('close-document-viewer'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to documents',
          ),
          title: Column(
            children: <Widget>[
              Text(
                _documentTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${widget.document.pageCount} page${widget.document.pageCount == 1 ? '' : 's'} • $_currentFolder',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.workspaceMuted,
                    ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              key: const Key('toggle-document-favorite'),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              icon: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _isFavorite
                    ? AppColors.warning
                    : AppColors.workspaceText,
              ),
              tooltip: _isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            ),
            IconButton(
              key: const Key('open-document-actions-appbar'),
              onPressed: _openDocumentActions,
              icon: const Icon(Icons.more_horiz_rounded),
              tooltip: 'More document options',
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              const _ViewerPrototypeNotice(),
              if (_hasTemporaryChanges) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                _TemporaryDocumentStatus(
                  titleChanged: _documentTitle != widget.document.title,
                  folder: _currentFolder,
                  favoriteChanged:
                      _isFavorite != widget.document.isFavorite,
                  markedDeleted: _isMarkedDeleted,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWide = constraints.maxWidth >= 720;
                    if (isWide) {
                      return Row(
                        children: <Widget>[
                          Expanded(child: _buildPreview()),
                          SizedBox(
                            width: 150,
                            child: _VerticalPageRail(
                              pageCount: widget.document.pageCount,
                              selectedPage: _selectedPage,
                              onSelected: _selectPage,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: <Widget>[
                        Expanded(child: _buildPreview()),
                        const SizedBox(height: AppSpacing.sm),
                        _HorizontalPageRail(
                          pageCount: widget.document.pageCount,
                          selectedPage: _selectedPage,
                          onSelected: _selectPage,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ViewerActionBar(
                onShare: _openShareOptions,
                onExport: _openPdfExport,
                onOcr: _openOcrWorkspace,
                onEdit: _openEditor,
                onMore: _openDocumentActions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.document.pageCount,
        onPageChanged: (int index) => setState(() => _selectedPage = index),
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: MockDocumentPage(
              pageNumber: index + 1,
              documentTitle: _documentTitle,
              fileType: widget.document.fileType,
              semanticLabel: '$_documentTitle, page ${index + 1}',
            ),
          );
        },
      ),
    );
  }
}

class _TemporaryDocumentStatus extends StatelessWidget {
  const _TemporaryDocumentStatus({
    required this.titleChanged,
    required this.folder,
    required this.favoriteChanged,
    required this.markedDeleted,
  });

  final bool titleChanged;
  final String folder;
  final bool favoriteChanged;
  final bool markedDeleted;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      if (titleChanged) 'Renamed',
      if (folder != 'No folder') 'Folder: $folder',
      if (favoriteChanged) 'Favorite changed',
      if (markedDeleted) 'Marked deleted',
    ];

    return Container(
      key: const Key('temporary-document-status'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: markedDeleted
            ? AppColors.destructiveSoft
            : AppColors.primarySoft,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppRadius.medium),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            markedDeleted
                ? Icons.delete_outline_rounded
                : Icons.edit_note_rounded,
            color: markedDeleted
                ? AppColors.destructive
                : AppColors.primaryDark,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Temporary: ${labels.join(' • ')}',
              style: TextStyle(
                color: markedDeleted
                    ? AppColors.destructive
                    : AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerPrototypeNotice extends StatelessWidget {
  const _ViewerPrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('document-viewer-prototype-notice'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.visibility_outlined, color: AppColors.info, size: 18),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Viewer prototype — mock pages only, no saved file is opened',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalPageRail extends StatelessWidget {
  const _HorizontalPageRail({
    required this.pageCount,
    required this.selectedPage,
    required this.onSelected,
  });

  final int pageCount;
  final int selectedPage;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: pageCount,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          return _PageThumbnail(
            index: index,
            selected: selectedPage == index,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _VerticalPageRail extends StatelessWidget {
  const _VerticalPageRail({
    required this.pageCount,
    required this.selectedPage,
    required this.onSelected,
  });

  final int pageCount;
  final int selectedPage;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 0, AppSpacing.md, 0),
      itemCount: pageCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (BuildContext context, int index) {
        return Align(
          alignment: Alignment.center,
          child: _PageThumbnail(
            index: index,
            selected: selectedPage == index,
            onTap: () => onSelected(index),
          ),
        );
      },
    );
  }
}

class _PageThumbnail extends StatelessWidget {
  const _PageThumbnail({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Open page ${index + 1}',
      child: InkWell(
        key: Key('viewer-page-${index + 1}'),
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 58,
          padding: const EdgeInsets.all(AppSpacing.xxs),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.navyElevated,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.documentPaper,
                    borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.subject_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? AppColors.navy : AppColors.workspaceText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerActionBar extends StatelessWidget {
  const _ViewerActionBar({
    required this.onShare,
    required this.onExport,
    required this.onOcr,
    required this.onEdit,
    required this.onMore,
  });

  final VoidCallback onShare;
  final VoidCallback onExport;
  final VoidCallback onOcr;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _ViewerAction(
              key: const Key('open-share-options'),
              icon: Icons.ios_share_rounded,
              label: 'Share',
              onTap: onShare,
            ),
            _ViewerAction(
              key: const Key('open-pdf-export-options'),
              icon: Icons.picture_as_pdf_outlined,
              label: 'PDF',
              onTap: onExport,
            ),
            _ViewerAction(
              key: const Key('open-ocr-text-workspace'),
              icon: Icons.text_snippet_outlined,
              label: 'OCR',
              onTap: onOcr,
            ),
            _ViewerAction(
              key: const Key('edit-document-pages'),
              icon: Icons.edit_note_rounded,
              label: 'Edit pages',
              highlighted: true,
              onTap: onEdit,
            ),
            _ViewerAction(
              key: const Key('open-document-actions-more'),
              icon: Icons.more_horiz_rounded,
              label: 'More',
              onTap: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerAction extends StatelessWidget {
  const _ViewerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color foreground = highlighted ? AppColors.primary : AppColors.workspaceText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
        child: SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: foreground),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
