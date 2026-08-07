import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/filters/presentation/filter_selection_screen.dart';
import 'package:clearscan/features/scanner/presentation/auto_capture_settings_sheet.dart';
import 'package:clearscan/features/scanner/presentation/capture_review_screen.dart';
import 'package:clearscan/features/scanner/presentation/capture_session_page_strip.dart';
import 'package:clearscan/features/scanner/presentation/scan_session_completion_screen.dart';
import 'package:clearscan/features/scanner/presentation/scanner_import_source_sheet.dart';
import 'package:clearscan/features/scanner/presentation/scanner_session_page.dart';
import 'package:flutter/material.dart';

enum _ScannerAccessState {
  permissionNeeded,
  ready,
  denied,
  permanentlyDenied,
  unavailable,
}

extension _ScannerAccessStateDetails on _ScannerAccessState {
  String get label => switch (this) {
        _ScannerAccessState.permissionNeeded => 'Permission needed',
        _ScannerAccessState.ready => 'Camera ready',
        _ScannerAccessState.denied => 'Permission denied',
        _ScannerAccessState.permanentlyDenied => 'Open settings guidance',
        _ScannerAccessState.unavailable => 'Camera unavailable',
      };

  IconData get icon => switch (this) {
        _ScannerAccessState.permissionNeeded => Icons.camera_alt_outlined,
        _ScannerAccessState.ready => Icons.camera_alt_rounded,
        _ScannerAccessState.denied => Icons.no_photography_outlined,
        _ScannerAccessState.permanentlyDenied => Icons.settings_outlined,
        _ScannerAccessState.unavailable => Icons.camera_indoor_outlined,
      };

  String get keyName => switch (this) {
        _ScannerAccessState.permissionNeeded => 'permission-needed',
        _ScannerAccessState.ready => 'ready',
        _ScannerAccessState.denied => 'denied',
        _ScannerAccessState.permanentlyDenied => 'permanently-denied',
        _ScannerAccessState.unavailable => 'unavailable',
      };
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  int _selectedMode = 1;
  bool _flashEnabled = false;
  _ScannerAccessState _accessState = _ScannerAccessState.permissionNeeded;
  AutoCapturePrototypeSettings _autoCaptureSettings =
      const AutoCapturePrototypeSettings();
  final List<ScannerSessionPage> _sessionPages = <ScannerSessionPage>[];
  int _selectedSessionPageIndex = 0;
  int _nextSessionPageId = 1;
  String? _sessionStatus;

  static const List<String> _modes = <String>[
    'ID card',
    'Document',
    'Book',
    'Whiteboard',
  ];

  String get _selectedModeLabel => _modes[_selectedMode];

  void _setAccessState(_ScannerAccessState state, {String? status}) {
    setState(() {
      _accessState = state;
      _sessionStatus = status;
      if (state != _ScannerAccessState.ready) {
        _flashEnabled = false;
      }
    });
  }

