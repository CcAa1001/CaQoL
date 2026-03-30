import 'dart:math';
import 'package:flutter/material.dart';

class SimonQuest extends StatefulWidget {
  final int gridSize;
  final VoidCallback onSuccess;
  const SimonQuest({super.key, required this.gridSize, required this.onSuccess});

  @override
  State<SimonQuest> createState() => _SimonQuestState();
}

class _SimonQuestState extends State<SimonQuest> {
  late List<int> _sequence;
  late List<int> _userInput;
  int _highlightIndex = -1;
  bool _canTap = false;
  String _status = 'Watch the pattern...';

  @override
  void initState() {
    super.initState();
    _generateAndShow();
  }

  void _generateAndShow() {
    final rng = Random();
    final count = widget.gridSize + 2;
    _sequence = List.generate(count, (_) => rng.nextInt(widget.gridSize * widget.gridSize));
    _userInput = [];
    _canTap = false;
    setState(() => _status = 'Watch the pattern...');
    _showSequence();
  }

  Future<void> _showSequence() async {
    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _highlightIndex = _sequence[i]);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _highlightIndex = -1);
    }
    if (!mounted) return;
    setState(() {
      _canTap = true;
      _status = 'Now repeat the pattern!';
    });
  }

  void _onTap(int index) {
    if (!_canTap) return;
    final step = _userInput.length;
    if (_sequence[step] != index) {
      setState(() {
        _status = 'Wrong! Watch again...';
        _canTap = false;
        _userInput = [];
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _generateAndShow();
      });
      return;
    }
    _userInput.add(index);
    if (_userInput.length == _sequence.length) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.gridSize;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_status, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          _canTap ? '${_userInput.length} / ${_sequence.length}' : '',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: n,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: n * n,
            itemBuilder: (_, i) {
              final isLit = _highlightIndex == i;
              return GestureDetector(
                onTap: () => _onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isLit
                        ? Colors.deepPurple
                        : (_canTap ? Colors.white24 : Colors.white12),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isLit
                        ? [const BoxShadow(color: Colors.deepPurple, blurRadius: 12)]
                        : [],
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
