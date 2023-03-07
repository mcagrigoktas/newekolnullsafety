import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class MainScreenBackgroundWidget extends StatelessWidget {
  final Widget? child;
  MainScreenBackgroundWidget({this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xaa3EE689),
          Color(0xaa3EE689),
          Color(0xaaFF4A79),
          Color(0xaaFF4A79),
          Color(0xaa97D33F),
          Color(0xaa97D33F),
          Color(0xaaFF9F26),
        ],
        stops: [0.19, 0.21, 0.34, 0.36, 0.62, 0.64, 1.0],
      )),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Fav.design.others['widget.pageBackground'],
        child: child,
      ),
    );
    // return Container(
    //   color: Fav.design.scaffold.background,
    //   width: double.infinity,
    //   height: double.infinity,
    //   child: child,
    // );
  }
}
