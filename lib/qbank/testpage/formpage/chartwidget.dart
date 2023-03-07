import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class ChartWidget extends StatelessWidget {
  final int? ds, ys, bs;
  final bool mini;

  ChartWidget({this.ds, this.ys, this.bs, this.mini = true});
  @override
  Widget build(BuildContext context) {
    double width = 80.0;
    if (mini) {
      width /= 2.5;
    }
    double height = 60.0;
    if (mini) {
      height /= 2.5;
    }
    int? max;
    if (ds! >= ys! && ds! >= bs!) {
      max = ds;
    } else if (ys! >= ds! && ys! >= bs!) {
      max = ys;
    } else {
      max = bs;
    }
    if (max == 0) {
      max = 1;
    }

    return SizedBox(
        width: width,
        height: mini ? height + 10.0 : height + 16.0,
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: mini ? 2.0 : 4.0),
                        height: height * (ds! / max!),
                        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.green, Colors.green], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: mini ? 2.0 : 4.0),
                          height: height * (ys! / (max)),
                          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xffD32A0F), Color(0xffAF1909)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: mini ? 2.0 : 4.0),
                          height: height * (bs! / (max)),
                          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xffC9D6FF), Color(0xffE2E2E2)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                        )),
                  ],
                )),
            SizedBox(
              height: mini ? 2.0 : 4.0,
            ),
            //tododanger Burda yazi rengi ekolden gelip gelmeme durumuna gore degistirilimeli
            Container(
              width: width,
              height: mini ? 4.0 : 8.0,
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: Fav.design.primaryText),
            )
          ],
        ));
  }
}
