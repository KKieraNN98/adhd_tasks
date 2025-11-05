// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd_todo/model/app_model.dart';
import 'package:adhd_todo/data/local_store.dart';
import 'package:adhd_todo/view/list_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Launch to List Screen: app opens ListViewScreen without errors', (tester) async {
    // Arrange
    final appModel = AppModel(store: LocalStore());
    await appModel.initialize();

    // Act
    await tester.pumpWidget(MaterialApp(home: ListViewScreen(appModel: appModel)));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(ListViewScreen), findsOneWidget);
  });

  testWidgets('AppModel initializes without initialSettings param', (tester) async {
    // Arrange
    final appModel = AppModel(store: LocalStore());

    // Act
    await appModel.initialize();

    // Assert
    expect(appModel.settings, isNotNull);
    expect(appModel.settings.defaultTaskDuration.inMinutes, greaterThan(0));
    expect(appModel.tasks, isA<List>());
  });
}
