import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../appbloc/databaseconfig.dart';

class QBGetDataService {
  QBGetDataService();

  //////BOOK SERVICE////////
  // Databasede kayıtlı olan tüm kitap listesini getirir.
  //Future<DataSnapshot> getBooks(DatabaseReference database) => database.child("Books").once();
  static Future<Snap?> getBooks(Database database) => database.once('Books');
  static Reference getBooksReference(Database database) => Reference(database, 'Books');

//  // Yayınlanmış kitapların içindekiler menusunu çeker
  // Future<DataSnapshot> getPublishedBookContents(DatabaseReference database, String bookKey) => database.child("KitapIndex").child(bookKey).once();
  static Future<Snap?> getPublishedBookContents(Database database, String bookKey) => database.once('KitapIndex/$bookKey');

// mail adresinde yad google adresinden giris yapmak icib kullanici verilerinni getirir
  // Future<DataSnapshot> getLoginData(String mail, String password) => AppVar.qbankBloc.databaseSB.child("Users").child('MailUsers').child(mail.replaceAll('.', ':')).child(password).once();
  static Future<Snap?> getLoginData(String mail, String? password) => AppVar.qbankBloc.databaseSBB.once('Users/MailUsers/${mail.replaceAll('.', ':')}/$password');

  //Future<DataSnapshot> getGoogleLoginData(String mail) => AppVar.qbankBloc.databaseSB.child("Users").child('GmailUsers').child(mail.replaceAll('.', ':')).once();
  static Future<Snap?> getGoogleLoginData(String mail) => AppVar.qbankBloc.databaseSBB.once('Users/GmailUsers/${mail.replaceAll('.', ':')}');

  // Kullanıcı kişisel bilgilerini çeker.
  //Future<DataSnapshot> getUserInfo(DatabaseReference database, String uid) => AppVar.qbankBloc.databaseSB.child("UserData").child(uid).once();
  static Future<Snap?> getUserInfo(Database database, String? uid) => AppVar.qbankBloc.databaseSBB.once('UserData/$uid');

  // Kitap satin alirkenki sonuclari takip etmek icin
  // DatabaseReference getBookPurchasedResult(DatabaseReference database, String uid, String bookKey) => AppVar.qbankBloc.databaseSB.child("UserData").child(uid).child('bookList').child(bookKey);
  static Reference getBookPurchasedResult(Database database, String uid, String bookKey) => Reference(AppVar.qbankBloc.databaseSBB, 'UserData/$uid/bookList/$bookKey');

  // Kullanicinin tum satin aldigi kitaplari getirir
  //DatabaseReference getBookPurchasedList(DatabaseReference database, String uid) => AppVar.qbankBloc.databaseSB.child("UserData").child(uid).child('bookList');
  static Reference getBookPurchasedList(Database database, String? uid) => Reference(AppVar.qbankBloc.databaseSBB, 'UserData/$uid/bookList');

  // Kullanicinin hangi uid ile marketten satin aldigini ceker guvenlik icin
  //DatabaseReference getPurchasedUid(String uid, String purchaseId) => AppVar.qbankBloc.databaseSB.child("PurchaseDatas").child('AppStoreData').child(purchaseId);
  static Reference getPurchasedUid(String uid, String purchaseId) => Reference(AppVar.qbankBloc.databaseSBB, 'PurchaseDatas/AppStoreData/$purchaseId');

  // Taslak kitapların içindekiler menusunu çeker
  // Future<DataSnapshot> getDraftBookContents(String bookKey) => FirebaseDatabase(databaseURL: "https://elseifsorubankasi.firebaseio.com").reference().child('TaslakKitapIndex').child(bookKey).once();
  static Future<Snap?> getDraftBookContents(String bookKey) => Database(databaseUrl: DatabaseStarter.databaseConfig.draftBooksUrl).once('TaslakKitapIndex/$bookKey');

  // Editorler için soruların girilirken sürekli yenilenmesi için testi sürekli çeker.
  //Stream<Event> streamTest(String bookKey, String testKey) => FirebaseDatabase(databaseURL: "https://elseifsorubankasi.firebaseio.com").reference().child("TaslakKitaplar").child(bookKey).child(testKey).onValue;
  static Stream<Snap?> streamTest(String bookKey, String? testKey) => Database(databaseUrl: DatabaseStarter.databaseConfig.draftBooksUrl).onValue("TaslakKitaplar/$bookKey/$testKey");

