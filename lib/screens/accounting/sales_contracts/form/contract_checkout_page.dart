import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../localization/usefully_words.dart';
import '../controller.dart';
import '../model.dart';
import 'widgets.dart';

class ContractCheckoutPage extends StatelessWidget {
  ContractCheckoutPage();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesContractsController>();
    return IgnorePointer(
      ignoring: controller.selectedContract!.isCompleted!,
      child: Column(
        key: ValueKey(controller.itemData!.key),
        children: [
          Group2Widget(
            children: [
              ContractName(controller: controller),
              SalesContractPersonWidget(controller: controller),
            ],
          ),
          Group2Widget(
            children: [
              StartDate(controller: controller),
              ContractFinishTime(controller: controller),
            ],
          ),
          Group2Widget(
            children: [
              ContractExp(controller: controller),
              Label(controller: controller),
            ],
          ),
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 840,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 18,
                    showCheckboxColumn: true,
                    columns: [
                      DataColumn2(label: SizedBox(), flex: 2),
                      DataColumn2(label: 'name'.translate.text.bold.make(), flex: 5),
                      DataColumn2(label: 'amount'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'discount'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'tax'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'result'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'dateofcontract'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'finishtime'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'aciklama'.translate.text.bold.make(), flex: 8),
                      DataColumn2(label: ''.translate.text.bold.make(), flex: 2),
                    ],
                    rows: controller.itemData!.products!
                        .map((product) => DataRow2(
                              cells: [
                                DataCell((controller.itemData!.products!.indexOf(product) + 1).toString().text.color(Fav.design.primary).bold.make().center),
                                DataCell(product.name.text.make()),
                                DataCell(product.amount!.toStringAsFixed(2).text.make()),
                                DataCell(product.discount!.toStringAsFixed(2).text.make()),
                                DataCell(product.tax!.toStringAsFixed(2).text.make()),
                                DataCell(product.net.toStringAsFixed(2).text.make()),
                                DataCell(product.startDate!.dateFormat("d-MMM-yyyy").text.make()),
                                DataCell(product.endDate!.dateFormat("d-MMM-yyyy").text.make()),
                                DataCell(product.exp.text.make()),
                                DataCell(SizedBox())
                              ].toList(),
                            ))
                        .toList()
                      ..add(DataRow2(
                        color: MaterialStateColor.resolveWith((states) => Fav.design.primary.withAlpha(25)),
                        cells: [
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                          DataCell(controller.itemData!.products!.fold<double>(0.0, (p, e) => p + e.net).toStringAsFixed(2).text.color(Fav.design.primary).bold.make()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                        ].toList(),
                      )),
                  ),
                ),
              )
            ],
          ),
          Divider(),
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 840,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 18,
                    showCheckboxColumn: true,
                    columns: [
                      DataColumn2(
                          label: Icons.add.icon
                              .color(Fav.design.primary)
                              .onPressed(() {
                                final _installament = SalesInstallament()
                                  ..no = controller.itemData!.installaments.length + 1
                                  ..amount = 0
                                  ..exp = ''
                                  ..date = controller.itemData!.installaments.last.date! + Duration(days: 30).inMilliseconds;
                                controller.itemData!.installaments.add(_installament);
                                _openChangeTaksitMenu(context, _installament, showCancelButton: false);
                                controller.update();
                              })
                              .padding(0)
                              .make()
                              .center,
                          flex: 2),
                      DataColumn2(label: 'date'.translate.text.bold.make(), flex: 5),
                      DataColumn2(label: 'amount'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'paid'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'unpaid'.translate.text.bold.make(), flex: 4),
                      DataColumn2(label: 'aciklama'.translate.text.bold.make(), flex: 8),
                      DataColumn2(label: ''.translate.text.bold.make(), flex: 2),
                    ],
                    rows: controller.itemData!.installaments
                        .map((installament) => DataRow2(
                              opacity: installament.kalan < 1.0 ? 0.5 : 1.0,
                              onSelectChanged: (value) {
                                controller.selectInstallamnet(installament);
                              },
                              selected: controller.selectedInstallament == installament,
                              cells: [
                                DataCell(installament.no.toString().text.color(Fav.design.primary).bold.make().center),
                                DataCell(installament.date!.dateFormat("d-MMM-yyyy").text.make()),
                                DataCell(installament.amount!.toStringAsFixed(2).text.make()),
                                DataCell(installament.paid.toStringAsFixed(2).text.make()),
                                DataCell(installament.kalan.toStringAsFixed(2).text.make()),
                                DataCell(MyTextField(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  initialValue: installament.exp,
                                  onChanged: (value) {
                                    installament.exp = value;
                                  },
                                )),
                                DataCell(
                                  MyPopupMenuButton(
                                      child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
                                      onSelected: (value) async {
                                        if (value == 1) {
                                          await _openChangeTaksitMenu(context, installament);
                                        } else if (value == 2) {
                                          controller.itemData!.installaments.remove(installament);
                                        }
                                        controller.update();
                                      },
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(value: 1, child: Text('changeamount'.translate, style: TextStyle(color: Fav.design.primaryText))),
                                          if (installament.paid < 1.0) PopupMenuItem(value: 2, child: Text(Words.delete, style: TextStyle(color: Fav.design.primaryText))),
                                        ];
                                      }),
                                )
                              ].toList(),
                            ))
                        .toList()
                      ..add(DataRow2(
                        color: MaterialStateColor.resolveWith((states) => Fav.design.primary.withAlpha(25)),
                        cells: [
                          DataCell(''.text.color(Fav.design.primary).bold.make()),
                          DataCell(''.text.make()),
                          DataCell(controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + e.amount!).toStringAsFixed(2).text.color(Fav.design.primary).bold.make()),
                          DataCell(controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + e.paid).toStringAsFixed(2).text.color(Fav.design.primary).bold.make()),
                          DataCell(controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + e.kalan).toStringAsFixed(2).text.color(Fav.design.primary).bold.make()),
                          DataCell(SizedBox()),
                          DataCell(SizedBox()),
                        ].toList(),
                      )),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChangeTaksitMenu(BuildContext context, SalesInstallament installament, {bool showCancelButton = true}) async {
    GlobalKey<FormState> formKey = GlobalKey();

    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Material(
              color: Colors.transparent,
              child: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 750),
                      decoration: BoxDecoration(color: Fav.design.scaffold.background, borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.all(32),
                      child: Group2Widget(
                        children: [
                          MyTextFormField(
                              labelText: 'enternewamount'.translate,
                              validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: installament.paid.minLimit(1)),
                              initialValue: installament.amount!.toStringAsFixed(2),
                              onSaved: (value) {
                                if (double.tryParse(value) != null) {
                                  installament.amount = double.tryParse(value);
                                }
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (showCancelButton)
                                MyRaisedButton(
                                  text: 'cancel'.translate,
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                              MyRaisedButton(
                                text: 'ok'.translate,
                                onPressed: () {
                                  if (formKey.currentState!.checkAndSave()) {
                                    Get.back();
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
