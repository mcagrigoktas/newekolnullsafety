import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/mainhelper.dart';
import '../../models/models.dart';
import '../../qbankbloc/getdataservice.dart';
import '../bookpreview/purchasepage/purchasehelper.dart';
import '../bookpreviewspage/bookpreviewspage.dart';

class MyBooks extends StatelessWidget with PurchaseHelper {
  @override
  Widget build(BuildContext context) {
    if (AppVar.qbankBloc.hesapBilgileri.girisYapildi != true) {
      return MyQBankScaffold(
        hasScaffold: false,
        appBar: MyQBankAppBar(title: 'mybooks'.translate),
        body: Center(
            child: EmptyState(
          text: 'signinerr'.translate,
        )),
      );
    }

    return MyQBankScaffold(
      hasScaffold: false,
      appBar: MyQBankAppBar(
        title: 'mybooks'.translate,
        trailingWidgets: <Widget>[
          MyPopupMenuButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.more_vert, color: Fav.secondaryDesign.primaryText),
              ),
              onSelected: (value) async {
                if (value == 1) {
                  await reloadBooks();
                  OverAlert.show(message: 'reloadedpurchasedbook'.translate);
                  AppVar.qbankBloc.bookListFecther!.refresh.add(true);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('reloadpurchasedbook'.translate, style: TextStyle(color: Fav.secondaryDesign.primaryText)),
                    value: 1,
                  ),
                ];
              }),
          16.widthBox
        ],
      ),
      body: StreamBuilder(
          initialData: false,
          stream: AppVar.qbankBloc.bookListFecther!.stream,
          builder: (context, snapshot) {
            if (AppVar.qbankBloc.getKitapListesi.isEmpty) {
              return EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS);
            }
            return BookList();
          }),
    );
  }
}

