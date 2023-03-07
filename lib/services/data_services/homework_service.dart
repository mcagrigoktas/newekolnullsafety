part of '../dataservice.dart';

class HomeWorkService {
  HomeWorkService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _databaseProgram => AppVar.appBloc.databaseProgram;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  //Ogrencinin  ve Ogretmenin odev listesini ceker. key geliyorsa idareci birine bakiyordur
  static Reference dbUserHomeWorkRef([key]) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/${key ?? _uid}');

  //Ogretmen icin odev kontrol bilgilerini ceker
  static Reference dbHomeWorkCheckData(String? homeworkKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/LessonDetail/HomeWorkDatas/$homeworkKey');

  //Idareci yayinlanmamis odevleri ceker
  static Reference dbIsNotPublishedHomeWork(String? classKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/LessonDetail/Datas/$classKey');

//Odev qr codes
  static Reference dbGetHomeworkDataFromQRData(String qrCode) => Reference(_databaseLogss, 'QRCodes/$qrCode');

//! SETDATASERVICE

  // Ogretmen odev ekler. Ayrica ogretmenin direk paylasma yetkisi yoksa idareci onay kisminada ekler.
  // Ogretmenlerinde hanesine kendi paylasimlari yaziliyor. Ayrica isterse tum datalardan anliz yaptirilabilir
  static Future<void> saveHomeWork(Map homeWorkData, bool teacherHomeWorkSharing, String? classKey, String? lessonKey, List<String?> contactList, String? teacherKey) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesUserVersion = {};
    final String key = 6.makeKey;

    contactList.forEach((studentUid) {
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$studentUid/$key'] = homeWorkData;
      if (teacherHomeWorkSharing) {
        updatesUserVersion['/Okullar/$_kurumId/$_termKey/$studentUid/${VersionListEnum.homeWork}'] = _realTime;
      }
    });
    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/Datas/$classKey/$key'] = homeWorkData;
    updatesUserVersion['/Okullar/$_kurumId/$_termKey/$teacherKey/${VersionListEnum.homeWork}'] = _realTime;
    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$teacherKey/$key'] = homeWorkData;
    return _database33.update(updates).then((_) {
      if (updatesUserVersion.keys.isNotEmpty) {
        _databaseVersionss.update(updatesUserVersion);
        LogHelper.addLog('HomeWork', teacherKey);
      }
    });
  }

// Odevi siler
  static Future<void> deleteHomeWork(String? existingKey, String? classKey, String? lessonKey, List<String?> contactList, String? teacherKey) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesUserVersion = {};

    contactList.forEach((uid) {
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$uid/$existingKey/aktif'] = false;
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$uid/$existingKey/timeStamp'] = _realTime;
      updatesUserVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.homeWork}'] = _realTime;
    });

    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$teacherKey/$existingKey/aktif'] = false;
    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$teacherKey/$existingKey/timeStamp'] = _realTime;
    updatesUserVersion['/Okullar/$_kurumId/$_termKey/$teacherKey/${VersionListEnum.homeWork}'] = _realTime;

    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/Datas/$classKey/$existingKey/aktif'] = false;

    return _database33.update(updates).then((_) {
      if (updatesUserVersion.keys.isNotEmpty) {
        _databaseVersionss.update(updatesUserVersion);
      }
    });
  }

// Odevi yayinlar
  static Future<void> publishHomeWork(String? existingKey, String? classKey, String? lessonKey, List<String?> contactList, String? teacherKey) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesUserVersion = {};

    contactList.forEach((uid) {
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$uid/$existingKey/isPublish'] = true;
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$uid/$existingKey/timeStamp'] = _realTime;
      updatesUserVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.homeWork}'] = _realTime;
    });

    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$teacherKey/$existingKey/isPublish'] = true;
    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$teacherKey/$existingKey/timeStamp'] = _realTime;
    updatesUserVersion['/Okullar/$_kurumId/$_termKey/$teacherKey/${VersionListEnum.homeWork}'] = _realTime;

    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/Datas/$classKey/$existingKey/isPublish'] = true;

    return _database33.update(updates).then((_) {
      if (updatesUserVersion.keys.isNotEmpty) {
        _databaseVersionss.update(updatesUserVersion);
      }
    });
  }

  // Odev Kontrol bilgilerini girer
  static Future<void> addCheckHomeWorkData(HomeWork homeWork, Map homeWorkData) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesUserVersion = {};
    Map<String, dynamic> updatesProgram = {};

    updates['/Okullar/$_kurumId/$_termKey/LessonDetail/HomeWorkDatas/${homeWork.key}'] = homeWorkData;
    (homeWorkData['studentData'] as Map).entries.forEach((item) {
      final uid = item.key;
      final _homeWorkData = HomeWorkCheck(
        noteText: item.value.toString() + '-t:' + homeWorkData['checktype'].toString(),
        title: homeWork.title,
        lessonKey: homeWork.lessonKey,
        content: homeWork.content,
        tur: homeWork.tur,
        date: homeWork.checkDate,
      );
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$uid/${homeWork.key}/checkNote'] = item.value.toString() + '-t:' + homeWorkData['checktype'].toString();
      updates['/Okullar/$_kurumId/$_termKey/LessonDetail/UserDatas/$uid/${homeWork.key}/timeStamp'] = _realTime;
      updatesProgram['/Okullar/$_kurumId/$_termKey/SPortfolio/$uid/${"HWC_" + homeWork.key!}'] = Portfolio(_homeWorkData.toJson(), lastUpdate: _realTime, aktif: true, key: "HWC_" + homeWork.key!, portfolioType: homeWork.tur == 1 ? PortfolioType.homeworkCheck : PortfolioType.examCheck).mapForSave();

      updatesUserVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.homeWork}'] = _realTime;
      updatesUserVersion['/Okullar/$_kurumId/$_termKey/$uid/${VersionListEnum.portfolio}'] = _realTime;
    });

    return Future.wait([
      _database33.update(updates),
      _databaseProgram.update(updatesProgram),
    ]).then((_) {
      if (updatesUserVersion.keys.isNotEmpty) {
        _databaseVersionss.update(updatesUserVersion);
      }
    });
  }
}
