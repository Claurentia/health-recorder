import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hw1/diet_recorder.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('Food item recorded appears in the list with calorie count', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DietRecorder()));

    await tester.enterText(find.byType(TextField).at(0), 'Apple');
    await tester.enterText(find.byType(TextField).at(1), '95');
    await tester.tap(find.text('Record Diet'));
    DateTime recordTime = DateTime.now();
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsWidgets);

    String date = DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);
    expect(find.text(' Calories: 95 cal \n Recorded at $date'), findsWidgets);

    // await tester.tap(find.byIcon(Icons.arrow_drop_down));
    // await tester.pumpAndSettle();

    final dropdown = find.byKey(const Key('dropdown'));
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final dropdownItem = find.text('Apple').last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Apple'), findsOneWidget);
  });
}
