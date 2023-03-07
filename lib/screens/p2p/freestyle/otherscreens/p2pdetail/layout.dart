import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../models/allmodel.dart';
import '../../../../eders/livebroadcast/live_area/eager_live_area_starter.dart';
import '../../../../eders/livebroadcast/livebroadcasthelper.dart';
import 'controller.dart';

class P2PDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<P2PDetailController>(builder: (controller) {
      return AppScaffold(
          topBar: TopBar(leadingTitle: 'timetables'.translate),
          topActions: TopActionsTitle(title: 'p2pmenuname'.translate),
          body: Body.child(
              maxWidth: 720,
              child: Center(
                child: Card(
                  shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.transparent)),
                  color: Fav.design.others['scaffold.background'],
                  elevation: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      controller.timeText1,
                      8.heightBox,
                      controller.timeText2,
                      16.heightBox,
                      controller.note,
                      16.heightBox,
                      controller.peopleText,
                      16.heightBox,
                      MyRaisedButton(
                        text: 'joinonline'.translate,
                        onPressed: () async {
                          if ((await PermissionManager.microphoneAndCamera()) == false) return;
                          LiveAreaStarter.startGetTo(
                            item: LiveBroadcastModel()
                              ..targetList = controller.model!.studentList
                              ..broadcastLink = LiveBroadCastHelper.getJitsiDomain()
                              ..channelName = controller.model!.channel

                              ///ogrencinin kamera ve sesi giriste acik olabilmesi  icin lesson name  e bakiyor
                              ..lessonName = 'videolesson'.translate
                              ..livebroadcasturltype = 5,
                          ).unawaited;
                        },
                      ),
                    ],
                  ).p16,
                ),
              )));
    });
  }
}
