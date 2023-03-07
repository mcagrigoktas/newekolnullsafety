import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../flavors/mainhelper.dart';
import '../../flavors/themelist/helper.dart';
import '../../helpers/glassicons.dart';
import '../../models/accountdata.dart';
import '../models/models.dart';
import '../qbankbloc/getdataservice.dart';
import '../qbankbloc/qbankbloc.dart';
import 'bookpreviewspage/bookpreviewspage.dart';
import 'bookpreviewspage/statisticspage.dart';

class DeferredEkolQBankPage extends StatefulWidget {
  final bool forMiniScreen;
  DeferredEkolQBankPage({this.forMiniScreen = false});

  @override
  _DeferredEkolQBankPageState createState() => _DeferredEkolQBankPageState();
}

class _DeferredEkolQBankPageState extends State<DeferredEkolQBankPage> {
  void _sonKullanilanlaraEkle(Kitap kitap) {
    Map lastBookList = jsonDecode(Fav.preferences.getString("lastBookList", {}.toString())!);
    lastBookList[kitap.bookKey] = DateTime.now().millisecondsSinceEpoch;
    Fav.preferences.setString("lastBookList", json.encode(lastBookList));
  }

  void _openBook(Kitap book, IcindekilerModel kitapIcindekilerMenusu) {
    if (AppVar.appBloc.hesapBilgileri.girisTuru == 40) {
      Fav.to(StatisticsPage(kitap: book, icindekilerData: kitapIcindekilerMenusu));
      return;
    }

    _sonKullanilanlaraEkle(book);

    QBankHesapBilgileri qBankHesapBilgileri = QBankHesapBilgileri()
      ..name = AppVar.appBloc.hesapBilgileri.name
      ..ekolUid = AppVar.appBloc.hesapBilgileri.uid
      ..uid = AppVar.appBloc.hesapBilgileri.qbankUid
      ..schoolType = AppVar.appBloc.hesapBilgileri.schoolType
      ..girisYapildi = true
      ..girisTuru = AppVar.appBloc.hesapBilgileri.girisTuru
      ..username = AppVar.appBloc.hesapBilgileri.username
      ..password = AppVar.appBloc.hesapBilgileri.password
      ..imgUrl = AppVar.appBloc.hesapBilgileri.imgUrl
      ..purchasedList = purchasedList
      ..kurumID = AppVar.appBloc.hesapBilgileri.kurumID;

    // Fav.preferences.setString("qbankHesapBilgileri", qBankHesapBilgileri.toString());
    qBankHesapBilgileri.savePreferences();

    if (isWeb) {
      Fav.preferences.setString('qbankThemeV2', ThemeListModel.qbankLightKey);
    } else if (Fav.design.brightness == Brightness.dark) {
      Fav.preferences.setString('qbankThemeV2', ThemeListModel.qbankLightKey);
    } else {
      Fav.preferences.setString('qbankThemeV2', ThemeListModel.qbankDarkKey);
    }
    final QbankAppBloc qbankBloc = QbankAppBloc(isEkol: true);
    Get.put<QbankAppBloc>(qbankBloc);
    qbankBloc.init();
    //  AppVar.qbankTheme = qbankBloc.theme;
    Fav.to(Theme(
        data: ThemeData(
          brightness: Fav.secondaryDesign.brightness,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Fav.secondaryDesign.primary,
        ),
        child: BooksPreviewPage(icindekilerModel: kitapIcindekilerMenusu, kitap: book)));
  }

  void _buyBook(Kitap book) {
    OverAlert.show(type: AlertType.danger, message: 'soonpossiblebuy'.translate);
    return;
//todo burada odeme islemini yaptir ve kontrol et

//   //   setState(() {isLoading=true;});
//    List<String> purchasedList = AppVar.appBloc.prefs.getStringList('ekolQbankPurchasedList') ?? [];
//      purchasedList.add(book.bookKey);
//    AppVar.appBloc.prefs.setStringList('ekolQbankPurchasedList',purchasedList);
//      QBSetDataService.buyBook(AppVar.appBloc.hesapBilgileri.qbankUid, book.bookKey, {'isFree':true}).then((_){
//     //   setState(() {isLoading=false;});
//
//      OverAlert.show(message:   'buybooksuc'),closeButton: true);
//        Get.back();
//
//      }).catchError((_){
//      // setState(() {isLoading=false;});
//      //OverAlert.show(message:   'buybookerr'),type: AlertType.danger);
//      });
//
  }

  Future<void> _checkContentAndOpenBook(Kitap book) async {
    List<String>? purchasedList = Fav.preferences.getStringList('ekolQbankPurchasedList', []);

    if (book.priceStatus == BookPriceStatus.PAID && !purchasedList!.contains(book.bookKey)) {
      _buyBook(book);
      return;
    }

    // İççindekiler değişince kitap versiyonu değiştrmeuyi yaz
    final kitapIcindekilerMenusu = await Fav.securePreferences.getHiveMap("${book.bookKey}_Icindekiler" + AppConst.preferenecesBoxVersion.toString());

    final bool sonVersiyonKayitlimi = (Fav.preferences.getString("${book.bookKey}_Icindekiler_version") ?? "") == book.versionRelease;

    if (kitapIcindekilerMenusu.isNotEmpty && sonVersiyonKayitlimi) {
      _openBook(book, IcindekilerModel.fromJson(kitapIcindekilerMenusu));
    } else {
      if (Fav.noConnection()) return;

      OverLoading.show();

      await QBGetDataService.getPublishedBookContents(AppVar.appBloc.databaseSB, book.bookKey).then((snapshot) async {
        await OverLoading.close();
        if (snapshot?.value == null) {
          OverAlert.show(type: AlertType.danger, message: 'nopublish'.translate);
          return;
        }
        await Fav.securePreferences.setHiveMap("${book.bookKey}_Icindekiler" + AppConst.preferenecesBoxVersion.toString(), snapshot!.value, clearExistingData: true);
        await Fav.preferences.setString("${book.bookKey}_Icindekiler_version", book.versionRelease!);
        _openBook(book, IcindekilerModel.fromJson(snapshot.value));
      }).catchError((_) async {
        await OverLoading.close();
      });
    }
  }

