import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spectogram/spectogram_method_channel.dart';

void main() {
  MethodChannelSpectogram platform = MethodChannelSpectogram();
  const MethodChannel channel = MethodChannel('spectogram');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('start', () async {
    await platform.start();
  });
}
