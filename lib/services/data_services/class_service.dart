part of '../dataservice.dart';

class ClassService {
  ClassService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static Database get _database11 => AppVar.appBloc.database1;
  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE
// Sınıf Listesi Referansı
  static Reference dbClassListRef() => Reference(_database11, 'Okullar/$_kurumId/$_termKey/Classes');

//! SETDATASERVICE
// Sınıf Kaydeder
  static Future<void> saveClass(Class sinif, String existingKey) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Classes/' + existingKey] = sinif.mapForSave(existingKey)..['lastUpdate'] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Classes'] = _realTime;
    return _database11.update(updates).then((value) {
      makeBundle();
    });
  }

//Sinif Listesini kaydeder
  static Future<void> saveMultipleClass(List<Class> itemList) async {
    Map<String, dynamic> updates = {};

    itemList.forEach((sinif) {
      updates['/Okullar/$_kurumId/$_termKey/Classes/' + sinif.key!] = sinif.mapForSave(sinif.key)..['lastUpdate'] = _realTime;
    });

    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Classes'] = _realTime;

    return _database11.update(updates).then((value) {
      makeBundle();
    });
  }

// Sınıf Siler
  static Future<void> deleteClass(String existingKey, {bool recover = false}) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Classes/' + existingKey + "/aktif"] = recover;
    updates['/Okullar/$_kurumId/$_termKey/Classes/' + existingKey + "/lastUpdate"] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Classes'] = _realTime;
    return _database11.update(updates);
  }

  static Future<void> makeBundle() async {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;
    return () {
      AppVar.appBloc.classService?.makeBundle();
    }.delay(1500);
  }
}
