import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/glassicons.dart';
import '../../eders/livebroadcast/livebroadcastmain.dart';
import '../../eders/videochat/videochatmain.dart';
import '../../generallyscreens/birthdaypage/layout.dart';
import '../../main/macos_dock/macos_dock.dart';
import '../../p2p/freestyle/model.dart';
import '../../p2p/freestyle/otherscreens/p2pdetail/controller.dart';
import '../../p2p/freestyle/otherscreens/p2pdetail/layout.dart';
import '../../portfolio/model.dart';
import '../../timetable/lessondetail/lessondetailstudent.dart';
import '../../timetable/lessondetail/lessondetailteacher.dart';

class AppointmentWidget extends StatelessWidget {
  final Appointment? appointment;
  final AgendaGroup? _agendaGroup;
  AppointmentWidget({this.appointment}) : _agendaGroup = AgendaGroup.values.singleWhereOrNull((element) => element.name == appointment!.resourceIds!.first);

  @override
  Widget build(BuildContext context) {
    String title = appointment!.subject;
    String? content = getContent();

    return MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      color: Fav.design.scaffold.background,
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          //  4.widthBox,
          getIcon(),
          8.widthBox,
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(child: title.text.color(Fav.design.primaryText).maxLines(1).autoSize.make()),
                      if (appointment!.isAllDay != true)
                        (appointment!.startTime.dateFormat('HH:mm') + (appointment!.startTime.dateFormat('HH:mm') == appointment!.endTime.dateFormat('HH:mm') ? '' : ' - ' + appointment!.endTime.dateFormat('HH:mm'))).text.color(Fav.design.primaryText).bold.fontSize(10).make().pl8,
                    ],
                  ),
                  if (content != null) content.text.color(Fav.design.primaryText.withAlpha(200)).maxLines(1).autoSize.fontSize(12).make(),
                ],
              ),
            ),
          ),
          // 4.widthBox,
        ],
      ).px8,
    );
  }

  String? getContent() {
    if (appointment!.resourceIds!.length > 1) {
      return appointment!.resourceIds![1] as String?;
    }
    return null;
  }

  void onPressed() {
    final controller = Get.find<MacOSDockController>();
    if (_agendaGroup == AgendaGroup.timetable && appointment!.resourceIds!.length == 2) {
      final _lesson = AppVar.appBloc.lessonService!.dataListItem(appointment!.resourceIds![1] as String);
      if (_lesson == null) return;
      if (AppVar.appBloc.hesapBilgileri.gtS) {
        Fav.to(LessonDetailStudent(lesson: _lesson, classKey: _lesson.classKey));
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        Fav.to(LessonDetailTeacher(lesson: _lesson, classKey: _lesson.classKey));
      }
    }

    if (_agendaGroup == AgendaGroup.portfolioP2P && appointment!.resourceIds!.length > 2) {
      final item = AppVar.appBloc.portfolioService!.dataList.firstWhereOrNull((element) {
        if (element.portfolioType != PortfolioType.p2p) return false;
        return element.key == appointment!.resourceIds![2];
      });

      if (item != null) Fav.to(P2PDetail(), binding: BindingsBuilder(() => Get.put<P2PDetailController>(P2PDetailController(item.data<P2PModel>()))));
    }
    if (_agendaGroup == AgendaGroup.homework && appointment!.resourceIds!.length > 2) {
      final _lessonKey = appointment!.resourceIds![2];
      final _lesson = AppVar.appBloc.lessonService!.dataListItem(_lessonKey as String);
      if (_lesson == null) return;
      if (AppVar.appBloc.hesapBilgileri.gtS) {
        Fav.to(LessonDetailStudent(lesson: _lesson, classKey: _lesson.classKey));
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        Fav.to(LessonDetailTeacher(lesson: _lesson, classKey: _lesson.classKey));
      }
    }
    if (_agendaGroup == AgendaGroup.lessonExam && appointment!.resourceIds!.length > 2) {
      final _lessonKey = appointment!.resourceIds![2];
      final _lesson = AppVar.appBloc.lessonService!.dataListItem(_lessonKey as String);
      if (_lesson == null) return;
      if (AppVar.appBloc.hesapBilgileri.gtS) {
        Fav.to(LessonDetailStudent(lesson: _lesson, classKey: _lesson.classKey));
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        Fav.to(LessonDetailTeacher(lesson: _lesson, classKey: _lesson.classKey));
      }
    }

    if (_agendaGroup == AgendaGroup.liveBroadCast && appointment!.resourceIds!.length > 2) {
      if (controller.isSmallLayoutEnable) {
        Fav.to(LiveBroadcastMain(forMiniScreen: true));
      } else {
        final _macOSDockPageItem = controller.bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == DockItemTag.liveBroadCast);
        if (_macOSDockPageItem != null) controller.bigScreenOnChanged(_macOSDockPageItem);
      }
    }
    if (_agendaGroup == AgendaGroup.videoLesson && appointment!.resourceIds!.length > 2) {
      if (controller.isSmallLayoutEnable) {
        Fav.to(VideoChatMain(forMiniScreen: true));
      } else {
        final _macOSDockPageItem = controller.bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == DockItemTag.videoLesson);
        if (_macOSDockPageItem != null) controller.bigScreenOnChanged(_macOSDockPageItem);
      }
    }
    if (_agendaGroup == AgendaGroup.exam && appointment!.resourceIds!.length == 2) {}
    if (_agendaGroup == AgendaGroup.birthDay && appointment!.resourceIds!.length == 2) {
      Fav.to(BirthdayListPage());
    }
  }

  Widget getIcon() {
    if (_agendaGroup == AgendaGroup.timetable) return Image.asset(GlassIcons.timetable2.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.portfolioP2P) return Image.asset(GlassIcons.portfolio.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.homework) return Image.asset(GlassIcons.homework.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.liveBroadCast) return Image.asset(GlassIcons.liveBroadcastIcon.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.videoLesson) return Image.asset(GlassIcons.videoLesson.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.exam) return Image.asset(GlassIcons.exam.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.lessonExam) return Image.asset(GlassIcons.exam.imgUrl, width: 22);
    if (_agendaGroup == AgendaGroup.birthDay) return Image.asset(GlassIcons.birthday.imgUrl, width: 22);

    return SizedBox();
  }
}
