part of '../dataservice.dart';

class ManagerService {
  ManagerService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Manager Listesi Referansı
  static Reference dbManagerListRef() => Reference(_database11, '${StringHelper.schools}/$_kurumId/Managers');

//! SETDATASERVICE

  // Manager Kaydeder
  static Future<void> saveManager(Manager manager, String? existingKey) async {
    String? key = existingKey;
    key ??= _database11.pushKey('Okullar/$_kurumId/Managers');

    Map checkListValues = {};
    checkListValues["GirisTuru"] = 10;
    checkListValues["UID"] = key;

    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/Managers/' + key] = manager.mapForSave(key)..['lastUpdate'] = _realTime;
    updates['/Okullar/$_kurumId/CheckList/' + manager.username! + manager.password!] = checkListValues;
    updates['/Okullar/$_kurumId/SchoolData/Versions/Managers'] = _realTime;
    return _database11.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$key/${VersionListEnum.userInfoChangeService}', _realTime);
      makeBundle();
    });
  }

// Manager Siler
  static Future<void> deleteManager(String existingKey) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/Managers/' + existingKey + "/aktif"] = false;
    updates['/Okullar/$_kurumId/Managers/' + existingKey + "/lastUpdate"] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/Managers'] = _realTime;
    return _database11.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$existingKey/${VersionListEnum.userInfoChangeService}', _realTime);
    });
  }

  static Future<void> makeBundle() async {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;
    return () {
      AppVar.appBloc.managerService?.makeBundle();
    }.delay(1500);
  }
}
