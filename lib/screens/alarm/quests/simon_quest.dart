import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class SimonQuest extends StatefulWidget {
  final int gridSize;
  final int totalRounds;
  final VoidCallback onSuccess;

  const SimonQuest({
    super.key,
    required this.gridSize,
    this.totalRounds = 3,
    required this.onSuccess,
  });

  @override
  State<SimonQuest> createState() => _SimonQuestState();
}

class _SimonQuestState extends State<SimonQuest> with SingleTickerProviderStateMixin {
  late int _roundTimeLimit;
  final _rng = Random();
  late List<int> _sequence;
  late List<int> _userInput;
  int _highlightIndex = -1;
  int _pressedIndex = -1;
  int _round = 1;
  
  double _timeLeft = 0;
  bool _canTap = false;
  String _status = 'Watch the pattern';
  Timer? _countdownTimer;
  int _roundToken = 0;

  @override
  void initState() {
    super.initState();
    // Default 15 seconds for a 3x3 grid, adjust if larger.
    _roundTimeLimit = 10 + (widget.gridSize * 2);
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
    // Sequence length starts at 3, increases each round.
    final count = 2 + _round;
    _sequence = List.generate(count, (_) => _rng.nextInt(widget.gridSize * widget.gridSize));
    _userInput = [];
    _canTap = false;
    _timeLeft = _roundTimeLimit.toDouble();
    setState(() {
      _highlightIndex = -1;
      _pressedIndex = -1;
      _status = 'Round $_round of ${widget.totalRounds}: Watch carefully';
    });
    _showSequence(_roundToken);
  }

  Future<void> _showSequence(int token) async {
    // Wait a brief moment before starting
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || token != _roundToken) return;

    for (int i = 0; i < _sequence.length; i++) {
      setState(() => _highlightIndex = _sequence[i]);
      // The speed can be adjusted here, maybe faster as rounds go up
      await Future.delayed(Duration(milliseconds: max(250, 600 - (_round * 50))));
      if (!mounted || token != _roundToken) return;
      
      setState(() => _highlightIndex = -1);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted || token != _roundToken) return;
    }
    
    setState(() {
      _canTap = true;
      _status = 'Your turn!';
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    // Use 50ms ticks for a super smooth progress bar
    const tickMs = 50;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (!mounted || !_canTap) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft -= (tickMs / 1000);
      });

      if (_timeLeft <= 0) {
        timer.cancel();
        _failRound('Time is up!');
      }
    });
  }

  void _failRound(String reason) async {
    _canTap = false;
    _countdownTimer?.cancel();
    setState(() {
      _status = reason;
      _highlightIndex = -1;
    });
    // Flash red or show error
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _startRound();
    }
  }

  void _onTapBox(int index) {
    if (!_canTap) return;

    setState(() {
      _pressedIndex = index;
    });
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _pressedIndex = -1);
      }
    });

    _userInput.add(index);
    final currentIndex = _userInput.length - 1;

    if (_userInput[currentIndex] != _sequence[currentIndex]) {
      _failRound('Wrong box!');
      return;
    }

    if (_userInput.length == _sequence.length) {
      _canTap = false;
      _countdownTimer?.cancel();
      if (_round == widget.totalRounds) {
        setState(() => _status = 'Quest Complete!');
        widget.onSuccess();
      } else {
        setState(() {
          _status = 'Perfect! Next round...';
          _round++;
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _startRound();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_timeLeft / _roundTimeLimit).clamp(0.0, 1.0);
    
    return Column(
      children: [
        // Slim progress bar at the top
        Container(
          height: 6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white10,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progress > 0.3 
                    ? [AppTheme.neonCyan, Colors.blueAccent] 
                    : [AppTheme.danger, Colors.redAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (progress > 0.3 ? AppTheme.neonCyan : AppTheme.danger).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.gridSize,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: widget.gridSize * widget.gridSize,
                itemBuilder: (context, index) {
                  final isHighlighted = index == _highlightIndex;
                  final isPressed = index == _pressedIndex;
                  
                  return GestureDetector(
                    onTapDown: (_) => _onTapBox(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isHighlighted 
                          ? AppTheme.neonCyan 
                          : isPressed 
                            ? AppTheme.neonPink 
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHighlighted 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                        boxShadow: isHighlighted || isPressed
                            ? [
                                BoxShadow(
                                  color: (isHighlighted ? AppTheme.neonCyan : AppTheme.neonPink).withOpacity(0.6),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
