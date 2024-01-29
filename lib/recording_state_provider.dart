import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class RecordingState extends ChangeNotifier {
  DateTime? lastRecordingTime;
  int recordingPoints = 0;

  void recordActivity() {
    _calculatePoints();
    notifyListeners();
  }

  void _calculatePoints() {
    var now = DateTime.now();
    if (lastRecordingTime == null) {
      recordingPoints += 100;
    } else {
      var hoursElapsed = now.difference(lastRecordingTime!).inHours + 1;

      int pointsToAdd = min(hoursElapsed, 15);
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
    String dedicationLevel = 'Level ${recordingState.recordingPoints ~/ 100}';
    String lastRecordTime = recordingState.lastRecordingTime != null
        ? DateFormat('MMM dd, yyyy – kk:mm').format(recordingState.lastRecordingTime!)
        : 'No record';

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
                    'Last Recorded: $lastRecordTime',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Dedication Level: $dedicationLevel',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}