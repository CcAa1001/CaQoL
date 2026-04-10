import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../models/note_folder.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/note_folders_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/stickies_provider.dart';
import '../../services/note_links_service.dart';
import '../../theme/app_theme.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final String? initialFolderId;
  final bool isEmbedded;
  final ValueChanged<String>? onSaved;
  const NoteEditorScreen({
    super.key,
    this.note,
    this.initialFolderId,
    this.isEmbedded = false,
    this.onSaved,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => NoteEditorScreenState();
}

class NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  static final _attachmentTokenPattern =
      RegExp(r'\[\[attachment:([^\|\]]+)\|([^\]]+)\]\]');
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  late TextEditingController _tagsCtrl;
  final _bodyScrollController = ScrollController();
  final _linksService = NoteLinksService();
  String? _selectedFolderId;
  bool _isFavorite = false;
  bool _previewMode = false;
  bool _showOrganizer = true;
  bool _showTools = true;
  bool _showReferences = false;
  bool _showComments = false;
  bool _showAttachments = false;
  bool _focusMode = false;
  final _searchCtrl = TextEditingController();
  final _bodyFocusNode = FocusNode();
  int _searchIndex = -1;
  List<(int, int)> _searchMatches = const [];
  
  bool _isDirty = false;
  bool get isDirty => _isDirty;
  
  Future<void> save() async {
    await _saveAndPop(isClosing: false);
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.note?.body ?? '');
    _tagsCtrl = TextEditingController(text: (widget.note?.tags ?? const []).join(', '));
    _selectedFolderId = widget.note?.folderId ?? widget.initialFolderId;
    _isFavorite = widget.note?.isFavorite ?? false;
    final settings = ref.read(appSettingsProvider);
    _showTools = !settings.noteEditorCollapsedTools;
    _bodyFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _titleCtrl.addListener(_markDirty);
    _bodyCtrl.addListener(_markDirty);
    _tagsCtrl.addListener(_markDirty);
  }

  @override
  void didUpdateWidget(NoteEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note?.id != oldWidget.note?.id || widget.initialFolderId != oldWidget.initialFolderId) {
      _titleCtrl.text = widget.note?.title ?? '';
      _bodyCtrl.text = widget.note?.body ?? '';
      _tagsCtrl.text = (widget.note?.tags ?? const []).join(', ');
      _selectedFolderId = widget.note?.folderId ?? widget.initialFolderId;
      _isFavorite = widget.note?.isFavorite ?? false;
      _isDirty = false;
    }
  }

  void _markDirty() {
    if (!_isDirty) {
      _isDirty = true;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _tagsCtrl.dispose();
    _searchCtrl.dispose();
    _bodyFocusNode.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  Future<void> _saveAndPop({bool isClosing = true}) async {
    final title = _titleCtrl.text;
    final body = _bodyCtrl.text;
    final tags = _tagsCtrl.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    String? savedNoteId;
    if (title.isNotEmpty || body.isNotEmpty) {
      final notifier = ref.read(notesProvider.notifier);
      if (widget.note == null) {
        final created = await notifier.add(
          title,
          body,
          folderId: _selectedFolderId,
          isFavorite: _isFavorite,
          tags: tags,
        );
        savedNoteId = created.id;
      } else {
        final current = _findActiveNote(ref.read(notesProvider)) ?? widget.note!;
        final updated = current.copyWith(
          title: title,
          body: body,
          folderId: _selectedFolderId,
          clearFolderId: _selectedFolderId == null,
          isFavorite: _isFavorite,
          tags: tags,
        );
        await notifier.update(
          updated,
        );
        savedNoteId = updated.id;
      }
    } else if (widget.note != null) {
      savedNoteId = widget.note!.id;
    }

    if (savedNoteId != null) {
      widget.onSaved?.call(savedNoteId);
    }
    
    _isDirty = false;

    if (!isClosing) return;

    if (widget.isEmbedded) {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(noteFoldersProvider);
    final notes = ref.watch(notesProvider);
    final activeNote = _findActiveNote(notes);
    final linkedNotes = _linksService.parse(_bodyCtrl.text, notes: notes);
    final currentNote = activeNote;
    final backlinks = currentNote == null
        ? const <Note>[]
        : _linksService.backlinksFor(currentNote, notes);
    final comments = activeNote?.comments ?? const <NoteComment>[];
    final attachments = activeNote?.attachments ?? const <NoteAttachment>[];
    final focusWidth = (!kIsWeb && MediaQuery.of(context).size.width < 700)
        ? double.infinity
        : 760.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndPop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            _focusMode
                ? (widget.note == null ? 'Draft Mode' : 'Focus Mode')
                : (widget.note == null ? 'New Note' : 'Edit Note'),
          ),
          automaticallyImplyLeading: !widget.isEmbedded,
          leading: widget.isEmbedded
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _saveAndPop,
                ),
          actions: [
            IconButton(
              icon: Icon(
                _focusMode ? Icons.center_focus_strong : Icons.article_outlined,
              ),
              tooltip: _focusMode ? 'Exit focus mode' : 'Enter focus mode',
              onPressed: () => setState(() => _focusMode = !_focusMode),
            ),
            IconButton(
              icon: Icon(
                _previewMode ? Icons.edit_outlined : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _previewMode = !_previewMode),
            ),
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showNoteOptionsSheet(
                context,
                folders: folders,
                notes: notes,
                comments: comments,
                attachments: attachments,
                backlinks: backlinks,
                linkedNotes: linkedNotes,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveAndPop,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 20,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: focusWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      TextField(
                        controller: _titleCtrl,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _bodyCtrl,
                              builder: (context, _) => Text(
                                _metaLine(activeNote),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_focusMode)
                            AnimatedBuilder(
                              animation: _bodyCtrl,
                              builder: (context, _) => Text(
                                _draftStats(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!_focusMode && _searchCtrl.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _searchMatches.isEmpty
                              ? 'No matches'
                              : 'Match ${_searchIndex + 1} of ${_searchMatches.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (!_focusMode &&
                          (_selectedFolderId != null ||
                          _tagsCtrl.text.trim().isNotEmpty ||
                          _isFavorite)) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_selectedFolderId != null)
                              _MetaChip(
                                icon: Icons.folder_outlined,
                                label: _folderNameForId(folders, _selectedFolderId!) ?? 'Folder',
                              ),
                            for (final tag in _currentTags())
                              _MetaChip(
                                icon: Icons.sell_outlined,
                                label: tag,
                              ),
                            if (_isFavorite)
                              const _MetaChip(
                                icon: Icons.star_rounded,
                                label: 'Favorite',
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _previewMode
                            ? Container(
                                key: const ValueKey('preview'),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                constraints: const BoxConstraints(minHeight: 360),
                                child: _FormattedNotePreview(
                                  text: _bodyCtrl.text,
                                  linksService: _linksService,
                                  notes: notes,
                                  attachments: attachments,
                                  onOpenNote: (note) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NoteEditorScreen(note: note),
                                      ),
                                    );
                                  },
                                  onOpenAttachment: _showAttachmentDetails,
                                ),
                              )
                            : TextField(
                                key: const ValueKey('editor'),
                                focusNode: _bodyFocusNode,
                                controller: _bodyCtrl,
                                scrollController: _bodyScrollController,
                                minLines: 18,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                scrollPadding: const EdgeInsets.only(bottom: 260),
                                contextMenuBuilder: (context, editableTextState) =>
                                    _buildBodyContextMenu(
                                  context,
                                  editableTextState,
                                  notes,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.45,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Start typing',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      if (!_focusMode && linkedNotes.isNotEmpty)
                        _InlineSection(
                          title: 'Linked notes',
                          child: _LinkSection(
                            title: '',
                            links: linkedNotes,
                            notes: notes,
                          ),
                        ),
                      if (!_focusMode && backlinks.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _InlineSection(
                          title: 'Linked from',
                          child: _BacklinkSection(notes: backlinks),
                        ),
                      ],
                      if (!_focusMode && comments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _InlineSection(
                          title: 'Comments',
                          child: Column(
                            children: comments
                                .map(
                                  (comment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _CommentTile(comment: comment),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      if (!_focusMode && attachments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _InlineSection(
                          title: 'Attachments',
                          child: Column(
                            children: attachments
                                .map(
                                  (attachment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _AttachmentTile(attachment: attachment),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_focusMode)
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: focusWidth),
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _bodyCtrl,
                            builder: (context, _) => Text(
                              _draftStats(),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Distraction-free drafting',
                            style: TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_bodyFocusNode.hasFocus && !_previewMode)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: _QuickActionBar(
                    key: const ValueKey('quick-tools'),
                    onBold: () => _wrapSelection('**', '**'),
                    onItalic: () => _wrapSelection('*', '*'),
                    onHighlight: () => _wrapSelection('==', '=='),
                    onChecklist: () => _applyBlockPrefix('- [ ] '),
                    onQuote: () => _applyBlockPrefix('> '),
                    onLinkNote: () => _showLinkPicker(context, notes),
                    onSendToBoard: _sendSelectionToBoard,
                    onComment: _addCommentFromSelection,
                    onAttachment: _addAttachment,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Note? _findActiveNote(List<Note> notes) {
    final original = widget.note;
    if (original == null) return null;
    for (final note in notes) {
      if (note.id == original.id) return note;
    }
    return original;
  }

  String _metaLine(Note? activeNote) {
    final updated = activeNote?.updatedAt ?? DateTime.now();
    final hour = updated.hour % 12 == 0 ? 12 : updated.hour % 12;
    final minute = updated.minute.toString().padLeft(2, '0');
    final suffix = updated.hour >= 12 ? 'PM' : 'AM';
    final charCount = _bodyCtrl.text.characters.length;
    return '${updated.day}/${updated.month}/${updated.year} $hour:$minute $suffix • $charCount characters';
  }

  List<String> _currentTags() {
    return _tagsCtrl.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  String _draftStats() {
    final text = '${_titleCtrl.text}\n${_bodyCtrl.text}'.trim();
    final words = RegExp(r'\S+').allMatches(text).length;
    final characters = text.characters.length;
    return '$words words | $characters chars';
  }

  String? _folderNameForId(List<NoteFolder> folders, String id) {
    for (final folder in folders) {
      if (folder.id == id) return _folderLabel(folder, folders);
    }
    return null;
  }

  Future<void> _showNoteOptionsSheet(
    BuildContext context, {
    required List<NoteFolder> folders,
    required List<Note> notes,
    required List<NoteComment> comments,
    required List<NoteAttachment> attachments,
    required List<Note> backlinks,
    required List<NoteLink> linkedNotes,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _selectedFolderId,
                  decoration: const InputDecoration(
                    labelText: 'Folder',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Root'),
                    ),
                    ...folders.map(
                      (folder) => DropdownMenuItem<String?>(
                        value: folder.id,
                        child: Text(_folderLabel(folder, folders)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFolderId = value);
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'tag1, tag2, tag3',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) {
                    setState(() {
                      _searchMatches = _findMatches(_searchCtrl.text);
                      _searchIndex = _searchMatches.isEmpty ? -1 : 0;
                    });
                    setSheetState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Find in note',
                    hintText: 'Search text...',
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : Wrap(
                            children: [
                              IconButton(
                                onPressed: _searchMatches.isEmpty
                                    ? null
                                    : () => _jumpToSearchMatch(-1),
                                icon: const Icon(Icons.keyboard_arrow_up),
                              ),
                              IconButton(
                                onPressed: _searchMatches.isEmpty
                                    ? null
                                    : () => _jumpToSearchMatch(1),
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showLinkPicker(context, notes);
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Link note'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _sendSelectionToBoard();
                      },
                      icon: const Icon(Icons.sticky_note_2_outlined),
                      label: const Text('Send to board'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _addCommentFromSelection();
                      },
                      icon: const Icon(Icons.add_comment_outlined),
                      label: const Text('Add comment'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _addAttachment();
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Add attachment'),
                    ),
                  ],
                ),
                if (linkedNotes.isNotEmpty || backlinks.isNotEmpty || comments.isNotEmpty || attachments.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'This note has ${linkedNotes.length} outgoing links, ${backlinks.length} backlinks, ${comments.length} comments, and ${attachments.length} attachments.',
                    style: const TextStyle(color: Colors.grey, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _folderLabel(NoteFolder folder, List<NoteFolder> allFolders) {
    final names = <String>[folder.name];
    var currentParentId = folder.parentId;

    while (currentParentId != null) {
      NoteFolder? parent;
      for (final item in allFolders) {
        if (item.id == currentParentId) {
          parent = item;
          break;
        }
      }
      if (parent == null) {
        break;
      }
      names.insert(0, parent.name);
      currentParentId = parent.parentId;
    }

    return names.join(' / ');
  }

  Future<void> _showLinkPicker(BuildContext context, List<Note> notes) async {
    final candidates = notes.where((note) => note.id != widget.note?.id).toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: candidates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final note = candidates[index];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              title: Text(note.title),
              subtitle: Text(
                _linksService.plainText(note.body).trim().isEmpty
                    ? 'No content'
                    : _linksService.plainText(note.body),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                _insertLinkAtSelection(note);
                Navigator.pop(context);
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendSelectionToBoard() async {
    final range = _normalizedSelectionRange(_bodyCtrl.selection, _bodyCtrl.text.length);
    final selectedText = range.$1 == range.$2
        ? ''
        : _bodyCtrl.text.substring(range.$1, range.$2).trim();
    if (selectedText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlight some text first.')),
        );
      }
      return;
    }

    final settings = ref.read(appSettingsProvider);
    final current = _findActiveNote(ref.read(notesProvider));
    final stickyTitle = selectedText.length > 40
        ? '${selectedText.substring(0, 40).trim()}...'
        : selectedText;
    await ref.read(stickiesProvider.notifier).add(
          title: stickyTitle,
          body: selectedText,
          boardId: settings.defaultStickyBoardId,
          linkedNoteId: current?.id,
          linkedNoteTitle: current?.title,
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selection sent to Stickies board.')),
    );
  }

  void _wrapSelection(String before, String after) {
    final text = _bodyCtrl.text;
    final range = _normalizedSelectionRange(_bodyCtrl.selection, text.length);
    final start = range.$1;
    final end = range.$2;
    final selected = text.substring(start, end);
    final replacement = '$before$selected$after';
    final updated = text.replaceRange(start, end, replacement);
    final selection = selected.isEmpty
        ? TextSelection.collapsed(offset: start + before.length)
        : TextSelection(
            baseOffset: start + before.length,
            extentOffset: start + before.length + selected.length,
          );
    _bodyCtrl.value = TextEditingValue(
      text: updated,
      selection: selection,
    );
    _bodyFocusNode.requestFocus();
    setState(() {});
  }

  void _applyBlockPrefix(String prefix) {
    final text = _bodyCtrl.text;
    final range = _normalizedSelectionRange(_bodyCtrl.selection, text.length);
    final start = range.$1;
    final end = range.$2;
    final selected = text.substring(start, end);
    final lines = (selected.isEmpty ? '' : selected).split('\n');
    final replacement = lines.map((line) => '$prefix$line').join('\n');
    final updated = text.replaceRange(start, end, replacement);
    final selection = selected.isEmpty
        ? TextSelection.collapsed(offset: start + prefix.length)
        : TextSelection(
            baseOffset: start,
            extentOffset: start + replacement.length,
          );
    _bodyCtrl.value = TextEditingValue(
      text: updated,
      selection: selection,
    );
    _bodyFocusNode.requestFocus();
    setState(() {});
  }

  (int, int) _normalizedSelectionRange(TextSelection selection, int textLength) {
    var start = selection.start;
    var end = selection.end;
    if (start < 0) start = textLength;
    if (end < 0) end = textLength;
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }
    start = start.clamp(0, textLength);
    end = end.clamp(0, textLength);
    return (start, end);
  }

  void _insertLinkAtSelection(Note note) {
    final text = _bodyCtrl.text;
    final range = _normalizedSelectionRange(_bodyCtrl.selection, text.length);
    final token = _linksService.insertLink('', note).trim();
    final updated = text.replaceRange(range.$1, range.$2, token);
    final offset = range.$1 + token.length;
    _bodyCtrl.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: offset),
    );
    _bodyFocusNode.requestFocus();
  }

  void _insertAttachmentAtSelection(NoteAttachment attachment) {
    final text = _bodyCtrl.text;
    final range = _normalizedSelectionRange(_bodyCtrl.selection, text.length);
    final token = '[[attachment:${attachment.id}|${attachment.name}]]';
    final updated = text.replaceRange(range.$1, range.$2, token);
    final offset = range.$1 + token.length;
    _bodyCtrl.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: offset),
    );
    _bodyFocusNode.requestFocus();
    setState(() {});
  }

  Widget _buildBodyContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
    List<Note> notes,
  ) {
    final items = <ContextMenuButtonItem>[
      ...editableTextState.contextMenuButtonItems,
      ContextMenuButtonItem(
        label: 'Bold',
        onPressed: () {
          editableTextState.hideToolbar();
          _wrapSelection('**', '**');
        },
      ),
      ContextMenuButtonItem(
        label: 'Italic',
        onPressed: () {
          editableTextState.hideToolbar();
          _wrapSelection('*', '*');
        },
      ),
      ContextMenuButtonItem(
        label: 'Highlight',
        onPressed: () {
          editableTextState.hideToolbar();
          _wrapSelection('==', '==');
        },
      ),
      ContextMenuButtonItem(
        label: 'Link note',
        onPressed: () async {
          editableTextState.hideToolbar();
          await _showLinkPicker(context, notes);
        },
      ),
      ContextMenuButtonItem(
        label: 'Send to board',
        onPressed: () {
          editableTextState.hideToolbar();
          _sendSelectionToBoard();
        },
      ),
      ContextMenuButtonItem(
        label: 'Comment',
        onPressed: () {
          editableTextState.hideToolbar();
          _addCommentFromSelection();
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  List<(int, int)> _findMatches(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final text = _bodyCtrl.text.toLowerCase();
    final needle = trimmed.toLowerCase();
    final matches = <(int, int)>[];
    var start = 0;
    while (true) {
      final index = text.indexOf(needle, start);
      if (index == -1) break;
      matches.add((index, index + needle.length));
      start = index + needle.length;
    }
    return matches;
  }

  void _jumpToSearchMatch(int delta) {
    if (_searchMatches.isEmpty) return;
    final nextIndex =
        (_searchIndex + delta) % _searchMatches.length;
    final normalized =
        nextIndex < 0 ? _searchMatches.length - 1 : nextIndex;
    final match = _searchMatches[normalized];
    _bodyFocusNode.requestFocus();
    _bodyCtrl.selection = TextSelection(baseOffset: match.$1, extentOffset: match.$2);
    setState(() => _searchIndex = normalized);
  }

  Future<void> _addCommentFromSelection() async {
    final range = _normalizedSelectionRange(_bodyCtrl.selection, _bodyCtrl.text.length);
    final quotedText = range.$1 == range.$2
        ? ''
        : _bodyCtrl.text.substring(range.$1, range.$2);
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (quotedText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  quotedText,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: null,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Write your comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final comment = NoteComment(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                text: text,
                quotedText: quotedText,
                createdAt: DateTime.now(),
              );
              final current = _findActiveNote(ref.read(notesProvider));
              if (current != null) {
                ref.read(notesProvider.notifier).update(
                      current.copyWith(
                        comments: [...current.comments, comment],
                      ),
                    );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    final file = result?.files.single;
    final current = _findActiveNote(ref.read(notesProvider));
    if (file == null || current == null) return;
    final attachment = NoteAttachment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: file.name,
      path: file.path ?? file.name,
      type: file.extension ?? 'file',
      createdAt: DateTime.now(),
    );
    await ref.read(notesProvider.notifier).update(
          current.copyWith(
            attachments: [...current.attachments, attachment],
          ),
        );
    _insertAttachmentAtSelection(attachment);
  }

  Future<void> _showAttachmentDetails(NoteAttachment attachment) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attachment.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${attachment.type}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              if (_canPreviewImageInline(attachment)) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    attachment.path,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Image preview is not available for this attachment path.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SelectableText(
                attachment.path,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: attachment.path),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Attachment path copied'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copy path'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canPreviewImageInline(NoteAttachment attachment) {
    final path = attachment.path.toLowerCase();
    final imageType = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'];
    return kIsWeb &&
        (path.startsWith('http://') || path.startsWith('https://')) &&
        imageType.any((ext) => path.endsWith('.$ext'));
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

class _FormattedNotePreview extends StatelessWidget {
  const _FormattedNotePreview({
    required this.text,
    required this.linksService,
    required this.notes,
    required this.attachments,
    required this.onOpenNote,
    required this.onOpenAttachment,
  });

  final String text;
  final NoteLinksService linksService;
  final List<Note> notes;
  final List<NoteAttachment> attachments;
  final ValueChanged<Note> onOpenNote;
  final ValueChanged<NoteAttachment> onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final source = text.trimRight();
    if (source.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Text(
          'Preview will appear here as you write.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final lines = source.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(context, line)).toList(),
    );
  }

  Widget _buildLine(BuildContext context, String line) {
    final trimmed = line.trimRight();
    if (trimmed.isEmpty) {
      return const SizedBox(height: 12);
    }

    if (trimmed.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headlineSmall ??
              const TextStyle(fontSize: 24),
          child: _inlineRich(context, trimmed.substring(2)),
        ),
      );
    }

    if (trimmed.startsWith('> ')) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        child: _inlineRich(context, trimmed.substring(2)),
      );
    }

    if (trimmed.startsWith('- [ ] ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 10),
              child: Icon(Icons.check_box_outline_blank_rounded, size: 18),
            ),
            Expanded(child: _inlineRich(context, trimmed.substring(6))),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _inlineRich(context, trimmed),
    );
  }

  Widget _inlineRich(BuildContext context, String raw) {
    final spans = _spansForText(context, raw);
    if (spans.isEmpty) {
      return const SizedBox.shrink();
    }
    return RichText(
      text: TextSpan(
        style:
            Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
        children: spans,
      ),
    );
  }

  List<InlineSpan> _spansForText(BuildContext context, String raw) {
    if (raw.isEmpty) {
      return const [];
    }
    final defaultStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final spans = <InlineSpan>[];
    final tokenPattern = RegExp(
      r'(\[\[note:[^\]]+\]\]|\[\[attachment:[^\]]+\]\]|\[\[[^\[\]\|]+\]\])',
    );
    var cursor = 0;

    for (final match in tokenPattern.allMatches(raw)) {
      if (match.start > cursor) {
        spans.addAll(
          _styledTextSpans(
            raw.substring(cursor, match.start),
            defaultStyle,
          ),
        );
      }
      final token = match.group(0)!;
      if (token.startsWith('[[note:')) {
        final match = RegExp(r'\[\[note:([^\|\]]+)\|([^\]]+)\]\]').firstMatch(token);
        final noteId = match?.group(1);
        final title = match?.group(2) ?? 'Linked note';
        Note? note;
        for (final item in notes) {
          if (item.id == noteId) {
            note = item;
            break;
          }
        }
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: const Icon(Icons.link, size: 16),
                label: Text(title),
                onPressed: note == null
                    ? null
                    : () {
                        final resolvedNote = note;
                        if (resolvedNote != null) {
                          onOpenNote(resolvedNote);
                        }
                      },
              ),
            ),
          ),
        );
      } else if (token.startsWith('[[attachment:')) {
        final match = RegExp(r'\[\[attachment:([^\|\]]+)\|([^\]]+)\]\]')
            .firstMatch(token);
        final attachmentId = match?.group(1);
        final title = match?.group(2) ?? 'Attachment';
        NoteAttachment? attachment;
        for (final item in attachments) {
          if (item.id == attachmentId) {
            attachment = item;
            break;
          }
        }
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: const Icon(Icons.attach_file, size: 16),
                label: Text(title),
                onPressed: attachment == null
                    ? null
                    : () {
                        final resolvedAttachment = attachment;
                        if (resolvedAttachment != null) {
                          onOpenAttachment(resolvedAttachment);
                        }
                      },
              ),
            ),
          ),
        );
      } else {
        final title = token.substring(2, token.length - 2).trim();
        Note? note;
        for (final item in notes) {
          if (item.title.trim().toLowerCase() == title.toLowerCase()) {
            note = item;
            break;
          }
        }
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: const Icon(Icons.auto_awesome_motion, size: 16),
                label: Text(title),
                onPressed: note == null
                    ? null
                    : () {
                        final resolvedNote = note;
                        if (resolvedNote != null) {
                          onOpenNote(resolvedNote);
                        }
                      },
              ),
            ),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < raw.length) {
      spans.addAll(
        _styledTextSpans(
          raw.substring(cursor),
          defaultStyle,
        ),
      );
    }
    return spans;
  }

  List<InlineSpan> _styledTextSpans(String text, TextStyle defaultStyle) {
    if (text.isEmpty) return const [];
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(\*\*.*?\*\*|\*.*?\*|==.*?==)');
    var cursor = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: linksService.plainText(text.substring(cursor, match.start)),
        ));
      }
      final token = match.group(0)!;
      if (token.startsWith('**') && token.endsWith('**')) {
        if (token.length <= 4) {
          spans.add(TextSpan(text: token));
          cursor = match.end;
          continue;
        }
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: defaultStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (token.startsWith('==') && token.endsWith('==')) {
        if (token.length <= 4) {
          spans.add(TextSpan(text: token));
          cursor = match.end;
          continue;
        }
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: defaultStyle.copyWith(
              backgroundColor: Colors.amber.withOpacity(0.45),
            ),
          ),
        );
      } else if (token.startsWith('*') && token.endsWith('*')) {
        if (token.length <= 2) {
          spans.add(TextSpan(text: token));
          cursor = match.end;
          continue;
        }
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: linksService.plainText(text.substring(cursor))));
    }
    return spans;
  }
}

class _QuickActionBar extends StatelessWidget {
  const _QuickActionBar({
    super.key,
    required this.onBold,
    required this.onItalic,
    required this.onHighlight,
    required this.onChecklist,
    required this.onQuote,
    required this.onLinkNote,
    required this.onSendToBoard,
    required this.onComment,
    required this.onAttachment,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onHighlight;
  final VoidCallback onChecklist;
  final VoidCallback onQuote;
  final VoidCallback onLinkNote;
  final VoidCallback onSendToBoard;
  final VoidCallback onComment;
  final VoidCallback onAttachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(icon: Icons.format_bold, label: 'Bold', onTap: onBold),
            _ToolbarButton(icon: Icons.format_italic, label: 'Italic', onTap: onItalic),
            _ToolbarButton(icon: Icons.highlight_alt, label: 'Highlight', onTap: onHighlight),
            _ToolbarButton(icon: Icons.check_box_outlined, label: 'Checklist', onTap: onChecklist),
            _ToolbarButton(icon: Icons.format_quote, label: 'Quote', onTap: onQuote),
            _ToolbarButton(icon: Icons.link, label: 'Link', onTap: onLinkNote),
            _ToolbarButton(icon: Icons.sticky_note_2_outlined, label: 'Board', onTap: onSendToBoard),
            _ToolbarButton(icon: Icons.add_comment_outlined, label: 'Comment', onTap: onComment),
            _ToolbarButton(icon: Icons.attach_file, label: 'Attach', onTap: onAttachment),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _InlineSection extends StatelessWidget {
  const _InlineSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _LinkSection extends StatelessWidget {
  const _LinkSection({
    required this.title,
    required this.links,
    required this.notes,
  });

  final String title;
  final List<NoteLink> links;
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: links.map((link) {
        return ActionChip(
          label: Text(link.title),
          avatar: const Icon(Icons.link, size: 16),
          onPressed: () {
            final target = notes.where((note) => note.id == link.noteId).toList();
            if (target.isEmpty) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(note: target.first),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _BacklinkSection extends StatelessWidget {
  const _BacklinkSection({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: notes.map((note) {
        return ActionChip(
          label: Text(note.title),
          avatar: const Icon(Icons.call_made, size: 16),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(note: note),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final NoteComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comment.quotedText.isNotEmpty) ...[
            Text(
              comment.quotedText,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(comment.text),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment});

  final NoteAttachment attachment;

  bool get _isRemoteImage {
    final path = attachment.path.toLowerCase();
    return (path.startsWith('http://') || path.startsWith('https://')) &&
        ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp']
            .any((ext) => path.endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: attachment.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attachment path copied')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attachment.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isRemoteImage) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  attachment.path,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
