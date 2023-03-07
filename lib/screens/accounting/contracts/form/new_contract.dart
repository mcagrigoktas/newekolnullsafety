import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../controller.dart';
import 'widgets.dart';

class NewContract extends StatelessWidget {
  NewContract();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContractsController>();

    return Column(
      key: ValueKey(controller.itemData!.key),
      children: [
        Group2Widget(
          leftItemPercent: 25,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Column(
              children: [
                ContractName(controller: controller),
                StartDate(controller: controller),
                ContractFinishTime(controller: controller),
                ContractDuration(controller: controller),
                ContractAmount(controller: controller),
                InstallamentCount(controller: controller),
                Label(controller: controller),
                ContractExp(controller: controller),
              ],
            ),
            Column(
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
                      if (isWeb)
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
                              controller.newContracTotal.value = controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + (e.amount ?? 0.0));
                            },
                            onSaved: (value) => controller.itemData!.installaments[_i].amount = double.tryParse(value!),
                          ),
                        ),
                        if (isWeb)
                          Expanded(
                            flex: 3,
                            child: MyTextFormField(
                              labelText: 'aciklama'.translate,
                              validatorRules: ValidatorRules(),
                              iconData: Icons.note,
                              initialValue: controller.itemData!.exp,
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
                      child: Align(alignment: Alignment.centerRight, child: Obx(() => ('total'.translate + ': ' + controller.newContracTotal.toStringAsFixed(2)).text.bold.color(Fav.design.primary).make().center)),
                    ),
                    if (isWeb) Spacer(flex: 3),
                  ],
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}
