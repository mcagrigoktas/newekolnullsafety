import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/appfunctions.dart';
import '../../../../services/dataservice.dart';
import '../../../../services/reference_service.dart';
import '../../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../../../portfolio/model.dart';
import '../../freestyle/model.dart';
import '../edit_p2p_draft/model.dart';
import 'model.dart';

class ReserveP2PController extends BaseController {
  late SimpleP2pDraft schoolDraftData;
  late P2PSimpleWeekData selectedWeekP2pData;
  int? selectedWeek;
  String? selectedTeacher;

  @override
  void onInit() {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      selectedTeacher = AppVar.appBloc.hesapBilgileri.uid;
    } else {
      setupTeacherDropdownItemList();
    }
    schoolDraftData = AppVar.appBloc.simpleP2PDraftService?.singleData ?? SimpleP2pDraft.fromJson({});
    super.onInit();
  }

  Future<void> weekChange(int week) async {
    selectedWeek = week;
    await getWeekData();
    formKey = GlobalKey();
    //? getWeekData daha datayi esitlemeden update edince hata veriyorudu sanirim
    await 300.wait;
    update();
  }

  Future<void> teacherChange(String teacherKey) async {
    selectedTeacher = teacherKey;
    update();
  }

  StreamSubscription? _weeklyDataListenController;
  Future<void> getWeekData() async {
    OverLoading.show();
    if (!isDebugMode) await 3000.wait;
    await _weeklyDataListenController?.cancel();
    _weeklyDataListenController = AppVar.appBloc.firestore.listenDoc(ReferenceService.simpleP2PWeekData() + '/week$selectedWeek').listen((snap) async {
      final _data = snap?.value == null ? {} : (snap!.value['data'] ?? {});
      selectedWeekP2pData = P2PSimpleWeekData.fromJson(_data);
      await OverLoading.close();
      update();
    });
  }

  //? Ogretmen listesi icin gerekli filtrelemeleri yapar
  List<DropdownItem> dropDownItemList = [];
  void setupTeacherDropdownItemList() {
    if (AppVar.appBloc.hesapBilgileri.gtM || UserPermissionList.hasStudentOtherTeacherP2PRequest()) {
      dropDownItemList = AppVar.appBloc.teacherService!.dataList.map((e) => DropdownItem(value: e.key, name: e.name)).toList();
    } else if (AppVar.appBloc.hesapBilgileri.gtS) {
      final _studentVisibleTeacherList = StudentFunctions.listOfTeachersTheStudentCanSee();
      dropDownItemList = AppVar.appBloc.teacherService!.dataList.where((element) => _studentVisibleTeacherList.contains(element.key)).map((e) => DropdownItem(value: e.key, name: e.name)).toList();
    }
  }

  Future<void> teacherReserveMenu(SimpeP2PDraftItem draftItem, P2PSimpleWeekDataItem? existingItem) async {
    if (timeIsClosed(draftItem)) {
      OverAlert.show(message: 'p2ptimeerror'.translate, type: AlertType.danger);
      return;
    }

    final formKey = GlobalKey<FormState>();
    int capacity = existingItem?.maxStudentCount ?? 1;
    String targetClass = existingItem?.targetList == null || existingItem!.targetList!.isEmpty ? 'all' : existingItem.targetList!.first;
    List<String> rezerveList = existingItem?.studentListData?.keys.toList() ?? [];

    final List<String?> _teacherClassList = AppVar.appBloc.hesapBilgileri.gtT ? TeacherFunctions.getTeacherClassList() : [];
    final _studentList = AppFunctions2.getStudentListForTeacherAndManager();

    final capacityDropdownItemList = Iterable.generate(25, (e) => e + 1).map((e) => DropdownItem(value: e, name: e == 0 ? 'close'.translate : '$e')).toList();
    if (AppVar.appBloc.hesapBilgileri.gtM) {
      capacityDropdownItemList.insert(0, DropdownItem(value: 0, name: 'close'.translate));
    }

    await OverBottomSheet.show(BottomSheetPanel.child(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppVar.appBloc.teacherService!.dataListItem(selectedTeacher!)!.name.text.fontSize(24).color(Fav.design.primary).make(),
            4.heightBox,
            (McgFunctions.getDayNameFromDayOfWeek(draftItem.dayNo!) + ' / ' + draftItem.startTime!.timeToString + '-' + draftItem.endTime!.timeToString).text.bold.make(),
            AdvanceDropdown<int>(
              items: capacityDropdownItemList,
              name: 'capacity'.translate,
              initialValue: capacity,
              onSaved: (value) {
                capacity = value;
              },
              validatorRules: ValidatorRules(req: true, minLength: 1),
              searchbarEnableLength: 30,
            ),
            AdvanceDropdown<String>(
              items: AppVar.appBloc.classService!.dataList.where((element) => AppVar.appBloc.hesapBilgileri.gtM || _teacherClassList.contains(element.key)).map((e) => DropdownItem(value: e.key, name: e.name)).toList()..insert(0, DropdownItem(value: 'all', name: 'all'.translate)),
              name: 'targetlist'.translate,
              initialValue: targetClass,
              validatorRules: ValidatorRules(req: true, minLength: 1),
              onSaved: (value) {
                targetClass = value;
              },
              searchbarEnableLength: 10,
            ),
            AdvanceMultiSelectDropdown<String>(
              iconData: Icons.person_sharp,
              items: _studentList.map((e) => DropdownItem(value: e.key, name: e.name)).toList(),
              name: 'makereserve'.translate,
              initialValue: rezerveList,
              validatorRules: ValidatorRules.none(),
              onSaved: (value) {
                rezerveList = value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyFlatButton(
                    onPressed: () {
                      OverBottomSheet.closeBottomSheet();
                    },
                    text: 'close'.translate),
                16.widthBox,
                MyRaisedButton(
                    onPressed: () async {
                      if (Fav.noConnection()) return;
                      if (formKey.currentState!.checkAndSave()) {
                        final _itemForSave = existingItem ?? P2PSimpleWeekDataItem.create('w$selectedWeek' + '_p_' + selectedTeacher! + '_p_' + draftItem.key);

                        _itemForSave.targetList = [targetClass];

                        final List<String> newStudentList = rezerveList.fold(<String>[], (p, e) => _itemForSave.studentListData!.containsKey(e) ? p : (p..add(e)));

                        if (studentHasAnotherP2PThisTime(newStudentList, draftItem)) return;
                        final List<String?> studentListForRemove = _itemForSave.studentListData!.keys.fold(<String?>[], (p, e) => rezerveList.contains(e) ? p : (p..add(e)));

                        studentListForRemove.forEach((element) {
                          _itemForSave.removeThisStudent(element);
                        });
                        _itemForSave.addThisStudents(newStudentList.fold<Map<String, String>>({}, (p, e) => p..[e] = AppVar.appBloc.studentService!.dataListItem(e)!.name!));

                        _itemForSave.maxStudentCount = capacity.clamp(_itemForSave.studentListData?.length ?? 1, 25);
                        OverBottomSheet.closeBottomSheet();
                        OverLoading.show();

                        await P2PService.saveStudentInWeeklySimpleP2p(_itemForSave, draftItem, selectedWeek!, selectedTeacher, newStudentList, studentListForRemove).then((value) {
                          OverAlert.saveSuc();
                        }).catchError((value) {
                          log(value);
                          OverAlert.saveErr();
                        });
                        await OverLoading.close();
                      }
                    },
                    text: 'save'.translate),
              ],
            )
          ],
        ).p4,
      ),
    ));
  }

  Future<void> makeRezerveForStudent(SimpeP2PDraftItem item, P2PSimpleWeekDataItem? existingItem, {bool cancelReserve = false}) async {
    if (cancelReserve) {
      if (hasP2pp4DurationErr(item)) {
        OverAlert.show(message: 'p2pp4e'.translate, type: AlertType.danger);
        return;
      }
    } else {
      if (timeIsClosed(item)) {
        OverAlert.show(message: 'p2ptimeerror'.translate, type: AlertType.danger);
        return;
      }
      if (hasP2pp1Err(item)) {
        OverAlert.show(message: 'p2pp1e'.translate, type: AlertType.danger);
        return;
      }
      if (hasP2pp2Err(item)) {
        OverAlert.show(message: 'p2pp2e'.translate, type: AlertType.danger);
        return;
      }
      if (hasP2pp3Err(item)) {
        OverAlert.show(message: 'p2pp3e'.translate, type: AlertType.danger);
        return;
      }
    }

    final _studentBanControlOk = await studentBanControlOk(selectedWeek, item);
    if (_studentBanControlOk == false) return;

    if (existingItem?.targetList != null && existingItem!.targetList!.isNotEmpty && !existingItem.targetList!.contains('all')) {
      //? burada sinif listesi birden fazla yapilirsa any fonksiyonunu kullan
      if (!AppVar.appBloc.hesapBilgileri.classKeyList.contains(existingItem.targetList!.first)) {
        OverAlert.show(message: 'p2ptargetlistcontainerr'.translate, type: AlertType.danger);
        return;
      }
    }

    if (cancelReserve == false && studentHasAnotherP2PThisTime([AppVar.appBloc.hesapBilgileri.uid], item)) return;

    String? capactyText;
    if (existingItem != null && existingItem.maxStudentCount! > 1) {
      capactyText = "capacity".translate + ': ' + (existingItem.studentListData!.length).toString() + '/' + existingItem.maxStudentCount.toString();
    }

    String? studentNote = '';
    final result = await OverBottomSheet.show(BottomSheetPanel.child(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppVar.appBloc.teacherService!.dataListItem(selectedTeacher!)!.name.text.fontSize(24).bold.make(),
          (McgFunctions.getDayNameFromDayOfWeek(item.dayNo!) + ' / ' + item.startTime!.timeToString + '-' + item.endTime!.timeToString + (capactyText != null ? ' $capactyText' : '')).text.make(),
          8.heightBox,
          if (existingItem != null && existingItem.maxStudentCount == 1)
            MyTextField(
              initialValue: existingItem.note,
              labelText: 'note'.translate,
              iconData: Icons.note_rounded,
              onChanged: (value) {
                studentNote = value.safeSubString(0, 250);
              },
            ).pb8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyFlatButton(
                  onPressed: () {
                    OverBottomSheet.selectBottomSheetItem(false);
                  },
                  text: 'back'.translate),
              32.widthBox,
              MyRaisedButton(
                  onPressed: () {
                    OverBottomSheet.selectBottomSheetItem(true);
                  },
                  text: (cancelReserve ? 'cancelreserve' : 'makereserve').translate),
            ],
          ),
        ],
      ),
    ));
    if (result == true) {
      P2PSimpleWeekDataItem? _itemForSave;
      if (!cancelReserve) {
        _itemForSave = (existingItem ?? P2PSimpleWeekDataItem.create('w$selectedWeek' + '_p_' + selectedTeacher! + '_p_' + item.key))..addThisStudents({AppVar.appBloc.hesapBilgileri.uid: AppVar.appBloc.hesapBilgileri.name!});
      } else {
        _itemForSave = existingItem!..removeThisStudent(AppVar.appBloc.hesapBilgileri.uid);
      }

      if (_itemForSave.hasMaxCapacityError) {
        OverAlert.show(message: 'maxcapacityerr'.translate, type: AlertType.danger);
        return;
      }
      if (Fav.noConnection()) return;
      if (cancelReserve == false) {
        final _item = selectedWeekP2pData.allItem.singleWhereOrNull((element) => element.key == _itemForSave!.key);
        if (_item?.isFull == true) {
          OverAlert.show(message: 'maxcapacityerr', type: AlertType.danger);
          return;
        }
      }
      _itemForSave.note = studentNote;
      OverLoading.show();
      await P2PService.saveStudentInWeeklySimpleP2p(
        _itemForSave,
        item,
        selectedWeek!,
        selectedTeacher,
        cancelReserve ? [] : [AppVar.appBloc.hesapBilgileri.uid],
        !cancelReserve ? [] : [AppVar.appBloc.hesapBilgileri.uid],
      ).then((value) {
        OverAlert.saveSuc();
      }).catchError((value) {
        log(value);
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }

  bool studentHasAnotherP2PThisTime(List<String?> studentList, SimpeP2PDraftItem selectedItem) {
    final _allItem = selectedWeekP2pData.allItem;
    for (var i = 0; i < _allItem.length; i++) {
      final _item = _allItem[i];
      if (_item.studentListData!.isEmpty) continue;
      if (_item.teacherKey == selectedTeacher) continue;
      if (selectedItem.startTime! > _item.lessonEndTime!) continue;
      if (selectedItem.endTime! < _item.lessonStartTime!) continue;

      if (_item.studentListData!.keys.any((stkey) => studentList.contains(stkey))) {
        OverAlert.show(message: (AppVar.appBloc.hesapBilgileri.gtS ? 'studenthasanotherp2p' : 'studentshasanotherp2p').translate, type: AlertType.danger);
        return true;
      }
    }

    return false;
  }

//? Iptal edebilmek icin gerekn surede bir problem var mi
  bool hasP2pp4DurationErr(SimpeP2PDraftItem item) {
    final _checkDay = UserPermissionList.howManyDayForCancel();
    final _currentTime = DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime);
    final _itemWeek = selectedWeek!;
    final _currentTimeWeek = _currentTime.weekOfYear;
    final _itemDayNo = item.dayNo;
    final _currentTimeDayNo = _currentTime.weekday;
    if (_currentTimeWeek > _itemWeek) {
      return true;
    } else if (_currentTimeWeek == _itemWeek) {
      return _currentTimeDayNo > _itemDayNo! - _checkDay;
    } else {
      return _currentTimeDayNo > _itemDayNo! - _checkDay + 7;
    }
  }

//?todowrong sene degisimlerinde problem var yilbasi oncesi sonrasi
//? Iptal edebilmek icin gerekn surede bir problem var mi
  bool timeIsClosed(SimpeP2PDraftItem item) {
    final _currentTime = DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime);
    final _itemWeek = selectedWeek!;
    final _currentTimeWeek = _currentTime.weekOfYear;
    final _itemDayNo = item.dayNo;
    final _currentTimeDayNo = _currentTime.weekday;
    if (_currentTimeWeek > _itemWeek) {
      return true;
    } else if (_currentTimeWeek == _itemWeek) {
      return _currentTimeDayNo > _itemDayNo!;
    }
    return false;
  }

  //? Bir öğrencinin haftalık en fazla alabileceği etüd sayısı kontrolu
  bool hasP2pp1Err(SimpeP2PDraftItem item) {
    final _howManyP2PThereThisStudent = selectedWeekP2pData.howManyP2PThereThisStudent(AppVar.appBloc.hesapBilgileri.uid);
    return _howManyP2PThereThisStudent >= UserPermissionList.howManyLesson1Week();
  }

  //? Bir öğrencinin aynı öğretmenden haftalık en fazla alabileceği etüd sayısı
  bool hasP2pp2Err(SimpeP2PDraftItem item) {
    final _howManyP2PThereThisStudentThisTeacher = selectedWeekP2pData.howManyP2PThereThisStudentThisTeacher(AppVar.appBloc.hesapBilgileri.uid, selectedTeacher);
    return _howManyP2PThereThisStudentThisTeacher >= UserPermissionList.howManyLesson1WeekSameTeacher();
  }

  //? Bir öğrencinin aynı günde aynı ogretmen için alabileceği en fazla saat sayısı
  bool hasP2pp3Err(SimpeP2PDraftItem item) {
    final _howManyP2PThereThisStudentThisTeacherSameDay = selectedWeekP2pData.howManyP2PThereThisStudentThisTeacherSameDay(AppVar.appBloc.hesapBilgileri.uid, selectedTeacher, item.dayNo);
    return _howManyP2PThereThisStudentThisTeacherSameDay >= UserPermissionList.howManySameLesson1Day();
  }

