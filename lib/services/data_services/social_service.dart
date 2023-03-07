part of '../dataservice.dart';

class SocialService {
  SocialService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _database22 => AppVar.appBloc.database2;
  static dynamic get _realTime => databaseTime;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

//! GETDATASERVICE
  // Sosyal Ağ Referansı
  static Reference dbSocialNetworkRef() => Reference(_database22, '${StringHelper.schools}/$_kurumId/$_termKey/SocialNetwork/$_uid');
// Video Referansı
  static Reference dbVideoRef() => Reference(_database22, '${StringHelper.schools}/$_kurumId/$_termKey/Video/$_uid');

//! SETDATASERVICE
  // Sosyal Ağa İtem Kaydeder
  static Future<void> saveSocialItem(SocialItem socialItem, List<String> managerList, List<String> teacherList, List<String> studentList, String tur /*SocialNetwork-Video*/, bool? isPublish) async {
    String key = _database22.pushKey('Okullar/$_kurumId/SocialNetwork/$_kurumId');
    Map<String, dynamic> updatesSocial = {};
    Map<String, dynamic> updatesSocialVersion = {};
    final socialData = socialItem.mapForSave(key);
    managerList.forEach((uid) {
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/$key'] = socialData;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/$tur'] = _realTime;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.newSocialService}'] = ServerValue.increment(1);
    });
    teacherList.forEach((uid) {
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/$key'] = socialData;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/$tur'] = _realTime;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.newSocialService}'] = ServerValue.increment(1);
    });
    studentList.forEach((uid) {
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/$key'] = socialData;
      if (isPublish == true) {
        updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/$tur'] = _realTime;
        updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.newSocialService}'] = ServerValue.increment(1);
      }
    });
    return Future.wait([
      AppVar.appBloc.firestore.setItemInPkg('Okullar/$_kurumId/Data/$_termKey/Social/$key', 'data', key, socialItem.toJsonForFirestore(key), targetList: [
        ...socialItem.targetList!,
        socialItem.senderKey!,
      ]),
      _database22.update(updatesSocial),
    ]).then((_) {
      _databaseVersionss.update(updatesSocialVersion);

      if (socialItem.isPublish == true) {
        EkolPushNotificationService.sendMultipleNotification(socialItem.senderName, socialItem.isPhoto ? 'newsocialitemnotify'.argsTranslate({'count': socialItem.imgList!.length}) : 'newsocialvideonotify'.translate, socialItem.targetList!, NotificationArgs(tag: 'social'));
      } else if (UserPermissionList.sendnotifyunpublisheditem() == true) {
        AnnouncementService.sendUnpublishedItemNotify(socialItem.senderName!, 'publishthissocial'.translate);
      }
      if (tur == 'SocialNetwork') {
        List imgList = socialItem.imgList ?? [];
        LogHelper.addLog(tur, _uid, imgList.length);
      } else {
        LogHelper.addLog(tur, _uid);
      }
    });
  }

  // Sosyal Ağ Yayınlar
  static Future<void> publishSocialItem(SocialItem item, String tur, List<String> contactList) async {
    Map<String, dynamic> updatesSocial = {};
    Map<String, dynamic> updatesSocialVersion = {};
    contactList.forEach((uid) {
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/${item.key}/isPublish'] = true;
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/${item.key}/timeStamp'] = _realTime;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/$tur'] = _realTime;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.newSocialService}'] = ServerValue.increment(1);
    });

    final _saveFirestore = AppVar.appBloc.firestore.updateFullField('Okullar/$_kurumId/Data/$_termKey/Social/${item.key}', {
      'data': {
        item.key: {'isPublish': true, 'lastUpdate': firestoreTime}
      }
    });
    final _saveRealTimeDb = _database22.update(updatesSocial);

    return Future.wait([_saveFirestore, _saveRealTimeDb]).then((_) {
      EkolPushNotificationService.sendMultipleNotification(item.senderName, item.isPhoto ? 'newsocialitemnotify'.argsTranslate({'count': item.imgList!.length}) : 'newsocialvideonotify'.translate, item.targetList!, NotificationArgs(tag: 'social'));
      _databaseVersionss.update(updatesSocialVersion);
    });
  }

// Sosyal Ağ Siler
  static Future<void> deleteSocialItem(String existingKey, String tur, List<String> contactList) async {
    Map<String, dynamic> updatesSocial = {};
    Map<String, dynamic> updatesSocialVersion = {};
    contactList.forEach((uid) {
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/$existingKey/aktif'] = false;
      updatesSocial['/Okullar/$_kurumId/$_termKey/$tur/$uid/$existingKey/timeStamp'] = _realTime;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/$tur'] = _realTime;
      updatesSocialVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.newSocialService}'] = ServerValue.increment(1);
    });

    final _saveFirestore = AppVar.appBloc.firestore.updateFullField('Okullar/$_kurumId/Data/$_termKey/Social/$existingKey', {
      'data': {
        existingKey: {'lastUpdate': firestoreTime, 'aktif': false}
      }
    });
    final _saveRealTimeDb = _database22.update(updatesSocial);
    return Future.wait([_saveFirestore, _saveRealTimeDb]).then((_) {
      _databaseVersionss.update(updatesSocialVersion);
    });
  }
}
