import 'package:clearscan/app/configuration/app_config.dart';
import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class OnboardingPreviewScreen extends StatefulWidget {
  const OnboardingPreviewScreen({super.key});

  @override
  State<OnboardingPreviewScreen> createState() =>
      _OnboardingPreviewScreenState();
}

class _OnboardingPreviewScreenState extends State<OnboardingPreviewScreen> {
  static const int _pageCount = 4;

  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _permissionPreviewed = false;

  bool get _isLastPage => _pageIndex == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    await _pageController.animateToPage(
      page.clamp(0, _pageCount - 1).toInt(),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _continueWithoutAccount() {
    Navigator.of(context).pop(true);
  }

  void _previewCameraPermission() {
    setState(() => _permissionPreviewed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 1200),
        content: Text(
          'Prototype only — ClearScan did not request camera permission.',
        ),
      ),
    );
  }

  void _showSignInPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 1200),
        content: Text(
          'Sign-in is not connected yet. You can continue without an account.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('onboarding-preview-screen'),
      appBar: AppBar(
        leading: IconButton(
          key: const Key('close-onboarding-preview'),
          tooltip: 'Close onboarding preview',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Onboarding preview'),
        actions: <Widget>[
          if (!_isLastPage)
            TextButton(
              key: const Key('onboarding-skip-to-permission'),
              onPressed: () => _goToPage(_pageCount - 1),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                0,
              ),
              child: _PrototypeNotice(),
            ),
            Expanded(
              child: PageView(
                key: const Key('onboarding-page-view'),
                controller: _pageController,
                onPageChanged: (int value) {
                  setState(() => _pageIndex = value);
                },
                children: <Widget>[
                  const _WelcomePage(),
                  const _FeaturesPage(),
                  const _PrivacyPage(),
                  _CameraPermissionPage(
                    permissionPreviewed: _permissionPreviewed,
                    onPreviewPermission: _previewCameraPermission,
                  ),
                ],
              ),
            ),
            _BottomControls(
              pageIndex: _pageIndex,
              pageCount: _pageCount,
              isLastPage: _isLastPage,
              onBack: () => _goToPage(_pageIndex - 1),
              onNext: () => _goToPage(_pageIndex + 1),
              onContinue: _continueWithoutAccount,
              onSignIn: _showSignInPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrototypeNotice extends StatelessWidget {
  const _PrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('onboarding-prototype-notice'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.visibility_outlined, color: AppColors.info),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Preview only — progress is not saved, sign-in is unavailable, '
              'and no device permission is requested.',
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageFrame(
      key: const Key('onboarding-welcome-page'),
      child: Column(
        children: <Widget>[
          const _WelcomeIllustration(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Welcome to ${AppConfig.appName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppConfig.tagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryDark,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Turn paper into clear, organised documents with a workflow '
            'designed to stay simple from capture to export.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Document moving through a clear scanning frame',
      image: true,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320, minHeight: 230),
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 154,
                height: 194,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppRadius.medium)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _PaperLine(width: 86, strong: true),
                    SizedBox(height: AppSpacing.sm),
                    _PaperLine(width: 118),
                    SizedBox(height: AppSpacing.xs),
                    _PaperLine(width: 102),
                    SizedBox(height: AppSpacing.xs),
                    _PaperLine(width: 126),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        _PaperLine(width: 66, strong: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 206,
              height: 222,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.large)),
              ),
            ),
            const Positioned(
              right: 34,
              bottom: 28,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.workspaceText,
                child: Icon(Icons.document_scanner_outlined, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperLine extends StatelessWidget {
  const _PaperLine({required this.width, this.strong = false});

  final double width;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: strong ? 8 : 6,
      decoration: BoxDecoration(
        color: strong ? AppColors.primaryMuted : AppColors.surfaceMuted,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageFrame(
      key: const Key('onboarding-features-page'),
      child: Column(
        children: <Widget>[
          const _PageIcon(
            icon: Icons.auto_awesome_mosaic_outlined,
            backgroundColor: AppColors.purpleSoft,
            foregroundColor: AppColors.purple,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Scan, refine, and organise',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A focused path for creating documents without overwhelming tools.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _ValueCard(
            icon: Icons.document_scanner_outlined,
            title: 'Capture clearly',
            description:
                'Frame pages, review boundaries, and keep manual control available.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _ValueCard(
            icon: Icons.tune_rounded,
            title: 'Refine non-destructively',
            description:
                'Crop and filter while preserving the original capture workflow.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _ValueCard(
            icon: Icons.folder_copy_outlined,
            title: 'Stay organised',
            description:
                'Group documents, search quickly, and prepare them for sharing.',
          ),
        ],
      ),
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageFrame(
      key: const Key('onboarding-privacy-page'),
      child: Column(
        children: <Widget>[
          const _PageIcon(
            icon: Icons.verified_user_outlined,
            backgroundColor: AppColors.successSoft,
            foregroundColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Private by default',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Core scanning is planned to remain useful without requiring an account.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _PrivacyPoint(
            icon: Icons.phone_android_rounded,
            title: 'Local-first workflow',
            description:
                'Documents stay on your device unless you deliberately enable a future backup feature.',
          ),
          const _PrivacyPoint(
            icon: Icons.cloud_off_outlined,
            title: 'No silent uploads',
            description:
                'ClearScan will explain when a future action needs network access.',
          ),
          const _PrivacyPoint(
            icon: Icons.person_off_outlined,
            title: 'Account optional',
            description:
                'You can continue into the current prototype without signing in.',
          ),
        ],
      ),
    );
  }
}

class _CameraPermissionPage extends StatelessWidget {
  const _CameraPermissionPage({
    required this.permissionPreviewed,
    required this.onPreviewPermission,
  });

  final bool permissionPreviewed;
  final VoidCallback onPreviewPermission;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageFrame(
      key: const Key('onboarding-permission-page'),
      child: Column(
        children: <Widget>[
          const _PageIcon(
            icon: Icons.camera_alt_outlined,
            backgroundColor: AppColors.warningSoft,
            foregroundColor: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Camera access, explained first',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ClearScan needs camera access only when you choose to scan a physical page.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.large)),
              border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: const Column(
              children: <Widget>[
                _PermissionRow(
                  icon: Icons.center_focus_strong_outlined,
                  title: 'Used for document capture',
                  description:
                      'The camera preview helps frame a page before you press capture.',
                ),
                Divider(height: AppSpacing.xl),
                _PermissionRow(
                  icon: Icons.block_outlined,
                  title: 'Not requested on app launch',
                  description:
                      'Permission should be requested only after clear education and a scan action.',
                ),
                Divider(height: AppSpacing.xl),
                _PermissionRow(
                  icon: Icons.settings_outlined,
                  title: 'You stay in control',
                  description:
                      'A denied permission must have a clear explanation and settings path later.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            key: const Key('onboarding-permission-preview'),
            onPressed: onPreviewPermission,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview camera permission'),
          ),
          if (permissionPreviewed) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Container(
              key: const Key('onboarding-permission-preview-status'),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                borderRadius:
                    BorderRadius.all(Radius.circular(AppRadius.medium)),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.check_circle_outline, color: AppColors.success),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Education preview complete. No real permission was requested.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardingPageFrame extends StatelessWidget {
  const _OnboardingPageFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: child,
        ),
      ),
    );
  }
}

class _PageIcon extends StatelessWidget {
  const _PageIcon({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: foregroundColor, size: 44),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.medium)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: AppSpacing.xxs),
          Icon(icon, color: AppColors.success, size: 30),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.pageIndex,
    required this.pageCount,
    required this.isLastPage,
    required this.onBack,
    required this.onNext,
    required this.onContinue,
    required this.onSignIn,
  });

  final int pageIndex;
  final int pageCount;
  final bool isLastPage;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onContinue;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    pageCount,
                    (int index) => AnimatedContainer(
                      key: Key('onboarding-page-indicator-$index'),
                      duration: const Duration(milliseconds: 180),
                      width: index == pageIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: index == pageIndex
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (isLastPage) ...<Widget>[
                  FilledButton(
                    key: const Key('onboarding-continue-without-account'),
                    onPressed: onContinue,
                    child: const Text('Continue without account'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    key: const Key('onboarding-sign-in-placeholder'),
                    onPressed: onSignIn,
                    child: const Text('Sign in instead'),
                  ),
                ] else
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final bool stackActions = constraints.maxWidth < 390 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.5;
                      final Widget back = OutlinedButton(
                        key: const Key('onboarding-back'),
                        onPressed: pageIndex == 0 ? null : onBack,
                        child: const Text('Back'),
                      );
                      final Widget next = FilledButton(
                        key: const Key('onboarding-next'),
                        onPressed: onNext,
                        child: const Text('Next'),
                      );

                      if (stackActions) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            next,
                            const SizedBox(height: AppSpacing.xs),
                            back,
                          ],
                        );
                      }

                      return Row(
                        children: <Widget>[
                          Expanded(child: back),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(flex: 2, child: next),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
