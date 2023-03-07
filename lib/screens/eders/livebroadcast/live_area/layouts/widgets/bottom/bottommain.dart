import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../controller.dart';
import 'here.dart';

class LiveLayoutBotttom extends StatelessWidget {
  LiveLayoutBotttom();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    double height = 0;
    Widget current = const SizedBox();

    if (controller.videoChatSettings.isRollCallEnable) {
      height = 40;
      current = HereButton();
    }

    return AnimatedContainer(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      duration: 333.milliseconds,
      child: current,
    );
  }
}
