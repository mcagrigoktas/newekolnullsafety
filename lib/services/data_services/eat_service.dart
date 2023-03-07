part of '../dataservice.dart';

class EatService {
  EatService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database33 => AppVar.appBloc.database3;
  static Database get _database11 => AppVar.appBloc.database1;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Yemek Listesi  Referansı
  static Reference dbEatList() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Eat/EatList');

  // Günün Yemek Listesi  Referansı
  static Reference dbDayEatList(String day) => Reference(_database33, 'Okullar/$_kurumId/$_termKey/Eat/DayEats/$day');

//! SETDATASERVICE

// Yenek Listesi yemek ekleme
  static Future<void> dbAddEat(String yemekAdi) => _database33.set('Okullar/$_kurumId/$_termKey/Eat/EatList/$yemekAdi', true);

  // Yenek Listesi yemek silme
  static Future<void> dbDeleteEat(String yemekAdi) => _database33.set('Okullar/$_kurumId/$_termKey/Eat/EatList/$yemekAdi', false);

  //Günün Yemeklerinin Değiştirir
  static Future<void> dbSetDayEats(String day, List<String> yemekListesi) => _database33.set('Okullar/$_kurumId/$_termKey/Eat/DayEats/$day', yemekListesi);

  // Okul bilgilerini yemek url si veya dosya urlsini kaydeder
  static Future<void> saveEatData(String? url) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/em'] = url;
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }
}
