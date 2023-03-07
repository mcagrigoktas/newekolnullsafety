import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../helpers/firebase_helper.dart';
import '../services/remote_control.dart';
import 'appconfig.dart';
import 'dbconfigs/helper.dart';
import 'themelist/helper.dart';

class MainHelper {
  Future<void> initializeBeforeRunApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    Hive.registerAdapter(TimeStampAdapter());
    await GetStarter.initAppController();
    await Firebase.initializeApp(options: DefaultFirebaseOptionsForFlavor.currentFlavor);
    if (isWeb) _setupWebNotification().unawaited;
    await GetStarter.init();
    if (isWeb) {
      if (DateTime.now().day == 1 && Fav.preferences.getBool(DateTime.now().dateFormat("d-MM-yyyy")) != true) {
        DownloadManager.clearExpireditem().then((value) => Fav.preferences.setBool(DateTime.now().dateFormat("d-MM-yyyy"), true)).unawaited;
      }
    }
    if (Get.find<AppConfig>().appType == AppType.qbank) {
      ThemeHelper.setQbankTheme();
    } else {
      ThemeHelper.setEkolTheme(null);
    }
  }

  Future<void> _setupWebNotification() async {
    final fcmIsSupported = await FirebaseMessaging.instance.isSupported();
    FirebaseHelper.fcmIsSupported = fcmIsSupported;
    if (FirebaseHelper.fcmIsSupported) {
      //? Bu configtext simdilik gonderilmesi bi ise yaramiyor url ile degilde post message ile gondermek lazim sanirim
      var _configText = DefaultFirebaseOptionsForFlavor.currentFlavor.urlText;
      await PlatformFunctions.registerServiceWorker('firebase-messaging-sw.js?' + _configText);
    }
  }
}

class GetStarter {
  GetStarter._();

  static Future<void> initAppController() async {
    @unModifiable
    final _commonEncryptKey = utf8.decode(Uint8List.fromList([97, 120, 115, 119, 101, 117, 114, 104, 100, 115, 97, 115, 100, 101, 102, 100, 118, 98, 100, 101, 104, 103, 100, 101, 102, 103, 104, 121, 102, 100, 101, 119]));

    @unModifiable
    final _mapEncKey = utf8.decode(Uint8List.fromList([56, 103, 69, 117, 90, 109, 105, 117, 111, 115, 55, 103, 88, 111, 50, 107, 88, 116, 97, 97, 76, 57, 115, 53, 105, 48, 117, 103, 79, 110, 118, 49, 113]));

    @unModifiable
    final _iVEncKey = utf8.decode(Uint8List.fromList([78, 48, 83, 56, 56, 85, 55, 88, 74, 53, 105, 51, 66, 76, 120, 109, 68, 53, 88, 81, 97, 97, 49, 113, 97, 115, 101, 51, 51, 49, 50, 115, 97]));

    final _appController = AppController(
      commonEncryptKey: _commonEncryptKey,
      iVEncKey: _iVEncKey,
      mapEncKey: _mapEncKey,
    );
    Get.put<AppController>(_appController, permanent: true);
    await _appController.init();
    Fav.writeSeasonCache('RealTimeDataFetcherBoxVersion', AppConst.dataFetcherBoxVersion);
    Fav.writeSeasonCache('MultipleDataFCS', AppConst.multipleDataFCS);
    Fav.writeSeasonCache('RealTimeDataMiniFetcherBoxVersion', AppConst.miniFetcherBoxVersion);
    Fav.writeSeasonCache('FirestoreDataFetcherBoxVersion', AppConst.fireStoreDataFetcherBoxVersion);
  }

  static Future<void> init() async {
    Get.put<ServerSettings>(ServerSettings(), permanent: true);
    Get.put<PhotoVideoCompressSetting>(PhotoVideoCompressSetting(showPhotoSizeAfterCompression: isDebugMode), permanent: true);
    Get.put<RemoteControlValues>(RemoteControlValues(), permanent: true);
  }
}

class AppConst {
  static const String appVersion = '2.1.0';
  static const int cacheBoxVersion = 15;
  static const int versionListBoxVersion = 15;
  static const int dataFetcherBoxVersion = 15;
  static const int multipleDataFCS = 15;
  static const int fireStoreDataFetcherBoxVersion = 15;
  static const int miniFetcherBoxVersion = 15;
  static const int preferenecesBoxVersion = 15;
  static const int stickerCount = 132;
  static const List<String> accountingType = ['paymenttype1', 'paymenttype2', 'paymenttype3', 'paymenttype4', 'paymenttype5', 'custompayment'];
}
