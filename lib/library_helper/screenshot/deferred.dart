import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

class DeferredScreenShotLibraryHelper {
  DeferredScreenShotLibraryHelper._();
  static Future<Uint8List> captureFromWidget(Widget widget, {BuildContext? context}) async {
    return ScreenshotController().captureFromWidget(widget, context: context);
  }
}
