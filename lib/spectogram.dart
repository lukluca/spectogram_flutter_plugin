
import 'package:spectogram/spectogram_platform_interface.dart';

class Spectogram {

  Future<void> configureWhiteBackground()  {
    return SpectogramPlatform.instance.configureWhiteBackground();
  }

  Future<void> configureBlackBackground()  {
    return SpectogramPlatform.instance.configureBlackBackground();
  }

  Future<void> setWidget() async {
    return await SpectogramPlatform.instance.setWidget();
  }

  Future<void> start() {
    return SpectogramPlatform.instance.start();
  }

  Future<void> stop() {
    return SpectogramPlatform.instance.stop();
  }

  Future<void> reset() {
    return SpectogramPlatform.instance.reset();
  }
}