  List<Kitap> _bookList = [];
  List<PurchasedBookData>? purchasedList;
  @override
  void initState() {
    _setUpBookList();
//todo buraya satin alinanlar eklenmeli
    purchasedList = [];
    super.initState();
  }

  void _setUpBookList() {
    _bookList = AppVar.appBloc.bookService!.dataList;
    _bookList.removeWhere((book) {
      if (book.status != "50") return true;
      if (book.privacy.contains(AppVar.appBloc.hesapBilgileri.kurumID)) return false;

      return true;
    });
    final Map? lastBookList = jsonDecode(Fav.preferences.getString("lastBookList") ?? {}.toString());

    if (AppVar.appBloc.hesapBilgileri.girisTuru! > 25) {
      String? classLevel = AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == AppVar.appBloc.hesapBilgileri.class0)?.classLevel;
      _bookList.removeWhere((book) {
        if (classLevel == '0' || classLevel == null) return false;

        if (classLevel == book.seviye) return false;

        return true;
      });
    }

    _bookList.sort((a, b) {
      if ((lastBookList![a.bookKey] ?? 0) != (lastBookList[b.bookKey] ?? 0)) {
        if ((lastBookList[a.bookKey] ?? 0) - (lastBookList[b.bookKey] ?? 0) > 0) {
          return -1;
        } else {
          return 1;
        }
      }
      return a.name1!.toLowerCase().compareTo(b.name1!.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    Body _body;

    if (_bookList.isEmpty) {
      _body = Body.child(
          child: EmptyState(
        text: 'nopurchasedbook'.translate,
        emptyStateWidget: EmptyStateWidget.NORECORDS,
      ));
    } else {
      var _seviyeMap = <String?, List<Kitap>?>{};

      _bookList.forEach((kitap) {
        if (_seviyeMap.containsKey(kitap.className2)) {
          _seviyeMap[kitap.className2] = _seviyeMap[kitap.className2]!..add(kitap);
        } else {
          _seviyeMap[kitap.className2] = [kitap];
        }
      });
      final double _width = ((context.screenWidth - 32) / 2).clamp(0.0, 150.0) - 1;
      _body = AppVar.appBloc.hesapBilgileri.gtMT
          ? Body.singleChildScrollView(
              child: Column(
                  children: _seviyeMap.keys.map((itemKey) {
                var _books = _seviyeMap[itemKey]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    8.heightBox,
                    Text(itemKey!, style: TextStyle(color: Fav.design.primaryText, fontSize: 24.0, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 295,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final book = _books[index];

                          return BookWidget(
                            width: _width,
                            book: book,
                            onTap: _checkContentAndOpenBook,
                          );
                        },
                        itemCount: _books.length,
                      ),
                    ),
                  ],
                );
              }).toList()),
            )
          : Body.singleChildScrollView(
              maxWidth: 720,
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                alignment: WrapAlignment.center,
                children: _bookList
                    .map((book) => BookWidget(
                          width: _width,
                          book: book,
                          onTap: _checkContentAndOpenBook,
                        ))
                    .toList(),
              ),
            );
    }

    return AppScaffold(
      isFullScreenWidget: widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
      topBar: TopBar(
        leadingTitle: 'menu1'.translate,
        hideBackButton: !widget.forMiniScreen,
      ),
      topActions: TopActionsTitle(
        title: 'mybooks'.translate,
        imgUrl: GlassIcons.books2.imgUrl,
        color: GlassIcons.books2.color,
      ),
      body: _body,
    );
  }
}

class BookWidget extends StatelessWidget {
  final Function(Kitap) onTap;
  final Kitap book;
  final double? width;
  BookWidget({required this.onTap, required this.book, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: <Widget>[
          4.heightBox,
          InkWell(
            onTap: () {
              onTap(book);
            },
            child: Card(
              elevation: 4.0,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), image: DecorationImage(image: CacheHelper.imageProvider(imgUrl: book.imgUrl!), fit: BoxFit.fill)),
                width: width,
                height: width! * 1.42,
              ),
            ),
          ),
          4.heightBox,
          Text(
            book.name1!,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(color: Fav.design.primaryText.withAlpha(200), fontSize: 15.0),
          ),
          4.heightBox,
          Text(
            book.priceStatus == BookPriceStatus.FREE || book.priceStatus == BookPriceStatus.FREE_TO_INSTUTION ? 'freebook'.translate : book.price.toString(),
            style: TextStyle(color: Fav.design.primaryText, fontSize: 14.0, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
