import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import './appLocalizations.dart';
import 'floor_model/recorder_database.dart';
import 'floor_model/recorder_entity.dart';

class RecordingState extends ChangeNotifier {
  final RecorderDatabase database;
  DateTime? lastRecordingTime;
  String lastRecordingActivity = 'no record';
  int recordingPoints = 0;

  RecordingState({required this.database});

  Future<void> updatePointsAndLastActivity() async {
    final int emotionPoints = await database.emotionRecordDao.getSumOfPoints() ?? 0;
    final int dietPoints = await database.dietRecordDao.getSumOfPoints() ?? 0;
    final int workoutPoints = await database.workoutRecordDao.getSumOfPoints() ?? 0;

    recordingPoints = emotionPoints + dietPoints + workoutPoints;

    final EmotionRecord? lastEmotionRecord = await database.emotionRecordDao.getLastInsertedRecord();
    final DietRecord? lastDietRecord = await database.dietRecordDao.getLastInsertedRecord();
    final WorkoutRecord? lastWorkoutRecord = await database.workoutRecordDao.getLastInsertedRecord();

    DateFormat format = DateFormat('yyyy-MM-dd – kk:mm');
    List<MapEntry<String, DateTime>> activityDatePairs = [];

    if (lastEmotionRecord != null) {
      activityDatePairs.add(MapEntry('Mood', format.parse(lastEmotionRecord.dateTime)));
    }
    if (lastDietRecord != null) {
      activityDatePairs.add(MapEntry('Diet', format.parse(lastDietRecord.dateTime)));
    }
    if (lastWorkoutRecord != null) {
      activityDatePairs.add(MapEntry('Workout', format.parse(lastWorkoutRecord.dateTime)));
    }

    activityDatePairs.sort((a, b) => b.value.compareTo(a.value));

    if (activityDatePairs.isNotEmpty) {
      final mostRecentActivity = activityDatePairs.first;
      lastRecordingTime = mostRecentActivity.value.add(Duration(hours: 1));
      lastRecordingActivity = mostRecentActivity.key;
    }

    notifyListeners();
  }

  void deductPoints(int points) {
    updatePointsAndLastActivity();

    int pointsToDeduct = -1 * points;
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Deducting ${pointsToDeduct} points from user');
      updateUserPoints(pointsToDeduct);
    }
  }

  int recordActivity(String activity) {
    lastRecordingActivity = activity;
    int ptsEarned = _calculatePoints();
    updateUserPoints(ptsEarned);
    notifyListeners();
    return ptsEarned;
  }

  int _calculatePoints() {
    var now = DateTime.now();
    int ptsEarned = 0;
    if (lastRecordingTime == null) {
      recordingPoints += 50;
      ptsEarned += 50;
    } else {
      var hoursElapsed = now.difference(lastRecordingTime!).inHours + 1;

      ptsEarned = 2 * min(hoursElapsed, 15);
      recordingPoints += ptsEarned;
    }
    lastRecordingTime = now;
    return ptsEarned;
  }

  Future<void> updateUserPoints(int pts) async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    try {
      final HttpsCallableResult result = await functions.httpsCallable('updateUserPoints').call({
        'points': pts,
      });
      print("Function result: ${result.data}");
    } catch (e) {
      print("Error calling function: $e");
    }
  }

  Future<void> syncPointsWithFirestore() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFunctions functions = FirebaseFunctions.instance;
      try {
        final HttpsCallable callable = functions.httpsCallable('syncUserPoints');
        final HttpsCallableResult result = await callable.call({
          'points': recordingPoints,
        });
        recordingPoints = result.data['points'];
        print("Synced points: $recordingPoints");
      } catch (e) {
        print("Error calling function: $e");
      }
    }
  }
}

class RecordingStatusWidget extends StatelessWidget {
  const RecordingStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    final recordingState = Provider.of<RecordingState>(context);
    String dedicationLevel = '${recordingState.recordingPoints ~/ 100}';
    String lastRecord = recordingState.lastRecordingTime != null
        ? '${recordingState.lastRecordingActivity} at ${DateFormat('MMM dd, yyyy – kk:mm').format(recordingState.lastRecordingTime!)}'
        : localizations.translate('noRecord');

    int nextLevelPoints = ((recordingState.recordingPoints ~/ 100) + 1) * 100;
    int pointsToNextLevel = nextLevelPoints - recordingState.recordingPoints;

    return Container(
        color: Colors.blueGrey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${localizations.translate('lastRecord')}: $lastRecord',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '${localizations.translate('dedicationLevel')}: $dedicationLevel',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '${localizations.translate('nextLevel')}: $pointsToNextLevel ${localizations.translate('points')} ',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
