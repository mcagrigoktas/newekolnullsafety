part of '../dataservice.dart';

class PortfolioService {
  PortfolioService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _databaseProgramm => AppVar.appBloc.databaseProgram;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE
  // Portfolyo Referansı
  static Reference dbPortfolio(String userKey) => Reference(_databaseProgramm, 'Okullar/$_kurumId/$_termKey/SPortfolio/$userKey');

//! SETDATASERVICE
//PortfollyoKayeder
  static Future<void> savePortfolyo(Map data, String studentKey, String existingKey) {
    return _databaseProgramm.set('Okullar/$_kurumId/$_termKey/SPortfolio/$studentKey/$existingKey', data).then((value) => _databaseVersionss.set('/Okullar/$_kurumId/$_termKey/$studentKey/${VersionListEnum.portfolio}', _realTime));
  }
}
