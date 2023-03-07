import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../appbloc/appvar.dart';

class ClockWidget extends StatelessWidget {
  final int? duration;
  final int? fulltime;
  ClockWidget({this.duration, this.fulltime});

  String _timeRemaining(context) {
    if (duration! >= fulltime!) return '✅'; // 'timeisup');
    final remaining = duration!.remainingTime;
    return '${remaining.minute.toString().padLeft(2, '0')}:${remaining.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (fulltime == null || fulltime == 0) {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Fav.design.primaryText.withAlpha(10)),
          child: '${duration!.remainingTime.minute.toString().padLeft(2, '0')}:${duration!.remainingTime.second.toString().padLeft(2, '0')}'.text.make());
    }

    Widget _clockWidget = Container(
        margin: const EdgeInsets.all(16),
        //  width: 70,height: 70,
        child: AbsorbPointer(
          absorbing: true,
          child: SleekCircularSlider(
              appearance: CircularSliderAppearance(
                  angleRange: 360,
                  animationEnabled: true,
                  size: 100,
                  startAngle: 90,
                  infoProperties: InfoProperties(
                      bottomLabelText: "\n ${(fulltime! / 60 / 1000).toStringAsFixed(0)}  ${'shortminute'.translate}",
                      mainLabelStyle: TextStyle(fontSize: 16.0, color: AppVar.questionPageController.theme!.bookColor, fontWeight: FontWeight.bold),
                      bottomLabelStyle: TextStyle(fontSize: 10.0, color: AppVar.questionPageController.theme!.primaryTextColor),
                      modifier: (value) {
                        return _timeRemaining(context);
                      })),
              initialValue: duration!.clamp(0.0, fulltime!.toDouble()).toDouble(),
              min: 0,
              max: fulltime!.toDouble(),
              onChange: (double value) {}),
        ));

    return _clockWidget;
  }
}