class BookList extends StatefulWidget {
  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<Kitap> satianAlinanlarList = [];
  Set<String?> kategoriListesi = {};
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    listeyiAyarla();
  }

  void listeyiAyarla() {
    satianAlinanlarList.clear();
    kategoriListesi.clear();
    final Map? lastBookList = jsonDecode(Fav.preferences.getString("lastBookList") ?? {}.toString());

    AppVar.qbankBloc.getKitapListesi.sort((a, b) {
      if ((lastBookList![a.bookKey] ?? 0) != (lastBookList[b.bookKey] ?? 0)) {
        if ((lastBookList[a.bookKey] ?? 0) - (lastBookList[b.bookKey] ?? 0) > 0) {
          return -1;
        } else {
          return 1;
        }
      }
      return a.sira.toLowerCase().compareTo(b.sira.toLowerCase());
    });

    AppVar.qbankBloc.getKitapListesi.forEach((kitap) {
      if (AppVar.qbankBloc.hesapBilgileri.checkBookPurchased(kitap.bookKey)) {
        kategoriListesi.add(kitap.className2);
        if (selectedCategory == null && kategoriListesi.isNotEmpty) selectedCategory = kategoriListesi.first;
        if (kitap.className2 == selectedCategory) satianAlinanlarList.add(kitap);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (satianAlinanlarList.isEmpty) {
      return Center(child: Text('nopurchasedbook'.translate, style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 16.0, fontWeight: FontWeight.bold)));
    }

    const double bookWidth = 240.0;

    Widget current = Swiper(
      key: Key(selectedCategory!),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            kitabiAcRelease(index);
          },
          onLongPress: () {
            kitabiAcDebug(index);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: context.screenHeight > 600 ? 64 : 24),
            width: bookWidth,
            height: bookWidth * 1.41,
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              image: DecorationImage(image: CacheHelper.imageProvider(imgUrl: satianAlinanlarList[index].imgUrl!), fit: BoxFit.fill),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: satianAlinanlarList[index].coverName
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration:
                            BoxDecoration(color: Fav.secondaryDesign.scaffold.background.withAlpha(210), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(50), offset: const Offset(-1, -1))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const SizedBox(width: bookWidth, height: 8),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(text: satianAlinanlarList[index].className1, style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 22.0, fontWeight: FontWeight.bold), children: [
                                TextSpan(
                                    text: "\n" + satianAlinanlarList[index].name1!,
                                    style: TextStyle(
                                      color: Fav.secondaryDesign.primaryText.withAlpha(170),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ))
                              ]),
                            ),
                            8.heightBox
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        );
      },
      itemCount: satianAlinanlarList.length,
      itemWidth: bookWidth,
      itemHeight: bookWidth * 1.41 + 20 + 64,
      layout: SwiperLayout.STACK,
      pagination: SwiperPagination(
        builder: satianAlinanlarList.length < 20
            ? DotSwiperPaginationBuilder(size: 5.0, activeSize: 9.0, activeColor: const Color(0xff6665FF), color: Fav.secondaryDesign.brightness == Brightness.dark ? const Color(0xffffffff) : const Color(0xaa6665FF))
            : FractionPaginationBuilder(fontSize: 12, activeFontSize: 18, activeColor: const Color(0xff6665FF), color: Fav.secondaryDesign.brightness == Brightness.dark ? const Color(0xffffffff) : const Color(0xaa6665FF)),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: bookWidth * 1.41 + 30),
      ),
    );

    var listKategoriListesi = kategoriListesi.toList();

    if (kategoriListesi.length > 1) {
      current = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 25,
            child: ListView.separated(
              itemCount: kategoriListesi.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return Align(alignment: Alignment.center, child: Container(width: 4, height: 4, color: Colors.grey));
              },
              itemBuilder: (context, index) {
                //todocheck eskidaen flatbutton du kontrol edilmesi lazim
                return TextButton(
                  // color: selectedCategory == listKategoriListesi[index] ? AppVar.qbankBloc.theme.raisedButtonBackgroundColor : AppVar.qbankBloc.theme.raisedButtonBackgroundColor.withAlpha(80),
                  child: Text(
                    listKategoriListesi[index]!,
                    style: TextStyle(color: selectedCategory == listKategoriListesi[index] ? Fav.secondaryDesign.primary : Colors.deepOrangeAccent.withAlpha(180), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedCategory = listKategoriListesi[index];
                      listeyiAyarla();
                    });
                  },
                );
              },
            ),
          ),
          Expanded(child: current)
        ],
      );
    }

    return current;
  }

  void sonKullanilanlaraEkle(Kitap kitap) {
    Map lastBookList = jsonDecode(Fav.preferences.getString("lastBookList") ?? {}.toString());
    lastBookList[kitap.bookKey] = DateTime.now().millisecondsSinceEpoch;
    Fav.preferences.setString("lastBookList", json.encode(lastBookList));
  }

  Future<void> kitabiAcRelease(int index) async {
    if (satianAlinanlarList[index].status != "50") {
      OverAlert.show(type: AlertType.danger, message: 'nopublish'.translate);
      return;
    }

    if (!AppVar.qbankBloc.hesapBilgileri.checkBookPurchased(satianAlinanlarList[index].bookKey)) {
      OverAlert.show(type: AlertType.danger, message: 'nopayment'.translate);
      return;
    }

    // İççindekiler değişince kitap versiyonu değiştrmeuyi yaz
    final kitapIcindekilerMenusu = await Fav.securePreferences.getHiveMap("${satianAlinanlarList[index].bookKey}_Icindekiler" + AppConst.preferenecesBoxVersion.toString());

    final bool sonVersiyonKayitlimi = (Fav.preferences.getString("${satianAlinanlarList[index].bookKey}_Icindekiler_version") ?? "") == satianAlinanlarList[index].versionRelease;

    if (kitapIcindekilerMenusu.isNotEmpty && sonVersiyonKayitlimi) {
      sonKullanilanlaraEkle(satianAlinanlarList[index]);
      await Fav.to(BooksPreviewPage(icindekilerModel: IcindekilerModel.fromJson(kitapIcindekilerMenusu), kitap: satianAlinanlarList[index]));
    } else {
      if (Fav.noConnection()) return;

      OverLoading.show();

      await QBGetDataService.getPublishedBookContents(AppVar.qbankBloc.databaseSBB, satianAlinanlarList[index].bookKey).then((snapshot) async {
        await OverLoading.close();
        if (snapshot!.value == null) {
          OverAlert.show(type: AlertType.danger, message: 'nopublish'.translate);
          return;
        }

        await Fav.securePreferences.setHiveMap("${satianAlinanlarList[index].bookKey}_Icindekiler" + AppConst.preferenecesBoxVersion.toString(), snapshot.value, clearExistingData: true);

        await Fav.preferences.setString("${satianAlinanlarList[index].bookKey}_Icindekiler_version", satianAlinanlarList[index].versionRelease!);

        sonKullanilanlaraEkle(satianAlinanlarList[index]);
        await Fav.to(BooksPreviewPage(icindekilerModel: IcindekilerModel.fromJson(snapshot.value), kitap: satianAlinanlarList[index]));
      }).catchError((e) async {
        await OverLoading.close(state: false);
      });
    }
  }

  Future<void> kitabiAcDebug(int index) async {
    if (Fav.noConnection()) return;

    if (!AppVar.qbankBloc.hesapBilgileri.gtE) return;

    OverLoading.show();
    await QBGetDataService.getDraftBookContents(satianAlinanlarList[index].bookKey).then((snapshot) async {
      await OverLoading.close();
      if (snapshot!.value == null) return;

      sonKullanilanlaraEkle(satianAlinanlarList[index]);

      await Fav.to(BooksPreviewPage(icindekilerModel: IcindekilerModel.fromJson(snapshot.value), kitap: satianAlinanlarList[index], debug: true));
    }).catchError((err) async {
      await OverLoading.close();
    });
  }
}
