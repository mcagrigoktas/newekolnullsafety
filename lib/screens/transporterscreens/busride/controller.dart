import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/dbconfigs/other/init_helpers.dart';
import '../../../models/allmodel.dart';
import '../../../models/notification.dart';
import '../../../services/dataservice.dart';
import 'dialog.dart';
import 'helper.dart';
import 'notifications.dart';

class BusRideController extends BaseController {
  late DateTime time;
  late List<Student> studentList;
  final int seferNo;
  BusRideController(this.seferNo);

  //* Ogrenci siralamasini kullanicin belirledigi sekilde kaydeder
  List<String?> orderList = [];

  String get savePreferencesKey => AppVar.appBloc.hesapBilgileri.uid + '-' + time.millisecondsSinceEpoch.dateFormat('dd-MMM-yyyy') + '-' + seferNo.toString() + 'saved';
  String get dataPreferencesKey => AppVar.appBloc.hesapBilgileri.uid + '-' + time.millisecondsSinceEpoch.dateFormat('dd-MMM-yyyy') + '-' + seferNo.toString() + 'data';
  String get orderPreferencesKey => AppVar.appBloc.hesapBilgileri.uid + '-' + time.millisecondsSinceEpoch.dateFormat('dd-MMM-yyyy') + '-' + seferNo.toString() + 'order';
  String get notificationPreferencesKey => AppVar.appBloc.hesapBilgileri.uid + '-' + time.millisecondsSinceEpoch.dateFormat('dd-MMM-yyyy') + '-' + seferNo.toString() + 'notification';

//*{studentKey:{s: Durum(1 geldi -1 gelmedi 0 bilinmiyor),}}
  Map<String?, Map>? data;

  //*{studentKey:{c (geldik): true,w (geliyoruz): true , p (Ogrenci geldi), a (Ogrenci gelmedi)}}
  var notificationCacheData = <String?, Map>{};

  FirebaseApp? _firebaseLogsApp;

  StreamSubscription? _notificationSubscription;
  bool newNotificationReceived = false;

  @override
  void onInit() {
    FirebaseInitHelper.getLogsApp().then((value) => _firebaseLogsApp = value);

    isPageLoading = true;
    time = DateTime.now();
    studentList = AppVar.appBloc.studentService!.dataList.where((element) => element.transporter == AppVar.appBloc.hesapBilgileri.uid).toList();

    data = Map<String?, Map>.from(Fav.securePreferences.getMap(dataPreferencesKey));
    notificationCacheData = Map<String?, Map>.from(Fav.securePreferences.getMap(notificationPreferencesKey));
    _getStudentOrderList();

    studentList.sort((i1, i2) => orderList.indexOf(i1.key) - orderList.indexOf(i2.key));

    makeSturdy();

    _notificationSubscription = AppVar.appBloc.inAppNotificationService!.stream.listen((event) async {
      if (_notificationIsVisible == true && Get.isDialogOpen!) {
        _notificationIsVisible = false;

        ///!Burasi geri yapmiyor birden fazla dialog aciliyor
        Get.back();
      }
      if (DateTime.now().difference(time) > Duration(seconds: 1)) {
        newNotificationReceived = true;
        update();
        await showNotificationDialog();
      }
    });

    LocationHelper.isGranted().then((_locationUpdateEnable) {
      if (_locationUpdateEnable == true) {
        if (LocationHelper.isBackroundServiceEnabled) {
          PermissionManager.hasBackgroundLocationPermission().then((value) {
            _sendLocation(value);
            isPageLoading = false;
            update();
          });
        } else {
          Future.delayed(222.milliseconds).then((_) {
            _sendLocation(false);
            isPageLoading = false;
            update();
          });
        }
      } else {
        isPageLoading = false;
        update();
      }
    });

    super.onInit();
  }

  void _getStudentOrderList() {
    orderList = Fav.preferences.getStringList(orderPreferencesKey) ?? studentList.map((e) => e.key).toList();
  }

  void saveOrderList() {
    Fav.preferences.setStringList(orderPreferencesKey, studentList.map((e) => e.key).toList() as List<String>);
  }

  void makeSturdy() {
    studentList.forEach((student) {
      if (!data!.containsKey(student.key)) data![student.key] = {'s': 0};
    });
  }

  void showOptionsDialog(Student student) {
    Get.dialog(TransporterStudentDialog(student: student), barrierColor: Color(0xdd000000), useSafeArea: true);
  }

  int? getStudentStatus(String? studentKey) => data![studentKey]!['s'];
  void makeStudentHere(String studentKey) {
    data![studentKey]!['s'] = 1;
    Fav.securePreferences.setMap(dataPreferencesKey, data!);

    if ((notificationCacheData[studentKey] ??= {})['p'] != true) {
      if (Fav.hasConnection()) {
        (notificationCacheData[studentKey] ??= {})['p'] = true;
        Fav.securePreferences.setMap(notificationPreferencesKey, notificationCacheData);
        InAppNotificationService.sendInAppNotification(
            InAppNotification(
              title: 'transportnot'.translate,
              content: 'transportstudenthere'.translate,
              key: 'transportstudenthere',
              type: NotificationType.service,
            ),
            studentKey,
            notificationTag: 'service');

        //   EkolPushNotificationService.sendSingleNotification('transportnot'.translate, 'transportstudenthere'.translate, studentKey);
      }
    }
    update();
  }

