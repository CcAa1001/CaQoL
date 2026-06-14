import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/awake_check_entry.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/awake_check_provider.dart';
import '../../theme/app_theme.dart';

class AwakeCheckScreen extends ConsumerStatefulWidget {
  const AwakeCheckScreen({super.key, required this.entry});

  final AwakeCheckEntry entry;

  @override
  ConsumerState<AwakeCheckScreen> createState() => _AwakeCheckScreenState();
}

class _AwakeCheckScreenState extends ConsumerState<AwakeCheckScreen> {
  Timer? _timer;
  late int _secondsLeft;
  bool _handlingTimeout = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.entry.expiresAt.difference(DateTime.now()).inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = widget.entry.expiresAt.difference(DateTime.now()).inSeconds;
      if (next <= 0) {
        _handleTimeout();
      } else {
        setState(() => _secondsLeft = next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleTimeout() async {
    if (_handlingTimeout) return;
    _handlingTimeout = true;
    _timer?.cancel();
    await ref.read(awakeCheckServiceProvider).complete(widget.entry);
    await ref.read(alarmProvider.notifier).failAwakeCheck(widget.entry.alarmId);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _confirmAwake() async {
    _timer?.cancel();
    await ref
        .read(awakeCheckServiceProvider)
        .complete(widget.entry, acknowledged: true);
    await ref.read(alarmProvider.notifier).completeAwakeCheck(widget.entry.alarmId);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsLeft / widget.entry.expiresAt.difference(widget.entry.createdAt).inSeconds;
    final minutes = (_secondsLeft / 60).floor();
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.self_improvement_rounded,
                    size: 72,
                    color: AppTheme.neonCyan,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Wake Consistency',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You cleared "${widget.entry.alarmLabel}".\nProve you are still awake before the timer ends.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 12,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _secondsLeft < 30 ? AppTheme.danger : AppTheme.neonCyan,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$minutes:$seconds',
                              style: TextStyle(
                                color: _secondsLeft < 30 ? AppTheme.danger : Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Remaining',
                              style: TextStyle(
                                color: _secondsLeft < 30 ? AppTheme.danger.withOpacity(0.8) : Colors.white60,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonCyan.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: FilledButton.icon(
                        onPressed: _confirmAwake,
                        icon: const Icon(Icons.check_circle_outline, size: 28),
                        label: const Text(
                          "I'm Awake",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.neonCyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
