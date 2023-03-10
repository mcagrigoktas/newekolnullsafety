import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../assets.dart';
import '../../../../helpers/print/accountingprint.dart';
import '../../../../library_helper/printing/eager.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../../account_settings/case_names.dart';

class PaymentPlanWidget extends StatefulWidget {
  final Map? data;
  final String studentKey;
  final String paymentTypeKey;
  PaymentPlanWidget({this.data, required this.studentKey, required this.paymentTypeKey});
  @override
  _PaymentPlanWidgetState createState() => _PaymentPlanWidgetState();
}

class _PaymentPlanWidgetState extends State<PaymentPlanWidget> {
  late PaymentModel data;
  TaksitModel? selectedTaksit;
  String? selecTedKey;
  TextEditingController odemeMiktariController = TextEditingController(text: '0');
  int? payDate = DateTime.now().millisecondsSinceEpoch;
  bool isLoading = false;
  int kasaNo = 0;

  @override
  void didUpdateWidget(covariant PaymentPlanWidget oldWidget) {
    if (oldWidget.data.hashCode != widget.data.hashCode) {
      data = PaymentModel.fromJson(widget.data!);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    data = PaymentModel.fromJson(widget.data!);
  }

  void dataCellOnTap(TaksitModel taksit, String selecTedKey) {
    setState(() {
      selectedTaksit = taksit;
      this.selecTedKey = selecTedKey;
      double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
      odemeMiktariController.text = (taksit.tutar! - odenen).toStringAsFixed(2);
    });
    //  Future.delayed(const Duration(milliseconds: 100), () => widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent - 75, duration: const Duration(milliseconds: 333), curve: Curves.linear));
  }

  List<String> columnNames = [
    'name'.translate,
    'date'.translate,
    'quantity'.translate,
    'paid'.translate,
    'unpaid'.translate,
  ];

  late double totalTutar;
  late double totalOdenen;
  Widget _buildDataTable() {
    totalTutar = 0;
    totalOdenen = 0;
    List<DataRow> rows = [];
    rows.add(DataRow(selected: selectedTaksit?.name == data.pesinat!.name, cells: _buildDataCell(data.pesinat!, 'pesinat')));

    if (data.odemeTuru == 0) {
      rows.add(DataRow(selected: selectedTaksit?.name == data.pesinUcret!.name, cells: _buildDataCell(data.pesinUcret!, 'pesinUcret')));
    } else {
      data.taksitler!.forEach((taksit) {
        rows.add(DataRow(selected: selectedTaksit?.name == taksit.name, cells: _buildDataCell(taksit, 'taksitler')));
      });
    }
    return DataTable(
      columns: columnNames.map((item) => DataColumn(label: Text(item, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)))).toList(),
      rows: rows
        ..add(DataRow(
            selected: false,
            cells: [
              'total'.translate.text.color(Fav.design.primary).bold.make(),
              ''.text.make(),
              totalTutar.toStringAsFixed(2).text.make(),
              totalOdenen.toStringAsFixed(2).text.make(),
              (totalTutar - totalOdenen).toStringAsFixed(2).text.make(),
            ].map((e) => DataCell(e)).toList(),
            color: MaterialStateColor.resolveWith((states) => Fav.design.primary.withAlpha(25)))),
    );
  }

  List<DataCell> _buildDataCell(TaksitModel taksit, String selecTedKey) {
    double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
    totalTutar += taksit.tutar!;
    totalOdenen += odenen;
    return [
      taksit.tutar == 0 && int.tryParse(taksit.name!) != null ? 'erased'.translate.text.color(Fav.design.primary).bold.make() : taksit.name.text.color(Fav.design.primary).bold.make(),
      taksit.tarih!.dateFormat("d-MMM-yy").text.make(),
      taksit.tutar!.toStringAsFixed(2).text.make(),
      odenen.toStringAsFixed(2).text.make(),
      (taksit.tutar! - odenen).toStringAsFixed(2).text.make(),
    ]
        .map<DataCell>(((e) => DataCell(e, onTap: () {
              dataCellOnTap(taksit, selecTedKey);
            })))
        .toList();
  }

