import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/alarm.dart';
import '../../models/alarm_history_entry.dart';
import '../../models/quest_config.dart';
import '../../providers/alarm_history_provider.dart';
import '../../providers/alarm_provider.dart';
import '../../services/alarm_service.dart';
import '../../services/android_alarm_permissions_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_sheet.dart';
import 'alarm_editor_screen.dart';

class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);
    final history = ref.watch(alarmHistoryProvider).take(6).toList();
    final user = ref.watch(authStateProvider).valueOrNull;
    final alarmService = AlarmService();
    final enabledAlarms = alarms.where((a) => a.isEnabled).toList()
      ..sort(
        (a, b) => alarmService
            .nextOccurrence(a)
            .compareTo(alarmService.nextOccurrence(b)),
      );
    final nextAlarm = enabledAlarms.isNotEmpty ? enabledAlarms.first : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alarm',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${enabledAlarms.length} active • ${alarms.length} total',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (user != null)
                    GestureDetector(
                      onTap: () => showAccountSheet(context, ref, user),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.surfaceHigh,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Text(
                                (user.displayName?.trim().isNotEmpty == true
                                        ? user.displayName!.trim()[0]
                                        : user.email?.trim().isNotEmpty == true
                                            ? user.email!.trim()[0]
                                            : 'U')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                    ),
                  if (user != null) const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlarmEditorScreen()),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _AlarmReadinessCard(),
            ),
            if (nextAlarm != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _NextAlarmBanner(alarm: nextAlarm),
              ),
            if (history.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _AlarmHistoryCard(entries: history),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: alarms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alarm_off, size: 48, color: AppTheme.textTertiary),
                          const SizedBox(height: 12),
                          const Text(
                            'No alarms yet',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap + to add one',
                            style: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: alarms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _AlarmCard(alarm: alarms[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlarmHistoryCard extends StatelessWidget {
  const _AlarmHistoryCard({required this.entries});

  final List<AlarmHistoryEntry> entries;

  String _relative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _label(String event) {
    switch (event) {
      case 'triggered':
        return 'Triggered';
      case 'dismissed':
        return 'Dismissed';
      case 'snoozed':
        return 'Snoozed';
      case 'missed':
        return 'Missed';
      case 'mission_started':
        return 'Mission started';
      case 'updated':
        return 'Updated';
      case 'enabled':
        return 'Enabled';
      case 'disabled':
        return 'Disabled';
      case 'created':
        return 'Created';
      case 'deleted':
        return 'Deleted';
      case 'rescheduled':
        return 'Rescheduled';
      default:
        return event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final missedCount = entries.where((entry) => entry.event == 'missed').length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent alarm activity',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showFullHistory(context, entries),
                child: const Text('View all'),
              ),
              if (missedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$missedCount missed',
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: entry.event == 'missed' ? AppTheme.danger : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_label(entry.event)} • ${entry.alarmLabel}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.details.isEmpty ? _relative(entry.timestamp) : '${entry.details} • ${_relative(entry.timestamp)}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showFullHistory(BuildContext context, List<AlarmHistoryEntry> entries) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (_) => _AlarmHistorySheet(entries: entries),
    );
  }
}

class _AlarmHistorySheet extends StatefulWidget {
  const _AlarmHistorySheet({required this.entries});

  final List<AlarmHistoryEntry> entries;

  @override
  State<_AlarmHistorySheet> createState() => _AlarmHistorySheetState();
}

class _AlarmHistorySheetState extends State<_AlarmHistorySheet> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? widget.entries
        : _filter == 'failures'
            ? widget.entries
                .where((entry) => entry.event == 'missed')
                .toList()
            : widget.entries.where((entry) => entry.event == _filter).toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alarm history',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _HistoryFilterChip(
                    label: 'All',
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  _HistoryFilterChip(
                    label: 'Missed',
                    selected: _filter == 'missed',
                    onTap: () => setState(() => _filter = 'missed'),
                  ),
                  _HistoryFilterChip(
                    label: 'Failures',
                    selected: _filter == 'failures',
                    onTap: () => setState(() => _filter = 'failures'),
                  ),
                  _HistoryFilterChip(
                    label: 'Dismissed',
                    selected: _filter == 'dismissed',
                    onTap: () => setState(() => _filter = 'dismissed'),
                  ),
                  _HistoryFilterChip(
                    label: 'Snoozed',
                    selected: _filter == 'snoozed',
                    onTap: () => setState(() => _filter = 'snoozed'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = filtered[index];
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
                          '${_prettyEvent(entry.event)} • ${entry.alarmLabel}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.details.isEmpty
                              ? entry.timestamp.toLocal().toString()
                              : '${entry.details}\n${entry.timestamp.toLocal()}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyEvent(String event) {
    switch (event) {
      case 'mission_started':
        return 'Mission started';
      case 'missed':
        return 'Mission failed';
      case 'updated':
        return 'Updated';
      default:
        return event[0].toUpperCase() + event.substring(1);
    }
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withOpacity(0.14) : AppTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AlarmReadinessCard extends StatefulWidget {
  const _AlarmReadinessCard();

  @override
  State<_AlarmReadinessCard> createState() => _AlarmReadinessCardState();
}

class _AlarmReadinessCardState extends State<_AlarmReadinessCard> {
  final _service = AndroidAlarmPermissionsService();
  AndroidAlarmPermissionStatus? _status;
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    final status = await _service.getStatus();
    if (!mounted) return;
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }

    if (_loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Checking alarm readiness...',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    final status = _status;
    if (status == null) return const SizedBox.shrink();

    final ready = status.isReady;
    final shouldExpand = _expanded || !ready;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ready ? AppTheme.success.withOpacity(0.12) : AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ready ? AppTheme.success.withOpacity(0.35) : AppTheme.primary.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ready ? 'Alarm readiness OK' : 'Alarm setup needed',
                    style: TextStyle(
                      color: ready ? AppTheme.success : AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  shouldExpand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: ready ? AppTheme.success : AppTheme.primary,
                ),
              ],
            ),
          ),
          if (shouldExpand) ...[
            const SizedBox(height: 4),
            Text(
              ready
                  ? 'Exact alarm, fullscreen, notifications, and battery settings are in a good state.'
                  : 'One or more Android permissions/settings still need attention.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PermissionChip(
                  label: status.exactAlarmAllowed ? 'Exact Alarm On' : 'Enable Exact Alarm',
                  isReady: status.exactAlarmAllowed,
                  onTap: () async {
                    if (!status.exactAlarmAllowed) {
                      await _service.openExactAlarmSettings();
                      await _refresh();
                    }
                  },
                ),
                _PermissionChip(
                  label: status.fullScreenIntentAllowed ? 'Full Screen On' : 'Enable Full Screen',
                  isReady: status.fullScreenIntentAllowed,
                  onTap: () async {
                    if (!status.fullScreenIntentAllowed) {
                      await _service.openFullScreenIntentSettings();
                      await _refresh();
                    }
                  },
                ),
                _PermissionChip(
                  label: status.notificationsAllowed ? 'Notifications On' : 'Enable Notifications',
                  isReady: status.notificationsAllowed,
                  onTap: () async {
                    if (!status.notificationsAllowed) {
                      await _service.openNotificationSettings();
                      await _refresh();
                    }
                  },
                ),
                _PermissionChip(
                  label: status.ignoringBatteryOptimizations
                      ? 'Battery Unrestricted'
                      : 'Disable Battery Limits',
                  isReady: status.ignoringBatteryOptimizations,
                  onTap: () async {
                    if (!status.ignoringBatteryOptimizations) {
                      await _service.openBatteryOptimizationSettings();
                      await _refresh();
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  final bool isReady;
  final VoidCallback onTap;

  const _PermissionChip({
    required this.label,
    required this.isReady,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isReady ? AppTheme.success.withOpacity(0.15) : AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isReady ? AppTheme.success : AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NextAlarmBanner extends StatelessWidget {
  final AlarmModel alarm;
  const _NextAlarmBanner({required this.alarm});

  String _timeUntil() {
    final now = DateTime.now();
    final target = AlarmService().nextOccurrence(alarm);
    final diff = target.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h == 0) return 'Rings in $m minutes';
    return 'Rings in $h hr ${m > 0 ? '$m min' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppTheme.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            _timeUntil(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            alarm.timeString,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmCard extends ConsumerWidget {
  final AlarmModel alarm;
  const _AlarmCard({required this.alarm});

  String _questLabel(QuestType type) {
    switch (type) {
      case QuestType.none:
        return 'No quest';
      case QuestType.math:
        return 'Math';
      case QuestType.typeSentence:
        return 'Type sentence';
      case QuestType.simon:
        return 'Simon Says';
      case QuestType.qr:
        return 'QR scan';
      case QuestType.squat:
        return 'Step challenge';
    }
  }

  String _nextRingText() {
    final next = AlarmService().nextOccurrence(alarm);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = days[next.weekday - 1];
    final hh = next.hour.toString().padLeft(2, '0');
    final mm = next.minute.toString().padLeft(2, '0');
    return 'Next: $day $hh:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(alarmProvider.notifier).delete(alarm.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlarmEditorScreen(alarm: alarm)),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: alarm.isEnabled ? AppTheme.surface : AppTheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alarm.isEnabled ? AppTheme.border : AppTheme.border.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          alarm.timeString,
                          style: TextStyle(
                            color: alarm.isEnabled ? AppTheme.textPrimary : AppTheme.textTertiary,
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            alarm.hour < 12 ? 'AM' : 'PM',
                            style: TextStyle(
                              color: alarm.isEnabled ? AppTheme.textSecondary : AppTheme.textTertiary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (alarm.label.isNotEmpty) ...[
                          Text(
                            alarm.label,
                            style: TextStyle(
                              color: alarm.isEnabled ? AppTheme.textSecondary : AppTheme.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppTheme.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          alarm.repeatString,
                          style: TextStyle(
                            color: alarm.isEnabled ? AppTheme.textSecondary : AppTheme.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _nextRingText(),
                      style: TextStyle(
                        color: alarm.isEnabled ? AppTheme.textTertiary : AppTheme.textTertiary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    if (alarm.quest.type != QuestType.none) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _questLabel(alarm.quest.type),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: alarm.isEnabled,
                onChanged: (_) => ref.read(alarmProvider.notifier).toggle(alarm.id),
                activeColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary.withOpacity(0.3),
                inactiveThumbColor: AppTheme.textTertiary,
                inactiveTrackColor: AppTheme.surfaceHigh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
