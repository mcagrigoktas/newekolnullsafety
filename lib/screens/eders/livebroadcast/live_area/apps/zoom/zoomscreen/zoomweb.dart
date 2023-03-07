import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../../../appbloc/appvar.dart';
import '../../../../makeprogram/livebroadcastdatamodel.dart';
import '../../../layouts/controller.dart';
import '../zoomhelper.dart';
import 'js/meeting.dart';
import 'js/signature.dart';

class ZoomLive extends StatefulWidget {
  ZoomLive();

  @override
  _ZoomLiveState createState() => _ZoomLiveState();
}

class _ZoomLiveState extends State<ZoomLive> {
  int state = 0;
  String errorText = '';
  final controller = Get.find<OnlineLessonController>();
  String key = 5.makeKey;

  late LiveBroadcastZoomModel zoomData;
  Map<String, dynamic>? meetingInitData;
  html.IFrameElement? element;
  StreamSubscription? messageSubscription;
  void initState0() {
    key += '0';

    zoomData = LiveBroadcastZoomModel.fromJson(controller.liveBroadcastItem!.broadcastData!);
    meetingInitData = ZoomHelper.getOptions(
      apiKey: zoomData.apiKeySecret!.split('-mcg-').first,
      apiSecret: zoomData.apiKeySecret!.split('-mcg-').last,
      password: zoomData.password,
      meetingNumber: zoomData.meetingId,
      isHost: controller.liveBroadcastItem!.teacherKey == AppVar.appBloc.hesapBilgileri.uid,
    );

    element = html.IFrameElement()
      ..srcdoc = ZoomSignature.getHtml(json.encode(meetingInitData))
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none';
// ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('webview' + key, (int viewId) => element!);
  }

  void initState1() {
    key += '1';
    element = html.IFrameElement()
      ..srcdoc = ZoomMeeting.getHtml(json.encode(meetingInitData))
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none';
// ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('webview' + key, (int viewId) => element!);

    setState(() {
      state = 1;
    });
  }

  void initListener() {
    controller.postMessageToIframe = (String msg) {
      element?.contentWindow?.postMessage(msg, '*');
    };

    PlatformFunctions.localStorageSet('platform', 'web');
    messageSubscription = html.window.onMessage.listen((event) {
      var message = json.decode(event.data);
      var id = message['id'];
      var data = message['data'];

      if (id == 4) {
        //    controller.logDataReceived(json.decode(data));
      } else if (id == 5) {
        //     controller.participantListChanged(json.decode(data));
      } else if (id == 6) {
        //      controller.videoStatusChange(data);
      } else if (id == 7) {
        //     controller.audioStatusChange(data);
      } else if (id == 8) {
        //     controller.tileViewStatusChange(data);
      } else if (id == 300) {
        //      PlatformFunctions.jsContextCallMethod(controller.jsFunctionName, [300 + state, json.encode(meetingInitData)]);
      } else if (id == 120) {
        meetingInitData!['signature'] = data;
        // p.info(data);
        // meetingInitData['signature'] = ZoomHelper.generateSignature(
        //   apiKey: zoomData.apiKeySecret.split('-mcg-').first,
        //   apiSecret: zoomData.apiKeySecret.split('-mcg-').last,
        //   meetingNumber: zoomData.meetingId,
        //   isHost: controller.liveBroadcastItem.teacherKey == AppVar.appBloc.hesapBilgileri.uid,
        // );
        // p.info(meetingInitData['signature']);
        initState1();
      } else if (id == 121) {
        setState(() {
          state = 2;
        });
      } else if (id == 123) {
        setState(() {
          errorText = data.toString();
          state = 3;
        });
      }
    });
  }

  @override
  void initState() {
    initState0();
    initListener();

    super.initState();
  }

  @override
  void dispose() {
    messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (state == 2) {
      return ZoomHelper.getMeetingEndWidget();
    }
    if (state == 3) {
      return ZoomHelper.getStartOnZoomApp(errorText);
    }
    return HtmlElementView(viewType: 'webview' + key);
  }
}
