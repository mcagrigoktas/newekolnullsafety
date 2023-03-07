import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  late String jsData;
  String key = 5.makeKey;

  late LiveBroadcastZoomModel zoomData;
  Map<String, dynamic>? meetingInitData;

  void initState0() {
    key = 5.makeKey;
    zoomData = LiveBroadcastZoomModel.fromJson(controller.liveBroadcastItem!.broadcastData!);
    meetingInitData = ZoomHelper.getOptions(
      apiKey: zoomData.apiKeySecret!.split('-mcg-').first,
      apiSecret: zoomData.apiKeySecret!.split('-mcg-').last,
      password: zoomData.password,
      meetingNumber: zoomData.meetingId,
      isHost: controller.liveBroadcastItem!.teacherKey == AppVar.appBloc.hesapBilgileri.uid,
    );

    jsData = ZoomSignature.getHtml(json.encode(meetingInitData));
  }

  void initState1() {
    setState(() {
      state = 5;
    });
    100.wait.then((value) {
      setState(() {
        key = 5.makeKey;
        jsData = ZoomMeeting.getHtml(json.encode(meetingInitData));
        state = 1;
      });
    });
  }

  @override
  void initState() {
    initState0();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initListener() {
    controller.mobileWebview!.addJavaScriptHandler(
        handlerName: 'message',
        callback: (msg) async {
          final Map message = json.decode(msg[0]);

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
  Widget build(BuildContext context) {
    if (state == 5) {
      return Container();
    }
    if (state == 2) {
      return ZoomHelper.getMeetingEndWidget();
    }
    if (state == 3) {
      return ZoomHelper.getStartOnZoomApp(errorText);
    }
    return SafeArea(
        key: Key(key),
        child: InAppWebView(
          initialData: InAppWebViewInitialData(
            data: jsData,
            baseUrl: Uri.parse('https://ecollmeet.web.app/$key/'),
            encoding: 'utf-8',
            mimeType: 'text/html',
          ),

          initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(
              useHybridComposition: true,
              allowFileAccess: true,
              cacheMode: AndroidCacheMode.LOAD_NO_CACHE,
            ),
            ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: false,
              allowsAirPlayForMediaPlayback: false,
            ),
            crossPlatform: InAppWebViewOptions(
              preferredContentMode: UserPreferredContentMode.MOBILE,
              mediaPlaybackRequiresUserGesture: false,
              cacheEnabled: kReleaseMode,
              supportZoom: false,
            ),
          ), //aa
          onConsoleMessage: (controller, message) {},
          onWebViewCreated: (InAppWebViewController webviewContoller) async {
            controller.mobileWebview = webviewContoller;
            initListener();
          },
          onProgressChanged: (InAppWebViewController controller, int progress) async {},
          androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
            return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
          },
        ));
  }
}
