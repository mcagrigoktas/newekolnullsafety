import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../../models/notification.dart';
import '../../../services/dataservice.dart';
import '../../accounting/studentaccounting/widgets/planreview_for_student.dart';
import '../../announcements/helper.dart';
import '../../dailyreport/helper.dart';
import '../../eders/livebroadcast/broadcaststarter/broadcaststarthelper.dart';
import '../../eders/livebroadcast/helper.dart';
import '../../eders/videochat/videochatmain.dart';
import '../../healthcare/addmedicine.dart';
import '../../main/macos_dock/macos_dock.dart';
import '../../main/menu_list_helper.dart';
import '../../mesagging/helper.dart';
import '../../portfolio/helper.dart';
import '../../portfolio/model.dart';
import '../../rollcall/ekidrollcallstudent.dart';
import '../../rollcall/ekolrollcallstudentpage.dart';
import '../../rollcall/helper.dart';
import '../../social/helper.dart';
import '../../timetable/homework_helper.dart';
import '../../timetable/lessondetail/lessondetailstudent.dart';
import '../../timetable/lessondetail/lessondetailteacher.dart';
import 'notification_helper.dart';

class NotificationAnimatedList extends StatelessWidget {
  final List<InAppNotification>? itemList;
  final bool shrinkWrap;

