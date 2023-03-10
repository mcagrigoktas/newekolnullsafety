import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../assets.dart';
import '../../../helpers/glassicons.dart';
import '../../main/macos_dock/macos_dock.dart';

class OtherWidgetForMainMenu extends StatelessWidget {
  OtherWidgetForMainMenu();
  @override
  Widget build(BuildContext context) {
    final _macosDockController = Get.find<MacOSDockController>();

    return Obx(() {
      final _data = _macosDockController.extraMenuWidgets;
      if (_data.isEmpty) return SizedBox();

      List<Widget> _widgetList = [];

      if (_data['birthday'] != null) {
        _widgetList.add(Container(
          decoration: BoxDecoration(color: Fav.design.others['widget.primaryBackground'], borderRadius: BorderRadius.circular(24), boxShadow: [
            BoxShadow(
              color: const Color(0xff2C2E60).withOpacity(0.01),
              blurRadius: 2,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ]),
          child: Row(
            children: [
              16.widthBox,
              RiveSimpeLoopAnimation.asset(
                url: Assets.rive.ekolRIV,
                artboard: 'HAPPY_BIRTHDAY',
                animation: 'play',
                width: 120,
                heigth: 120,
              ),
              16.widthBox,
              Expanded(
                child: Column(
                  children: [
                    'happybirthday'.translate.text.center.fontSize(36).bold.color(GlassIcons.agenda.color).autoSize.maxLines(1).make(),
                    (_data['birthday']!['name'] as String?).text.fontSize(24).bold.center.make(),
                  ],
                ),
              ),
              16.widthBox,
            ],
          ),
        ));
      }

      return Column(
        children: _widgetList,
      ).pt16;
    });
  }
}
