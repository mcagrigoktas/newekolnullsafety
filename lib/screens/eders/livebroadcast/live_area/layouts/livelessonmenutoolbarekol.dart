import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../models/allmodel.dart';
import '../../../../rollcall/ekolrollcallteacher.dart';
import '../apps/agora/agorascreen/agorashared.dart';
import '../apps/empty.dart';
import '../apps/jitsimeetnew/jitsilivescreen/jitsiliveshared.dart';
import '../apps/zoom/zoomscreen/zoomshared.dart';
import 'controller.dart';
import 'widgets/bottom/bottommain.dart';
import 'widgets/chats.dart';
import 'widgets/featurebuttonsekol.dart';
import 'widgets/hints.dart';
import 'widgets/logs.dart';
import 'widgets/othersettings.dart';
import 'widgets/rollcallmenustarter.dart';
import 'widgets/settings.dart';
import 'widgets/studentlist.dart';

enum LiveLessonType {
  Jitsi,
  Agora,
  Zoom,
  Empty,
}

class LiveLessonMenuLayout extends StatelessWidget {
  final LiveBroadcastModel? item;
  final LiveLessonType? liveLessonType;

  /// Ders programindan geliyorsa
  final Lesson? lesson;
  LiveLessonMenuLayout({this.item, this.lesson, this.liveLessonType = LiveLessonType.Jitsi});

  @override
  Widget build(BuildContext context) {
    ///todo true yu  kaldir
    return Scaffold(
      backgroundColor: Fav.design.scaffold.background,
      body: GetBuilder<OnlineLessonController>(
          init: OnlineLessonController(liveBroadcastItem: item, lesson: lesson, liveLessonType: liveLessonType),
          builder: (controller) {
            Widget current = LiveLessonMenuLayoutEkol(item: item, lesson: lesson);

            current = Column(
              children: [
                Expanded(
                  child: current,
                ),
                LiveLayoutBotttom(),
              ],
            );

            return WillPopScope(
              onWillPop: () async {
                await controller.onBackPressed();
                return false;
              },
              child: SafeArea(child: current),
            );
          }),
    );
  }
}

class LiveLessonMenuLayoutEkol extends StatelessWidget {
  final LiveBroadcastModel? item;

  /// Ders programindan geliyorsa
  final Lesson? lesson;
  LiveLessonMenuLayoutEkol({this.item, this.lesson});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    final current = KeyedSubtree(
      key: const Key('LiveLessonKey'),
      child: controller.liveLessonType == LiveLessonType.Jitsi
          ? JitsiLive()
          : controller.liveLessonType == LiveLessonType.Zoom
              ? ZoomLive()
              : controller.liveLessonType == LiveLessonType.Agora
                  ? AgoraLive()
                  : EmptyLive(),
    );
    return Row(
      children: [
        if (controller.isLeftPanelEnable)
          AnimatedContainer(
            duration: 333.milliseconds,
            width: controller.extraMenuType == ExtraMenuType.logData || controller.extraMenuType == ExtraMenuType.settings
                ? 500
                : controller.extraMenuType != ExtraMenuType.closed
                    ? 350
                    : 72,
            child: Row(
              children: [
                8.widthBox,
                FeatureButtons(),
                if (controller.extraMenuType != ExtraMenuType.closed) Container(margin: const EdgeInsets.all(4.0), color: const Color(0x22BBC7DE), width: 1, height: double.infinity),
                if (controller.extraMenuType == ExtraMenuType.rollCallMenu) Expanded(child: EkolRollCallTeacher(sinif: AppVar.appBloc.classService!.dataListItem(controller.lesson!.classKey!), lesson: controller.lesson, forOnlineLesson: true, onlineLessonOnlinePeopleData: controller.onlineUserList)),
                if (controller.extraMenuType == ExtraMenuType.rollCallMenuStarter) Expanded(child: RollCallMenuStarter()),
                if (controller.extraMenuType == ExtraMenuType.hints) Expanded(child: Hints()),
                if (controller.extraMenuType == ExtraMenuType.otherMenu) Expanded(child: OtherSettings()),
                if (controller.extraMenuType == ExtraMenuType.onlineStudentList || controller.extraMenuType == ExtraMenuType.offlineStudentList) Expanded(child: StudentList()),
                if (controller.extraMenuType == ExtraMenuType.logData) Expanded(child: Logs()),
                if (controller.extraMenuType == ExtraMenuType.settings) Expanded(child: Settings()),
                if (controller.extraMenuType == ExtraMenuType.chats) Expanded(child: LiveLessonChatScreen()),
                if (controller.extraMenuType != ExtraMenuType.closed) Container(margin: const EdgeInsets.all(4.0), color: const Color(0x22BBC7DE), width: 1, height: double.infinity),
              ],
            ),
          ),
        Expanded(
            child: controller.isLeftPanelEnable
                ? Stack(
                    children: [
                      current,
                      if (controller.liveLessonType == LiveLessonType.Jitsi) _SchoolMeetLogo(),
                    ],
                  )
                : current),
      ],
    );
  }
}

class OnlineUserModel {
  String? name;
  String? uid;
  String? device;
  int? girisTuru;

  @Deprecated('Kullanimiyor')
  String get getDevice => device == null
      ? '-'
      : device == 'A'
          ? 'Android'
          : device == 'I'
              ? 'IOS'
              : device == 'W'
                  ? 'Web'
                  : '-';

  OnlineUserModel({this.name, this.uid, this.device, this.girisTuru});

  OnlineUserModel.fromText(String text) {
    final splittedText = text.split('*');
    name = splittedText[0];
    uid = splittedText.length > 1 ? splittedText[1] : '-';
    device = splittedText.length > 2 ? splittedText[2] : '-';
    girisTuru = splittedText.length > 3 ? (int.tryParse(splittedText[3]) ?? 0) : 0;
  }
}

class _SchoolMeetLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.shortestSide > 600;
    Widget _current = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        4.0.widthBox,
        ClipRRect(borderRadius: BorderRadius.circular(8), child: MyCachedImage(imgUrl: AppVar.appBloc.schoolInfoService!.singleData?.logoUrl ?? '', height: 50, width: 50)),
        12.0.widthBox,
        Expanded(
            flex: 1,
            child: Text(
              AppVar.appBloc.schoolInfoService!.singleData!.name!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 13),
            )),
        4.widthBox,
      ],
    );
    _current = SizedBox(
      width: 140,
      height: 55,
      child: _current,
    );
    _current = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: Fav.design.scaffold.background,
      child: _current,
    );

    if (kIsWeb) {
      _current = PointerInterceptor(
        child: _current,
      );
    }

    return Positioned(
      left: isLargeScreen ? 40 : 20,
      top: isLargeScreen ? 40 : 20,
      child: _current,
    );
  }
}
