import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutRecorder extends StatefulWidget {
  const WorkoutRecorder({super.key});

  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

class _WorkoutRecorderState extends State<WorkoutRecorder> {
  String selectedExercise = "Running";
  final TextEditingController _durationController = TextEditingController();
  List<WorkoutRecord> workoutRecords = [];

  int caloriesBurnedToday = 0;
  int averageCaloriesThisWeek = 0;

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
    updateCalStats();
  }

  void updateCalStats() {
    caloriesBurnedToday = calculateCaloriesBurnedToday();
    averageCaloriesThisWeek = calculateAverageCaloriesThisWeek();
    setState(() {});
  }

  int calculateCaloriesBurnedToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int totalCalories = workoutRecords
        .where((record) =>
    record.dateTime.year == today.year &&
        record.dateTime.month == today.month &&
        record.dateTime.day == today.day)
        .fold(0, (sum, record) => sum + record.caloriesBurned);

    return totalCalories;
  }

  int calculateAverageCaloriesThisWeek() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    var weekRecords = workoutRecords.where((record) =>
    record.dateTime.isAfter(startOfWeek) && record.dateTime.isBefore(now));

    if (weekRecords.isEmpty) return 0;

    int totalCalories = weekRecords.fold(0, (sum, record) => sum + record.caloriesBurned);
    int averageCalories = (totalCalories / weekRecords.length).toInt();

    return averageCalories;
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

    recordExercise(workout, durationOrReps, caloriesBurned);

    _durationController.clear();
    updateCalStats();
  }

  void recordExercise(String exercise, int durationOrReps, int calories) {
    setState(() {
      workoutRecords.insert(0, WorkoutRecord(exercise, durationOrReps, calories, DateTime.now()));
    });
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF333333),
          title: const Text(
            'Workout Recorder',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.local_fire_department, color: Colors.white),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text('Calories Burned Today',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text('$caloriesBurnedToday cal',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.trending_up, color: Colors.white),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text('Avg. Calories Burned This Week',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text('$averageCaloriesThisWeek cal',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
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
                title: Text(" ${record.workout} - ${record.durationOrReps} ${isDurationBasedExercise(record.workout) ? 'minutes' : 'reps'}"),
                subtitle: Text(" Calories burned: ${record.caloriesBurned} cal \n Recorded at ${DateFormat('yyyy-MM-dd – kk:mm').format(record.dateTime)}"),
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

class WorkoutRecord {
  String workout;
  int durationOrReps;
  int caloriesBurned;
  DateTime dateTime;

  WorkoutRecord(this.workout, this.durationOrReps, this.caloriesBurned, this.dateTime);
}