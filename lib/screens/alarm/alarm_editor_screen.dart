import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/alarm.dart';
import '../../models/note.dart';
import '../../models/quest_config.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/notes_provider.dart';
import '../../theme/app_theme.dart';
import 'alarm_trigger_screen.dart';
import 'quests/qr_quest.dart';

class AlarmEditorScreen extends ConsumerStatefulWidget {
  final AlarmModel? alarm;
  const AlarmEditorScreen({super.key, this.alarm});

  @override
  ConsumerState<AlarmEditorScreen> createState() => _AlarmEditorScreenState();
}

class _AlarmEditorScreenState extends ConsumerState<AlarmEditorScreen> {
  late TextEditingController _labelCtrl;
  late int _hour;
  late int _minute;
  late List<bool> _repeatDays;
  late QuestConfig _quest;
  late String _soundPath;
  String? _noteId;

  final _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final a = widget.alarm;
    final defaultMissionSeconds =
        ref.read(appSettingsProvider).defaultMissionSeconds;
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _hour = a?.hour ?? TimeOfDay.now().hour;
    _minute = a?.minute ?? TimeOfDay.now().minute;
    _repeatDays = a?.repeatDays ?? List.filled(7, false);
    _quest = a?.quest ?? QuestConfig(missionSeconds: defaultMissionSeconds);
    _soundPath = a?.soundPath ?? 'assets/alarm.mp3';
    _noteId = a?.noteId;
  }

  void _save() {
    final alarm = AlarmModel(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelCtrl.text,
      soundPath: _soundPath,
      noteId: _noteId,
      hour: _hour,
      minute: _minute,
      repeatDays: _repeatDays,
      isEnabled: widget.alarm?.isEnabled ?? true,
      quest: _quest,
    );
    if (widget.alarm == null) {
      ref.read(alarmProvider.notifier).add(alarm);
    } else {
      ref.read(alarmProvider.notifier).update(alarm);
    }
    Navigator.pop(context);
  }

  AlarmModel _previewAlarm() {
    return AlarmModel(
      id: widget.alarm?.id ?? 'preview',
      label: _labelCtrl.text,
      soundPath: _soundPath,
      noteId: _noteId,
      hour: _hour,
      minute: _minute,
      repeatDays: _repeatDays,
      isEnabled: true,
      quest: _quest,
    );
  }

  Future<void> _pickSound() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'ogg', 'm4a'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final source = File(path);
    if (!await source.exists()) return;

    final appDir = await getApplicationDocumentsDirectory();
    final alarmDir = Directory('${appDir.path}${Platform.pathSeparator}alarm_sounds');
    if (!await alarmDir.exists()) {
      await alarmDir.create(recursive: true);
    }

    final fileName = source.uri.pathSegments.isNotEmpty
        ? source.uri.pathSegments.last
        : 'alarm_sound.mp3';
    final targetPath = '${alarmDir.path}${Platform.pathSeparator}$fileName';
    await source.copy(targetPath);

    if (!mounted) return;
    setState(() => _soundPath = targetPath);
  }

  String get _soundLabel {
    if (_soundPath == 'assets/alarm.mp3') return 'Default sound';
    final normalized = _soundPath.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final linkedNote = notes.where((note) => note.id == _noteId).toList();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        title: Text(
          widget.alarm == null ? 'New alarm' : 'Edit alarm',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_quest.type != QuestType.none)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlarmTriggerScreen(
                    alarm: _previewAlarm(),
                    isPreview: true,
                  ),
                ),
              ),
              child: const Text(
                'Preview',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    looping: true,
                    scrollController: FixedExtentScrollController(initialItem: _hour),
                    itemExtent: 56,
                    onSelectedItemChanged: (v) => setState(() => _hour = v),
                    children: List.generate(24, (i) => Center(
                      child: Text(
                        i.toString().padLeft(2, '0'),
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w300),
                      ),
                    )),
                  ),
                ),
                const Text(':', style: TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w300)),
                Expanded(
                  child: CupertinoPicker(
                    looping: true,
                    scrollController: FixedExtentScrollController(initialItem: _minute),
                    itemExtent: 56,
                    onSelectedItemChanged: (v) => setState(() => _minute = v),
                    children: List.generate(60, (i) => Center(
                      child: Text(
                        i.toString().padLeft(2, '0'),
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w300),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _labelCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Alarm label (optional)',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.label_outline, color: AppTheme.textTertiary),
              ),
            ),
          ),
          const Divider(color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alarm sound', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note_outlined, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _soundLabel,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickSound,
                        child: const Text('Choose'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Open note after dismiss', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                const Text(
                  'Useful for opening a morning checklist, routine, or reminder note right after the alarm is cleared.',
                  style: TextStyle(color: AppTheme.textTertiary, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.article_outlined, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          linkedNote.isEmpty ? 'No note linked' : linkedNote.first.title,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final selected = await _showNotePicker(context, notes);
                          if (!mounted) return;
                          setState(() => _noteId = selected);
                        },
                        child: Text(linkedNote.isEmpty ? 'Choose' : 'Change'),
                      ),
                      if (_noteId != null)
                        IconButton(
                          onPressed: () => setState(() => _noteId = null),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Repeat', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => GestureDetector(
                    onTap: () => setState(() => _repeatDays[i] = !_repeatDays[i]),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _repeatDays[i] ? AppTheme.primary : AppTheme.surfaceHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _days[i],
                          style: TextStyle(
                            color: _repeatDays[i] ? Colors.black : AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wake-up mission', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                _QuestPickerSheet(
                  quest: _quest,
                  onChanged: (q) => setState(() => _quest = q),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showNotePicker(BuildContext context, List<Note> notes) async {
    return showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: notes.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                tileColor: AppTheme.surfaceHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                title: const Text('No linked note'),
                onTap: () => Navigator.pop(context, null),
              );
            }
            final note = notes[index - 1];
            return ListTile(
              tileColor: AppTheme.surfaceHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(note.title),
              subtitle: Text(
                note.body.isEmpty ? 'No content' : note.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.pop(context, note.id as String),
              
            );
          },
        ),
      ),
    );
  }
}