  Future<void> _showStatePreviewSheet() async {
    final _ScannerAccessState? selected =
        await showModalBottomSheet<_ScannerAccessState>(
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
            key: const Key('scanner-state-preview-sheet'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Preview scanner state',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.workspaceText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'These controls change local UI state only. No device permission or camera is accessed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.workspaceMuted,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._ScannerAccessState.values.map(
                (_ScannerAccessState state) => ListTile(
                  key: Key('scanner-state-${state.keyName}'),
                  leading: Icon(state.icon, color: AppColors.primary),
                  title: Text(
                    state.label,
                    style: const TextStyle(color: AppColors.workspaceText),
                  ),
                  trailing: state == _accessState
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(state),
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
    _setAccessState(
      selected,
      status: 'Previewed ${selected.label.toLowerCase()} state. No device setting changed.',
    );
  }

  Future<void> _openImportSource() async {
    final ScannerImportSource? source = await ScannerImportSourceSheet.show(context);
    if (!mounted || source == null) {
      return;
    }

    await _openCaptureReview('${source.label} preview');
  }

  Future<void> _openCaptureReview(
    String sourceLabel, {
    int? existingPageIndex,
  }) async {
    final bool reviewingExistingPage = existingPageIndex != null;
    final ScannerSessionPage? existingPage = reviewingExistingPage
        ? _sessionPages[existingPageIndex!]
        : null;
    final int pageNumber = reviewingExistingPage
        ? existingPageIndex! + 1
        : _sessionPages.length + 1;

    final CaptureReviewResult? result =
        await Navigator.of(context).push<CaptureReviewResult>(
      MaterialPageRoute<CaptureReviewResult>(
        builder: (BuildContext context) => CaptureReviewScreen(
          sourceLabel: existingPage?.sourceLabel ?? sourceLabel,
          scanMode: existingPage?.scanMode ?? _selectedModeLabel,
          pageNumber: pageNumber,
          reviewingExistingPage: reviewingExistingPage,
          initialCropAdjusted: existingPage?.cropAdjusted ?? false,
          initialFilter: existingPage?.filter ?? PrototypeFilter.original,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      if (!result.kept) {
        _sessionStatus = reviewingExistingPage
            ? 'Returned without updating page $pageNumber. No saved file changed.'
            : 'Returned to scanner. No image or file was created.';
        return;
      }

      if (reviewingExistingPage) {
        _sessionPages[existingPageIndex!] = existingPage!.copyWith(
          cropAdjusted: result.cropAdjusted,
          filter: result.filter,
        );
        _selectedSessionPageIndex = existingPageIndex!;
        _sessionStatus =
            'Mock page $pageNumber updated in this temporary session. Nothing was saved.';
        return;
      }

      _sessionPages.add(
        ScannerSessionPage(
          id: 'session-page-${_nextSessionPageId++}',
          sourceLabel: sourceLabel,
          scanMode: _selectedModeLabel,
          cropAdjusted: result.cropAdjusted,
          filter: result.filter,
        ),
      );
      _selectedSessionPageIndex = _sessionPages.length - 1;
      _sessionStatus =
          'Mock page $pageNumber kept in this scanner session. No image or file was saved.';
    });
  }

  Future<void> _showAutoCaptureSettings() async {
    final AutoCapturePrototypeSettings? settings =
        await AutoCaptureSettingsSheet.show(
      context,
      initialSettings: _autoCaptureSettings,
    );
    if (!mounted || settings == null) {
      return;
    }

    setState(() {
      _autoCaptureSettings = settings;
      _sessionStatus = settings.enabled
          ? 'Auto-capture preview is on. No frames are analysed and no capture is triggered.'
          : 'Auto-capture preview is off. No camera behaviour changed.';
    });
  }

  void _reviewSelectedPage() {
    if (_sessionPages.isEmpty) {
      return;
    }
    _openCaptureReview(
      _sessionPages[_selectedSessionPageIndex].sourceLabel,
      existingPageIndex: _selectedSessionPageIndex,
    );
  }

  Future<void> _addAnotherPage() async {
    if (_accessState == _ScannerAccessState.ready) {
      await _openCaptureReview('Camera preview');
      return;
    }
    await _openImportSource();
  }

  Future<void> _openSessionCompletion() async {
    if (_sessionPages.isEmpty) {
      return;
    }

    final ScanSessionCompletionResult? result =
        await Navigator.of(context).push<ScanSessionCompletionResult>(
      MaterialPageRoute<ScanSessionCompletionResult>(
        builder: (BuildContext context) => ScanSessionCompletionScreen(
          initialPages: List<ScannerSessionPage>.unmodifiable(_sessionPages),
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _sessionPages
        ..clear()
        ..addAll(result.pages);
      if (_sessionPages.isEmpty) {
        _selectedSessionPageIndex = 0;
      } else if (_selectedSessionPageIndex >= _sessionPages.length) {
        _selectedSessionPageIndex = _sessionPages.length - 1;
      }
      _sessionStatus = result.savePreviewed
          ? 'Save preview completed for "${result.documentTitle}" in ${result.folderName}. Nothing was saved or assigned.'
          : 'Returned from finish preview with ${result.pages.length} temporary ${result.pages.length == 1 ? 'page' : 'pages'}. Nothing was saved.';
    });
  }

  Future<void> _removeSelectedPage() async {
    if (_sessionPages.isEmpty) {
      return;
    }

    final int pageNumber = _selectedSessionPageIndex + 1;
    final bool? remove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('scanner-session-remove-dialog'),
        title: Text('Remove mock page $pageNumber?'),
        content: const Text(
          'This only removes a generated preview from the active scanner session. No device file or saved document is deleted.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('scanner-session-confirm-remove'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove page'),
          ),
        ],
      ),
    );

    if (!mounted || remove != true) {
      return;
    }

    setState(() {
      _sessionPages.removeAt(_selectedSessionPageIndex);
      if (_sessionPages.isEmpty) {
        _selectedSessionPageIndex = 0;
      } else if (_selectedSessionPageIndex >= _sessionPages.length) {
        _selectedSessionPageIndex = _sessionPages.length - 1;
      }
      _sessionStatus =
          'Mock page $pageNumber removed from this temporary session. No device file was deleted.';
    });
  }


  Future<bool> _confirmScannerExit() async {
    if (_sessionPages.isEmpty) {
      return true;
    }

    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        key: const Key('scanner-unsaved-exit-dialog'),
        title: const Text('Leave this scan session?'),
        content: Text(
          '${_sessionPages.length} temporary ${_sessionPages.length == 1 ? 'page' : 'pages'} will be discarded. No device file or saved document exists yet.',
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('scanner-stay-in-session'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            key: const Key('scanner-discard-session'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
            ),
            child: const Text('Discard session'),
          ),
        ],
      ),
    );

    return discard == true;
  }

