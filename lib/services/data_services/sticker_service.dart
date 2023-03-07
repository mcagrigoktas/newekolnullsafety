part of '../dataservice.dart';

class StickerService {
  StickerService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid!;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Etiketler Referansı
  static Reference dbStickersProfilesRef() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Stickers/Profiles');

  // Etiketler Referansı
  static Reference dbStudentStickersRef(String? studentKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Stickers/Datas/$studentKey');

//! SETDATASERVICE

//Etiketler defaulat değerleri yazar

  static Future<void> dbSetStickerProfile(String? className, List<Sticker> stickerList, {bool sendNotification = false}) {
    //final data = stickerList.map((sticker) => sticker.mapForSave()).toList();
    Map<String, dynamic> updates = {};
    stickerList.forEach((item) {
      updates["/Okullar/$_kurumId/$_termKey/Stickers/Profiles/${item.key}"] = (item.mapForSave()..['lastUpdate'] = _realTime);
    });
    return _database33.update(updates).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/StickerProfiles', _realTime);
      if (sendNotification == true) {
        final _studentList = AppFunctions2.getStudenKeytListThisClass(stickerList.first.classKey!);
        InAppNotificationService.sendSameInAppNotificationMultipleTarget(
          InAppNotification(
            title: AppVar.appBloc.hesapBilgileri.name,
            content: 'stickerlistchanged'.translate,
            type: NotificationType.stickers,
            pageName: PageName.S,
            key: 'stickerlistchanged',
          ),
          _studentList,
        );
      }
    });
  }

// Etiket yildizini degistirir

  static Future<void> dbSetStickersStar(String studentKey, Sticker sticker, int count, {bool sendNotification = false}) {
    return _database33.set('Okullar/$_kurumId/$_termKey/Stickers/Datas/$studentKey/${sticker.key}/stars', count).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$studentKey/StudentStickersData', _realTime);
      LogHelper.addLog('GiveStars', _uid);
    }).then((value) {
      if (sendNotification) {
        InAppNotificationService.sendInAppNotification(
          InAppNotification(
            title: sticker.title,
            content: 'studentearnstar'.argsTranslate({'name': AppFunctions2.whatIsThisName(studentKey, onlyStudent: true)}),
            type: NotificationType.stickers,
            pageName: PageName.S,
            key: 'NS' + sticker.key!,
          ),
          studentKey,
        );
      }
    });
  }
}
