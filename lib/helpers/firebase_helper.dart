import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/databaseconfig.dart';
import '../models/accountdata.dart';

class FirebaseHelper {
  FirebaseHelper._();

  static const _webPushNotificationEnableForManager = true;
  static const _webPushNotificationEnableForTeacher = true;
  static const _webPushNotificationEnableForStudent = false;
  static bool fcmIsSupported = true;

  static bool webPushNotificationEnable(HesapBilgileri hesapBilgileri) {
    if (!isWeb) return true;
    if (hesapBilgileri.gtS) return _webPushNotificationEnableForStudent;
    if (hesapBilgileri.gtT) return _webPushNotificationEnableForTeacher;
    if (hesapBilgileri.gtM) return _webPushNotificationEnableForManager;
    return true;
  }

  static Future<String?> getToken() async {
    if (!isWeb) return FirebaseMessaging.instance.getToken();
    final String? vapidKey = DatabaseStarter.databaseConfig.vapidKey;
    if (vapidKey.safeLength < 6) return null;
    //? Web icin izin alinmayinca hata verip threadi blokluyor
    final _tokenComleter = Completer<String?>();
    FirebaseMessaging.instance.getToken(vapidKey: vapidKey).then((value) {
      _tokenComleter.complete(value);
    }).catchError((err) {
      _tokenComleter.complete(null);
    }).unawaited;
    final _result = await _tokenComleter.future;
    // log('Yeni token $_result');
    return _result;
  }
}
