import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import './emotion_recorder.dart';
import './diet_recorder.dart';
import './workout_recorder.dart';
import './recording_state_provider.dart';
import './appLocalizations.dart';
import 'firebase_options.dart';
import 'floor_model/recorder_database.dart';
import 'leaderboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  bool _useMaterialDesign = true;

  bool get useMaterialDesign => _useMaterialDesign;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setStyle(bool useMaterialDesign) {
    setState(() {
      _useMaterialDesign = useMaterialDesign;
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
            GoRoute(
              path: '/leaderboard',
              builder: (BuildContext context, GoRouterState state) => LeaderboardPage(),
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

  Future<String?> getUsername(String uid) async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['username'] as String?;
  }

  Future<void> updateUsername(String newUsername) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateUsername');
    try {
      final response = await callable.call({
        'username': newUsername,
      });
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  void _showSettingDialog(BuildContext context) {
    final appState = MyApp.of(context);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    TextEditingController usernameController = TextEditingController();

    if (user != null) {
      getUsername(user.uid).then((username) {
        if (username != null) {
          usernameController.text = username;
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Settings')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).translate('chooseLanguage')),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Locale>[Locale('en', ''), Locale('id', '')].map((Locale locale) {
                    return RadioListTile<Locale>(
                      title: Text(AppLocalizations.of(context).translate(locale.languageCode)),
                      value: locale,
                      groupValue: MyApp.of(context)!._locale,
                      onChanged: (Locale? value) {
                        MyApp.of(context)?.setLocale(value!);
                      },
                    );
                  }).toList(),
                ),
                const Divider(),
                Text(AppLocalizations.of(context).translate('chooseTheme')),
                SwitchListTile(
                  title: Text(appState!.useMaterialDesign ? 'Material' : 'Cupertino'),
                  value: appState.useMaterialDesign,
                  onChanged: (bool value) {
                    appState.setStyle(value);
                    setState(() {});
                  },
                ),
                const Divider(),
                if (user != null) ...[
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('username'),
                    ),
                  ),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context).translate('updateUsername')),
                    onPressed: () async {
                      await updateUsername(usernameController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(AppLocalizations.of(context).translate('signOut')),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pop();
                    },
                  ),
                ]
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
              _showSettingDialog(context);
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
            case 3:
              context.go('/leaderboard');
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
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: localizations.translate('leaderboardTab'),
          ),
        ],
      ),
    );
  }
}