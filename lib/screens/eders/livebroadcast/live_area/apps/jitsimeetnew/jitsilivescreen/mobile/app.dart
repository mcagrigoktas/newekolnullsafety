import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:myvideocall/call.dart';

import '../../../../../../../../appbloc/appvar.dart';
import '../../../../layouts/controller.dart';
import '../../jitsihelper.dart';

class JitsiMobileApp extends StatefulWidget {
  @override
  _JitsiMobileAppState createState() {
    return _JitsiMobileAppState();
  }
}

class _JitsiMobileAppState extends State<JitsiMobileApp> {
  final controller = Get.find<OnlineLessonController>();

  var isAudioOnly = false;
  var isAudioMuted = !AppVar.appBloc.hesapBilgileri.gtT;
  var isVideoMuted = !AppVar.appBloc.hesapBilgileri.gtT;
  String? error;

  void calcStatistics() {
//    if (DateTime.now().millisecondsSinceEpoch - startTime.millisecondsSinceEpoch > Duration(minutes: 2).inMilliseconds) {
//      widget.statisticsSendDatabase(DateTime.now().difference(startTime ?? DateTime.now()).inSeconds);
//    }
  }

  String channelName = '';
  DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    ///ogrencinin kamera ve sesi giriste acik olabilmesi  icin lesson name  e bakiyor

    if (AppVar.appBloc.hesapBilgileri.gtS && controller.liveBroadcastItem!.lessonName == 'videolesson'.translate) {
      isVideoMuted = false;
      isAudioMuted = false;
    }

    final token = JitsiNewHelper.getToken(controller.liveBroadcastItem!.broadcastLink, controller.liveBroadcastItem!.channelName);

    String? serverUrl = controller.liveBroadcastItem!.broadcastLink!.contains('http') ? controller.liveBroadcastItem!.broadcastLink : 'https://${controller.liveBroadcastItem!.broadcastLink}';

    if (controller.liveBroadcastItem!.broadcastLink.safeLength > 5 && controller.liveBroadcastItem!.channelName.safeLength > 5) {
      JitsiFunctions.joinMeet(
        subject: controller.liveBroadcastItem!.lessonName!,
        channelName: (controller.liveBroadcastItem!.channelName
            //  + DateFormat("dMM").format(DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime))
            )
            .removeNonEnglishCharacter!,
        serverURL: serverUrl!,
        token: token!,
        userEmail: '',
        userDisplayName: AppVar.appBloc.hesapBilgileri.name.toFirebaseSafeKey! + '*' + AppVar.appBloc.hesapBilgileri.uid! + '*' + (Platform.isIOS ? 'I' : 'A'),
        isVideoMuted: isVideoMuted,
        isAudioMuted: isAudioMuted,
        onAudioMutedChanged: _onAudioMutedChanged,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onConferenceWillJoin: _onConferenceWillJoin,
        onError: _onError,
        onVideoMutedChanged: _onVideoMutedChanged,
        pipEnabled: false, //Get.find<RemoteControlValues>().liveBroadcastPIPEnable,
        //  iosAppBarColor:   Fav.design.appBar.background.toString().replaceAll('Color(0x', '').replaceAll(')', ''),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Container(color: Colors.amberAccent);

    if (controller.liveBroadcastItem!.broadcastLink.safeLength < 6) {
      current = EmptyState(text: 'Server Url Not Correct');
    } else if (error != null) {
      current = EmptyState(text: error);
    } else {
      current = Container();
    }
    return MyScaffold(
      appBar: MyAppBar(
        visibleBackButton: true,
        title: AppVar.appBloc.appConfig.otherData!['liveappmenuname'] ?? 'Ecoll Meet',
      ),
      body: current,
    );
  }

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    startTime = DateTime.now();
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    JitsiFunctions.dispose();
    calcStatistics();
    Get.back();
  }

  void _onError(error) {
    setState(() {
      this.error = error.toString();
    });
  }

  // ignore: unused_element
  void _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  void _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  void _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }
}
