import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:spectogram/spectogram.dart';
import 'package:spectogram/spectogram_widget.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  late bool _started;

  @override
  void initState() {
    super.initState();

    _started = false;
  }

  final _spectogramPlugin = Spectogram();

  Widget makeFloatingButton() {

    Icon icon;
    if (_started) {
      icon = const Icon(Icons.stop);
    } else {
      icon = const Icon(Icons.play_arrow);
    }

    return FloatingActionButton(onPressed: _onFloatingButtonPressed, child: icon);
  }

  void _onFloatingButtonPressed() {
    if (_started) {
      _spectogramPlugin.stop();
    } else {
      _spectogramPlugin.start().catchError((error, stackTrace) async {
        if (error is PlatformException) {
          String code = error.code;
          if (code == "requiresMicrophoneAccess") {
            //TODO: Localize
            final result = await FlutterPlatformAlert.showCustomAlert(windowTitle: "Error",
                text: "Spectogram needs access to microphone!",
                positiveButtonTitle: "Ok",
                neutralButtonTitle: "Open settings");

            if (result == CustomButton.neutralButton) {
              //TODO: open settings
            }
          }
        }
      });
    }

    setState(() {
      _started = !_started;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: SpectogramWidget(),
        ),
          floatingActionButton: makeFloatingButton(),
      ),
    );
  }
}
