import 'package:flutter_test/flutter_test.dart';
import 'package:spectogram/spectogram.dart';
import 'package:spectogram/spectogram_platform_interface.dart';
import 'package:spectogram/spectogram_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSpectogramPlatform
    with MockPlatformInterfaceMixin
    implements SpectogramPlatform {

  @override
  Future<void> configureBlackBackground() => Future.value();

  @override
  Future<void> configureWhiteBackground() => Future.value();

  @override
  Future<void> reset() => Future.value();

  @override
  Future<void> start()=> Future.value();

  @override
  Future<void> stop() => Future.value();
}

void main() {
  final SpectogramPlatform initialPlatform = SpectogramPlatform.instance;

  test('$MethodChannelSpectogram is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSpectogram>());
  });

  test('start', () async {
    Spectogram spectogramPlugin = Spectogram();
    await spectogramPlugin.start();
  });
}
