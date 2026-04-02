import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/note.dart';
import '../../models/sticky.dart';
import '../../models/sticky_board.dart';
import '../../providers/notes_provider.dart';
import '../../providers/stickies_provider.dart';
import '../../providers/sticky_boards_provider.dart';
import '../../services/auth_service.dart';
import '../../services/sticky_backup_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_sheet.dart';
import '../notes/note_editor_screen.dart';

List<StickyChecklistItem> _buildChecklistFromText(String text) {
  return text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map(
        (line) => StickyChecklistItem(
          id: DateTime.now().microsecondsSinceEpoch.toString() + line.hashCode.toString(),
          text: line,
        ),
      )
      .toList();
}

String _stickyPreviewText(Sticky sticky) {
  if (!sticky.checklistMode) {
    return sticky.body;
  }
  if (sticky.checklistItems.isEmpty) {
    return 'Checklist';
  }
  return sticky.checklistItems
      .map((item) => '${item.isDone ? '[x]' : '[ ]'} ${item.text}')
      .join('\n');
}

class StickiesScreen extends ConsumerStatefulWidget {
  const StickiesScreen({super.key});

  @override
  ConsumerState<StickiesScreen> createState() => _StickiesScreenState();
}

class _StickiesScreenState extends ConsumerState<StickiesScreen> {
  static const _colorOptions = [
    Colors.yellow,
    Colors.lightGreen,
    Colors.lightBlue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
  ];

