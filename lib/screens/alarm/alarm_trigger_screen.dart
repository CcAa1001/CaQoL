import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/alarm.dart';
import '../../models/quest_config.dart';
import '../../services/notes_service.dart';
import '../../providers/alarm_provider.dart';
import '../notes/note_editor_screen.dart';
import 'quests/math_quest.dart';
import 'quests/qr_quest.dart';
import 'quests/simon_quest.dart';
import 'quests/squat_quest.dart';
import 'quests/type_quest.dart';

class AlarmTriggerScreen extends ConsumerStatefulWidget {
  final AlarmModel alarm;
  final bool isPreview;

  const AlarmTriggerScreen({
    super.key,
    required this.alarm,
    this.isPreview = false,
  });

  @override
  ConsumerState<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends ConsumerState<AlarmTriggerScreen> {
  late bool _showQuest;
  Timer? _clockTimer;
  Timer? _missionTimer;
  late int _missionTimeLeft;
  bool _missionStarted = false;
  bool _timeoutHandled = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _showQuest = widget.isPreview && widget.alarm.quest.type != QuestType.none;
    _missionTimeLeft = widget.alarm.quest.missionSeconds;
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _missionTimer?.cancel();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_finishing) return;
    _finishing = true;
    _missionTimer?.cancel();
    if (widget.isPreview) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await ref.read(alarmProvider.notifier).completeAfterDismiss(widget.alarm.id);
    if (mounted) {
      final linkedNoteId = widget.alarm.noteId;
      final linkedNote = linkedNoteId == null ? null : NotesService().getById(linkedNoteId);
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (linkedNote != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteEditorScreen(note: linkedNote),
          ),
        );
      }
    }
  }

  Future<void> _snooze() async {
    if (_finishing) return;
    _finishing = true;
    _missionTimer?.cancel();
    if (widget.isPreview) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await ref.read(alarmProvider.notifier).snooze(widget.alarm.id);
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _startMission() async {
    if (_missionStarted || _timeoutHandled) return;
    _missionStarted = true;
    if (!widget.isPreview) {
      await ref.read(alarmProvider.notifier).silenceForMission(widget.alarm.id);
      _startMissionTimer();
    }
    if (mounted) {
      setState(() => _showQuest = true);
    }
  }

  void _startMissionTimer() {
    _missionTimer?.cancel();
    _timeoutHandled = false;
    _missionTimeLeft = widget.alarm.quest.missionSeconds;
    _missionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_missionTimeLeft <= 1) {
        timer.cancel();
        await _handleMissionTimeout();
        return;
      }
      setState(() => _missionTimeLeft -= 1);
    });
  }

  Future<void> _handleMissionTimeout() async {
    if (_timeoutHandled || _finishing) return;
    _timeoutHandled = true;
    if (widget.isPreview) return;

    await ref.read(alarmProvider.notifier).restartAfterMissionTimeout(widget.alarm.id);
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _questInstruction() {
    switch (widget.alarm.quest.type) {
      case QuestType.none:
        return '';
      case QuestType.math:
        return 'Solve the math problem';
      case QuestType.typeSentence:
        return 'Type the sentence';
      case QuestType.simon:
        return 'Beat 3 Simon rounds before time runs out';
      case QuestType.qr:
        return 'Scan your QR code';
      case QuestType.squat:
        return 'Walk ${widget.alarm.quest.squatCount} steps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isPreview,
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
            Text(
              widget.isPreview ? 'Preview mode' : 'Swipe up to unlock',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
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
              widget.alarm.label.isEmpty
                  ? (widget.isPreview ? 'Mission preview' : 'Alarm')
                  : widget.alarm.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            if (widget.alarm.quest.type != QuestType.none) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mission: ${_questInstruction()}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LockButton(
                  icon: widget.isPreview ? Icons.close : Icons.snooze,
                  label: widget.isPreview ? 'Close' : 'Snooze',
                  onTap: widget.isPreview ? () => Navigator.of(context).pop() : _snooze,
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.alarm.quest.type == QuestType.none) {
                      _dismiss();
                    } else {
                      _startMission();
                    }
                  },
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A020),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        widget.alarm.quest.type == QuestType.none
                            ? (widget.isPreview ? 'Close' : 'Dismiss')
                            : (widget.isPreview ? 'Start Preview' : 'Wake Up'),
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
              widget.alarm.label.isEmpty
                  ? (widget.isPreview ? 'Mission preview' : 'Alarm')
                  : widget.alarm.label,
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
            if (!widget.isPreview) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Alarm muted while solving • ${_missionTimeLeft}s before it rings again',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
            if (widget.isPreview) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close preview'),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(child: _buildQuestWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestWidget() {
    switch (widget.alarm.quest.type) {
      case QuestType.math:
        return MathQuest(
          difficulty: widget.alarm.quest.mathDifficulty,
          onSuccess: _dismiss,
        );
      case QuestType.typeSentence:
        return TypeQuest(
          sentence: widget.alarm.quest.sentence,
          onSuccess: _dismiss,
        );
      case QuestType.simon:
        return SimonQuest(
          gridSize: widget.alarm.quest.gridSize,
          onSuccess: _dismiss,
        );
      case QuestType.qr:
        return QrQuest(
          expectedValues: widget.alarm.quest.qrOptions.isEmpty
              ? [widget.alarm.quest.qrValue]
              : widget.alarm.quest.qrOptions,
          onSuccess: _dismiss,
        );
      case QuestType.squat:
        return SquatQuest(
          targetCount: widget.alarm.quest.squatCount,
          onSuccess: _dismiss,
        );
      case QuestType.none:
        return Center(
          child: ElevatedButton.icon(
            onPressed: _dismiss,
            icon: const Icon(Icons.alarm_off),
            label: Text(widget.isPreview ? 'Close' : 'Dismiss'),
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
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
