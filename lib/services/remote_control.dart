import 'dart:convert';

import 'package:mcg_extension/mcg_extension.dart';

class RemoteControlValues {
  bool liveBroadcastPIPEnable = false;
  String agoraAppId = '';
  bool cryptedMap = false;
  bool broadcaststartpage = false;
  String? jitsiJwtData;
  bool excelIsSpreadSheet = true;
  bool useFirestoreForSocial = false || isDebugMode;
  // bool useFirestoreForSocial = false;

  List? jitsiJwtInfo(String? domain) {
    try {
      if (jitsiJwtData == null) return null;
      var edittedDomain = domain!.replaceAll('https://', '').replaceAll('http://', '').trim();
      if (edittedDomain.endsWith('/')) edittedDomain = edittedDomain.substring(0, edittedDomain.length - 1);

      final Map jitsiJwtMap = json.decode(jitsiJwtData!);

      if (jitsiJwtMap.containsKey(edittedDomain)) {
        final Map data = jitsiJwtMap[edittedDomain];

        return [
          //   (data['ak'] as String).unMix,
          (data['as'] as String?).unMix,
          (data['sub'] as String?).unMix,
          (data['iss'] as String?).unMix,
          (data['aud'] as String?).unMix,
          data['t'],
        ];
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }
}
