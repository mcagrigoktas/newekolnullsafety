import 'dart:async';
import 'dart:convert';
import 'dart:ui' hide TextStyle;

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:ntp/ntp.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../../flavors/mainhelper.dart';
import '../../models/models.dart';
import '../../qbankbloc/getdataservice.dart';
import '../../qbankbloc/setdataservice.dart';
import '../bookpreviewspage/bookpreviewspage.dart';
import '../login/signin.dart';
import 'purchasepage/purchasehelper.dart';

class BookReview extends StatefulWidget {
  final Kitap? book;
  BookReview({this.book});
  @override
  _BookReviewState createState() => _BookReviewState();
}

class _BookReviewState extends State<BookReview> with PurchaseHelper {
  bool alreadyPurchased = false;

  bool bookFree = false;
  bool isLoading = true;
  int menuLevel = 0;
  Map? icindekilerData;
  DateTime? date;

  String? productId;
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    NTP.now().then((date) => this.date = date);
    if (widget.book!.priceStatus == BookPriceStatus.FREE) {
      bookFree = true;
    } else if (!AppVar.qbankBloc.hesapBilgileri.isQbank && widget.book!.privacy.contains(AppVar.qbankBloc.hesapBilgileri.kurumID) && widget.book!.priceStatus == BookPriceStatus.FREE_TO_INSTUTION) {
      bookFree = true;
    }

    productId = widget.book!.priceCode;

    _inAppPurchaseInitialize();
    fetchIcindekiler();

