from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = (
    '.github/workflows/flutter-ci.yml',
    '.github/dependabot.yml',
    '.flutter-version',
    'README.md',
    'pubspec.yaml',
    'analysis_options.yaml',
    'tool/project.env',
    'scripts/environment_doctor.sh',
    'scripts/install_flutter_sdk.sh',
    'scripts/install_flutter_sdk.py',
    'scripts/bootstrap_platforms.sh',
    'scripts/check.sh',
    'scripts/check_offline.sh',
    'scripts/capture_phase0_evidence.sh',
    'scripts/complete_phase0_host.sh',
    'scripts/probe_p00_t03.py',
    'scripts/write_artifact_manifest.py',
    'scripts/artifact_manifest_test.py',
    'scripts/verify_phase0_evidence.py',
    'scripts/phase0_evidence_test.py',
    'scripts/write_phase0_gate_summary.py',
    'scripts/phase0_gate_summary_test.py',
    'scripts/write_phase0_launch_report.py',
    'scripts/verify_phase0_launch_evidence.py',
    'scripts/phase0_launch_evidence_test.py',
    'scripts/capture_android_launch_evidence.sh',
    'scripts/capture_ios_launch_evidence.sh',
    'scripts/verify_phase0_downloaded_run.py',
    'scripts/phase0_downloaded_run_test.py',
    'scripts/record_phase0_hosted_run.py',
    'scripts/run_phase0_github_gate.sh',
    'scripts/phase0_github_gate_contract_test.py',
    'scripts/bootstrap_phase0_github_repo.sh',
    'scripts/phase0_github_bootstrap_contract_test.py',
    'scripts/source_contract_test.py',
    'scripts/verify_platforms.py',
    'scripts/verify_ci_pins.py',
    'lib/main.dart',
    'lib/app/app.dart',
    'lib/app/configuration/app_config.dart',
    'lib/app/theme/app_colors.dart',
    'lib/app/theme/app_spacing.dart',
    'lib/app/theme/app_radius.dart',
    'lib/app/theme/app_theme.dart',
    'lib/features/shell/presentation/app_shell.dart',
    'lib/features/home/presentation/home_screen.dart',
    'lib/features/documents/domain/document_summary.dart',
    'lib/features/documents/data/mock_document_data.dart',
    'lib/features/documents/presentation/documents_screen.dart',
    'lib/features/documents/presentation/document_viewer_screen.dart',
    'lib/features/documents/presentation/multi_page_editor_screen.dart',
    'lib/features/documents/presentation/widgets/mock_document_page.dart',
    'lib/features/documents/presentation/widgets/document_grid_card.dart',
    'lib/features/documents/presentation/recently_deleted_screen.dart',
    'lib/features/crop_editor/presentation/crop_adjustment_screen.dart',
    'lib/features/filters/presentation/filter_selection_screen.dart',
    'lib/features/export/presentation/pdf_export_options_screen.dart',
    'lib/features/ocr/presentation/ocr_text_workspace_screen.dart',
    'lib/features/share/presentation/share_options_screen.dart',
    'lib/features/search/presentation/search_workspace_screen.dart',
    'lib/features/documents/presentation/document_actions_sheet.dart',
    'lib/features/folders/presentation/folders_screen.dart',
    'lib/features/settings/presentation/settings_screen.dart',
    'lib/features/settings/presentation/settings_detail_sheets.dart',
    'lib/features/settings/presentation/help_feedback_screen.dart',
    'lib/features/settings/presentation/legal_content_screen.dart',
    'lib/features/onboarding/presentation/onboarding_preview_screen.dart',
    'lib/features/scanner/presentation/scanner_screen.dart',
    'lib/features/scanner/presentation/scanner_import_source_sheet.dart',
    'lib/features/scanner/presentation/capture_review_screen.dart',
    'lib/features/scanner/presentation/auto_capture_settings_sheet.dart',
    'lib/features/scanner/presentation/scanner_session_page.dart',
    'lib/features/scanner/presentation/capture_session_page_strip.dart',
    'lib/features/scanner/presentation/scan_session_completion_screen.dart',
    'lib/core/widgets/adaptive_content_frame.dart',
    'lib/core/widgets/document_list_tile.dart',
    'lib/core/widgets/prototype_state_panel.dart',
    'lib/core/widgets/section_header.dart',
    'lib/core/widgets/status_announcement.dart',
    'test/app_startup_test.dart',
    'docs/PROJECT_MASTER.md',
    'docs/ROADMAP.md',
    'docs/TASKS.md',
    'docs/DESIGN_SYSTEM.md',
    'docs/ARCHITECTURE.md',
    'docs/DATABASE.md',
    'docs/API_CONTRACTS.md',
    'docs/DECISIONS.md',
    'docs/CHANGELOG.md',
    'docs/KNOWN_ISSUES.md',
    'docs/QA_CHECKLIST.md',
    'docs/HANDOFF.md',
    'docs/UI_AUDIT.md',
    'docs/ENVIRONMENT_SETUP.md',
    'docs/PHASE0_EVIDENCE.md',
    'docs/P00_T03_PROBE_2026-08-07.md',
    'docs/SIGNING_AND_CI_BASELINE.md',
    'docs/CONNECTED_HOST_RUNBOOK.md',
    'tool/fixtures/flutter_releases_linux.json',
)

