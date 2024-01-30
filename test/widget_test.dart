import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hw1/workout_recorder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hw1/emotion_recorder.dart';
import 'package:hw1/recording_state_provider.dart';
import 'package:hw1/diet_recorder.dart';

void main() {
  testWidgets('Emoji selected is recorded along with the time it is picked', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (context) => RecordingState(),
      child: const MaterialApp(home: EmotionRecorder()),
    ));

    await tester.tap(find.text('Select Mood'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('😀').first);
    DateTime recordTime = DateTime.now();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('yourMoodTodayKey')), findsOneWidget);

    final emojiListFinder = find.byKey(const Key('moodHistoryList'));
    expect(find.descendant(of: emojiListFinder, matching: find.text('😀')), findsOneWidget);

    String date = DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);
    expect(find.text('Selected on: $date'), findsOneWidget);
  });

  testWidgets('Food item is recorded and appears in the dropdown menu list', (WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (context) => RecordingState(),
      child: const MaterialApp(home: DietRecorder()),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'Apple');
    await tester.enterText(find.byType(TextField).at(1), '95');
    await tester.tap(find.text('Record Diet'));
    DateTime recordTime = DateTime.now();
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsWidgets);

    String date = DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);
    expect(find.text(' Calories: 95 cal \n Recorded at $date'), findsWidgets);

    final dropdown = find.byKey(const Key('dropdown'));
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final dropdownItem = find.text('Apple').last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Apple'), findsOneWidget);
  });

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
