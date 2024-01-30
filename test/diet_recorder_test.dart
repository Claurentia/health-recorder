import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hw1/diet_recorder.dart';
import 'package:hw1/recording_state_provider.dart';

void main() {
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
}
