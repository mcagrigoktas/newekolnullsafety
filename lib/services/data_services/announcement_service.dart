part of '../dataservice.dart';

class AnnouncementService {
  AnnouncementService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _database22 => AppVar.appBloc.database2;
  static dynamic get _realTime => databaseTime;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

//! GETDATASERVICE
  // Duyuru Listesi Referansı
  static Reference dbAnnouncementsRef() => Reference(_database22, '${StringHelper.schools}/$_kurumId/$_termKey/Announcements');

// Duyuru Listesi Okundu Referansı
  static Future<Snap?> getAnnouncementsLog() => _databaseLogss.once('${StringHelper.schools}/$_kurumId/$_termKey/AnnouncementsLogs');

//! SETDATASERVICE
  // Duyuru Kaydeder
  static Future<void> saveAnnouncement(Announcement announcement, String? existingKey) async {
    String pushKey = existingKey ?? _database22.pushKey('${StringHelper.schools}/$_kurumId/$_termKey/Announcements');

    return _database22.set('${StringHelper.schools}/$_kurumId/$_termKey/Announcements/$pushKey', announcement.mapForSave(pushKey)).then((_) {
      if (announcement.isPublish == true) {
        EkolPushNotificationService.sendMultipleNotification(announcement.title, announcement.content, announcement.targetList!, NotificationArgs(tag: 'announcement'));
      } else if (UserPermissionList.sendnotifyunpublisheditem() == true) {
        sendUnpublishedItemNotify(announcement.senderName!, 'publishthisannouncement'.argsTranslate({'title': announcement.title}));
      }
      _database11.set('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.announcements}', _realTime);
      if (existingKey == null) LogHelper.addLog('Announcements', _uid);
    });
  }

  // Duyuru Yayınlar
  static Future<void> publishAnnouncement(Announcement item) async {
    Map<String, dynamic> updates = {};
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/${item.key}/isPublish'] = true;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/${item.key}/timeStamp'] = _realTime;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/${item.key}/cT'] = _realTime;

    return _database22.update(updates).then((_) {
      EkolPushNotificationService.sendMultipleNotification(item.title, item.content, item.targetList!, NotificationArgs(tag: 'announcement'));
      _database11.set('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.announcements}', _realTime);
    });
  }

// Duyuru Siler
  static Future<void> deleteAnnouncement(String? existingKey) async {
    Map<String, dynamic> updates = {};
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/$existingKey/aktif'] = false;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/$existingKey/timeStamp'] = _realTime;
    return _database22.update(updates).then((_) {
      _database11.set('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.announcements}', _realTime);
    });
  }

// Duyuru Sabitler
  static Future<void> pinnedAnnouncement(Announcement item, value) async {
    Map<String, dynamic> updates = {};
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/${item.key}/isPinned'] = value;
//tododelete 1 alttaki satiri 15 agustos 2023 ten sonra sil createtime olmayinca pin tarihi degisip bildirim gonderdiginden konmustu
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/${item.key}/cT'] = item.createTime;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Announcements/${item.key}/timeStamp'] = _realTime;
    return _database22.update(updates).then((_) {
      _database11.set('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.announcements}', _realTime);
    });
  }

  // Hangi Duyurunun Çekildiğinin versiyonunu yazar;
  //todo bunun yeni versiyon mantigina gore calistigini kontrol et
  static Future<void> saveGettingAnnouncementVersion(int version) async {
    return _databaseLogss.set('${StringHelper.schools}/$_kurumId/$_termKey/AnnouncementsLogs/$_uid', version);
  }

  //Idareciye paylasmasi gerekenlerle ilgili bildirimat
  static void sendUnpublishedItemNotify(String title, String message) {
    final _uidList = AppVar.appBloc.managerService!.dataList.where((element) => element.key == 'Manager1' || element.authorityList!.contains('yetki4')).map((e) => e.key).toList();
    EkolPushNotificationService.sendMultipleNotification(title, message, _uidList, NotificationArgs(tag: 'unpublisheditem'));
  }
}
