import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:flutter/material.dart';

enum _PdfPageScope { allPages, currentPage }

enum _PdfOrientation { portrait, landscape }

class PdfExportOptionsScreen extends StatefulWidget {
  const PdfExportOptionsScreen({
    required this.document,
    required this.currentPage,
    super.key,
  });

  final DocumentSummary document;
  final int currentPage;

  @override
  State<PdfExportOptionsScreen> createState() => _PdfExportOptionsScreenState();
}

class _PdfExportOptionsScreenState extends State<PdfExportOptionsScreen> {
  static const List<String> _pageSizes = <String>[
    'A4',
    'US Letter',
    'Legal',
    'Auto',
  ];

  late final TextEditingController _fileNameController;
  _PdfPageScope _pageScope = _PdfPageScope.allPages;
  _PdfOrientation _orientation = _PdfOrientation.portrait;
  String _pageSize = _pageSizes.first;
  double _margin = 12;
  double _quality = 82;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(
      text: _safePrototypeName(widget.document.title),
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  String _safePrototypeName(String input) {
    final String cleaned = input
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned.isEmpty ? 'ClearScan_Document' : cleaned;
  }

  int get _pageCount =>
      _pageScope == _PdfPageScope.allPages ? widget.document.pageCount : 1;

  String get _estimateLabel {
    final double orientationFactor =
        _orientation == _PdfOrientation.landscape ? 1.08 : 1;
    final double estimatedMb =
        _pageCount * (_quality / 100) * orientationFactor * 0.72;
    return '${estimatedMb.toStringAsFixed(1)} MB illustrative estimate';
  }

  void _showPrototypeResult() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'PDF generation is not connected yet. These settings are temporary.',
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
        key: const Key('pdf-export-options-screen'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('close-pdf-export-options'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to document',
          ),
          title: const Text('Export PDF'),
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
              const _PdfPrototypeNotice(),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                title: 'Pages',
                subtitle: 'Choose what this temporary export setup includes.',
                child: Column(
                  children: <Widget>[
                    RadioListTile<_PdfPageScope>(
                      key: const Key('pdf-pages-all'),
                      value: _PdfPageScope.allPages,
                      groupValue: _pageScope,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pageScope = value);
                        }
                      },
                      title: Text('All ${widget.document.pageCount} pages'),
                      subtitle: const Text('Use the complete mock document'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<_PdfPageScope>(
                      key: const Key('pdf-pages-current'),
                      value: _PdfPageScope.currentPage,
                      groupValue: _pageScope,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pageScope = value);
                        }
                      },
                      title: Text('Current page ${widget.currentPage}'),
                      subtitle: const Text('Export only the visible mock page'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SectionCard(
                title: 'Layout',
                subtitle: 'Page size and orientation are temporary selections.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      key: const Key('pdf-page-size'),
                      initialValue: _pageSize,
                      decoration: const InputDecoration(
                        labelText: 'Page size',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      dropdownColor: AppColors.navyElevated,
                      items: _pageSizes
                          .map(
                            (String size) => DropdownMenuItem<String>(
                              value: size,
                              child: Text(size),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _pageSize = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Orientation',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        ChoiceChip(
                          key: const Key('pdf-orientation-portrait'),
                          selected: _orientation == _PdfOrientation.portrait,
                          onSelected: (_) {
                            setState(
                              () => _orientation = _PdfOrientation.portrait,
                            );
                          },
                          avatar: const Icon(Icons.stay_current_portrait_rounded),
                          label: const Text('Portrait'),
                        ),
                        ChoiceChip(
                          key: const Key('pdf-orientation-landscape'),
                          selected: _orientation == _PdfOrientation.landscape,
                          onSelected: (_) {
                            setState(
                              () => _orientation = _PdfOrientation.landscape,
                            );
                          },
                          avatar: const Icon(Icons.stay_current_landscape_rounded),
                          label: const Text('Landscape'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SectionCard(
                title: 'Output',
                subtitle: 'Tune the mock margin and quality controls.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SliderLabel(
                      title: 'Margin',
                      value: '${_margin.round()} mm',
                    ),
                    Slider(
                      key: const Key('pdf-margin-slider'),
                      value: _margin,
                      min: 0,
                      max: 32,
                      divisions: 16,
                      label: '${_margin.round()} mm',
                      onChanged: (double value) {
                        setState(() => _margin = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SliderLabel(
                      title: 'Image quality',
                      value: '${_quality.round()}%',
                    ),
                    Slider(
                      key: const Key('pdf-quality-slider'),
                      value: _quality,
                      min: 40,
                      max: 100,
                      divisions: 12,
                      label: '${_quality.round()}%',
                      onChanged: (double value) {
                        setState(() => _quality = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      key: const Key('pdf-file-name'),
                      controller: _fileNameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'File name',
                        prefixIcon: Icon(Icons.drive_file_rename_outline_rounded),
                        suffixText: '.pdf',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                key: const Key('pdf-estimated-output'),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.navyElevated,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.large),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.data_usage_rounded, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Estimated output',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '$_estimateLabel • $_pageSize • $_pageCount page${_pageCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: AppColors.workspaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: const Key('prepare-pdf-prototype'),
                onPressed: _showPrototypeResult,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Prepare PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfPrototypeNotice extends StatelessWidget {
  const _PdfPrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('pdf-export-prototype-notice'),
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
              'PDF export prototype — no PDF file is generated, saved, or shared. All selections reset when you leave.',
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

class _SliderLabel extends StatelessWidget {
  const _SliderLabel({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
