import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../layouts/controller.dart';
import '../../../layouts/widgets/advancedClass/layout.dart';
import '../agorahelper.dart';

class AgoraLive extends StatefulWidget {
  AgoraLive();

  @override
  _AgoraLiveState createState() => _AgoraLiveState();
}

class _AgoraLiveState extends State<AgoraLive> {
  final controller = Get.find<OnlineLessonController>();
  String localeElementKey = 'webview' + 5.makeKey;

  bool pageLoading = false;

  @override
  void initState() {
    init();

    super.initState();
  }

  Future init() async {
    await injectCssAndJSLibraries();
    await 3000.wait;
    final options = json.encode(AgoraHelper.getOptions(controller.liveBroadcastItem!.broadcastLink, controller.liveBroadcastItem!.channelName.removeNonEnglishCharacter));

    js.context.callMethod('AExtraFunctionCall', [100, options, controller.classRoomController.getWebElement, controller.classRoomController.removeWebElement, controller.classRoomController.ownElement, null]);
    setState(() {
      pageLoading = false;
    });

    js.context.callMethod('ADataFunctionInitialize', [
      (id, data) {
        if (id == 4) {
          controller.logDataReceived(json.decode(data));
        } else if (id == 5) {
          controller.participantListChanged(json.decode(data));
        } else if (id == 6) {
          controller.videoStatusChange(data);
        } else if (id == 7) {
          controller.audioStatusChange(data);
        } else if (id == 8) {
          controller.tileViewStatusChange(data);
        }
      }
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (pageLoading) return MyProgressIndicator();
    return AdvancedClassMain();

    // return Column(
    //   children: [
    //     Container(width: 300, height: 300, child: HtmlElementView(viewType: localeElementKey)),
    //   ],
    // );
  }

  Future<void> injectCssAndJSLibraries() async {
    if (Fav.readSeasonCache('ag_js_inject') == true) return;
    final List<Future<void>> loading = <Future<void>>[];
    final List<html.HtmlElement> tags = <html.HtmlElement>[];

    // final html.ScriptElement script = html.ScriptElement()
    //   //   ..async = true
    //   ..src = "./live_ag/AgoraRTC_N-4.2.1.js";
    //
    // loading.add(script.onLoad.first);
    // tags.add(script);

    final html.ScriptElement script2 = html.ScriptElement()
      //  ..async = true
      ..src = "./live_ag/ind.js";
    loading.add(script2.onLoad.first);
    tags.add(script2);

    html.querySelector('body')!.children.addAll(tags);

    await Future.wait(loading);

    Fav.writeSeasonCache('ag_js_inject', true);
  }
}
