import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class TimeTableLessonCellWidget extends StatelessWidget {
  final Function()? onTap;
  final Color? boxColor;
  final Color? boxShadowColor;
  final String? text1;
  final String? text2;
  final double? width;
  final double? height;
  final TextStyle? text1Style;
  final TextStyle? text2Style;
  final Widget? child;
  final bool autoFitChild;

  TimeTableLessonCellWidget({
    this.onTap,
    this.boxColor,
    this.text1,
    this.text2,
    this.boxShadowColor,
    this.width,
    this.height,
    this.text1Style,
    this.text2Style,
    this.child,
    this.autoFitChild = false,
  });

  @override
  Widget build(BuildContext context) {
    String? finalText;
    if (text1.safeLength < 1 && text2.safeLength > 0) {
      finalText = text2;
    }

    Widget _current = child ??
        (finalText == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  if (text1 != null) Text(text1!, style: text1Style ?? const TextStyle(color: Colors.white, fontSize: 14, height: 0.8)),
                  if (text2 != null) Text(text2!, style: text2Style ?? const TextStyle(color: Colors.white, fontSize: 11)),
                ],
              )
            : Text(finalText, style: text1Style ?? const TextStyle(color: Colors.white, fontSize: 14, height: 0.8)));

    if (autoFitChild) {
      _current = FittedBox(
        child: _current,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
          alignment: Alignment.center,
          decoration: boxColor == null
              ? null
              : BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [BoxShadow(color: boxShadowColor ?? const Color(0xff24262A).withAlpha(180), blurRadius: 1)],
                ),
          width: width ?? (kIsWeb ? 70 : 50),
          height: height ?? (kIsWeb ? 42 : 30),
          margin: const EdgeInsets.all(1),
          child: _current),
    );
  }
}
