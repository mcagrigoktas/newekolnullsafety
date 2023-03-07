part of '../dataservice.dart';

class VideoChatService {
  VideoChatService._();

  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static dynamic get _realTime => databaseTime;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

//! GETDATASERVICE

//Herhangi bir ogretmene ait video ders programini ceker
  static Reference dbGetTeacherVideoLessons(String? teacherKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/VideoLesson/UserData/$teacherKey');

  //Herhangi bir ogrenciye ait video ders programini ceker
  static Reference dbGetStudentVideoLessons() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/VideoLesson/UserData/$_uid');

  //Herhangi bir tarihten sonra aktif okan video derskerini ceker
  static Reference dbGetallActiveVideoLesson() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/VideoLesson/Profiles');

  //Herhangi bir keye ait video ders programini ceker
  static Reference dbGetVideoLessonProgram(String? itemKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/$itemKey');

//! SETDATASERVICE

  static Future<void> saveVideoLesson(VideoLessonProgramModel item) async {
    Map<String, dynamic> updates = {};

    final lessonData = item.mapForSave();
    String key = _database33.pushKey('Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${item.teacherKey}');
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${item.teacherKey}/$key'] = Map.from(lessonData)..remove('lessons');
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/$key'] = lessonData;

    return _database33.update(updates).then((_) {
      InAppNotificationService.sendSameInAppNotificationMultipleTarget(
          InAppNotification(
            key: 'VCN${item.lessonName.removeNonEnglishCharacter}',
            title: item.lessonName,
            content: 'videolessonaddednotify'.translate,
            type: NotificationType.videoChatNewEntry,
            argument: {'t': item.teacherKey},
            pageName: PageName.vCMA,
          ),
          [
            ...item.targetList!,
            if (AppVar.appBloc.hesapBilgileri.gtM) item.teacherKey!,
          ],
          notificationTag: 'videolesson',
          targetListContainsAllUserOrClassList: true,
          allUserKeyMeanAllStudent: true);
      //  EkolPushNotificationService.sendMultipleNotification(item.lessonName, 'videolessonaddednotify'.translate, item.targetList, tag: 'videolesson');
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/${item.teacherKey}/${VersionListEnum.videoLessonService}', _realTime);
    });
  }

  //Ogrenci video dersi rezervasyonu yapar
  static Future<void> saveReserveLesson(String programKey, int lessonNo, Map studentReserveData) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/$programKey/lessons/${lessonNo.toString()}/studentKey'] = _uid;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/$programKey/lessons/${lessonNo.toString()}/state'] = 1;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/$programKey/timeStamp'] = _realTime;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/$_uid/${programKey + lessonNo.toString()}'] = studentReserveData..['timeStamp'] = _realTime;

    return _database33.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$_uid/${VersionListEnum.videoLessonService}', _realTime);
    });
  }

  //Ogretmen video dersi rezervasyonu yapar
  static Future<void> saveTeacherReserveLesson(VideoLessonProgramModel program, int lessonNo, Map studentReserveData, studentKey) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/lessons/${lessonNo.toString()}/studentKey'] = studentKey;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/lessons/${lessonNo.toString()}/state'] = 1;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/timeStamp'] = _realTime;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/$studentKey/${program.key! + lessonNo.toString()}'] = studentReserveData..['timeStamp'] = _realTime;

    return _database33.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.videoLessonService}', _realTime);

      InAppNotificationService.sendInAppNotification(
          InAppNotification(
            title: program.lessonName,
            content: program.startTime!.dateFormat("d-MMMM-yyyy") + ' / ' + 'addteachervideolessonnotifiy'.translate,
            key: 'VCN${program.lessonName.removeNonEnglishCharacter}',
            pageName: PageName.vCR,
            type: NotificationType.videoChatReservationsPage,
          ),
          studentKey,
          notificationTag: 'videlesson');

      // EkolPushNotificationService.sendSingleNotification(
      //   program.lessonName,
      //   program.startTime.dateFormat("d-MMMM-yyyy") + ' / ' + 'addteachervideolessonnotifiy'.translate,
      //   studentKey,
      //   tag: 'videlesson',
      // );
    });
  }

//Ogrenci veya ogretmen video dersi rezervasyonu  iptal eder
  static Future<void> cancelReserveLesson(VideoLessonProgramModel program, int lessonNo, [studentKey]) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/lessons/${lessonNo.toString()}/studentKey'] = null;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/lessons/${lessonNo.toString()}/state'] = 0;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/timeStamp'] = _realTime;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${studentKey ?? _uid}/${program.key! + lessonNo.toString()}/aktif'] = false;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${studentKey ?? _uid}/${program.key! + lessonNo.toString()}/timeStamp'] = _realTime;

    return _database33.update(updates).then((_) {
      if (studentKey != null) {
        InAppNotificationService.sendInAppNotification(
            InAppNotification(
              title: program.lessonName,
              content: program.startTime!.dateFormat("d-MMMM-yyyy") + ' / ' + 'cancelvideolessonnotifiy'.translate,
              key: 'VCN${program.lessonName.removeNonEnglishCharacter}C',
              pageName: PageName.vCR,
              type: NotificationType.videoChatReservationsPage,
            ),
            studentKey,
            notificationTag: 'videlesson');
        //  EkolPushNotificationService.sendSingleNotification(program.lessonName, program.startTime.dateFormat("d-MMMM-yyyy") + ' / ' + 'cancelvideolessonnotifiy'.translate, studentKey, tag: 'videolesson');
      }
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/${studentKey ?? _uid}/${VersionListEnum.videoLessonService}', _realTime);
    });
  }

// VideoLessonProgramini Siler
  static Future<void> deleteVideoLessonProgram(VideoLessonProgramModel program) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesVersion = {};
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/aktif'] = false;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/Profiles/${program.key}/timeStamp'] = _realTime;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${program.teacherKey}/${program.key}/aktif'] = false;
    updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${program.teacherKey}/${program.key}/timeStamp'] = _realTime;
    updatesVersion['/Okullar/$_kurumId/$_termKey/${program.teacherKey}/${VersionListEnum.videoLessonService}'] = _realTime;
    List<String> studentKeys = [];
    for (var i = 0; i < program.lessons.length; i++) {
      if (program.lessons[i].studentKey != null) {
        studentKeys.add(program.lessons[i].studentKey!);
        updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${program.lessons[i].studentKey}/${program.key! + i.toString()}/aktif'] = false;
        updates['/Okullar/$_kurumId/$_termKey/VideoLesson/UserData/${program.lessons[i].studentKey}/${program.key! + i.toString()}/timeStamp'] = _realTime;
        updatesVersion['/Okullar/$_kurumId/$_termKey/${program.lessons[i].studentKey}/${VersionListEnum.videoLessonService}'] = _realTime;
      }
    }

    return _database33.update(updates).then((_) {
      InAppNotificationService.sendSameInAppNotificationMultipleTarget(
          InAppNotification(
            title: program.lessonName,
            content: program.startTime!.dateFormat("d-MMMM-yyyy") + ' / ' + 'cancelvideolessonnotifiy'.translate,
            key: 'VCN${program.lessonName.removeNonEnglishCharacter}C',
            pageName: PageName.vCR,
            type: NotificationType.videoChatReservationsPage,
          ),
          studentKeys,
          notificationTag: 'videlesson');

      //   EkolPushNotificationService.sendMultipleNotification(program.lessonName, program.startTime.dateFormat("d-MMMM-yyyy") + ' / ' + 'cancelvideolessonnotifiy'.translate, studentKeys, tag: 'videolesson');
      _databaseVersionss.update(updatesVersion);
    });
  }
}
