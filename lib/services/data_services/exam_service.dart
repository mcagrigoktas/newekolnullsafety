part of '../dataservice.dart';

class ExamService {
  ExamService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _databaseProgramm => AppVar.appBloc.databaseProgram;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid!;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  //Ollcme degerlendirme sinavtiplerini  ceker
  static Reference dbGetAllExamType() => Reference(_databaseLogss, 'EvaulationData/ExamTypes');
  static Reference dbGetSchoolExamTypes([String? termKey]) => Reference(_databaseLogss, 'Okullar/$_kurumId/${termKey ?? _termKey}/ExamTypes');

  //Ollcme degerlendirme opticformlari  ceker
  static Reference dbGetAdminOpticFormType() => Reference(_databaseLogss, 'EvaulationData/OpticFormTypes');
  static Reference dbGetSchoollOpticFormType([String? termKey]) => Reference(_databaseLogss, 'Okullar/$_kurumId/${termKey ?? _termKey}/OpticFormTypes');

  //Kazanim listesini ceker
  static Reference dbSchoollEarningItemList() => Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/EarningList');
  static Reference dbGlobalEarningItemList(String superManagerKurumId) => Reference(_databaseLogss, 'SuperManagers/$superManagerKurumId/EarningList');

  //Okullar yaptigi sinavlari listeler
  static Reference dbGetSchoolExams() => Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/Exams');
  //Gnel mudurluklerin denemelerini  listeler
  static Reference dbGetGlobalExams() => Reference(_databaseLogss, 'EvaulationData/Exams');

  //Incelemek icin ogrencilerin online sinav cevaplarini ceker
  static Reference dbGetOnlineExamAllStudentAnswer(String examKey) => Reference(_databaseLogss, 'OnlineExamLogs/$examKey/StudentAnswers');

//! SETDATASERVICE

  static Future<void> sendExamResultInPortfollio(Map<String?, Map> data, String examKey, String notificationContent) {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesUserVersion = {};
    List<String?> keyList = [];
    data.forEach((studentKey, studentsDataMap) {
      keyList.add(studentKey);
      updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/$examKey'] = Portfolio(studentsDataMap, lastUpdate: _realTime, aktif: true, key: examKey, portfolioType: PortfolioType.examreport).mapForSave();
      updatesUserVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}'] = _realTime;
    });

    return _databaseProgramm.update(updates, groupLength: 500).then((value) => _databaseVersionss.update(updatesUserVersion)).then((value) => EkolPushNotificationService.sendMultipleNotification('examresultnotify'.translate, notificationContent, keyList, NotificationArgs(tag: 'portfolio')));

    // return _databaseProgramm.update(updates, groupLength: 500).then((value) => _databaseVersionss.update(updatesUserVersion)).then((value) {
    //   return InAppNotificationService.sendSameInAppNotificationMultipleTarget(
    //       InAppNotification(
    //         title: 'examresultnotify'.translate,
    //         content: notificationContent,
    //         type: NotificationType.exam,
    //         key: 'ER_$examKey',
    //         pageName: PageName.sERIP,
    //       ),
    //       keyList,
    //       notificationTag: PageName.sERIP.name);
    // });
  }

  //Olcme degerlendirme Sinav tipi ekler
  static Future<void> saveAdminExamType(Map data, String key) => _databaseLogss.set('EvaulationData/ExamTypes/$key', data);
  static Future<void> saveSchoolExamType(Map data, String key) => _databaseLogss.set('Okullar/$_kurumId/$_termKey/ExamTypes/$key', data);

  //Olcme degerlendirme OpticFormekler
  static Future<void> saveAdminOpticForm(Map data, String key) => _databaseLogss.set('EvaulationData/OpticFormTypes/$key', data);
  static Future<void> saveSchoolOpticForm(Map data, String key) => _databaseLogss.set('Okullar/$_kurumId/$_termKey/OpticFormTypes/$key', data);

  //Okullar  yeni sinav ekler
  static Future<void> saveSchoollExam(Map data, String key) => _databaseLogss.set('Okullar/$_kurumId/$_termKey/Exams/$key', data);
  static Future<void> saveGlobalExams(Map data, String key) => _databaseLogss.set('EvaulationData/Exams/$key', data);

  //Kazanim listesini duzenler
  static Future<void> saveSchoollEarningItem(EarningItem item) => _databaseLogss.set('Okullar/$_kurumId/$_termKey/EarningList/${item.key}', (item..lastUpdate = databaseTime).toJson());
  static Future<void> saveGlobalEarningItem(EarningItem item, String? superManagerKurumId) => _databaseLogss.set('SuperManagers/$superManagerKurumId/EarningList/${item.key}', (item..lastUpdate = databaseTime).toJson());

  //sinavlarin cevap anahtari ve kazanim listesini kaydeder
  static Future<void> saveSchoolExamAnswerEarningData(Map data, String examKey) {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Exams/$examKey/answerEarningData'] = data;
    updates['/Okullar/$_kurumId/$_termKey/Exams/$examKey/lastUpdate'] = _realTime;
    return _databaseLogss.update(updates);
  }

  //Genel mudurluk sayfasindan sinavlarin cevap anahtari ve kazanim listesini kaydeder
  static Future<void> saveGlobalExamAnswerEarningData(Map data, String examKey) {
    Map<String, dynamic> updates = {};
    updates['/EvaulationData/Exams/$examKey/answerEarningData'] = data;
    updates['/EvaulationData/Exams/$examKey/lastUpdate'] = _realTime;
    return _databaseLogss.update(updates);
  }

//Ogrencilerin onlline sinavlarda cevapllarini gonderir
  static Future<void> saveOnlineExamStudentsAnswer(String examKey, Map data, String seisonName) {
    Map<String, dynamic> updates = {};
    updates['/OnlineExamLogs/$examKey/StudentAnswers/$_kurumId/$seisonName/$_uid/answerData'] = data;
    return _databaseLogss.update(updates);
  }
}
