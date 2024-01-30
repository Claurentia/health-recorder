import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class RecordingState extends ChangeNotifier {
  DateTime? lastRecordingTime;
  String lastRecordingActivity = 'no record';
  int recordingPoints = 0;

  void recordActivity(String activity) {
    lastRecordingActivity = activity;
    _calculatePoints();
    notifyListeners();
  }

  void _calculatePoints() {
    var now = DateTime.now();
    if (lastRecordingTime == null) {
      recordingPoints += 50;
    } else {
      var hoursElapsed = now.difference(lastRecordingTime!).inHours + 1;

      int pointsToAdd = 2 * min(hoursElapsed, 15);
      recordingPoints += pointsToAdd;
    }
    lastRecordingTime = now;
  }

}


class RecordingStatusWidget extends StatelessWidget {
  const RecordingStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final recordingState = Provider.of<RecordingState>(context);
    String dedicationLevel = '${recordingState.recordingPoints ~/ 100}';
    String lastRecord = recordingState.lastRecordingTime != null
        ? '${recordingState.lastRecordingActivity} at ${DateFormat('MMM dd, yyyy – kk:mm').format(recordingState.lastRecordingTime!)}'
        : 'No record';

    int nextLevelPoints = ((recordingState.recordingPoints ~/ 100) + 1) * 100;
    int pointsToNextLevel = nextLevelPoints - recordingState.recordingPoints;

    return BottomAppBar(
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Last Record: $lastRecord',
                    style: TextStyle(color: Colors.white),
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
                    Icon(Icons.star, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Dedication Level: $dedicationLevel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Next Level: $pointsToNextLevel pts',
                      style: TextStyle(color: Colors.white),
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