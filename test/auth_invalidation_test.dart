import 'package:flutter_test/flutter_test.dart';
import 'package:econoris_app/main.dart';
import 'package:econoris_app/services/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('redirects to LoginPage when session invalidated', (WidgetTester tester) async {
  // provide mock shared preferences so _loadLocal completes
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const EconorisApp());

    // Ensure app built
    await tester.pumpAndSettle();

    // Simulate invalidation (as if server returned 401)
    await AuthManager.instance.invalidateSession();

    // Wait for navigation to settle
    await tester.pumpAndSettle();

    // Expect LoginPage present: check for 'Se connecter' button text
    expect(find.text('Se connecter'), findsOneWidget);
  });
}
