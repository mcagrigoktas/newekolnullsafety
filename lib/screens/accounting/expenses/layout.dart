import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../account_settings/case_names.dart';
import 'controller.dart';
import 'label_editor/layout.dart';
import 'model.dart';

class Expenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpensesController>(
        init: ExpensesController(),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();
          final Widget _labelButton = Icons.label.icon.color(Fav.design.appBar.text).onPressed(() async {
            await Fav.to(ExpansesLabelEditor());
            await 100.wait;
            controller.update();
          }).make();
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.no
                      : 'expenses'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'expenses'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_labelButton, _newButton],
                  mainTrailingActions: [_labelButton, _newButton],
                  bothTrailingActions: [_labelButton, _newButton],
                  mainMiddle: _middle,
                  detailMiddle: _middle,
                  bothMiddle: _middle,
                );
          Body? _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.newItem == null && controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = controller.newItem != null
                ? null
                : Body.listviewBuilder(
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'expensesList',
                    listviewFirstWidget: Column(
                      children: [
                        MySearchBar(
                          onChanged: (text) {
                            controller.makeFilter(text);
                            controller.update();
                          },
                          resultCount: controller.filteredItemList.length,
                        ).p4,
                        Row(
                          children: [
                            Expanded(child: Center(child: 'docno'.translate.text.color(Fav.design.primary).bold.make())),
                            Expanded(child: Center(child: 'date'.translate.text.color(Fav.design.primary).bold.make())),
                            Expanded(child: Center(child: 'aciklama'.translate.text.color(Fav.design.primary).bold.make())),
                            Expanded(child: Center(child: 'total'.translate.text.color(Fav.design.primary).bold.make())),
                          ],
                        ).px12
                      ],
                    ),
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      child: Row(
                        children: [
                          Expanded(child: Center(child: controller.filteredItemList[index].no.text.color(!(controller.filteredItemList[index].key == controller.itemData?.key) ? Fav.design.selectableListItem.unselectedText : Colors.white).make())),
                          Expanded(child: Center(child: controller.filteredItemList[index].date!.dateFormat('d-MMM-yy').text.color(!(controller.filteredItemList[index].key == controller.itemData?.key) ? Fav.design.selectableListItem.unselectedText : Colors.white).make())),
                          Expanded(child: Center(child: controller.filteredItemList[index].exp.text.color(!(controller.filteredItemList[index].key == controller.itemData?.key) ? Fav.design.selectableListItem.unselectedText : Colors.white).make())),
                          Expanded(child: Center(child: controller.filteredItemList[index].totalValue().toString().text.color(!(controller.filteredItemList[index].key == controller.itemData?.key) ? Fav.design.selectableListItem.unselectedText : Colors.white).make())),
                        ],
                      ),
                      //   title: controller.filteredItemList[index].no,
                      onTap: () {
                        controller.selectPerson(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 960,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: <Widget>[
                          AnimatedGroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                initialValue: controller.itemData!.no,
                                labelText: "docno".translate,
                                iconData: MdiIcons.account,
                                validatorRules: ValidatorRules(req: true, minLength: 1),
                                onSaved: (value) {
                                  controller.itemData!.no = value;
                                },
                              ),
                              MyDatePicker(
                                initialValue: controller.itemData!.date,
                                title: "date".translate,
                                firstYear: 2021,
                                lastYear: 2030,
                                onSaved: (value) {
                                  controller.itemData!.date = value;
                                },
                              ),
                              AdvanceDropdown(
                                items: controller.personList.where((element) => element.isSupplier).map((e) => DropdownItem(name: e.name, value: e.key)).toList(),
                                initialValue: controller.itemData!.supplier,
                                iconData: Icons.support,
                                name: 'supplier'.translate,
                                onSaved: (dynamic value) {
                                  controller.itemData!.supplier = value;
                                },
                              ),
                              AdvanceDropdown(
                                items: [
                                  DropdownItem(value: ExpenseType.ENFORCED, name: 'enforcedexpense'.translate),
                                  DropdownItem(value: ExpenseType.OTHER, name: 'otherexpense'.translate),
                                ],
                                initialValue: controller.itemData!.type ?? ExpenseType.ENFORCED,
                                iconData: Icons.merge_type,
                                name: 'type'.translate,
                                onSaved: (dynamic value) {
                                  controller.itemData!.type = value;
                                },
                              ),
                              AdvanceDropdown(
                                items: controller.personList.where((element) => element.isEmployee).map((e) => DropdownItem(name: e.name, value: e.key)).toList(),
                                initialValue: controller.itemData!.personKey,
                                iconData: Icons.support,
                                name: 'employee'.translate,
                                onSaved: (dynamic value) {
                                  controller.itemData!.personKey = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.itemData!.exp,
                                maxLines: null,
                                hintText: "...".translate,
                                labelText: "aciklama".translate,
                                iconData: MdiIcons.information,
                                onSaved: (value) {
                                  controller.itemData!.exp = value;
                                },
                              ),
                            ],
                          ),
                          Scroller(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 900,
                              child: DataTable2(
                                columnSpacing: 12,
                                horizontalMargin: 18,
                                showCheckboxColumn: true,
                                columns: [
                                  DataColumn2(label: ''.translate.text.bold.make().center, flex: 1),
                                  DataColumn2(label: 'product'.translate.text.bold.make().center, flex: 8),
                                  DataColumn2(label: 'quantity'.translate.text.bold.make().center, flex: 4),
                                  DataColumn2(label: 'unitprice'.translate.text.center.color(Fav.design.primaryText).bold.make().center, flex: 4),
                                  DataColumn2(label: Center(child: 'total'.translate.text.bold.make()), flex: 3),
                                  DataColumn2(label: 'label'.translate.text.bold.make().center, flex: 7),
                                  DataColumn2(label: 'casenumber'.translate.text.bold.make().center, flex: 7),
                                  DataColumn2(
                                      label: Icons.add.icon
                                          .color(Colors.greenAccent)
                                          .onPressed(() {
                                            controller.itemData!.items!.add(ExpenseItem.create(controller.itemData!));
                                            controller.update();
                                          })
                                          .make()
                                          .center,
                                      flex: 2),
                                ],
                                rows: controller.itemData!.items!
                                    .map((item) => DataRow2(
                                          key: ObjectKey(item),
                                          cells: [
                                            DataCell((controller.itemData!.items!.indexOf(item) + 1).toString().text.make()),
                                            DataCell(MyTextFormField(
                                              padding: EdgeInsets.symmetric(vertical: 0),
                                              initialValue: item.product,
                                              validatorRules: ValidatorRules(minLength: 3, req: true),
                                              onSaved: (value) {
                                                item.product = value;
                                              },
                                            )),
                                            DataCell(MyTextFormField(
                                              padding: EdgeInsets.symmetric(vertical: 0),
                                              initialValue: item.count.toString(),
                                              validatorRules: ValidatorRules(req: true, minValue: 1, mustInt: true),
                                              onSaved: (value) {
                                                item.count = int.tryParse(value!);
                                              },
                                              onChanged: (value) {
                                                item.count = int.tryParse(value!);
                                                item.countTotalValue();
                                                controller.update(['totalValue']);
                                              },
                                            )),
                                            DataCell(MyTextFormField(
                                              padding: EdgeInsets.symmetric(vertical: 0),
                                              initialValue: item.unitPrice.toString(),
                                              validatorRules: ValidatorRules(req: true, minValue: 1, mustNumber: true),
                                              onSaved: (value) {
                                                item.unitPrice = double.tryParse(value!);
                                              },
                                              onChanged: (value) {
                                                item.unitPrice = double.tryParse(value!);
                                                item.countTotalValue();
                                                controller.update(['totalValue']);
                                              },
                                            )),
                                            DataCell(Obx(() => Center(child: item.total.value.text.make()))),
                                            DataCell(AdvanceDropdown<String>(
                                              padding: const EdgeInsets.all(2.0),
                                              name: ''.translate,
                                              nullValueText: 'label'.translate,
                                              initialValue: item.label,
                                              onSaved: (value) {
                                                item.label = value;
                                              },
                                              items: AppVar.appBloc.schoolInfoForManagerService!.singleData!.expenseLabelRootNode
                                                  .getAllChildren()
                                                  .map((e) => DropdownItem<String>(
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 20,
                                                            height: 14,
                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyPalette.getColorFromCount((e).colorNo!)),
                                                          ),
                                                          8.widthBox,
                                                          Expanded(child: (e).name.text.make())
                                                        ],
                                                      ),
                                                      value: e.key))
                                                  .toList(),
                                            )),
                                            DataCell(AdvanceDropdown(
                                              padding: const EdgeInsets.all(2.0),
                                              items: Iterable.generate(maxCaseNumber + 1).map((i) => DropdownItem(value: i, name: i == 0 ? 'casenumber'.translate : AppVar.appBloc.schoolInfoService!.singleData!.caseName(i))).toList(),
                                              onChanged: (dynamic value) {
                                                item.kasaNo = value;
                                                Fav.writeSeasonCache('${controller.itemData!.key}LastCaseNo', value);
                                              },
                                              validatorRules: ValidatorRules(req: true, minValue: 1, mustNumber: true),
                                              initialValue: item.kasaNo,
                                            )),
                                            DataCell(controller.itemData!.items!.indexOf(item) == 0 || controller.newItem == null
                                                ? SizedBox()
                                                : Icons.clear.icon.color(Colors.redAccent).onPressed(() {
                                                    controller.itemData!.items!.remove(item);
                                                    controller.update();
                                                  }).make()),
                                          ].toList(),
                                        ))
                                    .toList()
                                  ..add(DataRow2(
                                    color: MaterialStateColor.resolveWith((states) => Fav.design.primary.withAlpha(25)),
                                    cells: [
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                      DataCell('total'.translate.text.color(Fav.design.primary).bold.make()),
                                      DataCell(GetBuilder<ExpensesController>(
                                          id: 'totalValue',
                                          builder: (controller) {
                                            return controller.itemData!.items!.fold<double>(0.0, (p, e) => p + (double.tryParse(e.total.value) ?? 0.0)).toStringAsFixed(2).text.color(Fav.design.primary).bold.make();
                                          })),
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                      DataCell(SizedBox()),
                                    ].toList(),
                                  )),
                              ),
                            ),
                          ),
                          MyMultiplePhotoUploadWidget(
                            saveLocation: '${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/GenerallyFiles',
                            initialValue: controller.itemData!.invoiceUrl,
                            onSaved: (value) {
                              if (value != null) {
                                controller.itemData!.invoiceUrl = List<String>.from(value);
                              } else {
                                controller.itemData!.invoiceUrl = null;
                              }
                            },
                          )
                        ],
                      ),
                    ));
          }

          RBottomBar? _bottomBar;
          if (controller.itemData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedItem != null)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 0, child: Text(Words.delete)),
                      ];
                    },
                    child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.customDesign4.primary),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        )),
                    onSelected: (value) async {
                      if (value == 0) {
                        var sure = await Over.sure();
                        if (sure == true) await controller.delete();
                      }
                    },
                  ),
                const Spacer(),
                MyProgressButton(
                  onPressed: controller.save,
                  label: Words.save,
                  isLoading: controller.isSaving,
                ).pr16
              ],
            );
            _bottomBar = RBottomBar(
              bothChild: _bottomChild,
              detailChild: _bottomChild,
            );
          }

          return AppResponsiveScaffold(
            leftBodySize: LeftBodySize.S,
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
