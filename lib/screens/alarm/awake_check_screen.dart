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
    final minutes = (_secondsLeft / 60).floor();
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.self_improvement_rounded,
                size: 56,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 18),
              const Text(
                'Awake Check',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You cleared ${widget.entry.alarmLabel}. Confirm you are still awake before the timer ends.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$minutes:$seconds remaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _confirmAwake,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('I\'m awake'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
