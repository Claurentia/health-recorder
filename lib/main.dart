import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import './emotion_recorder.dart';
import './diet_recorder.dart';
import './workout_recorder.dart';
import './recording_state_provider.dart';
import 'floor_model/recorder_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final RecorderDatabase database = await $FloorRecorderDatabase.databaseBuilder('app_database.db').build();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => RecordingState()),
      Provider(create: (context) => database),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        title: Text(
          'Health Recorder',
          style: const TextStyle(color: Colors.white),
        ),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sentiment_very_satisfied), label: 'Emotion'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        ],
      ),
    );
  }
}