import 'package:clearscan/app/configuration/app_config.dart';
import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:clearscan/core/widgets/adaptive_content_frame.dart';
import 'package:flutter/material.dart';

enum LegalContentKind { about, privacyPolicy, terms }

class LegalContentScreen extends StatelessWidget {
  const LegalContentScreen.about({super.key}) : kind = LegalContentKind.about;

  const LegalContentScreen.privacyPolicy({super.key})
      : kind = LegalContentKind.privacyPolicy;

  const LegalContentScreen.terms({super.key}) : kind = LegalContentKind.terms;

  final LegalContentKind kind;

  @override
  Widget build(BuildContext context) {
    final _LegalPageContent content = _contentFor(kind);

    return Scaffold(
      key: Key(content.screenKey),
      appBar: AppBar(
        leading: IconButton(
          key: Key('close-${content.screenKey}'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Settings',
        ),
        title: Text(content.title),
      ),
      body: AdaptiveContentFrame(
        padding: EdgeInsets.zero,
        maxWidth: 820,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          Container(
            key: Key('${content.screenKey}-prototype-notice'),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.all(
                Radius.circular(AppRadius.medium),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(content.notice)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _HeaderCard(content: content),
          const SizedBox(height: AppSpacing.lg),
          for (int index = 0; index < content.sections.length; index++) ...<Widget>[
            _ContentSection(
              section: content.sections[index],
              sectionKey: '${content.screenKey}-section-$index',
            ),
            if (index != content.sections.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            key: Key('${content.screenKey}-external-placeholder'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${content.externalActionLabel} is a placeholder. No URL, email, licence page, or external document was opened.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(content.externalActionLabel),
          ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.content});

  final _LegalPageContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: content.headerBackground,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppRadius.extraLarge),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(content.icon, color: content.iconColor, size: 30),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(content.heading, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(content.summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content.meta,
            key: Key('${content.screenKey}-meta'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: content.iconColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.section,
    required this.sectionKey,
  });

  final _LegalSection section;
  final String sectionKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(sectionKey),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(section.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (final String paragraph in section.paragraphs) ...<Widget>[
            Text(paragraph, style: Theme.of(context).textTheme.bodyMedium),
            if (paragraph != section.paragraphs.last)
              const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

_LegalPageContent _contentFor(LegalContentKind kind) {
  switch (kind) {
    case LegalContentKind.about:
      return const _LegalPageContent(
        screenKey: 'about-clearscan-screen',
        title: 'About ClearScan',
        heading: AppConfig.appName,
        summary:
            'An original, privacy-first document scanner concept designed around local control, clear workflows and honest product states.',
        meta:
            'Version ${AppConfig.versionName} • ${AppConfig.releaseLabel}',
        notice:
            'About prototype — version, support, licence and release details are provisional and have not been prepared for a public store release.',
        icon: Icons.document_scanner_outlined,
        iconColor: AppColors.primaryDark,
        headerBackground: AppColors.primarySoft,
        externalActionLabel: 'View licences placeholder',
        sections: <_LegalSection>[
          _LegalSection(
            title: 'Product direction',
            paragraphs: <String>[
              'ClearScan aims to make scanning, editing, organising and exporting documents easy without copying another product’s interface or identity.',
              'The planned core workflow remains useful without an account, with optional cloud features introduced only after the offline experience is stable.',
            ],
          ),
          _LegalSection(
            title: 'Current build status',
            paragraphs: <String>[
              'This source contains interactive UI prototypes powered by mock and session-only state.',
              'Camera capture, persistence, OCR recognition, export, sharing, authentication and platform permissions are not connected yet.',
            ],
          ),
          _LegalSection(
            title: 'Principles',
            paragraphs: <String>[
              'Original design, local-first processing, explicit permission education, no silent uploads and honest disclosure of unfinished actions.',
            ],
          ),
        ],
      );
    case LegalContentKind.privacyPolicy:
      return const _LegalPageContent(
        screenKey: 'privacy-policy-screen',
        title: 'Privacy Policy',
        heading: 'Privacy policy preview',
        summary:
            'A readable draft structure showing the privacy commitments ClearScan intends to review before release.',
        meta: 'Draft preview • Updated August 7, 2026',
        notice:
            'Legal-content prototype — this is not a final or legally approved privacy policy and must not be published without professional review.',
        icon: Icons.privacy_tip_outlined,
        iconColor: AppColors.success,
        headerBackground: AppColors.successSoft,
        externalActionLabel: 'Privacy contact placeholder',
        sections: <_LegalSection>[
          _LegalSection(
            title: '1. Local document processing',
            paragraphs: <String>[
              'The planned core scanner should process captures, enhancements, OCR and PDF generation on the device whenever practical.',
              'The current prototype does not read, upload or store real documents.',
            ],
          ),
          _LegalSection(
            title: '2. Permissions',
            paragraphs: <String>[
              'Camera or file permissions should be requested only after clear education and only when the related feature is used.',
              'Denied or permanently denied permission states should remain understandable and recoverable.',
            ],
          ),
          _LegalSection(
            title: '3. Cloud and account data',
            paragraphs: <String>[
              'Cloud backup is planned as an optional later feature. Files must never be uploaded silently.',
              'Before any account service launches, data retention, encryption, deletion, export and support ownership must be documented.',
            ],
          ),
          _LegalSection(
            title: '4. Diagnostics and support',
            paragraphs: <String>[
              'Diagnostics and crash reporting are not connected in this prototype. Future collection must be disclosed and controlled appropriately.',
              'Feedback forms must explain what is submitted and must not attach private documents without explicit user action.',
            ],
          ),
          _LegalSection(
            title: '5. Your choices',
            paragraphs: <String>[
              'The intended product should provide understandable controls for local data, cleanup, optional backup, account deletion and data export.',
            ],
          ),
        ],
      );
    case LegalContentKind.terms:
      return const _LegalPageContent(
        screenKey: 'terms-screen',
        title: 'Terms of Use',
        heading: 'Terms of use preview',
        summary:
            'A draft content structure for responsible use, user documents, prototype limitations and future service terms.',
        meta: 'Draft preview • Updated August 7, 2026',
        notice:
            'Legal-content prototype — these terms are not legally approved, do not form a contract and must be reviewed before any public release.',
        icon: Icons.gavel_outlined,
        iconColor: AppColors.purple,
        headerBackground: AppColors.purpleSoft,
        externalActionLabel: 'Terms contact placeholder',
        sections: <_LegalSection>[
          _LegalSection(
            title: '1. Prototype status',
            paragraphs: <String>[
              'The current ClearScan build is a development UI prototype. Many controls simulate outcomes and must not be relied on for real document storage, export or deletion.',
            ],
          ),
          _LegalSection(
            title: '2. Responsible use',
            paragraphs: <String>[
              'Users should scan and process only documents they are authorised to handle and should comply with applicable privacy, copyright and record-keeping obligations.',
            ],
          ),
          _LegalSection(
            title: '3. Your content',
            paragraphs: <String>[
              'A future release should clearly state that users retain responsibility for their document content and for selecting safe sharing or backup destinations.',
            ],
          ),
          _LegalSection(
            title: '4. Accuracy and availability',
            paragraphs: <String>[
              'OCR, edge detection, enhancement and export may contain errors. Users should review important documents before relying on extracted text or generated files.',
              'Service availability, supported devices and feature limits must be described accurately at release.',
            ],
          ),
          _LegalSection(
            title: '5. Future paid or cloud services',
            paragraphs: <String>[
              'Any subscription, cloud storage, cancellation, refund, retention or account-deletion terms must be added only after those services are designed and legally reviewed.',
            ],
          ),
        ],
      );
  }
}

class _LegalPageContent {
  const _LegalPageContent({
    required this.screenKey,
    required this.title,
    required this.heading,
    required this.summary,
    required this.meta,
    required this.notice,
    required this.icon,
    required this.iconColor,
    required this.headerBackground,
    required this.externalActionLabel,
    required this.sections,
  });

  final String screenKey;
  final String title;
  final String heading;
  final String summary;
  final String meta;
  final String notice;
  final IconData icon;
  final Color iconColor;
  final Color headerBackground;
  final String externalActionLabel;
  final List<_LegalSection> sections;
}

class _LegalSection {
  const _LegalSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;
}
