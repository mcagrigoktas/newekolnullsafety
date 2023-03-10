import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/class.dart';
import '../../../../services/dataservice.dart';
import '../helper.dart';
import '../programlistmodels.dart';
import 'drawer.dart';
import 'popup_box.dart';

class TimaTableEditController extends BaseController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final scrollControllerTopBar = ScrollController();
  final scrollControllerBottom = ScrollController();
  final scrollControllerLeft = ScrollController();
  final scrollControllerRigth = ScrollController();

  final timeTableSettings = TimeTableSettings();
  DrawerType drawerType = DrawerType.settings;

  Map programData = {};
  final Map caches = {};

  var isLoadingSave = false.obs;
  var isLoadingShare = false.obs;

  late List<Class> classList;
  TimesModel? timesModel;

  @override
  void onInit() {
    super.onInit();

    scrollControllerBottom.addListener(() {
      scrollControllerTopBar.jumpTo(scrollControllerBottom.offset);
    });
    scrollControllerRigth.addListener(() {
      scrollControllerLeft.jumpTo(scrollControllerRigth.offset);
    });

    classList = AppVar.appBloc.classService!.dataList;

    Future.delayed(Duration.zero).then((_) {
      if ((AppVar.appBloc.schoolTimesService?.dataList.length ?? 0) == 0) {
        Get.back();
        OverAlert.show(type: AlertType.danger, message: 'schooltimeswarning'.translate);
      } else {
        timesModel = AppVar.appBloc.schoolTimesService!.dataList.last;
        //todo burda calisma saatleri ekol icin kaldirilabilir mi?
        final bool isNotSturdy = AppVar.appBloc.hesapBilgileri.isEkid
            ? (AppVar.appBloc.classService!.dataList.isEmpty || AppVar.appBloc.lessonService!.dataList.isEmpty || AppVar.appBloc.teacherService!.dataList.isEmpty)
            : (AppVar.appBloc.classService!.dataList.isEmpty || AppVar.appBloc.lessonService!.dataList.isEmpty || AppVar.appBloc.teacherService!.dataList.isEmpty
            //todo bu gerekli mi || AppVar.appBloc.teacherHoursService.data == null || AppVar.appBloc.classHoursService.data == null
            );

        if (isNotSturdy) {
          Get.back();
          OverAlert.show(type: AlertType.danger, message: 'timetablewarning1'.translate);
        } else {
          ProgramService.dbGetTimetableProgram('Taslak1').once().then((snap) {
            if (snap?.value != null) {
              programData = snap!.value;

              programData = ProgramHelper.makeProgramSturdy(programData, timesModel);
            }

            timeTableSettings.visibleDays = List<String>.from(timesModel!.activeDays!)..sort((a, b) => a.compareTo(b));
            timeTableSettings.visibleClass = AppVar.appBloc.classService!.dataList.map((sinif) => sinif.key).toList();
            isPageLoading = false;
            AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
              Map lessonCaches = {};
              lessonCaches['lessonColor'] = (lesson.color ?? "24262A").parseColor;
              lessonCaches['lessonName'] = lesson.name;
              var teacher = AppVar.appBloc.teacherService!.dataListItem(lesson.teacher ?? '?');

              if (teacher == null) {
                lessonCaches['teacherColor'] = Color(0xff24262A);
              } else {
                lessonCaches['teacherColor'] = (lesson.color ?? "24262A").parseColor;
                lessonCaches['teacherKey'] = teacher.key;
              }
              caches[lesson.key] = lessonCaches;
            });

            update();
          });
        }
      }
    });
  }

  Future<void> clearTimeTable() async {
    var _sure = await Over.sure();
    if (_sure == true) {
      programData.clear();
      update();
    }
  }

  Future<void> saveTimeTable() async {
    var _sure = await Over.sure();
    if (_sure == true) {
      if (Fav.noConnection()) return;

      isLoadingSave.value = true;
      await ProgramService.saveTimetableProgram(programData, 'Taslak1').then((a) {
        OverAlert.saveSuc();
      }).catchError((error) {
        OverAlert.saveErr();
      });
      isLoadingSave.value = false;
    }
  }

  Future<void> share() async {
    var _sure = await Over.sure();
    if (_sure == true) {
      if (Fav.noConnection()) return;

      Map _timeTableData = {};
      _timeTableData['classProgram'] = programData;
      _timeTableData['timeStamp'] = databaseTime;
      _timeTableData['times'] = timesModel!.mapForSave();

      isLoadingShare.value = true;
      ProgramService.saveTimetableProgram(programData, 'Taslak1').unawaited;
      await ProgramService.shareTimetableProgram(_timeTableData).then((a) {
        OverAlert.saveSuc();
      }).catchError((error) {
        OverAlert.saveErr();
      });
      isLoadingShare.value = false;
    }
  }

  @override
  void onClose() {
    scrollControllerTopBar.dispose();
    scrollControllerBottom.dispose();
    scrollControllerLeft.dispose();
    scrollControllerRigth.dispose();

    super.onClose();
  }

  bool ayniSaatteOgretmenDolumu(Class sinif, String lessonKey, int? day, int lessonNo) {
    bool _teacherFull = false;
    programData.forEach((classKey, value) {
      if (classKey != sinif.key && !_teacherFull) {
        final Map _sinifProgarmi = value;
        _sinifProgarmi.forEach((time, lessonKey2) {
          if (time == '$day-$lessonNo' && !_teacherFull) {
            if (caches.containsKey(lessonKey2) &&
                caches.containsKey(lessonKey) && // todo gelen hatadan sonra eklendi silinen sinif uada ders ile ilgili bir osrun var
                caches[lessonKey2]['teacherKey'] == caches[lessonKey]['teacherKey']) {
              _teacherFull = true;
            }
          }
        });
      }
    });
    return _teacherFull;
  }

  Future<void> boxOnSelect(BuildContext context, String day, int lessonNo, GlobalKey gestureKey, Class sinif) async {
    var _lessonList = AppVar.appBloc.lessonService!.dataList.where((lesson) => lesson.classKey == sinif.key).where((lesson) => lesson.count! > (((programData[sinif.key] ?? {}) as Map).values.fold(0, (t, e) => e == lesson.key ? t + 1 : t)));

    final _lessonKey = await PopUpBuild.build(
      lessonList: _lessonList,
      sinif: sinif,
      context: context,
      gestureKey: gestureKey,
      day: day,
      lessonNo: lessonNo,
    );
    if (_lessonKey == null) return;

    if (programData[sinif.key] == null) programData[sinif.key] = {};

    if (_lessonKey == 'sil') {
      (programData[sinif.key] as Map).remove('$day-${lessonNo + 1}');
    } else {
      if (ayniSaatteOgretmenDolumu(sinif, _lessonKey, int.tryParse(day), lessonNo + 1) == true) {
        OverAlert.show(type: AlertType.danger, message: 'teacherlessonfull'.translate);
        return;
      }
      programData[sinif.key]['$day-${lessonNo + 1}'] = _lessonKey;
    }
    update();
  }
}
