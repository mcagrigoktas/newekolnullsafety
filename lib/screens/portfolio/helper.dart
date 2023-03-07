import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../models/notification.dart';
import '../main/macos_dock/macos_dock.dart';
import '../notification_and_agenda/agenda/layout.dart';
import '../p2p/freestyle/model.dart';
import 'model.dart';

class PortfolioHelper {
  PortfolioHelper._();

  static void afterPortfolioGetData() {
    _calculateNotificationItem();
    _calculateAgendaItem();
  }

  static String get lastPortfolioPageExamReportEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}lastportfolioexamreportpagelogintime';
  static String get lastPortfolioP2PPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}lastportfoliop2ppagelogintime';

  static const examreportNotificationGroup = NotificationGroup.portfolioExamReport;
  static const p2pNotificationGroup = NotificationGroup.portfolioP2P;

////todocheck buraya ilerde yeniogdev ve yoklama geldiginde bildirim atacak sekilde ayarla diger kisimlar yapabiliyorsa sil
/////todocheck hatta rollcall student service ihtiyacin bile olmayabilir.Kontrol et.

  static void _calculateNotificationItem() {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      final lastPortfolioPageExamReportEntryTime = Fav.preferences.getInt(lastPortfolioPageExamReportEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch)!;
      final lastPortfolioP2PPageEntryTime = Fav.preferences.getInt(lastPortfolioP2PPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch)!;

      final allNewPortfolioExamReportItemList = AppVar.appBloc.portfolioService!.dataList.where((element) => element.portfolioType == PortfolioType.examreport && element.lastUpdate > lastPortfolioPageExamReportEntryTime);
      final allNewPortfolioP2PItemList = AppVar.appBloc.portfolioService!.dataList.where((element) => element.portfolioType == PortfolioType.p2p && element.lastUpdate > lastPortfolioP2PPageEntryTime);

      if (allNewPortfolioExamReportItemList.isNotEmpty) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(examreportNotificationGroup, [
          InAppNotification(type: NotificationType.examResult)
            ..title = 'newexamreportpost'.argsTranslate({'count': allNewPortfolioExamReportItemList.length})
            ..lastUpdate = allNewPortfolioExamReportItemList.fold<int>(lastPortfolioPageExamReportEntryTime, (previousValue, element) => element.lastUpdate > previousValue ? element.lastUpdate : previousValue)
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(examreportNotificationGroup, []);
      }

      if (allNewPortfolioP2PItemList.isNotEmpty) {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(p2pNotificationGroup, [
          InAppNotification(type: NotificationType.p2p)
            ..title = 'newp2ppost'.argsTranslate({'count': allNewPortfolioP2PItemList.length})
            ..lastUpdate = allNewPortfolioP2PItemList.fold<int>(lastPortfolioP2PPageEntryTime, (previousValue, element) => element.lastUpdate > previousValue ? element.lastUpdate : previousValue)
        ]);
      } else {
        Get.find<MacOSDockController>().replaceThisTagNotificationList(p2pNotificationGroup, []);
      }
    }
  }

  static void _calculateAgendaItem() {
    if (AppVar.appBloc.hesapBilgileri.gtS || AppVar.appBloc.hesapBilgileri.gtT) {
      final _agendaItemList = <Appointment>[];
      AppVar.appBloc.portfolioService!.dataList.where((element) => element.portfolioType == PortfolioType.p2p).forEach((element) {
        final _item = element.data<P2PModel>()!;

        if (_item.week != null) {
          String subject = '';
          if (AppVar.appBloc.hesapBilgileri.gtS) {
            subject = (AppVar.appBloc.teacherService!.dataListItem(_item.teacherKey!)?.name ?? '');
          } else if (AppVar.appBloc.hesapBilgileri.gtT) {
            if (_item.studentList != null && _item.studentList!.isNotEmpty) {
              subject = AppVar.appBloc.studentService!.dataListItem(_item.studentList!.first)?.name ?? '';
              if (_item.studentList!.length > 1) {
                subject += ' + ' + '${_item.studentList!.length - 1}' + ' ' + 'person'.translate;
              }
            }
          }

          final _itemStartTime = DateTime.fromMillisecondsSinceEpoch(_item.startTimeMilliSecond);
          final _appointment = Appointment(
            startTime: _itemStartTime,
            endTime: _itemStartTime.add(Duration(minutes: _item.duration!)),
            color: GlassIcons.portfolio.color!,
            subject: 'p2p'.translate,
            resourceIds: ResourceIdRule(AgendaGroup.portfolioP2P, otherKeys: [subject, element.key!]).idList,
            notes: _item.note,
          );
          _agendaItemList.add(_appointment);
        }
      });

      Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.portfolioP2P, _agendaItemList);
    }
  }

  static Future<void> saveLoginTime(PortfolioType? type) async {
    if (type == PortfolioType.examreport) await _saveLastExamReportTime();
    if (type == PortfolioType.p2p) await _saveLastP2PTime();
  }

  static Future<void> _saveLastExamReportTime() async {
    final _lastItem = Get.find<MacOSDockController>().portfolioExamReportNotificationList();
    if (_lastItem == null) return;
    await Fav.preferences.setInt(lastPortfolioPageExamReportEntryTimePrefKey, _lastItem.lastUpdate);
    _calculateNotificationItem();
  }

  static Future<void> _saveLastP2PTime() async {
    final _lastItem = Get.find<MacOSDockController>().portfolioP2PNotificationList();
    if (_lastItem == null) return;
    await Fav.preferences.setInt(lastPortfolioP2PPageEntryTimePrefKey, _lastItem.lastUpdate);
    _calculateNotificationItem();
  }
}
