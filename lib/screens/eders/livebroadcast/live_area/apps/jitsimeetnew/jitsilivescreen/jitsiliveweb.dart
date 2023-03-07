import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../layouts/controller.dart';
import '../jitsihelper.dart';
import 'html.dart';

class JitsiLive extends StatefulWidget {
  JitsiLive();

  @override
  _JitsiLiveState createState() => _JitsiLiveState();
}

class _JitsiLiveState extends State<JitsiLive> {
  final controller = Get.find<OnlineLessonController>();
  late String key;
  StreamSubscription? messageSubscription;
  late JitsiConfigData meetingInitData;
  @override
  void initState() {
    key = 5.makeKey;

    meetingInitData = JitsiNewHelper.getOptions(controller.liveBroadcastItem!.broadcastLink, controller.liveBroadcastItem!.channelName.removeNonEnglishCharacter);

    var element = html.IFrameElement()
      ..srcdoc = JitsiMeeting.getHtml(meetingInitData)
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('webview' + key, (int viewId) => element);

    controller.postMessageToIframe = (String msg) {
      element.contentWindow?.postMessage(msg, '*');
    };

    messageSubscription = html.window.onMessage.listen((event) {
      var message = json.decode(event.data);

      if (message?.containsKey('id') == true) {
        var id = message['id'];
        var data = message['data'];
        if (id == 4) {
          controller.logDataReceived(data);
        } else if (id == 5) {
          controller.participantListChanged(data);
        } else if (id == 6) {
          controller.videoStatusChange(data);
        } else if (id == 7) {
          controller.audioStatusChange(data);
        } else if (id == 8) {
          controller.tileViewStatusChange(data);
        } else if (id == 28) {
          controller.deviceListReceived(data);
        } else if (id == 300) {
          controller.sendDataLiveMenu({
            'id': 300,
            'domain': meetingInitData.domain,
            'roomName': meetingInitData.roomName,
            'jwt': meetingInitData.jwtToken,
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    if (!PlatformFunctions.browserIsChrome() && !PlatformFunctions.browserIsFirefox()) return EmptyState(text: 'onlychrome'.translate);
    return HtmlElementView(viewType: 'webview' + key).p4;
  }

  @override
  void dispose() {
    messageSubscription?.cancel();
    super.dispose();
  }
}
