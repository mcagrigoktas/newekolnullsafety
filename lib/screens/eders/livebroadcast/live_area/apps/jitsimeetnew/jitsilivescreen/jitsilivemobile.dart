import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../layouts/controller.dart';
import 'mobile/app.dart';
import 'mobile/webview.dart';

class JitsiLive extends StatelessWidget {
  JitsiLive();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();

    if (Platform.isIOS) {
      return FutureBuilder<bool>(
          future: DeviceManager.iosVersionGreater143(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false || snapshot.data == null) return MyProgressIndicator().inScaffold;
            if (snapshot.data == true) return JitsiMobileWebview();

            return AppScaffold(
                topBar: TopBar(leadingTitle: 'back'.translate),
                body: Body.child(
                  child: EmptyState(
                    text: 'ios143required'.translate,
                  ),
                ));
          });
    }

    if (controller.mobileJitsiWebview) return JitsiMobileWebview();

    return JitsiMobileApp();
  }
}
