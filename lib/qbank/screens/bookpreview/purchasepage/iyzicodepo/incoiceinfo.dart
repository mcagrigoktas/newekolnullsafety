//import 'package:flutter/material.dart';
//import 'package:elseifekol/appbloc/appvar.dart';
//
//import 'package:mypackage/mywidgets.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//
//
//class InvoicePage extends StatefulWidget {
//  InvoicePage();
//
//  @override
//  _InvoicePageState createState() =>   _InvoicePageState();
//}
//
//class _InvoicePageState extends State<InvoicePage>  {
//  bool isLoading = false;
//  GlobalKey<FormState> formKey = GlobalKey();
//
//  TextEditingController tcController = TextEditingController();
//  Map _data = {};
//
//  @override
//  void initState() {
//    _data = Map.from(AppVar.qbankBloc.hesapBilgileri.invoiceData ?? {});
//    super.initState();
//
//    tcController.addListener(() {
//      setState(() {});
//    });
//    tcController.value = TextEditingValue(text: _data['tc'] ?? '');
//  }
//
//  save() {
//    FocusScope.of(context).requestFocus(new FocusNode());
//    if (Fav.noConnection() ) {
//      return;
//    }
//    if (formKey.currentState.validate()) {
//      formKey.currentState.save();
//      setState(() {
//        isLoading = true;
//      });
//
//      QBSetDataService.saveInoviceData(_data, AppVar.qbankBloc.hesapBilgileri.uid).then((a) {
//        AppVar.qbankBloc.hesapBilgileri.invoiceData = _data;
//        //  Fav.preferences.setString("qbankHesapBilgileri", AppVar.qbankBloc.hesapBilgileri.toString());
//        AppVar.qbankBloc.hesapBilgileri.savePreferences(AppVar.qbankBloc.myPreferences);
//        Get.back();
//
//        OverAlert.saveSuc();
//      }).catchError((error) {
//        setState(() {
//          isLoading = false;
//        });
//        OverAlert.saveErr();
//      });
//    } else {
//     Alert.alert( message:  "fillrequired"), type: AlertType.danger);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return MyScaffold(
//        appBar: MyAppBar(
//          title:  'Fatura bilgilerim'),
//          visibleBackButton: true,
//        ),
//        body: Form(
//          key: formKey,
//          child: SingleChildScrollView(
//            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//            child: AnimatedGroupWidget(
//              children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      flex: 1,
//                      child: MyTextFormField(
//                        controller: tcController,
//                        labelText:  "tc"),
//                        iconData: MdiIcons.account_card_details,
//                        iconColor: Colors.deepOrangeAccent,
//                        validatorRules: ValidatorRules(hasSpace: false),
//                        onSaved: (value) {
//                          this._data['tc'] = value;
//                        },
//                      ),
//                    ),
//                    CircleAvatar(
//                      radius: 14.0,
//                      backgroundColor: Fav.secondaryDesign.primary,
//                      child: Text(
//                        "${tcController.text.length}",
//                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                      ),
//                    ),
//                    SizedBox(
//                      width: 16.0,
//                    ),
//                  ],
//                ),
//                MyTextFormField(
//                  initialValue: _data['city'],
//                  labelText:  "city"),
//                  iconData: MdiIcons.at,
//                  iconColor: Colors.deepPurpleAccent,
//                  validatorRules: ValidatorRules(),
//                  onSaved: (value) {
//                    _data['city'] = value;
//                  },
//                ),
//                MyTextFormField(
//                  initialValue: _data['adress'],
//                  maxLines: null,
//                  labelText:  'adress'),
//                  iconData: MdiIcons.information,
//                  iconColor: Colors.pink,
//                  onSaved: (value) {
//                    this._data['adress'] = value;
//                  },
//                ),
//                SizedBox(
//                  height: 12,
//                ),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    const SizedBox(),
//                    Padding(
//                      padding: const EdgeInsets.only(right: 16.0),
//                      child: MyProgressButton(
//                        onPressed: save,
//                        label:  "save"),
//                        isLoading: isLoading,
//                      ),
//                    ),
//                  ],
//                ),
//              ],
//            ),
//          ),
//        ));
//  }
//}

/// kredi  karti yada in app secme action sheet menusu istedigin yere  koy
//else {
//      var marketPrice = '';
//      if (_products.length > 0) {
//        ProductDetails prod = _products.singleWhere((item) => item.id == widget.book.priceCode, orElse: () => null);
//        if (prod != null) {
//          marketPrice = prod.price;
//        }
//      }
//
//      var value = await showCupertinoModalPopup(
//        context: context,
//        builder: (context) {
//          return CupertinoActionSheet(
//            title: Text(
//               'chooseprocess'),
//              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppVar.qbankBloc.theme.actionSheetHeaderTextColor),
//            ),
//            actions: [
//              CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.pop(context, 0);
//                  },
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      8.width,
//                      Icon(
//                        Icons.credit_card,
//                        color: AppVar.qbankBloc.theme.actionSheetItemTextColor,
//                      ),
//                      16.width,
//                      Expanded(
//                          child: Text(
//                         'buywithcreditcard'),
//                        style: TextStyle(fontSize: 16.0, color: AppVar.qbankBloc.theme.actionSheetItemTextColor, fontWeight: FontWeight.bold),
//                      )),
//                      16.width,
//                      Container(
//                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                        decoration: ShapeDecoration(color: Colors.grey.withAlpha(50), shape: StadiumBorder()),
//                        child: Text(
//                          widget.book.price,
//                          style: TextStyle(
//                            color: AppVar.qbankBloc.theme.actionSheetItemTextColor,
//                          ),
//                        ),
//                      ),
//                      8.width,
//                    ],
//                  )),
//              CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.pop(context, 1);
//                  },
//                  child: Row(
//                    children: <Widget>[
//                      8.width,
//                      Icon(
//                        Platform.isAndroid ? MdiIcons.google_play : MdiIcons.apple,
//                        color: AppVar.qbankBloc.theme.actionSheetItemTextColor,
//                      ),
//                      16.width,
//                      Expanded(
//                        child: Text(
//                           Platform.isAndroid ? 'buywithgoogleplay' : 'buywithappstore'),
//                          style: TextStyle(fontSize: 16.0, color: AppVar.qbankBloc.theme.actionSheetItemTextColor, fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                      16.width,
//                      Container(
//                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                        decoration: ShapeDecoration(color: Colors.grey.withAlpha(50), shape: StadiumBorder()),
//                        child: Text(
//                          marketPrice,
//                          style: TextStyle(
//                            color: AppVar.qbankBloc.theme.actionSheetItemTextColor,
//                          ),
//                        ),
//                      ),
//                      8.width,
//                    ],
//                  )),
//            ],
//            cancelButton: CupertinoActionSheetAction(
//                isDefaultAction: true,
//                onPressed: () {
//                  Navigator.pop(context, false);
//                },
//                child: Text( 'cancel'))),
//          );
//        },
//      );
//      if (value == 0) {
//        Fav.to(IyziCoPage(widget.book));
//      }
//      if (value == 1) {
//        if (_available == false) {
//         OverAlert.show(type: AlertType.danger, message:  'buyprocesserr'));
//          return;
//        }
//        _buyProducts();
//      }
//   }
