import 'dart:async';

import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/core/widgets/document_list_tile.dart';
import 'package:clearscan/core/widgets/prototype_state_panel.dart';
import 'package:clearscan/core/widgets/status_announcement.dart';
import 'package:clearscan/features/documents/data/mock_document_data.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/document_viewer_screen.dart';
import 'package:clearscan/features/documents/presentation/recently_deleted_screen.dart';
import 'package:clearscan/features/documents/presentation/widgets/document_grid_card.dart';
import 'package:clearscan/features/search/presentation/search_workspace_screen.dart';
import 'package:flutter/material.dart';

enum _LibraryView { list, grid }

enum _DocumentSort { newest, title, pages }

enum _LibraryPreviewState { content, loading, empty, error }

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<DocumentSummary> _documents =
      List<DocumentSummary>.of(MockDocumentData.recentDocuments);
  final List<DocumentSummary> _deletedDocuments = <DocumentSummary>[];
  final Set<String> _favoriteIds = MockDocumentData.recentDocuments
      .where((DocumentSummary document) => document.isFavorite)
      .map((DocumentSummary document) => document.id)
      .toSet();
  final Set<String> _selectedIds = <String>{};

  int _selectedFilter = 0;
  _LibraryView _view = _LibraryView.list;
  _DocumentSort _sort = _DocumentSort.newest;
  bool _selectionMode = false;
  _LibraryPreviewState _previewState = _LibraryPreviewState.content;
  String? _status;

  List<DocumentSummary> get _visibleDocuments {
    final List<DocumentSummary> documents = _documents
        .map(
          (DocumentSummary document) => document.copyWith(
            isFavorite: _favoriteIds.contains(document.id),
          ),
        )
        .where((DocumentSummary document) {
          return switch (_selectedFilter) {
            1 => document.fileType == DocumentFileType.pdf,
            2 => document.fileType == DocumentFileType.image,
            3 => document.isFavorite,
            _ => true,
          };
        })
        .toList();

    switch (_sort) {
      case _DocumentSort.newest:
        break;
      case _DocumentSort.title:
        documents.sort(
          (DocumentSummary a, DocumentSummary b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case _DocumentSort.pages:
        documents.sort(
          (DocumentSummary a, DocumentSummary b) =>
              b.pageCount.compareTo(a.pageCount),
        );
        break;
    }

    return documents;
  }

  String get _sortLabel => switch (_sort) {
        _DocumentSort.newest => 'Newest first',
        _DocumentSort.title => 'Title A–Z',
        _DocumentSort.pages => 'Most pages',
      };

  void _openSearch() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const SearchWorkspaceScreen(),
        ),
      ),
    );
  }

  void _openDocument(DocumentSummary document) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              DocumentViewerScreen(document: document),
        ),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedIds.clear();
      _status = null;
    });
  }

  void _toggleDocumentSelection(String documentId) {
    setState(() {
      if (_selectedIds.contains(documentId)) {
        _selectedIds.remove(documentId);
      } else {
        _selectedIds.add(documentId);
      }
    });
  }

  void _handleDocumentTap(DocumentSummary document) {
    if (_selectionMode) {
      _toggleDocumentSelection(document.id);
      return;
    }
    _openDocument(document);
  }

  void _startSelectionWith(DocumentSummary document) {
    setState(() {
      _selectionMode = true;
      _selectedIds
        ..clear()
        ..add(document.id);
      _status = null;
    });
  }

  void _selectAllVisible() {
    final List<DocumentSummary> visible = _visibleDocuments;
    setState(() {
      final bool allSelected = visible.isNotEmpty &&
          visible.every(
            (DocumentSummary document) => _selectedIds.contains(document.id),
          );
      if (allSelected) {
        _selectedIds.removeAll(
          visible.map((DocumentSummary document) => document.id),
        );
      } else {
        _selectedIds.addAll(
          visible.map((DocumentSummary document) => document.id),
        );
      }
    });
  }

  void _toggleFavoriteForSelected() {
    if (_selectedIds.isEmpty) {
      return;
    }

    final bool allFavorites =
        _selectedIds.every((String id) => _favoriteIds.contains(id));
    setState(() {
      if (allFavorites) {
        _favoriteIds.removeAll(_selectedIds);
        _status =
            '${_selectedIds.length} document${_selectedIds.length == 1 ? '' : 's'} removed from temporary favorites.';
      } else {
        _favoriteIds.addAll(_selectedIds);
        _status =
            '${_selectedIds.length} document${_selectedIds.length == 1 ? '' : 's'} added to temporary favorites.';
      }
    });
  }

  void _moveSelectedToRecentlyDeleted() {
    if (_selectedIds.isEmpty) {
      return;
    }

    final List<DocumentSummary> moving = _documents
        .where((DocumentSummary document) => _selectedIds.contains(document.id))
        .map(
          (DocumentSummary document) => document.copyWith(
            isFavorite: _favoriteIds.contains(document.id),
          ),
        )
        .toList(growable: false);

    setState(() {
      _deletedDocuments.insertAll(0, moving);
      _documents.removeWhere(
        (DocumentSummary document) => _selectedIds.contains(document.id),
      );
      _status =
          '${moving.length} document${moving.length == 1 ? '' : 's'} moved to the temporary Recently Deleted preview. Device files were not changed.';
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  void _restoreDeleted(DocumentSummary document) {
    setState(() {
      _deletedDocuments.removeWhere(
        (DocumentSummary item) => item.id == document.id,
      );
      if (_documents.every((DocumentSummary item) => item.id != document.id)) {
        _documents.insert(0, document.copyWith(isFavorite: false));
      }
      if (document.isFavorite) {
        _favoriteIds.add(document.id);
      }
      _status =
          '${document.title} restored to the temporary library. No device file was changed.';
    });
  }

  void _removeDeletedPreview(DocumentSummary document) {
    setState(() {
      _deletedDocuments.removeWhere(
        (DocumentSummary item) => item.id == document.id,
      );
      _favoriteIds.remove(document.id);
      _status =
          '${document.title} removed from temporary Recently Deleted only.';
    });
  }

  void _openRecentlyDeleted() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => RecentlyDeletedScreen(
            documents: List<DocumentSummary>.of(_deletedDocuments),
            onRestore: _restoreDeleted,
            onDeletePermanently: _removeDeletedPreview,
          ),
        ),
      ),
    );
  }

  Future<void> _openSortSheet() async {
    final _DocumentSort? selected = await showModalBottomSheet<_DocumentSort>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          key: const Key('documents-sort-sheet'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Sort documents',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              RadioListTile<_DocumentSort>(
                key: const Key('documents-sort-newest'),
                value: _DocumentSort.newest,
                groupValue: _sort,
                title: const Text('Newest first'),
                onChanged: (_DocumentSort? value) =>
                    Navigator.of(context).pop(value),
              ),
              RadioListTile<_DocumentSort>(
                key: const Key('documents-sort-title'),
                value: _DocumentSort.title,
                groupValue: _sort,
                title: const Text('Title A–Z'),
                onChanged: (_DocumentSort? value) =>
                    Navigator.of(context).pop(value),
              ),
              RadioListTile<_DocumentSort>(
                key: const Key('documents-sort-pages'),
                value: _DocumentSort.pages,
                groupValue: _sort,
                title: const Text('Most pages'),
                onChanged: (_DocumentSort? value) =>
                    Navigator.of(context).pop(value),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _sort = selected;
        _status = 'Temporary sort changed to $_sortLabel.';
      });
    }
  }

  Future<void> _openLibraryStatePreview() async {
    final _LibraryPreviewState? selected =
        await showModalBottomSheet<_LibraryPreviewState>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            key: const Key('documents-state-preview-sheet'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Preview library state',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Loading, empty, and error states are visual education only. No repository request is made.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                key: const Key('documents-state-content'),
                leading: const Icon(Icons.library_books_outlined),
                title: const Text('Content'),
                onTap: () => Navigator.of(context).pop(
                  _LibraryPreviewState.content,
                ),
              ),
              ListTile(
                key: const Key('documents-state-loading'),
                leading: const Icon(Icons.hourglass_top_rounded),
                title: const Text('Loading'),
                onTap: () => Navigator.of(context).pop(
                  _LibraryPreviewState.loading,
                ),
              ),
              ListTile(
                key: const Key('documents-state-empty'),
                leading: const Icon(Icons.inbox_outlined),
                title: const Text('Empty'),
                onTap: () => Navigator.of(context).pop(
                  _LibraryPreviewState.empty,
                ),
              ),
              ListTile(
                key: const Key('documents-state-error'),
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Error'),
                onTap: () => Navigator.of(context).pop(
                  _LibraryPreviewState.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _previewState = selected;
      _selectionMode = false;
      _selectedIds.clear();
      _status = selected == _LibraryPreviewState.content
          ? 'Returned to the temporary document library.'
          : 'Previewing ${selected.name} state. No data request was made.';
    });
  }

  Widget _buildPreviewStatePanel() {
    return switch (_previewState) {
      _LibraryPreviewState.loading => const PrototypeStatePanel(
          key: Key('documents-loading-state'),
          kind: PrototypeStateKind.loading,
          title: 'Loading document library',
          message:
              'This is a visual placeholder. No database, storage, or network request is running.',
        ),
      _LibraryPreviewState.empty => PrototypeStatePanel(
          key: const Key('documents-empty-preview-state'),
          kind: PrototypeStateKind.empty,
          title: 'Your library could be empty',
          message:
              'A real empty library would offer scan and import actions. Mock documents remain unchanged.',
          actionLabel: 'Return to library',
          onAction: () => setState(
            () => _previewState = _LibraryPreviewState.content,
          ),
        ),
      _LibraryPreviewState.error => PrototypeStatePanel(
          key: const Key('documents-error-state'),
          kind: PrototypeStateKind.error,
          title: 'Library could not be loaded',
          message:
              'This error is simulated for recovery education. No request failed and no document is at risk.',
          actionLabel: 'Retry preview',
          onAction: () => setState(() {
            _previewState = _LibraryPreviewState.content;
            _status = 'Retry preview completed. No repository request was made.';
          }),
        ),
      _LibraryPreviewState.content => const SizedBox.shrink(),
    };
  }

  void _changeFilter(int index) {
    setState(() {
      _selectedFilter = index;
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<String> filters = <String>['All', 'PDF', 'Images', 'Favorites'];
    const List<Key> filterKeys = <Key>[
      Key('documents-filter-all'),
      Key('documents-filter-pdf'),
      Key('documents-filter-images'),
      Key('documents-filter-favorites'),
    ];
    final List<DocumentSummary> visibleDocuments = _visibleDocuments;

    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey<String>('documents-scroll'),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Documents',
                              style: Theme.of(context).textTheme.headlineSmall),
                          Text(
                            '${_documents.length} temporary file${_documents.length == 1 ? '' : 's'} in this library preview',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: <Widget>[
                        IconButton.filledTonal(
                          key: const Key('documents-preview-states'),
                          onPressed: _openLibraryStatePreview,
                          icon: const Icon(Icons.preview_outlined),
                          tooltip: 'Preview loading, empty, and error states',
                        ),
                        IconButton.filledTonal(
                          key: const Key('documents-sort'),
                          onPressed: _openSortSheet,
                          icon: const Icon(Icons.sort_rounded),
                          tooltip: 'Sort documents',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  key: const Key('documents-library-prototype-notice'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.infoSoft,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.large),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.library_books_outlined, color: AppColors.info),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Library prototype — view, sorting, favorites, selection, and Recently Deleted only change temporary widget state. Database records and device files are unchanged.',
                        ),
                      ),
                    ],
                  ),
                ),
                if (_status != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  StatusAnnouncement(
                    key: const Key('documents-library-status'),
                    message: _status!,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('documents-open-search'),
                  readOnly: true,
                  onTap: _openSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search your documents',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List<Widget>.generate(
                      filters.length,
                      (int index) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: ChoiceChip(
                          key: filterKeys[index],
                          label: Text(filters[index]),
                          selected: _selectedFilter == index,
                          selectedColor: AppColors.primarySoft,
                          labelStyle: TextStyle(
                            color: _selectedFilter == index
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => _changeFilter(index),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    IconButton(
                      key: const Key('documents-view-list'),
                      onPressed: () => setState(() => _view = _LibraryView.list),
                      icon: const Icon(Icons.view_list_rounded),
                      tooltip: 'Show list view',
                      style: IconButton.styleFrom(
                        backgroundColor: _view == _LibraryView.list
                            ? AppColors.primarySoft
                            : AppColors.surfaceMuted,
                        foregroundColor: _view == _LibraryView.list
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      key: const Key('documents-view-grid'),
                      onPressed: () => setState(() => _view = _LibraryView.grid),
                      icon: const Icon(Icons.grid_view_rounded),
                      tooltip: 'Show grid view',
                      style: IconButton.styleFrom(
                        backgroundColor: _view == _LibraryView.grid
                            ? AppColors.primarySoft
                            : AppColors.surfaceMuted,
                        foregroundColor: _view == _LibraryView.grid
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    OutlinedButton.icon(
                      key: const Key('documents-toggle-selection'),
                      onPressed: _toggleSelectionMode,
                      icon: Icon(
                        _selectionMode
                            ? Icons.close_rounded
                            : Icons.checklist_rounded,
                      ),
                      label: Text(_selectionMode ? 'Cancel selection' : 'Select'),
                    ),
                    TextButton.icon(
                      key: const Key('documents-open-recently-deleted'),
                      onPressed: _openRecentlyDeleted,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text('Deleted (${_deletedDocuments.length})'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    const Icon(Icons.swap_vert_rounded,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      _sortLabel,
                      key: const Key('documents-sort-label'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${visibleDocuments.length} shown',
                      key: const Key('documents-visible-count'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                if (_selectionMode) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  _SelectionToolbar(
                    selectedCount: _selectedIds.length,
                    onSelectAll: _selectAllVisible,
                    onFavorite: _toggleFavoriteForSelected,
                    onDelete: _moveSelectedToRecentlyDeleted,
                  ),
                ],
              ],
            ),
          ),
          if (_previewState != _LibraryPreviewState.content)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(child: _buildPreviewStatePanel()),
            )
          else if (visibleDocuments.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(child: _LibraryEmptyState()),
            )
          else if (_view == _LibraryView.list)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.display + AppSpacing.xl,
              ),
              sliver: SliverList.builder(
                itemCount: visibleDocuments.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSummary document = visibleDocuments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DocumentListTile(
                      key: Key('document-${document.id}'),
                      document: document,
                      selectionMode: _selectionMode,
                      isSelected: _selectedIds.contains(document.id),
                      onTap: () => _handleDocumentTap(document),
                      onLongPress: () => _startSelectionWith(document),
                    ),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.display + AppSpacing.xl,
              ),
              sliver: SliverGrid.builder(
                itemCount: visibleDocuments.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSummary document = visibleDocuments[index];
                  return DocumentGridCard(
                    key: Key('document-grid-${document.id}'),
                    document: document,
                    selectionMode: _selectionMode,
                    isSelected: _selectedIds.contains(document.id),
                    onTap: () => _handleDocumentTap(document),
                    onLongPress: () => _startSelectionWith(document),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.selectedCount,
    required this.onSelectAll,
    required this.onFavorite,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('library-selection-toolbar'),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.primaryMuted)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            selectedCount == 0
                ? 'Tap documents to select'
                : '$selectedCount selected',
            key: const Key('documents-selection-count'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              TextButton.icon(
                key: const Key('documents-select-all'),
                onPressed: onSelectAll,
                icon: const Icon(Icons.select_all_rounded),
                label: const Text('Select all'),
              ),
              FilledButton.tonalIcon(
                key: const Key('favorite-selected-documents'),
                onPressed: selectedCount == 0 ? null : onFavorite,
                icon: const Icon(Icons.star_outline_rounded),
                label: const Text('Favorite'),
              ),
              FilledButton.tonalIcon(
                key: const Key('delete-selected-documents'),
                onPressed: selectedCount == 0 ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
                style: FilledButton.styleFrom(
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

class _LibraryEmptyState extends StatelessWidget {
  const _LibraryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const PrototypeStatePanel(
      key: Key('documents-library-empty'),
      kind: PrototypeStateKind.empty,
      title: 'No documents in this view',
      message:
          'Change the filter or create a future scan. Device files are not being searched.',
    );
  }
}
