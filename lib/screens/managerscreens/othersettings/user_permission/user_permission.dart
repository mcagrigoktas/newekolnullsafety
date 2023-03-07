import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';

class UserPermissionList {
  UserPermissionList._();

  static void refresh() {
    __permissionData![AppVar.appBloc.hesapBilgileri.kurumID] = AppVar.appBloc.permissionService!.data;
  }

//? Eger uygulama acilir acilmaz lazim olabilecek bir permission gelirse Menulistteki gibi prefe kaydederek kullabailirsin
  static Map<String?, Map>? __permissionData;

  static Map? get _permissionData {
    if (__permissionData == null || !__permissionData!.containsKey(AppVar.appBloc.hesapBilgileri.kurumID)) {
      __permissionData ??= {};
      __permissionData![AppVar.appBloc.hesapBilgileri.kurumID] = AppVar.appBloc.permissionService!.data;
      Future.delayed(3.seconds).then((value) {
        __permissionData![AppVar.appBloc.hesapBilgileri.kurumID] = AppVar.appBloc.permissionService!.data;
      });
    }

    return __permissionData![AppVar.appBloc.hesapBilgileri.kurumID];
  }

  static bool hasPrepareMyStudent() => _permissionData![PermissionEnum.preparemystudent] ?? false;
  static bool hasTeacherAnnouncementsSharing() => _permissionData![PermissionEnum.teacherAnnouncementsSharing] ?? false;
  static bool hasTeacherSocialSharing() => _permissionData![PermissionEnum.teacherSocialSharing] ?? false;
  static bool hasTeacherCallParent() => _permissionData![PermissionEnum.teacherCallParent] ?? false;
  static bool hasTeacherMessageParent() => _permissionData![PermissionEnum.teacherMessageParent] ?? true;
  static bool hasTeacherMessageManager() => _permissionData![PermissionEnum.teacherMessageManager] ?? false;
  static bool hasTeacherMailParent() => _permissionData![PermissionEnum.teacherMailParent] ?? false; //Bu neden kullanilmiyor
  static int bannedClockStartTime() => _permissionData![PermissionEnum.bannedClockStartTime] ?? 0;
  static int bannedClockEndTime() => _permissionData![PermissionEnum.bannedClockEndTime] ?? 23;
  static bool hasRollcallAutoNotification() => _permissionData![PermissionEnum.rollcallautonotification] ?? false;
  static bool hasTeacherHomeWorkSharing() => _permissionData![PermissionEnum.teacherHomeWorkSharing] ?? false;
  static bool hasStudentCanP2PRequest() => _permissionData![PermissionEnum.studentCanP2PRequest] ?? false;
  //['0'->sameweek,'1'->nextweek,'2'->week2later]
  static List<String> p2pRequestTimes() => List<String>.from(_permissionData![PermissionEnum.p2pRequestTimes] ?? ['1', '2']);
  static int howManyLesson1Week() => _permissionData![PermissionEnum.p2pp1] ?? 1;
  static int howManyLesson1WeekSameTeacher() => _permissionData![PermissionEnum.p2pp2] ?? 1;
  static int howManySameLesson1Day() => _permissionData![PermissionEnum.p2pp3] ?? 1;
  static int howManyDayForCancel() => _permissionData![PermissionEnum.p2pp4] ?? 1;
  static int howManyDaysBanStudentForP2P() => _permissionData![PermissionEnum.banForP2PInDays] ?? 7;
  static bool hasStudentOtherTeacherP2PRequest() => _permissionData![PermissionEnum.p2pp5] ?? true;
  static bool hasStudentRequestThenTeacherApprove() => _permissionData![PermissionEnum.p2pp6] ?? false;
  static bool hasStudentCanChangePhoto() => _permissionData![PermissionEnum.studentCanChangePhoto] ?? true;
  static bool hasDeletePermissionTeacherOwnELesson() => _permissionData![PermissionEnum.teacherCanDeleteOwnELesson] ?? false;
  static int teacherMaxPinAnnouncementCount() => _permissionData![PermissionEnum.teacherMaxPinAnnouncement] ?? 100;

  static bool sendP2PNotificationToTehacer() => _permissionData![PermissionEnum.sendTeacherNotificationForP2p] ?? false;
  static bool addAgendaBirthdayItems() => _permissionData![PermissionEnum.addBirthdayItemsInAgenda] ?? true;
  static bool sendnotifyunpublisheditem() => _permissionData![PermissionEnum.sendnotifyunpublisheditem] ?? false;
}

class PermissionEnum {
  PermissionEnum._();
  static String preparemystudent = 'pms';
  static String teacherAnnouncementsSharing = 'teacherAnnouncementsSharing';
  static String sendnotifyunpublisheditem = 'sendnotifyunpublisheditem';
  static String teacherSocialSharing = 'teacherSocialSharing';
  static String teacherCallParent = 'teacherCallParent';
  static String teacherMailParent = 'teacherMailParent';
  static String rollcallautonotification = 'rollcallautonotification';
  static String teacherHomeWorkSharing = 'teacherHomeWorkSharing';
  static String teacherMessageParent = 'teacherMessageParent';
  static String teacherMessageManager = 'teacherMessageManager';
  static String studentCanP2PRequest = 'studentCanP2PRequest';
  static String banForP2PInDays = 'banForP2PInDays';
  static String studentCanChangePhoto = 'studentCanChangePhoto';
  static String teacherCanDeleteOwnELesson = 'tcdoel';
  static String sendTeacherNotificationForP2p = 'stnfp2p';
  static String p2pRequestTimes = 'p2pRequestTimes';
  static String p2pp1 = 'p2pp1';
  static String p2pp2 = 'p2pp2';
  static String p2pp3 = 'p2pp3';
  static String p2pp4 = 'p2pp4';
  static String p2pp5 = 'p2pp5';
  static String p2pp6 = 'p2pp6';
  static String bannedClockStartTime = 'startTime';
  static String bannedClockEndTime = 'endTime';
  static String teacherMaxPinAnnouncement = 'tmpac';
  static String addBirthdayItemsInAgenda = 'blaa';
}
