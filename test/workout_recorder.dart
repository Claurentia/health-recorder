import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hw1/workout_recorder.dart';
import 'package:hw1/recording_state_provider.dart';

void main() {
  testWidgets('Workout details inputted is recorded along with the time it is picked', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (context) => RecordingState(),
      child: const MaterialApp(home: WorkoutRecorder()),
    ));

    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Swimming').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '30');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record Workout'));
    DateTime recordTime = DateTime.now();
    await tester.pumpAndSettle();

    expect(find.text(' Swimming - 30 minutes'), findsWidgets);

    String date = DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);
    int calBurned = 30 * 10;
    expect(find.text(' Calories burned: $calBurned cal \n Recorded at $date'), findsOneWidget);
  });
}