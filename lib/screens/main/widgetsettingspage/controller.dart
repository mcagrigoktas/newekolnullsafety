import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../services/dataservice.dart';
import 'model.dart';

class WidgetSettingsPageController extends GetxController {
  final List<WidgetModel> widgetList = AppVar.appBloc.schoolInfoService!.singleData!.widgetList;
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;

  ScrollController scrollController = ScrollController();

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> addwidget() async {
    var _type = await {
      'linkwidget': 'linkwidget'.translate,
      'counterwidget': 'counterwidget'.translate,
    }.selectOne(title: 'anitemchoose'.translate);

    if (_type == 'linkwidget') {
      widgetList.add(WidgetModel()
        ..key = 4.makeKey
        ..typeKey = 'linkwidget'
        ..linkWidgetUrl = ''
        ..linkWidgetImageUrl = ''
        ..targetList = ['onlyteachers']);
    } else if (_type == 'counterwidget') {
      widgetList.add(WidgetModel()
        ..key = 4.makeKey
        ..typeKey = 'counterwidget'
        ..countTime = DateTime.now().millisecondsSinceEpoch
        ..targetList = ['onlyteachers']);
    }
    update();
    await 100.wait;
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: 333.milliseconds, curve: Curves.ease).unawaited;
  }

  Future<void> save() async {
    if (formKey.currentState!.checkAndSave()) {
      final Map _data = widgetList.fold({}, (p, e) => p..[e.key] = e.toJson());
      isLoading = true;
      update();
      await SchoolDataService.saveWidgetsSchoolInfo(_data).then((_) async {
        OverAlert.saveSuc();
        final _sure = await Over.sure(title: 'widgetlistchangewarning'.translate);
        if (_sure) AppVar.appBloc.appConfig.ekolRestartApp!(true);
      }).catchError((_) {
        OverAlert.saveErr();
        isLoading = false;
        update();
      });
    }
  }
}
