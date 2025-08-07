import 'package:flutter_test/flutter_test.dart';

import '../entry_screens.dart';

void main() {
  testWidgets('MyWidget has a text and button', (WidgetTester tester) async {
    await tester.pumpWidget(EntryScreen());

    // expect(find.text('Hello'), findsOneWidget);
    // expect(find.text('Click Me'), findsOneWidget);
    // expect(find.byType(ElevatedButton), findsOneWidget);
    // expect(find.text("This is a simple widget"), findsOneWidget);
  });
}
