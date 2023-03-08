import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../account_settings/case_names.dart';
import 'controller.dart';
import 'form/contract_checkout_page.dart';
import 'form/new_contract.dart';

class SalesContracts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesContractsController>(
        init: SalesContractsController(),
        builder: (controller) {
          final Widget _newButton = MyOutlinedButton(
            onPressed: controller.clickNewItem,
            text: 'newcontract'.translate,
            boldText: true,
            maxHeight: 30,
          );

          final Widget _middle = (controller.newContract != null
                  ? 'new'.translate
                  : controller.selectedContract != null
                      ? controller.selectedContract!.name
                      : 'salescontracts'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final _topBar = controller.newContract != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'salescontracts'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_newButton],
                  mainTrailingActions: [_newButton],
                  bothTrailingActions: [_newButton],
                  mainMiddle: _middle,
                  detailMiddle: _middle,
                  bothMiddle: _middle,
                );
          Body? _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.newContract == null && controller.personList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = controller.newContract != null
                ? null
                : Body.listviewBuilder(
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'salescontractList',
                    listviewFirstWidget: Column(
                      children: [
                        MySearchBar(
                          onChanged: (text) {
                            controller.makeFilter(text);
                            controller.update();
                          },
                          resultCount: controller.filteredItemList.length,
                        ).p4,
                      ],
                    ),
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].name,
                      onTap: () {
                        controller.selectContract(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.selectedContract?.key,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 1080,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: controller.newContract != null ? NewContract() : ContractCheckoutPage(),
                    ));
          }

          RBottomBar? _bottomBar;
          if (controller.selectedInstallament != null) {
            Widget _bottomChild = Form(
                key: controller.payFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (context.width > 600)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: (controller.selectedInstallament!.odemeler ?? [])
                              .map((odeme) => Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    margin: Inset.hv(8, 4),
                                    height: 28,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MyKeyValueText(textKey: odeme!.date!.dateFormat("d-MMM-yy") + ' ' + (odeme.otherNo ?? '') + ' ' + '(${AppVar.appBloc.schoolInfoService!.singleData!.caseName(odeme.kasaNo)})', value: odeme.miktar!.toStringAsFixed(2)),
                                        Icons.delete.icon
                                            .color(Colors.red)
                                            .onPressed(() {
                                              controller.payDelete(odeme);
                                            })
                                            .padding(0)
                                            .size(16)
                                            .make(),
                                      ],
                                    ),
                                    decoration: ShapeDecoration(shape: const StadiumBorder(), color: Fav.design.customColors2[1]),
                                  ))
                              .toList(),
                        ),
                      ),
                    Group2Widget(
                      children: [
                        Row(
                          children: <Widget>[
                            Icons.close.icon
                                .onPressed(() {
                                  controller.selectedInstallament = null;
                                  controller.update();
                                })
                                .color(Colors.red)
                                .make(),
                            Expanded(
                              flex: 2,
                              child: AdvanceDropdown(
                                padding: const EdgeInsets.all(0.0),
                                items: Iterable.generate(maxCaseNumber + 1).map((i) => DropdownItem(value: i, name: i == 0 ? 'casenumber'.translate : AppVar.appBloc.schoolInfoService!.singleData!.caseName(i))).toList(),
                                onChanged: (dynamic value) {
                                  controller.payOff!.kasaNo = value;
                                  controller.update();
                                },
                                validatorRules: ValidatorRules(req: true, minValue: 1, mustNumber: true),
                                initialValue: controller.payOff!.kasaNo,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: MyDatePicker(
                                  onChanged: (value) {
                                    controller.payOff!.date = value;
                                  },
                                  title: 'date'.translate,
                                  initialValue: controller.payOff!.date),
                            ),
                            Expanded(
                              flex: 2,
                              child: MyTextFormField(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                textAlign: TextAlign.end,
                                validatorRules: ValidatorRules(),
                                onChanged: (value) {
                                  controller.payOff!.otherNo = value;
                                },
                                labelText: 'info'.translate,
                                initialValue: controller.payOff!.otherNo,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: MyTextFormField(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                textAlign: TextAlign.end,
                                validatorRules: ValidatorRules(req: true, mustNumber: true, minLength: 1, minValue: 1, maxValue: controller.selectedInstallament!.kalan),
                                onChanged: (value) {
                                  controller.payOff!.miktar = double.tryParse(value);
                                },
                                labelText: ''.translate,
                                initialValue: controller.payOff!.miktar.toString(),
                              ),
                            ),
                            MyProgressButton(isLoading: controller.isSaving, onPressed: controller.pay, label: Words.save)
                          ],
                        )
                      ],
                    ).px8,
                  ],
                ));
            _bottomBar = RBottomBar(
              bothChild: _bottomChild,
              detailChild: _bottomChild,
            );
          } else if (controller.itemData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedContract != null && controller.newContract == null)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 1, child: Text('complete'.translate)),
                        PopupMenuItem(value: 0, child: Text(Words.delete)),
                        //   PopupMenuItem(value: 0, child: Text('edit'.translate)),
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
                    onSelected: (value) {
                      if (value == 0) {
                        controller.delete();
                      } else if (value == 1) {
                        controller.complete();
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
            _bottomChild = IgnorePointer(
              ignoring: controller.selectedContract != null && controller.newContract == null && controller.selectedContract!.isCompleted == true,
              child: _bottomChild,
            );
            _bottomBar = RBottomBar(
              bothChild: _bottomChild,
              detailChild: _bottomChild,
            );
          }

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
