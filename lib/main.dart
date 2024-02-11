import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './emotion_recorder.dart';
import './diet_recorder.dart';
import './workout_recorder.dart';
import './recording_state_provider.dart';
import 'floor_model/recorder_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin services are initialized
  RecorderDatabase database = await $FloorRecorderDatabase.databaseBuilder('app_database.db').build(); // Initialize the database

  runApp(ChangeNotifierProvider(
    create: (context) => RecordingState(),
    child: MyApp(database), // Pass the database to MyApp
  ));
}

class MyApp extends StatelessWidget {
  final RecorderDatabase database;
  const MyApp(this.database, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HealthRecorder(),
    );
  }
}

class HealthRecorder extends StatelessWidget {
  const HealthRecorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: const [
          EmotionRecorder(),
          DietRecorder(),
          WorkoutRecorder(),
        ],
      ),
      bottomNavigationBar: const RecordingStatusWidget(),
    );
  }
}