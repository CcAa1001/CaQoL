import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class SquatQuest extends StatefulWidget {
  final int targetCount;
  final VoidCallback onSuccess;

  const SquatQuest({
    super.key,
    required this.targetCount,
    required this.onSuccess,
  });

  @override
  State<SquatQuest> createState() => _SquatQuestState();
}

class _SquatQuestState extends State<SquatQuest> {
  static const _timeLimit = 120;

  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;
  Timer? _timer;

  int? _baselineSteps;
  int _stepsTaken = 0;
  int _timeLeft = _timeLimit;
  String _status = 'Waiting for step sensor...';
  String? _error;
  bool _hasPermission = false;
  bool _isCalibrating = true;
  bool _sensorReady = false;

  @override
  void initState() {
    super.initState();
    _prepareTracking();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() => _timeLeft = 0);
        return;
      }
      setState(() => _timeLeft -= 1);
    });
  }

  Future<void> _prepareTracking() async {
    final status = await Permission.activityRecognition.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _error = 'Activity recognition permission is required for step tracking.';
        _status = 'Permission needed';
        _hasPermission = false;
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _error = null;
      _status = 'Calibrating step sensor...';
      _isCalibrating = true;
    });
    await _initStepTracking();
  }

  Future<void> _initStepTracking() async {
    await _stepSubscription?.cancel();
    await _statusSubscription?.cancel();

    _stepSubscription = Pedometer.stepCountStream.listen(
      (event) {
        if (!mounted) return;

        final baseline = _baselineSteps ?? event.steps;
        final stepsTaken = (event.steps - baseline).clamp(0, 1000000);

        setState(() {
          _baselineSteps ??= event.steps;
          _stepsTaken = stepsTaken;
          _error = null;
          _sensorReady = true;
          _isCalibrating = false;
        });

        if (stepsTaken >= widget.targetCount) {
          widget.onSuccess();
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _error = 'Step sensor is unavailable on this device.';
          _status = 'Sensor unavailable';
          _sensorReady = false;
          _isCalibrating = false;
        });
      },
      cancelOnError: false,
    );

    _statusSubscription = Pedometer.pedestrianStatusStream.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _status = event.status == 'walking'
              ? 'Walking detected'
              : _sensorReady
                  ? 'Sensor ready, waiting for movement'
                  : 'Move a little to calibrate';
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _status = 'Move a little to start counting';
          _sensorReady = false;
        });
      },
      cancelOnError: false,
    );
  }

  Future<void> _resetCounter() async {
    await _stepSubscription?.cancel();
    await _statusSubscription?.cancel();
    if (!mounted) return;
    setState(() {
      _baselineSteps = null;
      _stepsTaken = 0;
      _error = null;
      _sensorReady = false;
      _isCalibrating = true;
      _status = 'Re-calibrating step sensor...';
    });
    await _initStepTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.targetCount == 0 ? 0.0 : _stepsTaken / widget.targetCount;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.targetCount} step challenge',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ??
                'Walk with your phone for live sensor counting. The first moments are used to calibrate the sensor.',
            style: TextStyle(
              color: _error == null ? Colors.white70 : Colors.redAccent,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0, 1),
                  strokeWidth: 14,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orangeAccent,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_stepsTaken / ${widget.targetCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isCalibrating
                          ? 'Calibrating... ${_timeLeft}s left'
                          : '${_timeLeft}s left',
                      style: TextStyle(
                        color:
                            _timeLeft <= 15 ? Colors.redAccent : Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!_hasPermission)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: _prepareTracking,
                child: const Text('Grant motion permission'),
              ),
            ),
          if (_hasPermission)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetCounter,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset counter'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _prepareTracking,
                    icon: const Icon(Icons.sensors),
                    label: const Text('Retry sensor'),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                const Text(
                  'Live movement status',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  _status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isCalibrating
                      ? 'Take a few steps so the mission can lock onto your starting point.'
                      : 'If counting looks wrong, use reset or retry sensor.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (_timeLeft == 0) ...[
            const SizedBox(height: 12),
            const Text(
              'Time ran out. Snooze if you need another round.',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}
