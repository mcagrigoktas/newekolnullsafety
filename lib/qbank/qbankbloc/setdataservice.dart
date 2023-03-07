import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/stringhelper.dart';

class QBSetDataService {
  QBSetDataService();

  //  Mail Adresi ilen kullnaici kaydeder
//  Future saveUserForMail(String mail, String password, Map userData) {
//    Map<String, dynamic> updates =    {};
//    updates['/Users/MailUsers/${mail.replaceAll('.', ':')}'] = {password: userData};
//    updates['/Users/GmailUsers/${mail.replaceAll('.', ':')}'] = userData;
//    return AppVar.qbankBloc.databaseSB.update(updates);
//  }
  static Future saveUserForMail(String mail, String password, Map userData) {
    Map<String, dynamic> updates = {};
    updates['/Users/MailUsers/${mail.replaceAll('.', ':')}'] = {password: userData};
    updates['/Users/GmailUsers/${mail.replaceAll('.', ':')}'] = userData;
    return AppVar.qbankBloc.databaseSBB.update(updates);
  }

  //Gris yapan kullnaicinin cihaz bilgisini kaydeder
//  Future addLoginDevice(String mail, String password, List devicdData) {
//    Map<String, dynamic> updates =    {};
//    updates['/Users/MailUsers/${mail.replaceAll('.', ':')}/$password/deviceList'] = devicdData;
//    updates['/Users/GmailUsers/${mail.replaceAll('.', ':')}/deviceList'] = devicdData;
//    return AppVar.qbankBloc.databaseSB.update(updates).catchError(print);
//  }
  static Future addLoginDevice(String mail, String password, List devicdData) {
    Map<String, dynamic> updates = {};
    updates['/Users/MailUsers/${mail.replaceAll('.', ':')}/$password/deviceList'] = devicdData;
    updates['/Users/GmailUsers/${mail.replaceAll('.', ':')}/deviceList'] = devicdData;
    return AppVar.qbankBloc.databaseSBB.update(updates);
  }

  // Kullanıcıların isim ve resimlerinin bilgilerini değiştirebilmesini sağlar
//  Future<void> setProfieInfo(String uid, String imageUrl, String name) async {
//    Map<String, dynamic> updates =    {};
//    updates['/UserData/$uid/imgUrl'] = imageUrl;
//    updates['/UserData/$uid/name'] = name;
//
//    return AppVar.qbankBloc.databaseSB.update(updates);
//  }
  static Future<void> setProfieInfo(String uid, String? imageUrl, String? name) async {
    Map<String, dynamic> updates = {};
    updates['/UserData/$uid/imgUrl'] = imageUrl;
    updates['/UserData/$uid/name'] = name;

    return AppVar.qbankBloc.databaseSBB.update(updates);
  }

  // Kullanıcıların fatura bilgilerini kaydeder
//  Future<void> saveInoviceData(Map data, String uid) async {
//    Map<String, dynamic> updates =    {};
//    updates['/UserData/$uid/invoiceData'] = data;
//    return AppVar.qbankBloc.databaseSB.update(updates);
//  }
  static Future<void> saveInoviceData(Map data, String uid) async {
    Map<String, dynamic> updates = {};
    updates['/UserData/$uid/invoiceData'] = data;
    return AppVar.qbankBloc.databaseSBB.update(updates);
  }

//  Future<void> buyBook(String uid, String bookKey, Map buyData, {trimpurchaseId}) async {
//    Map<String, dynamic> updates =    {};
//    updates['/UserData/$uid/bookList/$bookKey'] = buyData;
//    if (trimpurchaseId != null) {
//      updates['/PurchaseDatas/AppStoreData/$trimpurchaseId'] = uid;
//    }
//    updates['/PurchaseDatas/InvoiceData/$uid' + 'mcagri' + bookKey] = buyData;
//    return AppVar.qbankBloc.databaseSB.update(updates);
//  }
  static Future<void> buyBook(String uid, String bookKey, Map buyData, {trimpurchaseId}) async {
    Map<String, dynamic> updates = {};
    updates['/UserData/${uid.toFirebaseSafeKey}/bookList/$bookKey'] = buyData;
    if (trimpurchaseId != null) {
      updates['/PurchaseDatas/AppStoreData/$trimpurchaseId'] = uid;
    }
    updates['/PurchaseDatas/InvoiceData/${uid.toFirebaseSafeKey}' + 'mcagri' + bookKey] = buyData;
    return AppVar.qbankBloc.databaseSBB.update(updates);
  }

  // Öğrencinin testteki istatistiğini kaydeder.
//  Future sendStudentStatistics(Map statisticsData, String bookKey, String testKey, String uid) {
//    // todo kurum id yide kaydetmen lazim
//    return AppVar.qbankBloc.databaseSB.child('UserData').child(uid.toFirebaseSafeKey).child('Statistics').child(bookKey).child(testKey).push().set(statisticsData);
//    //  Map<String, dynamic> updates =    {};
//    //   updates['/UserData/$uid/Statistics/$bookKey/$testKey/$key'] = statisticsData;
//    //   return AppVar.qbankBloc.databaseSB.update(updates);
//  }
  static Future sendStudentStatistics(Map statisticsData, String bookKey, String testKey, String uid) {
    // todo kurum id yide kaydetmen lazim
    return AppVar.qbankBloc.databaseSBB.push('UserData/${uid.toFirebaseSafeKey}/Statistics/$bookKey/$testKey', statisticsData);
    //  Map<String, dynamic> updates =    {};
    //   updates['/UserData/$uid/Statistics/$bookKey/$testKey/$key'] = statisticsData;
    //   return AppVar.qbankBloc.databaseSB.update(updates);
  }

  static Future sendDenemeStatistics(Map statisticsData, String bookKey, String denemeKey, String uid) {
    return AppVar.qbankBloc.databaseSBB.set('OtherData/DenemeData/${(denemeKey + bookKey).toFirebaseSafeKey}/UserData/${uid.toFirebaseSafeKey}/userAnswers', statisticsData);
  }

  static Future sendUserDenemeStartTime(int time, String bookKey, String denemeKey, String uid) {
    return AppVar.qbankBloc.databaseSBB.set('OtherData/DenemeData/${(denemeKey + bookKey).toFirebaseSafeKey}/UserData/${uid.toFirebaseSafeKey}/startTime', time);
  }

  // Ekol icin testteki istatistiğini ogretmenlerin gorebilecegi sekilde kaydeder kaydeder.
//  Future sendSchoolTestStatistics(Map statisticsData, String bookKey, String testKey, String kurumId, String uid) {
//    return AppVar.qbankBloc.databaseLogs.child('${StringHelper.schools}').child(kurumId).child('SchoolTestStatistics').child(bookKey).child(testKey).child(uid).set(statisticsData);
//  }
  static Future sendSchoolTestStatistics(Map statisticsData, String bookKey, String testKey, String kurumId, String uid) {
    return AppVar.qbankBloc.databaseLogss.set('${StringHelper.schools}/$kurumId/SchoolTestStatistics/$bookKey/$testKey/$uid', statisticsData);
  }
}
