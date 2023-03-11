import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import 'makeprogram/livebroadcastdatamodel.dart';

class LiveBroadCastHelper {
  LiveBroadCastHelper._();

  static Widget broadcastTypeWidget(Function(dynamic) onSaved, Function(dynamic) onChanged, initialValue) {
    final liveLessonTypes = <DropdownItem<int?>>[];
    liveLessonTypes.add(DropdownItem(value: null, name: 'anitemchoose'.translate));

    if (AppVar.appBloc.schoolInfoService!.singleData!.livedomainlist.safeLength > 4) {
      liveLessonTypes.add(DropdownItem(value: 5, name: 'livebroadcasturltype4'.translate));
    }

    if (AppVar.appBloc.hesapBilgileri.zoomApiKey.safeLength > 6 && AppVar.appBloc.hesapBilgileri.zoomApiSecret.safeLength > 6) {
      liveLessonTypes.add(DropdownItem(value: 9, name: 'ZOOM'));
    } else {
      liveLessonTypes.add(DropdownItem(value: 2, name: 'ZOOM'));
    }
    liveLessonTypes.add(DropdownItem(value: 3, name: 'Google Meet'));
    liveLessonTypes.add(DropdownItem(value: 10, name: 'other'.translate));
    return AdvanceDropdown(
      name: "livebroadcasturltype".translate,
      iconData: MdiIcons.accessPoint,
      items: liveLessonTypes,
      onSaved: onSaved,
      onChanged: onChanged,
      initialValue: initialValue,
    );
  }

  // static Widget broadCastChatSettingsWidget(Function onSaved, initialValue, int broadcastType) {
  //   if (broadcastType != 5) return const SizedBox();
  //
  //   return MyDropDownField(
  //     canvasColor: Fav.design.dropdown.canvas,
  //     name: "chats".translate,
  //     iconData: MdiIcons.access_point,
  //     color: Colors.red,
  //     items: [1, 2, 3].map((e) => DropdownMenuItem(child: 'chatsenable$e'.translate.text.make(), value: e)).toList(),
  //     onSaved: onSaved,
  //     initialValue: initialValue,
  //   );
  // }

  static String? getJitsiDomain() {
    return AppVar.appBloc.schoolInfoService!.singleData!.livedomainlist?.split('-*-').first;
  }

  static Future<LiveBroadcastZoomModel?> createZoomMeeting(String? zAk, String zAs, {String? topic}) async {
    const url = 'https://api.zoom.us/v2/users/me/meetings';

    var response = await FirebaseFunctionService.callFirebaseHttp(
      method: HttpMethod.POST,
      url: url,
      headers: {
        'Authorization': "Bearer " + _getZoomToken(zAk, zAs),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "topic": topic ?? "Meet Lesson (Lesson No: ${3.makeKeyFromNumber})",
        "type": '3',
        'settings': {
          'host_video': true,
          'participant_video': false,
          'join_before_host': false,
          'mute_upon_entry': true,
          'waiting_room': true,
        }
      }),
    );

    if (response['body'] is! String || !(response['body'] as String).contains('start_url')) return null;
    var result = jsonDecode(response['body']);

    ///2  saatlik starturl siniri icin kaydettim
    await Fav.preferences.setInt(result['id'].toString(), DateTime.now().millisecondsSinceEpoch);
    await Fav.preferences.setString(result['id'].toString() + 'link', result['start_url']);

    return LiveBroadcastZoomModel(startUrl: result['start_url'], joinUrl: result['join_url'], createTime: AppVar.appBloc.realTime, meetingId: result['id'], apiKeySecret: AppVar.appBloc.hesapBilgileri.zoomApiKey! + '-mcg-' + AppVar.appBloc.hesapBilgileri.zoomApiSecret!, password: result['password']);
  }

  static String _getZoomToken(String? zak, String zas) {
    final jwt = JWT(
      {
        'exp': DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime + const Duration(days: 60).inMilliseconds).millisecondsSinceEpoch,
      },
      issuer: zak,
    );
    final token = jwt.sign(SecretKey(zas), algorithm: JWTAlgorithm.HS256);
    return token;
  }

  static Future<String?> getZoomMeetingStartUrl(String? zak, String? zas, {int? meetingId}) async {
    if (DateTime.now().millisecondsSinceEpoch - Fav.preferences.getInt(meetingId.toString(), 0)! < const Duration(minutes: 90).inMilliseconds && Fav.preferences.getString(meetingId.toString() + 'link') != null) {
      return Fav.preferences.getString(meetingId.toString() + 'link');
    }

    String url = 'https://api.zoom.us/v2/meetings/$meetingId';

    var response = await FirebaseFunctionService.callFirebaseHttp(
      method: HttpMethod.GET,
      url: url,
      headers: {
        'Authorization': "Bearer " + _getZoomToken(zak, zas!),
        'Content-Type': 'application/json',
      },
    );

    if (response['body'] is! String || !(response['body'] as String).contains('start_url')) {
      if ((response['body'] as String).contains('exist')) {
        'meetingcorrpted'.translate.showAlert();
      }
      return null;
    }
    var result = jsonDecode(response['body']);

    var startUrl = result['start_url'];
    await Fav.preferences.setInt(meetingId.toString(), DateTime.now().millisecondsSinceEpoch);
    await Fav.preferences.setString(meetingId.toString() + 'link', startUrl);

    return startUrl;
  }

  static List<String?>? getZakAndZas(String? uid) {
    if (uid == null) {
      'zoomintegrationerr'.translate.showAlert();
      return null;
    }
    if (AppVar.appBloc.hesapBilgileri.uid == uid) return [AppVar.appBloc.hesapBilgileri.zoomApiKey, AppVar.appBloc.hesapBilgileri.zoomApiSecret];
    if (AppVar.appBloc.hesapBilgileri.gtM) {
      final teacher = AppVar.appBloc.teacherService!.dataListItem(uid);

      if (teacher != null) {
        if (teacher.otherData!.containsKey('zak') == false || teacher.otherData!.containsKey('zas') == false) {
        } else {
          return [(teacher.otherData!['zak'] as String?).unMix, (teacher.otherData!['zas'] as String?).unMix];
        }
      }
    }
    'zoomintegrationerr'.translate.showAlert();
    return null;
  }

  static const zoomFreeLessonMinute = 6 * 60;
}