  Widget buildPayWidget(bool screenIsMini) {
    if (selectedTaksit == null) {
      return Row(children: [_buildOptionsButton(data)]);
    }

    final _changeTaksitButton = MyPopupMenuButton(
        child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
        onSelected: (value) {
          if (value == 1) {
            _openChangeTaksitMenu();
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(value: 1, child: Text('changeamount'.translate, style: TextStyle(color: Fav.design.primaryText))),
          ];
        });

    final _changeCaseButton = AdvanceDropdown<int>(
      padding: const EdgeInsets.all(0.0),
      items: Iterable.generate(
        maxCaseNumber + 1,
        (index) => index,
      ).map((i) => DropdownItem<int>(value: i, name: i == 0 ? 'casenumber'.translate : AppVar.appBloc.schoolInfoService!.singleData!.caseName(i))).toList(),
      onChanged: (value) {
        setState(() {
          kasaNo = value;
        });
      },
      initialValue: kasaNo,
    );
    final _datePickerButton = MyDatePicker(
        padding: EdgeInsets.only(left: 8),
        onChanged: (value) {
          payDate = value;
        },
        title: 'date'.translate,
        initialValue: payDate);

    final _miktarButton = MyTextFormField(
      padding: EdgeInsets.symmetric(horizontal: 0),
      textAlign: TextAlign.end,
      validatorRules: ValidatorRules(req: true, mustNumber: true, minLength: 1),
      controller: odemeMiktariController,
      labelText: ''.translate,
    );
    final _saveButton = MyProgressButton(isLoading: isLoading, onPressed: pay, label: Words.save);

    Widget _current;
    if (screenIsMini) {
      _current = Column(
        children: [
          Row(
            children: <Widget>[
              _changeTaksitButton,
              Expanded(flex: 1, child: _changeCaseButton),
              Expanded(flex: 1, child: _datePickerButton),
            ],
          ),
          4.heightBox,
          _miktarButton,
          4.heightBox,
          Row(
            children: <Widget>[
              _buildOptionsButton(data),
              Spacer(),
              _saveButton,
            ],
          ),
        ],
      );
    } else {
      _current = Row(
        children: <Widget>[
          _buildOptionsButton(data),
          12.widthBox,
          _changeTaksitButton,
          Expanded(flex: 1, child: _changeCaseButton),
          Expanded(flex: 2, child: _datePickerButton),
          Expanded(flex: 2, child: _miktarButton.px8),
          _saveButton,
        ],
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8.0),
      color: Colors.greenAccent.withAlpha(20),
      child: _current,
    );
  }

