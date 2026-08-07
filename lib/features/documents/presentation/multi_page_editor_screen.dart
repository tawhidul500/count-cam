import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/crop_editor/presentation/crop_adjustment_screen.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/widgets/mock_document_page.dart';
import 'package:clearscan/features/filters/presentation/filter_selection_screen.dart';
import 'package:flutter/material.dart';

class MultiPageEditorScreen extends StatefulWidget {
  const MultiPageEditorScreen({
    required this.document,
    this.initialPage = 0,
    super.key,
  });

  final DocumentSummary document;
  final int initialPage;

  @override
  State<MultiPageEditorScreen> createState() => _MultiPageEditorScreenState();
}

class _MultiPageEditorScreenState extends State<MultiPageEditorScreen> {
  late final List<int> _pageIds;
  final Map<int, int> _quarterTurns = <int, int>{};
  final Set<int> _cropAdjustedPages = <int>{};
  final Map<int, FilterPrototypeResult> _pageFilters = <int, FilterPrototypeResult>{};
  int _nextPageId = 100;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _pageIds = List<int>.generate(widget.document.pageCount, (int index) => index + 1);
    _selectedIndex = widget.initialPage.clamp(0, _pageIds.length - 1).toInt();
  }

  int get _selectedPageId => _pageIds[_selectedIndex];

  void _showPlannedAction(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _addPage() {
    setState(() {
      _pageIds.add(_nextPageId++);
      _selectedIndex = _pageIds.length - 1;
    });
  }

  void _duplicatePage() {
    final int sourcePageId = _selectedPageId;
    final int duplicatedPageId = _nextPageId++;

    setState(() {
      _pageIds.insert(_selectedIndex + 1, duplicatedPageId);
      _quarterTurns[duplicatedPageId] = _quarterTurns[sourcePageId] ?? 0;
      if (_cropAdjustedPages.contains(sourcePageId)) {
        _cropAdjustedPages.add(duplicatedPageId);
      }
      final FilterPrototypeResult? sourceFilter = _pageFilters[sourcePageId];
      if (sourceFilter != null) {
        _pageFilters[duplicatedPageId] = sourceFilter;
      }
      _selectedIndex += 1;
    });
  }

  void _rotatePage() {
    setState(() {
      _quarterTurns[_selectedPageId] = ((_quarterTurns[_selectedPageId] ?? 0) + 1) % 4;
    });
  }

  void _deletePage() {
    if (_pageIds.length == 1) {
      _showPlannedAction('A document must keep at least one page.');
      return;
    }

    setState(() {
      final int removed = _pageIds.removeAt(_selectedIndex);
      _quarterTurns.remove(removed);
      _cropAdjustedPages.remove(removed);
      _pageFilters.remove(removed);
      if (_selectedIndex >= _pageIds.length) {
        _selectedIndex = _pageIds.length - 1;
      }
    });
  }

  Future<void> _openCropAdjustment() async {
    final CropPrototypeResult? result = await Navigator.of(context).push<CropPrototypeResult>(
      MaterialPageRoute<CropPrototypeResult>(
        builder: (_) => CropAdjustmentScreen(
          document: widget.document,
          pageNumber: _selectedIndex + 1,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() => _cropAdjustedPages.add(_selectedPageId));
  }

  Future<void> _openFilterSelection() async {
    final FilterPrototypeResult? current = _pageFilters[_selectedPageId];
    final FilterPrototypeResult? result =
        await Navigator.of(context).push<FilterPrototypeResult>(
      MaterialPageRoute<FilterPrototypeResult>(
        builder: (_) => FilterSelectionScreen(
          document: widget.document,
          pageNumber: _selectedIndex + 1,
          initialFilter: current?.filter ?? PrototypeFilter.original,
          initialIntensity: current?.intensity ?? 0.7,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() => _pageFilters[_selectedPageId] = result);
  }

  void _savePrototype() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: Scaffold(
        key: const Key('multi-page-editor'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('close-multi-page-editor'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close editor',
          ),
          title: const Text('Edit pages'),
          actions: <Widget>[
            TextButton.icon(
              key: const Key('save-editor-prototype'),
              onPressed: _savePrototype,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Done'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              const _EditorPrototypeNotice(),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.navySurface,
                    borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: RotatedBox(
                          quarterTurns: _quarterTurns[_selectedPageId] ?? 0,
                          child: MockDocumentPage(
                            key: Key('editor-preview-${_selectedPageId}'),
                            pageNumber: _selectedIndex + 1,
                            documentTitle: widget.document.title,
                            fileType: widget.document.fileType,
                            semanticLabel: 'Editor preview, page ${_selectedIndex + 1}',
                            compact: true,
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: _PageEditStatus(
                          cropAdjusted: _cropAdjustedPages.contains(_selectedPageId),
                          filter: _pageFilters[_selectedPageId]?.filter,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _EditorPageStrip(
                pageIds: _pageIds,
                selectedIndex: _selectedIndex,
                onSelected: (int index) => setState(() => _selectedIndex = index),
                onAdd: _addPage,
              ),
              const SizedBox(height: AppSpacing.xs),
              _EditorToolbar(
                onCrop: _openCropAdjustment,
                onFilter: _openFilterSelection,
                onRotate: _rotatePage,
                onDuplicate: _duplicatePage,
                onDelete: _deletePage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorPrototypeNotice extends StatelessWidget {
  const _EditorPrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('editor-prototype-notice'),
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
          Icon(Icons.edit_note_rounded, color: AppColors.warning, size: 18),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Editor prototype — changes are temporary and are not saved',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorPageStrip extends StatelessWidget {
  const _EditorPageStrip({
    required this.pageIds,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
  });

  final List<int> pageIds;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: pageIds.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          if (index == pageIds.length) {
            return _AddPageButton(onTap: onAdd);
          }

          final bool selected = selectedIndex == index;
          return Semantics(
            button: true,
            selected: selected,
            label: 'Select page ${index + 1}',
            child: InkWell(
              key: Key('editor-page-${index + 1}'),
              onTap: () => onSelected(index),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 56,
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
                            size: 18,
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
        },
      ),
    );
  }
}

class _AddPageButton extends StatelessWidget {
  const _AddPageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a temporary page',
      child: InkWell(
        key: const Key('add-editor-page'),
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
        child: Container(
          width: 56,
          decoration: const BoxDecoration(
            color: AppColors.navyElevated,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
            border: Border.fromBorderSide(BorderSide(color: AppColors.primary)),
          ),
          child: const Icon(Icons.add_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _PageEditStatus extends StatelessWidget {
  const _PageEditStatus({
    required this.cropAdjusted,
    required this.filter,
  });

  final bool cropAdjusted;
  final PrototypeFilter? filter;

  @override
  Widget build(BuildContext context) {
    if (!cropAdjusted && filter == null) {
      return const SizedBox.shrink();
    }

    return Container(
      key: const Key('page-edit-status'),
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.end,
        children: <Widget>[
          if (cropAdjusted)
            const _EditStatusChip(
              key: Key('crop-adjusted-status'),
              icon: Icons.crop_rounded,
              label: 'Crop',
            ),
          if (filter != null)
            _EditStatusChip(
              key: const Key('selected-filter-status'),
              icon: filter!.icon,
              label: filter!.label,
            ),
        ],
      ),
    );
  }
}

class _EditStatusChip extends StatelessWidget {
  const _EditStatusChip({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.navy, size: 14),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.onCrop,
    required this.onFilter,
    required this.onRotate,
    required this.onDuplicate,
    required this.onDelete,
  });

  final VoidCallback onCrop;
  final VoidCallback onFilter;
  final VoidCallback onRotate;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _EditorAction(
              key: const Key('open-crop-adjustment'),
              icon: Icons.crop_rounded,
              label: 'Crop',
              onTap: onCrop,
            ),
          ),
          Expanded(
            child: _EditorAction(
              key: const Key('open-filter-selection'),
              icon: Icons.auto_fix_high_outlined,
              label: 'Filter',
              onTap: onFilter,
            ),
          ),
          Expanded(
            child: _EditorAction(
              key: const Key('rotate-editor-page'),
              icon: Icons.rotate_right_rounded,
              label: 'Rotate',
              onTap: onRotate,
            ),
          ),
          Expanded(
            child: _EditorAction(
              key: const Key('duplicate-editor-page'),
              icon: Icons.copy_all_outlined,
              label: 'Duplicate',
              onTap: onDuplicate,
            ),
          ),
          Expanded(
            child: _EditorAction(
              key: const Key('delete-editor-page'),
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              foreground: AppColors.destructive,
              onTap: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorAction extends StatelessWidget {
  const _EditorAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foreground = AppColors.workspaceText,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: foreground, size: 22),
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
    );
  }
}
