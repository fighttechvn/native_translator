import 'native_translator_platform_interface.dart';

class NativeTranslator {
  Future<String?> getPlatformVersion() {
    return NativeTranslatorPlatform.instance.getPlatformVersion();
  }

  Future<void> translateText({
    required String text,
    int backgroundColorRed = 255,
    int backgroundColorGreen = 255,
    int backgroundColorBlue = 255,
    int backgroundColorAlpha = 255,
  }) {
    return NativeTranslatorPlatform.instance.translateText(
      text: text,
      backgroundColorRed: backgroundColorRed,
      backgroundColorGreen: backgroundColorGreen,
      backgroundColorBlue: backgroundColorBlue,
      backgroundColorAlpha: backgroundColorAlpha,
    );
  }
}
