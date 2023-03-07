import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../controller.dart';
import '../model.dart';
import 'widgets.dart';

class NewContract extends StatelessWidget {
  NewContract();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesContractsController>();

    return Column(
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
            Scroller(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1100,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150)),
                      child: Row(
                        children: [
                          Container(
                              alignment: Alignment.center,
                              width: 32,
                              child: Icons.add.icon.color(Colors.green).onPressed(() {
                                controller.itemData!.products!.add(SalesProduct.create());
                                controller.update();
                              }).make()),
                          Expanded(
                            flex: 5,
                            child: 'name'.translate.text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 3,
                            child: 'amount'.translate.text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 2,
                            child: ('discount'.translate + ' %').text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 2,
                            child: ('tax'.translate + ' %').text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 3,
                            child: 'result'.translate.text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 3,
                            child: 'dateofcontract'.translate.text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 3,
                            child: 'finishtime'.translate.text.bold.color(Fav.design.primary).make().center,
                          ),
                          Expanded(
                            flex: 5,
                            child: 'aciklama'.translate.text.bold.color(Fav.design.primary).make().center,
                          ),
                          SizedBox(width: 32)
                        ],
                      ),
                    ),
                    for (var _i = 0; _i < controller.itemData!.products!.length; _i++)
                      Container(
                        key: ObjectKey(controller.itemData!.products![_i]),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: _i.isOdd ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150), border: _i != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
                        child: Row(
                          children: [
                            Container(alignment: Alignment.center, width: 32, child: (_i + 1).toString().text.bold.color(Fav.design.primary).make()),
                            Expanded(
                              flex: 5,
                              child: MyTextFormField(
                                padding: Inset.h(2),
                                validatorRules: ValidatorRules(req: true, minLength: 2),
                                initialValue: controller.itemData!.products![_i].name,
                                onChanged: (value) {
                                  controller.itemData!.products![_i].name = value;
                                },
                                onSaved: (value) => controller.itemData!.products![_i].name = value,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: MyTextFormField(
                                padding: Inset.h(2),
                                textAlign: TextAlign.end,
                                validatorRules: ValidatorRules(mustNumber: true, minValue: 1, req: true),
                                initialValue: controller.itemData!.products![_i].amount!.toStringAsFixed(2),
                                onChanged: (value) {
                                  controller.itemData!.products![_i].amount = double.tryParse(value!) ?? 0.0;
                                  controller.newContracAmountTotal.value = controller.itemData!.products!.fold<double>(0.0, (p, e) => p + (e.net));
                                  controller.update();
                                },
                                onSaved: (value) => controller.itemData!.products![_i].amount = double.tryParse(value!),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: MyTextFormField(
                                padding: Inset.h(2),
                                textAlign: TextAlign.end,
                                validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                                initialValue: controller.itemData!.products![_i].discount!.toStringAsFixed(2),
                                onChanged: (value) {
                                  controller.itemData!.products![_i].discount = double.tryParse(value!) ?? 0.0;
                                  controller.newContracAmountTotal.value = controller.itemData!.products!.fold<double>(0.0, (p, e) => p + (e.net));
                                  controller.update();
                                },
                                onSaved: (value) => controller.itemData!.products![_i].discount = double.tryParse(value!),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: MyTextFormField(
                                padding: Inset.h(2),
                                textAlign: TextAlign.end,
                                validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                                initialValue: controller.itemData!.products![_i].amount!.toStringAsFixed(2),
                                onChanged: (value) {
                                  controller.itemData!.products![_i].tax = double.tryParse(value!) ?? 0.0;
                                  controller.newContracAmountTotal.value = controller.itemData!.products!.fold<double>(0.0, (p, e) => p + (e.net));
                                  controller.update();
                                },
                                onSaved: (value) => controller.itemData!.products![_i].tax = double.tryParse(value!),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: controller.itemData!.products![_i].net.toStringAsFixed(2).text.color(Fav.design.primary).bold.make().center,
                            ),
                            Expanded(
                              flex: 3,
                              child: MyDatePicker(
                                padding: Inset.h(2),
                                initialValue: controller.itemData!.products![_i].startDate,
                                onChanged: (value) async {
                                  controller.itemData!.products![_i].startDate = value;
                                },
                                onSaved: (value) async {
                                  controller.itemData!.products![_i].startDate = value;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: MyDatePicker(
                                padding: Inset.h(2),
                                initialValue: controller.itemData!.products![_i].endDate,
                                onChanged: (value) async {
                                  controller.itemData!.products![_i].endDate = value;
                                },
                                onSaved: (value) async {
                                  controller.itemData!.products![_i].endDate = value;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: MyTextFormField(
                                padding: Inset.h(2),
                                labelText: 'aciklama'.translate,
                                validatorRules: ValidatorRules(),
                                iconData: Icons.note,
                                initialValue: controller.itemData!.products![_i].exp,
                                onSaved: (value) => controller.itemData!.products![_i].exp = value,
                                onChanged: (value) => controller.itemData!.products![_i].exp = value,
                              ),
                            ),
                            Container(
                                alignment: Alignment.center,
                                width: 32,
                                child: _i == 0
                                    ? null
                                    : Icons.delete.icon.color(Colors.redAccent).onPressed(() {
                                        controller.itemData!.products!.remove(controller.itemData!.products![_i]);
                                        controller.update();
                                      }).make()),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        SizedBox(width: 32),
                        Spacer(flex: 12),
                        Expanded(
                          flex: 3,
                          child: Align(alignment: Alignment.centerRight, child: ('total'.translate + ': ' + controller.newContracAmountTotal.toStringAsFixed(2)).text.bold.color(Fav.design.primary).make().center),
                        ),
                        Spacer(flex: 11),
                        SizedBox(width: 32),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Divider(),
        InstallamentCount(
          controller: controller,
        ),
        Scroller(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 800,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150)),
                  child: Row(
                    children: [
                      Container(alignment: Alignment.center, width: 24, child: ''.text.bold.color(Fav.design.primary).make()),
                      Expanded(
                        flex: 3,
                        child: 'date'.translate.text.bold.color(Fav.design.primary).make().center,
                      ),
                      Expanded(
                        flex: 2,
                        child: 'amount'.translate.text.bold.color(Fav.design.primary).make().center,
                      ),
                      Expanded(
                        flex: 3,
                        child: 'aciklama'.translate.text.bold.color(Fav.design.primary).make().center,
                      ),
                    ],
                  ),
                ),
                for (var _i = 0; _i < controller.itemData!.installaments.length; _i++)
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _i.isOdd ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150), border: _i != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
                    child: Row(
                      children: [
                        Container(alignment: Alignment.center, width: 24, child: controller.itemData!.installaments[_i].no.toString().text.bold.color(Fav.design.primary).make()),
                        Expanded(
                          key: ValueKey('ItemD$_i-${controller.itemData!.installaments[_i].date}'),
                          flex: 3,
                          child: MyDatePicker(
                            initialValue: controller.itemData!.installaments[_i].date,
                            onChanged: (value) async {
                              controller.itemData!.installaments[_i].date = value;
                              if (_i == 0) {
                                final _sure = await Over.sure(title: 'accountingwarning1'.translate, cancelText: 'no'.translate);
                                if (_sure) {
                                  controller.itemData!.setUpInstallamenDates(forceFirstInstallaments: true);
                                  controller.update();
                                }
                              }
                            },
                          ),
                        ),
                        Expanded(
                          key: GlobalKey(),
                          // key: ValueKey('ItemI$_i-${controller.itemData.installaments[_i].amount.toStringAsFixed(2)}'),
                          flex: 2,
                          child: MyTextFormField(
                            textAlign: TextAlign.end,
                            validatorRules: ValidatorRules(mustNumber: true, minValue: 1, req: true),
                            initialValue: controller.itemData!.installaments[_i].amount!.toStringAsFixed(2),
                            onChanged: (value) {
                              controller.itemData!.installaments[_i].amount = double.tryParse(value!);
                              controller.newContracAmountTotal.value = controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + (e.amount ?? 0.0));
                            },
                            onSaved: (value) => controller.itemData!.installaments[_i].amount = double.tryParse(value!),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: MyTextFormField(
                            labelText: 'aciklama'.translate,
                            validatorRules: ValidatorRules(),
                            iconData: Icons.note,
                            initialValue: controller.itemData!.installaments[_i].exp,
                            onSaved: (value) => controller.itemData!.installaments[_i].exp = value,
                            onChanged: (value) => controller.itemData!.installaments[_i].exp = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    SizedBox(width: 24),
                    Spacer(flex: 3),
                    Expanded(
                      flex: 2,
                      child: Align(alignment: Alignment.centerRight, child: Obx(() => ('total'.translate + ': ' + controller.newContracAmountTotal.toStringAsFixed(2)).text.bold.color(Fav.design.primary).make().center)),
                    ),
                    if (isWeb) Spacer(flex: 3),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
