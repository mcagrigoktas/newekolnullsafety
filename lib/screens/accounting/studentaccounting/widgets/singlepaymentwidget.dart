import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/print/accountingprint.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/models.dart';
import '../../../../services/dataservice.dart';
import '../../account_settings/case_names.dart';

class SinglePaymentWidget extends StatefulWidget {
  final String studentKey;
  final String paymentTypeKey;
  final Map? data;
  SinglePaymentWidget({required this.paymentTypeKey, required this.studentKey, this.data});
  @override
  _SinglePaymentWidgetState createState() => _SinglePaymentWidgetState();
}

class _SinglePaymentWidgetState extends State<SinglePaymentWidget> {
  bool isLoading = false;
  bool addPlanState = false;
  TaksitModel taksit = TaksitModel()..aktif = true;
  GlobalKey<FormState> formKey = GlobalKey();
  TaksitModel? selectedTaksit;
  String? selecTedTaksitKey;
  TextEditingController odemeMiktariController = TextEditingController(text: '0');
  int kasaNo = 0;
  int? payDate = DateTime.now().millisecondsSinceEpoch;

  void savePayment(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    setState(() {
      isLoading = true;
    });
    if (formKey.currentState!.checkAndSave()) {
      AccountingService.addSinglePayment(widget.paymentTypeKey, taksit.mapForSave(), widget.studentKey).then((a) {
        setState(() {
          isLoading = false;
          addPlanState = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void dataCellOnTap(TaksitModel taksit, String key) {
    setState(() {
      selectedTaksit = taksit;
      selecTedTaksitKey = key;
      double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
      odemeMiktariController.text = (taksit.tutar! - odenen).toStringAsFixed(2);
    });
    //  Future.delayed(const Duration(milliseconds: 100), () => widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent - 75, duration: const Duration(milliseconds: 333), curve: Curves.linear));
  }

  List<DataCell> buildDataCell(TaksitModel taksit, String key) {
    double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;

    return [
      taksit.name.text.color(Fav.design.primary).bold.make(),
      (taksit.tarih ?? 0).dateFormat("d-MMM-yy").text.make(),
      taksit.tutar!.toStringAsFixed(2).text.make(),
      odenen.toStringAsFixed(2).text.make(),
      (taksit.tutar! - odenen).toStringAsFixed(2).text.make(),
    ]
        .map<DataCell>(((e) => DataCell(e, onTap: () {
              dataCellOnTap(taksit, key);
            })))
        .toList();
  }

  Widget buildDataTable(context) {
    List<DataRow> rows = [];
    widget.data?.forEach((key, value) {
      final taksit = TaksitModel.fromJson(value);
      if (taksit.aktif == true) {
        rows.add(DataRow(selected: selecTedTaksitKey == key, cells: buildDataCell(taksit, key)));
      }
    });

    return DataTable(
      columns: ['name', 'date', 'quantity', 'paid', 'unpaid'].map((e) => DataColumn(label: Text(e.translate, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)))).toList(),
      rows: rows,
    );
  }

  Widget buildAddPlanWidget() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Text(
            'addcustompayment'.translate.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText),
          ),
          GroupWidget(
            children: <Widget>[
              MyTextFormField(
                iconData: MdiIcons.dropbox,
                labelText: 'name'.translate,
                validatorRules: ValidatorRules(minLength: 6, req: true),
                onSaved: (value) {
                  taksit.name = value;
                },
              ),
              MyTextFormField(
                iconData: MdiIcons.cash,
                labelText: 'price'.translate,
                validatorRules: ValidatorRules(req: true, mustNumber: true, minLength: 1),
                onSaved: (value) {
                  taksit.tutar = double.tryParse(value);
                },
              ),
            ],
          ),
          MyDatePicker(
            initialValue: DateTime.now().millisecondsSinceEpoch,
            title: 'date'.translate,
            onSaved: (value) {
              taksit.tarih = value;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MyRaisedButton(
                text: 'cancel'.translate,
                onPressed: () {
                  setState(() {
                    addPlanState = false;
                  });
                },
              ),
              MyProgressButton(
                isLoading: isLoading,
                onPressed: () {
                  savePayment(context);
                },
                label: Words.save,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPayWidget(bool isMini) {
    if (selectedTaksit == null) return const SizedBox();

    final _removePaymentWidget = MyPopupMenuButton(
        child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
        onSelected: (value) {
          if (value == 1) {
            removePayment();
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(value: 1, child: Text('removecustompayment'.translate, style: TextStyle(color: Fav.design.primaryText))),
          ];
        });

    final _caseNumberWidget = AdvanceDropdown<int>(
      padding: const EdgeInsets.all(0.0),
      items: Iterable.generate(maxCaseNumber + 1)
          .map((i) => DropdownItem<int>(
                value: i,
                name: i == 0 ? 'casenumber'.translate : AppVar.appBloc.schoolInfoService!.singleData!.caseName(i),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          kasaNo = value;
        });
      },
      initialValue: kasaNo,
    );

    final _datePickerWidget = MyDatePicker(
        padding: EdgeInsets.zero,
        onChanged: (value) {
          payDate = value;
        },
        title: 'date'.translate,
        initialValue: payDate);

    final _miktarWidget = MyTextFormField(
      padding: EdgeInsets.zero,
      textAlign: TextAlign.end,
      validatorRules: ValidatorRules(req: true, mustNumber: true, minLength: 1),
      controller: odemeMiktariController,
      labelText: ''.translate,
    );

    final _saveButton = MyProgressButton(isLoading: isLoading, onPressed: pay, label: Words.save);

    Widget _current;
    if (isMini) {
      _current = Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(child: _caseNumberWidget),
              8.widthBox,
              Expanded(child: _datePickerWidget),
            ],
          ),
          8.heightBox,
          _miktarWidget,
          8.heightBox,
          Row(
            children: <Widget>[
              _removePaymentWidget,
              Spacer(),
              _saveButton,
            ],
          ),
        ],
      );
    } else {
      _current = Row(
        children: <Widget>[
          _removePaymentWidget,
          Expanded(child: _caseNumberWidget),
          8.widthBox,
          Expanded(flex: 2, child: _datePickerWidget),
          Expanded(flex: 2, child: _miktarWidget.px8),
          _saveButton,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.greenAccent.withAlpha(20),
      child: _current,
    );
  }

  Future<void> pay() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (kasaNo == 0) {
      OverAlert.show(type: AlertType.danger, message: 'choosecasewarning'.translate);
      return;
    }
    setState(() {
      isLoading = true;
    });

    double odenen = selectedTaksit!.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
    double kalan = selectedTaksit!.tutar! - odenen;
    double odenecekMiktar = double.tryParse(odemeMiktariController.text) ?? 0.0;
    if (odenecekMiktar < 1 || odenecekMiktar > kalan) {
      OverAlert.show(type: AlertType.danger, message: 'checkpaymentamount'.translate);
      setState(() {
        isLoading = true;
      });
      return;
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

    await AccountingService.payAccounting(widget.paymentTypeKey, selectedTaksit!.odemeler!.map((odeme) => odeme.mapForSave()).toList(), faturaData, widget.studentKey, selecTedTaksitKey, selectedTaksit!.name, faturaNo).then((a) {
      setState(() {
        isLoading = false;
      });
      selectedTaksit = null;
      selecTedTaksitKey = null;
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

  Widget buildPastPayments() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runSpacing: 4.0,
      spacing: 4.0,
      children: (selectedTaksit!.odemeler ?? [])
          .map((odeme) => Chip(
                label: MyKeyValueText(textKey: odeme.tarih!.dateFormat("d-MMM-yy"), value: odeme.miktar!.toStringAsFixed(2)),
                deleteIcon: const Icon(Icons.clear),
                backgroundColor: Fav.design.customColors2[1],
                onDeleted: () {
                  odemeSil(odeme);
                },
              ))
          .toList(),
    );
  }

  Future<void> odemeSil(Odeme odeme) async {
    if (Fav.noConnection()) return;

    setState(() {
      isLoading = true;
    });
    if ((await Over.sure(message: 'deletepaidwarning'.translate)) == false) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    int? faturaNo = odeme.faturaNo;
    selectedTaksit!.odemeler!.remove(odeme);

    await AccountingService.deletePayAccounting(widget.paymentTypeKey, selectedTaksit!.odemeler!.map((odeme) => odeme.mapForSave()).toList(), widget.studentKey, selecTedTaksitKey, selectedTaksit!.name, faturaNo).then((a) {
      setState(() {
        isLoading = false;
      });
      selectedTaksit = null;
      selecTedTaksitKey = null;
      OverAlert.saveSuc();
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  Future<void> removePayment() async {
    if (Fav.noConnection()) return;

    setState(() {
      isLoading = true;
    });
    if ((await Over.sure(message: 'removecustompaymenthint'.translate)) == false) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    await AccountingService.removeCustomPayment(widget.studentKey, selecTedTaksitKey!).then((a) {
      selectedTaksit = null;
      selecTedTaksitKey = null;
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        widget.data != null ? Flexible(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: buildDataTable(context)))) : const SizedBox(),
        16.heightBox,
        buildPayWidget(context.screenWidth < 700),
        if (selectedTaksit != null) Divider(color: Fav.design.customDesign4.accent),
        if (selectedTaksit?.odemeler != null) buildPastPayments(),
        if (addPlanState) buildAddPlanWidget(),
        16.heightBox,
        if (!addPlanState)
          MyRaisedButton(
            text: 'addcustompayment'.translate,
            onPressed: () {
              setState(() {
                addPlanState = true;
              });
            },
          ),
      ],
    );
  }
}
