import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../localization/usefully_words.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';

class NewPaymentPlanWidget extends StatefulWidget {
  final String studentKey;
  final String paymentTypeKey;

  NewPaymentPlanWidget({required this.paymentTypeKey, required this.studentKey});
  @override
  _NewPaymentPlanWidgetState createState() => _NewPaymentPlanWidgetState();
}

class _NewPaymentPlanWidgetState extends State<NewPaymentPlanWidget> {
  GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  double? _baslangicUcreti = 0;
  final List<EkBaslangicTutari> _ekBaslangicTutari = [];
  double get _fullUcret => _baslangicUcreti! + (_ekBaslangicTutari.fold(0, (p, e) => p + e.value!));
  int? _segmentCash = 0;
  int _taksitSayisi = 2;
  final List<TextEditingController> _controllerList = Iterable.generate(20).map((i) => TextEditingController(text: '0')).toList();
  final TextEditingController _startPriceController = TextEditingController(text: '0');
  final TextEditingController _amountController = TextEditingController(text: '0');
  final TextEditingController _cashController = TextEditingController(text: '0');
  List<TaksitModel>? _taksitListesi;
  double? _sozlesmeTutari = 0;
  final _pesinat = TaksitModel()
    ..tutar = 0
    ..aktif = true
    ..name = '0'
    ..tarih = DateTime.now().millisecondsSinceEpoch;
  double _birimTaksit = 0.0;
  double _ilkTaksit = 0.0;
  int? _firstpaymentdate = DateTime.now().millisecondsSinceEpoch;
  int? _contractdate = DateTime.now().millisecondsSinceEpoch;

  final List<Indirim> _indirimListesi = [];

  void _taksitListesiniTanimla() {
    _taksitListesi = Iterable.generate(_taksitSayisi)
        .map((i) => TaksitModel()
          ..name = '${i + 1}'
          ..tutar = 0
          ..aktif = true)
        .toList();
    _taksitleriHesapla();
  }

  int _calculateTaksitDate(int taksit) {
    final date1 = DateTime.fromMillisecondsSinceEpoch(_firstpaymentdate!);
    final month = date1.month + taksit;
    return DateTime(date1.year + (month ~/ 12), month % 12, date1.day, date1.hour, date1.minute).millisecondsSinceEpoch;
  }