//? Ogrenci daha once katilmadigin birebir yuzunden banlanmis mi (Sadece ogrenci hesabinda kontrol ediyor)
  Future<bool> studentBanControlOk(int? week, SimpeP2PDraftItem item) async {
    int? _checkTime;
    bool status = true;
    final _itemTime = P2PTimeCalculateHelper.calculateTimeStamp(week, item.dayNo, item.startTime, (DateTime.now().millisecondsSinceEpoch));
    AppVar.appBloc.portfolioService?.dataList.forEach((element) {
      if (_checkTime == null && element.portfolioType == PortfolioType.p2p && element.data<P2PModel>()!.rollCall == false) {
        final _element = element.data<P2PModel>()!;
        final _elementTime = P2PTimeCalculateHelper.calculateTimeStamp(_element.week, _element.day, _element.startTime, (element.lastUpdate ?? _element.lastUpdate));
        if (_itemTime > _elementTime && _itemTime < _elementTime + Duration(days: UserPermissionList.howManyDaysBanStudentForP2P()).inMilliseconds) {
          _checkTime = _elementTime;
          status = false;
        }
      }
    });

    if (_checkTime != null) {
      OverAlert.showDanger(message: 'studentbanp2perr'.argsTranslate({'date': _checkTime!.dateFormat('d-MMM-yyyy')}), autoClose: false);
    }
    return status;
  }
}
