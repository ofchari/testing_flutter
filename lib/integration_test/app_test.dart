import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Full app flow test", (WidgetTester tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // // Check if login page is shown
    // expect(find.text('Login'), findsOneWidget);
    //
    // // Fill form
    // await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
    // await tester.enterText(find.byKey(Key('password_field')), '123456');
    //
    // // Tap login
    // await tester.tap(find.byKey(Key('login_button')));
    // await tester.pumpAndSettle();
    //
    // // After login, should go to dashboard
    // expect(find.text('Welcome'), findsOneWidget);
  });
}
