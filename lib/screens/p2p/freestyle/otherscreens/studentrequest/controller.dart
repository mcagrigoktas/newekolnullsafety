import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../models/lesson.dart';
import '../../../../../services/dataservice.dart';
import '../../../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../../../../portfolio/model.dart';
import '../../model.dart';
import 'model.dart';

class StudentRequestController extends BaseController {
  Map<int?, P2PRequest> existingP2PRequests = {};
  late P2PRequest newP2PRequest;
  Lesson? lesson;
  int? week;

  StudentRequestController(this.lesson);

  bool get isThisWeekSelected => week == DateTime.now().weekOfYear;

  @override
  void onInit() {
    super.onInit();
  }

  P2PRequest? get existingP2PRequest {
    if (week == null) return null;
    return existingP2PRequests[week]?.week == null ? null : existingP2PRequests[week];
  }

  Future<void> weekChange(int week) async {
    this.week = week;
    await getLastRequest();
    formKey = GlobalKey();
    update();
  }

  Future<void> getLastRequest() async {
    if (existingP2PRequests[week] != null) return;
    startLoading();
    await P2PService.dbGetStudentP2PRequest(AppVar.appBloc.hesapBilgileri.uid, lesson!.key, week).once().then((snap) {
      // Buraya istersen ogrenci surekli bu datayi cekmemesi icin cache yazabilirsin
      if (snap?.value != null) {
        existingP2PRequests[week] = P2PRequest.fromJson(snap!.value, snap.key);
      } else {
        existingP2PRequests[week] = P2PRequest.createDefatult();
      }
      stopLoading();
    });
  }

  Future<void> submit() async {
    newP2PRequest = P2PRequest();

    if (formKey.currentState!.validate() && week != null) {
      formKey.currentState!.save();
      newP2PRequest.week = week;
      newP2PRequest.lastUpdate = databaseTime;
      newP2PRequest.lessonKey = lesson!.key;
      newP2PRequest.studentKey = AppVar.appBloc.hesapBilgileri.uid;
      if (await studentBanControlOk(newP2PRequest) == false) return;
      if (Fav.noConnection()) return;
      startLoading();

      await P2PService.setP2PStudentRequest(newP2PRequest.week, lesson!.key!, newP2PRequest.toJson()).then((value) {
        Get.back();
        OverAlert.saveSuc();
      }).catchError((err) {
        stopLoading();
        OverAlert.saveErr();
      });
    } else {
      OverAlert.fillRequired();
    }
  }

  //? Ogrenci daha once katilmadigin birebir yuzunden banlanmis mi (Sadece ogrenci hesabinda kontrol ediyor)
  Future<bool> studentBanControlOk(P2PRequest item) async {
    int? _checkTime;
    bool status = true;
    final _itemTime = P2PTimeCalculateHelper.calculateTimeStamp(week, (item.dayList!..sort()).first! - 1, item.startHour, (DateTime.now().millisecondsSinceEpoch));
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
      OverAlert.showDanger(
          message: 'studentbanp2perr2'.argsTranslate({
            'date': _checkTime!.dateFormat('d-MMM-yyyy'),
            'time': (_checkTime! + Duration(days: UserPermissionList.howManyDaysBanStudentForP2P()).inMilliseconds).dateFormat('d-MMM-yyyy, HH:mm'),
          }),
          autoClose: false);
    }
    return status;
  }
}
