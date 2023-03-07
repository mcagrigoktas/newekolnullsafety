import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import 'controller.dart';

class BroadcastStarter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastStarterController>(
      builder: (controller) {
        return AppScaffold(
          topBar: TopBar(
            leadingTitle: 'back'.translate,
            backButtonPressed: controller.back,
          ),
          body: Body.child(
              child: controller.errorText != null
                  ? ErrorWidget()
                  : AppVar.appBloc.hesapBilgileri.gtS
                      ? StudentWidget()
                      : TeacherWidget()),
        );
      },
    );
  }
}

class ErrorWidget extends StatelessWidget {
  ErrorWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BroadcastStarterController>();
    return Center(
      child: controller.errorText.text.make(),
    );
  }
}

class StudentWidget extends StatelessWidget {
  StudentWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BroadcastStarterController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        controller.title,
        16.heightBox,
        controller.content,
        64.heightBox,
        MyProgressButton(
          onPressed: controller.startBroadcast,
          label: 'joinlesson'.translate,
          isLoading: !controller.lessonStartable,
        ),
        //  if (controller.lessonStarted) GestureDetector(onTap: controller.startBroadcast, child: 'lessonstarted'.translate.text.make()).stadium(background: Fav.design.primaryText.withAlpha(15)) else MyProgressIndicator(text: 'lessonstartwaiting'.translate),
        if ((controller.item.broadcastLink.safeLength) > 6 && controller.item.broadcastLink!.contains('zoom') && !kIsWeb) ZoomHintWidget().pt32,

        32.heightBox,
        'timecontrolhint'.argTranslate(controller.time).text.center.color(Fav.design.primaryText.withAlpha(180)).bold.make().px16,
      ],
    );
  }
}

class TeacherWidget extends StatelessWidget {
  TeacherWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BroadcastStarterController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        controller.title,
        16.heightBox,
        controller.content,
        32.heightBox,
        Container(
          height: 72,
          alignment: Alignment.center,
          child: controller.isVisibleSendNotificationButton && controller.notificationSended == false
              ? TextButton(
                  style: TextButton.styleFrom(backgroundColor: Fav.design.primary.withOpacity(0.03)),
                  child: 'broadcastlessonstartwarning'.translate.text.color(Fav.design.primary).make(),
                  onPressed: controller.sendNotification,
                )
              : const SizedBox(),
        ),
        MyProgressButton(
          onPressed: controller.startBroadcastTeacher,
          label: 'startlesson'.translate,
          isLoading: controller.isLoading,
        ),
        if ((controller.item.broadcastLink.safeLength) > 6 && controller.item.broadcastLink!.contains('zoom') && !kIsWeb) ZoomHintWidget().pt32,
        'lessontimehint'.translate.text.color(Fav.design.primaryText.withAlpha(100)).center.make().p32,
      ],
    );
  }
}

class ZoomHintWidget extends StatelessWidget {
  ZoomHintWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Platform.isIOS) 'https://apps.apple.com/app/id546505307'.launch(LaunchType.url);
        if (Platform.isAndroid) 'https://play.google.com/store/apps/details?id=us.zoom.videomeetings'.launch(LaunchType.url);
      },
      child: Text(
        'zoomhint'.translate,
        textAlign: TextAlign.center,
        style: TextStyle(color: Fav.design.primaryText.withAlpha(150), fontSize: 8),
      ),
    );
  }
}
