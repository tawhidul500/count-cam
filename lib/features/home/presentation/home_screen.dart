import 'dart:async';

import 'package:clearscan/app/configuration/app_config.dart';
import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/core/widgets/document_list_tile.dart';
import 'package:clearscan/core/widgets/section_header.dart';
import 'package:clearscan/features/documents/data/mock_document_data.dart';
import 'package:clearscan/features/documents/presentation/document_viewer_screen.dart';
import 'package:clearscan/features/search/presentation/search_workspace_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onScan,
    required this.onDocuments,
    super.key,
  });

  final VoidCallback onScan;
  final VoidCallback onDocuments;


  void _openSearch(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const SearchWorkspaceScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey<String>('home-scroll'),
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
                const _HomeHeader(),
                const SizedBox(height: AppSpacing.lg),
                _SearchField(onTap: () => _openSearch(context)),
                const SizedBox(height: AppSpacing.lg),
                const _PrivacyBanner(),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Quick actions'),
                const SizedBox(height: AppSpacing.sm),
                _QuickActions(onScan: onScan),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: 'Recent documents',
                  actionLabel: 'See all',
                  onAction: onDocuments,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...MockDocumentData.recentDocuments.take(3).map(
                      (document) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: DocumentListTile(
                          key: Key('home-document-${document.id}'),
                          document: document,
                          onTap: () {
                            unawaited(
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      DocumentViewerScreen(document: document),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                const SizedBox(height: AppSpacing.md),
                const _StorageCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
          ),
          child: const Icon(
            Icons.document_scanner_outlined,
            color: AppColors.surface,
            semanticLabel: 'ClearScan logo',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Everything important, neatly scanned.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('home-open-search'),
      readOnly: true,
      onTap: onTap,
      decoration: const InputDecoration(
        hintText: 'Search documents and OCR text',
        prefixIcon: Icon(Icons.search_rounded),
        suffixIcon: Icon(Icons.tune_rounded),
      ),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.extraLarge)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Scan privately. Work faster.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.workspaceText,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Core scanning will be processed on your device.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.workspaceMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.navyElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 680 ? 4 : 2;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: columns == 4 ? 1.05 : 1.5,
          children: <Widget>[
            _QuickActionCard(
              icon: Icons.document_scanner_outlined,
              label: 'Scan document',
              helper: 'Use camera',
              background: AppColors.primarySoft,
              foreground: AppColors.primaryDark,
              onTap: onScan,
            ),
            const _QuickActionCard(
              icon: Icons.photo_library_outlined,
              label: 'Import images',
              helper: 'From gallery',
              background: AppColors.infoSoft,
              foreground: AppColors.info,
            ),
            const _QuickActionCard(
              icon: Icons.file_open_outlined,
              label: 'Import file',
              helper: 'PDF or image',
              background: AppColors.warningSoft,
              foreground: AppColors.warning,
            ),
            const _QuickActionCard(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Create PDF',
              helper: 'Combine pages',
              background: AppColors.purpleSoft,
              foreground: AppColors.purple,
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.helper,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String helper;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.medium),
                  ),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(helper, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard();

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
          const Icon(Icons.phone_android_rounded, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Device storage', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                const LinearProgressIndicator(
                  value: 0.18,
                  minHeight: 7,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                  backgroundColor: AppColors.surfaceMuted,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('36 MB used by ClearScan', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
