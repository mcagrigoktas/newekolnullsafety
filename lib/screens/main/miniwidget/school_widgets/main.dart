import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../app_widgets/z_mainwidget.dart';

///Okulun olusturdugu widgetlari cizer

class WidgetBox extends StatelessWidget {
  final double maxHeight;
  final String imageAsset;
  final Color? titleColor;
  final String? title;
  final String? subTitle;
  final Widget child;
  final bool isGoPageButtonEnable;
  final Widget? trailingWidget;
  WidgetBox({
    this.maxHeight = 170,
    required this.imageAsset,
    required this.child,
    this.isGoPageButtonEnable = false,
    this.subTitle,
    this.title,
    this.titleColor,
    this.trailingWidget,
  });
  @override
  Widget build(BuildContext context) {
    Widget current = Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
          color: Fav.design.others['widget.primaryBackground'],
          // gradient: Colors.white.hueGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xff2C2E60).withOpacity(0.01), blurRadius: 2, spreadRadius: 2, offset: const Offset(0, 0)),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(imageAsset, width: 32),
                8.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title.text.color(titleColor!).fontSize(18).bold.make(),
                      if (subTitle != null) subTitle.text.color(Fav.design.widgetSecondaryText!).maxLines(1).make(),
                    ],
                  ),
                ),
                if (trailingWidget != null) trailingWidget!
              ],
            ),
          ),
          Expanded(child: Center(child: child)),
          if (isGoPageButtonEnable)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
              child: Align(alignment: Alignment.topRight, child: ('gopage'.translate + ' >').text.bold.make()),
            ),
        ],
      ),
    );

    return current.p2;
  }
}
