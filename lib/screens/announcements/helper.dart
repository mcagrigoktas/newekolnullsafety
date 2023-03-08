import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../models/notification.dart';
import '../../services/dataservice.dart';
import '../main/macos_dock/macos_dock.dart';
import '../notification_and_agenda/agenda/layout.dart';
import 'announcement.dart';

class AnnouncementHelper {
  AnnouncementHelper._();

  static List<Announcement> getAllFilteredAnnouncement() {
    late List<String?> _teacherClassList;
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _teacherClassList = TeacherFunctions.getTeacherClassList();
    }

    List<String?>? _studentClassKeyList;
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      _studentClassKeyList = AppVar.appBloc.hesapBilgileri.classKeyList;
    }

    final _data = AppVar.appBloc.announcementService?.dataList.where((item) {
          if (item.aktif == false) return false;

          if (AppVar.appBloc.hesapBilgileri.gtM) return true;

          if (AppVar.appBloc.hesapBilgileri.gtT) {
            if (item.targetList!.contains("alluser") || item.targetList!.contains("onlyteachers")) return true;

            if (item.senderKey == AppVar.appBloc.hesapBilgileri.uid) return true;

            if (item.targetList!.any((item) => _teacherClassList.contains(item))) return true;
          }
          if (AppVar.appBloc.hesapBilgileri.gtS) {
            if (!(item.isPublish ?? false)) return false;

            if (item.targetList!.contains("alluser")) return true;

            if (item.targetList!.any((item) => [..._studentClassKeyList!, AppVar.appBloc.hesapBilgileri.uid].contains(item))) return true;
          }
          return false;
        }).toList() ??
        [];
    return _data;
  }

//! Burasi Yeni data geldikce yapilacak degisiklikler
  static void afterAnnouncementsNewData() {
    final _announcementList = getAllFilteredAnnouncement();
    _saveLastAnnouncementTimeToDatabaseForLastSeen(_announcementList);
    calculateNotificationItems(_announcementList);
    calculateAgendaItems(_announcementList);
  }

  //? Burada bir kisinin son gelen duyurusunun zamani en son bu tarihe kadari gonderildi diye database e yazar
  static void _saveLastAnnouncementTimeToDatabaseForLastSeen(List<Announcement> allAnnouncementList) {
    final newDatabaseVersion = allAnnouncementList.fold<int>(0, (p, e) => p > e.timeStamp ? p : e.timeStamp);

    final _prefKey = AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.termKey + AppVar.appBloc.hesapBilgileri.uid + 'anoouncemetseen';
    if (newDatabaseVersion != 0 && Fav.preferences.getInt(_prefKey) != newDatabaseVersion) {
      AnnouncementService.saveGettingAnnouncementVersion(newDatabaseVersion);
      Fav.preferences.setInt(_prefKey, newDatabaseVersion);
    }
  }

  static const announcementIconTag = DockItemTag.announcement;
  static String get lastAnnouncementPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.uid}lastannouncementpagelogintime';
  static void calculateNotificationItems(List<Announcement> allAnnouncementList) {
    final lastannouncementpagelogintime = Fav.preferences.getInt(lastAnnouncementPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch);

    int _unPublishedItemCount = 0;
    final newAnnouncementList = allAnnouncementList.where((element) {
      if (element.isPublish == false) _unPublishedItemCount++;
      return element.createTime > lastannouncementpagelogintime;
    }).toList();

    List<InAppNotification> notificationList = [];
    List<InAppNotification> unPublishedNotificationList = [];

    if (newAnnouncementList.isNotEmpty) {
      notificationList.add(InAppNotification(
        title: 'newannouncementpost'.argsTranslate({'count': newAnnouncementList.length}),
        type: NotificationType.announcement,
      )..lastUpdate = newAnnouncementList.fold<int?>(lastannouncementpagelogintime, (previousValue, element) => element.createTime > previousValue ? element.createTime : previousValue));
    }
    if (AppVar.appBloc.hesapBilgileri.gtM && _unPublishedItemCount > 0) {
      unPublishedNotificationList.add(InAppNotification(
        title: 'unpublishedannouncement'.argsTranslate({'count': _unPublishedItemCount}),
        type: NotificationType.announcementUnPublish,
      ));
    }
    Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.announcement, notificationList);
    Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.announcementUnPublish, unPublishedNotificationList);
  }

  static Future<void> saveLastLoginTime() async {
    final _itemList = Get.find<MacOSDockController>().announcementNotificationList();
    if (_itemList == null || _itemList.isEmpty) return;
    await Fav.preferences.setInt(lastAnnouncementPageEntryTimePrefKey, _itemList.fold<int?>(0, (p, e) => p! > e.lastUpdate ? p : e.lastUpdate)!);
    calculateNotificationItems(getAllFilteredAnnouncement());
  }

  static void calculateAgendaItems(List<Announcement> allAnnouncementList) {
    if (AppVar.appBloc.hesapBilgileri.gtS || AppVar.appBloc.hesapBilgileri.gtT || AppVar.appBloc.hesapBilgileri.gtM) {
      final _agendaItemList = <Appointment>[];

      allAnnouncementList.forEach((_item) {
        if (_item.examInfo != null) {
          final _date = DateTime.fromMillisecondsSinceEpoch(_item.examInfo!['date']);
          final _finishDate = DateTime.fromMillisecondsSinceEpoch(_item.examInfo!['date']);
          final _appointment = Appointment(
            startTime: _date,
            endTime: _finishDate,
            color: GlassIcons.exam.color!,
            subject: _item.examInfo!['name'],
            resourceIds: ResourceIdRule(AgendaGroup.exam, otherKeys: [_item.key!]).idList,
          );
          _agendaItemList.add(_appointment);
        }
      });

      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.exam, _agendaItemList);
    }
  }
}
