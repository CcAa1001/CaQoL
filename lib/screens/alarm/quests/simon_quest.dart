import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SimonQuest extends StatefulWidget {
  final int gridSize;
  final VoidCallback onSuccess;

  const SimonQuest({
    super.key,
    required this.gridSize,
    required this.onSuccess,
  });

  @override
  State<SimonQuest> createState() => _SimonQuestState();
}

class _SimonQuestState extends State<SimonQuest> {
  static const _totalRounds = 3;
  static const _roundTimeLimit = 12;

  final _rng = Random();
  late List<int> _sequence;
  late List<int> _userInput;
  int _highlightIndex = -1;
  int _pressedIndex = -1;
  int _round = 1;
  int _timeLeft = _roundTimeLimit;
  bool _canTap = false;
  bool _roundCompleted = false;
  String _status = 'Watch the pattern carefully';
  Timer? _countdownTimer;
  int _roundToken = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _roundToken += 1;
    _countdownTimer?.cancel();
    final count = widget.gridSize + _round;
    _sequence = List.generate(count, (_) => _rng.nextInt(widget.gridSize * widget.gridSize));
    _userInput = [];
    _canTap = false;
    _roundCompleted = false;
    _timeLeft = _roundTimeLimit;
    setState(() {
      _highlightIndex = -1;
      _pressedIndex = -1;
      _status = 'Round $_round of $_totalRounds: watch the pattern';
    });
    _showSequence(_roundToken);
  }

  Future<void> _showSequence(int token) async {
    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted || token != _roundToken) return;
      setState(() => _highlightIndex = _sequence[i]);
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted || token != _roundToken) return;
      setState(() => _highlightIndex = -1);
    }
    if (!mounted || token != _roundToken) return;
    setState(() {
      _canTap = true;
      _status = 'Your turn. Tap each box in order.';
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_canTap) {
        timer.cancel();
        return;
      }
      if (_timeLeft <= 1) {
        timer.cancel();
        _failRound('Time is up. Watch the next pattern.');
        return;
      }
      setState(() => _timeLeft -= 1);
    });
  }

  void _flashTapFeedback(int index) {
    setState(() => _pressedIndex = index);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted && _pressedIndex == index) {
        setState(() => _pressedIndex = -1);
      }
    });
  }

  void _failRound(String status) {
    setState(() {
      _status = status;
      _canTap = false;
      _highlightIndex = -1;
      _pressedIndex = -1;
      _userInput = [];
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _startRound();
    });
  }

  void _onTap(int index) {
    if (!_canTap) return;
    _flashTapFeedback(index);
    final step = _userInput.length;
    if (_sequence[step] != index) {
      _countdownTimer?.cancel();
      _failRound('Wrong circle. Let\'s retry that round.');
      return;
    }

    setState(() {
      _userInput.add(index);
    });

    if (_userInput.length == _sequence.length && !_roundCompleted) {
      _countdownTimer?.cancel();
      _roundCompleted = true;
      if (_round == _totalRounds) {
        widget.onSuccess();
        return;
      }
      setState(() {
        _status = 'Round $_round complete. Get ready for the next one.';
        _canTap = false;
        _highlightIndex = -1;
        _pressedIndex = -1;
        _round += 1;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _startRound();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.gridSize;
    final progress = _timeLeft / _roundTimeLimit;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Round $_round / $_totalRounds',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          _status,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _canTap ? progress : 1,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft <= 4 ? Colors.redAccent : Colors.orangeAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _canTap ? 'Progress ${_userInput.length}/${_sequence.length}  •  ${_timeLeft}s left' : 'Memorize first, then tap',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: n,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: n * n,
            itemBuilder: (_, i) {
              final isLit = _highlightIndex == i;
              final isPressed = _pressedIndex == i;
              return GestureDetector(
                onTap: () => _onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: isLit
                        ? Colors.orangeAccent
                        : isPressed
                            ? Colors.white
                            : (_canTap ? Colors.white24 : Colors.white12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPressed
                          ? Colors.orangeAccent
                          : (_canTap ? Colors.white24 : Colors.white10),
                      width: 2,
                    ),
                    boxShadow: isLit || isPressed
                        ? [
                            BoxShadow(
                              color: isLit ? Colors.orangeAccent.withOpacity(0.6) : Colors.white30,
                              blurRadius: 18,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 140),
                      opacity: isPressed ? 1 : 0.45,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isPressed ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

