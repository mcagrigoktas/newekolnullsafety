import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/glassicons.dart';
import '../../../models/allmodel.dart';
import '../../main/macos_dock/macos_dock.dart';
import '../../notification_and_agenda/agenda/layout.dart';

class VideoChatHelper {
  VideoChatHelper._();
  static List<VideoLessonStudentModel> getVideoChatDataForStudent() {
    //todocheck burda item.aktife gerek varmi bilmiyorum
    return AppVar.appBloc.videoChatStudentService!.dataList.where((item) => item.aktif != false).toList();
  }

  static void afterVideoChatNewData() {
    calculateAgendaItems();
  }

  static void calculateAgendaItems() {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      final _allVideoChatItems = getVideoChatDataForStudent();
      final _agendaItemList = <Appointment>[];

      _allVideoChatItems.forEach((_item) {
        final _date = DateTime.fromMillisecondsSinceEpoch(_item.startTime!);
        final _finishDate = DateTime.fromMillisecondsSinceEpoch(_item.endTime!);
        final _appointment = Appointment(
          startTime: _date,
          endTime: _finishDate,
          color: GlassIcons.videoLesson.color!,
          subject: 'p2pappointmentlesson'.translate + ' - ' + _item.lessonName.firstXcharacter(10)!,
          resourceIds: ResourceIdRule(AgendaGroup.videoLesson, otherKeys: [_item.explanation!, _item.key!]).idList,
        );
        _agendaItemList.add(_appointment);
      });

      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.videoLesson, _agendaItemList);
    } else if (AppVar.appBloc.hesapBilgileri.gtT) {
      final _allVideoChatItems = AppVar.appBloc.videoChatTeacherService!.dataList;
      final _agendaItemList = <Appointment>[];

      _allVideoChatItems.forEach((_item) {
        final _date = DateTime.fromMillisecondsSinceEpoch(_item.startTime!);
        final _finishDate = DateTime.fromMillisecondsSinceEpoch(_item.endTime!);
        final _appointment = Appointment(
          startTime: _date,
          endTime: _finishDate,
          color: GlassIcons.videoLesson.color!,
          subject: 'p2pappointmentlesson'.translate + ' - ' + _item.lessonName.firstXcharacter(10)!,
          resourceIds: ResourceIdRule(AgendaGroup.videoLesson, otherKeys: [_item.explanation!, _item.key!]).idList,
        );
        _agendaItemList.add(_appointment);
      });

      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.videoLesson, _agendaItemList);
    }
  }
}