VALID_TASK_STATUSES = {
    'BACKLOG',
    'READY',
    'IN_PROGRESS',
    'BLOCKED',
    'REVIEW',
    'DONE',
}

REQUIRED_HANDOFF_LABELS = (
    'Current phase:',
    'Current task ID:',
    'Current task status:',
    'Last completed task:',
    'Exact next task:',
    '## Work completed in the latest session',
    '## Files created',
    '## Files modified',
    '## Important decisions',
    '## Known problems',
    '## Tests completed',
    '## Tests still required',
    '## Continuation instructions',
)

REQUIRED_PROJECT_ENV = {
    'CLEARSCAN_PROJECT_NAME': 'clearscan',
    'CLEARSCAN_ORGANIZATION': 'com.clearscan',
    'CLEARSCAN_PLATFORMS': 'android,ios',
    'CLEARSCAN_ANDROID_APPLICATION_ID': 'com.clearscan.clearscan',
    'CLEARSCAN_IOS_BUNDLE_ID': 'com.clearscan.clearscan',
    'CLEARSCAN_FLUTTER_CHANNEL': 'stable',
    'CLEARSCAN_FLUTTER_VERSION': '3.44.8',
    'CLEARSCAN_DART_VERSION': '3.12.2',
    'CLEARSCAN_FLUTTER_RELEASE_HASH': '058e0af2c2b57e369d905a03ac9748b0ebf543c6',
    'CLEARSCAN_FLUTTER_ARCHIVE_SHA256_LINUX_X64': '672089e001571a9fbb209a495c583580c0c6c73ef98999264ba07fa93ace332d',
}


def parse_task_rows(task_text: str) -> dict[str, str]:
    tasks: dict[str, str] = {}
    for line in task_text.splitlines():
        if not re.match(r'^\|\s*P\d{2}-T\d{2}\s*\|', line):
            continue

        columns = [column.strip() for column in line.strip().strip('|').split('|')]
        if len(columns) < 7:
            raise ValueError(f'Malformed task row: {line}')

        task_id = columns[0]
        status = columns[5]
        if task_id in tasks:
            raise ValueError(f'Duplicate task ID: {task_id}')
        if status not in VALID_TASK_STATUSES:
            raise ValueError(f'Invalid status for {task_id}: {status}')
        tasks[task_id] = status

    return tasks


def parse_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#'):
            continue
        if '=' not in line:
            raise ValueError(f'Malformed environment line: {raw_line}')
        key, value = line.split('=', 1)
        values[key.strip()] = value.strip()
    return values


def fail(messages: list[str]) -> int:
    for message in messages:
        print(message)
    return 1


