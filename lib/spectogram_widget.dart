import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class IOSSpectogramWidget extends StatelessWidget {

  // This is used in the platform side to register the view.
  final String viewType;
  // Pass parameters to the platform side.
  final Map<String, dynamic>? creationParams;

  const IOSSpectogramWidget({super.key, required this.viewType, this.creationParams});

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class AndroidSpectogramWidget extends StatelessWidget {

  // This is used in the platform side to register the view.
  final String viewType;
  // Pass parameters to the platform side.
  final Map<String, dynamic>? creationParams;

  const AndroidSpectogramWidget({super.key, required this.viewType, this.creationParams});

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory:
          (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}

class SpectogramWidget extends StatelessWidget {
  const SpectogramWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'SpectogramView';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const AndroidSpectogramWidget(viewType: viewType);
      case TargetPlatform.iOS:
        return const IOSSpectogramWidget(viewType: viewType);
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}