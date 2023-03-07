import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:ntp/ntp.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/firebase_helper.dart';
import '../qbankbloc/setdataservice.dart';
import '../screens/bookpreviewspage/bookpreviewspage.dart';

class SendResult {
  SendResult._();

  static Future<bool?> send(bool showOverlay, IcindekilerItem icindekilerItem, String bookKey) async {
    var box = await Get.openSafeBox('$bookKey${icindekilerItem.denemeKey}answerresult');
    if (box.toMap().isEmpty) {
      if (showOverlay) OverAlert.show(type: AlertType.danger, message: 'erranswersend'.translate);
      return null;
    }
    if ((await NTP.now()).millisecondsSinceEpoch > (icindekilerItem.denemeEndTime! + 3600000)) {
      if (showOverlay) OverAlert.show(type: AlertType.danger, message: 'erranswersend2'.translate);
      return null;
    }
    Completer<bool> completer = Completer();

    if (showOverlay) OverLoading.show();

    QBSetDataService.sendDenemeStatistics({
      'userData': {
        'name': AppVar.qbankBloc.hesapBilgileri.name,
        'token': kIsWeb ? '' : await FirebaseHelper.getToken(),
      },
      'resultData': box.toMap()
    }, bookKey, icindekilerItem.denemeKey, AppVar.qbankBloc.hesapBilgileri.uid)
        .then((value) async {
      if (showOverlay) await OverLoading.close();
      await Fav.preferences.setBool(icindekilerItem.denemeKey + 'sonucgonderildi', true);
      completer.complete(true);
    }).catchError((err) {
      completer.complete(false);
    }).unawaited;

    return completer.future;
  }
}
