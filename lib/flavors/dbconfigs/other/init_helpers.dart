import 'package:firebase_core/firebase_core.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'ecolerrors.dart';
import 'ecollogss.dart';

class FirebaseInitHelper {
  FirebaseInitHelper._();
  static Future<FirebaseApp> getErrorApp() async {
    return Get.findOrPutAsync<FirebaseApp>(
        createFunction: () async {
          final _app = Firebase.apps.singleWhereOrNull((element) => element.name == 'ErrorsLogs');
          return (_app ?? await Firebase.initializeApp(name: 'ErrorsLogs', options: EcollErrorsFirebaseOptions.currentPlatform));
        },
        tag: 'ErrorsLogs');
  }

  static Future<FirebaseApp> getLogsApp() async {
    return Get.findOrPutAsync<FirebaseApp>(
        createFunction: () async {
          final _app = Firebase.apps.singleWhereOrNull((element) => element.name == 'Logs');
          return (_app ?? await Firebase.initializeApp(name: 'Logs', options: EcollLogssFirebaseOptions.currentPlatform));
        },
        tag: 'Logs');
  }
}
