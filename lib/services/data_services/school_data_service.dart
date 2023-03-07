part of '../dataservice.dart';

class SchoolDataService {
  SchoolDataService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static dynamic get _realTime => databaseTime;
  static Database get _database11 => AppVar.appBloc.database1;

//! GETDATASERVICE
  //Okul bilgilerinin son versiyon numarasini ceker
  //Reference dbLastSchoolInfoVersion(String serverId) => Reference(database11, '${StringHelper.schools}/$serverId/SchoolData/Versions/SchoolInfo');
// Dönem listesini çeker
  static Reference dbTermsRef() => Reference(_database11, '${StringHelper.schools}/$_kurumId/SchoolData/Terms');

  // School Version Referansı
  static Reference dbSchoolVersions([serverId]) => Reference(_database11, '${StringHelper.schools}/${serverId ?? _kurumId}/SchoolData/Versions');

  // Öğretmen izinlerini çeker
  static Reference dbPermissionRef() => Reference(_database11, 'Okullar/$_kurumId/SchoolData/Permissions');

  // Okul bilgileri  Referansı
  static Reference dbSchoolInfoRef([schoolId]) => Reference(_database11, 'Okullar/${schoolId ?? _kurumId}/SchoolData/Info');
  static Reference dbSchoolInfoForManagerRef([schoolId]) => Reference(_database11, 'Okullar/${schoolId ?? _kurumId}/SchoolData/InfoForManager');

//Okulun telefon rehberi
  static Reference dbAdressBook() => Reference(_database11, 'Okullar/$_kurumId/SchoolData/AdressBook');

//! SETDATASERVICE

  static Future<void> dbChangeActiveTerm(String termKey) async {
    Map<String, dynamic> updates = {};
    updates['/${StringHelper.schools}/$_kurumId/SchoolData/Info/activeTerm'] = termKey;
    updates['/${StringHelper.schools}/$_kurumId/SchoolData/Terms/$termKey/aT'] = databaseTime;
    updates['/${StringHelper.schools}/$_kurumId/SchoolData/Versions/${VersionListEnum.schoolInfo}'] = _realTime;
    return _database11.update(updates);
  }

  static Future<void> dbAddTerm(Map termData) => _database11.set('${StringHelper.schools}/$_kurumId/SchoolData/Terms/${termData['name']}/', termData);

  static Future<void> dbDeleteTerm(String termKey) => _database11.set('${StringHelper.schools}/$_kurumId/SchoolData/Terms/$termKey/aktif', false);

  // İzinleri Kaydeder
  static Future<void> savePermissions(Map permissionData) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Permissions'] = permissionData;
    updates['/Okullar/$_kurumId/SchoolData/Versions/Permissions'] = _realTime;
    return _database11.update(updates);
  }

  // Okul bilgilerini kaydeder. Gelen mapta name: okul adı, logourl:okul logosu;sloagan: okul slogani
  static Future<void> saveSchoolInfo(Map data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/name'] = data["name"];
    updates['/Okullar/$_kurumId/SchoolData/Info/logoUrl'] = data["logoUrl"];
    updates['/Okullar/$_kurumId/SchoolData/Info/slogan'] = data["slogan"];
    updates['/Okullar/$_kurumId/SchoolData/Info/et'] = data["et"];
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  // Okula alt donem bilgilerini kaydeder
  static Future<void> saveSchoolSubTerm(String termKey, List<SubTermModel> data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/sTL/$termKey'] = data.map((e) => e.toJson()).toList();
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  // Mutlucell gibi sms configleri kaydeder
  static Future<void> saveSmsConfig(SmSConfig data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/smsConfig'] = data.toJsonString();
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  // Okul widgetlarini duzenler
  static Future<void> saveWidgetsSchoolInfo(Map data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/widgetList'] = data;
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  // Okul bilgilerine ogretmen brans tiplerini ekler
  static Future<void> saveBranchNames(List<String> data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/branchList'] = data;
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  //Okul iletisim bilgisi Ekler
  static Future<void> dbSetAdressBook(adressData) => _database11.set('Okullar/$_kurumId/SchoolData/AdressBook', adressData);

  //Aktif dönemi değiştirir
  static Future<void> setClassTypes(Map classTypes) async {
    Map<String, dynamic> updates = {};
    updates['/${StringHelper.schools}/$_kurumId/SchoolData/Info/classTypes'] = classTypes;
    updates['/${StringHelper.schools}/$_kurumId/SchoolData/Versions/${VersionListEnum.schoolInfo}'] = _realTime;
    return _database11.update(updates);
  }

// InfoManagerForSave icin genel kaydedici
  static Future<void> schoolInfoForManagerSaver(String key, dynamic info) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/InfoForManager/$key'] = info;
    updates['/Okullar/$_kurumId/SchoolData/Versions/${VersionListEnum.schoolInfoForManager}'] = _realTime;
    return _database11.update(updates);
  }
}
