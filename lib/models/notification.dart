import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../assets.dart';
import '../helpers/glassicons.dart';

class InAppNotification extends DatabaseItem {
  dynamic lastUpdate;
  String? key;
  int? _type;
  String? title;
  String? content;

  String? senderKey;

  PageName? pageName;
  Map<String, dynamic>? argument;
  bool? forParentOtherMenu;

  InAppNotification({this.title, this.content, this.key, required NotificationType type, this.pageName, this.argument}) : _type = NotificationType.values.indexOf(type);

  InAppNotification.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['u'];
    _type = snapshot['t'] ?? 0;
    senderKey = snapshot['s'];
    pageName = snapshot['p'] == null ? null : PageName.values.firstWhereOrNull((element) => element.name == snapshot['p']);
    argument = snapshot['a'] is! Map ? null : Map<String, dynamic>.from(snapshot['a']);
    forParentOtherMenu = snapshot['fp'] ?? false;

    if (snapshot['enc'] != null) {
      final _decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;
      title = _decryptedData['x'];
      content = _decryptedData['c'];
    }
  }

  Map<String, dynamic> toJson(String key) {
    final data = <String, dynamic>{
      'u': lastUpdate,
      't': _type,
      's': senderKey,
      'p': pageName?.name,
      if (argument != null) 'a': argument,
      if (forParentOtherMenu != null) 'fp': forParentOtherMenu,
    };

    data['enc'] = {
      'x': title,
      'c': content,
    }.encrypt(key);

    return data;
  }

  set type(NotificationType value) => _type = NotificationType.values.indexOf(value);
  NotificationType get type => NotificationType.values[_type!];

  IconData get icon => type == NotificationType.appLastUsableTime
      ? Icons.payment
      : type == NotificationType.generally
          ? Icons.notifications
          : type == NotificationType.service
              ? Icons.bus_alert
              : type == NotificationType.payment
                  ? Icons.payment
                  : Icons.notifications;

  String? get assetImage => type == NotificationType.announcement || type == NotificationType.announcementUnPublish
      ? GlassIcons.announcementIcon.imgUrl
      : type == NotificationType.social || type == NotificationType.socialUnPublish
          ? GlassIcons.social.imgUrl
          : type == NotificationType.dailyreport
              ? GlassIcons.dailyReport.imgUrl
              : type == NotificationType.message
                  ? GlassIcons.messagesIcon.imgUrl
                  : (type == NotificationType.liveBroadCastNewEntry || type == NotificationType.liveBroadCastStarterPage)
                      ? GlassIcons.liveBroadcastIcon.imgUrl
                      : (type == NotificationType.videoChatReservationsPage || type == NotificationType.videoChatNewEntry)
                          ? GlassIcons.videoLesson.imgUrl
                          : type == NotificationType.stickers
                              ? GlassIcons.stickers.imgUrl
                              : type == NotificationType.medicine
                                  ? GlassIcons.medicine.imgUrl
                                  : type == NotificationType.homeWork
                                      ? GlassIcons.homework.imgUrl
                                      : type == NotificationType.examDateLesson
                                          ? GlassIcons.exam.imgUrl
                                          : type == NotificationType.prepareStudent
                                              ? Assets.images.pms1PNG
                                              : type == NotificationType.iamcame
                                                  ? Assets.images.pms2PNG
                                                  : null;

  // bool get notificationTypeMustManuelClear => type == NotificationType.generally || type == NotificationType.service;

  @override
  bool active() => true;
}

//? Sirasini bozma aradan silme
enum NotificationType {
  generally,
  service,
  payment,
  announcement,
  social,
  message,
  stickers,
  appLastUsableTime,
  dailyreport,
  medicine,
  timetable,
  //? Deneme sinavi sonucu
  examResult,
  p2p,
  liveBroadCastNewEntry,
  liveBroadCastStarterPage,
  videoChatNewEntry,
  videoChatReservationsPage,
  rollCall,
  examDateLesson,
  homeWork,
  appDemoTime,
  announcementUnPublish,
  socialUnPublish,
  prepareStudent,
  iamcame,
  preparedStudentOk,
}

enum PageName {
  //? StudentAccounting
  sA,

  //?  PortfolioMain
  pM,

  //? Medicine
  med,

  //? ELesson Lesson starter For Student
  eLS,

  //? Video Chat Make An Appointment For Student
  vCMA,

  //? Video Chat All Reservations For Student
  vCR,

  //? Etiket listesi
  S,

  //?  AnnouncementUnpublish
  uA,
  //?  SocialUnpublish
  uS,
}

class InAppNotificationArgument {
  //? Bildirimi gonderenin tokeni gelirse sadece o tokene geri bildirim atmak icin
  String token;

  InAppNotificationArgument.addTokenAndCheck({required this.token});

  InAppNotificationArgument.fromJson(Map snapshot) : token = snapshot['token'] ?? '';

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}