  Future<void> _closeScanner() async {
    final bool canClose = await _confirmScannerExit();
    if (canClose && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.workspaceDark,
      child: WillPopScope(
        onWillPop: _confirmScannerExit,
        child: Scaffold(
          key: const Key('scanner-screen'),
          appBar: AppBar(
            leading: IconButton(
              key: const Key('close-scanner'),
              onPressed: _closeScanner,
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close scanner',
            ),
            title: const Text('Scan'),
            actions: <Widget>[
              IconButton(
                onPressed: _accessState == _ScannerAccessState.ready
                    ? () => setState(() => _flashEnabled = !_flashEnabled)
                    : null,
                icon: Icon(
                  _flashEnabled
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                ),
                tooltip: 'Toggle flash preview',
              ),
              IconButton(
                key: const Key('scanner-open-state-preview'),
                onPressed: _showStatePreviewSheet,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Preview scanner states',
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  children: <Widget>[
                    const _PrototypeNotice(),
                    if (_sessionStatus != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      _SessionStatus(message: _sessionStatus!),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _buildAccessBody(),
                      ),
                    ),
                    if (_sessionPages.isNotEmpty)
                      CaptureSessionPageStrip(
                        pages: List<ScannerSessionPage>.unmodifiable(
                          _sessionPages,
                        ),
                        selectedIndex: _selectedSessionPageIndex,
                        onSelected: (int index) => setState(
                          () => _selectedSessionPageIndex = index,
                        ),
                        onReview: _reviewSelectedPage,
                        onAdd: _addAnotherPage,
                        onRemove: _removeSelectedPage,
                        onFinish: _openSessionCompletion,
                      ),
                    const SizedBox(height: AppSpacing.md),
                    _ModeSelector(
                      modes: _modes,
                      selectedIndex: _selectedMode,
                      onSelected: (int index) =>
                          setState(() => _selectedMode = index),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_accessState == _ScannerAccessState.ready)
                      _CaptureControls(
                        onImport: _openImportSource,
                        onCapture: () =>
                            _openCaptureReview('Camera preview'),
                        onAutoCapture: _showAutoCaptureSettings,
                      )
                    else
                      _FallbackControls(onImport: _openImportSource),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessBody() {
    return switch (_accessState) {
      _ScannerAccessState.permissionNeeded => _PermissionNeededState(
          key: const ValueKey<String>('permission-needed'),
          onPreviewAccess: () => _setAccessState(
            _ScannerAccessState.ready,
            status: 'Camera-ready UI preview opened. No device permission was requested.',
          ),
          onPreviewDenied: () => _setAccessState(_ScannerAccessState.denied),
          onImport: _openImportSource,
        ),
      _ScannerAccessState.ready => _CameraWorkspace(
          key: const ValueKey<String>('camera-ready'),
          autoCaptureSettings: _autoCaptureSettings,
        ),
      _ScannerAccessState.denied => _PermissionDeniedState(
          key: const ValueKey<String>('permission-denied'),
          onTryAgain: () => _setAccessState(
            _ScannerAccessState.ready,
            status: 'Retry preview only. No device permission was requested.',
          ),
          onPreviewPermanent: () =>
              _setAccessState(_ScannerAccessState.permanentlyDenied),
          onImport: _openImportSource,
        ),
      _ScannerAccessState.permanentlyDenied => _PermanentDeniedState(
          key: const ValueKey<String>('permission-permanent'),
          onSettingsGuidance: () => setState(
            () => _sessionStatus =
                'App-settings guidance previewed. Device settings were not opened.',
          ),
          onImport: _openImportSource,
        ),
      _ScannerAccessState.unavailable => _CameraUnavailableState(
          key: const ValueKey<String>('camera-unavailable'),
          onImport: _openImportSource,
        ),
    };
  }
}

class _PrototypeNotice extends StatelessWidget {
  const _PrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('scanner-prototype-notice'),
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
              'Scanner prototype — no camera, permission, gallery, or device file is accessed',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.workspaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionStatus extends StatelessWidget {
  const _SessionStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: Container(
        key: const Key('scanner-session-status'),
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

class _PermissionNeededState extends StatelessWidget {
  const _PermissionNeededState({
    required this.onPreviewAccess,
    required this.onPreviewDenied,
    required this.onImport,
    super.key,
  });

  final VoidCallback onPreviewAccess;
  final VoidCallback onPreviewDenied;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      key: const Key('scanner-permission-needed'),
      icon: Icons.camera_alt_outlined,
      title: 'Camera access is needed to scan',
      description:
          'A real app would explain the permission first, then let the operating system ask. This prototype changes UI state only.',
      primaryLabel: 'Preview camera access',
      primaryKey: const Key('scanner-preview-camera-access'),
      onPrimary: onPreviewAccess,
      secondaryActions: <Widget>[
        TextButton(
          key: const Key('scanner-preview-permission-denied'),
          onPressed: onPreviewDenied,
          child: const Text('Preview denied state'),
        ),
        TextButton(
          key: const Key('scanner-import-from-permission'),
          onPressed: onImport,
          child: const Text('Import instead'),
        ),
      ],
    );
  }
}

class _PermissionDeniedState extends StatelessWidget {
  const _PermissionDeniedState({
    required this.onTryAgain,
    required this.onPreviewPermanent,
    required this.onImport,
    super.key,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onPreviewPermanent;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      key: const Key('scanner-permission-denied'),
      icon: Icons.no_photography_outlined,
      title: 'Camera access was denied',
      description:
          'The scanner should stay usable through a clear retry path and a safe import fallback. No denial has actually occurred here.',
      primaryLabel: 'Preview retry',
      primaryKey: const Key('scanner-preview-permission-retry'),
      onPrimary: onTryAgain,
      secondaryActions: <Widget>[
        TextButton(
          key: const Key('scanner-preview-permanently-denied'),
          onPressed: onPreviewPermanent,
          child: const Text('Preview “don’t ask again”'),
        ),
        TextButton(
          key: const Key('scanner-import-from-denied'),
          onPressed: onImport,
          child: const Text('Import instead'),
        ),
      ],
    );
  }
}

class _PermanentDeniedState extends StatelessWidget {
  const _PermanentDeniedState({
    required this.onSettingsGuidance,
    required this.onImport,
    super.key,
  });

  final VoidCallback onSettingsGuidance;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      key: const Key('scanner-permission-permanently-denied'),
      icon: Icons.settings_outlined,
      title: 'Camera access must be changed in Settings',
      description:
          'A real app would guide the user to system settings and re-check access after returning. This prototype never opens device settings.',
      primaryLabel: 'Preview Settings guidance',
      primaryKey: const Key('scanner-preview-settings-guidance'),
      onPrimary: onSettingsGuidance,
      secondaryActions: <Widget>[
        TextButton(
          key: const Key('scanner-import-from-permanent'),
          onPressed: onImport,
          child: const Text('Use import instead'),
        ),
      ],
    );
  }
}

class _CameraUnavailableState extends StatelessWidget {
  const _CameraUnavailableState({required this.onImport, super.key});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      key: const Key('scanner-camera-unavailable'),
      icon: Icons.camera_indoor_outlined,
      title: 'Camera is unavailable',
      description:
          'A real device may have no camera, another app may be using it, or the camera may fail to initialise. Import remains available.',
      primaryLabel: 'Choose import source',
      primaryKey: const Key('scanner-import-from-unavailable'),
      onPrimary: onImport,
      secondaryActions: const <Widget>[],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.primaryKey,
    required this.onPrimary,
    required this.secondaryActions,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String primaryLabel;
  final Key primaryKey;
  final VoidCallback onPrimary;
  final List<Widget> secondaryActions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.navySurface,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.workspaceText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.workspaceMuted,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: primaryKey,
                onPressed: onPrimary,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(primaryLabel),
              ),
              if (secondaryActions.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: secondaryActions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraWorkspace extends StatelessWidget {
  const _CameraWorkspace({
    required this.autoCaptureSettings,
    super.key,
  });

  final AutoCapturePrototypeSettings autoCaptureSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('scanner-camera-ready'),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.navyElevated,
                  AppColors.navy,
                ],
              ),
            ),
          ),
          Center(
            child: AspectRatio(
              aspectRatio: 0.72,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.documentPaper,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.small)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const _PaperContent(),
                    ),
                    const Positioned(top: -1, left: -1, child: _CornerHandle()),
                    const Positioned(top: -1, right: -1, child: _CornerHandle()),
                    const Positioned(bottom: -1, left: -1, child: _CornerHandle()),
                    const Positioned(bottom: -1, right: -1, child: _CornerHandle()),
                  ],
                ),
              ),
            ),
          ),
          if (autoCaptureSettings.enabled)
            const Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: _AutoCaptureWorkspaceStatus(),
            ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: _ScanHint(settings: autoCaptureSettings),
          ),
        ],
      ),
    );
  }
}

