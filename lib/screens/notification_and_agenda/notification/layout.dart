import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/notification.dart';
import '../../main/macos_dock/macos_dock.dart';
import 'animated_list.dart';

class NotificationWidgetContent extends StatelessWidget {
  final bool forMiniScreen;
  final controller = Get.find<MacOSDockController>();
  NotificationWidgetContent({this.forMiniScreen = false});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _inAppNotificationList = <InAppNotification>[];
//? Idareci icin son kullanim zamani ekleniyor
      _inAppNotificationList.addIfNotNull(controller.appLastUsableTimeNotificationList());
//? Demo kullananlar icin demo zamanini ceker
      _inAppNotificationList.addIfNotNull(controller.appDemoTimeTimeNotificationList());
//? Duyuru bildirimleri ekleniyor
      _inAppNotificationList.addAllIfNotNull(controller.announcementNotificationList());
      _inAppNotificationList.addAllIfNotNull(controller.unPublishedAnnouncementNotificationList());

//? Sosyal ag bildirimleri ekleniyor
      _inAppNotificationList.addAllIfNotNull(controller.socialNotificationList());
      _inAppNotificationList.addAllIfNotNull(controller.unPublishedSocialNotificationList());

//? Mesaj bildirimleri ekleniyor
      _inAppNotificationList.addIfNotNull(controller.messageNotificationList());
//? Gunluk karne bildirimleri ekleniyor
      _inAppNotificationList.addIfNotNull(controller.studentDailyReprotNotification());
//? LiveBroadcast bildirimleri ekleniyor
      _inAppNotificationList.addIfNotNull(controller.liveBroadCastNotificationList());
//? RollCall bildirimleri ekleniyor
      _inAppNotificationList.addIfNotNull(controller.rollCallNotificationList());
//? HomeWork bildirimleri ekleniyor
      _inAppNotificationList.addAllIfNotNull(controller.homeWorkNotificationList());

//? Portfolio  bildirimleri ekleniyor
      _inAppNotificationList.addIfNotNull(controller.portfolioExamReportNotificationList());
      _inAppNotificationList.addIfNotNull(controller.portfolioP2PNotificationList());

//? Database bildirimleri ekleniyor
      _inAppNotificationList.addAllIfNotNull(controller.databaseNotificationList());

      //? Bunu delaydan cikarinca widget cizilemez
      () {
        controller.notificationBadge.value = _inAppNotificationList.length;
      }.delay(1);

      //# Ekstra durumlar
      _inAppNotificationList.removeWhere((notification) {
        //? Ekolde Muhasebe datasini falan ogrencinin gormemesi icin
        if (!AppVar.appBloc.hesapBilgileri.isEkid && notification.forParentOtherMenu == true && AppVar.appBloc.hesapBilgileri.isParent == false) {
          return true;
        }

        //? Veliye burdayim bildirimine ok bildirimi geldiginde yanlis kisilere bildirim gostermez
        if (AppVar.appBloc.hesapBilgileri.gtS && notification.type == NotificationType.preparedStudentOk) {
          final arguments = InAppNotificationArgument.fromJson(notification.argument ?? {});
          if (arguments.token != Fav.readSeasonCache('notificationToken')) {
            return true;
          }
        }
        return false;
      });

      if (_inAppNotificationList.isEmpty) return EmptyNotificationList(forMiniScreen: forMiniScreen);

      return NotificationAnimatedList(
        itemList: _inAppNotificationList,
        shrinkWrap: forMiniScreen,
      );
    });
  }
}
