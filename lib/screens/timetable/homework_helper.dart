import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../appbloc/appvar.dart';
import '../../flavors/mainhelper.dart';
import '../../helpers/glassicons.dart';
import '../../models/notification.dart';
import '../main/macos_dock/macos_dock.dart';
import '../notification_and_agenda/agenda/layout.dart';

class HomeWorkHelper {
  HomeWorkHelper._();
  //! Burasi Yeni data geldikce yapilacak degisiklikler
  static void afterHomeWorkNewData() {
    _parseHomeWork();
    _calculateNotificationItem();
    _calculateAgendaItem();
  }

  static const homeWorkNotificationGroup = NotificationGroup.homeWork;
  static String lastNewHomeWorkDataTimePrefKeyForLesson(String? lessonKey) => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}${lessonKey}lastNewHomeWorkDataTimePrefKey';
  static int? lastHomeWorkPageLoginTimeForLesson(String? lessonKey) => Fav.preferences.getInt(lastNewHomeWorkDataTimePrefKeyForLesson(lessonKey), DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch);
  static void _calculateNotificationItem() {
    if (AppVar.appBloc.hesapBilgileri.gtS || AppVar.appBloc.hesapBilgileri.gtT) {
      final newHomeWorkList = AppVar.appBloc.homeWorkService!.dataList.where((element) => element.aktif != false && element.isPublish == true && element.timeStamp > lastHomeWorkPageLoginTimeForLesson(element.lessonKey)).toList();

      if (newHomeWorkList.isNotEmpty) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(homeWorkNotificationGroup, <InAppNotification>[
          ...newHomeWorkList.map(
            (e) => InAppNotification(type: e.tur == 2 ? NotificationType.examDateLesson : NotificationType.homeWork)
              ..title = (AppVar.appBloc.hesapBilgileri.gtS ? (e.lessonName ?? '') : (e.className ?? '')) + ' - ' + (e.title ?? '')
              ..content = e.content! + (e.checkNote.safeLength > 0 ? ('\n' + 'hwcomplated'.translate) : '')
              ..lastUpdate = e.timeStamp
              ..argument = {
                'lessonKey': e.lessonKey,
              },
          )
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(homeWorkNotificationGroup, <InAppNotification>[]);
      }
    }
  }

  static void _calculateAgendaItem() {
    if (AppVar.appBloc.hesapBilgileri.gtS || AppVar.appBloc.hesapBilgileri.gtT) {
      final _agendaHomeWorkItemList = <Appointment>[];
      final _agendaLessonExamItemList = <Appointment>[];
      AppVar.appBloc.homeWorkService!.dataList.where((element) => element.aktif != false && element.isPublish == true).forEach((_item) {
        if (_item.checkDate is int) {
          if (_item.tur == 1) {
            final _date = DateTime.fromMillisecondsSinceEpoch(_item.checkDate!);
            final _appointment = Appointment(
              startTime: _date,
              endTime: _date.add(Duration(minutes: 40)),
              color: GlassIcons.homework.color!,
              subject: 'homework'.translate + ' - ' + _item.lessonName!,
              resourceIds: ResourceIdRule(AgendaGroup.homework, otherKeys: [_item.title!, _item.lessonKey!]).idList,
              isAllDay: true,
            );
            _agendaHomeWorkItemList.add(_appointment);
          } else if (_item.tur == 2) {
            final _date = DateTime.fromMillisecondsSinceEpoch(_item.checkDate!);
            final _appointment = Appointment(
              startTime: _date,
              endTime: _date.add(Duration(minutes: 40)),
              color: GlassIcons.exam.color!,
              subject: 'exam'.translate + ' - ' + _item.lessonName!,
              resourceIds: ResourceIdRule(AgendaGroup.lessonExam, otherKeys: [_item.title!, _item.lessonKey!]).idList,
              isAllDay: true,
            );
            _agendaHomeWorkItemList.add(_appointment);
          }
        }
      });
      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.homework, _agendaHomeWorkItemList);
      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.lessonExam, _agendaLessonExamItemList);
    }
  }

  static Future<void> saveLastLoginTime(String? lessonKey) async {
    final _itemList = Get.find<MacOSDockController>().homeWorkNotificationList();
    if (_itemList == null || _itemList.isEmpty) return;
    await Fav.preferences.setInt(lastNewHomeWorkDataTimePrefKeyForLesson(lessonKey), _itemList.where((element) => element.argument!['lessonKey'] == lessonKey).fold<int?>(lastHomeWorkPageLoginTimeForLesson(lessonKey), (p, e) => p! > e.lastUpdate ? p : e.lastUpdate)!);
    _calculateNotificationItem();
  }

  static Future<void> _parseHomeWork() async {
    // butun odev lerin analizi icin
    final String saveKey = "${AppVar.appBloc.hesapBilgileri.uid}${AppVar.appBloc.hesapBilgileri.termKey}HomeWorkAnalyse";
    final Map homeWorkData = AppVar.appBloc.homeWorkService!.data;
    final int now = DateTime.now().millisecondsSinceEpoch;
    // if (homeWorkData == null) return;

    homeWorkData.removeWhere((key, value) {
      if (value['timeStamp'] == null) return true;
      if (value['checkDate'] == null) return true;
      if (value['checkDate'] < now - 64800000) return true;
      if (value['isPublish'] != true) return true;
      if (value['aktif'] != true) return true;
      return false;
    });

    await Fav.securePreferences.setHiveMap(saveKey + AppConst.preferenecesBoxVersion.toString(), homeWorkData, clearExistingData: true);
  }

  static String getNotificationHeader(int? tur) {
    if (tur == 1) return "homework".translate;
    if (tur == 2) return "exam".translate;
    if (tur == 3) return "hwnote".translate;
    return '';
  }
}
