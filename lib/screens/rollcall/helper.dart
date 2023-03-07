import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../models/notification.dart';
import '../main/macos_dock/macos_dock.dart';
import '../main/menu_list_helper.dart';
import 'ekidrollcallstudent.dart';
import 'ekolrollcallstudentpage.dart';

class RollCallHelper {
  RollCallHelper._();
  static void afterRollCallsNewData() {
    calculateNewItemBadge();
  }

  static const ekidRollCallNotificationGroup = NotificationGroup.rollCallEkid;
  static const ekolRollCallNotificationGroup = NotificationGroup.rollCallEkol;
  static String get lastEkidRollCallPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}lastekidrollcallpagelogintime';
  static String get lastEkolRollCallPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}lastekolrollcallpagelogintime';

  static String get rollCallPageEntryTimePrefKey => MenuList.hasTimeTable() ? lastEkolRollCallPageEntryTimePrefKey : lastEkidRollCallPageEntryTimePrefKey;
  static NotificationGroup get rollCallNotificationGroup => MenuList.hasTimeTable() ? ekolRollCallNotificationGroup : ekidRollCallNotificationGroup;

  static void calculateNewItemBadge() {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      final lastRollCallPageLoginTime = Fav.preferences.getInt(rollCallPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch);

      int? maxLastUpdateTime = lastRollCallPageLoginTime;
      final newRollCallList = MenuList.hasTimeTable()
          ? List<EkolRolCallStudentModel>.from(AppVar.appBloc.studentRollCallService!.dataList).where((element) {
              if (element.lastUpdate! > maxLastUpdateTime!) maxLastUpdateTime = element.lastUpdate;
              return element.lastUpdate! > lastRollCallPageLoginTime!;
            }).toList()
          : List<EkidRolCallStudentModel>.from(AppVar.appBloc.studentRollCallService!.dataList).where((element) {
              if (element.lastUpdate! > maxLastUpdateTime!) maxLastUpdateTime = element.lastUpdate;
              return element.lastUpdate! > lastRollCallPageLoginTime!;
            }).toList();

      if (newRollCallList.isNotEmpty) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(rollCallNotificationGroup, [
          InAppNotification(type: NotificationType.rollCall)
            ..title = 'newrollcallpost'.translate
            ..lastUpdate = maxLastUpdateTime
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(rollCallNotificationGroup, []);
      }
    }
  }

  static Future<void> saveLastLoginTime() async {
    final _lastItem = Get.find<MacOSDockController>().rollCallNotificationList();
    if (_lastItem == null) return;
    await Fav.preferences.setInt(rollCallPageEntryTimePrefKey, _lastItem.lastUpdate);
    calculateNewItemBadge();
  }

  static Color getRollCallStatusColor(int? value) {
    if (value == 1) return Colors.red;
    if (value == 2) return Colors.deepOrangeAccent;
    if (value == 3) return Colors.amber;
    if (value == 4) return Colors.indigoAccent;
    if (value == 5) return Colors.deepPurpleAccent;
    return Colors.green;
  }

  static Color getRollCallEkidStatusColor(int? value) {
    if (value == 1) return Colors.red;
    if (value == 0) return Colors.green;
    return Colors.red;
  }
}
