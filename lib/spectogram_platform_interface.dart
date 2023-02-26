import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'spectogram_method_channel.dart';

abstract class SpectogramPlatform extends PlatformInterface {
  /// Constructs a SpectogramPlatform.
  SpectogramPlatform() : super(token: _token);

  static final Object _token = Object();

  static SpectogramPlatform _instance = MethodChannelSpectogram();

  /// The default instance of [SpectogramPlatform] to use.
  ///
  /// Defaults to [MethodChannelSpectogram].
  static SpectogramPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SpectogramPlatform] when
  /// they register themselves.
  static set instance(SpectogramPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> configureWhiteBackground() {
    throw UnimplementedError('configureWhiteBackground() has not been implemented.');
  }

  Future<void> configureBlackBackground() {
    throw UnimplementedError('configureBlackBackground() has not been implemented.');
  }

  Future<void> setWidget() async {
    throw UnimplementedError('setWidget has not been implemented.');
  }

  Future<void> start() {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> reset() {
    throw UnimplementedError('reset() has not been implemented.');
  }

}
