import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../../appbloc/appvar.dart';
import '../../../../../../appbloc/jwt.dart';

class JitsiNewHelper {
  JitsiNewHelper._();

  static String getWebUrl() => 'livenew9.html';

  // static Future<Map<String, dynamic>> getOptionsMobile(String domain, String channelName) async {
  //   Map deviceInfoMap = {};
  //   if (Platform.isAndroid) {
  //     deviceInfoMap['dvc'] = 'A';
  //   } else {
  //     deviceInfoMap['dvc'] = 'I';
  //   }
  //
  //   return getOptions(domain, channelName)..['di'] = deviceInfoMap;
  // }

  static JitsiConfigData getOptions(String? domain, String? channelName) {
    //
    return JitsiConfigData(
      userName: AppVar.appBloc.hesapBilgileri.name,
      userKey: AppVar.appBloc.hesapBilgileri.uid,
      domain: domain,
      roomName: channelName ?? 'ChannelABCDEF',
      liveLessonHint: 'studentjoinlivelessonhint'.translate,
      backgorundColor: Fav.design.scaffold.background.toHex.substring(Fav.design.scaffold.background.toHex.length - 6),
      jwtToken: getToken(domain, channelName ?? 'ChannelABCDEF'),
      girisTuru: AppVar.appBloc.hesapBilgileri.girisTuru.toString(),
      edittedKey: AppVar.appBloc.hesapBilgileri.name! + '*' + AppVar.appBloc.hesapBilgileri.uid,
    );

    // return {
    //   'n': AppVar.appBloc.hesapBilgileri.name,
    //   'k': AppVar.appBloc.hesapBilgileri.uid,
    //   'd': domain,
    //   'rn': channelName ?? 'ChannelABCDEF',
    //   'gt': AppVar.appBloc.hesapBilgileri.girisTuru.toString(),
    //   'to': [],
    //   'sh': 'studentjoinlivelessonhint'.translate,
    //   'res': AppVar.appBloc.hesapBilgileri.gtMT ? 480 : 320,
    //   'bC': Fav.design.scaffold.background.toHex.substring(Fav.design.scaffold.background.toHex.length - 6),
    //   'jwt': getToken(domain, channelName ?? 'ChannelABCDEF'),
    //   // if (kDebugMode) 'rP': channelName.mix,
    //   //  AppVar.appBloc.appConfig.databaseVersion == 1
    // };
  }

  static String? getToken(
    String? domain,
    String? channelKey,
  ) {
    String? token;
    try {
      token = Jwt.getJitsiJwtToken(
        domain: domain,
        name: AppVar.appBloc.hesapBilgileri.name! +
            '*' +
            AppVar.appBloc.hesapBilgileri.uid +
            '*' +
            (kIsWeb
                ? 'W'
                : Platform.isAndroid
                    ? 'A'
                    : 'I'),
        id: AppVar.appBloc.hesapBilgileri.name! +
            '*' +
            AppVar.appBloc.hesapBilgileri.uid +
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
}

class JitsiConfigData {
  String? userName;
  String? userKey;
  String? domain;
  String? roomName;
  String? girisTuru;
  String? backgorundColor;
  String? jwtToken;
  String? edittedKey;
  String? liveLessonHint;

  JitsiConfigData({
    this.userName,
    this.userKey,
    this.domain,
    this.roomName,
    this.girisTuru,
    this.backgorundColor,
    this.jwtToken,
    this.edittedKey,
    this.liveLessonHint,
  });
}

class DeviceModel {
  int no;
  Map data;
  String? name;
  String? deviceId;
  String? groupId;

  DeviceModel.jitsi(this.data, this.no) {
    name = data['label'];
    deviceId = data['deviceId'];
    groupId = data['groupId'];
  }

  /// deviceType: speaker, mic, cam
  String? edittedName(String deviceType) => name.safeLength > 3 ? name : (deviceType.translate + ' ' + no.toString());
  Map get jitsiSendDataMap => {'deviceLabel': name, 'deviceId': deviceId};
}
