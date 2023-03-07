// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../appbloc/appvar.dart';

class ClockWidget extends StatelessWidget {
  int? duration;
  int? fulltime;
  ClockWidget();

  String timeRemaining(context) {
    if (duration! >= fulltime!) return '✅'; // 'timeisup');
    final remaining = duration!.remainingTime;
    if (AppVar.questionPageController.kitapBilgileri.isDeneme) {
      return '${(remaining.hour * 60) + remaining.minute} ${'shortminute'.translate}';
    } else {
      return '${remaining.minute.toString().padLeft(2, '0')}:${remaining.second.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    duration = AppVar.questionPageController.gecenSure;
    fulltime = AppVar.questionPageController.testSuresi;

    //  final recognizer =   TapGestureRecognizer()..onTap = questionPageBloc.changeSaatTuru;

    if (AppVar.questionPageController.kitapBilgileri.isDeneme) {
      duration = (fulltime! - duration!).limit(0, AppVar.questionPageController.icindekilerItem!.denemeEndTime! - AppVar.questionPageController.realTime());
    } else {
      if (!AppVar.questionPageController.saatturu) duration = fulltime! - duration!;
    }

    if (fulltime == 0) return const SizedBox();

    Widget clockWidget = Container(
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
                        return timeRemaining(context);
                      })),
              initialValue: duration!.clamp(0.0, fulltime!.toDouble()).toDouble(),
              min: 0,
              max: fulltime!.toDouble(),
//          innerWidget: (value){
//            return Center(
//              child:   RichText(
//                textAlign: TextAlign.center,
//                text:   TextSpan(
//                  children: [
//                      TextSpan(
//                      recognizer: recognizer,
//                      text: timeRemaining(context),
//                      style: TextStyle(fontSize: 16.0,color: questionPageBloc.theme.bookColor,fontWeight: FontWeight.bold),
//                    ),
//                      TextSpan(
//                      recognizer: recognizer,
//                      text: "\n ${(fulltime/60/1000).toStringAsFixed(0)}  dk",
//                      style: TextStyle(fontSize: 10.0,color: questionPageBloc.theme.primaryTextColor),
//                    )
//                  ],
//                ),
//              ),
//            );
//          },
              onChange: (double value) {
                //  print(value);
              }),
        )

//      CustomPaint(
//        painter: ProgressPainter(duration: duration, fulltime: fulltime, color: questionPageBloc.theme.primaryTextColor,color2:questionPageBloc.theme.bookColor),
//        child:   Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//              RichText(
//              textAlign: TextAlign.center,
//              text:   TextSpan(
//                children: [
//                    TextSpan(
//                    recognizer: recognizer,
//                    text: timeRemaining(context),
//                    style: TextStyle(fontSize: 16.0,color: questionPageBloc.theme.bookColor,fontWeight: FontWeight.bold),
//                  ),
//                   TextSpan(
//                    recognizer: recognizer,
//                    text: "\n ${(fulltime/60/1000).toStringAsFixed(0)}  dk",
//                    style: TextStyle(fontSize: 10.0,color: questionPageBloc.theme.primaryTextColor),
//                  )
//                ],
//              ),
//            ),
//
//          ],
//        ),
//      ),

        );

    return clockWidget;
  }
}

// class ProgressPainter extends CustomPainter {
//   ProgressPainter({
//     @required this.duration,
//     @required this.fulltime,
//     @required this.color,
//     @required this.color2,
//   });

//   final int duration;
//   Color color;
//   Color color2;
//   final int fulltime;

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = color
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;

//     canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
//     //  canvas.drawCircle(size.center(Offset.zero), size.width / 2.0 -6, paint);

//     paint.color = color2;
//     double progressRadians = (duration / fulltime) * 2 * math.pi;

//     canvas.drawArc(Offset.zero & size, math.pi * 1.5, progressRadians, false, paint);
//     //  canvas.drawArc(new Rect.fromCircle(center: Offset(size.width/2, size.width/2) ,radius: size.width / 2.0 -6), math.pi * 1.5, -progressRadians, false, paint);
//   }

//   @override
//   bool shouldRepaint(ProgressPainter oldDelegate) {
//     return false;
//   }
// }
