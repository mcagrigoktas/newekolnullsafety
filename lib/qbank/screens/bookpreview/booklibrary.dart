import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../models/models.dart';
import 'bookreview.dart';

class BookLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyQBankScaffold(
      hasScaffold: false,
      appBar: MyQBankAppBar(title: 'bookstore'.translate),
      body: StreamBuilder(
          initialData: false,
          stream: AppVar.qbankBloc.bookListFecther!.stream,
          builder: (context, snapshot) {
            if (Fav.noConnection(warning: false)) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'noconnection'.translate,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(100)),
                      )),
                ],
              );
            }

            Widget current = LibraryBookList();

            if (MediaQuery.of(context).orientation != Orientation.portrait) {
              current = SafeArea(
                child: current,
                top: false,
                bottom: false,
              );
            }

            return current;
          }),
    );
  }
}

class LibraryBookList extends StatefulWidget {
  LibraryBookList();

  @override
  _LibraryBookListState createState() => _LibraryBookListState();
}

class _LibraryBookListState extends State<LibraryBookList> {
  @override
  Widget build(BuildContext context) {
    Map seviyeMap = {};

    AppVar.qbankBloc.getKitapListesi.forEach((kitap) {
      if (seviyeMap.containsKey(kitap.className2)) {
        seviyeMap[kitap.className2] = (seviyeMap[kitap.className2] as List)..add(kitap);
      } else {
        seviyeMap[kitap.className2] = [kitap];
      }
    });

    if (seviyeMap.keys.isEmpty) {
      return EmptyState(text: 'booklistempty'.translate);
    }

    return ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 32),
        children: seviyeMap.keys.map((itemKey) {
          List<Kitap> books = List<Kitap>.from(seviyeMap[itemKey]);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              8.heightBox,
              Text(
                // 'classlevel$itemKey'),
                itemKey,
                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return LibraryBookListItem(book: books[index]);
                  },
                  itemCount: books.length,
                ),
              ),
            ],
          );
        }).toList());
  }
}

class LibraryBookListItem extends StatelessWidget {
  final Kitap? book;

  LibraryBookListItem({this.book});

  @override
  Widget build(BuildContext context) {
    bool alreadyPurchased = false;

    AppVar.qbankBloc.hesapBilgileri.purchasedList!.forEach((item) {
      if (item.bookKey == book!.bookKey && item.isDateEnd == false) {
        alreadyPurchased = true;
      }
    });

    String? priceText = '';

    if (alreadyPurchased) {
      if (book!.priceStatus == BookPriceStatus.FREE) {
        priceText = 'alreadyaddedlibrary'.translate;
      } else {
        priceText = 'alreadypurchased'.translate;
      }
    } else if (book!.priceStatus == BookPriceStatus.FREE) {
      priceText = 'freebook'.translate;
    } else {
      priceText = AppVar.qbankBloc.bookPriceCache[book!.priceCode] ?? book!.price!;
    }

    if (book!.status == '0') {
      priceText = 'preparing'.translate;
    }

//    Widget image = Container(
//      decoration: BoxDecoration(
//          borderRadius: BorderRadius.circular(8.0),
//          image: DecorationImage(
//            image: myImageProvider(context, imgUrl: book.imgUrl),
//            fit: BoxFit.fill,
//          )),
//      width: 125.0,
//      height: 180.0,
//          placeholder: (_,__)=>Container( width: 125.0, height: 180.0, child: MyProgressIndicator(color: AppVar.qbankTheme.primaryColor,), alignment: Alignment.center,),
//    );
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: MyCachedImage(
        imgUrl: book!.imgUrl!,
        fit: BoxFit.cover,
        width: 125.0,
        height: 180.0,
        //    placeholder: (_,__)=>Container( width: 125.0, height: 180.0, child: MyProgressIndicator(color: AppVar.qbankTheme.primaryColor,), alignment: Alignment.center,),
      ),
    );

    if (book!.status == '0') {
      image = Banner(textStyle: const TextStyle(fontSize: 9), message: 'preparing'.translate, color: Colors.deepOrange, location: BannerLocation.topEnd, child: image);
    }

    return Column(
      children: <Widget>[
        4.heightBox,
        InkWell(
          onTap: () {
            if (Fav.noConnection()) return;

            if (book!.status == '0') return OverAlert.show(message: 'preparingerr'.translate, type: AlertType.danger);

            alreadyPurchased ? OverAlert.show(type: AlertType.danger, message: 'alreadypurchasedhint'.translate) : Fav.to(BookReview(book: book));
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: Hero(
              tag: "bookPhotoReview" + book!.bookKey,
              child: image,
            ),
          ),
        ),
        4.heightBox,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            book!.name1!,
            style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(200), fontSize: 15.0, fontWeight: FontWeight.w300),
          ),
        ),
        4.heightBox,
        alreadyPurchased
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  4.widthBox,
                  Flexible(
                      child: Text(
                    priceText,
                    style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 12.0, fontWeight: FontWeight.w900),
                  ))
                ],
              )
            : Text(
                priceText,
                style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 14.0, fontWeight: FontWeight.w900),
              ),
      ],
    );
  }
}
