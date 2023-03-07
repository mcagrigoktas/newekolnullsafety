import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WebsiteDivider extends StatelessWidget {
  WebsiteDivider();
  final _color = Color.fromARGB(50, 150, 150, 150);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(right: 8),
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _color,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8),
          width: 50,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _color,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _color,
          ),
        ),
      ],
    )
        .animate()
        .move(
          delay: 140.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn();
  }
}
