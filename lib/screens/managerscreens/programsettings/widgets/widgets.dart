import 'package:flutter/material.dart';

class TimeTableContainer extends StatelessWidget {
  final Alignment alignment;
  final double? width;
  final double? height;
  final double verticalMargin;
  final double horizantalMargin;
  final double verticalPadding;
  final double horizantalPadding;
  final Color? color;
  final double borderRadius;
  final dynamic child;

  TimeTableContainer({
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.verticalMargin = 0,
    this.horizantalMargin = 0,
    this.verticalPadding = 0,
    this.horizantalPadding = 0,
    this.color,
    this.borderRadius = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      margin: EdgeInsets.symmetric(vertical: verticalMargin, horizontal: horizantalMargin),
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizantalPadding),
      alignment: alignment,
      width: width,
      height: height,
      decoration: color == null ? null : BoxDecoration(color: color, borderRadius: BorderRadius.circular(borderRadius), boxShadow: [BoxShadow(color: color!.withAlpha(180), blurRadius: 1)]),
    );
  }
}
