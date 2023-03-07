part of '../dataservice.dart';

class UserInfoService {
  UserInfoService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;
  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;
  static Database get _database11 => AppVar.appBloc.database1;

//! GETDATASERVICE

  // Personal Version Referansı
  static Reference dbPersonalVersions() => Reference(_databaseVersionss, '${StringHelper.schools}/$_kurumId/$_termKey/$_uid');

  //Kurumun tum kullanim bilgilerini ceker
  static Reference dbUsageInfo([serverId, term]) => Reference(_databaseLogss, 'Okullar/${serverId ?? _kurumId}/${term ?? _termKey}/UsageLogs');

// Kullanıcı kişisel bilgilerini çeker. girisTuruKey(Manager,Students,Teachers,Editors listesine bakar)
  static Reference dbGetUserInfo(String serverId, String girisTuruKey, String userId, String? term) {
    if (girisTuruKey == "Managers") return Reference(_database11, '${StringHelper.schools}/$serverId/$girisTuruKey/$userId');
    return Reference(_database11, '${StringHelper.schools}/$serverId/$term/$girisTuruKey/$userId');
  }

//! SETDATASERVICE

}
