import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'spectogram_platform_interface.dart';

/// An implementation of [SpectogramPlatform] that uses method channels.
class MethodChannelSpectogram extends SpectogramPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('spectogram');

  @override
  Future<void> configureWhiteBackground()  {
    return methodChannel.invokeMethod<void>('configureWhiteBackground');
  }

  @override
  Future<void> configureBlackBackground() {
    return methodChannel.invokeMethod<void>('configureBlackBackground');
  }

  @override
  Future<void> setWidget() async {
    return await methodChannel.invokeMethod('setWidget');
  }

  @override
  Future<void> start() {
    return methodChannel.invokeMethod<void>('start');
  }

  @override
  Future<void> stop() {
    return methodChannel.invokeMethod<void>('stop');
  }

  @override
  Future<void> reset() {
    return methodChannel.invokeMethod<void>('reset');
  }
}
