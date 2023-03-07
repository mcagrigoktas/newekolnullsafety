part of '../dataservice.dart';

class TeacherService {
  TeacherService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _database11 => AppVar.appBloc.database1;
  static dynamic get _realTime => databaseTime;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

//! GETDATASERVICE
  // Öğretmen Listesi Referansı
  static Reference dbTeacherListRef() => Reference(_database11, 'Okullar/$_kurumId/$_termKey/Teachers');

  // Tek bir ogretmen Referansı
  static Reference dbTeacherRef(String key, String termKey) => Reference(_database11, 'Okullar/$_kurumId/$termKey/Teachers/$key');

//! SETDATASERVICE
// Öğretmen Kaydeder
  static Future<void> saveTeacher(Teacher teacher, String teacherKey) async {
    Map checkListValues = {};
    checkListValues["GirisTuru"] = 20;
    checkListValues["UID"] = teacherKey;

    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Teachers/' + teacherKey] = teacher.mapForSave(teacherKey)..['lastUpdate'] = _realTime;
    updates['/Okullar/$_kurumId/CheckList/' + teacher.username! + teacher.password!] = checkListValues;

    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Teachers'] = _realTime;
    return _database11.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$teacherKey/${VersionListEnum.userInfoChangeService}', _realTime);
      makeBundle();
    });
  }

  // Ogretmen Import sirasindaKaydeder
  static Future<void> saveMultipleTeacher(List<Teacher> itemList) async {
    Map<String, dynamic> _updates = {};

    itemList.forEach((teacher) {
      Map checkListValues = {};
      checkListValues["GirisTuru"] = 20;
      checkListValues["UID"] = teacher.key;

      _updates['/Okullar/$_kurumId/$_termKey/Teachers/' + teacher.key!] = teacher.mapForSave(teacher.key!)..['lastUpdate'] = _realTime;
      _updates['/Okullar/$_kurumId/CheckList/' + teacher.username! + teacher.password!] = checkListValues;
    });

    _updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Teachers'] = _realTime;

    return _database11.update(_updates).then((value) {
      makeBundle();
    });
  }

// Öğretmen Siler
  static Future<void> deleteTeacher(String existingKey, {bool recover = false}) async {
    Map<String, dynamic> _updates = {};
    _updates['/Okullar/$_kurumId/$_termKey/Teachers/' + existingKey + "/aktif"] = recover;
    _updates['/Okullar/$_kurumId/$_termKey/Teachers/' + existingKey + "/lastUpdate"] = _realTime;
    _updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Teachers'] = _realTime;
    return _database11.update(_updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$existingKey/${VersionListEnum.userInfoChangeService}', _realTime);
    });
  }

  static Future<void> makeBundle() async {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;
    return () {
      AppVar.appBloc.teacherService?.makeBundle();
    }.delay(1500);
  }
}
