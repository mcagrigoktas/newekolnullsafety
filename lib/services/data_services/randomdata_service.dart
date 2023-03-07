part of '../dataservice.dart';

class RandomDataService {
  RandomDataService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;

  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

//! GETDATASERVICE
  static Reference dbGetRandomLog(String logKey) => Reference(_databaseLogss, 'Okullar/$_kurumId/$_termKey/SchoolRandomLogs/$logKey');

//! SETDATASERVICE
  static Future<void> setRandomLog(String logKey, dynamic value) {
    return _databaseLogss.set('Okullar/$_kurumId/$_termKey/SchoolRandomLogs/$logKey', value);
  }
}