def main() -> int:
    errors: list[str] = []

    missing = [path for path in REQUIRED_FILES if not (ROOT / path).is_file()]
    empty = [
        path
        for path in REQUIRED_FILES
        if (ROOT / path).is_file() and (ROOT / path).stat().st_size == 0
    ]

    if missing:
        errors.append('Missing files:')
        errors.extend(f'  - {path}' for path in missing)
    if empty:
        errors.append('Empty files:')
        errors.extend(f'  - {path}' for path in empty)
    if errors:
        return fail(errors)

    task_text = (ROOT / 'docs/TASKS.md').read_text(encoding='utf-8')
    try:
        tasks = parse_task_rows(task_text)
    except ValueError as error:
        return fail([str(error)])

    if not tasks:
        errors.append('TASKS.md contains no parseable task rows.')

    in_progress = [
        task_id for task_id, status in tasks.items() if status == 'IN_PROGRESS'
    ]
    if len(in_progress) > 1:
        errors.append(
            'TASKS.md contains multiple IN_PROGRESS tasks: '
            + ', '.join(in_progress)
        )

    handoff_text = (ROOT / 'docs/HANDOFF.md').read_text(encoding='utf-8')
    for label in REQUIRED_HANDOFF_LABELS:
        if label not in handoff_text:
            errors.append(f'HANDOFF.md is missing required label: {label}')

    current_task_match = re.search(
        r'Current task ID:\s*(P\d{2}-T\d{2})',
        handoff_text,
    )
    current_status_match = re.search(
        r'Current task status:\s*([A-Z_]+)',
        handoff_text,
    )

    if current_task_match is None:
        errors.append('HANDOFF.md current task ID could not be parsed.')
    elif current_task_match.group(1) not in tasks:
        errors.append(
            f'HANDOFF.md references unknown task {current_task_match.group(1)}.'
        )

    if current_status_match is None:
        errors.append('HANDOFF.md current task status could not be parsed.')
    elif current_status_match.group(1) not in VALID_TASK_STATUSES:
        errors.append(
            'HANDOFF.md contains invalid current task status: '
            f'{current_status_match.group(1)}'
        )

    if current_task_match and current_status_match:
        task_id = current_task_match.group(1)
        handoff_status = current_status_match.group(1)
        task_status = tasks.get(task_id)
        if task_status is not None and task_status != handoff_status:
            errors.append(
                f'HANDOFF.md says {task_id} is {handoff_status}, '
                f'but TASKS.md says {task_status}.'
            )

    try:
        project_env = parse_env_file(ROOT / 'tool/project.env')
    except ValueError as error:
        return fail([str(error)])

    for key, expected_value in REQUIRED_PROJECT_ENV.items():
        actual_value = project_env.get(key)
        if actual_value != expected_value:
            errors.append(
                f'tool/project.env expected {key}={expected_value}, '
                f'found {actual_value!r}.'
            )


    flutter_version_file = (ROOT / '.flutter-version').read_text(encoding='utf-8').strip()
    if flutter_version_file != project_env.get('CLEARSCAN_FLUTTER_VERSION'):
        errors.append(
            '.flutter-version does not match CLEARSCAN_FLUTTER_VERSION in tool/project.env.'
        )

    installer_wrapper = (ROOT / 'scripts/install_flutter_sdk.sh').read_text(encoding='utf-8')
    if 'install_flutter_sdk.py' not in installer_wrapper or '"$@"' not in installer_wrapper:
        errors.append(
            'scripts/install_flutter_sdk.sh must delegate all arguments to install_flutter_sdk.py.'
        )

    host_runner_text = (ROOT / 'scripts/complete_phase0_host.sh').read_text(encoding='utf-8')
    for required_option in ('--archive-file', '--manifest-file', '--skip-install'):
        if required_option not in host_runner_text:
            errors.append(
                f'complete_phase0_host.sh is missing required option {required_option}.'
            )

    ci_text = (ROOT / '.github/workflows/flutter-ci.yml').read_text(encoding='utf-8')
    if 'python3 scripts/install_flutter_sdk.py' not in ci_text:
        errors.append('GitHub Actions does not use the repository-owned Flutter installer.')
    if 'subosito/flutter-action' in ci_text:
        errors.append('GitHub Actions still uses an unreviewed Flutter setup action.')
    for required_job in ('source-quality:', 'native-android:', 'native-ios:', 'phase0-summary:'):
        if required_job not in ci_text:
            errors.append(f'GitHub Actions is missing required job: {required_job}')
    if 'scripts/verify_platforms.py' not in ci_text:
        errors.append('GitHub Actions does not verify generated platform identifiers.')
    if 'scripts/verify_ci_pins.py' not in ci_text:
        errors.append('GitHub Actions does not verify immutable action pins.')
    if 'scripts/write_artifact_manifest.py' not in ci_text:
        errors.append('GitHub Actions does not create evidence checksum manifests.')
    if 'scripts/artifact_manifest_test.py' not in ci_text:
        errors.append('GitHub Actions does not test the evidence manifest contract.')
    if 'scripts/phase0_evidence_test.py' not in ci_text:
        errors.append('GitHub Actions does not test the Phase 0 evidence verifier contract.')
    if 'scripts/phase0_gate_summary_test.py' not in ci_text:
        errors.append('GitHub Actions does not test the hosted gate-summary contract.')
    if 'scripts/write_phase0_gate_summary.py' not in ci_text:
        errors.append('GitHub Actions does not write the single hosted P00-T03 gate summary.')
    if 'GITHUB_STEP_SUMMARY' not in ci_text:
        errors.append('GitHub Actions does not surface the hosted P00-T03 gate summary in the run UI.')
    if 'clearscan-phase0-summary' not in ci_text:
        errors.append('GitHub Actions does not retain the hosted P00-T03 gate summary artifact.')
    if 'scripts/verify_phase0_evidence.py' not in ci_text:
        errors.append('GitHub Actions does not verify completed native evidence bundles.')
    if 'scripts/phase0_launch_evidence_test.py' not in ci_text:
        errors.append('GitHub Actions does not test the Phase 0 launch-evidence verifier contract.')
    if 'scripts/phase0_downloaded_run_test.py' not in ci_text:
        errors.append('GitHub Actions does not test downloaded hosted-run verification.')
    if 'scripts/phase0_github_gate_contract_test.py' not in ci_text:
        errors.append('GitHub Actions does not test the GitHub dispatch/collect contract.')
    if './scripts/capture_android_launch_evidence.sh' not in ci_text:
        errors.append('GitHub Actions does not capture Android launch evidence.')
    if './scripts/capture_ios_launch_evidence.sh' not in ci_text:
        errors.append('GitHub Actions does not capture iOS launch evidence.')
    if 'system-images;android-35;google_apis;x86_64' not in ci_text:
        errors.append('GitHub Actions does not pin the Android Phase 0 emulator system image.')
    for required_summary_arg in (
        '--android-launch-verified',
        '--ios-launch-verified',
        '--android-launch-sha256',
        '--ios-launch-sha256',
        '--commit-sha',
        '--git-ref',
    ):
        if required_summary_arg not in ci_text:
            errors.append(
                f'GitHub Actions hosted gate summary is missing {required_summary_arg}.'
            )
    if 'if: always()' not in ci_text:
        errors.append('GitHub Actions does not retain partial native evidence on failure.')

    app_config_text = (
        ROOT / 'lib/app/configuration/app_config.dart'
    ).read_text(encoding='utf-8')
    if "appName = 'ClearScan'" not in app_config_text:
        errors.append('Central app configuration does not define ClearScan.')
    if "tagline = 'Smart Scanner. Better Documents.'" not in app_config_text:
        errors.append('Central app configuration tagline does not match the project master.')

    if errors:
        return fail(errors)

    print(
        f'Validated {len(REQUIRED_FILES)} required project files, '
        f'{len(tasks)} task rows, handoff alignment, and platform settings.'
    )
    return 0


if __name__ == '__main__':
    sys.exit(main())
