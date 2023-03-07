import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathWidget extends StatelessWidget {
  final Color? color;
  final String data;
  final TextStyle? textStyle;
  final double? fontSize;
  final bool bold;
  MathWidget({this.color, required this.data, this.textStyle, this.fontSize, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      data,
      textStyle: TextStyle(
        fontSize: (fontSize ?? textStyle!.fontSize ?? 19) + 1,
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      options: MathOptions(
        style: MathStyle.display,
        fontSize: (fontSize ?? textStyle!.fontSize ?? 19) + 1,
        color: color!,
        mathFontOptions: FontOptions(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'SansSerif',
        ),
        textFontOptions: FontOptions(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'SansSerif',
        ),
        //  baseSizeMultiplier: fontSize / 19 ?? textStyle.fontSize / 19,
      ),
      onErrorFallback: (err) => Text(
        'Formule is Error',
        style: textStyle,
      ),
    );

    // Math.tex(
    //   data,
    //   options: MathOptions(
    //     style: MathStyle.display,
    //     color: color,
    //     mathFontOptions: FontOptions(
    //       fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    //       fontFamily: 'SansSerif',
    //     ),
    //     textFontOptions: FontOptions(
    //       fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    //       fontFamily: 'SansSerif',
    //     ),
    //     // logicalPpi: lazim olursa asagidakinden hesapla
    //     // baseSizeMultiplier: fontSize / 19 ?? textStyle.fontSize / 19,
    //   ),
    //   onErrorFallback: (err) => Text(
    //     '**Error**',
    //     style: textStyle,
    //   ),
    // );
  }
}
