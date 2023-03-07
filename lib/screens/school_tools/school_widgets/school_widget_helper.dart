import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/glassicons.dart';
import '../../main/widgetsettingspage/model.dart';
import '../prepare_my_student/tool_item_widget.dart';

part 'counter.dart';

class SchoolWidgetHelper {
  SchoolWidgetHelper._();

  static List<Widget>? getLinkWidgets() {
    final _allSchoolWidgets = _getAllFilteredWidgets();
    final _linkWidgetList = _allSchoolWidgets.where((wdgt) => wdgt.isLinkWidget).toList();
    if (_linkWidgetList.isEmpty) return null;
    return _linkWidgetList
        .map((e) => ToolItem(
              text: e.name,
              onTap: () {
                e.linkWidgetUrl.launch(LaunchType.url);
              },
              imgUrl: e.linkWidgetImageUrl,
            ))
        .toList();
  }

  static List<Widget>? getCounterWidgets() {
    final _allSchoolWidgets = _getAllFilteredWidgets();
    final _counterWidgetList = _allSchoolWidgets.where((wdgt) => wdgt.isCounterWidget).toList();
    if (_counterWidgetList.isEmpty) return null;
    final _now = DateTime.now().millisecondsSinceEpoch;
    _counterWidgetList.sort((i1, i2) {
      if (i1.countTime < _now && i2.countTime > _now) return i2.countTime - i1.countTime;
      if (i1.countTime > _now && i2.countTime < _now) return i2.countTime - i1.countTime;
      return i1.countTime - i2.countTime;
    });
    return _counterWidgetList.map((e) => _CounterWidget(e)).toList();
  }

  static List<WidgetModel> _getAllFilteredWidgets() {
    return AppVar.appBloc.schoolInfoService!.singleData!.widgetList.where((item) {
      if (AppVar.appBloc.hesapBilgileri.gtM) return true;

      if (AppVar.appBloc.hesapBilgileri.gtT) {
        if (item.targetList!.contains("alluser") || item.targetList!.contains("onlyteachers")) return true;
        if (item.targetList!.any((item) => TeacherFunctions.getTeacherClassList().contains(item))) return true;
      }
      if (AppVar.appBloc.hesapBilgileri.gtS) {
        if (item.targetList!.contains("alluser")) return true;

        if (item.targetList!.any((item) => [...AppVar.appBloc.hesapBilgileri.classKeyList, AppVar.appBloc.hesapBilgileri.uid].contains(item))) return true;
      }
      return false;
    }).toList();
  }
}
