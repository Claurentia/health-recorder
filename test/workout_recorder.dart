import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hw1/workout_recorder.dart';
import 'package:intl/intl.dart'; // Replace with your actual import

void main() {
  testWidgets('Workout details appear in the list after entry', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: WorkoutRecorder()));

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