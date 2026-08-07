import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/filters/presentation/filter_selection_screen.dart';
import 'package:clearscan/features/scanner/presentation/scanner_session_page.dart';
import 'package:flutter/material.dart';

class ScanSessionCompletionResult {
  const ScanSessionCompletionResult({
    required this.pages,
    required this.documentTitle,
    required this.folderName,
    required this.savePreviewed,
  });

  final List<ScannerSessionPage> pages;
  final String documentTitle;
  final String folderName;
  final bool savePreviewed;
}

class ScanSessionCompletionScreen extends StatefulWidget {
  const ScanSessionCompletionScreen({
    required this.initialPages,
    super.key,
  });

  final List<ScannerSessionPage> initialPages;

  @override
  State<ScanSessionCompletionScreen> createState() =>
      _ScanSessionCompletionScreenState();
}

class _ScanSessionCompletionScreenState
    extends State<ScanSessionCompletionScreen> {
  static const List<String> _folderOptions = <String>[
    'Unfiled',
    'Work',
    'Receipts',
    'Study',
    'Personal',
  ];

  late final TextEditingController _titleController;
  late final List<ScannerSessionPage> _pages;
  String _folderName = _folderOptions.first;
  String? _status;
  String? _titleError;
  bool _savePreviewed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'New scanned document');
    _pages = List<ScannerSessionPage>.of(widget.initialPages);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _pageCountLabel =>
      _pages.length == 1 ? '1 temporary page' : '${_pages.length} temporary pages';

  int get _cropAdjustedCount =>
      _pages.where((ScannerSessionPage page) => page.cropAdjusted).length;

  int get _filteredCount => _pages
      .where(
        (ScannerSessionPage page) =>
            page.filter != PrototypeFilter.original,
      )
      .length;

  String get _documentTitle => _titleController.text.trim();

  void _markDetailsChanged() {
    setState(() {
      _titleError = null;
      _savePreviewed = false;
    });
  }

  void _movePage(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _pages.length ||
        newIndex < 0 ||
        newIndex >= _pages.length ||
        oldIndex == newIndex) {
      return;
    }

    final ScannerSessionPage page = _pages.removeAt(oldIndex);
    _pages.insert(newIndex, page);
    setState(() {
      _savePreviewed = false;
      _status = 'Moved page ${oldIndex + 1} to position ${newIndex + 1}. '
          'This order exists only in the active scanner session.';
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    _movePage(oldIndex, newIndex);
  }

  Future<void> _chooseFolder() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.navySurface,
      isScrollControlled: true,
      builder: (BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            key: const Key('scan-completion-folder-sheet'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Choose a temporary folder',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.workspaceText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'This selection does not create a folder assignment or change the document library.',
                style: TextStyle(color: AppColors.workspaceMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._folderOptions.map(
                (String folder) => ListTile(
                  key: Key(
                    'scan-completion-folder-${folder.toLowerCase().replaceAll(' ', '-')}',
                  ),
                  leading: const Icon(
                    Icons.folder_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    folder,
                    style: const TextStyle(color: AppColors.workspaceText),
                  ),
                  trailing: folder == _folderName
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(folder),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _folderName = selected;
      _savePreviewed = false;
      _status = 'Temporary folder changed to $selected. Nothing was assigned.';
    });
  }

  Future<void> _previewSave() async {
    FocusScope.of(context).unfocus();
    if (_documentTitle.isEmpty) {
      setState(() {
        _titleError = 'Enter a document title for this preview.';
        _savePreviewed = false;
      });
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('scan-completion-save-dialog'),
        title: const Text('Preview save document?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$_documentTitle • $_folderName • ${_pages.length} ${_pages.length == 1 ? 'page' : 'pages'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'This preview does not create a document, database record, folder assignment, image, or PDF.',
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('scan-completion-confirm-save-preview'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Preview save'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _savePreviewed = true;
      _status = 'Save preview prepared. No document or file was created.';
    });
  }

  void _returnToScanner() {
    Navigator.of(context).pop(
      ScanSessionCompletionResult(
        pages: List<ScannerSessionPage>.unmodifiable(_pages),
        documentTitle:
            _documentTitle.isEmpty ? 'Untitled scan' : _documentTitle,
        folderName: _folderName,
        savePreviewed: _savePreviewed,
      ),
    );
  }

  Future<bool> _handleSystemBack() async {
    _returnToScanner();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: WillPopScope(
        onWillPop: _handleSystemBack,
        child: Scaffold(
        key: const Key('scan-session-completion-screen'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('scan-completion-appbar-back'),
            onPressed: _returnToScanner,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Return to scanner',
          ),
          title: const Text('Finish scan'),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                children: <Widget>[
              const _CompletionPrototypeNotice(),
              if (_status != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                _CompletionStatus(message: _status!),
              ],
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  children: <Widget>[
                    _CompletionSection(
                      title: 'Document details',
                      subtitle:
                          'Title and folder remain inside this preview session.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            key: const Key('scan-completion-title'),
                            controller: _titleController,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => _markDetailsChanged(),
                            decoration: InputDecoration(
                              labelText: 'Document title',
                              prefixIcon: const Icon(
                                Icons.drive_file_rename_outline_rounded,
                              ),
                              errorText: _titleError,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            key: const Key('scan-completion-folder'),
                            onPressed: _chooseFolder,
                            icon: const Icon(Icons.folder_outlined),
                            label: Text('Folder: $_folderName'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CompletionSection(
                      title: 'Page order',
                      subtitle:
                          'Drag a handle or use the arrow controls to change the temporary order.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text(
                            'Reordering changes only this scanner preview. No saved page or device file is moved.',
                            key: Key('scan-completion-reorder-disclosure'),
                            style: TextStyle(
                              color: AppColors.workspaceMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ReorderableListView.builder(
                            key: const Key('scan-completion-reorder-list'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: _pages.length,
                            onReorder: _handleReorder,
                            itemBuilder: (BuildContext context, int index) {
                              final ScannerSessionPage page = _pages[index];
                              return _CompletionPageTile(
                                key: ValueKey<String>(page.id),
                                index: index,
                                page: page,
                                canMoveUp: index > 0,
                                canMoveDown: index < _pages.length - 1,
                                onMoveUp: () => _movePage(index, index - 1),
                                onMoveDown: () => _movePage(index, index + 1),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CompletionSection(
                      title: 'Page summary',
                      subtitle: 'Generated from local mock session metadata.',
                      child: Wrap(
                        key: const Key('scan-completion-page-summary'),
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: <Widget>[
                          _SummaryChip(
                            icon: Icons.collections_outlined,
                            label: _pageCountLabel,
                          ),
                          _SummaryChip(
                            icon: Icons.crop_rounded,
                            label: '$_cropAdjustedCount crop adjusted',
                          ),
                          _SummaryChip(
                            icon: Icons.auto_awesome_outlined,
                            label: '$_filteredCount filtered',
                          ),
                          _SummaryChip(
                            icon: Icons.folder_outlined,
                            label: _folderName,
                          ),
                        ],
                      ),
                    ),
                    if (_savePreviewed) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      _SavePreviewResult(
                        title: _documentTitle,
                        folderName: _folderName,
                        pageCount: _pages.length,
                      ),
                    ],
                  ],
                ),
              ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final bool stackActions = constraints.maxWidth < 520;
                      final List<Widget> actions = <Widget>[
                        OutlinedButton.icon(
                          key: const Key('scan-completion-return-scanner'),
                          onPressed: _returnToScanner,
                          icon: const Icon(Icons.document_scanner_outlined),
                          label: const Text('Return to scanner'),
                        ),
                        FilledButton.icon(
                          key: const Key('scan-completion-preview-save'),
                          onPressed: _previewSave,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Preview save'),
                        ),
                      ];

                      if (stackActions) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            actions.first,
                            const SizedBox(height: AppSpacing.xs),
                            actions.last,
                          ],
                        );
                      }

                      return Row(
                        children: <Widget>[
                          Expanded(child: actions.first),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: actions.last),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
    );
  }
}

class _CompletionPrototypeNotice extends StatelessWidget {
  const _CompletionPrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('scan-completion-prototype-notice'),
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
          Icon(Icons.construction_rounded, color: AppColors.warning, size: 18),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Completion prototype — details, order, folder, and save preview are not persisted',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionStatus extends StatelessWidget {
  const _CompletionStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: Container(
        key: const Key('scan-completion-status'),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CompletionSection extends StatelessWidget {
  const _CompletionSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.workspaceText,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.workspaceMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _CompletionPageTile extends StatelessWidget {
  const _CompletionPageTile({
    required this.index,
    required this.page,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    super.key,
  });

  final int index;
  final ScannerSessionPage page;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final List<String> status = <String>[
      if (page.cropAdjusted) 'Crop adjusted',
      if (page.filter != PrototypeFilter.original) page.filter.label,
    ];

    return Container(
      key: Key('scan-completion-page-$index'),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.documentPaper,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Page ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.workspaceText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${page.sourceLabel} • ${page.scanMode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.workspaceMuted,
                    fontSize: 12,
                  ),
                ),
                if (status.isNotEmpty)
                  Text(
                    status.join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            key: Key('scan-completion-move-up-$index'),
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.arrow_upward_rounded),
            tooltip: 'Move page ${index + 1} up',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            key: Key('scan-completion-move-down-$index'),
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.arrow_downward_rounded),
            tooltip: 'Move page ${index + 1} down',
            visualDensity: VisualDensity.compact,
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                Icons.drag_handle_rounded,
                color: AppColors.workspaceMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: const TextStyle(color: AppColors.workspaceText)),
        ],
      ),
    );
  }
}

class _SavePreviewResult extends StatelessWidget {
  const _SavePreviewResult({
    required this.title,
    required this.folderName,
    required this.pageCount,
  });

  final String title;
  final String folderName;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('scan-completion-save-preview-result'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Save preview ready',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$title • $folderName • $pageCount ${pageCount == 1 ? 'page' : 'pages'}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            'No document, database record, folder assignment, image, or PDF was created.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
