import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/lesson.dart';
import '../../../../models/models.dart';
import '../../../../models/notification.dart';
import '../../../../services/dataservice.dart';
import '../../../../services/remote_control.dart';
import '../live_area/eager_live_area_starter.dart';
import '../live_area/layouts/livelessonmenutoolbarekol.dart';
import '../livebroadcasthelper.dart';
import '../makeprogram/livebroadcastdatamodel.dart';
import 'model.dart';

class BroadcastStarterController extends GetxController {
  StreamSubscription? subscription;
  final LiveBroadcastModel item;
  final Lesson? lesson;

  bool isLoading = false;
  bool lessonStartable = false;
  bool notificationSended = false;

  String time = AppVar.appBloc.realTime.dateFormat('d-MMM, HH:mm');
  Timer? _timer;
  String? errorText;

  ///Eger dersprogrami icinden geliyorsa lesson gelmeli
  BroadcastStarterController(this.item, {this.lesson});

  String get randomLogKey => 'LiveLessonStarter${item.key}';

  @override
  void onInit() {
    super.onInit();

    /// ders programi icinden gelmiyorsa zaman kontrolu lazim
    if (lesson == null) {
      if (AppVar.appBloc.realTime < item.startTime! - const Duration(minutes: 70).inMilliseconds || AppVar.appBloc.realTime > item.endTime! + const Duration(minutes: 90).inMilliseconds) {
        errorText = 'broadcastliveerr'.translate;
        return;
      }

      bool girisYapabilir = false;
      if (AppVar.appBloc.hesapBilgileri.gtT && item.teacherKey == AppVar.appBloc.hesapBilgileri.uid) {
        girisYapabilir = true;
      } else if (AppVar.appBloc.hesapBilgileri.gtS) {
        if (item.targetList!.contains("alluser")) girisYapabilir = true;
        if (item.targetList!.any((item) => [...AppVar.appBloc.hesapBilgileri.classKeyList, AppVar.appBloc.hesapBilgileri.uid].contains(item))) girisYapabilir = true;
      } else if (AppVar.appBloc.hesapBilgileri.gtM) {
        girisYapabilir = true;
      }
      if (girisYapabilir == false) {
        errorText = 'notjoin'.translate;
        return;
      }
    }

    if (AppVar.appBloc.hesapBilgileri.gtS) {
      if (Get.find<RemoteControlValues>().broadcaststartpage == true) {
        subscription = RandomDataService.dbGetRandomLog(randomLogKey).onValue().listen((event) async {
          final data = event?.value;

          if (data != null) {
            var model = BroadcastStarterModel.fromJson(data);
            if (model.active) {
              await _closeSubscription();

              lessonStartable = true;
              update();
            }
          }
        });
      } else {
        400.wait.then((value) {
          lessonStartable = true;
          update();
        });
      }
    }

    _timer = Timer.periodic(1.minutes, (timer) {
      time = AppVar.appBloc.realTime.dateFormat('d-MMM, HH:mm');
      update();
    });
  }

  Future<void> back() async {
    _timer?.cancel();
    await _closeSubscription();
    Get.back();
  }

  bool get isVisibleSendNotificationButton => AppVar.appBloc.hesapBilgileri.gtT || (AppVar.appBloc.hesapBilgileri.gtM && lesson == null);

  void sendNotification() {
    isLoading = true;
    notificationSended = true;
    update();
    final tag = 'bl-' +
        jsonEncode({
          if (lesson != null) 'LK': lesson!.key,
          'CN': item.channelName,
          'BL': item.broadcastLink,
          'LT': item.livebroadcasturltype,
          'BD': item.broadcastData,
          'ST': item.startTime,
          'ET': item.endTime,
          'TL': item.targetList,
          'T': item.lessonName,
          'C': item.explanation,
        });

    InAppNotificationService.sendSameInAppNotificationMultipleTarget(
      InAppNotification(
        title: lesson?.name ?? item.lessonName,
        content: 'broadcastlessonnotifycontent'.translate,
        key: 'Not${item.channelName}',
        pageName: PageName.eLS,
        type: NotificationType.liveBroadCastStarterPage,
        argument: {'d': tag},
      ),
      item.targetList,
      notificationTag: tag,
      targetListContainsAllUserOrClassList: true,
      allUserKeyMeanAllStudent: true,
    )!.then((value) {
      isLoading = false;
      update();
      'sendnotificationsuc'.translate.showAlert();
    });
    // EkolPushNotificationService.sendMultipleNotification(lesson?.name ?? item.lessonName, 'broadcastlessonnotifycontent'.translate, item.targetList, tag: tag).then((value) {
    //   isLoading = false;
    //   update();
    //   'sendnotificationsuc'.translate.showAlert();
    // });
  }

