part of '../dataservice.dart';

class CaseRecordService {
  CaseRecordService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database33 => AppVar.appBloc.database3;
  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE
  // Vaka kayitlari referansi
  static Reference dbGetAllCaseRecords() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/CaseRecords');

//! SETDATASERVICE
  static Future<void> saveCaseRecord(CaseRecordModel item) {
    item.lastUpdate = _realTime;
    return _database33.set('Okullar/$_kurumId/$_termKey/CaseRecords/${item.key}', item.toJson());
  }
}
