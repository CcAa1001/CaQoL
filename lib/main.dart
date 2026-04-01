import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'models/alarm.dart';
import 'screens/alarm/alarm_screen.dart';
import 'screens/alarm/alarm_trigger_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/stickies/stickies_screen.dart';
import 'services/alarm_history_service.dart';
import 'services/alarm_service.dart';
import 'services/app_settings_service.dart';
import 'services/auth_service.dart';
import 'services/note_folders_service.dart';
import 'services/notes_service.dart';
import 'services/sticky_boards_service.dart';
import 'services/stickies_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotesService().init();
  await NoteFoldersService().init();
  await StickyBoardsService().init();
  await StickiesService().init();
  await AppSettingsService().init();
  await AlarmHistoryService().init();
  await AlarmService().init();
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
      return;
    }
    await AlarmHistoryService().log(alarm, 'triggered');
    await _openAlarmTrigger(alarm);
  }

  Future<void> _recoverTriggeredAlarm() async {
    final service = AlarmService();
    for (final alarm in service.getAll()) {
      final isRinging = await Alarm.isRinging(
        service.platformAlarmId(alarm.id),
      );
      if (isRinging) {
        await _openAlarmTrigger(alarm);
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const AlarmScreen();
      case 1:
        return const NotesScreen();
      case 2:
        return const StickiesScreen();
      default:
        return const AlarmScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
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
        ],
      ),
    );
  }
}
