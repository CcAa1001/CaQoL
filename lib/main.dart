import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/stickies/stickies_screen.dart';
import 'screens/alarm/alarm_screen.dart';
import 'screens/alarm/alarm_trigger_screen.dart';
import 'services/notes_service.dart';
import 'services/stickies_service.dart';
import 'services/alarm_service.dart';
import 'models/quest_config.dart';
import 'models/alarm.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await NotesService().init();
  await StickiesService().init();
  await AlarmService().init();
  if (defaultTargetPlatform == TargetPlatform.android) {
    await Alarm.init();
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      Alarm.ringStream.stream.listen((alarmSettings) {
        final box = Hive.box<Map>('alarms');
        final all = box.values
            .map((e) => AlarmModel.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        AlarmModel? match;
        for (final a in all) {
          if (a.id.hashCode.abs() % 2147483647 == alarmSettings.id) {
            match = a;
            break;
          }
        }
        _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (_) => AlarmTriggerScreen(
            alarmId: alarmSettings.id.toString(),
            label: match?.label ?? '',
            quest: match?.quest ?? QuestConfig(),
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'CaQoL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
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

  final List<Widget> _screens = const [
    AlarmScreen(),
    NotesScreen(),
    StickiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
