import 'dart:io';

import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../../appbloc/appvar.dart';
import '../../../../../../services/remote_control.dart';

class AgoraHelper {
  AgoraHelper._();

  static String getWebUrl() => 'live_ag/aglive.html';

  static Future<Map<String, dynamic>> getOptionsMobile(String domain, String channelName) async {
    Map deviceInfoMap = {};
    if (Platform.isAndroid) {
      deviceInfoMap['dvc'] = 'A';
    } else {
      deviceInfoMap['dvc'] = 'I';
    }

    return getOptions(domain, channelName)..['di'] = deviceInfoMap;
  }

  static Map<String, dynamic> getOptions(String? domain, String? channelName) {
    return {
      'n': AppVar.appBloc.hesapBilgileri.name.changeTurkishCharacter,
      'k': AppVar.appBloc.hesapBilgileri.uid,
      'd': Get.find<RemoteControlValues>().agoraAppId,
      'rn': channelName ?? 'AgoraGenerallyChannel',
      'gt': AppVar.appBloc.hesapBilgileri.girisTuru.toString(),
      'sh': 'studentjoinlivelessonhint'.translate,
      't': null, //Agora token
      'res': AppVar.appBloc.hesapBilgileri.gtMT ? 640 : 240
    };
  }

  // static String makeAgoraId() {
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 4, 25).millisecondsSinceEpoch) return '';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 5, 25).millisecondsSinceEpoch) return '67deda2aadfc4769890cad40c8bf900d';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 6, 25).millisecondsSinceEpoch) return '3da05dfa3bd34c5297d5ebb12707f2c0';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 7, 25).millisecondsSinceEpoch) return 'f658ef45269f4434b4434478586d0de6';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 8, 25).millisecondsSinceEpoch) return 'fa787eaa52524ad0a9337049d514033a';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 9, 25).millisecondsSinceEpoch) return '9fcdf0d2904c47a4ac056722edb874f9';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 10, 25).millisecondsSinceEpoch) return 'ace8fc1de35e4c9b865678ab40957b5f';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 11, 25).millisecondsSinceEpoch) return '0bb5b546bfb24d4f96f4f1089e4b8583';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2020, 12, 25).millisecondsSinceEpoch) return 'ebd51c64b31f48479af14570466c9881';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2021, 1, 25).millisecondsSinceEpoch) return '098bf4f4af144d75bc14091d5bb293fa';
  //   if (DateTime.now().millisecondsSinceEpoch < DateTime(2021, 2, 25).millisecondsSinceEpoch) return '098bf4f4af144d75bc14091d5bb293fa';
  //   //  if (DateTime.now().millisecondsSinceEpoch < DateTime(2021, 2, 25).millisecondsSinceEpoch) return '37817b27ebe04d4d8392c2614adddc59';
  //   return '';
  // }
}