class _QuestPickerSheet extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _QuestPickerSheet({required this.quest, required this.onChanged});

  static const _quests = [
    (QuestType.none, Icons.block_outlined, 'No mission', ''),
    (QuestType.math, Icons.calculate_outlined, 'Math problem', 'Solve equations'),
    (QuestType.typeSentence, Icons.keyboard_outlined, 'Type sentence', 'Type a phrase'),
    (QuestType.simon, Icons.grid_on_outlined, 'Simon Says', 'Memory grid'),
    (QuestType.qr, Icons.qr_code_scanner_outlined, 'QR scan', 'Scan your code'),
    (QuestType.squat, Icons.directions_walk_outlined, 'Step challenge', 'Move with live step counting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: _quests.map((q) {
            final selected = quest.type == q.$1;
            return GestureDetector(
              onTap: () => onChanged(quest.copyWith(type: q.$1)),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.border,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(q.$2, color: selected ? AppTheme.primary : AppTheme.textSecondary, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      q.$3,
                      style: TextStyle(
                        color: selected ? AppTheme.primary : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (quest.type == QuestType.math) _MathConfig(quest: quest, onChanged: onChanged),
        if (quest.type == QuestType.typeSentence) _TypeConfig(quest: quest, onChanged: onChanged),
        if (quest.type == QuestType.simon) _SimonConfig(quest: quest, onChanged: onChanged),
        if (quest.type == QuestType.qr) _QrConfig(quest: quest, onChanged: onChanged),
        if (quest.type == QuestType.squat) _SquatConfig(quest: quest, onChanged: onChanged),
        if (quest.type != QuestType.none) _TimerConfig(quest: quest, onChanged: onChanged),
      ],
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ConfigCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MathConfig extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _MathConfig({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ConfigCard(
      title: 'Difficulty',
      child: Row(
        children: ['easy', 'medium', 'hard'].map((d) {
          final sel = quest.mathDifficulty == d;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(quest.copyWith(mathDifficulty: d)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d[0].toUpperCase() + d.substring(1),
                  style: TextStyle(
                    color: sel ? Colors.black : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TypeConfig extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _TypeConfig({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ConfigCard(
      title: 'Sentence to type',
      child: TextField(
        controller: TextEditingController(text: quest.sentence),
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: 'Enter your sentence...',
          hintStyle: TextStyle(color: AppTheme.textTertiary),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (v) => onChanged(quest.copyWith(sentence: v)),
      ),
    );
  }
}

class _SimonConfig extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _SimonConfig({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ConfigCard(
      title: 'Simon settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3, 4, 5].map((s) {
              final sel = quest.gridSize == s;
              return GestureDetector(
                onTap: () => onChanged(quest.copyWith(gridSize: s)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${s}×$s grid',
                    style: TextStyle(
                      color: sel ? Colors.black : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '3 rounds with a visible timer and clear tap feedback.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QrConfig extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _QrConfig({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ConfigCard(
      title: 'QR code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (quest.qrValue.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quest.qrValue,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final value = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => const QrScannerScreen(
                      title: 'Register QR code',
                      description: 'Scan the QR code that will be required to dismiss this alarm.',
                    ),
                  ),
                );
                if (value != null && value.isNotEmpty) {
                  onChanged(quest.copyWith(qrValue: value));
                }
              },
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(quest.qrValue.isEmpty ? 'Scan QR to register' : 'Re-scan QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceHigh,
                foregroundColor: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquatConfig extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _SquatConfig({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _ConfigCard(
      title: 'Number of steps',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [5, 10, 15, 20, 30].map((s) {
          final sel = quest.squatCount == s;
          return GestureDetector(
            onTap: () => onChanged(quest.copyWith(squatCount: s)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : AppTheme.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$s',
                style: TextStyle(
                  color: sel ? Colors.black : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimerConfig extends StatelessWidget {
  final QuestConfig quest;
  final ValueChanged<QuestConfig> onChanged;
  const _TimerConfig({required this.quest, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [10, 20, 30, 45, 60, 90];
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _ConfigCard(
        title: 'Task timer',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((seconds) {
            final selected = quest.missionSeconds == seconds;
            return GestureDetector(
              onTap: () => onChanged(quest.copyWith(missionSeconds: seconds)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${seconds}s',
                  style: TextStyle(
                    color: selected ? Colors.black : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
