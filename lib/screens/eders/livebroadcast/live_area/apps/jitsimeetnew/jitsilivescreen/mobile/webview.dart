import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../layouts/controller.dart';
import '../../jitsihelper.dart';
import '../html.dart';

class JitsiMobileWebview extends StatefulWidget {
  JitsiMobileWebview();

  @override
  _JitsiMobileWebviewState createState() => _JitsiMobileWebviewState();
}

class _JitsiMobileWebviewState extends State<JitsiMobileWebview> {
  final controller = Get.find<OnlineLessonController>();
  String key = 5.makeKey;
  late JitsiConfigData meetingInitData;

  @override
  void initState() {
    meetingInitData = JitsiNewHelper.getOptions(controller.liveBroadcastItem!.broadcastLink, controller.liveBroadcastItem!.channelName.removeNonEnglishCharacter);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void init() {
    controller.mobileWebview!.addJavaScriptHandler(
        handlerName: 'message',
        callback: (msg) async {
          final Map? message = json.decode(msg[0]);

          if (message?.containsKey('id') == true) {
            var id = message!['id'];
            var data = message['data'];
            if (id == 28) {}

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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: KeyedSubtree(
      key: Key('JitsiMobileWebview$key'),
      child: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: JitsiMeeting.getHtml(meetingInitData),
          baseUrl: Uri.parse('https://ecollmeet.web.app/$key/'),
          encoding: 'utf-8',
          mimeType: 'text/html',
        ),
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
            allowFileAccess: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
            allowsPictureInPictureMediaPlayback: false,
            allowsAirPlayForMediaPlayback: false,
          ),
          crossPlatform: isAndroid
              ? InAppWebViewOptions(
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  mediaPlaybackRequiresUserGesture: false,
                  cacheEnabled: kReleaseMode,
                  supportZoom: false,
                )
              : InAppWebViewOptions(
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  mediaPlaybackRequiresUserGesture: false,
                  cacheEnabled: kReleaseMode,
                  supportZoom: false,
                  applicationNameForUserAgent: isIOS ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15' : '',
                  userAgent: isIOS ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15' : '',
                ),
        ), //aa

        onConsoleMessage: (controller, message) {
          //     p.info(message.message);
        },
        onWebViewCreated: (InAppWebViewController webviewContoller) async {
          controller.mobileWebview = webviewContoller;
          init();
        },
        onProgressChanged: (InAppWebViewController controller, int progress) async {},
        androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
          return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
        },
      ),
    ));
  }
}
