//import 'dart:async';
//
//import 'package:cloud_functions/cloud_functions.dart';
//import 'package:elseifekol/appbloc/appvar.dart';
//import 'package:elseifekol/qbank/models/models.dart';
//import 'package:elseifekol/qbank/screens/bookpreview/purchasepage/purchasehelper.dart';
//import 'package:flutter/material.dart';
//import 'package:flip_card/flip_card.dart';
//
//import 'package:mypackage/mywidgets.dart';
//
//import 'package:ntp/ntp.dart';
//
//import 'incoiceinfo.dart';
//import 'termsofuse.dart';
//
//class IyziCoPage extends StatefulWidget {
//  final Kitap book;
//  IyziCoPage(this.book);
//
//  @override
//  _IyziCoPageState createState() =>   _IyziCoPageState();
//}
//
//class _IyziCoPageState extends State<IyziCoPage> with  PurchaseHelper {
//  bool isLoading = true;
//  bool checkBox = false;
//  PurchasedBookData purchasedBookData = PurchasedBookData(status: 0);
//  final LinearGradient _creditCardGradient = LinearGradient(colors: [Color(0xff56CCF2), Color(0xff2F80ED)]);
//  final double _creditCardWidth = 310;
//  final double _creditCardHeight = 140;
//
//  StreamSubscription subscription;
//  DateTime date;
//
//  final TextEditingController nameController = TextEditingController(text: '');
//  final TextEditingController cardNumberController = TextEditingController(text: '');
//  String monthController = '1';
//  String yearController = '2019';
//  final TextEditingController cvcController = TextEditingController(text: '');
//
//  FocusNode backFocus = FocusNode();
//  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
//  GlobalKey<FormState> formKey = GlobalKey();
//
//  getCardNumberText() {
//    var text = cardNumberController.text.padRight(16, '*');
//    text = text.substring(0, 4) + ' ' + text.substring(4, 8) + ' ' + text.substring(8, 12) + ' ' + text.substring(12, 16);
//    return text;
//  }
//
//  int visaOrMaster() {
//    return 0;
//  }
//
//  @override
//  void initState() {
//    super.initState();
//
//    NTP.now().then((date) {
//      this.date = date;
//    });
//
//    backFocus.addListener(() {
//      if (backFocus.hasFocus && cardKey.currentState.isFront == true) {
//        cardKey.currentState.toggleCard();
//      } else if (!backFocus.hasFocus && cardKey.currentState.isFront == false) {
//        cardKey.currentState.toggleCard();
//      }
//    });
//
//    subscription = QBGetDataService.getBookPurchasedResult(AppVar.qbankBloc.databaseSBB, AppVar.qbankBloc.hesapBilgileri.uid, widget.book.bookKey).onValue().listen((event) async {
//      if (event.value != null) {
//        purchasedBookData = PurchasedBookData.fromJson(event.value);
//        if (purchasedBookData.status == 10) {
//          await reloadBooks();
//         Alert.alert(
//              context: context,
//              rowActions: [
//                FlushBarAction(
//                    text:  'ok'),
//                    onPressed: () {
//                      AppVar.qbankBloc.appConfig.qbankRestartApp(true, AppVar.qbankBloc);
//                    })
//              ],
//              text:  'buysuc'));
//        } else if (purchasedBookData.status == -1) {
//         OverAlert.show(type: AlertType.danger, message:  'buyerr') + '\n' + (purchasedBookData.extraData ?? {})['errorMessage']);
//        }
//      }
//
//      setState(() {
//        isLoading = false;
//      });
//    });
//    coldStart();
//  }
//
//  coldStart() {
//    CloudFunctions.instance.getHttpsCallable(functionName: "onPaymentCreate").call({
//      "coldStart": true,
//      "satinAlmaTuru": 1,
//      "cardHolderName": 'Deneme Deneme',
//      "cardNumber": '1111111111111111',
//      "expireMonth": '12',
//      'expireYear': '2022',
//      'cvc': '123',
//      'registerCard': 0,
//      'uid': 'Deneme',
//      'bookKey': 'Deneme',
//      'bookName': 'Deneme',
//      'invoiceKey': '-1',
//      'category1': 'Dijital Kitap',
//      'price': '19.90',
//      'priceDay': widget.book.priceDay,
//      'paidPrice': '19.90',
//      'name': 'John',
//      'surname': 'Doe',
//      'mail': 'abcdef@gmail.com',
//      'identityNumber': '12312332132',
//      'city': 'Ankara',
//      'adress': 'Ceyhun  atuf kansu cd. Gozde Plaza. No:130/62 Balgat/Cankaya',
//    }).catchError((err) {
//      print(err.message);
//      print(err.details);
//    });
//  }
//
//  @override
//  void dispose() {
//    subscription.cancel();
//    super.dispose();
//  }
//
//  buy() {
//    double fiyat;
//    RegExp regExp =   RegExp(
//      '[0-9.,]+',
//    );
//
//    if (regExp.allMatches(widget.book.price).length > 0) {
//      fiyat = double.tryParse(regExp.firstMatch(widget.book.price).group(0));
//    } else {
//     OverAlert.show(type: AlertType.danger, message:  'priceerr'));
//      return;
//    }
//
//    if (Fav.noConnection() ) {
//      return;
//    }
//    if (purchasedBookData.status == 10) {
//     OverAlert.show(type: AlertType.danger, message: 'Bu kitabı zaten satın aldınız');
//      return;
//    }
//    if (purchasedBookData.status == 1) {
//     OverAlert.show(type: AlertType.danger, message: 'Şu an devam eden bir işleminiz bulunmaktadır.');
//      return;
//    }
//
//    if (!checkBox) {
//     OverAlert.show(type: AlertType.danger, message: 'Lütfen satın alma sözleşmesini onaylayın.');
//      return;
//    }
//
//    if (formKey.currentState.validate()) {
//      formKey.currentState.save();
//      if (Fav.noConnection() ) {
//        return;
//      }
//      setState(() {
//        isLoading = true;
//      });
//      CloudFunctions.instance.getHttpsCallable(functionName: "onPaymentCreate").call({
//        "coldStart": false,
//        "satinAlmaTuru": 1,
//        "cardHolderName": nameController.text,
//        "cardNumber": cardNumberController.text,
//        "expireMonth": monthController,
//        'expireYear': yearController,
//        'cvc': cvcController.text,
//        'registerCard': 0,
//        'uid': AppVar.qbankBloc.hesapBilgileri.uid,
//        'bookKey': widget.book.bookKey,
//        'bookName': widget.book.name1,
//        'invoiceKey': widget.book.invoiceKey ?? '',
//        'category1': 'Dijital Kitap',
//        'price': fiyat.toString(),
//        'priceDay': widget.book.priceDay,
//        'paidPrice': fiyat.toString(),
//        'name': nameController.text.split(' ').first,
//        'surname': nameController.text.split(' ').last,
//        'mail': AppVar.qbankBloc.hesapBilgileri.username ?? 'abcdef@gmail.com',
//        'identityNumber': (AppVar.qbankBloc.hesapBilgileri.invoiceData ?? {})['tc'] ?? '12312332132',
//        'city': (AppVar.qbankBloc.hesapBilgileri.invoiceData ?? {})['city'] ?? 'Ankara',
//        'adress': (AppVar.qbankBloc.hesapBilgileri.invoiceData ?? {})['adress'] ?? 'Ceyhun  atuf kansu cd. Gozde Plaza. No:130/62 Balgat/Cankaya',
//      }).catchError((err) {
//        print(err.message);
//        print(err.details);
//      });
//    } else {
//     Alert.alert( message:  "fillrequired"), type: AlertType.danger);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Fav.secondaryDesign.scaffold.background,
//      appBar: AppBar(
//        automaticallyImplyLeading: true,
//        backgroundColor: Fav.secondaryDesign.scaffold.background,
//        elevation: 0,
//        title: Text(
//          widget.book.name1,
//          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//        ),
//        actions: <Widget>[
//          Chip(
//            label: Text(
//              widget.book.price,
//              style: TextStyle(color: Colors.white),
//            ),
//            backgroundColor: Colors.white.withAlpha(10),
//          ),
//          SizedBox(
//            width: 16,
//          ),
//        ],
//        centerTitle: true,
//      ),
//      body: SingleChildScrollView(
//        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//        child: MyForm(
//          formKey: formKey,
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: <Widget>[
//              Container(
//                alignment: Alignment.center,
//                child: FlipCard(
//                  key: cardKey,
//                  direction: FlipDirection.HORIZONTAL, // default
//                  front: Material(
//                    elevation: 8,
//                    borderRadius: BorderRadius.circular(12),
//                    child: Container(
//                      width: _creditCardWidth,
//                      height: _creditCardHeight,
//                      decoration: BoxDecoration(gradient: _creditCardGradient, borderRadius: BorderRadius.circular(12)),
//                      child: Stack(
//                        children: <Widget>[
//                          Positioned(
//                            left: 16,
//                            bottom: 50,
//                            child: Text(
//                              getCardNumberText(),
//                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w200),
//                            ),
//                          ),
//                          Positioned(
//                            left: 16,
//                            bottom: 25,
//                            child: Text(
//                              nameController.text,
//                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                          Positioned(
//                            right: 16,
//                            top: 16,
//                            child: visaOrMaster() == 0
//                                ? Row(children: [
//                                    Image.asset(
//                                      'assets/images/visa.png',
//                                      height: 18,
//                                      fit: BoxFit.fill,
//                                      color: Colors.white,
//                                    ),
//                                    SizedBox(
//                                      width: 8,
//                                    ),
//                                    Image.asset(
//                                      'assets/images/mastercard.png',
//                                      height: 22,
//                                      fit: BoxFit.fill,
//                                    ),
//                                  ])
//                                : visaOrMaster() == 1
//                                    ? Image.asset(
//                                        'assets/images/visa.png',
//                                        height: 18,
//                                        fit: BoxFit.fill,
//                                        color: Colors.white,
//                                      )
//                                    : Image.asset(
//                                        'assets/images/mastercard.png',
//                                        height: 22,
//                                        fit: BoxFit.fill,
//                                      ),
//                          ),
//                          Positioned(
//                            right: 16,
//                            bottom: 25,
//                            child: Row(
//                              children: <Widget>[
//                                Text(
//                                  monthController.padLeft(2, '0'),
//                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                                ),
//                                Text(
//                                  ' / ',
//                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//                                ),
//                                Text(
//                                  yearController.padRight(2, '*'),
//                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                  back: Material(
//                    elevation: 8,
//                    borderRadius: BorderRadius.circular(12),
//                    child: Container(
//                      width: _creditCardWidth,
//                      height: _creditCardHeight,
//                      decoration: BoxDecoration(gradient: _creditCardGradient, borderRadius: BorderRadius.circular(12)),
//                      child: Stack(
//                        children: <Widget>[
//                          Positioned(
//                            right: 0,
//                            top: 20,
//                            left: 0,
//                            child: Container(
//                              height: 33,
//                              color: Colors.black.withAlpha(200),
//                            ),
//                          ),
//                          Positioned(
//                            right: 32,
//                            bottom: 45,
//                            child: Text(
//                              cvcController.text.padRight(3, '*'),
//                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//              SizedBox(
//                height: 16,
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                child: MyTextFormField2(
//                  validatorRules: ValidatorRules(
//                    minLength: 4,
//                  ),
//                  controller: nameController,
//                  onChanged: (value) {
//                    setState(() {});
//                  },
//                  labelText: 'Kart üzerindeki isim',
//                ),
//              ),
//              SizedBox(
//                height: 8,
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                child: MyTextFormField2(
//                  validatorRules: ValidatorRules(
//                    maxLength: 16,
//                    minLength: 16,
//                    mustNumber: true,
//                  ),
//                  keyboardType: TextInputType.number,
//                  controller: cardNumberController,
//                  onChanged: (value) {
//                    setState(() {});
//                  },
//                  labelText: 'Kart no',
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                child: Row(
//                  children: <Widget>[
//                    SizedBox(
//                      width: 56,
//                      child: MyDropDownField(
//                        padding: EdgeInsets.symmetric(horizontal: 4),
//                        isExpanded: true,
//                        onChanged: (value) {
//                          monthController = value.toString();
//                          setState(() {});
//                        },
//                        arrowIcon: false,
//                        onSaved: (value) {
//                          monthController = value.toString();
//                          setState(() {});
//                        },
//                        name: 'Ay',
//                        items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']
//                            .map((i) => DropdownMenuItem(
//                                  value: i,
//                                  child: Text(
//                                    i,
//                                    style: TextStyle(color: Fav.secondaryDesign.primaryText),
//                                  ),
//                                ))
//                            .toList(),
//                      ),
//                    ),
//                    //    SizedBox(width: 8,),
//                    Padding(
//                      padding: const EdgeInsets.only(bottom: 16.0),
//                      child: Text(
//                        '/',
//                        style: TextStyle(color: Fav.secondaryDesign.primaryText),
//                      ),
//                    ),
//                    //   SizedBox(width: 8,),
//                    SizedBox(
//                      width: 80,
//                      child: MyDropDownField(
//                        padding: EdgeInsets.symmetric(horizontal: 4),
//                        isExpanded: true,
//                        onSaved: (value) {
//                          yearController = value.toString();
//                          setState(() {});
//                        },
//                        onChanged: (value) {
//                          yearController = value.toString();
//                          setState(() {});
//                        },
//                        arrowIcon: false,
//                        name: 'Yıl',
//                        items: ['2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035']
//                            .map((i) => DropdownMenuItem(
//                                  value: i,
//                                  child: Text(
//                                    i,
//                                    style: TextStyle(color: Fav.secondaryDesign.primaryText),
//                                  ),
//                                ))
//                            .toList(),
//                      ),
//                    ),
//                    SizedBox(
//                      width: 48,
//                    ),
//                    Expanded(
//                      child: MyTextFormField2(
//                        validatorRules: ValidatorRules(maxLength: 3, minLength: 3, mustNumber: true),
//                        keyboardType: TextInputType.number,
//                        focusNode: backFocus,
//                        controller: cvcController,
//                        onChanged: (value) {
//                          setState(() {});
//                        },
//                        labelText: 'CVC',
//                        counterColor: Colors.transparent,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                child: Row(
//                  children: <Widget>[
//                    Checkbox(
//                        value: checkBox,
//                        activeColor: Color(0xff2F80ED),
//                        onChanged: (value) {
//                          setState(() {
//                            checkBox = value;
//                          });
//                        }),
//                    Expanded(
//                        child:
//
////                      RichText(
////                        text: TextSpan(
////                          style: TextStyle(fontSize: 10,color: Fav.secondaryDesign.primaryText.withAlpha(100)),
////                          children: [
////                            TextSpan(text: 'Satin alma sozlesmesini okudum ve kabul ediyorum. Satin alma sozlesmesini okumak icin'),
////                            TextSpan(text: ' buraya ',style: TextStyle(color: Color(0xff2F80ED)),recognizer: TapGestureRecognizer()..onTap = () { Navigator.push(context, MaterialPageRoute(builder: (context) {return  TermOfUse();}),);}),
////                            TextSpan(text: 'fatura bilgilerinizi guncellemek icin'),
////                            TextSpan(text: ' buraya ',style: TextStyle(color: Color(0xff2F80ED)),recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) {return  InvoicePage();}),)),
////                            TextSpan(text: 'tiklayiniz.'),
////                          ]
////                        ),
////                      )
//                            GestureDetector(
//                                onTap: () {
//                                  Navigator.push(
//                                    context,
//                                    MaterialPageRoute(builder: (context) {
//                                      return TermOfUse(
//                                        invoiceNumber: widget.book.invoiceKey,
//                                      );
//                                    }),
//                                  );
//                                },
//                                child: Text(
//                                  'Satın alma sözleşmesini okudum ve kabul ediyorum. Sözleşmeyi okumak için buraya tıklayın.',
//                                  style: TextStyle(fontSize: 9, color: Fav.secondaryDesign.primaryText.withAlpha(100)),
//                                ))),
//                  ],
//                ),
//              ),
//              SizedBox(
//                height: 10,
//              ),
//              Align(
//                alignment: Alignment.topRight,
//                child: Padding(
//                  padding: const EdgeInsets.only(right: 32.0),
//                  child: MyProgressButton(
//                    label:  'buy2'),
//                    isLoading: isLoading,
//                    color: Color(0xff2F80ED),
//                    onPressed: buy,
//                  ),
//                ),
//              ),
//              SizedBox(height: 32),
//              Align(
//                alignment: Alignment.center,
//                child: OutlineButton(
//                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//                    onPressed: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(builder: (context) {
//                          return InvoicePage();
//                        }),
//                      );
//                    },
//                    child: Text(
//                       'Fatura bilgilerini düzenle'),
//                      style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 12),
//                    )),
//              )
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}
//
//class MyTextFormField2 extends StatelessWidget {
//  final TextEditingController controller;
//  final Function onSaved;
//  final Function onChanged;
//  final int maxLines;
//  final bool obscureText;
//  final Color iconColor;
//  final Color counterColor;
//  final String labelText;
//  final IconData iconData;
//  final String initialValue;
//  final TextInputType keyboardType;
//  final ValidatorRules validatorRules;
//  final EdgeInsets padding;
//  final TextAlign textAlign;
//  final FocusNode focusNode;
//
//  MyTextFormField2(
//      {this.onSaved, this.focusNode, this.keyboardType, this.textAlign = TextAlign.start, this.initialValue, this.controller, this.maxLines = 1, this.obscureText = false, this.iconColor, this.counterColor, this.labelText, this.iconData, this.validatorRules, this.padding, this.onChanged});
//
//  @override
//  Widget build(BuildContext context) {
//    return   TextFormField(
//      validator: validatorRules == null
//          ? null
//          : (value) {
//              return validatorRules.validator(context, value);
//            },
//      onSaved: onSaved,
//      maxLength: validatorRules.maxLength,
//      onChanged: onChanged,
//      initialValue: initialValue,
//      obscureText: obscureText,
//      maxLines: maxLines,
//      controller: controller,
//      autocorrect: false,
//      maxLengthEnforced: false,
//      keyboardType: keyboardType,
//      textAlign: textAlign,
//      focusNode: focusNode,
//      style:   TextStyle(fontSize: 16.0, color: AppVar.qbankBloc.theme.textFieldTextColor),
//      decoration: InputDecoration(
//        counterStyle: counterColor == null ? TextStyle(fontSize: 8) : TextStyle(fontSize: 8, color: counterColor),
//        focusedErrorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.redAccent)),
//        errorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.redAccent)),
//        enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.white)),
//        //hintText: hintText,
//        labelText: labelText,
//        labelStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 13),
//        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
//        focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Color(0xff2F80ED))),
//      ),
//    );
//  }
//}
