import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/note.dart';
import '../../models/note_folder.dart';
import '../../providers/note_folders_provider.dart';
import '../../providers/notes_provider.dart';
import '../../services/auth_service.dart';
import '../../services/note_export_service.dart';
import '../../services/note_import_service.dart';
import '../../services/note_links_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_sheet.dart';
import 'note_editor_screen.dart';

enum _NotesFilter { all, favorites, recent }

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchCtrl = TextEditingController();
  final _exportService = NoteExportService();
  final _importService = NoteImportService();
  final _linksService = NoteLinksService();
  String? _currentFolderId;
  String? _selectedNoteId;
  bool _isCreatingNote = false;
  String? _selectedTag;
  _NotesFilter _filter = _NotesFilter.all;
  bool _showFilters = false;
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _createNewNote(bool isWide) {
    if (isWide) {
      setState(() {
        _isCreatingNote = true;
        _selectedNoteId = null;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEditorScreen(initialFolderId: _currentFolderId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final folders = ref.watch(noteFoldersProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final query = _searchCtrl.text.trim().toLowerCase();

    final currentFolder = _folderById(folders, _currentFolderId);
    final availableTags = notes
        .expand((note) => note.tags)
        .toSet()
        .toList()
      ..sort();
    final visibleFolders = query.isEmpty
        ? folders.where((folder) => folder.parentId == _currentFolderId).toList()
        : folders.where((folder) => folder.name.toLowerCase().contains(query)).toList();
    final visibleNotes = _applyFilter(notes).where((note) {
      if (_selectedTag != null && !note.tags.contains(_selectedTag)) {
        return false;
      }
      if (query.isNotEmpty) {
        return note.title.toLowerCase().contains(query) ||
            note.body.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
      }
      return note.folderId == _currentFolderId;
    }).toList();

    final isWide = MediaQuery.of(context).size.width > 800;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () => _searchFocusNode.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): () => _searchFocusNode.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () => _createNewNote(isWide),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () => _createNewNote(isWide),
      },
      child: FocusScope(
        autofocus: true,
        child: Scaffold(
      appBar: AppBar(
        title: Text(currentFolder?.name ?? 'Notes'),
        actions: [
          IconButton(
            onPressed: _importBackup,
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Import notes backup',
          ),
          IconButton(
            onPressed: () => _exportBackup(notes, folders),
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export notes backup',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          final content = Column(
            children: [
              Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  focusNode: _searchFocusNode,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notes and folders...',
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
                if (query.isEmpty)
                  _Breadcrumbs(
                    currentFolderId: _currentFolderId,
                    folders: folders,
                    onSelect: (folderId) => setState(() => _currentFolderId = folderId),
                  ),
                if (query.isEmpty) const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CompactPill(
                            icon: Icons.tune,
                            label: _selectedTag == null && _filter == _NotesFilter.all
                                ? 'Filters'
                                : 'Filtered',
                            selected: _showFilters || _selectedTag != null || _filter != _NotesFilter.all,
                            onTap: () => setState(() => _showFilters = !_showFilters),
                          ),
                          if (_filter == _NotesFilter.favorites)
                            _CompactPill(
                              label: 'Favorites',
                              selected: true,
                              onTap: () => setState(() => _filter = _NotesFilter.all),
                            ),
                          if (_filter == _NotesFilter.recent)
                            _CompactPill(
                              label: 'Recent',
                              selected: true,
                              onTap: () => setState(() => _filter = _NotesFilter.all),
                            ),
                          if (_selectedTag != null)
                            _CompactPill(
                              label: '#$_selectedTag',
                              selected: true,
                              onTap: () => setState(() => _selectedTag = null),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showCreateFolderDialog(context),
                      icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                      label: const Text('Folder'),
                    ),
                  ],
                ),
                if (_showFilters) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _filter == _NotesFilter.all,
                          onTap: () => setState(() => _filter = _NotesFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Favorites',
                          selected: _filter == _NotesFilter.favorites,
                          onTap: () => setState(() => _filter = _NotesFilter.favorites),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Recent',
                          selected: _filter == _NotesFilter.recent,
                          onTap: () => setState(() => _filter = _NotesFilter.recent),
                        ),
                      ],
                    ),
                  ),
                  if (availableTags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableTags.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _FilterChip(
                              label: 'Any tag',
                              selected: _selectedTag == null,
                              onTap: () => setState(() => _selectedTag = null),
                            );
                          }
                          final tag = availableTags[index - 1];
                          return _FilterChip(
                            label: '#$tag',
                            selected: _selectedTag == tag,
                            onTap: () => setState(() => _selectedTag = tag),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          Expanded(
            child: visibleFolders.isEmpty && visibleNotes.isEmpty
                ? _EmptyNotesState(isSearching: query.isNotEmpty)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      if (visibleFolders.isNotEmpty) ...[
                        const _SectionTitle('Folders'),
                        const SizedBox(height: 8),
                        ...visibleFolders.map(
                          (folder) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _FolderTile(
                              folder: folder,
                              noteCount: notes.where((note) => note.folderId == folder.id).length,
                              pathLabel: query.isEmpty ? null : _folderPath(folder, folders),
                              onTap: () => setState(() {
                                _currentFolderId = folder.id;
                                _searchCtrl.clear();
                              }),
                              onRename: () => _showRenameFolderDialog(folder),
                              onDelete: () => _deleteFolder(folder, folders),
                            ),
                          ),
                        ),
                      ],
                      if (visibleNotes.isNotEmpty) ...[
                        if (visibleFolders.isNotEmpty) const SizedBox(height: 10),
                        const _SectionTitle('Notes'),
                        const SizedBox(height: 8),
                        ...visibleNotes.map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _NoteTile(
                              note: note,
                              previewText: _linksService.plainText(note.body),
                              tags: note.tags,
                              pathLabel: query.isEmpty ? null : _notePath(note, folders),
                              onOpen: () {
                                if (isWide) {
                                  setState(() {
                                    _selectedNoteId = note.id;
                                    _isCreatingNote = false;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NoteEditorScreen(note: note),
                                    ),
                                  );
                                }
                              },
                              onFavorite: () =>
                                  ref.read(notesProvider.notifier).toggleFavorite(note.id),
                              onDelete: () =>
                                  ref.read(notesProvider.notifier).delete(note.id),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      );

      if (!isWide) return content;

      Note? selectedNote;
      if (_selectedNoteId != null) {
        for (final n in notes) {
          if (n.id == _selectedNoteId) {
            selectedNote = n;
            break;
          }
        }
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: content,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _isCreatingNote
                ? NoteEditorScreen(
                    key: const ValueKey('embedded-new-note'),
                    initialFolderId: _currentFolderId,
                    isEmbedded: true,
                    onSaved: (id) {
                      if (!mounted) return;
                      setState(() {
                        _selectedNoteId = id;
                        _isCreatingNote = false;
                      });
                    },
                  )
                : _selectedNoteId == null || selectedNote == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 64, color: AppTheme.textTertiary),
                        SizedBox(height: 16),
                        Text('Select a note or folder', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : NoteEditorScreen(
                    key: ValueKey(_selectedNoteId),
                    note: selectedNote,
                    isEmbedded: true,
                    onSaved: (id) {
                      if (!mounted) return;
                      setState(() {
                        _selectedNoteId = id;
                        _isCreatingNote = false;
                      });
                    },
                  ),
          ),
        ],
      );
    }),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createNewNote(isWide),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('New note'),
          ),
        ),
      ),
    );
  }

  List<Note> _applyFilter(List<Note> notes) {
    switch (_filter) {
      case _NotesFilter.all:
        return notes;
      case _NotesFilter.favorites:
        return notes.where((note) => note.isFavorite).toList();
      case _NotesFilter.recent:
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        return notes.where((note) => note.updatedAt.isAfter(cutoff)).toList();
    }
  }

  NoteFolder? _folderById(List<NoteFolder> folders, String? id) {
    if (id == null) {
      return null;
    }
    for (final folder in folders) {
      if (folder.id == id) {
        return folder;
      }
    }
    return null;
  }

  String _folderPath(NoteFolder folder, List<NoteFolder> folders) {
    final names = <String>[folder.name];
    var parentId = folder.parentId;
    while (parentId != null) {
      final parent = _folderById(folders, parentId);
      if (parent == null) {
        break;
      }
      names.insert(0, parent.name);
      parentId = parent.parentId;
    }
    return names.join(' / ');
  }

  String _notePath(Note note, List<NoteFolder> folders) {
    if (note.folderId == null) {
      return 'Root';
    }
    final folder = _folderById(folders, note.folderId);
    if (folder == null) {
      return 'Root';
    }
    return _folderPath(folder, folders);
  }

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                return;
              }
              await ref
                  .read(noteFoldersProvider.notifier)
                  .add(name, parentId: _currentFolderId);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameFolderDialog(NoteFolder folder) async {
    final controller = TextEditingController(text: folder.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                return;
              }
              await ref.read(noteFoldersProvider.notifier).update(
                    folder.copyWith(name: name),
                  );
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFolder(NoteFolder folder, List<NoteFolder> folders) async {
    final children = folders.where((item) => item.parentId == folder.id).toList();
    for (final child in children) {
      await ref.read(noteFoldersProvider.notifier).update(
            child.copyWith(
              parentId: folder.parentId,
              clearParentId: folder.parentId == null,
            ),
          );
    }
    await ref.read(notesProvider.notifier).moveOutOfFolder(folder.id);
    await ref.read(noteFoldersProvider.notifier).delete(folder.id);
    if (_currentFolderId == folder.id && mounted) {
      setState(() => _currentFolderId = folder.parentId);
    }
  }

  Future<void> _exportBackup(List<Note> notes, List<NoteFolder> folders) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await _exportService.exportAll(
        folders: folders,
        notes: notes,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(result)),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    }
  }

  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final payload = await _importService.pickAndParse();
      if (payload == null) {
        return;
      }
      await ref.read(noteFoldersProvider.notifier).importAll(payload.folders);
      await ref.read(notesProvider.notifier).importAll(payload.notes);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${payload.folders.length} folders and ${payload.notes.length} notes.',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    }
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({
    required this.currentFolderId,
    required this.folders,
    required this.onSelect,
  });

  final String? currentFolderId;
  final List<NoteFolder> folders;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final chain = <NoteFolder>[];
    var folderId = currentFolderId;
    while (folderId != null) {
      NoteFolder? current;
      for (final folder in folders) {
        if (folder.id == folderId) {
          current = folder;
          break;
        }
      }
      if (current == null) {
        break;
      }
      chain.insert(0, current);
      folderId = current.parentId;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          TextButton(
            onPressed: () => onSelect(null),
            child: const Text('Root'),
          ),
          for (final folder in chain) ...[
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.textTertiary),
            TextButton(
              onPressed: () => onSelect(folder.id),
              child: Text(folder.name),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
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

class _CompactPill extends StatelessWidget {
  const _CompactPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.noteCount,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    this.pathLabel,
  });

  final NoteFolder folder;
  final int noteCount;
  final String? pathLabel;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.folder_open_rounded, color: AppTheme.primary),
        title: Text(
          folder.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          pathLabel ?? '$noteCount notes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'rename') {
              onRename();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'rename',
              child: Text('Rename folder'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete folder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.previewText,
    required this.tags,
    required this.onOpen,
    required this.onFavorite,
    required this.onDelete,
    this.pathLabel,
  });

  final Note note;
  final String previewText;
  final List<String> tags;
  final String? pathLabel;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onOpen,
        leading: Icon(
          note.isFavorite ? Icons.star_rounded : Icons.note_outlined,
          color: note.isFavorite ? AppTheme.primary : AppTheme.textSecondary,
        ),
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              previewText.trim().isEmpty ? 'No content' : previewText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (pathLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                pathLabel!,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'favorite':
                onFavorite();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'favorite',
              child: Text(note.isFavorite ? 'Remove favorite' : 'Add favorite'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete note'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotesState extends StatelessWidget {
  const _EmptyNotesState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.folder_open_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching ? 'No matching results' : 'No notes or folders here yet',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSearching
                ? 'Try a different search term.'
                : 'Create a folder or add a note to get started.',
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
