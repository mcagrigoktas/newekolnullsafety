import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class MyListedCard extends StatelessWidget {
  final int? number;
  final Widget? child;
  final Function()? closePressed;
  final Function()? downPressed;
  final Function()? tapPressed;
  final IconData? iconData;
  MyListedCard({this.child, this.number, this.closePressed, this.iconData, this.downPressed, this.tapPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 12),
            margin: const EdgeInsets.only(left: 8.0, right: 8, top: 12.0, bottom: 8),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 2.0), BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 2.0)],
              color: Fav.design.card.background,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Fav.design.primary,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tapPressed != null) Icons.keyboard_arrow_up.icon.color(Colors.white.withAlpha(200)).padding(0).size(24).onPressed(tapPressed!).make() else SizedBox(height: 24),
                      "$number".text.maxLines(1).color(Colors.white).autoSize.fontSize(24).bold.make(),
                      if (downPressed != null) Icons.keyboard_arrow_down.icon.color(Colors.white.withAlpha(200)).padding(0).size(24).onPressed(downPressed!).make() else SizedBox(height: 24),
                    ],
                  ),
                ),
                4.widthBox,
                Expanded(child: child!),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (closePressed != null)
                CircleAvatar(
                  backgroundColor: Fav.design.scaffold.background,
                  radius: 12,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: closePressed,
                    icon: Icon(
                      iconData ?? Icons.clear,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
