part of '../dataservice.dart';

class P2PService {
  P2PService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseProgramm => AppVar.appBloc.databaseProgram;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid!;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // P2P ders  Referansı
  static Reference dbGetP2PEvent(int week) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/P2P/Weeks/w_$week');

  // Ogrenci p2p isteklerini getirir
  static Reference dbGetStudentP2PRequest(String studentKey, String lessonKey, int week) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/P2P/SRequests/$studentKey/week$week/$lessonKey');
  //Tum ogrencilerin verilen haftadaki birebir isteklerini listeler
  static Reference dbGetWeekStudentRequest(int week) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/P2P/AllRequests/week$week');

  //Ogrencilerin ne kadar birebire kaydoldugu gibi loglari getirir
  static Reference dbGetp2pLogs() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/P2P/Logs1');

  // Basit birebir programi icin okul etut saatleri ve ogretmen kisitlamalarini ceker
  static Reference dgGetSimpleP2PSchoolDraft() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/SimpleP2p/SchoolDraft');

//! SETDATASERVICE

  static Future<void> setP2PEvent(int week, P2PModel data) {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesUserVersion = {};

    updates['/Okullar/$_kurumId/$_termKey/P2P/Weeks/w_$week/${data.key}'] = data.mapForSave();

    data.studentList!.forEach((studentKey) {
      updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/${data.key}'] = Portfolio(data.mapForStudentSave(), lastUpdate: _realTime, aktif: data.aktif != false, key: data.key, portfolioType: PortfolioType.p2p).mapForSave();
      updatesUserVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}'] = _realTime;

      //   updates['/Okullar/$_kurumId/$_termKey/P2P/Logs1/$studentKey/Events/${data.key}'] = {'s': data.aktif != false, 't': data.teacherKey, 'w': data.week, 'd': data.day, 'sT': data.startTime};
      updates['/Okullar/$_kurumId/$_termKey/P2P/Logs1/${data.key}$studentKey'] = (P2PLogs()
            ..aktif = data.aktif != false
            ..teacherKey = data.teacherKey
            ..studentKey = studentKey
            ..week = data.week
            ..day = data.day
            ..startTime = data.startTime
            ..lastUpdate = databaseTime)
          .toJson();
    });

