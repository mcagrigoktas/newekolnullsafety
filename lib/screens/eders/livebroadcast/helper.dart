import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/glassicons.dart';
import '../../../models/models.dart';
import '../../../models/notification.dart';
import '../../main/macos_dock/macos_dock.dart';
import '../../notification_and_agenda/agenda/layout.dart';

class LiveBroadcastMainHalper {
  LiveBroadcastMainHalper._();
  static List<LiveBroadcastModel> getData(String? _teacherKey) {
    var _filteredList = <LiveBroadcastModel>[];

    _filteredList = AppVar.appBloc.liveBroadcastService!.dataList.where((item) => (item.teacherKey == _teacherKey || _teacherKey == 'all') && item.aktif != false).toList();
    _filteredList.removeWhere((element) => (element.timeType ?? 0) == 0 && element.endTime! < DateTime.now().millisecondsSinceEpoch - const Duration(hours: 5).inMilliseconds);
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      _filteredList.removeWhere((element) {
        if (element.targetList!.contains("alluser")) return false;
        if (element.targetList!.any((item) => [...AppVar.appBloc.hesapBilgileri.classKeyList, AppVar.appBloc.hesapBilgileri.uid].contains(item))) return false;
        return true;
      });
    }
    return _filteredList;
  }

  static const liveBroadcastIconTag = DockItemTag.liveBroadCast;
  static const liveBroadcastNotifcitaionGroup = NotificationGroup.liveBroadCast;
  static String get lastLiveBroadcastPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}lastLiveBroadcastPageEntryTime';

  static void afterLiveBroadCastNewData() {
    calculateNotificationItems();
    calculateAgendaItems();
  }

  static void calculateNotificationItems() {
    final lastLiveBroadCastPageLoginTime = Fav.preferences.getInt(lastLiveBroadcastPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch);

    if (AppVar.appBloc.hesapBilgileri.gtS) {
      final _allBroadcastModeList = getData('all').where((element) => element.lastUpdate > lastLiveBroadCastPageLoginTime).toList();

      if (_allBroadcastModeList.isNotEmpty) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(liveBroadcastNotifcitaionGroup, [
          InAppNotification(type: NotificationType.liveBroadCastNewEntry)
            ..title = 'newlivebroadcasttpost'.argsTranslate({'count': _allBroadcastModeList.length})
            ..lastUpdate = _allBroadcastModeList.fold<int?>(lastLiveBroadCastPageLoginTime, (previousValue, element) => element.lastUpdate > previousValue ? element.lastUpdate : previousValue)
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(liveBroadcastNotifcitaionGroup, []);
      }
    } else if (AppVar.appBloc.hesapBilgileri.gtT) {
      final _allBroadcastModeList = getData(AppVar.appBloc.hesapBilgileri.uid).where((element) => element.lastUpdate > lastLiveBroadCastPageLoginTime).toList();

      if (_allBroadcastModeList.isNotEmpty) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(liveBroadcastNotifcitaionGroup, [
          InAppNotification(type: NotificationType.liveBroadCastNewEntry)
            ..title = 'newlivebroadcasttpostt'.argsTranslate({'count': _allBroadcastModeList.length})
            ..lastUpdate = _allBroadcastModeList.fold<int?>(lastLiveBroadCastPageLoginTime, (previousValue, element) => element.lastUpdate > previousValue ? element.lastUpdate : previousValue)
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(liveBroadcastNotifcitaionGroup, []);
      }
    }
  }

  static void calculateAgendaItems() {
    if (AppVar.appBloc.hesapBilgileri.gtS || AppVar.appBloc.hesapBilgileri.gtT) {
      final _allBroadcastModeList = (AppVar.appBloc.hesapBilgileri.gtS ? getData('all') : getData(AppVar.appBloc.hesapBilgileri.uid));
      final _agendaItemList = <Appointment>[];

      _allBroadcastModeList.forEach((_item) {
        if (_item.timeType == 0) {
          final _date = DateTime.fromMillisecondsSinceEpoch(_item.startTime!);
          final _finishDate = DateTime.fromMillisecondsSinceEpoch(_item.endTime!);
          final _appointment = Appointment(
            startTime: _date,
            endTime: _finishDate,
            color: GlassIcons.liveBroadcastIcon.color!,
            subject: 'livebroadcast'.translate + ' - ' + _item.lessonName!,
            resourceIds: ResourceIdRule(AgendaGroup.liveBroadCast, otherKeys: [_item.explanation!, _item.key!]).idList,
          );
          _agendaItemList.add(_appointment);
        }
      });

      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.liveBroadCast, _agendaItemList);
    }
  }

  static Future<void> saveLastLoginTime() async {
    final _lastItem = Get.find<MacOSDockController>().liveBroadCastNotificationList();
    if (_lastItem == null) return;
    await Fav.preferences.setInt(lastLiveBroadcastPageEntryTimePrefKey, _lastItem.lastUpdate);
    calculateNotificationItems();
  }
}
