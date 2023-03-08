part of '../dataservice.dart';

class LiveBroadCastService {
  LiveBroadCastService._();

  static String get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static dynamic get _realTime => databaseTime;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _database22 => AppVar.appBloc.database2;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

//! GETDATASERVICE

  // Video Chat Message  Referansı
  static Reference dbVideoChats(String channelKey) => Reference(_database22, 'Okullar/$_kurumId/$_termKey/Messages/VideoChats/$channelKey');
  // static Reference dbVideoChatSettings(String channelKey) => Reference(_database22, 'Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/$channelKey');
  static Reference dbVideoChatSettings(String channelKey) =>
      AppVar.appBloc.hesapBilgileri.gtS ? Reference(_database22, 'Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/${channelKey + 'v2'}/settings') : Reference(_database22, 'Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/${channelKey + 'v2'}');

//Canli yayin listesini ceker
  static Reference dbGetLiveBroadcastLessons() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/LiveBroadCast');
//Canli yayin Katilimci listesini ceker
  static Reference dbGetLiveBroadcastUser(String channelKey) => Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey');
//Ogrencinin canli yayina katilip katilmadigini ogrenciye ilterir
  static Reference dbGetStudentIsLiveSpeaker(String channelKey) {
    return Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/${AppVar.appBloc.hesapBilgileri.name.toFirebaseSafeKey.removeNonEnglishCharacter}---$_uid/b');
  }

//! SETDATASERVICE
//Video Chat Mesaji yazar
  static Future<void> addVideoChatsMessage(channelKey, messageData) => _database22.push('Okullar/$_kurumId/$_termKey/Messages/VideoChats/$channelKey', messageData);
  static Future<void> setVideoChatSetting(channelKey, settingData) => _database22.set('Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/${channelKey + 'v2'}/settings', settingData);
  static Future<void> startVideoChatRollCall(channelKey, settingData) {
    Map<String, dynamic> updates = {};
    updates['Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/${channelKey + 'v2'}/settings'] = settingData;
    updates['Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/${channelKey + 'v2'}/hereList'] = {};
    return _database22.update(updates);
  }

  static Future<void> setIAmHere(channelKey) {
    return _database22.set('Okullar/$_kurumId/$_termKey/Messages/VideoChatSettings/${channelKey + 'v2'}/hereList/$_uid', true);
  }

  // VideoLesson Kaydeder
  ///
  static Future<void> saveBroadcastProgram(LiveBroadcastModel item, {String? existingKey}) async {
    Map<String, dynamic> updates = {};

    String key = existingKey ?? _database33.pushKey('Okullar/$_kurumId/$_termKey/LiveBroadCast');
    updates['/Okullar/$_kurumId/$_termKey/LiveBroadCast/$key'] = item.mapForSave();
    return _database33.update(updates).then((_) {
      // InAppNotificationService.sendSameInAppNotificationMultipleTarget(
      //     InAppNotification(
      //       title: item.lessonName,
      //       content: 'broadcaslessonaddednotify'.translate,
      //       key: 'NELC${item.lessonName.removeNonEnglishCharacter}',
      //       type: NotificationType.eLessson,
      //       pageName: PageName.eLP,
      //     ),
      //     item.targetList,
      //     notificationTag: 'broadcastlesson');

      EkolPushNotificationService.sendMultipleNotification(item.lessonName, 'broadcaslessonaddednotify'.translate, item.targetList!, NotificationArgs(tag: 'broadcastlesson'));
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.liveBroadCast}', _realTime);
    });
  }

  static Future<void> deleteBroadcastProgram(String itemKey) async {
    Map<String, dynamic> updates = {};

    updates['/Okullar/$_kurumId/$_termKey/LiveBroadCast/$itemKey/aktif'] = false;
    updates['/Okullar/$_kurumId/$_termKey/LiveBroadCast/$itemKey/lastUpdate'] = _realTime;

    return _database33.update(updates).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.liveBroadCast}', _realTime);
    });
  }

  /// Online derse katildigini-yada ciktigini kaydeder
  /// 0 hic girmedi, 1 online 2 cikmis
  static Future<void> saveLiveBroadcastStatus(String channelKey, Map status) {
    return _databaseLogss.set('Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/${AppVar.appBloc.hesapBilgileri.name.toFirebaseSafeKey}---$_uid', status);
  }

  /// ogrenciye soz verir
  static Future<void> addUserLiveBroadcastStatus(String channelKey, List<String> targetList, String student, bool sozVerildi, {bool digerOgrencileriAt = true}) {
    Map<String, dynamic> updates = {};
    //todo error burda allusers falan varsa ogrenciyi atiyomu yoksa all user gelmiyormu asahisi fiyasko updates nerede

    if (digerOgrencileriAt) {
      targetList.forEach((element) {
        updates['/Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/$element/b'] = 0;
      });
    }

    if (sozVerildi == false) updates['/Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/$student/b'] = 2;
    return _databaseLogss.update(updates);
  }

  // /// ogrenciye soz verir
  // static Future<void> jitsiAddUserLiveBroadcastStatus(
  //   String channelKey,
  //   List<String> targetList,
  //   String student,
  //   bool sozVerildi, {
  //   bool digerOgrencileriAt = true,
  //   bool butunOgrencileriAl = false,
  // }) {
  //   Map<String, dynamic> updates = {};
  //   //todo error burda allusers falan varsa ogrenciyi atiyomu yoksa all user gelmiyormu asahisi fiyasko updates nerede
  //
  //   if (digerOgrencileriAt) {
  //     targetList.forEach((element) {
  //       updates['/Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/$element/b'] = Random().nextInt(400);
  //     });
  //   }
  //
  //   if (butunOgrencileriAl) {
  //     targetList.forEach((element) {
  //       updates['/Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/$element/b'] = 500 + Random().nextInt(400);
  //     });
  //   }
  //
  //   if (student != null) {
  //     if (sozVerildi == true) {
  //       updates['/Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/$student/b'] = 500 + Random().nextInt(400);
  //     } else {
  //       updates['/Okullar/$_kurumId/$_termKey/LiveBroadcastLogs/$channelKey/$student/b'] = Random().nextInt(400);
  //     }
  //   }
  //
  //   return _databaseLogss.update(updates);
  // }
}
