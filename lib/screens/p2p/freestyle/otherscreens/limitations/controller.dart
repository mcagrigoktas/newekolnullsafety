import 'package:flutter/cupertino.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../services/dataservice.dart';
import '../../../../managerscreens/programsettings/programlistmodels.dart';
import 'limitationhelper.dart';

class P2PLimitationsController extends GetxController {
  TimesModel? timesModel;
  bool isLoading = true;
  var refreshKey = GlobalKey();

  var data = <String?, Map<String, List<int?>>>{};

  List<int?>? getTeacherTimes(String? teacherKey, int? day) {
    setUpAndFixData(teacherKey);
    return data[teacherKey]!['d$day'];
  }

  void setTeacherTimes(String? teacherKey, int? day, int index, int? value) {
    setUpAndFixData(teacherKey);
    data[teacherKey]!['d$day']![index] = value;
  }

  bool validate() {
    String? error;

    data.forEach((key, dayData) {
      dayData.forEach((key, times) {
        if (times.last! < times.first!) error = 'incompatiblehours1'.translate;
        if (times.first! < timesModel!.schoolStartTime! || times.last! > timesModel!.schoolEndTime!) error = 'incompatiblehours3'.translate;
      });
    });

    if (error != null) {
      error.showAlert();
      return false;
    }
    return true;
  }

  void submit() {
    if (Fav.noConnection()) return;
    if (!validate()) return;
    AppVar.appBloc.teacherService!.dataList.forEach((element) {
      setUpAndFixData(element.key);
    });

    isLoading = true;
    update();
    RandomDataService.setRandomLog('P2PTeacherLimitations', data).then((value) {
      Get.back(result: data);
      OverAlert.saveSuc();
    }).catchError((err) {
      isLoading = false;
      update();
      OverAlert.saveErr();
    });
  }

  void setUpAndFixData(String? teacherKey) {
    data[teacherKey] ??= {};
    data[teacherKey]!['d1'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
    data[teacherKey]!['d2'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
    data[teacherKey]!['d3'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
    data[teacherKey]!['d4'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
    data[teacherKey]!['d5'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
    data[teacherKey]!['d6'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
    data[teacherKey]!['d7'] ??= [timesModel!.schoolStartTime, timesModel!.schoolEndTime];
  }

  @override
  void onInit() {
    timesModel = AppVar.appBloc.schoolTimesService?.dataList.last;
    RandomDataService.dbGetRandomLog('P2PTeacherLimitations').once().then((snap) {
      if (snap?.value != null) {
        data = LimitationHelper.parseData(snap!.value);
      }
      refreshKey = GlobalKey();
      isLoading = false;
      update();
    });
    super.onInit();
  }
}
