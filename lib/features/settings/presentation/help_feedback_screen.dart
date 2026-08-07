import 'package:clearscan/app/theme/app_colors.dart';
import 'package:clearscan/app/theme/app_radius.dart';
import 'package:clearscan/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  static const List<String> _categories = <String>[
    'General question',
    'Scanning issue',
    'Export issue',
    'Privacy question',
    'Feature suggestion',
  ];

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedCategory = _categories.first;
  String? _statusMessage;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showPlaceholder(String action) {
    setState(() {
      _statusMessage =
          '$action is a prototype placeholder. No URL was opened and no message was sent.';
    });
  }

  void _previewFeedbackSubmission() {
    final String message = _messageController.text.trim();
    setState(() {
      _statusMessage = message.isEmpty
          ? 'Add a short message before preparing the feedback preview.'
          : 'Feedback preview prepared for “$_selectedCategory”. Nothing was sent or saved.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('help-feedback-screen'),
      appBar: AppBar(
        leading: IconButton(
          key: const Key('close-help-feedback'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Settings',
        ),
        title: const Text('Help and feedback'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          const _PrototypeNotice(
            key: Key('help-feedback-prototype-notice'),
            icon: Icons.support_agent_rounded,
            message:
                'Support prototype — FAQs are sample content. Feedback, email, help-centre and bug-report actions do not send data or open external links.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Common questions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _FaqCard(
            itemKey: 'help-faq-offline',
            question: 'Can ClearScan work without an account?',
            answer:
                'The planned core scanning flow is local-first and should remain useful without an account. Cloud backup is a later optional feature.',
          ),
          const SizedBox(height: AppSpacing.xs),
          const _FaqCard(
            itemKey: 'help-faq-camera',
            question: 'Why will camera permission be needed?',
            answer:
                'Camera access will be requested only when you start a real scan. This prototype does not request device permission.',
          ),
          const SizedBox(height: AppSpacing.xs),
          const _FaqCard(
            itemKey: 'help-faq-export',
            question: 'Where are exported files saved?',
            answer:
                'Export is not connected yet. A later implementation will show the destination clearly and will not publish private documents silently.',
          ),
          const SizedBox(height: AppSpacing.xs),
          const _FaqCard(
            itemKey: 'help-faq-delete',
            question: 'Does delete remove my real files?',
            answer:
                'Not in the current prototype. Library deletion and cleanup only change temporary preview state.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Contact placeholders',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SupportPanel(
            children: <Widget>[
              ListTile(
                key: const Key('help-email-support'),
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email support'),
                subtitle: const Text('External email action not connected'),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => _showPlaceholder('Email support'),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('help-open-help-centre'),
                leading: const Icon(Icons.public_rounded),
                title: const Text('Open help centre'),
                subtitle: const Text('No support website exists yet'),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => _showPlaceholder('Help centre'),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('help-report-bug'),
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('Report a bug'),
                subtitle: const Text('Submission channel not connected'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showPlaceholder('Bug report'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Prepare feedback',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Draft a message for review. The form stays only in this screen and is never submitted.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            key: const Key('help-feedback-category'),
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _categories
                .map(
                  (String category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(growable: false),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('help-feedback-email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Reply email (optional preview)',
              prefixIcon: Icon(Icons.alternate_email_rounded),
              helperText: 'Not saved or transmitted',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('help-feedback-message'),
            controller: _messageController,
            minLines: 4,
            maxLines: 7,
            maxLength: 800,
            decoration: const InputDecoration(
              labelText: 'What would you like help with?',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 82),
                child: Icon(Icons.edit_note_rounded),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            key: const Key('preview-feedback-submit'),
            onPressed: _previewFeedbackSubmission,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview feedback submission'),
          ),
          if (_statusMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Container(
              key: const Key('help-feedback-status'),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppRadius.medium),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.info_outline_rounded, color: AppColors.info),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(_statusMessage!)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.itemKey,
    required this.question,
    required this.answer,
  });

  final String itemKey;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: Key(itemKey),
        leading: const Icon(Icons.question_answer_outlined),
        title: Text(question),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _PrototypeNotice extends StatelessWidget {
  const _PrototypeNotice({
    required this.icon,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.warning),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