    super.initState();
  }

  Future<void> _inAppPurchaseInitialize() async {
    _available = await _iap.isAvailable();

    if (_available) {
      await _getProducts();
      await _getPurchased();

      _subscription = _iap.purchaseStream.listen(
        (purchases) {
          setState(() {
            _purchases.addAll(purchases);
            _verifyPurchase();
          });
        },
        onError: (err) {
          OverAlert.show(type: AlertType.danger, message: 'onErr$err');
        },
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getProducts() async {
    Set<String> ids = {productId!};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;
  }

  Future<void> _getPurchased() async {
    //! In app purchase son guncelleme gelince kaldirildi yeniisi icin burayi acip bastan yaz
    //   QueryPurchaseDetailsResponse response = await _iap.restorePurchases();
    //   for (PurchaseDetails purchase in response.pastPurchases) {
    //     await _iap.completePurchase(purchase);

    //     if (purchase.productID == productId && widget.book.priceDay == '0') {
    //       final purchasedUid = await QBGetDataService.getPurchasedUid(AppVar.qbankBloc.hesapBilgileri.uid, trimPurchaseId(purchase.purchaseID)).once();
    //       if (purchasedUid.value == AppVar.qbankBloc.hesapBilgileri.uid) {
    //         alreadyPurchased = true;
    //         await spendBooks(purchaseDetails: purchase);
    //       } else {
    //         OverAlert.show(type: AlertType.danger, message: 'Geri yukleme yapilamadi'.translate);
    //       }
    //     }
    //   }
    //   setState(() {
    //     _purchases = response.pastPurchases;
    //   });
  }

  PurchaseDetails? _hasPurchased(String? productId) {
    var purchase = _purchases.singleWhereOrNull((purchase) => purchase.productID == productId && purchase.status == PurchaseStatus.purchased);
    if (purchase != null) {
      return purchase;
    }
    return _purchases.singleWhereOrNull((purchase) => purchase.productID == productId);
  }

  void _verifyPurchase() {
    PurchaseDetails? purchase = _hasPurchased(productId);

    if (purchase == null) {
      setState(() {
        isLoading = false;
      });
    } else if (purchase.status == PurchaseStatus.pending) {
    } else if (purchase.status == PurchaseStatus.purchased) {
      _iap.completePurchase(purchase);
      setState(() {
        isLoading = false;
      });

      spendBooks(purchaseDetails: purchase);
    } else {
      setState(() {
        isLoading = false;
      });
      OverAlert.show(type: AlertType.danger, message: 'buyerr'.translate);
    }
  }

  Future<void> _buyProducts() async {
    ProductDetails? prod = _products.singleWhereOrNull((item) => item.id == widget.book!.priceCode);

    if (prod != null) {
      setState(() {
        isLoading = true;
      });
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
      //   await bekleterekAlertVer(widget.book.priceDay);
      await spendBooks(status: 1);
      if (widget.book!.priceDay == '0') {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _iap.buyConsumable(purchaseParam: purchaseParam);
      }
    } else {
      OverAlert.show(type: AlertType.danger, message: 'Product ID is missing' /*'soonpossiblebuy'*/ .translate);
    }
  }

  Future<void> spendBooks({PurchaseDetails? purchaseDetails, int status = 10}) async {
    date ??= DateTime.now();
    setState(() {
      if (status == 10) {
        alreadyPurchased = true;
        isLoading = true;
      }
    });
    PurchasedBookData purchasedBookData = PurchasedBookData(
        bookKey: widget.book!.bookKey,
        uid: AppVar.qbankBloc.hesapBilgileri.uid,
        invoiceKey: widget.book!.invoiceKey,
        purchasedDate: date!.millisecondsSinceEpoch,
        purchasedPrice: widget.book!.price,
        puchasedLimitDay: widget.book!.priceDay.toString() == '0' ? 3650 : int.parse(widget.book!.priceDay.toString()),
        purchasedCode: widget.book!.priceCode,
        satinAlmaTuru: purchaseDetails == null ? 0 : 2,
        extraData: purchaseDetails == null ? {} : {'purchaseId': purchaseDetails.purchaseID},
        status: status);
    if (status == 10) {
      AppVar.qbankBloc.hesapBilgileri.purchasedList!.add(purchasedBookData);
      if (AppVar.qbankBloc.hesapBilgileri.isQbank) {
        await AppVar.qbankBloc.hesapBilgileri.savePreferences();
      } else {
        var existingList = Fav.preferences.getStringList(AppVar.appBloc.hesapBilgileri.qbankUid + 'ekolQbankPurchasedList', [])!.map((item) => PurchasedBookData.fromJson(json.decode(item))).toList();
        existingList.add(purchasedBookData);
        await Fav.preferences.setStringList(AppVar.appBloc.hesapBilgileri.qbankUid + 'ekolQbankPurchasedList', existingList.map((item) => json.encode(item.mapForSave())).toList());
      }
    }

    await QBSetDataService.buyBook(AppVar.qbankBloc.hesapBilgileri.uid, widget.book!.bookKey, purchasedBookData.mapForSave(), trimpurchaseId: purchaseDetails == null ? null : trimPurchaseId(purchaseDetails.purchaseID)).then((_) async {
      if (status == 10) {
        await reloadBooks();
        setState(() {
          isLoading = false;
        });
        Get.back();
        OverAlert.show(message: 'buybooksuc'.translate);
      }
    }).catchError((_) {
      if (status == 10) {
        setState(() {
          isLoading = false;
        });
        OverAlert.show(message: 'buybookerr'.translate, type: AlertType.danger);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void setMenuLevel(int index) {
    setState(() {
      menuLevel = index;
    });
  }

  Future<void> fetchIcindekiler() async {
    final kitapIcindekilerMenusu = await Fav.securePreferences.getHiveMap("${widget.book!.bookKey}_Icindekiler" + AppConst.preferenecesBoxVersion.toString());

    final bool sonVersiyonKayitlimi = (Fav.preferences.getString("${widget.book!.bookKey}_Icindekiler_version") ?? "") == widget.book!.versionRelease;

    if (kitapIcindekilerMenusu.isNotEmpty && sonVersiyonKayitlimi) {
      icindekilerData = kitapIcindekilerMenusu;

      setState(() {});
    } else {
      await QBGetDataService.getPublishedBookContents(AppVar.qbankBloc.databaseSBB, widget.book!.bookKey).then((snapshot) async {
        if (snapshot!.value == null) {
          return;
        }

        await Fav.securePreferences.setHiveMap("${widget.book!.bookKey}_Icindekiler" + AppConst.preferenecesBoxVersion.toString(), snapshot.value, clearExistingData: true);

        await Fav.preferences.setString("${widget.book!.bookKey}_Icindekiler_version", widget.book!.versionRelease!);

        setState(() {});
        icindekilerData = snapshot.value;
      });
    }
  }

  Future<void> buyBook() async {
    if (Fav.noConnection()) return;

    if ((AppVar.qbankBloc.hesapBilgileri.uid ?? '').length < 10) {
      Over.sure(
        title: 'buyuiderr'.translate,
        yesText: 'signin'.translate,
      ).then((value) {
        if (value == true) Fav.to(SignInPage());
      }).unawaited;

      return;
    }

    if (bookFree) {
      await spendBooks();
    } else //if (!widget.book.creditCardStatus)
    {
      if (_available == false) {
        OverAlert.show(type: AlertType.danger, message: 'buyprocesserr'.translate);
        return;
      }
      await _buyProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + 96.0;

    late Widget detailWidget;
    if (menuLevel == 0) {
      detailWidget = BookDetails(book: widget.book, topPadding: topPadding);
    } else if (menuLevel == 1 && icindekilerData == null) {
      detailWidget = const Center(child: CircularProgressIndicator());
      fetchIcindekiler();
    } else if (menuLevel == 1) {
      detailWidget = ListIcindekiler(
        testData: icindekilerData,
        topPadding: topPadding,
      );
    }

    return Scaffold(
      backgroundColor: Fav.secondaryDesign.scaffold.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          BlurWidget(book: widget.book),
          CardWidget(book: widget.book, topPadding: topPadding),
          Positioned(
            top: topPadding - 32,
            right: 32,
            left: 32,
            bottom: 22,
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    12.widthBox,
                    SizedBox(
                      child: BookPhotoWidget(book: widget.book, topPadding: topPadding),
                      width: 125.0,
                      height: 180,
                    ),
                    Expanded(
                        child: Column(
                      children: <Widget>[
                        16.heightBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: PriceWidget(book: widget.book, topPadding: topPadding, onClick: buyBook, isLoading: isLoading, alreadyPurchased: alreadyPurchased),
                        ),
                        12.heightBox,
                        if (icindekilerData != null && widget.book!.priceStatus != BookPriceStatus.FREE)
                          GestureDetector(
                            onTap: () {
                              Fav.to(BooksPreviewPage(isTry: true, kitap: widget.book, icindekilerModel: IcindekilerModel.fromJson(icindekilerData!)));
                            },
                            child: Material(
                              color: Colors.amber,
                              shape: const StadiumBorder(),
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                child: Text(
                                  'freetry'.translate,
                                  style: const TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        16.heightBox,
                        BookNameWidget(book: widget.book, topPadding: topPadding),
                        12.heightBox,
                      ],
                    ))
                  ],
                ),
                16.heightBox,
                //   Divider(),
                ButtonWidget(topPadding: topPadding, onClick: setMenuLevel, menuLevel: menuLevel),
                Expanded(child: detailWidget),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
                icon: Icon(Icons.arrow_back, color: Fav.secondaryDesign.appBar.text),
                onPressed: () {
                  Get.back();
                }),
          )
        ],
      ),
    );
  }

  String trimPurchaseId(String? id) => id.toFirebaseSafeKey!.replaceAll(':', '');
}

class BlurWidget extends StatelessWidget {
  final Kitap? book;
  BlurWidget({this.book});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CacheHelper.imageProvider(imgUrl: book!.imgUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Fav.secondaryDesign.scaffold.background.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final Kitap? book;
  final double? topPadding;
  CardWidget({this.book, this.topPadding});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16.0,
      right: 16.0,
      bottom: 16.0,
      top: topPadding,
      child: Card(
        color: Fav.secondaryDesign.accent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
      ),
    );
  }
}

class BookPhotoWidget extends StatelessWidget {
  final Kitap? book;
  final double? topPadding;
  BookPhotoWidget({this.book, this.topPadding});
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "bookPhotoReview" + book!.bookKey,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: DecorationImage(
            image: CacheHelper.imageProvider(imgUrl: book!.imgUrl!),
            fit: BoxFit.fill,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
    );
  }
}

class PriceWidget extends StatelessWidget {
  final Kitap? book;
  final double? topPadding;
  final Function()? onClick;
  final bool? isLoading;
  final bool? alreadyPurchased;
  PriceWidget({this.book, this.topPadding, this.onClick, this.isLoading, this.alreadyPurchased});
  @override
  Widget build(BuildContext context) {
    return MyProgressButton(
      onPressed: onClick,
      isLoading: isLoading!,
      label: alreadyPurchased!
          ? 'alreadypurchased'.translate
          : book!.priceStatus == BookPriceStatus.FREE
              ? 'freebook'.translate
              : "${'buy'.translate} ${AppVar.qbankBloc.bookPriceCache[book!.priceCode] ?? book!.price}",
      color: const Color(0xff6665FF), //shape: StadiumBorder(),
      // child: Text(book.priceStatus == "0" ?  'freebook') : "${ 'buy')} ${book.price}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13.0),),
    );
  }
}

class BookNameWidget extends StatelessWidget {
  final Kitap? book;
  final double? topPadding;
  BookNameWidget({this.book, this.topPadding});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            book!.name1!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          4.heightBox,
          Text(
            book!.className1!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(180), fontSize: 14.0),
          )
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final double? topPadding;
  final Function? onClick;
  final int? menuLevel;
  ButtonWidget({this.topPadding, this.onClick, this.menuLevel});
  @override
  Widget build(BuildContext context) {
    Color disableColor = Fav.secondaryDesign.primaryText.withAlpha(120);
    TextStyle enableStyle = TextStyle(
      color: Fav.secondaryDesign.primaryText,
      fontWeight: FontWeight.bold,
      fontSize: 14.0,
    );
    TextStyle disableStyle = TextStyle(color: disableColor, fontWeight: FontWeight.bold, fontSize: 14.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ////tododanger
        OutlinedButton(
          //shape: const StadiumBorder(),
          onPressed: () {
            onClick!(0);
          },
          child: Text(
            'bookinfo'.translate,
            style: menuLevel == 0 ? enableStyle : disableStyle,
          ),
        ),
        16.widthBox,
        ////tododanger
        OutlinedButton(
          // shape: const StadiumBorder(),
          onPressed: () {
            onClick!(1);
          },
          child: Text(
            'bookcontents'.translate,
            style: menuLevel == 1 ? enableStyle : disableStyle,
          ),
        ),
      ],
    );
  }
}

