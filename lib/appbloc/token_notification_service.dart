import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_icon_badge/flutter_app_icon_badge.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../helpers/firebase_helper.dart';
import '../screens/main/widgets/user_profile_widget/user_image_helper.dart';
import '../services/dataservice.dart';
import 'appvar.dart';

class TokenAndNotificationListenerService {
  TokenAndNotificationListenerService._();

  static void setUp() {
    if (isWeb && FirebaseHelper.fcmIsSupported == false) return;

    _requestPermission();
    _firebaseCloudMessagingListeners();
    if (AppVar.appBloc.hesapBilgileri.isGood) {
      _saveToken();
      _subscribeTopic();
    }
  }

  static void _requestPermission() {
    final _firebaseMessaging = FirebaseMessaging.instance;
    if (isIOS) {
      _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    } else if (isWeb) {
      _firebaseMessaging.requestPermission();
    } else if (isAndroid) {
      _firebaseMessaging.requestPermission();
    }
  }

  static void _subscribeTopic() {
    //? Web de simdilik topic yok sanirim incele
    if (isWeb) return;
    final _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.subscribeToTopic(AppVar.appBloc.hesapBilgileri.kurumID + 'pushnotification');
    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      //? Only teachers bildirimierni bu topicten at
      _firebaseMessaging.subscribeToTopic(AppVar.appBloc.hesapBilgileri.kurumID + 'onlyteachers');
    }
  }

  static void _saveToken() {
    if (isWeb && FirebaseHelper.webPushNotificationEnable(AppVar.appBloc.hesapBilgileri) == false) return;
    FirebaseHelper.getToken().then((token) async {
      if (token == null) return;
      Fav.writeSeasonCache('notificationToken', token);

      final String tokenPreferencesKey = "${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.girisTuru}${AppVar.appBloc.hesapBilgileri.uid}_token3";
      if (token != (Fav.preferences.getString(tokenPreferencesKey, "-1"))) {
        await SignInOutService.dbAddToken2(token, await DeviceManager.getDeviceModel()).then((_) {
          log('Yeni token kaydedildi');
          Fav.preferences.setString(tokenPreferencesKey, token);
        });
      }
    });
  }

  static StreamSubscription? _onMessageSubscription;
  static StreamSubscription? _onMessageOpenedAppSubscription;

  static Future<void> _firebaseCloudMessagingListeners() async {
    if (isIOS) {
      FlutterAppIconBadge.removeBadge().unawaited;
    }
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();
    _onMessageSubscription = null;
    _onMessageOpenedAppSubscription = null;

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      final String? tag = event.data['tag'];

      final _notificationTag = NotificationArgs.fromStringJson(tag);

      if (_notificationTag.forDifferentUser(AppVar.appBloc.hesapBilgileri.uid)) {
        final _otherUserAccountInfo = UserImageHelper.getAnyUserInThisUserList(_notificationTag.getUidList());
        if (_otherUserAccountInfo == null) {
          OverAlert.show(message: event.notification!.title! + '\n' + event.notification!.body!, autoClose: false);
        } else {
          OverAlert.show(title: 'notifyforthisuser'.argsTranslate({'name': _otherUserAccountInfo.name}), message: event.notification!.title! + '\n' + event.notification!.body!, autoClose: false);
        }
      } else {
        OverAlert.show(message: event.notification!.title! + '\n' + event.notification!.body!, autoClose: false);
      }
    });

    Future<void> _changeUserFunction(RemoteMessage? event, bool useDelay) async {
      if (event?.notification == null) return;
      final String? tag = event!.data['tag'];

      final _notificationTag = NotificationArgs.fromStringJson(tag);

      if (_notificationTag.forDifferentUser(AppVar.appBloc.hesapBilgileri.uid)) {
        final _otherUserAccountInfo = UserImageHelper.getAnyUserInThisUserList(_notificationTag.getUidList());
        if (_otherUserAccountInfo != null) {
          await (useDelay ? 4000 : 100).wait;
          final lastNMST = Fav.preferences.getInt('lastNMST', 0);
          final messageNMST = event.sentTime!.millisecondsSinceEpoch;

          if (lastNMST != messageNMST) {
            await Fav.preferences.setInt('lastNMST', messageNMST);
            final _result = await OverBottomSheet.show(BottomSheetPanel.defaultPanel(
              okButtonText: 'yes'.translate,
              cancelText: 'no'.translate,
              title: 'switchthisuser'.argsTranslate({'name': _otherUserAccountInfo.name}),
            ));
            if (_result == true) UserImageHelper.selectAccount(_otherUserAccountInfo, SelectUserMenuType.ProfileImage);
          }
        }
      }
    }

    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((event) {
      _changeUserFunction(event, false);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((event) {
          _changeUserFunction(event, true);
        })
        .catchError((err) {})
        .unawaited;
  }
}
