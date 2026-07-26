import 'package:bhoomisetu/app.dart';
import 'package:bhoomisetu/core/storage/preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('cold start with no stored session lands on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
        ],
        child: const BhoomiSetuApp(),
      ),
    );

    // First frame: splash, while session restore is in flight. Both screens
    // animate indefinitely, so pump a bounded number of frames instead of
    // pumpAndSettle (which would time out waiting for animations to finish).
    await tester.pump();
    expect(find.text('BhoomiSetu'), findsOneWidget);

    // Session restore resolves (no stored session in this test environment)
    // and the router redirect sends us to the login screen.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
