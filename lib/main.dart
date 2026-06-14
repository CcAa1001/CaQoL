import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'models/alarm.dart';
import 'models/awake_check_entry.dart';
import 'models/note.dart';
import 'models/note_folder.dart';
import 'models/sticky.dart';
import 'models/sticky_board.dart';
import 'providers/note_folders_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/stickies_provider.dart';
import 'providers/sticky_boards_provider.dart';
import 'screens/alarm/alarm_screen.dart';
import 'screens/alarm/awake_check_screen.dart';
import 'screens/alarm/alarm_trigger_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/notes/note_editor_screen.dart';
import 'screens/stickies/stickies_screen.dart';
import 'services/alarm_history_service.dart';
import 'services/alarm_service.dart';
import 'services/app_settings_service.dart';
import 'services/auth_service.dart';
import 'services/awake_check_service.dart';
import 'services/qr_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  
  await Hive.initFlutter();
  await AppSettingsService().init();
  await AwakeCheckService().init();
  await AlarmHistoryService().init();
  await AlarmService().init();
  await QrService().init();
  if (defaultTargetPlatform == TargetPlatform.android) {
    await Alarm.init();
    await Alarm.setWarningNotificationOnKill(
      'Keep CaQoL available',
      'Re-open the app if your device closes it so alarms can keep waking the screen.',
    );
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AlarmSettings>? _ringSubscription;
  String? _openAlarmId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (defaultTargetPlatform == TargetPlatform.android) {
      _ringSubscription = Alarm.ringStream.stream.listen(_handleAlarmRing);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recoverTriggeredAlarm();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ringSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        defaultTargetPlatform == TargetPlatform.android) {
      _recoverTriggeredAlarm();
    }
  }

  Future<void> _handleAlarmRing(AlarmSettings alarmSettings) async {
    final alarm = AlarmService().findByPlatformId(alarmSettings.id);
    if (alarm == null) {
      final awakeCheck = AwakeCheckService().findByPlatformId(alarmSettings.id);
      if (awakeCheck != null) {
        await _openAwakeCheck(awakeCheck);
      }
      return;
    }
    await AlarmHistoryService().log(alarm, 'triggered');
    await _openAlarmTrigger(alarm);
  }

  Future<void> _recoverTriggeredAlarm() async {
    final service = AlarmService();
    for (final alarm in service.getAll()) {
      final isRinging = await Alarm.isRinging(
        alarm.platformId,
      );
      if (isRinging) {
        await _openAlarmTrigger(alarm);
        return;
      }
    }
    final awakeChecks = AwakeCheckService().getAll();
    for (final entry in awakeChecks) {
      final isRinging = await Alarm.isRinging(
        entry.platformId,
      );
      if (isRinging) {
        await _openAwakeCheck(entry);
        return;
      }
    }
  }

  Future<void> _openAlarmTrigger(AlarmModel alarm) async {
    if (_openAlarmId == alarm.id) {
      return;
    }

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAlarmTrigger(alarm);
      });
      return;
    }

    _openAlarmId = alarm.id;
    await navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AlarmTriggerScreen(alarm: alarm)),
      (route) => route.isFirst,
    );
    _openAlarmId = null;
  }

  Future<void> _openAwakeCheck(AwakeCheckEntry entry) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAwakeCheck(entry);
      });
      return;
    }

    await navigator.push(
      MaterialPageRoute(builder: (_) => AwakeCheckScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'CaQoL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null || user.isAnonymous) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: AppTheme.primary,
                  size: 44,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Authentication is not ready',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  List<NavigationDestination> _destinations = [];
  final _homeShortcutsNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _screens = const [NotesScreen(), StickiesScreen()];
      _destinations = const [
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
          label: 'Notes',
        ),
        NavigationDestination(
          icon: Icon(Icons.sticky_note_2_outlined),
          selectedIcon: Icon(Icons.sticky_note_2),
          label: 'Stickies',
        ),
      ];
    } else {
      _screens = const [AlarmScreen(), NotesScreen(), StickiesScreen()];
      _destinations = const [
        NavigationDestination(
          icon: Icon(Icons.alarm_outlined),
          selectedIcon: Icon(Icons.alarm),
          label: 'Alarm',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
          label: 'Notes',
        ),
        NavigationDestination(
          icon: Icon(Icons.sticky_note_2_outlined),
          selectedIcon: Icon(Icons.sticky_note_2),
          label: 'Stickies',
        ),
      ];
    }
  }

  @override
  void dispose() {
    _homeShortcutsNode.dispose();
    super.dispose();
  }

  int get _notesTabIndex => kIsWeb ? 0 : 1;
  int get _stickiesTabIndex => kIsWeb ? 1 : 2;

  Future<void> _openCommandPalette() async {
    final notes = ref.read(notesProvider);
    final folders = ref.read(noteFoldersProvider);
    final stickies = ref.read(stickiesProvider);
    final boards = ref.read(stickyBoardsProvider);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => _CommandPaletteDialog(
        notes: notes,
        folders: folders,
        stickies: stickies,
        boards: boards,
        showAlarmTab: !kIsWeb,
        onOpenAlarm: () => setState(() => _currentIndex = 0),
        onOpenNotes: () => setState(() => _currentIndex = _notesTabIndex),
        onOpenStickies: () => setState(() => _currentIndex = _stickiesTabIndex),
        onNewNote: () {
          setState(() => _currentIndex = _notesTabIndex);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
        },
        onOpenNote: (note) {
          setState(() => _currentIndex = _notesTabIndex);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _openCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _openCommandPalette,
      },
      child: Focus(
        autofocus: true,
        focusNode: _homeShortcutsNode,
        child: Scaffold(
          body: _screens[_currentIndex]
              .animate(key: ValueKey(_currentIndex))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutQuart),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: _destinations,
          ),
        ),
      ),
    );
  }
}

