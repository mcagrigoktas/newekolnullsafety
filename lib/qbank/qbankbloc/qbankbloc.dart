import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/databaseconfig.dart';
import '../../flavors/appconfig.dart';
import '../../flavors/themelist/helper.dart';
import '../../models/accountdata.dart';
import '../models/models.dart';
import 'getdataservice.dart';

class QbankAppBloc extends Object {
  final QBankHesapBilgileri hesapBilgileri = QBankHesapBilgileri();
  AppConfig get appConfig => Get.find<AppConfig>();

  final Database databaseSBB = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbSB);
  final Database databaseLogss = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbLogs);
  MiniFetcher<Kitap>? bookListFecther;

  String packageName = '';

  List<Kitap> get getKitapListesi => makeFilteredBookList(bookListFecther!.dataList);
  Map<String, String> bookPriceCache = {};
  final bool isEkol;

  //List<Kitap> _kitapListesi = [];

  QbankAppBloc({this.isEkol = false});

  void init() {
    hesapBilgileri.setHesapBilgileri();

    ThemeHelper.setQbankTheme();

    if (!isEkol) {
      kitapListesiniHazirla();
      bookPriceCache = Map<String, String>.from(Fav.preferences.getString('bookPriceCache') == null ? {} : json.decode(Fav.preferences.getString('bookPriceCache')!));
    }
  }

  List<Kitap> makeFilteredBookList(List<Kitap> kitapListesi) {
    kitapListesi.removeWhere((kitap) => kitap.seviye == '1000'); //kitap depo da

    kitapListesi.removeWhere((kitap) => kitap.status == '100'); //kitap silinmis ise

    //  _kitapListesi.removeWhere((kitap)=>kitap.status!='50' && !hesapBilgileri.gtE);//kitap ogrenci icin yayinda degilse

    kitapListesi.removeWhere((kitap) => !hesapBilgileri.isQbank && !kitap.privacy.contains(hesapBilgileri.kurumID) && !kitap.privacy.contains('MARKET22474')); //kitap ekol icin okula acik degilse

    kitapListesi.removeWhere((kitap) => hesapBilgileri.isQbank && !kitap.privacy2.contains(packageName) && !hesapBilgileri.gtE); //kitap apk ya tanimli degilse

    kitapListesi.removeWhere((kitap) => hesapBilgileri.isQbank && hesapBilgileri.gtE2 && kitap.editorPrivacy != hesapBilgileri.uid); //kitap apk ya tanimli degilse

    return kitapListesi;
  }

  void kitapListesiniHazirla() {
    PackagaManager.getPackageName().then((value) {
      packageName = value;
    });

    bookListFecther = MiniFetcher<Kitap>('qbankSecAllBookList', FetchType.LISTEN,
        multipleData: true,
        jsonParse: (key, value) => Kitap.fromJson(value, key),
        lastUpdateKey: 'lastUpdate',
        sortFunction: (Kitap i1, Kitap i2) => i2.lastUpdate - i1.lastUpdate,
        removeFunction: (a) => a.name1 == null || a.status == null,
        queryRef: QBGetDataService.getBooksReference(databaseSBB),
        filterDeletedData: true,
        getValueAfter: (_) async {
          await initializeBookPriceCache();
        },
        getValueAfterOnlyDatabaseQuery: (value) {});
  }

  late InAppPurchase _iap;
  Future<void> initializeBookPriceCache() async {
    _iap = InAppPurchase.instance;
    bool _available = await _iap.isAvailable();

    if (_available && !kIsWeb) {
      Set<String> ids = Set.from(getKitapListesi.map((e) => e.priceCode.trim()).toList()..removeWhere((element) => element.safeLength < 3));

      if (ids.isEmpty) return;

      ///todo timebloc haline getir
      bool delayTimeFinish = DateTime.now().millisecondsSinceEpoch - Fav.preferences.getInt('bookPriceCacheDelay', 0)! > const Duration(minutes: 30).inMilliseconds;
      if (!delayTimeFinish) return;

      ProductDetailsResponse response = await _iap.queryProductDetails(ids);

      if (response.error == null && response.productDetails.isEmpty == false) {
        bookPriceCache = {};
        response.productDetails.forEach((element) {
          bookPriceCache[element.id] = element.price;
        });
        Fav.preferences.setString('bookPriceCache', json.encode(bookPriceCache)).unawaited;
        Fav.preferences.setInt('bookPriceCacheDelay', DateTime.now().millisecondsSinceEpoch).unawaited;
        bookListFecther?.refresh.add(true);
      }
    }
  }

  void signOut() {
    hesapBilgileri.removePreferences();
    Fav.preferences.clear();
    hesapBilgileri.reset();

    appConfig.qbankRestartApp!(true);
  }

  Future<void> dispose() async {
    // _kitapListesiYenile.close();
    //   await MiniFetchers.unregisterAllFetcher();
    await bookListFecther?.dispose();
  }
}
