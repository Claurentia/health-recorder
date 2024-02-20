import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import './emotion_recorder.dart';
import './diet_recorder.dart';
import './workout_recorder.dart';
import './recording_state_provider.dart';
import './appLocalizations.dart';
import 'floor_model/recorder_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final RecorderDatabase database = await $FloorRecorderDatabase.databaseBuilder('app_database.db').build();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => RecordingState(database: database)),
      Provider(create: (context) => database),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {

    final GoRouter _router = GoRouter(
      initialLocation: '/emotion',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HealthRecorder(child: child),
          routes: [
            GoRoute(
              path: '/emotion',
              builder: (BuildContext context, GoRouterState state) => const EmotionRecorder(),
            ),
            GoRoute(
              path: '/diet',
              builder: (BuildContext context, GoRouterState state) => const DietRecorder(),
            ),
            GoRoute(
              path: '/workout',
              builder: (BuildContext context, GoRouterState state) => const WorkoutRecorder(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: _router,
      title: 'Health Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('id', ''),
      ],
    );
  }
}

class HealthRecorder extends StatefulWidget {
  final Widget child;

  const HealthRecorder({super.key, required this.child});

  @override
  State<HealthRecorder> createState() => _HealthRecorderState();
}

class _HealthRecorderState extends State<HealthRecorder> {
  int _selectedIndex = 0;

  void _showLanguageChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('chooseLanguage')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const <Locale>[Locale('en', ''), Locale('id', '')].map((Locale locale) {
              return RadioListTile<Locale>(
                title: Text(AppLocalizations.of(context).translate(locale.languageCode)),
                value: locale,
                groupValue: MyApp.of(context)!._locale,
                onChanged: (Locale? value) {
                  MyApp.of(context)?.setLocale(value!);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recordingState = Provider.of<RecordingState>(context, listen: false);
      recordingState.updatePointsAndLastActivity();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        title: Text(
          localizations.translate('appTitle'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              _showLanguageChangeDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded (
            child: widget.child,
          ),
          RecordingStatusWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go('/emotion');
              break;
            case 1:
              context.go('/diet');
              break;
            case 2:
              context.go('/workout');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.sentiment_very_satisfied),
              label: localizations.translate('emotionTab'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: localizations.translate('dietTab'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: localizations.translate('workoutTab'),
          ),
        ],
      ),
    );
  }
}