class _PaperContent extends StatelessWidget {
  const _PaperContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.sm),
          Container(height: 12, color: AppColors.textPrimary),
          const SizedBox(height: AppSpacing.md),
          ...List<Widget>.generate(
            8,
            (int index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: index.isEven ? 1 : 0.78,
                child: Container(height: 5, color: AppColors.border),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(child: Container(height: 42, color: AppColors.surfaceMuted)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Container(height: 42, color: AppColors.surfaceMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CornerHandle extends StatelessWidget {
  const _CornerHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.workspaceText, width: 3),
        ),
      ),
    );
  }
}

class _AutoCaptureWorkspaceStatus extends StatelessWidget {
  const _AutoCaptureWorkspaceStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('scanner-auto-capture-workspace-status'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primaryDark),
          SizedBox(width: AppSpacing.xxs),
          Text(
            'Auto preview on',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHint extends StatelessWidget {
  const _ScanHint({required this.settings});

  final AutoCapturePrototypeSettings settings;

  @override
  Widget build(BuildContext context) {
    final String hint = settings.enabled
        ? 'Auto preview only — no frames analysed or capture triggered'
        : 'Mock camera-ready state — keep corners inside the frame';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.workspaceOverlay,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
        child: Text(hint, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.modes,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> modes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = index == selectedIndex;
          return ChoiceChip(
            key: Key('scanner-mode-${modes[index].toLowerCase().replaceAll(' ', '-')}'),
            label: Text(modes[index]),
            selected: selected,
            onSelected: (_) => onSelected(index),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.navySurface,
            side: const BorderSide(color: AppColors.navyElevated),
            labelStyle: TextStyle(
              color: selected ? AppColors.navy : AppColors.workspaceMuted,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }
}

class _CaptureControls extends StatelessWidget {
  const _CaptureControls({
    required this.onImport,
    required this.onCapture,
    required this.onAutoCapture,
  });

  final VoidCallback onImport;
  final VoidCallback onCapture;
  final VoidCallback onAutoCapture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton.filledTonal(
            key: const Key('scanner-open-import-source'),
            onPressed: onImport,
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Choose import source',
          ),
          Semantics(
            button: true,
            label: 'Preview capture review',
            child: Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.workspaceText, width: 3),
                ),
              ),
              child: Material(
                color: AppColors.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  key: const Key('scanner-capture-button'),
                  onTap: onCapture,
                  customBorder: const CircleBorder(),
                ),
              ),
            ),
          ),
          IconButton.filledTonal(
            key: const Key('scanner-auto-capture-preview'),
            onPressed: onAutoCapture,
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Preview auto capture settings',
          ),
        ],
      ),
    );
  }
}

class _FallbackControls extends StatelessWidget {
  const _FallbackControls({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: OutlinedButton.icon(
        key: const Key('scanner-import-fallback'),
        onPressed: onImport,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Choose import source'),
      ),
    );
  }
}