  // Firestoredan herhangi bir kişinin herhangi bir kitabı için istatistikleri getirir.
  //Future<DataSnapshot> getStudentBookStatistics(String bookKey, String uid) => AppVar.qbankBloc.databaseSB.child("UserData").child(uid).child("Statistics").child(bookKey).once();
  static Future<Snap?> getStudentBookStatistics(String bookKey, String? uid) => AppVar.qbankBloc.databaseSBB.once('UserData/$uid/Statistics/$bookKey');

  // Ekol icin testteki istatistiğini ogretmenlerin gorebilecegi sekilde ceker.
//  Future<DataSnapshot> getSchoolTestStatistics(String bookKey, String testKey, String kurumId) {
//    return AppVar.qbankBloc.databaseLogs.child('Okullar').child(kurumId).child('SchoolTestStatistics').child(bookKey).child(testKey).once();
//  }
  static Future<Snap?> getSchoolTestStatistics(String bookKey, String? testKey, String? kurumId) {
    return AppVar.qbankBloc.databaseLogss.once('Okullar/$kurumId/SchoolTestStatistics/$bookKey/$testKey');
  }

  static Future<Snap?> getUserDenemeStartTime(String bookKey, String denemeKey, String? uid) {
    return AppVar.qbankBloc.databaseSBB.once('OtherData/DenemeData/${(denemeKey + bookKey).toFirebaseSafeKey}/UserData/${uid.toFirebaseSafeKey}/startTime');
  }

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

// Editor dışındaki kullanıcılar için yayınlanmış testi çeker.
//  Future<Uint8List> dbGetTest(bookKey,testKey) => FirebaseStorage(storageBucket: 'gs://sorubankasi').ref().child('Books').child(bookKey).child(testKey).getData(10*1024*1024);

//  // Firestoredan herhangi bir kişinin herhangi bir kitabı için istatistikleri getirir.
//  //Future<DocumentSnapshot> getTestStatistics(Firestore firestore,String kurumID,String bookKey,String testKey) => Firestore.instance.collection("Okullar").document(kurumID).collection("Statistics").document("TestStatistics").collection(bookKey).document(testKey).get();
//

//
//  /////QUESTION PAGE SERVICE
//  // Soruların resimlerinin tekrar eden kısımları kısaltılmıştı.
//  String questionImageFullUrl(String miniUrl) => "https://firebasestorage.googleapis.com/v0/b/elseifsorubankasi.appspot.com/o/$miniUrl?alt=media";
//

//
//  /////LOGIN SERVICE//////
//  // Username ve Password ile kullanıcının sadece varlığını ve giriş türünü çeker.
//  Future<DataSnapshot> checkUser(DatabaseReference database,String username,String password,String kurumID) => database.child("Okullar").child(kurumID).child("CheckList").child(username+password).once();
//

//  ////MANAGER PAGE REFERENCE////
//  // Mini Yönetim Paneli için Sınıf Listesi
//  DatabaseReference dbClassListRef(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("Classes");
//
//  // Mini Yönetim Paneli için Öğretmen Listesi
//  DatabaseReference dbTeacherListRef(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("Teachers");
//
//  // Mini Yönetim Paneli için Manager Listesi
//  DatabaseReference dbManagerListRef(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("Managers");
//
//
//// Mini Yönetim Paneli için Öğrenci Listesi
//  DatabaseReference dbStudentListRef(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("Students");
//  // Şifre oluşturma kısmının karmaşıklığı yüzünden öğretmen ve öğrenci sayfaları buraya taşınamadı.
//
//
//  // TOKEN LİST REFERENCE
//  DatabaseReference dbTokenList(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("Tokens");
//
//////Announcement PAGE REFERENCE////
//  DatabaseReference dbAnnouncementsRef(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("Announcements");
//// DUyuruları çeker
//
//// School Version Referansı
//  DatabaseReference dbSchoolVersions(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("SchoolData").child("Versions");
//
//  // Okul bilgileri  Referansı
//  DatabaseReference dbSchoolInfoRef(DatabaseReference database,String kurumID) => database.child("Okullar").child(kurumID).child("KurumBilgileri");

}
