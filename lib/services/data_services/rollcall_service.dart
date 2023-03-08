part of '../dataservice.dart';

class RollCallService {
  RollCallService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _databaseProgramm => AppVar.appBloc.databaseProgram;
  static dynamic get _realTime => databaseTime;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

//! GETDATASERVICE

//Gunu sinifi ve dersi belli olan yoklama listesini ceker
  static Reference dbGetEkolRollCall(String dateKey, String classKey, String lessonNo) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/RollCall/$dateKey/$classKey/$lessonNo');

  //DatabaseReference dbGetEkidRollCall(String dateKey, String classKey) => databaseProgram.child("Okullar").child(kurumId).child(termKey).child('EkidRollCall').child(dateKey).child(classKey);
  static Reference dbGetEkidRollCall(String dateKey, String classKey) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/EkidRollCall/$dateKey/$classKey');

  //Ogrencinin yoklama bilgilerini ceker idareci ogrenci keyi yolllamli
  static Reference dbEkolStudentGetRollCall([studentKey]) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/StudentRollCall/${studentKey ?? _uid}');
  static Reference dbEkolAllStudentGetRollCall() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/StudentRollCall');

  // DatabaseReference dbEkidStudentGetRollCall([studentKey]) => databaseProgram.child("Okullar").child(kurumId).child(termKey).child('EkidStudentRollCall').child(studentKey ?? uid);
  static Reference dbEkidStudentGetRollCall([studentKey]) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/EkidStudentRollCall/${studentKey ?? _uid}');

  //Idareci herhangi bir gunun gelmeyenlerini ceker
  static Reference dbGetRollCallDay(String dateKey) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/RollCall/$dateKey');

  //Kurum icin tum servis datalari referansi
  static Reference dbAllServiceRollCallData() => Reference(_databaseLogss, '${StringHelper.schools}/$_kurumId/$_termKey/ServiceLogs/TimeBasedRC');

//! SETDATASERVICE

  // Yoklamayi idareci icin kaydeder. 2. liste gelen ogrencileride icermez
  static Future<void> addEkolRollCall(String dateKey, String classKey, int? lessonNo, String lessonNameNo, Map data, /*Map data2,*/ Map<String, RollCallStudentModel> studentData) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesStudentVersion = {};
    updates['/Okullar/$_kurumId/$_termKey/RollCall/$dateKey/$classKey/$lessonNameNo'] = data;
    // updates['/Okullar/$kurumId/$termKey/RollCall2/$dateKey/$classKey/$lessonNameNo' ] = data2;
    studentData.forEach((studentKey, value) {
      updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/${"PRC_" + dateKey + 'LN:' + lessonNo.toString()}'] = Portfolio(value.toJson(), lastUpdate: _realTime, aktif: true, key: dateKey + 'LN:' + lessonNo.toString(), portfolioType: PortfolioType.rollcall).mapForSave();
      updates['/Okullar/$_kurumId/$_termKey/StudentRollCall/$studentKey/${dateKey + 'LN:' + lessonNo.toString()}'] = (value..lastUpdate = _realTime).toJson();
      updatesStudentVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.rollCall}'] = _realTime;
      updatesStudentVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}'] = _realTime;
    });

    return _databaseProgramm.update(updates).then((_) {
      _databaseVersionss.update(updatesStudentVersion);

      LogHelper.addLog('RollCall', _uid);
    });
  }

  static Future<void> addEkidRollCall(String dateKey, String classKey, Map data, Map<String?, RollCallStudentModel> studentData) async {
    Map<String, dynamic> updates = {};
    Map<String, dynamic> updatesStudentVersion = {};
    updates['/Okullar/$_kurumId/$_termKey/EkidRollCall/$dateKey/$classKey'] = data;

    studentData.forEach((studentKey, value) {
      updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/${"PRC_" + dateKey}'] = Portfolio(value.toJson(), lastUpdate: _realTime, aktif: true, key: dateKey, portfolioType: PortfolioType.rollcall).mapForSave();
      updates['/Okullar/$_kurumId/$_termKey/EkidStudentRollCall/$studentKey/$dateKey'] = (value..lastUpdate = _realTime).toJson();
      updatesStudentVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.rollCall}'] = _realTime;
      updatesStudentVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}'] = _realTime;
    });

    return _databaseProgramm.update(updates).then((_) {
      _databaseVersionss.update(updatesStudentVersion);
      LogHelper.addLog('RollCall', _uid);
    });
  }

  // Idareci yoklamalarda ogrencilerin gelip gelmedigini degistirebilir
  static Future<void> changeStudnetRollCall(String dateKey, String classKey, int? lessonNo, String lessonNameNo, String studentKey, value) async {
    final _rollCallData = RollCallStudentModel(
      lessonKey: lessonNameNo.split('LN:').first,
      classKey: classKey,
      value: value,
      date: DateTime.now().millisecondsSinceEpoch,
      lessonNo: lessonNo,
      lessonName: AppVar.appBloc.lessonService!.dataListItem(lessonNameNo.split('LN:').first)?.name ?? '',
      isEkid: false,
      key: dateKey + 'LN:' + lessonNo.toString(),
    );

    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/RollCall/$dateKey/$classKey/$lessonNameNo/$studentKey'] = value;
    updates['/Okullar/$_kurumId/$_termKey/StudentRollCall/$studentKey/${dateKey + 'LN:' + lessonNo.toString()}'] = (_rollCallData..lastUpdate = _realTime).toJson();
    updates['/Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/${"PRC_" + dateKey}'] = Portfolio(_rollCallData.toJson(), lastUpdate: _realTime, aktif: true, key: dateKey, portfolioType: PortfolioType.rollcall).mapForSave();

    return _databaseProgramm.update(updates).then((_) {
      Map<String, dynamic> updatesStudentVersion = {};
      updatesStudentVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.rollCall}'] = _realTime;
      updatesStudentVersion['/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}'] = _realTime;
      _databaseVersionss.update(updatesStudentVersion);
    });
  }
}
