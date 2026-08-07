import 'dart:async';

import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/core/widgets/adaptive_content_frame.dart';
import 'package:clearscan/core/widgets/document_list_tile.dart';
import 'package:clearscan/core/widgets/prototype_state_panel.dart';
import 'package:clearscan/features/documents/data/mock_document_data.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/document_viewer_screen.dart';
import 'package:flutter/material.dart';

enum _SearchTypeFilter { all, pdf, image }

class SearchWorkspaceScreen extends StatefulWidget {
  const SearchWorkspaceScreen({super.key});

  @override
  State<SearchWorkspaceScreen> createState() => _SearchWorkspaceScreenState();
}

class _SearchWorkspaceScreenState extends State<SearchWorkspaceScreen> {
  final TextEditingController _queryController = TextEditingController();
  _SearchTypeFilter _typeFilter = _SearchTypeFilter.all;
  bool _favoritesOnly = false;
  String _folderFilter = 'All folders';

  List<String> get _folderOptions => <String>[
        'All folders',
        ...MockDocumentData.folders.map((FolderSummary folder) => folder.name),
        'Unfiled',
      ];

  List<DocumentSummary> get _results {
    final String query = _queryController.text.trim().toLowerCase();

    return MockDocumentData.recentDocuments.where((DocumentSummary document) {
      final bool matchesQuery = query.isEmpty ||
          document.title.toLowerCase().contains(query) ||
          document.folderName.toLowerCase().contains(query) ||
          document.fileType.name.toLowerCase().contains(query);
      final bool matchesType = switch (_typeFilter) {
        _SearchTypeFilter.all => true,
        _SearchTypeFilter.pdf => document.fileType == DocumentFileType.pdf,
        _SearchTypeFilter.image => document.fileType == DocumentFileType.image,
      };
      final bool matchesFolder =
          _folderFilter == 'All folders' || document.folderName == _folderFilter;
      final bool matchesFavorite = !_favoritesOnly || document.isFavorite;

      return matchesQuery && matchesType && matchesFolder && matchesFavorite;
    }).toList(growable: false);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
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

  void _clearFilters() {
    _queryController.clear();
    setState(() {
      _typeFilter = _SearchTypeFilter.all;
      _favoritesOnly = false;
      _folderFilter = 'All folders';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DocumentSummary> results = _results;

    return Scaffold(
      key: const Key('search-workspace-screen'),
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('close-search-workspace'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Close search',
        ),
        title: const Text('Search'),
        actions: <Widget>[
          TextButton(
            key: const Key('clear-search-filters'),
            onPressed: _clearFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AdaptiveContentFrame(
          padding: EdgeInsets.zero,
          child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: <Widget>[
            Container(
              key: const Key('search-prototype-notice'),
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
                  Icon(Icons.manage_search_rounded, color: AppColors.info),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Search prototype — results use isolated mock titles, folders, file types, and favorite state. OCR indexing, recent-search history, and persisted search do not exist yet.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('search-query-field'),
              controller: _queryController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search title, folder, or file type',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _queryController.text.isEmpty
                    ? null
                    : IconButton(
                        key: const Key('clear-search-query'),
                        onPressed: () {
                          _queryController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Clear search query',
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('File type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                ChoiceChip(
                  key: const Key('search-type-all'),
                  label: const Text('All'),
                  selected: _typeFilter == _SearchTypeFilter.all,
                  onSelected: (_) =>
                      setState(() => _typeFilter = _SearchTypeFilter.all),
                ),
                ChoiceChip(
                  key: const Key('search-type-pdf'),
                  label: const Text('PDF'),
                  selected: _typeFilter == _SearchTypeFilter.pdf,
                  onSelected: (_) =>
                      setState(() => _typeFilter = _SearchTypeFilter.pdf),
                ),
                ChoiceChip(
                  key: const Key('search-type-images'),
                  label: const Text('Images'),
                  selected: _typeFilter == _SearchTypeFilter.image,
                  onSelected: (_) =>
                      setState(() => _typeFilter = _SearchTypeFilter.image),
                ),
                FilterChip(
                  key: const Key('search-favorites-filter'),
                  avatar: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Favorites'),
                  selected: _favoritesOnly,
                  onSelected: (bool selected) =>
                      setState(() => _favoritesOnly = selected),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              key: const Key('search-folder-filter'),
              value: _folderFilter,
              decoration: const InputDecoration(
                labelText: 'Folder',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              items: _folderOptions
                  .map(
                    (String folder) => DropdownMenuItem<String>(
                      value: folder,
                      child: Text(folder),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _folderFilter = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${results.length} found',
                  key: const Key('search-result-count'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (results.isEmpty)
              const _SearchEmptyState()
            else
              ...results.map(
                (DocumentSummary document) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: DocumentListTile(
                    key: Key('search-result-${document.id}'),
                    document: document,
                    onTap: () => _openDocument(document),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return const PrototypeStatePanel(
      key: Key('search-empty-state'),
      kind: PrototypeStateKind.empty,
      title: 'No mock documents match',
      message:
          'Change the query or filters. No device files are searched in this prototype.',
    );
  }
}
