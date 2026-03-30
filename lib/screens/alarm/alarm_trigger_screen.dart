import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:alarm/alarm.dart';
import '../../models/quest_config.dart';
import 'quests/math_quest.dart';
import 'quests/type_quest.dart';
import 'quests/simon_quest.dart';

class AlarmTriggerScreen extends StatefulWidget {
  final String alarmId;
  final String label;
  final QuestConfig quest;

  const AlarmTriggerScreen({
    super.key,
    required this.alarmId,
    required this.label,
    required this.quest,
  });

  @override
  State<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends State<AlarmTriggerScreen> {
  bool _showQuest = false;

  Future<void> _stopAlarm() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final id = int.tryParse(widget.alarmId) ?? 0;
      await Alarm.stop(id);
    }
  }

  Future<void> _dismiss() async {
    await _stopAlarm();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    }
  }

  Future<void> _snooze() async {
    await _stopAlarm();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    }
  }

  String get _timeString {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _dateString {
    final now = DateTime.now();
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _questInstruction() {
    switch (widget.quest.type) {
      case QuestType.none: return '';
      case QuestType.math: return 'Solve the math problem';
      case QuestType.typeSentence: return 'Type the sentence';
      case QuestType.simon: return 'Repeat the pattern';
      case QuestType.qr: return 'Scan your QR code';
      case QuestType.squat: return 'Complete ${widget.quest.squatCount} squats';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _showQuest ? _buildQuestView() : _buildLockView(),
      ),
    );
  }

  Widget _buildLockView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
            const SizedBox(height: 4),
            const Text(
              'Swipe up to unlock',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 40),
            Text(
              _timeString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 88,
                fontWeight: FontWeight.w200,
                letterSpacing: -4,
              ),
            ),
            Text(
              _dateString,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Text(
              widget.label.isEmpty ? 'Alarm' : widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            if (widget.quest.type != QuestType.none) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🎯 ${_questInstruction()} to dismiss',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LockButton(
                  icon: Icons.snooze,
                  label: 'Snooze',
                  onTap: _snooze,
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.quest.type == QuestType.none) {
                      _dismiss();
                    } else {
                      setState(() => _showQuest = true);
                    }
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A020),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        widget.quest.type == QuestType.none
                            ? 'Dismiss'
                            : 'Wake Up 👊',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestView() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.alarm, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              widget.label.isEmpty ? 'Alarm' : widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _questInstruction(),
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildQuestWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestWidget() {
    switch (widget.quest.type) {
      case QuestType.math:
        return MathQuest(
          difficulty: widget.quest.mathDifficulty,
          onSuccess: _dismiss,
        );
      case QuestType.typeSentence:
        return TypeQuest(
          sentence: widget.quest.sentence,
          onSuccess: _dismiss,
        );
      case QuestType.simon:
        return SimonQuest(
          gridSize: widget.quest.gridSize,
          onSuccess: _dismiss,
        );
      case QuestType.qr:
      case QuestType.squat:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Coming soon!',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _dismiss,
                child: const Text('Dismiss for now'),
              ),
            ],
          ),
        );
      case QuestType.none:
        return Center(
          child: ElevatedButton.icon(
            onPressed: _dismiss,
            icon: const Icon(Icons.alarm_off),
            label: const Text('Dismiss'),
          ),
        );
    }
  }
}

class _LockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LockButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
