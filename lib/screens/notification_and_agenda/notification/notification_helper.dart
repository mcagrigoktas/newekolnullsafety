import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/notification.dart';
import '../../main/macos_dock/macos_dock.dart';

class NotificationWidgetHelper {
  NotificationWidgetHelper._();

  static String get prefKeyReadTime => AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.uid + 'notreadtime';

  /// Son okunan bildrimlerin zamanindan sonra okunan tekil bildirimlerin listesini tutar. Tumu okundu yapildiginda temizlenir
  static String get prefKeyReadKeyList => AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.uid + 'notreadkeylist';

  static Future<void> makeAllNotificationRead() async {
    final _notificationList = Get.find<MacOSDockController>().databaseNotificationList();
    if (_notificationList != null) {
      await Fav.preferences.setInt(prefKeyReadTime, _notificationList.fold<int>(Fav.preferences.getInt(prefKeyReadTime, 0)!, (p, e) => e.lastUpdate > p ? e.lastUpdate : p));
      await Fav.preferences.setStringList(prefKeyReadKeyList, []);
      Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.database, []);
    }
  }

  static Future<void> makeThisNotificationRead(InAppNotification notification) async {
    final _readKeyList = Fav.preferences.getStringList(prefKeyReadKeyList, [])!;
    await Fav.preferences.setStringList(prefKeyReadKeyList, _readKeyList..add(notification.key! + notification.lastUpdate.toString()));
    await checkNotification();
  }

  static Future<void> checkNotification() async {
    await 10.wait;

//? Database deki bildirimler ekleniyor
    final _lastReadTime = Fav.preferences.getInt(prefKeyReadTime, 0);
    final _readKeyList = Fav.preferences.getStringList(prefKeyReadKeyList, []);

//? [_maxLastUpdateTimeInNotificationList] bu degisken bildirimleri temizlemek icin son bildirimin zamanini tutar
    int? _maxLastUpdateTimeInNotificationList = _lastReadTime;
    final _newNotifications = AppVar.appBloc.inAppNotificationService!.dataList.where((element) {
      if ((element.lastUpdate as int) > _maxLastUpdateTimeInNotificationList!) _maxLastUpdateTimeInNotificationList = element.lastUpdate;
      return (element.lastUpdate as int) > _lastReadTime! && !_readKeyList!.contains(element.key! + element.lastUpdate.toString());
    }).toList();

    if (_newNotifications.isEmpty) {
      await Fav.preferences.setStringList(prefKeyReadKeyList, []);
      await Fav.preferences.setInt(prefKeyReadTime, _maxLastUpdateTimeInNotificationList!);
      Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.database, []);
    } else {
      Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.database, _newNotifications);
    }

//? Diger bildirimler ekleniyor
    _addOtherNotifications();
  }

  static void _addOtherNotifications() {
    _addAppStartNotifications();
  }

  static void _addAppStartNotifications() {
    _checkAppLastUsableTime();
    _checkAppDemoTime();
  }

  //?----------------
  static void _checkAppLastUsableTime() {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;

    ///Burda delay olma sebebi eger iptal edilirse acilista daha bilgsi gelmemiste olabilir. onu bekliyoruz
    Future.delayed(5000.milliseconds).then((value) {
      final _lastUsableTime = AppVar.appBloc.schoolInfoForManagerService!.singleData!.lastUsableTime ?? DateTime.now().add(Duration(days: 1095)).millisecondsSinceEpoch;
      final _now = DateTime.now().millisecondsSinceEpoch;
      String? _text;
      if (_now > _lastUsableTime - Duration(days: 7).inMilliseconds) {
        _text = 'appstopedin3days'.argsTranslate({'date': _lastUsableTime.dateFormat()});
      }

      if (_text != null) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.appLastUsableTime, [
          (InAppNotification(type: NotificationType.appLastUsableTime)
            ..key = 'appstopedin3days'
            ..title = 'warning'.translate
            ..content = _text
            ..lastUpdate = DateTime.now().millisecondsSinceEpoch)
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.appLastUsableTime, []);
      }
    });
  }

  static void _checkAppDemoTime() {
    if (AppVar.appBloc.hesapBilgileri.demoTime == null) return;

    Future.delayed(2000.milliseconds).then((value) {
      final String _timeText = (AppVar.appBloc.hesapBilgileri.demoTime! + const Duration(days: 7).inMilliseconds).dateFormat("d-MMM, HH:mm");

      final text = "demofinishtime".translate + ': ' + _timeText;

      Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.appDemoTime, [
        (InAppNotification(type: NotificationType.appDemoTime)
          ..key = 'demofinishtime'
          ..title = 'warning'.translate
          ..content = text
          ..lastUpdate = DateTime.now().millisecondsSinceEpoch)
      ]);
    });
  }
}
