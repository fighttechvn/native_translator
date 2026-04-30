// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:native_translator/native_translator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final NativeTranslator plugin = NativeTranslator();
    final String? version = await plugin.getPlatformVersion();
    // The version string depends on the host platform running the test, so
    // just assert that some non-empty string is returned.
    expect(version?.isNotEmpty, true);
  });

  testWidgets('translateText test', (WidgetTester tester) async {
    final NativeTranslator plugin = NativeTranslator();
    // The native call should complete without throwing any exception.
    // Testing the actual UI presentation requires manual testing or UI automation testing tools
    // that go beyond typical Flutter widget tests, but this ensures the method channel works.
    await expectLater(plugin.translateText(text: 'Hello World'), completes);
  });
}
