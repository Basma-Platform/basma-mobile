import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/language/app_localizations.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/task_form_screen.dart';

void main() {
  testWidgets('shows English text and switches to Arabic', (tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('مهامي'), findsOneWidget);
    expect(find.text('إضافة مهمة'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('allows editing a task that already has a past due date', (
    tester,
  ) async {
    final task = Task(
      id: 'old-task',
      title: 'Old task',
      dueDate: DateTime(2020, 1, 15),
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      AppLocalizations(
        locale: const Locale('en'),
        onLocaleChanged: (_) {},
        child: MaterialApp(home: TaskFormScreen(task: task)),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
