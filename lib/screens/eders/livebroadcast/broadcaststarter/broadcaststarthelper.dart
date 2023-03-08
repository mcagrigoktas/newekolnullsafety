import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/mybutton.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../livebroadcasthelper.dart';
import 'controller.dart';
import 'layout.dart';

class BroadcastHelper {
  BroadcastHelper._();

  static void startBroadcastLessonInNotification(String notificationTag) {
    final data = notificationTag.replaceAll('bl-', '').trim();
    final Map mapData = jsonDecode(data);

    final lessonKey = mapData['LK'];
    final LiveBroadcastModel item = LiveBroadcastModel()
      ..channelName = mapData['CN']
      ..broadcastLink = mapData['BL']
      ..livebroadcasturltype = mapData['LT']
      ..broadcastData = mapData['BD']
      ..startTime = mapData['ST']
      ..endTime = mapData['ET']
      ..targetList = List<String>.from(mapData['TL'] ?? [])
      ..lessonName = mapData['T']
      ..explanation = mapData['C'];

    if (lessonKey == null) {
      Fav.guardTo(BroadcastStarter(), binding: BindingsBuilder(() => Get.put<BroadcastStarterController>(BroadcastStarterController(item))));
    } else {
      Fav.guardTo(BroadcastStarter(), binding: BindingsBuilder(() => Get.put<BroadcastStarterController>(BroadcastStarterController(item, lesson: AppVar.appBloc.lessonService!.dataListItem(lessonKey)))));
    }
  }

  static Widget broadcastStartWidget(BuildContext context, LiveBroadcastModel item) {
    var broadcastActive = true;
    if (item.livebroadcasturltype == 4 || item.livebroadcasturltype == 5) {
      if (item.broadcastLink.safeLength < 6 || AppVar.appBloc.schoolInfoService!.singleData!.livedomainlist.safeLength < 5) broadcastActive = false;
    }
    if (item.livebroadcasturltype == 2 || item.livebroadcasturltype == 3 || item.livebroadcasturltype == 10) {
      if (item.broadcastLink.safeLength < 6) broadcastActive = false;
    }
    if (item.livebroadcasturltype == 9) {
      if (item.broadcastData == null) broadcastActive = false;
    }

    return MyMiniRaisedButton(
      text: (broadcastActive ? "startvideolesson" : 'livebroadcastnotstarted').translate,
      color: broadcastActive ? Fav.design.card.button : Colors.grey,
      onPressed: () {
        Fav.guardTo(BroadcastStarter(), binding: BindingsBuilder(() => Get.put<BroadcastStarterController>(BroadcastStarterController(item))));
      },
    );
  }

  static Widget broadcastLessonStartWidget(Lesson existingLesson) {
    final Lesson lesson = AppVar.appBloc.lessonService!.dataListItem(existingLesson.key)!;
    if (lesson.remoteLessonActive != true) return const SizedBox();
    if (lesson.livebroadcasturltype == 4 || lesson.livebroadcasturltype == 5) {
      if (lesson.broadcastLink.safeLength < 6 || AppVar.appBloc.schoolInfoService!.singleData!.livedomainlist.safeLength < 5) return const SizedBox();
    }
    if (lesson.livebroadcasturltype == 2 || lesson.livebroadcasturltype == 3 || lesson.livebroadcasturltype == 10) {
      if (lesson.broadcastLink.safeLength < 6) return const SizedBox();
    }
    if (lesson.livebroadcasturltype == 9) {
      if (lesson.broadcastData == null) return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
        String? broadcastLink;
        String channelName;
        Map? broadcastData;

        if (lesson.livebroadcasturltype == 4 || lesson.livebroadcasturltype == 5) {
          broadcastLink = lesson.broadcastLink!.split('-*-').first;
          if (!AppVar.appBloc.schoolInfoService!.singleData!.livedomainlist!.toLowerCase().contains(broadcastLink.toLowerCase())) {
            broadcastLink = LiveBroadCastHelper.getJitsiDomain();
          }
          channelName = lesson.broadcastLink!.split('-*-').last;
        } else if (lesson.livebroadcasturltype == 9) {
          broadcastData = lesson.broadcastData;
          channelName = lesson.key + 'livelessonkey';
        } else {
          broadcastLink = lesson.broadcastLink;
          channelName = lesson.key + 'livelessonkey';
        }

        if (broadcastLink.safeLength < 6 && broadcastData == null) return OverAlert.show(type: AlertType.danger, message: 'errliveurl'.translate);
        final item = LiveBroadcastModel()
          ..targetList = [lesson.classKey!]
          ..broadcastLink = broadcastLink
          ..broadcastData = broadcastData
          ..channelName = channelName
          ..livebroadcasturltype = lesson.livebroadcasturltype;

        Fav.guardTo(BroadcastStarter(), binding: BindingsBuilder(() => Get.put<BroadcastStarterController>(BroadcastStarterController(item, lesson: lesson))));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        constraints: BoxConstraints(maxWidth: 120, maxHeight: 40),
        decoration: BoxDecoration(color: lesson.color.parseColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.live_tv, color: Colors.white, size: 16),
            8.widthBox,
            Flexible(child: 'goremotelesson'.translate.text.color(Colors.white).height(0.85).autoSize.make()),
          ],
        ),
      ),
    );
  }
}