  void _save() {
    if (Fav.noConnection()) return;

    if (_formKey.currentState!.validate()) {
      if (_baslangicUcreti! < 1 || _sozlesmeTutari! < 1 || _pesinat.tutar! < 0 || _birimTaksit < 0 || _ilkTaksit < 0) {
        OverAlert.show(type: AlertType.danger, message: 'errvalidation'.translate);
        return;
      }
      _formKey.currentState!.save();
      PaymentModel paymentModel = PaymentModel();
      paymentModel.aktif = true;
      paymentModel.pesinat = _pesinat..name = 'advancepayment'.translate;
      paymentModel.ilkTaksitTarihi = _firstpaymentdate;
      paymentModel.odemeTuru = _segmentCash;
      paymentModel.tutar = _sozlesmeTutari;
      paymentModel.sozlesmeTarihi = _contractdate;
      paymentModel.baslangicTutari = _baslangicUcreti;
      paymentModel.ekBaslangicTutari = _ekBaslangicTutari;
      paymentModel.indirimler = _indirimListesi;
      if (_segmentCash == 0) {
        paymentModel.pesinUcret = TaksitModel()
          ..tutar = (_sozlesmeTutari! - _pesinat.tutar!)
          ..aktif = true
          ..name = 'price'.translate
          ..tarih = _firstpaymentdate;
      } else {
        for (int i = 0; i < _taksitListesi!.length; i++) {
          _taksitListesi![i].tarih ??= _calculateTaksitDate(i);
        }

        paymentModel.taksitSayisi = _taksitSayisi;
        paymentModel.taksitler = _taksitListesi;
      }

      setState(() {
        _isLoading = true;
      });

      AccountingService.addAccountingContract(widget.paymentTypeKey, paymentModel.mapForSave(), widget.studentKey).then((a) {}).catchError((error) {
        if (mounted) {
          OverAlert.saveErr();
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      OverAlert.fillRequired();
    }
  }

  void _startPriceChanged() {
    _sozlesmeTutari = _indirimListesi.fold<double>(_fullUcret, (total, discount) {
      if (discount.type == 1) return total - discount.oran!;
      return total * (100 - discount.oran!) / 100;
    });
    _amountController.text = _sozlesmeTutari!.toStringAsFixed(2);
    if (_segmentCash == 1) {
      _taksitleriHesapla();
    }
  }

  void _indirimChanged() {
    _startPriceChanged();
  }

  void _sozlesmeTutariChanged() {
    _baslangicUcreti = _indirimListesi.reversed.fold(_sozlesmeTutari, (total, discount) {
      if (discount.type == 1) return total! + discount.oran!;
      return total! * 100 / (100 - discount.oran!);
    });

    _ekBaslangicTutari.forEach((item) {
      _baslangicUcreti = _baslangicUcreti! - item.value!;
    });

    _startPriceController.text = _baslangicUcreti!.toStringAsFixed(2);
    if (_segmentCash == 1) {
      _taksitleriHesapla();
    }
  }

  void _pesinatChanged() {
    if (_segmentCash == 1) {
      _taksitleriHesapla();
    }
  }

  void _taksitChanged() {
    _sozlesmeTutari = _taksitListesi!.fold(0.0, (dynamic toplam, value) => toplam + value.tutar) + _pesinat.tutar;
    _baslangicUcreti = _indirimListesi.reversed.fold(_sozlesmeTutari, (total, discount) {
      if (discount.type == 1) return total! + discount.oran!;
      return total! * 100 / (100 - discount.oran!);
    });
    _ekBaslangicTutari.forEach((item) {
      _baslangicUcreti = _baslangicUcreti! - item.value!;
    });
    _amountController.text = _sozlesmeTutari!.toStringAsFixed(2);
    _startPriceController.text = _baslangicUcreti!.toStringAsFixed(2);
  }

  void _taksitSayisiChanged() {
    _taksitleriHesapla();
  }

  void _taksitleriHesapla() {
    _birimTaksit = ((_sozlesmeTutari! - _pesinat.tutar!) ~/ _taksitSayisi - (_sozlesmeTutari! - _pesinat.tutar!) ~/ _taksitSayisi % 5).toDouble();
    _ilkTaksit = _sozlesmeTutari! - _pesinat.tutar! - _birimTaksit * (_taksitSayisi - 1);
    for (int i = 0; i < _taksitSayisi; i++) {
      _controllerList[i].text = (i == 0 ? _ilkTaksit : _birimTaksit).toStringAsFixed(2);
      _taksitListesi![i].tutar = (i == 0 ? _ilkTaksit : _birimTaksit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyForm(
      formKey: _formKey,
      child: Column(
        children: <Widget>[
          Container(margin: const EdgeInsets.only(top: 8.0), height: 2, width: double.infinity, color: Fav.design.customDesign4.primary),
          Container(
            color: Fav.design.customDesign4.primary.withAlpha(7),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: MyDatePicker(
                          onSaved: (value) {
                            _contractdate = value;
                          },
                          title: 'dateofcontract'.translate,
                          initialValue: _contractdate),
                    ),
                    Expanded(
                      flex: 2,
                      child: MyTextFormField(
                        textAlign: TextAlign.end,
                        onChanged: (text) {
                          setState(() {
                            _baslangicUcreti = double.tryParse(text!) ?? 0;
                            _startPriceChanged();
                          });
                        },
                        controller: _startPriceController,
                        labelText: 'startprice'.translate,
                        iconData: MdiIcons.currencyTry,
                        validatorRules: ValidatorRules(mustNumber: true, req: true, minValue: 1),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Center(
                        child: MyPopupMenuButton(
                            child: Icons.more_vert.icon.color(Fav.design.primaryText).make(),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(value: 0, child: 'addanotherpayment'.translate.text.make()),
                                if (_ekBaslangicTutari.isNotEmpty) PopupMenuItem(value: 1, child: 'deleteanotherpayment'.translate.text.make()),
                              ];
                            },
                            onSelected: (value) {
                              if (value == 0) {
                                setState(() {
                                  _ekBaslangicTutari.add(EkBaslangicTutari()
                                    ..name = ''
                                    ..value = 0);
                                });
                              } else if (value == 1) {
                                setState(() {
                                  _ekBaslangicTutari.clear();
                                });
                              }
                            }),
                      ),
                    ),
                  ],
                ),
                ..._ekBaslangicTutari
                    .map((e) => Row(
                          key: ObjectKey(e),
                          children: [
                            Expanded(
                              flex: 3,
                              child: MyTextFormField(
                                onChanged: (text) {
                                  e.name = text;
                                },
                                initialValue: e.name,
                                validatorRules: ValidatorRules(minLength: 3, req: true),
                                labelText: 'paymentname'.translate,
                                iconData: MdiIcons.currencyTry,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: MyTextFormField(
                                textAlign: TextAlign.end,
                                onChanged: (text) {
                                  setState(() {
                                    e.value = double.tryParse(text!) ?? 0;
                                    _startPriceChanged();
                                  });
                                },
                                initialValue: e.value!.toStringAsFixed(2),
                                labelText: 'amount'.translate,
                                iconData: MdiIcons.currencyTry,
                                validatorRules: ValidatorRules(mustNumber: true, req: true, minValue: 1),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _ekBaslangicTutari.remove(e);
                                    _indirimChanged();
                                  });
                                })
                          ],
                        ))
                    .toList()
              ],
            ),
          ),
          Container(margin: const EdgeInsets.only(bottom: 8.0), height: 2, width: double.infinity, color: Fav.design.customDesign4.primary),
          MyPopupMenuButton(
            child: 'adddiscount'.translate.text.color(Colors.white).make().stadium(background: Fav.design.primary),
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 0, child: 'percentagediscount'.translate.text.make()),
                PopupMenuItem(value: 1, child: 'feediscount'.translate.text.make()),
              ];
            },
            onSelected: (value) {
              if (value is int) {
                setState(() {
                  _indirimListesi.add(Indirim()
                    ..name = ''
                    ..type = value
                    ..oran = 0);
                });
              }
            },
          ),
          Column(
            children: [
              ..._indirimListesi.map((discount) {
                return Row(
                  key: ObjectKey(discount),
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: MyTextFormField(
                        labelText: 'name'.translate,
                        validatorRules: ValidatorRules(minLength: 3, req: true),
                        initialValue: discount.name,
                        onChanged: (text) {
                          discount.name = text;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: MyTextFormField(
                        labelText: (discount.type == 0 ? 'rate' : 'amount').translate,
                        initialValue: discount.oran.toString(),
                        validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
                        textAlign: TextAlign.end,
                        //  initialValue: discount.oran.toString(),
                        onChanged: (text) {
                          setState(() {
                            discount.oran = (int.tryParse(text!) ?? 0);
                            _indirimChanged();
                          });
                        },
                        suffixIcon: discount.type == 0 ? '%'.text.bold.color(Fav.design.primary).make().pr8 : null,
                      ),
                    ),
                    //  if (discount.type == 0) '%'.text.bold.color(Fav.design.primary).make().px8,
                    IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _indirimListesi.remove(discount);
                            _indirimChanged();
                          });
                        })
                  ],
                );
              }).toList()
            ],
          ),
          Container(margin: const EdgeInsets.only(top: 8.0), height: 2, width: double.infinity, color: Fav.design.customDesign4.primary),
          GroupWidget(
            children: <Widget>[
              MyTextFormField(
                textAlign: TextAlign.end,
                onChanged: (text) {
                  setState(() {
                    _sozlesmeTutari = double.tryParse(text!) ?? 0;
                    _sozlesmeTutariChanged();
                  });
                },
                controller: _amountController,
                labelText: 'contractamount'.translate,
                iconData: MdiIcons.fileDocumentEdit,
                validatorRules: ValidatorRules(mustNumber: true, req: true, minValue: 1),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              CupertinoSlidingSegmentedControl(
                onValueChanged: (dynamic value) {
                  setState(() {
                    _segmentCash = value;
                    if (value == 1) {
                      _taksitListesiniTanimla();
                    }
                  });
                },
                groupValue: _segmentCash,
                children: {0: Text('cash'.translate), 1: Text('installment'.translate)},
              ),
            ],
          ),
          GroupWidget(
            children: <Widget>[
              MyTextFormField(
                onChanged: (text) {
                  setState(() {
                    _pesinat.tutar = double.tryParse(text!) ?? 0;
                    _pesinatChanged();
                  });
                },
                controller: _cashController,
                textAlign: TextAlign.end,
                labelText: 'advancepayment'.translate,
                iconData: MdiIcons.cash,
                validatorRules: ValidatorRules(mustNumber: true, req: true),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              _segmentCash == 1
                  ? AdvanceDropdown(
                      iconData: MdiIcons.formatListNumbered,
                      name: 'installmentnumber'.translate,
                      initialValue: _taksitSayisi,
                      items: Iterable.generate(19)
                          .map((i) => DropdownItem(
                                name: '${i + 2}',
                                value: i + 2,
                              ))
                          .toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          _taksitSayisi = value;
                          _taksitListesiniTanimla();
                          _taksitSayisiChanged();
                        });
                      })
                  : AbsorbPointer(
                      absorbing: true,
                      child: MyTextFormField(
                        controller: TextEditingController(text: (_sozlesmeTutari! - _pesinat.tutar!).toStringAsFixed(2)),
                        textAlign: TextAlign.end,
                        labelText: 'remainingfee'.translate,
                        iconData: MdiIcons.cashRefund,
                        validatorRules: ValidatorRules(
                          mustNumber: true,
                          req: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      )),
            ],
          ),
          if (_segmentCash == 0)
            MyDatePicker(
              initialValue: _firstpaymentdate,
              onSaved: (value) {
                _firstpaymentdate = value;
              },
              title: _segmentCash == 0 ? 'dateofpayment'.translate : 'firstpaymentdate'.translate,
            ),
          if (_segmentCash == 1) Text('installments'.translate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Fav.design.primaryText)),
          if (_segmentCash == 1)
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: Iterable.generate(_taksitSayisi).map((i) {
                      return Card(
                        color: Fav.design.card.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        child: SizedBox(
                          width: 400,
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Fav.design.primaryText,
                                radius: 12,
                                child: Text(
                                  "${i + 1}",
                                  style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              8.widthBox,
                              Expanded(
                                flex: 2,
                                child: MyTextFormField(
                                  padding: EdgeInsets.zero,
                                  validatorRules: ValidatorRules(mustNumber: true, req: true),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.end,
                                  controller: _controllerList[i],
                                  onChanged: (text) {
                                    setState(() {
                                      _taksitListesi![i].tutar = double.tryParse(text!) ?? 0;
                                      _taksitChanged();
                                    });
                                  },
                                ),
                              ),
                              8.widthBox,
                              Expanded(
                                flex: 3,
                                child: MyDatePicker(
                                  padding: EdgeInsets.zero,
                                  onChanged: (value) async {
                                    if (i == 0) {
                                      _firstpaymentdate = value;
                                      final _sure = await Over.sure(title: 'accountingwarning1'.translate, cancelText: 'no'.translate);
                                      if (_sure) {
                                        for (var t = 0; t < _taksitListesi!.length; t++) {
                                          _taksitListesi![t].tarih = _calculateTaksitDate(t);
                                        }
                                        setState(() {
                                          _formKey = GlobalKey();
                                        });
                                      }
                                    }
                                  },
                                  initialValue: _taksitListesi![i].tarih ?? _calculateTaksitDate(i),
                                  onSaved: (value) {
                                    _taksitListesi![i].tarih = value;
                                  },
                                  title: 'dateofpayment'.translate,
                                ),
                              ),
                            ],
                          ),
                        ).p8,
                      );
                    }).toList()),
              ),
            ),
          8.heightBox,
          MyProgressButton(label: Words.save, onPressed: _save, isLoading: _isLoading),
        ],
      ),
    );
  }
}
