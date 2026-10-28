import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login_app/drag_drop_screen.dart';
import 'package:flutter_login_app/otp_screen.dart';
import 'package:flutter_login_app/records_screen.dart';

void main() {
  test('PhoneInputFormatter formats digits and caps at 10', () {
    String fmt(String input) => PhoneInputFormatter()
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input))
        .text;
    expect(fmt('5'), '(5');
    expect(fmt('5321'), '(532) 1');
    expect(fmt('53212345'), '(532) 123 45');
    expect(fmt('5321234567999'), '(532) 123 45 67');
  });

  testWidgets('Swipe left deletes after confirm, undo restores', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordsScreen()));
    await tester.pump(const Duration(milliseconds: 1)); // chaosDelay

    await tester.drag(find.byKey(const Key('record-item-1')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-confirm-yes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record-item-1')), findsNothing);

    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record-item-1')), findsOneWidget);
  });

  testWidgets('Swipe right opens detail screen; edit is saved', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordsScreen()));
    await tester.pump(const Duration(milliseconds: 1));

    await tester.drag(find.byKey(const Key('record-item-2')), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record-detail-scaffold')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('record-title-input')), 'Düzenlendi');
    await tester.tap(find.byKey(const Key('record-save-button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Düzenlendi'), findsOneWidget);
    expect(find.byKey(const Key('record-item-2')), findsOneWidget);
  });

  testWidgets('Swipe left reveals edit + delete side by side; delete works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordActionsScreen()));
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byKey(const Key('record-delete-1')), findsNothing);

    await tester.drag(find.byKey(const Key('record-item-1')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    final edit = tester.getCenter(find.byKey(const Key('record-edit-1')));
    final delete = tester.getCenter(find.byKey(const Key('record-delete-1')));
    expect(edit.dy, delete.dy);
    expect(edit.dx, lessThan(delete.dx));

    await tester.tap(find.byKey(const Key('record-delete-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-confirm-yes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record-item-1')), findsNothing);
  });

  testWidgets('Drag task to done zone', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DragDropScreen()));
    final target = tester.getCenter(find.byKey(const Key('drop-zone-done')));
    await tester.dragFrom(tester.getCenter(find.byKey(const Key('drag-task-1'))),
        target - tester.getCenter(find.byKey(const Key('drag-task-1'))));
    await tester.pumpAndSettle();
    expect(find.text('Tamamlandı (1)'), findsOneWidget);
    expect(find.text('Yapılacak (4)'), findsOneWidget);
  });
}
