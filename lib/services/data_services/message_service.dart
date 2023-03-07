part of '../dataservice.dart';

class MessageService {
  MessageService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;
  static Database get _database22 => AppVar.appBloc.database2;
  static dynamic get _realTime => databaseTime;
  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

//! GETDATASERVICE

// Mesajlar  Referansı
  static Reference dbChats(String? targetKey, [String? ghostUid]) => Reference(_database22, 'Okullar/$_kurumId/$_termKey/Messages/Chats/${ghostUid ?? _uid}/$targetKey');

  // Mesaj onizleme Referansı
  static Reference dbMessagesPreviewRef([ghostUid]) => Reference(_database22, 'Okullar/$_kurumId/$_termKey/Messages/MessagesPreview/${ghostUid ?? _uid}');

  //DatabaseReference dbMessageLoginTime(String targetKey) => databaseLogs.child("Okullar").child(kurumId).child(termKey).child("MessageIsSeen").child(targetKey);
  static Reference dbMessageLoginTime(String? targetKey) => Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/MessageIsSeen/$targetKey');

//! SETDATASERVICE

// (Gönfderllecek kişi keyleri,Gönferilecesk medsaj, Gönderen kişinin preview sayfasınındeğitirir. Map içinde göndereilek her kişinin keyine ait preview gelir.,gönderilecek kilinin preview sayfasını değilştirir.)
  static Future<void> sendMultipleMessage(
      List<String?> keyList,
      ChatModel message,
      //  Map messageData,
      Map<String?, MesaggingPreview> ownMessagePreviewData,
      MesaggingPreview targetMessagePreviewData,
      {bool? forParentMessageMenu = false,
      String? existingKey,
      String? parentVisibleCodeForNotification}) async {
    String key = existingKey ?? _database22.pushKey('Okullar/$_kurumId/$_termKey/Messages/Chats/$_uid/${keyList.first}');

    const groupLength = 500;
    final groupSize = keyList.length ~/ groupLength + 1;
    List<Future> futureList = [];
    for (var i = 0; i < groupSize; i++) {
      Map<String, dynamic> updates = {};
      var subList = keyList.sublist((i * groupLength).clamp(0, keyList.length), ((i + 1) * groupLength).clamp(0, keyList.length));
      subList.forEach((userKey) {
        updates['/Okullar/$_kurumId/$_termKey/Messages/MessagesPreview/$_uid/$userKey'] = Map<String, dynamic>.from(ownMessagePreviewData[userKey]!.mapForSave())..addAll({"owner": true});
        updates['/Okullar/$_kurumId/$_termKey/Messages/MessagesPreview/$userKey/$_uid'] = Map<String, dynamic>.from(targetMessagePreviewData.mapForSave())..addAll({"owner": false});
        updates['/Okullar/$_kurumId/$_termKey/Messages/Chats/$_uid/$userKey/$key'] = Map<String, dynamic>.from(message.mapForSave())..addAll({"owner": true});
        updates['/Okullar/$_kurumId/$_termKey/Messages/Chats/$userKey/$_uid/$key'] = Map<String, dynamic>.from(message.mapForSave())..addAll({"owner": false});
      });

      if (subList.isNotEmpty) futureList.add(_database22.update(updates));
    }

    Map<String, dynamic> updatesPersonalVersion = {};
    keyList.forEach((userKey) {
      updatesPersonalVersion['/Okullar/$_kurumId/$_termKey/$userKey/MessagesPreview'] = _realTime;
      if (forParentMessageMenu == true && AppVar.appBloc.hesapBilgileri.gtMT) {
        if (parentVisibleCodeForNotification!.contains('2')) {
          updatesPersonalVersion['/Okullar/$_kurumId/$_termKey/$userKey/newMessageParent2'] = true;
        } else {
          updatesPersonalVersion['/Okullar/$_kurumId/$_termKey/$userKey/newMessageParent'] = true;
        }
      }

      if (forParentMessageMenu == false) updatesPersonalVersion['/Okullar/$_kurumId/$_termKey/$userKey/newMessage'] = true;
    });
    updatesPersonalVersion['/Okullar/$_kurumId/$_termKey/$_uid/MessagesPreview'] = _realTime;

    return Future.wait(futureList).then((_) {
      if (existingKey == null) {
        if (keyList.length > 1) {
          EkolPushNotificationService.sendMultipleNotification(AppVar.appBloc.hesapBilgileri.name, message.message, keyList, NotificationArgs(tag: 'message'), forParentMessageMenu: forParentMessageMenu, parentVisibleCodeForNotification: parentVisibleCodeForNotification);
        } else if (keyList.length == 1) {
          EkolPushNotificationService.sendSingleNotification(AppVar.appBloc.hesapBilgileri.name, message.message, keyList.first, NotificationArgs(tag: 'message'), forParentMessageMenu: forParentMessageMenu, parentVisibleCodeForNotification: parentVisibleCodeForNotification);
        }
        LogHelper.addLog('Messages', _uid, keyList.length);
      }
      _databaseVersionss.update(updatesPersonalVersion);
    });
  }
//  Future<void> sendMultipleMessage(List<String> keyList, Map messageData, Map ownMessagePreviewData, Map targetMessagePreviewData) async {
//    Map<String, dynamic> updates =    {};
//    Map<String, dynamic> updatesPersonalVersion =    {};
//
//    String key = database22.pushKey('Okullar/$kurumId/$termKey/Messages/Chats/$uid/${keyList.first}');
//    keyList.forEach((userKey) {
//      updates['/Okullar/$kurumId/$termKey/Messages/MessagesPreview/$uid/$userKey'] =   Map<String, dynamic>.from(ownMessagePreviewData[userKey])..addAll({"owner": true});
//      updates['/Okullar/$kurumId/$termKey/Messages/MessagesPreview/$userKey/$uid'] =   Map<String, dynamic>.from(targetMessagePreviewData)..addAll({"owner": false});
//      updates['/Okullar/$kurumId/$termKey/Messages/Chats/$uid/$userKey/$key'] =   Map<String, dynamic>.from(messageData)..addAll({"owner": true});
//      updates['/Okullar/$kurumId/$termKey/Messages/Chats/$userKey/$uid/$key'] =   Map<String, dynamic>.from(messageData)..addAll({"owner": false});
//      updatesPersonalVersion['/Okullar/$kurumId/$termKey/$userKey/MessagesPreview'] = realTime;
//      updatesPersonalVersion['/Okullar/$kurumId/$termKey/$userKey/newMessage'] = true;
//    });
//    updatesPersonalVersion['/Okullar/$kurumId/$termKey/$uid/MessagesPreview'] = realTime;
//    return database22.update(updates).then((_) {
//      if (keyList.length > 1) {
//        sendMultipleNotification(appBloc, appBloc.hesapBilgileri.name, messageData['message'], keyList, tag: 'message');
//      } else if (keyList.length == 1) {
//        sendSingleNotification(appBloc, appBloc.hesapBilgileri.name, messageData['message'], keyList.first, tag: 'message');
//      }
//      databaseVersionss.update(updatesPersonalVersion);
//      addLog('Messages', uid, keyList.length);
//    });
//  }

  //,Mesajlar kismina giris yapildiginda zamanini kaydeder
  static Future<void> setMessageLoginTime(String? userUid) => _databaseLogss.set("Okullar/$_kurumId/$_termKey/MessageIsSeen/$userUid", _realTime);

  //,Yeni mesaj geldiginin bilgisini siler
  static Future<void> setFalseNewMessage({required bool isParent, int? parentNo}) {
    final _key = isParent ? ('newMessageParent' + (parentNo == 2 ? '2' : '')) : 'newMessage';
    return _databaseVersionss.set("Okullar/$_kurumId/$_termKey/$_uid/$_key", false);
  }
}
