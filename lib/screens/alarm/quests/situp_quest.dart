import 'package:flutter/material.dart';

class SitupQuest extends StatefulWidget {
  final int targetCount;
  final VoidCallback onSuccess;

  const SitupQuest({
    super.key,
    required this.targetCount,
    required this.onSuccess,
  });

  @override
  State<SitupQuest> createState() => _SitupQuestState();
}

class _SitupQuestState extends State<SitupQuest> {
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.targetCount;
  }

  void _onTap() {
    if (_remaining > 0) {
      setState(() {
        _remaining--;
      });
      if (_remaining == 0) {
        widget.onSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Situp Punishment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Do a situp and tap the button.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent.withOpacity(0.2),
                border: Border.all(color: Colors.orangeAccent, width: 4),
              ),
              alignment: Alignment.center,
              child: Text(
                '$_remaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
