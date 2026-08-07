import 'package:clearscan/features/filters/presentation/filter_selection_screen.dart';

class ScannerSessionPage {
  const ScannerSessionPage({
    required this.id,
    required this.sourceLabel,
    required this.scanMode,
    this.cropAdjusted = false,
    this.filter = PrototypeFilter.original,
  });

  final String id;
  final String sourceLabel;
  final String scanMode;
  final bool cropAdjusted;
  final PrototypeFilter filter;

  ScannerSessionPage copyWith({
    String? sourceLabel,
    String? scanMode,
    bool? cropAdjusted,
    PrototypeFilter? filter,
  }) {
    return ScannerSessionPage(
      id: id,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      scanMode: scanMode ?? this.scanMode,
      cropAdjusted: cropAdjusted ?? this.cropAdjusted,
      filter: filter ?? this.filter,
    );
  }
}
