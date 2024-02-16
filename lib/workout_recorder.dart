import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';

class WorkoutRecorder extends StatefulWidget {
  const WorkoutRecorder({super.key});

  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

class _WorkoutRecorderState extends State<WorkoutRecorder> {
  String selectedExercise = "Running";
  final TextEditingController _durationController = TextEditingController();
  List<WorkoutRecord> workoutRecords = [];

  static const List<String> exercises = [
    "Running",
    "Cycling",
    "Swimming",
    "Yoga",
    "Bench Press",
    "Hammer Curl",
    "Roman Dead Lift",
    "Squat",
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkoutRecords();
  }

  void _loadWorkoutRecords() async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    final records = await database.workoutRecordDao.findAllWorkoutRecords();
    setState(() {
      workoutRecords = List.from(records.reversed);
    });
  }

  void _onRecordTap(BuildContext context) {
    if (_durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String workout = selectedExercise;
    int durationOrReps = int.tryParse(_durationController.text) ?? 0;
    int caloriesBurned = calculateCalories(workout, durationOrReps);
    String now = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    int ptsEarned = Provider.of<RecordingState>(context, listen: false).recordActivity('Workout');

    WorkoutRecord newRecord = WorkoutRecord(workout: workout, durationOrReps: durationOrReps, caloriesBurned: caloriesBurned, dateTime: now, points: ptsEarned);

    recordExercise(newRecord);
  }

  void recordExercise(WorkoutRecord newRecord) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.workoutRecordDao.insertWorkoutRecord(newRecord);
    _loadWorkoutRecords();
    _durationController.clear();
  }

  int calculateCalories(String exercise, int durationOrReps) {
    switch (exercise) {
      case "Running":
        return durationOrReps * 8;
      case "Cycling":
        return durationOrReps * 6;
      case "Swimming":
        return durationOrReps * 10;
      case "Yoga":
        return durationOrReps * 4;
      case "Bench Press":
      case "Hammer Curl":
      case "Roman Dead Lift":
      case "Squat":
        return durationOrReps * 2;
      default:
        return 0;
    }
  }

  void _deleteWorkoutRecord(WorkoutRecord record) async {
    final database = Provider.of<RecorderDatabase>(context, listen: false);
    await database.workoutRecordDao.deleteWorkoutRecord(record);
    Provider.of<RecordingState>(context, listen: false).deductPoints(record.points);
    _loadWorkoutRecords();
  }

  void _confirmDeleteWorkoutRecord(WorkoutRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Record"),
          content: const Text("Are you sure you want to delete this workout record?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteWorkoutRecord(record);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  bool isDurationBasedExercise(String exercise) {
    const durationBasedExercises = ["Running", "Cycling", "Swimming", "Yoga"];
    return durationBasedExercises.contains(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: ListView(
          children: [
            Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                const Text('Record Your Workout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedExercise,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedExercise = newValue;
                      });
                    }
                  },
                  items: exercises.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: isDurationBasedExercise(selectedExercise) ? 'Duration (minutes)' : 'Reps',
                    hintText: isDurationBasedExercise(selectedExercise)
                        ? 'Enter duration of workout'
                        : 'Enter number of reps',
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _onRecordTap(context),
                    child: const Text('Record Workout'),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Workout History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ),
            for (var record in workoutRecords)
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(" ${record.workout} - ${record.durationOrReps} ${isDurationBasedExercise(record.workout) ? 'minutes' : 'reps'}", style: TextStyle(fontSize: 16),),
                subtitle: Text(" Calories burned: ${record.caloriesBurned} cal \n Recorded at ${record.dateTime}", style: TextStyle(fontSize: 12),),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteWorkoutRecord(record),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}