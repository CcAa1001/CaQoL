import 'package:flutter/material.dart';

class TypeQuest extends StatefulWidget {
  final String sentence;
  final VoidCallback onSuccess;
  const TypeQuest({super.key, required this.sentence, required this.onSuccess});

  @override
  State<TypeQuest> createState() => _TypeQuestState();
}

class _TypeQuestState extends State<TypeQuest> {
  final _ctrl = TextEditingController();
  bool _wrong = false;

  void _check() {
    if (_ctrl.text.trim() == widget.sentence.trim()) {
      widget.onSuccess();
    } else {
      setState(() => _wrong = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrong = false);
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.sentence,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type the sentence above...',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _wrong ? Colors.red : Colors.white,
                ),
              ),
              errorText: _wrong ? 'Not quite right, try again' : null,
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