  NotificationAnimatedList({this.itemList, this.shrinkWrap = true});
  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedList<InAppNotification>(
      padding: EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 8),
      items: itemList!,
      shrinkWrap: shrinkWrap,
      areItemsTheSame: (a, b) => a.key == b.key && a.title == b.title && a.content == b.content,
      itemBuilder: (context, animation, item, index) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: _NotificationListTile(notification: item),
        );
      },
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  final InAppNotification? notification;
  _NotificationListTile({this.notification});
  final controller = Get.find<MacOSDockController>();
  @override
  Widget build(BuildContext context) {
    Function()? _onNotificationTap;
    Function()? _onDeleteTap;
    IconData? _deleteIcon;

    if (notification!.type == NotificationType.appLastUsableTime) {
      //  _onNotificationTap = null;
      //__onDeleteTap = null;
    } else if (notification!.type == NotificationType.appDemoTime) {
      //  _onNotificationTap = null;
      //__onDeleteTap = null;
    } else if (notification!.type == NotificationType.announcement) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.announcement);
      };
      _onDeleteTap = () {
        AnnouncementHelper.saveLastLoginTime();
      };
    } else if (notification!.type == NotificationType.announcementUnPublish) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.announcement);
      };
    } else if (notification!.type == NotificationType.social) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.social);
      };
      _onDeleteTap = () {
        SocialHelper.saveLastLoginTime();
      };
    } else if (notification!.type == NotificationType.socialUnPublish) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.social);
      };
    } else if (notification!.type == NotificationType.message) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.messages);
      };
      _onDeleteTap = () {
        MessagePreviewHelper.saveLastLoginTime();
      };
    } else if (notification!.type == NotificationType.dailyreport) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.dailyreport);
      };
      _onDeleteTap = () {
        DailyReportHelper.saveLastLoginTime();
      };
    } else if (notification!.type == NotificationType.liveBroadCastNewEntry) {
      _onNotificationTap = () {
        controller.goToThisPageTag(DockItemTag.liveBroadCast);
      };
      _onDeleteTap = () {
        LiveBroadcastMainHalper.saveLastLoginTime();
      };
    } else if (notification!.type == NotificationType.p2p) {
      _onNotificationTap = () {
        controller.setPageArgs(PageName.pM, PortfolioType.p2p);
        controller.goToThisPageTag(DockItemTag.portfolio);
      };
      _onDeleteTap = () {
        PortfolioHelper.saveLoginTime(PortfolioType.p2p);
      };
    } else if (notification!.type == NotificationType.examResult) {
      _onNotificationTap = () {
        controller.setPageArgs(PageName.pM, PortfolioType.examreport);
        controller.goToThisPageTag(DockItemTag.portfolio);
      };
      _onDeleteTap = () {
        PortfolioHelper.saveLoginTime(PortfolioType.examreport);
      };
    } else if (notification!.type == NotificationType.rollCall) {
      _onNotificationTap = () {
        if (MenuList.hasTimeTable()) {
          Fav.guardTo(EkolRollCallStudentPage());
        } else {
          Fav.guardTo(EkidRollCallStudentPage());
        }
      };
      _onDeleteTap = () {
        RollCallHelper.saveLastLoginTime();
      };
    } else if (notification!.type == NotificationType.homeWork || notification!.type == NotificationType.examDateLesson) {
      _onNotificationTap = () {
        final _lessonKey = notification!.argument!['lessonKey'];
        final _lesson = AppVar.appBloc.lessonService!.dataListItem(_lessonKey);
        if (_lesson == null) return;
        if (AppVar.appBloc.hesapBilgileri.gtS) {
          Fav.to(LessonDetailStudent(lesson: _lesson, classKey: _lesson.classKey));
        } else if (AppVar.appBloc.hesapBilgileri.gtT) {
          Fav.to(LessonDetailTeacher(lesson: _lesson, classKey: _lesson.classKey));
        }
      };
      _onDeleteTap = () {
        final _lessonKey = notification!.argument!['lessonKey'];
        if (_lessonKey != null) HomeWorkHelper.saveLastLoginTime(_lessonKey);
      };
    } else if (notification!.type == NotificationType.prepareStudent || notification!.type == NotificationType.iamcame) {
      Future<void> _function() async {
        final arguments = InAppNotificationArgument.fromJson(notification!.argument ?? {});

        final _sure = await OverDialog.show(DialogPanel.simpleList(items: [
          if (arguments.token.safeLength > 6) BottomSheetItem(name: 'sendoknotification'.translate, value: 1, bold: true),
          BottomSheetItem(name: 'delete'.translate, value: 0, itemColor: Colors.red),
        ]));
        if (_sure == 0) {
          await NotificationWidgetHelper.makeThisNotificationRead(notification!);
        } else if (_sure == 1) {
          await InAppNotificationService.sendInAppNotification(
            InAppNotification(type: NotificationType.preparedStudentOk)
              ..argument = InAppNotificationArgument.addTokenAndCheck(token: arguments.token).toJson()
              ..key = AppVar.appBloc.hesapBilgileri.uid! + 'preparemystudentok'
              ..senderKey = AppVar.appBloc.hesapBilgileri.uid
              ..title = AppVar.appBloc.hesapBilgileri.name
              ..content = 'preparemystudentok'.translate,
            notification!.senderKey,
            sendOnlyThisTokenList: [arguments.token],
          );
          await NotificationWidgetHelper.makeThisNotificationRead(notification!);
        }
      }

      _deleteIcon = Icons.more_vert;
      _onNotificationTap = _function;
      _onDeleteTap = _function;
    } else {
      _onDeleteTap = () {
        NotificationWidgetHelper.makeThisNotificationRead(notification!);
      };

      if (notification!.pageName == PageName.sA) {
        _onNotificationTap = () async {
          await Fav.guardTo(StudentPlanReview());
          await NotificationWidgetHelper.makeThisNotificationRead(notification!);
        };
      } else if (notification!.pageName == PageName.med) {
        _onNotificationTap = () async {
          await Fav.guardTo(AddedMedicineList());
          await NotificationWidgetHelper.makeThisNotificationRead(notification!);
        };
      } else if (notification!.pageName == PageName.eLS) {
        _onNotificationTap = () async {
          if ((notification!.argument != null) && (notification!.argument!.containsKey('d')) && (notification!.argument!['d'] as String).startsWith('bl-')) {
            BroadcastHelper.startBroadcastLessonInNotification(notification!.argument!['d']);
            await NotificationWidgetHelper.makeThisNotificationRead(notification!);
          }
        };
      } else if (notification!.pageName == PageName.vCMA) {
        _onNotificationTap = () async {
          if ((notification!.argument != null) && (notification!.argument!.containsKey('t'))) {
            await Fav.to(VideoChatManagerScreen(forStudent: true, initialTeacherKey: notification!.argument!['t']), preventDuplicates: false);
            await NotificationWidgetHelper.makeThisNotificationRead(notification!);
          }
        };
      } else if (notification!.pageName == PageName.vCR) {
        _onNotificationTap = () async {
          controller.goToThisPageTag(DockItemTag.videoLesson);
          await NotificationWidgetHelper.makeThisNotificationRead(notification!);
        };
      } else if (notification!.pageName == PageName.S) {
        _onNotificationTap = () async {
          controller.goToThisPageTag(DockItemTag.sticker);
          await NotificationWidgetHelper.makeThisNotificationRead(notification!);
        };
      }
    }

    return InkWell(
      onTap: _onNotificationTap,
      child: Padding(
        padding: EdgeInsets.only(right: 8, top: 8, bottom: 8, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (notification!.assetImage != null)
              Image.asset(
                notification!.assetImage!,
                width: 22,
              )
            else
              notification!.icon.icon.size(22).padding(0).color(Fav.design.primaryText).make(),
            14.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  notification!.title.text.bold.fontSize(17).make(),
                  if (notification!.content.safeLength > 0) notification!.content!.trim().text.fontSize(14).make(),
                ],
              ),
            ),
            if (_onDeleteTap != null) (_deleteIcon ?? MdiIcons.deleteEmpty).icon.padding(6).onPressed(_onDeleteTap).size(20).color(Fav.design.primaryText.withAlpha(125)).make()
            // InkWell(
            //   onTap: _onDeleteTap,
            //   child: Image.asset(GlassIcons.trash.imgUrl, width: 18).p8,
            // ),
          ],
        ),
      ),
    );
  }
}

class EmptyNotificationList extends StatelessWidget {
  final bool forMiniScreen;
  EmptyNotificationList({this.forMiniScreen = false});
  @override
  Widget build(BuildContext context) {
    Widget _current = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RiveSimpeLoopAnimation.asset(
          url: Assets.rive.ekolRIV,
          artboard: 'NOTIFICATIONS',
          animation: 'play',
          width: forMiniScreen ? 220 : 280,
          heigth: forMiniScreen ? 220 * (301 / 461) : 280 * (301 / 461),
        ).pl8,
        2.heightBox,
        'nonewnotifications'.translate.text.fontSize(18).bold.make(),
      ],
    ).p16;
    if (!forMiniScreen) {
      return Center(
        child: _current,
      );
    }
    //? Burdaki row gerekli
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_current],
    );
  }
}