  final _searchCtrl = TextEditingController();
  final _backupService = StickyBackupService();
  String? _currentBoardId;
  bool _reorderMode = false;
  bool _listView = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stickies = ref.watch(stickiesProvider);
    final boards = ref.watch(stickyBoardsProvider);
    final notes = ref.watch(notesProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final query = _searchCtrl.text.trim().toLowerCase();
    final currentBoard = _boardById(boards, _currentBoardId);

    final visibleBoards = query.isEmpty
        ? boards
        : boards.where((board) => board.name.toLowerCase().contains(query)).toList();
    final visibleStickies = stickies.where((sticky) {
      final matchesBoard = _currentBoardId == null || sticky.boardId == _currentBoardId;
      final boardName =
          _boardById(boards, sticky.boardId)?.name.toLowerCase() ?? '';
      final matchesQuery = query.isEmpty ||
          sticky.title.toLowerCase().contains(query) ||
          sticky.body.toLowerCase().contains(query) ||
          sticky.checklistItems.any(
            (item) => item.text.toLowerCase().contains(query),
          ) ||
          boardName.contains(query) ||
          (sticky.linkedNoteTitle ?? '').toLowerCase().contains(query);
      return matchesBoard && matchesQuery;
    }).toList();
    final boardStickyCount = _currentBoardId == null
        ? visibleStickies.length
        : stickies.where((sticky) => sticky.boardId == _currentBoardId).length;
    final pinnedCount = visibleStickies.where((sticky) => sticky.isPinned).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentBoard?.name ?? 'Sticky Notes'),
        actions: [
          IconButton(
            tooltip: 'Import backup',
            onPressed: () => _importBackup(context),
            icon: const Icon(Icons.upload_file_outlined),
          ),
          IconButton(
            tooltip: 'Export backup',
            onPressed: () => _exportBackup(context, boards, stickies),
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: _reorderMode ? 'Finish reorder' : 'Reorder',
            onPressed: query.isNotEmpty || _currentBoardId == null
                ? null
                : () => setState(() => _reorderMode = !_reorderMode),
            icon: Icon(_reorderMode ? Icons.done_all : Icons.reorder_rounded),
          ),
          IconButton(
            tooltip: _listView ? 'Grid view' : 'List view',
            onPressed: () => setState(() => _listView = !_listView),
            icon: Icon(
              _listView ? Icons.grid_view_rounded : Icons.view_agenda_rounded,
            ),
          ),
          if (user != null)
            IconButton(
              onPressed: () => showAccountSheet(context, ref, user),
              icon: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white10,
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? Text(
                        (user.displayName?.trim().isNotEmpty == true
                                ? user.displayName!.trim()[0]
                                : user.email?.trim().isNotEmpty == true
                                    ? user.email!.trim()[0]
                                    : 'U')
                            .toUpperCase(),
                        style: const TextStyle(fontSize: 11),
                      )
                    : null,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() => _reorderMode = false),
                  decoration: InputDecoration(
                    hintText: 'Search stickies or boards...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visibleBoards.length + 2,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _BoardChip(
                          label: 'All',
                          selected: _currentBoardId == null,
                          onTap: () => setState(() {
                            _currentBoardId = null;
                            _reorderMode = false;
                          }),
                        );
                      }
                      if (index == 1) {
                        return _BoardChip(
                          label: '+ Board',
                          selected: false,
                          onTap: () => _showBoardDialog(context),
                        );
                      }
                      final board = visibleBoards[index - 2];
                      return _BoardChip(
                        label: board.name,
                        selected: _currentBoardId == board.id,
                        onTap: () => setState(() {
                          _currentBoardId = board.id;
                          _reorderMode = false;
                        }),
                        onLongPress: () => _showBoardActions(board),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _reorderMode
                        ? 'Drag stickies to reorder them inside this board.'
                        : '${currentBoard?.name ?? 'All boards'} • $boardStickyCount visible • $pinnedCount pinned',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: visibleStickies.isEmpty
                ? const Center(
                    child: Text('No stickies yet. Tap + to add one.'),
                  )
                : _reorderMode
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: visibleStickies.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final reordered = [...visibleStickies];
                          final item = reordered.removeAt(oldIndex);
                          reordered.insert(newIndex, item);
                          await ref.read(stickiesProvider.notifier).reorder(
                                boardId: _currentBoardId,
                                orderedIds: reordered.map((sticky) => sticky.id).toList(),
                              );
                        },
                        itemBuilder: (context, i) {
                          final sticky = visibleStickies[i];
                          return Container(
                            key: ValueKey(sticky.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: _StickyListTile(
                              index: i,
                              sticky: sticky,
                              boardName: _boardById(boards, sticky.boardId)?.name,
                              onTap: () => _showStickyDetailSheet(
                                context,
                                sticky,
                                boards,
                                notes,
                              ),
                              onTogglePinned: () => ref
                                  .read(stickiesProvider.notifier)
                                  .togglePinned(sticky.id),
                            ),
                          );
                        },
                      )
                    : _listView
                        ? ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: visibleStickies.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final sticky = visibleStickies[i];
                              return _StickyCard(
                                sticky: sticky,
                                compact: false,
                                boardName: _boardById(boards, sticky.boardId)?.name,
                                onTap: () => _showStickyDetailSheet(
                                  context,
                                  sticky,
                                  boards,
                                  notes,
                                ),
                                onTogglePinned: () => ref
                                    .read(stickiesProvider.notifier)
                                    .togglePinned(sticky.id),
                              );
                            },
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int columns = 2;
                              if (constraints.maxWidth >= 1200) {
                                columns = 5;
                              } else if (constraints.maxWidth >= 900) {
                                columns = 4;
                              } else if (constraints.maxWidth >= 600) {
                                columns = 3;
                              }
                              final totalSpacing = 24 + ((columns - 1) * 10);
                              final cardWidth = (constraints.maxWidth - totalSpacing) / columns;
                              
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: visibleStickies.map((sticky) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: _StickyCard(
                                        sticky: sticky,
                                        compact: true,
                                        boardName: _boardById(boards, sticky.boardId)?.name,
                                        onTap: () => _showStickyDetailSheet(
                                          context,
                                          sticky,
                                          boards,
                                          notes,
                                        ),
                                        onTogglePinned: () => ref
                                            .read(stickiesProvider.notifier)
                                            .togglePinned(sticky.id),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStickyEditorSheet(
          context: context,
          boards: boards,
          notes: notes,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _exportBackup(
    BuildContext context,
    List<StickyBoard> boards,
    List<Sticky> stickies,
  ) async {
    try {
      final destination = await _backupService.exportAll(
        boards: boards,
        stickies: stickies,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stickies backup saved to $destination')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final payload = await _backupService.pickAndParse();
      if (payload == null) {
        return;
      }
      await ref.read(stickyBoardsProvider.notifier).importAll(payload.boards);
      await ref.read(stickiesProvider.notifier).importAll(payload.stickies);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${payload.boards.length} boards and ${payload.stickies.length} stickies.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    }
  }

  StickyBoard? _boardById(List<StickyBoard> boards, String? id) {
    if (id == null) return null;
    for (final board in boards) {
      if (board.id == id) return board;
    }
    return null;
  }

  Note? _noteById(List<Note> notes, String? id) {
    if (id == null) return null;
    for (final note in notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  Future<void> _showBoardDialog(BuildContext context, {StickyBoard? board}) async {
    final controller = TextEditingController(text: board?.name ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(board == null ? 'New board' : 'Rename board'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Board name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              if (board == null) {
                await ref.read(stickyBoardsProvider.notifier).add(name);
              } else {
                await ref.read(stickyBoardsProvider.notifier).update(
                      board.copyWith(name: name),
                    );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBoardActions(StickyBoard board) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename board'),
              onTap: () {
                Navigator.pop(context);
                _showBoardDialog(context, board: board);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('Pin all in board'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(stickiesProvider.notifier).pinAllInBoard(board.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist_rtl_outlined),
              title: const Text('Clear completed checklist items'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(stickiesProvider.notifier)
                    .clearCompletedChecklistItems(board.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete board'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(stickiesProvider.notifier).moveOutOfBoard(board.id);
                await ref.read(stickyBoardsProvider.notifier).delete(board.id);
                if (_currentBoardId == board.id && mounted) {
                  setState(() => _currentBoardId = null);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStickyEditorSheet({
    required BuildContext context,
    required List<StickyBoard> boards,
    required List<Note> notes,
    Sticky? sticky,
  }) async {
    final titleCtrl = TextEditingController(text: sticky?.title ?? '');
    final bodyCtrl = TextEditingController(text: sticky?.body ?? '');
    Color picked = sticky?.color ?? Colors.yellow;
    String? selectedBoardId = sticky?.boardId ?? _currentBoardId;
    bool isPinned = sticky?.isPinned ?? false;
    String size = sticky?.size ?? 'medium';
    bool checklistMode = sticky?.checklistMode ?? false;
    DateTime? expiresAt = sticky?.expiresAt;
    String? linkedNoteId = sticky?.linkedNoteId;
    String? linkedNoteTitle = sticky?.linkedNoteTitle;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.65,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sticky == null ? 'New sticky' : 'Edit sticky',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (sticky != null)
                    IconButton(
                      onPressed: () async {
                        await ref.read(stickiesProvider.notifier).delete(sticky.id);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Optional sticky title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                minLines: 10,
                maxLines: null,
                autofocus: sticky == null,
                decoration: const InputDecoration(
                  hintText: 'Write your sticky note...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: selectedBoardId,
                decoration: const InputDecoration(
                  labelText: 'Board',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('No board')),
                  ...boards.map(
                    (board) => DropdownMenuItem<String?>(
                      value: board.id,
                      child: Text(board.name),
                    ),
                  ),
                ],
                onChanged: (value) => setSheetState(() => selectedBoardId = value),
              ),
              const SizedBox(height: 16),
              const Text(
                'Linked note',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        linkedNoteTitle ?? 'No linked note',
                        style: const TextStyle(color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final note = await _showNotePickerForSticky(context, notes);
                        if (note == null) return;
                        setSheetState(() {
                          linkedNoteId = note.id;
                          linkedNoteTitle = note.title;
                        });
                      },
                      child: const Text('Choose'),
                    ),
                    if (linkedNoteId != null)
                      IconButton(
                        onPressed: () => setSheetState(() {
                          linkedNoteId = null;
                          linkedNoteTitle = null;
                        }),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Size',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['small', 'medium', 'large'].map((option) {
                  return _BoardChip(
                    label: option[0].toUpperCase() + option.substring(1),
                    selected: size == option,
                    onTap: () => setSheetState(() => size = option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Checklist mode'),
                subtitle: const Text(
                  'Turn each line into a tappable checkbox on the board.',
                ),
                value: checklistMode,
                onChanged: (value) => setSheetState(() => checklistMode = value),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expires'),
                subtitle: Text(
                  expiresAt == null
                      ? 'Never'
                      : '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year} ${expiresAt!.hour.toString().padLeft(2, '0')}:${expiresAt!.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => setSheetState(() => expiresAt = null),
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: expiresAt ?? now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 3650)),
                        );
                        if (date == null || !mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(expiresAt ?? now),
                        );
                        if (time == null) return;
                        setSheetState(() {
                          expiresAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                      child: const Text('Set'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pin sticky'),
                subtitle: const Text('Pinned stickies stay on top of the board.'),
                value: isPinned,
                onChanged: (value) => setSheetState(() => isPinned = value),
              ),
              const SizedBox(height: 8),
              const Text(
                'Color',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colorOptions.map((c) {
                  return GestureDetector(
                    onTap: () => setSheetState(() => picked = c),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: picked == c
                            ? Border.all(width: 3, color: Colors.black54)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final body = bodyCtrl.text.trim();
                  final nextChecklistItems = checklistMode
                      ? sticky != null &&
                              sticky.checklistMode &&
                              sticky.body.trim() == body
                          ? sticky.checklistItems
                          : _buildChecklistFromText(body)
                      : const <StickyChecklistItem>[];
                  if (title.isEmpty && body.isEmpty) return;
                  if (sticky == null) {
                    await ref.read(stickiesProvider.notifier).add(
                          title: title,
                          body: body,
                          color: picked,
                          boardId: selectedBoardId,
                          linkedNoteId: linkedNoteId,
                          linkedNoteTitle: linkedNoteTitle,
                          size: size,
                          checklistMode: checklistMode,
                          checklistItems: nextChecklistItems,
                          expiresAt: expiresAt,
                          isPinned: isPinned,
                        );
                  } else {
                    await ref.read(stickiesProvider.notifier).update(
                          sticky.copyWith(
                            title: title,
                            body: body,
                            color: picked,
                            boardId: selectedBoardId,
                            clearBoardId: selectedBoardId == null,
                            linkedNoteId: linkedNoteId,
                            linkedNoteTitle: linkedNoteTitle,
                            clearLinkedNoteId: linkedNoteId == null,
                            size: size,
                            checklistMode: checklistMode,
                            checklistItems: nextChecklistItems,
                            expiresAt: expiresAt,
                            clearExpiresAt: expiresAt == null,
                            isPinned: isPinned,
                          ),
                        );
                  }
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: Text(sticky == null ? 'Create sticky' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showStickyDetailSheet(
    BuildContext context,
    Sticky sticky,
    List<StickyBoard> boards,
    List<Note> notes,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sticky view',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showStickyEditorSheet(
                      context: context,
                      boards: boards,
                      notes: notes,
                      sticky: sticky,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: sticky.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sticky.title.trim().isEmpty ? 'Untitled sticky' : sticky.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sticky.checklistMode)
                    ...sticky.checklistItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () async {
                            await ref
                                .read(stickiesProvider.notifier)
                                .toggleChecklistItem(sticky.id, item.id);
                            if (sheetContext.mounted) {
                              Sticky refreshed = sticky;
                              for (final candidate in ref.read(stickiesProvider)) {
                                if (candidate.id == sticky.id) {
                                  refreshed = candidate;
                                  break;
                                }
                              }
                              Navigator.pop(sheetContext);
                              _showStickyDetailSheet(
                                context,
                                refreshed,
                                boards,
                                notes,
                              );
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                item.isDone
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: Colors.black87,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.text,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    height: 1.45,
                                    decoration: item.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SelectableText(
                      sticky.body,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        height: 1.45,
                      ),
                    ),
                ],
              ),
            ),
            if (sticky.linkedNoteId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sticky.linkedNoteTitle ?? 'Linked note',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final note = _noteById(notes, sticky.linkedNoteId);
                        if (note == null) return;
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteEditorScreen(note: note),
                          ),
                        );
                      },
                      child: const Text('Open note'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.dashboard_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _boardById(boards, sticky.boardId)?.name ?? 'No board',
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.aspect_ratio_rounded,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Size: ${sticky.size}',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.push_pin_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sticky.isPinned ? 'Pinned' : 'Not pinned',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  if (sticky.expiresAt != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expires ${sticky.expiresAt!.day}/${sticky.expiresAt!.month}/${sticky.expiresAt!.year}',
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showStickyEditorSheet(
                  context: context,
                  boards: boards,
                  notes: notes,
                  sticky: sticky,
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit sticky'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Note?> _showNotePickerForSticky(
    BuildContext context,
    List<Note> notes,
  ) async {
    return showModalBottomSheet<Note?>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final note = notes[index];
            return ListTile(
              tileColor: AppTheme.surfaceHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(note.title.isEmpty ? 'Untitled note' : note.title),
              subtitle: Text(
                note.body.isEmpty ? 'No content' : note.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.pop(context, note),
            );
          },
        ),
      ),
    );
  }
}

class _StickyListTile extends StatelessWidget {
  const _StickyListTile({
    required this.index,
    required this.sticky,
    required this.onTap,
    required this.onTogglePinned,
    this.boardName,
  });

  final int index;
  final Sticky sticky;
  final String? boardName;
  final VoidCallback onTap;
  final VoidCallback onTogglePinned;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: sticky.color,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: ReorderableDelayedDragStartListener(
          index: index,
          child: const Icon(Icons.drag_indicator_rounded, color: Colors.black54),
        ),
        title: Text(
          sticky.title.trim().isEmpty ? sticky.body : sticky.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          sticky.title.trim().isEmpty
              ? (boardName ?? 'No board')
              : '${boardName ?? 'No board'} • ${_stickyPreviewText(sticky)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          onPressed: onTogglePinned,
          icon: Icon(
            sticky.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _StickyCard extends StatelessWidget {
  const _StickyCard({
    required this.sticky,
    required this.compact,
    required this.onTap,
    required this.onTogglePinned,
    this.boardName,
  });

  final Sticky sticky;
  final bool compact;
  final String? boardName;
  final VoidCallback onTap;
  final VoidCallback onTogglePinned;

  int _lineCount() {
    switch (sticky.size) {
      case 'small':
        return compact ? 4 : 5;
      case 'large':
        return compact ? 12 : 18;
      default:
        return compact ? 7 : 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sticky.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (sticky.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.push_pin_rounded, size: 16, color: Colors.black54),
                  ),
                Expanded(
                  child: Text(
                    sticky.title.trim().isEmpty ? 'Untitled sticky' : sticky.title.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onTogglePinned,
                  child: Icon(
                    sticky.isPinned ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            if ((boardName ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                boardName!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _stickyPreviewText(sticky),
              maxLines: _lineCount(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            if (sticky.linkedNoteTitle?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        sticky.linkedNoteTitle!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (sticky.checklistMode || sticky.expiresAt != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (sticky.checklistMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${sticky.checklistItems.where((item) => item.isDone).length}/${sticky.checklistItems.length} done',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (sticky.expiresAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Expires ${sticky.expiresAt!.day}/${sticky.expiresAt!.month}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BoardChip extends StatelessWidget {
  const _BoardChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.14) : AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