class _CommandPaletteDialog extends StatefulWidget {
  const _CommandPaletteDialog({
    required this.notes,
    required this.folders,
    required this.stickies,
    required this.boards,
    required this.showAlarmTab,
    required this.onOpenAlarm,
    required this.onOpenNotes,
    required this.onOpenStickies,
    required this.onNewNote,
    required this.onOpenNote,
  });

  final List<Note> notes;
  final List<NoteFolder> folders;
  final List<Sticky> stickies;
  final List<StickyBoard> boards;
  final bool showAlarmTab;
  final VoidCallback onOpenAlarm;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenStickies;
  final VoidCallback onNewNote;
  final ValueChanged<Note> onOpenNote;

  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  final _queryCtrl = TextEditingController();

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _queryCtrl.text.trim().toLowerCase();
    final noteMatches = widget.notes
        .where((note) =>
            query.isEmpty ||
            note.title.toLowerCase().contains(query) ||
            note.body.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query)))
        .take(8)
        .toList();
    final folderMatches = widget.folders
        .where((folder) => query.isEmpty || folder.name.toLowerCase().contains(query))
        .take(5)
        .toList();
    final stickyMatches = widget.stickies
        .where((sticky) =>
            query.isEmpty ||
            sticky.title.toLowerCase().contains(query) ||
            sticky.body.toLowerCase().contains(query))
        .take(5)
        .toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: AppTheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _queryCtrl,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Type a command, note title, folder, or sticky...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.showAlarmTab)
                    _CommandChip(
                      label: 'Go to Alarm',
                      icon: Icons.alarm,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenAlarm();
                      },
                    ),
                  _CommandChip(
                    label: 'Go to Notes',
                    icon: Icons.edit_note,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOpenNotes();
                    },
                  ),
                  _CommandChip(
                    label: 'Go to Stickies',
                    icon: Icons.sticky_note_2,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOpenStickies();
                    },
                  ),
                  _CommandChip(
                    label: 'New note',
                    icon: Icons.note_add_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNewNote();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    if (noteMatches.isNotEmpty) ...[
                      const _PaletteSectionTitle('Notes'),
                      ...noteMatches.map(
                        (note) => _PaletteTile(
                          icon: Icons.description_outlined,
                          title: note.title,
                          subtitle: note.tags.isEmpty
                              ? note.body.trim().isEmpty
                                  ? 'No content'
                                  : note.body.trim()
                              : '#${note.tags.join(' #')}',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onOpenNote(note);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (folderMatches.isNotEmpty) ...[
                      const _PaletteSectionTitle('Folders'),
                      ...folderMatches.map(
                        (folder) => _PaletteTile(
                          icon: Icons.folder_open_outlined,
                          title: folder.name,
                          subtitle: 'Folder',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onOpenNotes();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (stickyMatches.isNotEmpty) ...[
                      const _PaletteSectionTitle('Stickies'),
                      ...stickyMatches.map(
                        (sticky) => _PaletteTile(
                          icon: Icons.sticky_note_2_outlined,
                          title: sticky.title.isEmpty ? 'Untitled sticky' : sticky.title,
                          subtitle: sticky.body.trim().isEmpty ? 'No content' : sticky.body.trim(),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onOpenStickies();
                          },
                        ),
                      ),
                    ],
                    if (noteMatches.isEmpty &&
                        folderMatches.isEmpty &&
                        stickyMatches.isEmpty &&
                        query.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'No matches found.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppTheme.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _PaletteSectionTitle extends StatelessWidget {
  const _PaletteSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
