import 'package:flutter_test/flutter_test.dart';
import 'package:native_translator/native_translator.dart';
import 'package:native_translator/native_translator_platform_interface.dart';
import 'package:native_translator/native_translator_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeTranslatorPlatform
    with MockPlatformInterfaceMixin
    implements NativeTranslatorPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> translateText({
    required String text,
    int backgroundColorRed = 255,
    int backgroundColorGreen = 255,
    int backgroundColorBlue = 255,
    int backgroundColorAlpha = 255,
  }) async {}
}

void main() {
  final NativeTranslatorPlatform initialPlatform =
      NativeTranslatorPlatform.instance;

  test('$MethodChannelNativeTranslator is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeTranslator>());
  });

  test('getPlatformVersion', () async {
    NativeTranslator nativeTranslatorPlugin = NativeTranslator();
    MockNativeTranslatorPlatform fakePlatform = MockNativeTranslatorPlatform();
    NativeTranslatorPlatform.instance = fakePlatform;

    expect(await nativeTranslatorPlugin.getPlatformVersion(), '42');
  });

  test('translateText', () async {
    NativeTranslator nativeTranslatorPlugin = NativeTranslator();
    MockNativeTranslatorPlatform fakePlatform = MockNativeTranslatorPlatform();
    NativeTranslatorPlatform.instance = fakePlatform;

    await expectLater(
      nativeTranslatorPlugin.translateText(text: 'Hello'),
      completes,
    );
  });
}
