part of '../dataservice.dart';

class PreRegisterService {
  PreRegisterService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;

//! GETDATASERVICE

// Öğrenci On Kayit Listesi Referansı
  static Reference dbPreRegisterListRef() => Reference(_database11, 'Okullar/$_kurumId/$_termKey/PreRegister');

//! SETDATASERVICE

// Öğrenci On Kayit Kaydeder
  static Future<void> savePreRegister(Map studentData, String? existingKey) async {
    return _database11.set('Okullar/$_kurumId/$_termKey/PreRegister/$existingKey', studentData);
  }

  // Öğrenci On Kayit Statusunu Degistirir
  static Future<void> changePreRegisterStatus(String? existingKey, int status) async {
    return _database11.set('Okullar/$_kurumId/$_termKey/PreRegister/$existingKey/status', status);
  }
}
