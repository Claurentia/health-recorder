import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class RecordingState extends ChangeNotifier {
  DateTime? lastRecordingTime;
  String lastRecordingActivity = 'no record';
  int recordingPoints = 0;

  int recordActivity(String activity) {
    lastRecordingActivity = activity;
    int ptsEarned = _calculatePoints();
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

    return Container(
        color: Colors.blueGrey, // Background color
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
                      'Last Record: $lastRecord',
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
                        'Dedication Level: $dedicationLevel',
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
                        'Next Level: $pointsToNextLevel pts ',
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
