import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'controller.dart';
import 'drawer.dart';
import 'timetable.dart';

class TimeTableEditView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimaTableEditController>(
        init: TimaTableEditController(),
        builder: (controller) {
          return AppScaffold(
            scaffoldKey: controller.scaffoldKey,
            drawerPanel: DrawerPanel(
                drawer: Drawer(
                  child: DrawerWidget(),
                ),
                isRightDrawer: true),
            topBar: TopBar(
              leadingTitle: 'menu1'.translate,
              trailingActions: [
                IconButton(
                  icon: Icon(Icons.print, color: Fav.design.appBar.text),
                  onPressed: () {
                    controller.drawerType = DrawerType.print;
                    controller.scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_list_numbered_rounded, color: Fav.design.appBar.text),
                  onPressed: () {
                    controller.drawerType = DrawerType.settings;
                    controller.scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Fav.design.appBar.text),
                  onPressed: () {
                    controller.drawerType = DrawerType.menu;
                    controller.scaffoldKey.currentState!.openEndDrawer();
                  },
                )
              ],
              middle: 'timetables'.translate.text.bold.color(Fav.design.primary).make(),
            ),
            body: Body.child(child: controller.isPageLoading ? MyProgressIndicator(isCentered: true) : TimeTable()),
          );
        });
  }
}
