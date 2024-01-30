import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hw1/emotion_recorder.dart';
import 'package:hw1/recording_state_provider.dart';

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
}