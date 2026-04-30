import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_translator_platform_interface.dart';

/// An implementation of [NativeTranslatorPlatform] that uses method channels.
class MethodChannelNativeTranslator extends NativeTranslatorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_translator');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> translateText({
    required String text,
    int backgroundColorRed = 255,
    int backgroundColorGreen = 255,
    int backgroundColorBlue = 255,
    int backgroundColorAlpha = 255,
  }) async {
    await methodChannel.invokeMethod<void>('translateText', {
      'text': text,
      'backgroundColorRed': backgroundColorRed,
      'backgroundColorGreen': backgroundColorGreen,
      'backgroundColorBlue': backgroundColorBlue,
      'backgroundColorAlpha': backgroundColorAlpha,
    });
  }
}