  Widget _buildPastPayments() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runSpacing: 4.0,
      spacing: 4.0,
      children: (selectedTaksit!.odemeler ?? [])
          .map((odeme) => Container(
                margin: Inset(2),
                height: 32,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.print),
                      color: Colors.white,
                      onPressed: () {
                        var student = AppVar.appBloc.studentService!.dataListItem(widget.studentKey)!;
                        PrintAccounting.printMakbuz(context, student, tutar: odeme.miktar, paymentTypeKey: widget.paymentTypeKey, faturaNo: odeme.faturaNo, paymentName: selectedTaksit!.name!, date: odeme.tarih);
                      },
                    ),
                    MyKeyValueText(textKey: odeme.tarih!.dateFormat("d-MMM-yy"), value: odeme.miktar!.toStringAsFixed(2)),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        odemeSil(odeme);
                      },
                    ),
                  ],
                ),
                decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), color: Colors.green),
              ))
          .toList(),
    );
  }

  Widget _buildOptionsButton(PaymentModel data) {
    return QudsPopupButton(
      backgroundColor: Fav.design.scaffold.background,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: Fav.design.elevatedButton.background),
        child: Row(
          children: [
            const Icon(Icons.list, color: Colors.white),
            8.widthBox,
            Text('options'.translate, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      items: [
        QudsPopupMenuWidget(builder: (context) {
          var _info = {
            ('dateofcontract'.translate + ': '): data.sozlesmeTarihi!.dateFormat("d-MMM-yy"),
            ('startprice'.translate + ': '): data.baslangicTutari!.toStringAsFixed(2),
          };
          if (data.ekBaslangicTutari != null) _info.addAll(data.ekBaslangicTutari!.fold<Map<String, String>>(<String, String>{}, (p, item) => p..[item.name! + ': '] = item.value!.toStringAsFixed(2)));
          if ((data.indirimler?.length ?? 0) > 0) _info.addAll(data.indirimler!.fold<Map<String, String>>(<String, String>{}, (p, item) => p..[item.name! + ': '] = '-' + item.oran.toString() + (item.type == 0 ? '%' : '')));
          _info.addAll({
            'contractamount'.translate + ': ': data.tutar!.toStringAsFixed(2),
          });

          return Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              ..._info.entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(e.key, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(e.value, style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          );
        }),
        if (data.notes != null) QudsPopupMenuDivider(),
        if (data.notes != null)
          QudsPopupMenuWidget(builder: (context) {
            return data.notes!.values.join('\n').text.color(Fav.design.primary).make().p2;
          }),
        QudsPopupMenuDivider(),
        QudsPopupMenuItem(
            leading: Icons.print.icon.color(Fav.design.primaryText).make(),
            title: 'print1'.translate.text.make(),
            onPressed: () async {
              var student = AppVar.appBloc.studentService!.dataListItem(widget.studentKey);
              if ('lang'.translate == 'tr') {
                await PrintAccounting.printStudentAccountingForTurkey(student!, columnNames, data);
                await 1000.wait;
                var sure = await Over.sure(title: 'Kayıt sözleşmeside çıkartılsın mı?');
                if (sure) {
                  await PrintLibraryHelper.printAssetFilePdf(Assets.files.kayitsozlesmesiPDF);
                }
              } else {
                await PrintAccounting.printStudentAccounting(student!, columnNames, data);
              }
            }),
        QudsPopupMenuItem(
            leading: Icons.print.icon.color(Fav.design.primaryText).make(),
            title: 'print2'.translate.text.make(),
            onPressed: () async {
              var student = AppVar.appBloc.studentService!.dataListItem(widget.studentKey);
              await PrintAccounting.printAccountingVoucher(context, student, columnNames, data);
            }),
        if (data.odemeTuru == 1) QudsPopupMenuDivider(),
        if (data.odemeTuru == 1)
          QudsPopupMenuItem(
            leading: Icons.add_box_rounded.icon.color(Fav.design.primaryText).make(),
            title: 'addnewinstallament'.translate.text.make(),
            onPressed: _openAddTaksitMenu,
          ),
        if (data.odemeTuru == 1)
          QudsPopupMenuItem(
            leading: Icons.disabled_by_default_sharp.icon.color(Colors.red).make(),
            title: 'deletelastinstallament'.translate.text.color(Colors.red).make(),
            onPressed: _deleteLastInstallament,
          ),
        QudsPopupMenuDivider(),
        QudsPopupMenuItem(leading: Icons.delete.icon.color(Colors.red).make(), title: 'deletepaymentplan'.translate.text.color(Colors.red).make(), onPressed: _deletePaymentPlan),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: _buildDataTable()))),
        if (selectedTaksit?.odemeler != null) _buildPastPayments(),
        buildPayWidget(context.screenWidth < 700),
      ],
    );
  }

  Future<void> _openChangeTaksitMenu() async {
    double odenen = selectedTaksit!.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
    double? eskiTutar = selectedTaksit!.tutar;
    int? taksitNo = int.tryParse(selectedTaksit!.name!);
    String? taksitAdi;
    if (taksitNo == null) {
      taksitAdi = selectedTaksit!.name;
    } else {
      taksitAdi = (taksitNo - 1).toString();
    }
    double? newTutar;
    final formKey = GlobalKey<FormState>();

    final _amount = await OverBottomSheet.show(BottomSheetPanel.child(
        child: Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextFormField(
              enableInteractiveSelection: false,
              labelText: 'enternewamount'.translate,
              validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: odenen),
              initialValue: selectedTaksit!.tutar.toString(),
              onSaved: (value) {
                newTutar = double.tryParse(value);
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyFlatButton(
                text: 'cancel'.translate,
                onPressed: () {
                  OverBottomSheet.closeBottomSheet();
                },
              ).pr16,
              MyRaisedButton(
                text: 'ok'.translate,
                onPressed: () {
                  if (Fav.noConnection()) return;
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    OverBottomSheet.selectBottomSheetItem(newTutar);
                  }
                },
              ).pr16,
            ],
          ),
          16.heightBox,
        ],
      ),
    )));
    if (_amount == null) return;
    setState(() {
      isLoading = true;
    });
    await AccountingService.birTaksidiDegistir(widget.paymentTypeKey, widget.studentKey, selecTedKey!, taksitAdi, eskiTutar!, newTutar!).then((value) {
      setState(() {
        isLoading = false;
      });

      selectedTaksit!.tutar = newTutar;
      selectedTaksit = null;
      OverAlert.saveSuc();
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  Future<void> _openAddTaksitMenu() async {
    if (data.taksitler!.length > 19) {
      OverAlert.anError();
      return;
    }

    double? _newTutar = 0.0;
    int? _date = DateTime.now().millisecondsSinceEpoch;

    GlobalKey<FormState> _formKey = GlobalKey();

    final _amount = await OverBottomSheet.show(BottomSheetPanel.child(
        child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextFormField(
              enableInteractiveSelection: false,
              labelText: 'enternewamount'.translate,
              validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 0.1),
              initialValue: _newTutar.toString(),
              onSaved: (value) {
                _newTutar = double.tryParse(value);
              }),
          MyDatePicker(
            onSaved: (value) {
              _date = value;
            },
            initialValue: _date,
            title: 'date'.translate,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyFlatButton(
                text: 'cancel'.translate,
                onPressed: () {
                  OverBottomSheet.closeBottomSheet();
                },
              ).pr16,
              MyRaisedButton(
                text: 'ok'.translate,
                onPressed: () {
                  if (Fav.noConnection()) return;
                  if (_formKey.currentState!.checkAndSave()) {
                    OverBottomSheet.selectBottomSheetItem(_newTutar);
                  }
                },
              ).pr16,
            ],
          ),
          16.heightBox,
        ],
      ),
    )));

    if (_amount == null || _amount == 0.0) return;
    setState(() {
      isLoading = true;
    });

    await AccountingService.addNewInstalament(
      widget.paymentTypeKey,
      widget.studentKey,
      data.taksitler!.length.toString(),
      TaksitModel()
        ..name = (data.taksitler!.length + 1).toString()
        ..tutar = _newTutar
        ..aktif = true
        ..tarih = _date,
    ).then((value) async {
      selectedTaksit = null;
      OverAlert.saveSuc();
      setState(() {});
    }).catchError((error) {
      OverAlert.saveErr();
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteLastInstallament() async {
    if (data.taksitler!.length < 3) {
      OverAlert.anError();
      return;
    }
    if (data.taksitler!.last.odemeler != null && data.taksitler!.last.odemeler!.any((element) => element.miktar! > 0)) {
      OverAlert.show(message: 'deletepaymentplanhint1'.translate);
      return;
    }

    final _sure = await Over.sure();
    if (_sure != true) return;

    await AccountingService.deleteLastInstallament(
      widget.paymentTypeKey,
      widget.studentKey,
      (data.taksitler!.length - 1).toString(),
    ).then((value) async {
      selectedTaksit = null;
      OverAlert.saveSuc();
      setState(() {});
    }).catchError((error) {
      OverAlert.saveErr();
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> pay() async {
    if (Fav.noConnection()) return;

    FocusScope.of(context).requestFocus(FocusNode());
    if (kasaNo == 0) return OverAlert.show(type: AlertType.danger, message: 'choosecasewarning'.translate);

    double odenen = selectedTaksit!.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
    double kalan = selectedTaksit!.tutar! - odenen;
    double odenecekMiktar = double.tryParse(odemeMiktariController.text) ?? 0.0;
    if (odenecekMiktar < 1 || odenecekMiktar > kalan) {
      setState(() {
        isLoading = false;
      });
      return OverAlert.show(type: AlertType.danger, message: 'checkpaymentamount'.translate);
    }

    int faturaNo = (await AccountingService.dbInvoiceNumber().once())?.value ?? 1;
    selectedTaksit!.odemeler ??= [];
    selectedTaksit!.odemeler!.add(Odeme()
      ..miktar = odenecekMiktar
      ..kasaNo = kasaNo
      ..tarih = payDate
      ..faturaNo = faturaNo);

    Map faturaData = (FaturaModel()
          ..personKey = widget.studentKey
          ..tarih = payDate
          ..aktif = true
          ..tutar = odenecekMiktar
          ..paymentTypeKey = widget.paymentTypeKey
          ..paymentName = selectedTaksit!.name
          ..kasaNo = kasaNo)
        .mapForSave();

    int? taksitNo = int.tryParse(selectedTaksit!.name!);
    String? taksitAdi;
    if (taksitNo == null) {
      taksitAdi = selectedTaksit!.name;
    } else {
      taksitAdi = (taksitNo - 1).toString();
    }

    setState(() {
      isLoading = true;
    });
    await AccountingService.payAccounting(widget.paymentTypeKey, selectedTaksit!.odemeler!.map((odeme) => odeme.mapForSave()).toList(), faturaData, widget.studentKey, selecTedKey, taksitAdi, faturaNo).then((a) {
      setState(() {
        isLoading = false;
      });
      selectedTaksit = null;
      OverAlert.saveSuc();
      var student = AppVar.appBloc.studentService!.dataListItem(widget.studentKey)!;
      PrintAccounting.printMakbuz(
        context,
        student,
        faturaNo: faturaNo,
        paymentName: FaturaModel.fromJson(faturaData, 'fatura$faturaNo').paymentName!,
        paymentTypeKey: FaturaModel.fromJson(faturaData, 'fatura$faturaNo').paymentTypeKey!,
        tutar: FaturaModel.fromJson(faturaData, 'fatura$faturaNo').tutar,
        date: payDate,
      );
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  Future<void> odemeSil(Odeme odeme) async {
    if (Fav.noConnection()) return;
    setState(() {
      isLoading = true;
    });
    if ((await Over.sure(message: 'deletepaidwarning'.translate)) != true) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    int? faturaNo = odeme.faturaNo;

    selectedTaksit!.odemeler!.remove(odeme);

    var taksitName = selectedTaksit!.name;
    if (selecTedKey == 'taksitler' && int.tryParse(taksitName!) != null) {
      taksitName = (int.tryParse(taksitName)! - 1).toString();
    }

    await AccountingService.deletePayAccounting(widget.paymentTypeKey, selectedTaksit!.odemeler!.map((odeme) => odeme.mapForSave()).toList(), widget.studentKey, selecTedKey, taksitName, faturaNo).then((a) {
      setState(() {
        isLoading = false;
      });
      selectedTaksit = null;
      OverAlert.saveSuc();
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  Future<void> _deletePaymentPlan() async {
    if (Fav.noConnection()) return;

    bool odenmisFaturaVar = false;
    if ((data.pesinat?.odemeler?.length ?? 0) > 0) odenmisFaturaVar = true;
    if ((data.pesinUcret?.odemeler?.length ?? 0) > 0) odenmisFaturaVar = true;
    if (data.taksitler?.any((element) => element.odemeler != null && element.odemeler!.isNotEmpty) == true) odenmisFaturaVar = true;

    if (odenmisFaturaVar) {
      OverAlert.show(message: 'deletepaymentplanhint1'.translate, type: AlertType.danger, autoClose: false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    if ((await Over.sure()) == true) {
      await AccountingService.deleteAccountingContract(widget.paymentTypeKey, widget.studentKey).then((a) {}).catchError((error) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    } else {
      setState(() {
        isLoading = false;
      });
      return;
    }
  }
}
