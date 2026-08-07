import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

enum _ShareFormat { pdf, images, text }

enum _SharePageScope { allPages, currentPage }

class ShareOptionsScreen extends StatefulWidget {
  const ShareOptionsScreen({
    required this.document,
    required this.currentPage,
    super.key,
  });

  final DocumentSummary document;
  final int currentPage;

  @override
  State<ShareOptionsScreen> createState() => _ShareOptionsScreenState();
}

class _ShareOptionsScreenState extends State<ShareOptionsScreen> {
  _ShareFormat _format = _ShareFormat.pdf;
  _SharePageScope _pageScope = _SharePageScope.allPages;
  bool _includeDocumentTitle = true;

  int get _selectedPageCount =>
      _pageScope == _SharePageScope.allPages ? widget.document.pageCount : 1;

  String get _formatLabel => switch (_format) {
        _ShareFormat.pdf => 'PDF document',
        _ShareFormat.images => 'JPG images',
        _ShareFormat.text => 'Extracted text',
      };

  String get _availabilityNote => switch (_format) {
        _ShareFormat.pdf => 'A real PDF must be generated before sharing.',
        _ShareFormat.images => 'Processed page images are not available yet.',
        _ShareFormat.text => 'Real OCR text has not been created yet.',
      };

  void _showPrototypeResult() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'System sharing is not connected. $_formatLabel remains a temporary selection.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: Scaffold(
        key: const Key('share-options-screen'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('close-share-options'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to document',
          ),
          title: const Text('Share options'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: <Widget>[
              const _SharePrototypeNotice(),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                title: 'Choose format',
                subtitle: 'Select the kind of output you would share later.',
                child: Column(
                  children: <Widget>[
                    _ShareFormatTile(
                      key: const Key('share-format-pdf'),
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF',
                      subtitle: 'One multi-page document',
                      selected: _format == _ShareFormat.pdf,
                      onTap: () => setState(() => _format = _ShareFormat.pdf),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _ShareFormatTile(
                      key: const Key('share-format-images'),
                      icon: Icons.photo_library_outlined,
                      title: 'Images',
                      subtitle: 'Separate JPG pages',
                      selected: _format == _ShareFormat.images,
                      onTap: () => setState(() => _format = _ShareFormat.images),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _ShareFormatTile(
                      key: const Key('share-format-text'),
                      icon: Icons.text_snippet_outlined,
                      title: 'Text',
                      subtitle: 'OCR text when recognition exists',
                      selected: _format == _ShareFormat.text,
                      onTap: () => setState(() => _format = _ShareFormat.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SectionCard(
                title: 'Pages',
                subtitle: 'This scope affects only the temporary summary.',
                child: Column(
                  children: <Widget>[
                    RadioListTile<_SharePageScope>(
                      key: const Key('share-pages-all'),
                      value: _SharePageScope.allPages,
                      groupValue: _pageScope,
                      contentPadding: EdgeInsets.zero,
                      title: Text('All ${widget.document.pageCount} pages'),
                      subtitle: const Text('Use the complete mock document'),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pageScope = value);
                        }
                      },
                    ),
                    RadioListTile<_SharePageScope>(
                      key: const Key('share-pages-current'),
                      value: _SharePageScope.currentPage,
                      groupValue: _pageScope,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Current page ${widget.currentPage}'),
                      subtitle: const Text('Use only the visible mock page'),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pageScope = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SectionCard(
                title: 'Details',
                subtitle: 'Control the temporary share description.',
                child: SwitchListTile(
                  key: const Key('share-include-title'),
                  value: _includeDocumentTitle,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include document title'),
                  subtitle: Text(widget.document.title),
                  onChanged: (bool value) {
                    setState(() => _includeDocumentTitle = value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                key: const Key('share-selection-summary'),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.navyElevated,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.large),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Row(
                      children: <Widget>[
                        Icon(Icons.ios_share_rounded, color: AppColors.info),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Temporary share summary',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$_formatLabel • $_selectedPageCount page${_selectedPageCount == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppColors.workspaceText),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _includeDocumentTitle
                          ? 'Title included: ${widget.document.title}'
                          : 'Document title excluded',
                      style: const TextStyle(color: AppColors.workspaceMuted),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _availabilityNote,
                      style: const TextStyle(color: AppColors.warning),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: const Key('open-system-share-prototype'),
                onPressed: _showPrototypeResult,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Open share sheet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharePrototypeNotice extends StatelessWidget {
  const _SharePrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('share-options-prototype-notice'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: AppColors.warning),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Share prototype — no exported file or platform share sheet is available. All selections reset when you leave.',
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.navyElevated),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _ShareFormatTile extends StatelessWidget {
  const _ShareFormatTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navyElevated : AppColors.navy,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadius.medium),
            ),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.navyElevated,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.navyElevated,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.medium),
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.navy : AppColors.workspaceText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.workspaceMuted),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : AppColors.workspaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
