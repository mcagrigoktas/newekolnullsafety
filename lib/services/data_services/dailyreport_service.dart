part of '../dataservice.dart';

class DailyReportService {
  DailyReportService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Günlük Profilleri Referansı
  static Reference dbDailyReportProfilesRef() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/DailyReports/Profiles');

  // Öğrencinin günlük karnetsini getirme  Referansı
  static Reference dbStudentDailyReports(String day, String studentKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/DailyReports/Datas/$studentKey/$day');

  // Öğrencinin son 5 günlük karnetsini getirme  Referansı
  static Reference dbStudent5DailyReports() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/DailyReports/Datas/$_uid');

  // Seçilen gün için gönderilen günlük karne öğrenci listesi  Referansı
  static Reference dbSendingDaliyReportStudentList(String day) => Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/DailyReportLogs/$day');

//! SETDATASERVICE

  //,Günlük karneye defaulat değerleri yazar
  static Future<void> dbSetDailyReport(String className, data) => _database33.set('Okullar/$_kurumId/$_termKey/DailyReports/Profiles/$className', data).then((_) {
        _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.dailyReportProfiles}', _realTime);
      });

  //Ogrencinin gunluk karnesini kaydeder

  static Future<void> dbSetStudentDailyReport(String studentKey, String day, Map data) => _database33.set('Okullar/$_kurumId/$_termKey/DailyReports/Datas/$studentKey/$day', data).then((_) {
        if (data['aktif']['value'] == '1') {
          LogHelper.addLog('DailyReports', _uid);
          EkolPushNotificationService.sendSingleNotification('hi'.translate, 'dailypushnotifycontent'.translate, studentKey, NotificationArgs(tag: 'dailyreport'));
          _databaseLogss.set('Okullar/$_kurumId/$_termKey/DailyReportLogs/$day/$studentKey', true);
          _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.dailyReport}', _realTime);
        }
      });
}