  Future<void> startBroadcastTeacher() async {
    var model = BroadcastStarterModel();
    model.lastUpdate = databaseTime;
    model.state = 1;
    isLoading = true;
    update();
    await RandomDataService.setRandomLog(randomLogKey, model.mapForSave()).then((value) {
      startBroadcast();
      isLoading = false;
      update();
    });
  }

  void startEmptyLiveLessonMenuLayout() {
    LiveAreaStarter.startGetOff(
      item: item,
      lesson: lesson,
      liveLessonType: LiveLessonType.Empty,
    );
  }

  Future<void>? startBroadcast() async {
    if ((await PermissionManager.microphoneAndCamera()) == false) return;
    if (Fav.noConnection()) return;

    /// sanirim 1 agora 5 eski jitsimeet di
    if (item.livebroadcasturltype == 1 || item.livebroadcasturltype == 4) item.livebroadcasturltype = 5;

    ///Yeni jitsi meet
    if (item.livebroadcasturltype == 5) {
      return LiveAreaStarter.startGetOff(
        item: item,
        lesson: lesson,
        liveLessonType: LiveLessonType.Jitsi,
      );
    }
    if (item.livebroadcasturltype == 12) {
      return LiveAreaStarter.startGetOff(
        item: item,
        lesson: lesson,
        liveLessonType: LiveLessonType.Agora,
      );
    }

    if (item.livebroadcasturltype == 9) {
      final LiveBroadcastZoomModel zoomData = LiveBroadcastZoomModel.fromJson(item.broadcastData!);

      final zoomAppResult = await {true: 'meetingstaronzoomapp'.translate, false: 'meetingstaroekolapp'.translate}.selectOne(title: 'meetingstarhint'.translate);
      if (zoomAppResult == null) return;

      if (zoomAppResult == false) {
        return LiveAreaStarter.startGetOff(
          item: item,
          lesson: lesson,
          liveLessonType: LiveLessonType.Zoom,
        );
      }

      if (AppVar.appBloc.hesapBilgileri.gtS) {
        zoomData.joinUrl.launch(LaunchType.url, mode: LaunchMode.externalApplication).unawaited;
        startEmptyLiveLessonMenuLayout();
        return;
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        final startUrl = await LiveBroadCastHelper.getZoomMeetingStartUrl(AppVar.appBloc.hesapBilgileri.zoomApiKey, AppVar.appBloc.hesapBilgileri.zoomApiSecret, meetingId: zoomData.meetingId);
        startUrl.launch(LaunchType.url, mode: LaunchMode.externalApplication).unawaited;
        startEmptyLiveLessonMenuLayout();
        return;
      } else if (AppVar.appBloc.hesapBilgileri.gtM) {
        if (lesson != null) {
          zoomData.joinUrl.launch(LaunchType.url, mode: LaunchMode.externalApplication).unawaited;
          startEmptyLiveLessonMenuLayout();
          return;
        } else if (item.teacherKey == AppVar.appBloc.hesapBilgileri.uid) {
          final startUrl = await LiveBroadCastHelper.getZoomMeetingStartUrl(AppVar.appBloc.hesapBilgileri.zoomApiKey, AppVar.appBloc.hesapBilgileri.zoomApiSecret, meetingId: zoomData.meetingId);
          startUrl.launch(LaunchType.url, mode: LaunchMode.externalApplication).unawaited;
          startEmptyLiveLessonMenuLayout();
          return;
        } else {
          zoomData.joinUrl.launch(LaunchType.url, mode: LaunchMode.externalApplication).unawaited;
          startEmptyLiveLessonMenuLayout();
          return;
        }
      }

      //    return (AppVar.appBloc.hesapBilgileri.gtMT ? (await LiveBroadCastHelper.getZoomMeetingStartUrl(meetingId: zoomData.meetingId)) : zoomData.joinUrl).launch(LaunchType.url);
    }

    if (item.broadcastLink.safeLength < 6) return OverAlert.show(message: 'errliveurl'.translate);

    if ((item.broadcastLink.safeLength) > 6) {
      startEmptyLiveLessonMenuLayout();
      item.broadcastLink.launch(LaunchType.url, mode: LaunchMode.externalApplication).unawaited;
      return;
    }
  }

  Future<void> _closeSubscription() async {
    await subscription?.cancel();
    subscription = null;
  }

  Widget get title {
    return (item.lessonName ?? lesson?.name ?? '').text.color(Fav.design.primary).fontSize(40).bold.make();
  }

  Widget get content {
    return (item.explanation ?? lesson?.explanation ?? '').text.fontSize(16).make();
  }

  @override
  void onClose() {
    _closeSubscription();
    _timer!.cancel();
    super.onClose();
  }
}
