import 'dart:async';

import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/features/documents/data/mock_document_data.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final List<FolderSummary> _folders =
      List<FolderSummary>.of(MockDocumentData.folders);
  int _nextTemporaryFolder = 1;
  String? _statusMessage;

  List<FolderSummary> get _visibleFolders {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return List<FolderSummary>.unmodifiable(_folders);
    }
    return _folders
        .where((FolderSummary folder) => folder.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    final _FolderEditorResult? result = await showModalBottomSheet<_FolderEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) => const _FolderEditorSheet(),
    );

    if (!mounted || result == null) {
      return;
    }

    final String id = 'temporary-folder-${_nextTemporaryFolder++}';
    setState(() {
      _folders.add(
        FolderSummary(
          id: id,
          name: result.name,
          documentCount: 0,
          visualIndex: result.visualIndex,
        ),
      );
      _statusMessage =
          'Created "${result.name}" for this preview only. Device storage was not changed.';
    });
  }

  Future<void> _openFolderActions(FolderSummary folder) async {
    final _FolderAction? action = await showModalBottomSheet<_FolderAction>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) => _FolderActionsSheet(folder: folder),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _FolderAction.edit:
        await _editFolder(folder);
        break;
      case _FolderAction.delete:
        await _confirmDelete(folder);
        break;
    }
  }

  Future<void> _editFolder(FolderSummary folder) async {
    final _FolderEditorResult? result = await showModalBottomSheet<_FolderEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) => _FolderEditorSheet(
        initialName: folder.name,
        initialVisualIndex: folder.visualIndex,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final int index = _folders.indexWhere(
      (FolderSummary item) => item.id == folder.id,
    );
    if (index < 0) {
      return;
    }

    setState(() {
      _folders[index] = folder.copyWith(
        name: result.name,
        visualIndex: result.visualIndex,
      );
      _statusMessage =
          'Updated "${result.name}" in this preview. Documents and device storage were not changed.';
    });
  }

  Future<void> _confirmDelete(FolderSummary folder) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('delete-folder-dialog'),
        icon: const Icon(
          Icons.folder_delete_outlined,
          color: AppColors.destructive,
        ),
        title: Text('Remove ${folder.name}?'),
        content: const Text(
          'This prototype only removes the folder card for the current session. Documents are not deleted or moved, and device storage is unchanged.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-delete-folder-prototype'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.surface,
            ),
            child: const Text('Remove preview'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _folders.removeWhere((FolderSummary item) => item.id == folder.id);
      _statusMessage =
          'Removed "${folder.name}" from this preview. Documents and device storage were not changed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<FolderSummary> visibleFolders = _visibleFolders;

    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey<String>('folders-scroll'),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.display + AppSpacing.xl,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Folders',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Keep related scans together',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      key: const Key('create-folder'),
                      onPressed: () => unawaited(_createFolder()),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('New'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  key: const Key('folder-prototype-notice'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.large),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.folder_copy_outlined,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Folder prototype — create, rename, recolour, and remove actions are temporary. Removing a folder never deletes documents or changes device storage.',
                        ),
                      ),
                    ],
                  ),
                ),
                if (_statusMessage != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    key: const Key('temporary-folder-status'),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: Text(_statusMessage!)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('folder-search-field'),
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search folders',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            key: const Key('clear-folder-search'),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Clear folder search',
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (visibleFolders.isEmpty)
                  const _FolderEmptyState()
                else
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final int columns = constraints.maxWidth >= 720 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleFolders.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.05,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final FolderSummary folder = visibleFolders[index];
                          return _FolderCard(
                            key: Key('folder-card-${folder.id}'),
                            folder: folder,
                            onMore: () => unawaited(_openFolderActions(folder)),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.lg),
                const _UnfiledCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.onMore,
    super.key,
  });

  final FolderSummary folder;
  final VoidCallback onMore;

  static const List<Color> _backgrounds = <Color>[
    AppColors.primarySoft,
    AppColors.infoSoft,
    AppColors.warningSoft,
    AppColors.purpleSoft,
  ];

  static const List<Color> _foregrounds = <Color>[
    AppColors.primaryDark,
    AppColors.info,
    AppColors.warning,
    AppColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final int index = folder.visualIndex % _backgrounds.length;
    return Material(
      color: _backgrounds[index],
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.folder_rounded, color: _foregrounds[index], size: 38),
                  const Spacer(),
                  IconButton(
                    key: Key('folder-more-${folder.id}'),
                    onPressed: onMore,
                    icon: const Icon(Icons.more_horiz_rounded),
                    color: AppColors.textSecondary,
                    tooltip: 'Folder actions',
                  ),
                ],
              ),
              const Spacer(),
              Text(
                folder.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text('${folder.documentCount} documents'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderEmptyState extends StatelessWidget {
  const _FolderEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('folder-search-empty-state'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.folder_off_outlined, size: 42, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text('No temporary folders match',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Clear the search or create a new preview folder.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _UnfiledCard extends StatelessWidget {
  const _UnfiledCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Unfiled documents',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '3 documents are not in a folder',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

enum _FolderAction { edit, delete }

class _FolderActionsSheet extends StatelessWidget {
  const _FolderActionsSheet({required this.folder});

  final FolderSummary folder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key('folder-actions-sheet'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(folder.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              key: const Key('folder-actions-prototype-notice'),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
              ),
              child: const Text(
                'These actions only update the current preview and never change documents or device storage.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              key: const Key('folder-action-edit'),
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename and recolour'),
              subtitle: const Text('Update the temporary folder card'),
              onTap: () => Navigator.of(context).pop(_FolderAction.edit),
            ),
            ListTile(
              key: const Key('folder-action-delete'),
              leading: const Icon(
                Icons.folder_delete_outlined,
                color: AppColors.destructive,
              ),
              title: const Text('Remove folder preview'),
              subtitle: const Text('Documents remain unchanged'),
              textColor: AppColors.destructive,
              onTap: () => Navigator.of(context).pop(_FolderAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

final class _FolderEditorResult {
  const _FolderEditorResult({required this.name, required this.visualIndex});

  final String name;
  final int visualIndex;
}

class _FolderEditorSheet extends StatefulWidget {
  const _FolderEditorSheet({
    this.initialName = '',
    this.initialVisualIndex = 0,
  });

  final String initialName;
  final int initialVisualIndex;

  @override
  State<_FolderEditorSheet> createState() => _FolderEditorSheetState();
}

class _FolderEditorSheetState extends State<_FolderEditorSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  late int _visualIndex = widget.initialVisualIndex % 4;
  String? _errorText;

  static const List<Color> _colours = <Color>[
    AppColors.primary,
    AppColors.info,
    AppColors.warning,
    AppColors.purple,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Enter a folder name.');
      return;
    }

    Navigator.of(context).pop(
      _FolderEditorResult(name: name, visualIndex: _visualIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.initialName.isNotEmpty;

    return Padding(
      key: const Key('folder-editor-sheet'),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              editing ? 'Edit folder preview' : 'New folder preview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              key: const Key('folder-editor-prototype-notice'),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
              ),
              child: const Text(
                'Folder name and colour are temporary and reset when this app session ends.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('folder-name-field'),
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Folder name',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.folder_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Folder colour', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List<Widget>.generate(
                _colours.length,
                (int index) => Semantics(
                  selected: _visualIndex == index,
                  label: 'Folder colour ${index + 1}',
                  child: InkWell(
                    key: Key('folder-color-$index'),
                    onTap: () => setState(() => _visualIndex = index),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadius.pill),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _colours[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _visualIndex == index
                              ? AppColors.navy
                              : AppColors.surface,
                          width: _visualIndex == index ? 4 : 2,
                        ),
                      ),
                      child: _visualIndex == index
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.surface,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('save-folder-prototype'),
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded),
                label: Text(editing ? 'Apply temporary changes' : 'Create preview folder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
