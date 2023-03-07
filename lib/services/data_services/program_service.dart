part of '../dataservice.dart';

class ProgramService {
  ProgramService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseProgramm => AppVar.appBloc.databaseProgram;
  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  //Ders programi icin gunluk ders saatlerini ceker
  static Reference dbGetTimes() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/Times');

  //Herhangi bir ogretmenin calisma saatrlerini ceker
  static Reference dbGetTeacherWorkTimes(String teacherKey) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/TeacherHours/$teacherKey');

  //Butun ogretmenlerin calisma saatlerini ceker
  static Reference dbGetAllTeacherWorkTimes() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/TeacherHours');

  //Herhangi bir sinifin calisma saatrlerini ceker
  static Reference dbGetClassActiveTimes(String classKey) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/ClassHours/$classKey');

  //Butun siniflarin calisma saatlerini ceker
  static Reference dbGetAllClassActiveTimes() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/ClassHours');

  //Taslak Ders Programini ceker
  static Reference dbGetTimetableProgram(String draftName) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/TimeTables/Drafts/$draftName');

  //Aktif ders porgramini ceker
  static Reference dbGetActiveTimeTable() => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/TimeTables/Published');

//! SETDATASERVICE

// Okul calisma saatlerini kaydeder

  static Future<void> saveTimes(Map timesData) async {
    return _databaseProgramm.push('Okullar/$_kurumId/$_termKey/Times', timesData).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.times}', _realTime);
    });
  }

  // Ogretmenlerin calisma saatlerini kaydeder
  static Future<void> saveTeacherWorkTimes(Map timesData, String teacherKey) async {
    return _databaseProgramm.set('Okullar/$_kurumId/$_termKey/TeacherHours/$teacherKey', timesData).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.teacherClassHours}', _realTime);
    });
  }

  // herhangi bir sinifin aktif saatlerini kaydeder
  static Future<void> saveClassActiveTimes(Map timesData, String classKey) async {
    return _databaseProgramm.set('Okullar/$_kurumId/$_termKey/ClassHours/$classKey', timesData).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.teacherClassHours}', _realTime);
    });
  }

  // Programi taslak olarak kaydeder
  static Future<void> saveTimetableProgram(Map? timetableData, String draftName) async {
    return _databaseProgramm.set('Okullar/$_kurumId/$_termKey/TimeTables/Drafts/$draftName', timetableData);
  }

  // Ders Programini paylasir
  static Future<void> shareTimetableProgram(Map timetableData) async {
    return _databaseProgramm.push('Okullar/$_kurumId/$_termKey/TimeTables/Published', timetableData).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.timeTable}', _realTime);
    });
  }
}
