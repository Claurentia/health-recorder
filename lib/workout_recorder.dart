import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './recording_state_provider.dart';
import './appLocalizations.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';
import './main.dart';

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
    final AppLocalizations localizations = AppLocalizations.of(context);

    if (_durationController.text.isEmpty) {
      if (MyApp.of(context)!.useMaterialDesign) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('pleaseFillInAllFields')),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(localizations.translate('Alert')),
            content: Text(localizations.translate('pleaseFillInAllFields')),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.translate('Ok')),
              ),
            ],
          ),
        );
      }
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
    final AppLocalizations localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyApp.of(context)!.useMaterialDesign
        ? AlertDialog(
            title: Text(localizations.translate('confirmDeleteTitle')),
            content: Text(localizations.translate('confirmDeleteWorkoutRecord')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  _deleteWorkoutRecord(record);
                  Navigator.of(context).pop();
                },
                child: Text(localizations.translate('delete'), style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        : CupertinoAlertDialog(
          title: Text(localizations.translate('confirmDeleteTitle')),
          content: Text(localizations.translate('confirmDeleteWorkoutRecord')),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.translate('cancel')),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                _deleteWorkoutRecord(record);
                Navigator.of(context).pop();
              },
              child: Text(localizations.translate('delete')),
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

  Widget _buildExercisePicker() {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return MyApp.of(context)!.useMaterialDesign
    ? DropdownButtonFormField<String>(
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
            child: Text(localizations.translate(value)),
          );
        }).toList(),
      )
    : Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            color: CupertinoColors.white,
            child: Text(
              localizations.translate(selectedExercise),
              style: TextStyle(color: CupertinoColors.black),
            ),
            onPressed: () => _showCupertinoExercisePicker(context),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.arrowtriangle_down),
          onPressed: () => _showCupertinoExercisePicker(context),
        ),
      ],
    );
  }

  void _showCupertinoExercisePicker(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32,
                children: exercises.map((String value) => Text(localizations.translate(value))).toList(),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    selectedExercise = exercises[index];
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutRecordsList(WorkoutRecord record) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return MyApp.of(context)!.useMaterialDesign
    ? ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(" ${localizations.translate(record.workout)} - ${record.durationOrReps} ${isDurationBasedExercise(record.workout) ? localizations.translate('minutes') : 'reps'}", style: TextStyle(fontSize: 16),),
        subtitle: Text(" ${localizations.translate('caloriesBurned')}: ${record.caloriesBurned} cal \n ${localizations.translate('recordedAt')} ${record.dateTime}", style: TextStyle(fontSize: 12),),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteWorkoutRecord(record),
        ),
      )
    : Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.fitness_center, color: CupertinoColors.systemGrey),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${localizations.translate(record.workout)} - ${record.durationOrReps} ${isDurationBasedExercise(record.workout) ? localizations.translate('minutes') : localizations.translate('reps')}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    " ${localizations.translate('caloriesBurned')}: ${record.caloriesBurned} cal \n ${localizations.translate('recordedAt')} ${record.dateTime}",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _confirmDeleteWorkoutRecord(record),
              child: Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool useMaterialDesign = MyApp.of(context)!.useMaterialDesign;

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
                  Text(localizations.translate('recordYourWorkout'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildExercisePicker(),
                  const SizedBox(height: 10),
                  useMaterialDesign
                  ? TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: isDurationBasedExercise(selectedExercise) ? localizations.translate('durationMinutes') : localizations.translate('reps'),
                        hintText: isDurationBasedExercise(selectedExercise)
                            ? localizations.translate('enterDurationOfWorkout')
                            : localizations.translate('enterNumberOfReps'),
                      ),
                    )
                  : CupertinoTextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      placeholder: isDurationBasedExercise(selectedExercise) ? localizations.translate('enterDurationOfWorkout') : localizations.translate('enterNumberOfReps'),
                      clearButtonMode: OverlayVisibilityMode.editing,
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: useMaterialDesign
                      ? ElevatedButton(
                        onPressed: () => _onRecordTap(context),
                        child: Text(localizations.translate('recordWorkout')),
                      )
                      : CupertinoButton(
                        color: CupertinoColors.systemTeal,
                        onPressed: () => _onRecordTap(context),
                        child: Text(localizations.translate('recordWorkout')),
                      ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      localizations.translate('workoutHistory'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            for (var record in workoutRecords)
              _buildWorkoutRecordsList(record),
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