    updates['/Okullar/$_kurumId/$_termKey/SPortfolio/${data.teacherKey}/${data.key}'] = Portfolio(data.mapForSave(), lastUpdate: _realTime, aktif: data.aktif != false, key: data.key, portfolioType: PortfolioType.p2p).mapForSave();
    updatesUserVersion['/Okullar/$_kurumId/$_termKey/${data.teacherKey}/${VersionListEnum.portfolio}'] = _realTime;
    return _databaseProgramm.update(updates).then((value) => _databaseVersionss.update(updatesUserVersion)).then((value) {
      if (data.aktif!) {
        EkolPushNotificationService.sendMultipleNotification(
          'p2pstudentnotify1'.translate,
          AppVar.appBloc.teacherService!.dataListItem(data.teacherKey!)!.name! + ' ' + McgFunctions.getDayNameFromDayOfWeek(data.day! + 1) + ' ' + data.startTime!.timeToString,
          data.studentList!,
          NotificationArgs(tag: 'portfolio'),
        );

        if (UserPermissionList.sendP2PNotificationToTehacer() == true) {
          var _studentName = AppVar.appBloc.studentService!.dataListItem(data.studentList!.first)!.name!;
          if (data.studentList!.length > 1) {
            _studentName += ' +${data.studentList!.length - 1} ${"person".translate}';
          }

          EkolPushNotificationService.sendSingleNotification(
            'p2pstudentnotify1'.translate,
            _studentName + ' ' + McgFunctions.getDayNameFromDayOfWeek(data.day! + 1) + ' ' + data.startTime!.timeToString,
            data.teacherKey!,
            NotificationArgs(tag: 'portfolio'),
          );
        }
      }
    });
  }

  static Future<void> setP2PRollCall1(Student student, P2PModel model, bool r) {
    Map<String, dynamic> updates = {};
    final studentKey = student.key;
    final p2pKey = model.key;

    // updates['/Okullar/$_kurumId/$_termKey/P2P/Logs1/$studentKey/Events/$key/r'] = r;
    updates['/Okullar/$_kurumId/$_termKey/P2P/Logs1/$p2pKey$studentKey/r'] = r;
    updates['/Okullar/$_kurumId/$_termKey/P2P/Logs1/$p2pKey$studentKey/lastUpdate'] = databaseTime;

    updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/$p2pKey/data/r'] = r;
    updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/$p2pKey/lastUpdate'] = databaseTime;

    return _databaseProgramm.update(updates).then((_) {
      if (r == false) {
        EkolPushNotificationService.sendSingleNotification(
          student.name!,
          'p2prollcall1'.argsTranslate({
            'time': model.startTime!.timeToString,
            'name': (AppVar.appBloc.teacherService!.dataListItem(model.teacherKey!)?.name ?? ''),
          }),
          studentKey!,
          NotificationArgs(tag: 'portfolio'),
        );
      }
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}', _realTime);
    });
  }

  static Future<void> setP2PStudentRequest(int week, String lessonKey, Map data) {
    Map<String, dynamic> updates = {};

    updates['/Okullar/$_kurumId/$_termKey/P2P/AllRequests/week$week/${_uid + "_" + lessonKey}'] = data;
    updates['/Okullar/$_kurumId/$_termKey/P2P/SRequests/$_uid/week$week/$lessonKey'] = data;

    return _databaseProgramm.update(updates);
  }

  // Basit birebir programi icin okul etut saatleri ve ogretmen kisitlamalarini kaydeder
  static Future<void> saveSimpleP2PSchoolDraft(Map? data) async {
    return _databaseProgramm.set('Okullar/$_kurumId/$_termKey/SimpleP2p/SchoolDraft', data).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.simpleP2PSchoolDraft}', _realTime);
    });
  }

  //? Simple birebir haftalik programa ogrenci kaydini ekler siler
  static Future<void> saveStudentInWeeklySimpleP2p(
    P2PSimpleWeekDataItem item,
    SimpeP2PDraftItem p2pDraftItem,
    int week,
    String? teacherKey,
    //? yeni kaydedilecekogrenci listesi. item icindeki eski ogrencilere zaten bildirim gittiginden yenileri gerekli
    List<String?> newStudentList,
    //? silinecek ogrenci listesi. item icindeki eski ogrencilere zaten bildirim gittiginden yenileri gerekli
    List<String?> removedStudentList,
  ) {
    return AppVar.appBloc.firestore
        .setItemInPkg(
      ReferenceService.simpleP2PWeekData() + '/week$week',
      'data',
      item.key,
      item.toJson(),
      addParentDocName: false,
    )
        .then((value) {
      Map<String, dynamic> updates = {};
      Map<String, dynamic> updatesUserVersion = {};

      [...newStudentList, ...removedStudentList].forEach((studentKey) {
        final _aktif = newStudentList.contains(studentKey);
        updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/${item.key}'] = Portfolio(item.mapForPortFolioSave(), lastUpdate: _realTime, aktif: _aktif, key: item.key, portfolioType: PortfolioType.p2p).mapForSave();
        updatesUserVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}'] = _realTime;

        updates['/Okullar/$_kurumId/$_termKey/P2P/Logs1/${item.key}$studentKey'] = (P2PLogs()
              ..aktif = _aktif
              ..teacherKey = item.teacherKey
              ..studentKey = studentKey
              ..week = item.week
              ..day = item.dayNo
              ..startTime = item.lessonStartTime
              ..lastUpdate = databaseTime)
            .toJson();
      });

      updates['/Okullar/$_kurumId/$_termKey/SPortfolio/${item.teacherKey}/${item.key}'] = Portfolio(item.mapForTeacherSave(), lastUpdate: _realTime, aktif: item.studentListData!.isNotEmpty, key: item.key, portfolioType: PortfolioType.p2p).mapForSave();
      updatesUserVersion['/Okullar/$_kurumId/$_termKey/${item.teacherKey}/${VersionListEnum.portfolio}'] = _realTime;

      _databaseProgramm.update(updates).then((value) => _databaseVersionss.update(updatesUserVersion)).then((value) {
        if (newStudentList.isNotEmpty) {
          EkolPushNotificationService.sendMultipleNotification(
            'p2pstudentnotify1'.translate,
            AppVar.appBloc.teacherService!.dataListItem(item.teacherKey)!.name! + ' ' + McgFunctions.getDayNameFromDayOfWeek(item.dayNo!) + ' ' + item.lessonStartTime!.timeToString,
            newStudentList,
            NotificationArgs(tag: 'portfolio'),
          );

          if (UserPermissionList.sendP2PNotificationToTehacer() == true) {
            var _studentName = AppVar.appBloc.studentService!.dataListItem(newStudentList.first!)!.name!;
            if (newStudentList.length > 1) {
              _studentName += ' +${newStudentList.length - 1} ${"person".translate}';
            }

            EkolPushNotificationService.sendSingleNotification(
              'p2pstudentnotify1'.translate,
              _studentName + ' ' + McgFunctions.getDayNameFromDayOfWeek(item.dayNo!) + ' ' + item.lessonStartTime!.timeToString,
              item.teacherKey,
              NotificationArgs(tag: 'portfolio'),
            );
          }
        }
      });
    });
  }

//? Simple birebir haftalik programina gelen itemi yazar
  //? Simple birebir haftalik programda herhangi bir dersin capacitysini yada baska bilgisini degistirmek icin kullanilabilir
  static Future<void> saveWeeklySimpleP2pItem(P2PSimpleWeekDataItem item, int week) {
    return AppVar.appBloc.firestore.setItemInPkg(
      ReferenceService.simpleP2PWeekData() + '/week$week',
      'data',
      item.key,
      item.toJson(),
      addParentDocName: false,
    );
  }
}
