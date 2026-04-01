import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_settings_provider.dart';
import '../../providers/note_folders_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/stickies_provider.dart';
import '../../providers/sticky_boards_provider.dart';
import '../../services/android_alarm_permissions_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../notes/notes_screen.dart';
import '../stickies/stickies_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _alarmPermissionsService = AndroidAlarmPermissionsService();
  AndroidAlarmPermissionStatus? _alarmStatus;

  @override
  void initState() {
    super.initState();
    _refreshAlarmStatus();
  }

  Future<void> _refreshAlarmStatus() async {
    final status = await _alarmPermissionsService.getStatus();
    if (!mounted) return;
    setState(() => _alarmStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final notesCount = ref.watch(notesProvider).length;
    final foldersCount = ref.watch(noteFoldersProvider).length;
    final stickiesCount = ref.watch(stickiesProvider).length;
    final boardsCount = ref.watch(stickyBoardsProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Account & sync',
            children: [
              _StatusRow(
                label: 'Signed in account',
                value: user?.email ?? 'Not signed in',
              ),
              const SizedBox(height: 10),
              _StatusRow(
                label: 'Sync mode',
                value: user == null ? 'Local only' : 'Google account sync enabled',
              ),
              const SizedBox(height: 10),
              _StatusRow(
                label: 'Workspace items',
                value:
                    '$notesCount notes • $foldersCount folders • $stickiesCount stickies • $boardsCount boards',
              ),
              const SizedBox(height: 10),
              const Text(
                'Notes, folders, stickies, and boards sync through Firebase when you are signed in with Google.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Alarm defaults',
            children: [
              const Text(
                'Default mission timer',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [10, 20, 30, 45, 60, 90].map((seconds) {
                  return _SettingsTimerChip(seconds: seconds);
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Notes',
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: settings.noteEditorCollapsedTools,
                onChanged: (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setNoteEditorCollapsedTools(value),
                title: const Text('Collapse note tools by default'),
                subtitle: const Text(
                  'Keeps the note editor cleaner and easier to use on smaller screens.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            title: 'Backup center',
            children: [
              _BackupHintTile(
                title: 'Notes backup',
                subtitle:
                    'Use the Notes screen toolbar to export or import a JSON backup of folders and notes.',
              ),
              SizedBox(height: 10),
              _BackupHintTile(
                title: 'Stickies backup',
                subtitle:
                    'Use the Stickies screen toolbar to export or import a JSON backup of boards and sticky notes.',
              ),
              SizedBox(height: 10),
              Text(
                'Cloud sync and local backup work well together: sync keeps devices up to date, while JSON backup gives you an offline copy.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Workspace shortcuts',
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.note_alt_outlined),
                    label: const Text('Open Notes'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StickiesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sticky_note_2_outlined),
                    label: const Text('Open Stickies'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Alarm readiness',
            children: [
              if (_alarmStatus == null)
                const Text(
                  'Checking alarm permissions...',
                  style: TextStyle(color: AppTheme.textSecondary),
                )
              else ...[
                _PermissionRow(
                  label: 'Exact alarms',
                  ok: _alarmStatus!.exactAlarmAllowed,
                ),
                _PermissionRow(
                  label: 'Full-screen intent',
                  ok: _alarmStatus!.fullScreenIntentAllowed,
                ),
                _PermissionRow(
                  label: 'Notifications',
                  ok: _alarmStatus!.notificationsAllowed,
                ),
                _PermissionRow(
                  label: 'Battery unrestricted',
                  ok: _alarmStatus!.ignoringBatteryOptimizations,
                ),
                if (defaultTargetPlatform == TargetPlatform.android) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await _alarmPermissionsService.openExactAlarmSettings();
                          await _refreshAlarmStatus();
                        },
                        child: const Text('Exact alarm'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _alarmPermissionsService.openFullScreenIntentSettings();
                          await _refreshAlarmStatus();
                        },
                        child: const Text('Full screen'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _alarmPermissionsService.openNotificationSettings();
                          await _refreshAlarmStatus();
                        },
                        child: const Text('Notifications'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _alarmPermissionsService.openBatteryOptimizationSettings();
                          await _refreshAlarmStatus();
                        },
                        child: const Text('Battery'),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            title: 'Control center',
            children: [
              Text(
                'Use Notes and Stickies screens for export/import backups. This page will keep growing into the app-wide control center for sync, alarm behavior, and personal preferences.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTimerChip extends ConsumerWidget {
  const _SettingsTimerChip({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(appSettingsProvider).defaultMissionSeconds == seconds;
    return InkWell(
      onTap: () => ref
          .read(appSettingsProvider.notifier)
          .setDefaultMissionSeconds(seconds),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            color: selected ? Colors.black : AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.label,
    required this.ok,
  });

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.error_outline,
            size: 18,
            color: ok ? AppTheme.success : AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupHintTile extends StatelessWidget {
  const _BackupHintTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.45,
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
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