class BookDetails extends StatelessWidget {
  final double? topPadding;
  final Kitap? book;
  BookDetails({this.book, this.topPadding});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Text(book!.aciklama!,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
            fontSize: 15.0,
          )),
    );
  }
}

class ListIcindekiler extends StatelessWidget {
  final Map? testData;
  final double? topPadding;
  ListIcindekiler({this.testData, this.topPadding});

  Widget _buildTiles(Map item, BuildContext context, {int? no}) {
    if (item["testKey"] == "menulevel" || item["testKey"] == "testseviyesi" || item["testKey"] == "denemeseviyesi") {
      List<Widget> children = [];

      (item["children"] as List).forEach((map) {
        children.add(_buildTiles(map, context));
      });
      return Container(
        decoration: ShapeDecoration(
          color: Fav.secondaryDesign.accent,
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(6.0)), side: BorderSide(color: Fav.secondaryDesign.primaryText.withAlpha(130), width: 0.2)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: ExpansionTile(
          /*  backgroundColor: Color(0xffFFF1C1).withAlpha(40),*/
          title: Text(no == null ? item["baslik"] : "$no. " + item["baslik"],
              style: TextStyle(
                color: Fav.secondaryDesign.primaryText,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              )), //,
          children: children,
        ),
      );
    }

    return Container(
      decoration: ShapeDecoration(
          color: Fav.secondaryDesign.accent.withAlpha(20),
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(1.0)), side: BorderSide(color: Fav.secondaryDesign.accent.withAlpha(150), width: 0.1)),
          image: DecorationImage(image: AssetImage(Assets.images.confettioPNG), fit: BoxFit.cover)),
      child: ListTile(
        title: Text(
          item["baslik"],
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          testData!["questionCount"][item["testKey"]].toString() + " " + 'soruplural'.translate,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText.withAlpha(125),
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          itemCount: testData!['data'].length,
          itemBuilder: (BuildContext context, int index) {
            // ignore: expected_token
            return _buildTiles(testData!['data'][index], context, no: index + 1);
          }),
    );
  }
}
