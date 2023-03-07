import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../models/notification.dart';
import '../main/macos_dock/macos_dock.dart';

class DailyReportHelper {
  DailyReportHelper._();

  //! Burasi Yeni data geldikce yapilacak degisiklikler
  static void afterDailyReportNewData() {
    calculateNewItemBadge();
  }

  static const dailyReportIconTag = DockItemTag.dailyreport;
  static const dailyReportNotifcitaionGroup = NotificationGroup.dailyreport;
  static String get lastDailyReportPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.uid}lastdailyreportpagelogintime';
  static void calculateNewItemBadge() {
    final _buguneAitData = DailyReportHelper.dailyReportThisDate(DateTime.now().millisecondsSinceEpoch);

    if (_buguneAitData != null) {
      final lastdailyreportpagelogintime = Fav.preferences.getInt(lastDailyReportPageEntryTimePrefKey, 0);
      final dailyReportDataReceived = (_buguneAitData['timeStamp'] ?? 0) > lastdailyreportpagelogintime;
      if (dailyReportDataReceived) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(dailyReportNotifcitaionGroup, [
          InAppNotification(type: NotificationType.dailyreport)
            ..title = 'newdailyreportpost'.translate
            ..lastUpdate = (_buguneAitData['timeStamp'] ?? 0)
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(dailyReportNotifcitaionGroup, []);
      }
    } else {
      Get.find<MacOSDockController>().replaceThisTagNotificationList(dailyReportNotifcitaionGroup, []);
    }
  }

  static Future<void> saveLastLoginTime() async {
    final _lastItem = Get.find<MacOSDockController>().studentDailyReprotNotification();
    if (_lastItem == null) return;
    await Fav.preferences.setInt(lastDailyReportPageEntryTimePrefKey, _lastItem.lastUpdate);
    calculateNewItemBadge();
  }
  //!

  static List<Map> defaultData() {
    return [
      DailyReport(header: "morningbreakfast".translate, iconName: "et14c.png", options: ["yedi".translate, "azyedi".translate, "yemedi".translate], key: "data1", hasOption: true, tur: 0).mapForSave(),
      DailyReport(header: "lunch".translate, iconName: "et14c.png", options: ["yedi".translate, "azyedi".translate, "yemedi".translate], key: "data2", hasOption: true, tur: 0).mapForSave(),
      DailyReport(header: "afternoonbreakfast".translate, iconName: "et14c.png", options: ["yedi".translate, "azyedi".translate, "yemedi".translate], key: "data3", hasOption: true, tur: 0).mapForSave(),
      DailyReport(header: "uyku".translate, iconName: "et14c.png", options: ["uyudu".translate, "uyumadi".translate], key: "data4", hasOption: true, tur: 0).mapForSave(),
      DailyReport(header: "etkinlikler".translate, iconName: "et14c.png", options: ["katildi".translate, "katilmadi".translate], key: "data5", hasOption: true, tur: 0).mapForSave(),
      DailyReport(header: "ingilizce".translate, iconName: "et14c.png", key: "data6", hasOption: false, tur: 1).mapForSave(),
      DailyReport(header: "dans".translate, iconName: "et14c.png", key: "data7", hasOption: false, tur: 1).mapForSave(),
      DailyReport(header: "matematik".translate, iconName: "et14c.png", key: "data8", hasOption: false, tur: 1).mapForSave(),
    ];
  }

  static Map? dailyReportThisDate(int date) {
    final data = AppVar.appBloc.dailyReportService!.data[date.dateFormat("dd-MM-yyyy")];

    if (data == null || (data.containsKey('aktif') && data['aktif']['value'] != '1')) return null;
    return data;
  }
}
