part of '../dataservice.dart';

class SurveyService {
  SurveyService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static Database get _database33 => AppVar.appBloc.database3;

//! GETDATASERVICE

//Anket Listesi Referansi
  static Reference dbSurveyList() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Surveys/Profiles');

  //Anket Referansi
  static Reference dbSurvey(String? key) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Surveys/Profiles/$key');

  //Doldurulan Orenci Anketi Referansi
  static Reference dbFilledSurvey(String? surveyKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Surveys/Datas/$surveyKey/$_uid');

//Data list olusturmak icin anket sonuclari Referansi
  static Reference dbSurveyDataList(String? surveyKey) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Surveys/Datas/$surveyKey');

//! SETDATASERVICE

  //Anket Ekler
  static Future<void> dbAddSurvey(surveyData, key) => _database33.set('Okullar/$_kurumId/$_termKey/Surveys/Profiles/$key', surveyData).then((_) {
        LogHelper.addLog('Survey', _uid);
      });

  //Anket Siler
  static Future<void> dbdeleteSurvey(key) => _database33.set('Okullar/$_kurumId/$_termKey/Surveys/Profiles/$key/aktif', false).then((_) {
        LogHelper.addLog('Survey', _uid);
      });

  //Velinin anketini  Kaydeder
  static Future<void> dbSaveSurvey(surveyKey, surveyData) => _database33.set('Okullar/$_kurumId/$_termKey/Surveys/Datas/$surveyKey/$_uid', surveyData);
}
