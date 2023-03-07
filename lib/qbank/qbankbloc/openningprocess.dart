import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';

class OpeningProcess {
  void openingProcess() {
    if (Platform.isIOS) {
      _iosPermission();
    }
    _tokenGuncelle();
  }

  static StreamSubscription? _onMessageSubscription;
  Future<void> _tokenGuncelle() async {
    await _onMessageSubscription?.cancel();

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      OverAlert.show(message: event.notification!.title! + '\n' + event.notification!.body!);
    });

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) {
    //     Alert.alert(
    //       message: message["notification"]["title"] + '\n' + message["notification"]["body"],
    //     );

    //     return null;
    //   },
    //   onLaunch: (Map<String, dynamic> message) {},
    //   onResume: (Map<String, dynamic> message) {},
    // );

    if (AppVar.qbankBloc.hesapBilgileri.girisYapildi!) {
      if ('lang'.translate == 'tr') {
        FirebaseMessaging.instance.subscribeToTopic("AnnouncementsTR").unawaited;
      }
    }
  }

  void _iosPermission() {
    final _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    // FirebaseMessaging().requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    // FirebaseMessaging().onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
  }
}
