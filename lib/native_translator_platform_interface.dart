import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_translator_method_channel.dart';

abstract class NativeTranslatorPlatform extends PlatformInterface {
  /// Constructs a NativeTranslatorPlatform.
  NativeTranslatorPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeTranslatorPlatform _instance = MethodChannelNativeTranslator();

  /// The default instance of [NativeTranslatorPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeTranslator].
  static NativeTranslatorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeTranslatorPlatform] when
  /// they register themselves.
  static set instance(NativeTranslatorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> translateText({
    required String text,
    int backgroundColorRed = 255,
    int backgroundColorGreen = 255,
    int backgroundColorBlue = 255,
    int backgroundColorAlpha = 255,
  }) {
    throw UnimplementedError('translateText() has not been implemented.');
  }
}
