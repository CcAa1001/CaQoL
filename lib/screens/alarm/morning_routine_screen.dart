import 'package:flutter/material.dart';

import '../../models/alarm.dart';
import '../../models/note.dart';
import '../../theme/app_theme.dart';
import '../notes/note_editor_screen.dart';

class MorningRoutineScreen extends StatefulWidget {
  const MorningRoutineScreen({
    super.key,
    required this.alarm,
    this.linkedNote,
  });

  final AlarmModel alarm;
  final Note? linkedNote;

  @override
  State<MorningRoutineScreen> createState() => _MorningRoutineScreenState();
}

class _MorningRoutineScreenState extends State<MorningRoutineScreen> {
  final Set<int> _done = <int>{};

  List<String> get _steps => [
        'Confirm you are out of bed',
        if (widget.linkedNote != null) 'Open linked note',
        'Pick the first task for today',
      ];

  @override
  Widget build(BuildContext context) {
    final complete = _done.length >= _steps.length;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Morning routine'),
        backgroundColor: AppTheme.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.alarm.label.isEmpty
                    ? 'Alarm ${widget.alarm.timeString}'
                    : widget.alarm.label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A short handoff from waking up to actually starting.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              ..._steps.asMap().entries.map((entry) {
                final index = entry.key;
                final checked = _done.contains(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() {
                      checked ? _done.remove(index) : _done.add(index);
                    }),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: checked
                              ? AppTheme.success.withOpacity(0.45)
                              : AppTheme.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            checked
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: checked
                                ? AppTheme.success
                                : AppTheme.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (widget.linkedNote != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NoteEditorScreen(note: widget.linkedNote),
                        ),
                      );
                    },
                    icon: const Icon(Icons.article_outlined),
                    label: Text(widget.linkedNote!.title.isEmpty
                        ? 'Open linked note'
                        : widget.linkedNote!.title),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      complete ? () => Navigator.pop(context) : null,
                  child: const Text('Start the day'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
