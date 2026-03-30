import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alarm_provider.dart';
import '../../models/alarm.dart';
import '../../models/quest_config.dart';
import '../../theme/app_theme.dart';
import 'alarm_editor_screen.dart';

class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);
    final nextAlarm = alarms.where((a) => a.isEnabled).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
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
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlarmEditorScreen()),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            if (nextAlarm.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _NextAlarmBanner(alarm: nextAlarm.first),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: alarms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alarm_off, size: 48, color: AppTheme.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            'No alarms yet',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
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

class _NextAlarmBanner extends StatelessWidget {
  final AlarmModel alarm;
  const _NextAlarmBanner({required this.alarm});

  String _timeUntil() {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
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
      case QuestType.none: return 'No quest';
      case QuestType.math: return '🧮 Math';
      case QuestType.typeSentence: return '⌨️ Type sentence';
      case QuestType.simon: return '🟦 Simon Says';
      case QuestType.qr: return '📱 QR scan';
      case QuestType.squat: return '🏃 Squat';
    }
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
                          Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppTheme.textTertiary, shape: BoxShape.circle)),
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
                    if (alarm.quest.type != QuestType.none) ...[
                      const SizedBox(height: 6),
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
