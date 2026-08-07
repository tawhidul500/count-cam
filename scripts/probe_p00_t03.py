from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
PROJECT_ENV = ROOT / 'tool/project.env'
DEFAULT_OUTPUT_ROOT = ROOT / 'artifacts/p00_t03_probe'
NETWORK_TIMEOUT_SECONDS = 12


def parse_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#'):
            continue
        key, sep, value = line.partition('=')
        if not sep:
            raise ValueError(f'Malformed environment line: {raw_line}')
        values[key.strip()] = value.strip()
    return values


def run_command(command: list[str], *, timeout: int = 180) -> dict[str, Any]:
    try:
        result = subprocess.run(
            command,
            cwd=ROOT,
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        return {
            'command': command,
            'passed': False,
            'exit_code': None,
            'stdout': '',
            'stderr': str(error),
        }

    return {
        'command': command,
        'passed': result.returncode == 0,
        'exit_code': result.returncode,
        'stdout': result.stdout.strip(),
        'stderr': result.stderr.strip(),
    }


def tool_probe(name: str, version_command: list[str] | None = None) -> dict[str, Any]:
    path = shutil.which(name)
    probe: dict[str, Any] = {'name': name, 'available': path is not None, 'path': path}
    if path is None or version_command is None:
        return probe

    result = run_command(version_command, timeout=45)
    probe['version_probe'] = {
        'passed': result['passed'],
        'exit_code': result['exit_code'],
        'stdout': result['stdout'],
        'stderr': result['stderr'],
    }
    return probe


def network_probe(url: str) -> dict[str, Any]:
    # Run DNS/TLS probing in a child process so a stuck resolver cannot hang
    # the parent probe indefinitely. The outer subprocess timeout is the hard
    # bound; urllib's timeout remains the inner connection/read bound.
    worker = r"""
import json
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

url = sys.argv[1]
request = Request(url, method='HEAD', headers={'User-Agent': 'ClearScan-P00-T03-Probe/1.0'})
try:
    with urlopen(request, timeout=10) as response:
        result = {'url': url, 'reachable': True, 'status': getattr(response, 'status', None), 'error': None}
except HTTPError as error:
    result = {'url': url, 'reachable': True, 'status': error.code, 'error': f'HTTP {error.code}: {error.reason}'}
except (URLError, OSError) as error:
    result = {'url': url, 'reachable': False, 'status': None, 'error': str(error)}
print(json.dumps(result))
"""
    try:
        completed = subprocess.run(
            [sys.executable, '-c', worker, url],
            check=False,
            capture_output=True,
            text=True,
            timeout=NETWORK_TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired:
        return {
            'url': url,
            'reachable': False,
            'status': None,
            'error': f'network probe exceeded hard timeout of {NETWORK_TIMEOUT_SECONDS}s',
        }

    try:
        result = json.loads(completed.stdout.strip())
    except json.JSONDecodeError:
        return {
            'url': url,
            'reachable': False,
            'status': None,
            'error': completed.stderr.strip() or 'network probe returned invalid JSON',
        }
    return result


def first_line(value: str | None) -> str:
    if not value:
        return ''
    return value.splitlines()[0].strip()


def markdown_report(report: dict[str, Any]) -> str:
    pins = report['pins']
    readiness = report['readiness']
    lines = [
        '# ClearScan P00-T03 Environment Probe',
        '',
        f"- Captured at (UTC): {report['captured_at_utc']}",
        f"- Host: {report['host']['system']} {report['host']['release']} ({report['host']['machine']})",
        f"- Repository: `{report['repository']}`",
        f"- Pinned Flutter: `{pins['flutter_version']}` / `{pins['flutter_channel']}`",
        f"- Pinned Dart: `{pins['dart_version']}`",
        f"- Android ID: `{pins['android_application_id']}`",
        f"- iOS bundle ID: `{pins['ios_bundle_id']}`",
        '',
        '## Readiness',
        '',
        f"- Static source checks: {'PASS' if readiness['static_checks_pass'] else 'FAIL'}",
        f"- Exact Flutter available: {'YES' if readiness['exact_flutter_available'] else 'NO'}",
        f"- Dart available: {'YES' if readiness['dart_available'] else 'NO'}",
        f"- Android runner present: {'YES' if readiness['android_runner_present'] else 'NO'}",
        f"- iOS runner present: {'YES' if readiness['ios_runner_present'] else 'NO'}",
        f"- Git repository metadata present: {'YES' if readiness['git_repository_present'] else 'NO'}",
        f"- GitHub CLI available: {'YES' if readiness['github_cli_available'] else 'NO'}",
        f"- Android native build prerequisites on this host: {'READY' if readiness['android_build_prerequisites'] else 'NOT READY'}",
        f"- iOS native build prerequisites on this host: {'READY' if readiness['ios_build_prerequisites'] else 'NOT READY'}",
        f"- P00-T03 complete on this host: {'YES' if readiness['p00_t03_host_gate_ready'] else 'NO'}",
        '',
        '## Static checks',
        '',
    ]

    for name, result in report['static_checks'].items():
        status = 'PASS' if result['passed'] else 'FAIL'
        detail = first_line(result['stderr']) or first_line(result['stdout'])
        suffix = f' — {detail}' if detail else ''
        lines.append(f'- `{name}`: **{status}**{suffix}')

    lines.extend(['', '## Toolchain', ''])
    for name, probe in report['tools'].items():
        status = 'available' if probe['available'] else 'missing'
        version = ''
        if probe.get('version_probe'):
            vp = probe['version_probe']
            version_text = first_line(vp.get('stdout')) or first_line(vp.get('stderr'))
            if version_text:
                version = f' — {version_text}'
        lines.append(f'- `{name}`: **{status}**{version}')

    lines.extend(['', '## Release resolution', ''])
    resolution = report['release_resolution']
    if resolution['passed']:
        lines.append('- Local official-manifest fixture resolves the pinned Flutter release: **PASS**')
        if resolution.get('metadata'):
            metadata = resolution['metadata']
            lines.append(f"- Archive: `{metadata.get('archive', '')}`")
            lines.append(f"- SHA-256: `{metadata.get('sha256', '')}`")
    else:
        lines.append('- Local official-manifest fixture resolves the pinned Flutter release: **FAIL**')
        if resolution.get('error'):
            lines.append(f"- Error: `{resolution['error']}`")

    lines.extend(['', '## Connectivity', ''])
    for probe in report['network']:
        status = 'reachable' if probe['reachable'] else 'blocked/unreachable'
        detail = f" (HTTP {probe['status']})" if probe['status'] is not None else ''
        lines.append(f"- `{probe['url']}`: **{status}**{detail}")
        if probe.get('error'):
            lines.append(f"  - {probe['error']}")

    lines.extend(['', '## Current blockers', ''])
    blockers = report['blockers']
    if blockers:
        lines.extend(f'- {item}' for item in blockers)
    else:
        lines.append('- None detected by this probe.')

    lines.extend(
        [
            '',
            '## Gate rule',
            '',
            'This probe is diagnostic evidence only. It never marks P00-T03 complete by itself. ',
            'P00-T03 still requires real Flutter formatting, analysis, widget tests, generated Android/iOS runners, ',
            'native builds, and verified Android/iOS launch evidence from a real hosted or connected target.',
            '',
        ]
    )
    return '\n'.join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Capture a non-destructive P00-T03 readiness probe even when Flutter is unavailable.'
    )
    parser.add_argument(
        '--output-root',
        type=Path,
        default=DEFAULT_OUTPUT_ROOT,
        help='Directory that will receive a timestamped probe folder.',
    )
    parser.add_argument(
        '--require-ready',
        action='store_true',
        help='Exit non-zero unless this host has the local prerequisites to execute P00-T03.',
    )
    args = parser.parse_args()

    try:
        env = parse_env(PROJECT_ENV)
    except (OSError, ValueError) as error:
        print(f'Unable to read {PROJECT_ENV}: {error}', file=sys.stderr)
        return 2

    timestamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    output_dir = args.output_root.expanduser().resolve() / timestamp
    output_dir.mkdir(parents=True, exist_ok=True)

    checks = {
        'repository_contract': run_command(['python3', 'scripts/validate_project.py']),
        'source_contract': run_command(['python3', 'scripts/source_contract_test.py']),
        'immutable_ci_pins': run_command(['python3', 'scripts/verify_ci_pins.py']),
        'artifact_manifest_contract': run_command(['python3', 'scripts/artifact_manifest_test.py']),
        'phase0_evidence_contract': run_command(['python3', 'scripts/phase0_evidence_test.py']),
        'phase0_gate_summary_contract': run_command(['python3', 'scripts/phase0_gate_summary_test.py']),
        'phase0_launch_evidence_contract': run_command(['python3', 'scripts/phase0_launch_evidence_test.py']),
        'phase0_downloaded_run_contract': run_command(['python3', 'scripts/phase0_downloaded_run_test.py']),
        'phase0_github_gate_contract': run_command(['python3', 'scripts/phase0_github_gate_contract_test.py']),
        'phase0_github_bootstrap_contract': run_command(['python3', 'scripts/phase0_github_bootstrap_contract_test.py']),
    }

    version_commands = {
        'python3': ['python3', '--version'],
        'git': ['git', '--version'],
        'gh': ['gh', '--version'],
        'java': ['java', '-version'],
        'flutter': ['flutter', '--version'],
        'dart': ['dart', '--version'],
        'adb': ['adb', 'version'],
        'sdkmanager': ['sdkmanager', '--version'],
        'xcodebuild': ['xcodebuild', '-version'],
        'pod': ['pod', '--version'],
        'docker': ['docker', '--version'],
        'podman': ['podman', '--version'],
    }
    tools = {name: tool_probe(name, command) for name, command in version_commands.items()}

    resolution_command = [
        'python3',
        'scripts/install_flutter_sdk.py',
        '--resolve-only',
        '--manifest-file',
        'tool/fixtures/flutter_releases_linux.json',
        '--platform',
        'linux',
        '--architecture',
        'x64',
    ]
    resolution_result = run_command(resolution_command)
    resolution: dict[str, Any] = {'passed': resolution_result['passed']}
    if resolution_result['passed']:
        try:
            resolution['metadata'] = json.loads(resolution_result['stdout'])
        except json.JSONDecodeError:
            resolution['passed'] = False
            resolution['error'] = 'Release resolver returned invalid JSON.'
    else:
        resolution['error'] = resolution_result['stderr'] or resolution_result['stdout']

    manifest_url = 'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json'
    archive_url = ''
    if resolution.get('metadata'):
        archive_url = str(resolution['metadata'].get('archive_url', ''))
    network = [network_probe(manifest_url)]
    if archive_url:
        network.append(network_probe(archive_url))

    flutter_exact = False
    flutter_probe = tools['flutter']
    if flutter_probe['available']:
        machine = run_command(['flutter', '--version', '--machine'], timeout=60)
        if machine['passed']:
            try:
                metadata = json.loads(machine['stdout'])
                flutter_exact = metadata.get('frameworkVersion') == env.get('CLEARSCAN_FLUTTER_VERSION')
            except json.JSONDecodeError:
                flutter_exact = False

    system = platform.system()
    android_home = os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
    android_sdk_present = bool(android_home and Path(android_home).is_dir())
    android_prereqs = (
        flutter_exact
        and tools['dart']['available']
        and tools['java']['available']
        and android_sdk_present
    )
    ios_prereqs = (
        system == 'Darwin'
        and flutter_exact
        and tools['dart']['available']
        and tools['xcodebuild']['available']
    )

    android_runner = (ROOT / 'android').is_dir()
    ios_runner = (ROOT / 'ios').is_dir()
    git_repository_present = (ROOT / '.git').exists()
    static_pass = all(result['passed'] for result in checks.values())
    host_gate_ready = static_pass and flutter_exact and tools['dart']['available'] and (
        android_prereqs or ios_prereqs
    )

    blockers: list[str] = []
    if not flutter_exact:
        blockers.append(
            f"Pinned Flutter {env.get('CLEARSCAN_FLUTTER_VERSION', 'unknown')} is not executable on this host."
        )
    if not tools['dart']['available']:
        blockers.append('Dart is not executable on this host.')
    if not android_runner:
        blockers.append('Generated Android runner directory is absent.')
    if not ios_runner:
        blockers.append('Generated iOS runner directory is absent.')
    if not git_repository_present:
        blockers.append('This extracted project has no .git metadata; hosted dispatch requires a connected git clone.')
    if not tools['gh']['available']:
        blockers.append('GitHub CLI is not installed; hosted dispatch/download automation cannot run on this host.')
    if system in {'Linux', 'Darwin'} and not android_sdk_present:
        blockers.append('ANDROID_HOME/ANDROID_SDK_ROOT does not point to an installed Android SDK.')
    if system != 'Darwin':
        blockers.append('This host cannot supply iOS/Xcode launch evidence because it is not macOS.')
    elif not tools['xcodebuild']['available']:
        blockers.append('Xcode command-line build tooling is unavailable.')
    unreachable = [probe['url'] for probe in network if not probe['reachable']]
    if unreachable:
        blockers.append('Official Flutter release storage is unreachable from this host during the probe.')
    if not static_pass:
        blockers.append('One or more repository-owned static checks failed.')

    report: dict[str, Any] = {
        'schema_version': 1,
        'captured_at_utc': timestamp,
        'repository': str(ROOT),
        'host': {
            'system': system,
            'release': platform.release(),
            'machine': platform.machine(),
            'python': platform.python_version(),
        },
        'pins': {
            'flutter_channel': env.get('CLEARSCAN_FLUTTER_CHANNEL'),
            'flutter_version': env.get('CLEARSCAN_FLUTTER_VERSION'),
            'flutter_release_hash': env.get('CLEARSCAN_FLUTTER_RELEASE_HASH'),
            'flutter_linux_x64_sha256': env.get('CLEARSCAN_FLUTTER_ARCHIVE_SHA256_LINUX_X64'),
            'dart_version': env.get('CLEARSCAN_DART_VERSION'),
            'android_application_id': env.get('CLEARSCAN_ANDROID_APPLICATION_ID'),
            'ios_bundle_id': env.get('CLEARSCAN_IOS_BUNDLE_ID'),
        },
        'static_checks': checks,
        'tools': tools,
        'release_resolution': resolution,
        'network': network,
        'environment': {
            'ANDROID_HOME': os.environ.get('ANDROID_HOME'),
            'ANDROID_SDK_ROOT': os.environ.get('ANDROID_SDK_ROOT'),
        },
        'readiness': {
            'static_checks_pass': static_pass,
            'exact_flutter_available': flutter_exact,
            'dart_available': tools['dart']['available'],
            'android_runner_present': android_runner,
            'ios_runner_present': ios_runner,
            'git_repository_present': git_repository_present,
            'github_cli_available': tools['gh']['available'],
            'android_sdk_present': android_sdk_present,
            'android_build_prerequisites': android_prereqs,
            'ios_build_prerequisites': ios_prereqs,
            'p00_t03_host_gate_ready': host_gate_ready,
        },
        'blockers': blockers,
    }

    json_path = output_dir / 'P00_T03_PROBE.json'
    markdown_path = output_dir / 'P00_T03_PROBE.md'
    json_path.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    markdown_path.write_text(markdown_report(report), encoding='utf-8')

    print(markdown_report(report))
    print(f'Probe evidence: {output_dir}')

    if args.require_ready and not host_gate_ready:
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
