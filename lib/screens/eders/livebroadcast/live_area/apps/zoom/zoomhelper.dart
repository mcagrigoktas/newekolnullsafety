import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../../appbloc/appvar.dart';
import '../../../../../../appbloc/jwt.dart';
import '../../../livebroadcasthelper.dart';
import '../../../makeprogram/livebroadcastdatamodel.dart';
import '../../layouts/controller.dart';

class ZoomHelper {
  ZoomHelper._();

  static String getWebUrl() => 'live_z/livez.html';
  static String getWebMeetingUrl() => 'live_z/meeting.html';
  static Map<String, dynamic> getOptions({String? apiKey, String? apiSecret, int? meetingNumber, bool? isHost, String? password}) {
    Map<String, dynamic> data;
    data = {
      'ak': apiKey,
      'as': apiSecret,
      'mn': meetingNumber,
      'name': AppVar.appBloc.hesapBilgileri.name.changeTurkishCharacter.removeNonEnglishCharacter,
      'pwd': password,
      'role': isHost == true ? 1 : 0,
      'email': AppVar.appBloc.hesapBilgileri.uid!.toLowerCase() + '@user.com',
      'lang': "en-US",
      'signature': "",
      'china': 0,
      'leaveUrl': './live_z/meetingend.html',
      'webEndpoint': 'api.zoom.us',
    };
    return data;
  }

  static String? getToken(
    String domain,
    String channelKey,
  ) {
    String? token;
    try {
      token = Jwt.getJitsiJwtToken(
        domain: domain,
        name: AppVar.appBloc.hesapBilgileri.name! +
            '*' +
            AppVar.appBloc.hesapBilgileri.uid! +
            '*' +
            (kIsWeb
                ? 'W'
                : Platform.isAndroid
                    ? 'A'
                    : 'I'),
        id: AppVar.appBloc.hesapBilgileri.name! +
            '*' +
            AppVar.appBloc.hesapBilgileri.uid! +
            '*' +
            (kIsWeb
                ? 'W'
                : Platform.isAndroid
                    ? 'A'
                    : 'I'),
        channelKey: channelKey,
      );
      return token;
    } catch (err) {
      return null;
    }
  }

  static String generateSignature({String? apiKey, required String apiSecret, int? meetingNumber, bool? isHost}) {
    final role = isHost == true ? 1 : 0;
    final int time = DateTime.now().millisecondsSinceEpoch - 30000;

    final msg = utf8.encode('$apiKey$meetingNumber$time$role');
    var digest = Hmac(sha256, utf8.encode(apiSecret)).convert(msg);
    var hash = base64Encode(digest.bytes);

    final signature = base64Encode(utf8.encode('$apiKey.$meetingNumber.$time.$role.$hash'));
    return signature.replaceAll(RegExp("\\=+\$"), "");
  }

  static Widget getMeetingEndWidget() {
    return Center(
      child: 'meetingended'.translate.text.color(Fav.design.primary).fontSize(20).bold.make(),
    );
  }

  static Widget getStartOnZoomApp(String errorText) {
    final controller = Get.find<OnlineLessonController>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          'meetingstarterror'.translate.text.color(Fav.design.primary).fontSize(20).bold.make(),
          16.heightBox,
          if (!errorText.contains('not start')) errorText.text.fontSize(9).center.make(),
          16.heightBox,
          MyRaisedButton(
            onPressed: () async {
              final LiveBroadcastZoomModel zoomData = LiveBroadcastZoomModel.fromJson(controller.liveBroadcastItem!.broadcastData!);

              if (AppVar.appBloc.hesapBilgileri.gtS) {
                return zoomData.joinUrl.launch(LaunchType.url);
              } else if (AppVar.appBloc.hesapBilgileri.gtT) {
                return (await LiveBroadCastHelper.getZoomMeetingStartUrl(AppVar.appBloc.hesapBilgileri.zoomApiKey, AppVar.appBloc.hesapBilgileri.zoomApiSecret, meetingId: zoomData.meetingId)).launch(LaunchType.url);
              } else if (AppVar.appBloc.hesapBilgileri.gtM) {
                if (controller.lesson != null) {
                  return zoomData.joinUrl.launch(LaunchType.url);
                } else if (controller.liveBroadcastItem!.teacherKey == AppVar.appBloc.hesapBilgileri.uid) {
                  return (await LiveBroadCastHelper.getZoomMeetingStartUrl(AppVar.appBloc.hesapBilgileri.zoomApiKey, AppVar.appBloc.hesapBilgileri.zoomApiSecret, meetingId: zoomData.meetingId)).launch(LaunchType.url);
                } else {
                  return zoomData.joinUrl.launch(LaunchType.url);
                }
              }
            },
            text: 'meetingstaronzoomapp'.translate,
          ),
        ],
      ),
    );
  }
}
