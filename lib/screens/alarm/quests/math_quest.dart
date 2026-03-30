import 'dart:math';
import 'package:flutter/material.dart';

class MathQuest extends StatefulWidget {
  final String difficulty;
  final VoidCallback onSuccess;
  const MathQuest({super.key, required this.difficulty, required this.onSuccess});

  @override
  State<MathQuest> createState() => _MathQuestState();
}

class _MathQuestState extends State<MathQuest> {
  late int _a, _b, _answer;
  late String _operator;
  final _ctrl = TextEditingController();
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final rng = Random();
    switch (widget.difficulty) {
      case 'hard':
        _a = rng.nextInt(50) + 10;
        _b = rng.nextInt(50) + 10;
        _operator = ['+', '-', '*'][rng.nextInt(3)];
        break;
      case 'medium':
        _a = rng.nextInt(20) + 5;
        _b = rng.nextInt(20) + 5;
        _operator = ['+', '-'][rng.nextInt(2)];
        break;
      default:
        _a = rng.nextInt(10) + 1;
        _b = rng.nextInt(10) + 1;
        _operator = '+';
    }
    switch (_operator) {
      case '+': _answer = _a + _b; break;
      case '-': _answer = _a - _b; break;
      case '*': _answer = _a * _b; break;
      default:  _answer = _a + _b;
    }
  }

  void _check() {
    if (int.tryParse(_ctrl.text) == _answer) {
      widget.onSuccess();
    } else {
      setState(() => _wrong = true);
      _ctrl.clear();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() {
          _wrong = false;
          _generate();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_a $_operator $_b = ?',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _wrong ? Colors.red : Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(fontSize: 32, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Your answer',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorText: _wrong ? 'Wrong! Try again...' : null,
            ),
            onSubmitted: (_) => _check(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _check,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
            child: const Text('Submit', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