  void makeStudentAbsent(String studentKey) {
    data![studentKey]!['s'] = -1;
    Fav.securePreferences.setMap(dataPreferencesKey, data!);

    if ((notificationCacheData[studentKey] ??= {})['a'] != true) {
      if (Fav.hasConnection()) {
        (notificationCacheData[studentKey] ??= {})['a'] = true;
        Fav.securePreferences.setMap(notificationPreferencesKey, notificationCacheData);

        InAppNotificationService.sendInAppNotification(
            InAppNotification(
              title: 'transportnot'.translate,
              content: 'transportstudentabsent'.translate,
              key: 'transportstudentabsent',
              type: NotificationType.service,
            ),
            studentKey,
            notificationTag: 'service');
        //  EkolPushNotificationService.sendSingleNotification('transportnot'.translate, 'transportstudentabsent'.translate, studentKey);
      }
    }

    update();
  }

  bool? getSendWeAreComingNotStatus(String? studentKey) => (notificationCacheData[studentKey] ??= {})['c'];
  void sendWeAreComingNot(Student student) {
    if (Fav.noConnection()) return;
    (notificationCacheData[student.key] ??= {})['c'] = true;
    Fav.securePreferences.setMap(notificationPreferencesKey, notificationCacheData);
    final _inAppNotification = InAppNotification(type: NotificationType.service)
      ..key = student.key! + 'sc'
      ..title = 'transportnot'.translate
      ..content = 'transportcomingnot'.translate;
    InAppNotificationService.sendInAppNotification(_inAppNotification, student.key!);
    update();
  }

  bool? getSendWeAreCameNotStatus(String? studentKey) => (notificationCacheData[studentKey] ??= {})['w'];
  void sendWeAreCameNot(Student student) {
    if (Fav.noConnection()) return;
    (notificationCacheData[student.key] ??= {})['w'] = true;
    Fav.securePreferences.setMap(notificationPreferencesKey, notificationCacheData);
    final _inAppNotification = InAppNotification(type: NotificationType.service)
      ..key = student.key! + 'sw'
      ..title = 'transportnot'.translate
      ..content = 'transportcamenot'.translate;
    InAppNotificationService.sendInAppNotification(_inAppNotification, student.key!);
    update();
  }

  Future<void> saveStudentLocation(String? studentKey) async {
    if (Fav.noConnection()) return;
    final _student = AppVar.appBloc.studentService!.dataListItem(studentKey!);
    if (_student == null) return;
    OverLoading.show();
    try {
      final _location = await Geolocator.getCurrentPosition(timeLimit: 3.seconds);
      _student.setLatitude(_location.latitude);
      _student.setLongitude(_location.longitude);
      await StudentService.saveStudent(_student, _student.key!);
      await OverLoading.close();
      OverAlert.saveSuc();
    } catch (err) {
      await OverLoading.close();
      OverAlert.saveErr();
      debugPrint(err.toString());
    } finally {}
  }

  final _druationDelaySeconds = isDebugMode ? 5 : 15;
  StreamSubscription? _locationSubscription;
  Future<void> _sendLocation(bool _inBackground) async {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationHelper.isBackroundServiceEnabled == false
          ? null
          : isWeb
              ? LocationSettings()
              : isIOS
                  ? AppleSettings(showBackgroundLocationIndicator: _inBackground)
                  : AndroidSettings(
                      //! Arka planda guncellemek icin. simdilik bi sebepten calimiyor
                      foregroundNotificationConfig: _inBackground
                          ? ForegroundNotificationConfig(
                              notificationTitle: 'runningbackground'.translate,
                              notificationText: 'runningbackground2'.translate,
                              enableWakeLock: true,
                            )
                          : null,
                    ),
    ).listen((currentLocation) {
      Fav.timeGuardFunction('LocationSended', Duration(seconds: _druationDelaySeconds), () {
        Database(app: _firebaseLogsApp).set('Okullar/${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/TransporterLocations/${AppVar.appBloc.hesapBilgileri.uid}', [currentLocation.latitude, currentLocation.longitude]);
        //    log('Location gonderildi ${currentLocation?.latitude} ${currentLocation?.longitude}');
      });
    });
  }

  Future<void> save() async {
    if (Fav.noConnection()) return;

    if (data!.values.any((element) => element['s'] == 0)) {
      OverAlert.show(message: 'incomplaterollcall'.translate, type: AlertType.danger);
      return;
    }

    final _result = await Over.sure(title: 'savesure'.translate, message: 'savesurehint'.translate);
    if (_result == true) {
      startLoading();

      await TransportService.sendTransporterRollCall('S${seferNo}K${time.daysSinceEpoch}', AppVar.appBloc.hesapBilgileri.uid, {'data': data, 'no': seferNo, 'time': time.dateFormat()}).then((value) {
        OverAlert.saveSuc();
        Fav.preferences.setBool(savePreferencesKey, true);
        _locationSubscription!.cancel();

        //* Eger transporter isi bittikten sonra konumunu silmek istiyorsan ac
        //  Database(app: _firebaseLogsApp).set('Okullar/${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/TransporterLocations/${AppVar.appBloc.hesapBilgileri.uid}', null);
      }).catchError((err) {
        OverAlert.saveErr();
      });
      stopLoading();
    }
  }

  bool _notificationIsVisible = false;
  Future<void> showNotificationDialog() async {
    _notificationIsVisible = true;
    await Get.dialog(
      TransporterNotifications(timeText: time.dateFormat()),
      barrierColor: Color(0xdd000000),
      useSafeArea: true,
    );
    newNotificationReceived = false;

    _notificationIsVisible = false;
    update();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.onClose();
  }
}
