import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/documents/domain/document_summary.dart';
import 'package:clearscan/features/documents/presentation/widgets/mock_document_page.dart';
import 'package:flutter/material.dart';

enum PrototypeFilter {
  original,
  auto,
  colour,
  grayscale,
  blackAndWhite,
  clarity,
  lowLight,
}

extension PrototypeFilterDetails on PrototypeFilter {
  String get label => switch (this) {
        PrototypeFilter.original => 'Original',
        PrototypeFilter.auto => 'Auto',
        PrototypeFilter.colour => 'Colour',
        PrototypeFilter.grayscale => 'Grayscale',
        PrototypeFilter.blackAndWhite => 'B&W',
        PrototypeFilter.clarity => 'Clarity',
        PrototypeFilter.lowLight => 'Low-light',
      };

  String get keyName => switch (this) {
        PrototypeFilter.original => 'original',
        PrototypeFilter.auto => 'auto',
        PrototypeFilter.colour => 'colour',
        PrototypeFilter.grayscale => 'grayscale',
        PrototypeFilter.blackAndWhite => 'black-and-white',
        PrototypeFilter.clarity => 'clarity',
        PrototypeFilter.lowLight => 'low-light',
      };

  IconData get icon => switch (this) {
        PrototypeFilter.original => Icons.image_outlined,
        PrototypeFilter.auto => Icons.auto_awesome_rounded,
        PrototypeFilter.colour => Icons.palette_outlined,
        PrototypeFilter.grayscale => Icons.tonality_rounded,
        PrototypeFilter.blackAndWhite => Icons.contrast_rounded,
        PrototypeFilter.clarity => Icons.document_scanner_outlined,
        PrototypeFilter.lowLight => Icons.brightness_5_outlined,
      };
}

final class FilterPrototypeResult {
  const FilterPrototypeResult({
    required this.filter,
    required this.intensity,
  });

  final PrototypeFilter filter;
  final double intensity;
}

class FilterSelectionScreen extends StatefulWidget {
  const FilterSelectionScreen({
    required this.document,
    required this.pageNumber,
    this.initialFilter = PrototypeFilter.original,
    this.initialIntensity = 0.7,
    super.key,
  });

  final DocumentSummary document;
  final int pageNumber;
  final PrototypeFilter initialFilter;
  final double initialIntensity;

  @override
  State<FilterSelectionScreen> createState() => _FilterSelectionScreenState();
}

class _FilterSelectionScreenState extends State<FilterSelectionScreen> {
  late PrototypeFilter _selectedFilter;
  late double _intensity;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _intensity = widget.initialIntensity.clamp(0, 1).toDouble();
  }

  void _applyPrototype() {
    Navigator.of(context).pop(
      FilterPrototypeResult(
        filter: _selectedFilter,
        intensity: _intensity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: Scaffold(
        key: const Key('filter-selection-screen'),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('close-filter-selection'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close filter selection',
          ),
          title: const Text('Choose filter'),
          actions: <Widget>[
            TextButton.icon(
              key: const Key('apply-filter-prototype'),
              onPressed: _applyPrototype,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Apply'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              const _FilterPrototypeNotice(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${_selectedFilter.label} preview',
                            key: const Key('selected-filter-heading'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Page ${widget.pageNumber} • Mock visual treatment only',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.workspaceMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.navyElevated,
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                      ),
                      child: Text(
                        '${(_intensity * 100).round()}%',
                        key: const Key('filter-intensity-value'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.navySurface,
                    borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
                  ),
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        _filterMatrix(_selectedFilter, _intensity),
                      ),
                      child: MockDocumentPage(
                        pageNumber: widget.pageNumber,
                        documentTitle: widget.document.title,
                        fileType: widget.document.fileType,
                        semanticLabel:
                            '${_selectedFilter.label} mock preview for page ${widget.pageNumber}',
                        compact: true,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Intensity',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Slider(
                        key: const Key('filter-intensity-slider'),
                        value: _intensity,
                        onChanged: (double value) => setState(() => _intensity = value),
                      ),
                    ),
                  ],
                ),
              ),
              _FilterOptionStrip(
                selectedFilter: _selectedFilter,
                onSelected: (PrototypeFilter filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPrototypeNotice extends StatelessWidget {
  const _FilterPrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('filter-prototype-notice'),
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
          Icon(Icons.auto_fix_high_outlined, color: AppColors.warning, size: 18),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Filter prototype — no real image processing or saved output exists yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptionStrip extends StatelessWidget {
  const _FilterOptionStrip({
    required this.selectedFilter,
    required this.onSelected,
  });

  final PrototypeFilter selectedFilter;
  final ValueChanged<PrototypeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: PrototypeFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final PrototypeFilter filter = PrototypeFilter.values[index];
          final bool selected = filter == selectedFilter;
          return Semantics(
            button: true,
            selected: selected,
            label: '${filter.label} filter',
            child: InkWell(
              key: Key('filter-option-${filter.keyName}'),
              onTap: () => onSelected(filter),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 82,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.navyElevated,
                  borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      filter.icon,
                      color: selected ? AppColors.navy : AppColors.workspaceText,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      filter.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

List<double> _filterMatrix(PrototypeFilter filter, double intensity) {
  const List<double> identity = <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  final List<double> target = switch (filter) {
    PrototypeFilter.original => identity,
    PrototypeFilter.auto => <double>[
        1.12, 0, 0, 0, 5,
        0, 1.12, 0, 0, 5,
        0, 0, 1.12, 0, 5,
        0, 0, 0, 1, 0,
      ],
    PrototypeFilter.colour => <double>[
        1.18, -0.05, -0.05, 0, 0,
        -0.05, 1.15, -0.05, 0, 0,
        -0.05, -0.05, 1.18, 0, 0,
        0, 0, 0, 1, 0,
      ],
    PrototypeFilter.grayscale => <double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ],
    PrototypeFilter.blackAndWhite => <double>[
        1.5, 1.5, 1.5, 0, -190,
        1.5, 1.5, 1.5, 0, -190,
        1.5, 1.5, 1.5, 0, -190,
        0, 0, 0, 1, 0,
      ],
    PrototypeFilter.clarity => <double>[
        1.35, 0, 0, 0, -28,
        0, 1.35, 0, 0, -28,
        0, 0, 1.35, 0, -28,
        0, 0, 0, 1, 0,
      ],
    PrototypeFilter.lowLight => <double>[
        1.05, 0, 0, 0, 32,
        0, 1.05, 0, 0, 32,
        0, 0, 1.05, 0, 32,
        0, 0, 0, 1, 0,
      ],
  };

  return List<double>.generate(
    identity.length,
    (int index) => identity[index] + (target[index] - identity[index]) * intensity,
    growable: false,
  );
}
