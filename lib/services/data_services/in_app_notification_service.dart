part of '../dataservice.dart';

class InAppNotificationService {
  InAppNotificationService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static dynamic get _realTime => databaseTime;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;

//! GETDATASERVICE
  static Reference dbInAppNotificationsRef() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Notifications/$_uid');

//! SETDATASERVICE
  static Future<void> sendInAppNotification(InAppNotification notification, String? targetUid, {String notificationTag = 'notify', List<String?>? sendOnlyThisTokenList}) {
    notification.lastUpdate = _realTime;
    return _database33.set('Okullar/$_kurumId/$_termKey/Notifications/$targetUid/${notification.key}', notification.toJson(notification.key!)).then((value) {
      EkolPushNotificationService.sendSingleNotification(notification.title, notification.content, targetUid, NotificationArgs(tag: notificationTag), forParentOtherMenu: notification.forParentOtherMenu == true, sendOnlyThisTokenList: sendOnlyThisTokenList);
      _databaseVersionss.runTransaction("Okullar/$_kurumId/$_termKey/$targetUid/${VersionListEnum.inAppNotification}", 1);
    });
  }

//[allUserKeyMeanAllStudent] keyi allUser demenin sadece ogrencilere bildirim gondermek manasina geldigini belirtir
  static Future<void>? sendSameInAppNotificationMultipleTarget(InAppNotification notification, List<String?>? targetList, {String notificationTag = 'notify', bool targetListContainsAllUserOrClassList = false, bool allUserKeyMeanAllStudent = false}) {
    if (targetList == null || targetList.isEmpty) return null;

    if (targetListContainsAllUserOrClassList) {
      targetList = AppFunctions2.targetListToUidList(targetList, allUserKeyMeanAllStudent: allUserKeyMeanAllStudent);
    }

    notification.lastUpdate = _realTime;
    Map<String, dynamic> updates = {};
    targetList.forEach((uid) {
      updates['/Okullar/$_kurumId/$_termKey/Notifications/$uid/${notification.key}'] = notification.toJson(notification.key!);
    });
    return _database33.update(updates).then((value) {
      Map<String, dynamic> updatesVersion = {};
      targetList!.forEach((uid) {
        updatesVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.inAppNotification}'] = ServerValue.increment(1);
      });
      _databaseVersionss.update(updatesVersion);
      EkolPushNotificationService.sendMultipleNotification(notification.title, notification.content, targetList, NotificationArgs(tag: notificationTag), forParentOtherMenu: notification.forParentOtherMenu == true);
    });
  }

  static Future<void>? sendMultipleInAppNotification(List<MultipleInAppNotificationItem> itemList, {String notificationTag = 'notify'}) {
    if (itemList.isEmpty) return null;
    Map<String, dynamic> updates = {};
    itemList.forEach((item) {
      item.notification.lastUpdate = _realTime;
      updates['/Okullar/$_kurumId/$_termKey/Notifications/${item.uid}/${item.notification.key}'] = item.notification.toJson(item.notification.key!);
    });
    return _database33.update(updates).then((value) {
      Map<String, dynamic> updatesVersion = {};
      itemList.forEach((item) {
        EkolPushNotificationService.sendSingleNotification(item.notification.title, item.notification.content, item.uid, NotificationArgs(tag: notificationTag), forParentOtherMenu: item.notification.forParentOtherMenu == true);

        updatesVersion['/Okullar/$_kurumId/$_termKey/${item.uid}/${VersionListEnum.inAppNotification}'] = ServerValue.increment(1);
      });
      _databaseVersionss.update(updatesVersion);
    });
  }
}

class MultipleInAppNotificationItem {
  final InAppNotification notification;
  final String uid;
  MultipleInAppNotificationItem({required this.uid, required this.notification});
}
