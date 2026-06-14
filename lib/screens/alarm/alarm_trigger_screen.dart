import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/alarm.dart';
import '../../models/quest_config.dart';
import '../../providers/notes_provider.dart';
import '../../providers/alarm_provider.dart';
import '../notes/note_editor_screen.dart';
import 'quests/math_quest.dart';
import 'quests/qr_quest.dart';
import 'quests/simon_quest.dart';
import 'quests/squat_quest.dart';
import 'quests/type_quest.dart';
import 'quests/pushup_quest.dart';
import 'quests/situp_quest.dart';

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
    if (!widget.isPreview) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (defaultTargetPlatform == TargetPlatform.android) {
        const MethodChannel('caqol/alarm_clock').invokeMethod('startLockTask').catchError((_) {});
      }
    }
  }

  @override
  void dispose() {
    if (!widget.isPreview) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (defaultTargetPlatform == TargetPlatform.android) {
        const MethodChannel('caqol/alarm_clock').invokeMethod('stopLockTask').catchError((_) {});
      }
    }
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
      final linkedNote = linkedNoteId == null 
          ? null 
          : ref.read(notesProvider).where((n) => n.id == linkedNoteId).firstOrNull;
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
    if (_missionTimeLeft < 60 && widget.alarm.quest.type == QuestType.simon) {
      _missionTimeLeft = 180; // Minimum 3 minutes for Simon Says
    }
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
      case QuestType.pushup:
        return 'Do ${widget.alarm.quest.squatCount} pushups';
      case QuestType.situp:
        return 'Do ${widget.alarm.quest.squatCount} situps';
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active, color: Color(0xFF00F0FF), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.isPreview ? 'PREVIEW MODE' : 'ALARM RINGING',
                    style: const TextStyle(
                      color: Color(0xFF00F0FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _timeString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -5,
                        height: 1,
                      ),
                    ),
                    Text(
                      _dateString,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      widget.alarm.label.isEmpty
                          ? 'Wake Up'
                          : widget.alarm.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    if (widget.alarm.quest.type != QuestType.none) ...[
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFF0066).withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF0066).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'MANDATORY QUEST',
                              style: TextStyle(
                                color: Color(0xFFFF0066),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _questInstruction(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.alarm.quest.type == QuestType.none || widget.isPreview)
                  GestureDetector(
                    onTap: widget.isPreview ? () => Navigator.of(context).pop() : _snooze,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isPreview ? Icons.close : Icons.snooze,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
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
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFF7B61FF)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.alarm.quest.type == QuestType.none
                            ? (widget.isPreview ? 'CLOSE' : 'DISMISS')
                            : (widget.isPreview ? 'START PREVIEW' : 'START QUEST'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
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
        if (kIsWeb) {
          return Center(
            child: ElevatedButton.icon(
              onPressed: _dismiss,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR not supported on Web - tap to dismiss'),
            ),
          );
        }
        return QrQuest(
          expectedValues: widget.alarm.quest.qrOptions.isEmpty
              ? [widget.alarm.quest.qrValue]
              : widget.alarm.quest.qrOptions,
          onSuccess: _dismiss,
        );
      case QuestType.squat:
        if (kIsWeb) {
          return Center(
            child: ElevatedButton.icon(
              onPressed: _dismiss,
              icon: const Icon(Icons.directions_walk),
              label: const Text('Sensors not supported on Web - tap to dismiss'),
            ),
          );
        }
        return SquatQuest(
          targetCount: widget.alarm.quest.squatCount,
          onSuccess: _dismiss,
        );
      case QuestType.pushup:
        return PushupQuest(
          targetCount: widget.alarm.quest.squatCount,
          onSuccess: _dismiss,
        );
      case QuestType.situp:
        return SitupQuest(
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
