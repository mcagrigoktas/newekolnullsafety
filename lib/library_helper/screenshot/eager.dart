import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'deferred.dart' deferred as eager;

class ScreenShotLibraryHelper {
  ScreenShotLibraryHelper._();
  static Future<Uint8List> captureFromWidget(Widget widget, {BuildContext? context}) async {
    await eager.loadLibrary();
    return eager.DeferredScreenShotLibraryHelper.captureFromWidget(widget, context: context);
  }
}
