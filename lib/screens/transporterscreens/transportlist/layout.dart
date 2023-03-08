import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import 'controller.dart';

class TransporterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransporterListController>(
        init: TransporterListController(),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.profileName
                      : 'transportlist'.translate)
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
                  detailLeadingTitle: 'transportlist'.translate,
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
          } else if (controller.newItem == null && controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = controller.newItem != null
                ? null
                : Body.listviewBuilder(
                    listviewFirstWidget: MySearchBar(
                      onChanged: (text) {
                        controller.makeFilter(text);
                        controller.update();
                      },
                      resultCount: controller.filteredItemList.length,
                    ).p4,
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].profileName,
                      onTap: () {
                        // OverAlert.show(message: 'Bu deneme mesajidir', title: 'Heyy', type: AlertType.successful,autoClose:false);
                        controller.selectPerson(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.child(
                    maxWidth: 920,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: AnimatedGroupWidget(
                                children: [
                                  MyTextFormField(
                                    initialValue: controller.itemData!.profileName,
                                    labelText: "profilename".translate,
                                    iconData: MdiIcons.signature,
                                    validatorRules: ValidatorRules(req: true, minLength: 4),
                                    onSaved: (value) {
                                      controller.itemData!.profileName = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.plate,
                                    labelText: "plate".translate,
                                    iconData: MdiIcons.bus,
                                    onSaved: (value) {
                                      controller.itemData!.plate = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    validatorRules: ValidatorRules(req: true, minLength: 3),
                                    initialValue: controller.itemData!.driverName,
                                    labelText: "driver".translate,
                                    iconData: MdiIcons.account,
                                    onSaved: (value) {
                                      controller.itemData!.driverName = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.driverPhone,
                                    labelText: "driver".translate + " " + "phone".translate,
                                    iconData: MdiIcons.phone,
                                    keyboardType: TextInputType.phone,
                                    validatorRules: ValidatorRules(noGap: true, phoneNumber: true),
                                    onSaved: (value) {
                                      controller.itemData!.driverPhone = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.employeeName,
                                    labelText: "employee".translate,
                                    iconData: MdiIcons.account,
                                    onSaved: (value) {
                                      controller.itemData!.employeeName = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.employeePhone,
                                    labelText: "employee".translate + " " + "phone".translate,
                                    iconData: MdiIcons.phone,
                                    keyboardType: TextInputType.phone,
                                    validatorRules: ValidatorRules(noGap: true, phoneNumber: true),
                                    onSaved: (value) {
                                      controller.itemData!.employeePhone = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.username,
                                    hintText: "sixcharacter".translate,
                                    labelText: "username".translate,
                                    iconData: MdiIcons.at,
                                    validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
                                    onSaved: (value) {
                                      controller.itemData!.username = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.password,
                                    hintText: "sixcharacter".translate,
                                    labelText: "password".translate,
                                    iconData: MdiIcons.key,
                                    validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
                                    onSaved: (value) {
                                      controller.itemData!.password = value;
                                    },
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.explanation,
                                    maxLines: null,
                                    hintText: "...".translate,
                                    labelText: "aciklama".translate,
                                    iconData: MdiIcons.information,
                                    onSaved: (value) {
                                      controller.itemData!.explanation = value;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (context.screenWidth > 750 && controller.selectedItem != null) VerticalDivider(width: 1, color: Fav.design.primaryText.withAlpha(20)),
                          if (context.screenWidth > 750 && controller.selectedItem != null)
                            Container(
                              padding: const EdgeInsets.all(4),
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'studentlist'.translate,
                                    style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
                                  ).p8,
                                  Expanded(
                                      child: ListView(
                                          children: AppVar.appBloc.studentService!.dataList
                                              .where((e) => e.transporter == controller.selectedItem!.key)
                                              .map((e) => Center(
                                                    child: Text(
                                                      e.name,
                                                      style: TextStyle(color: Fav.design.primaryText, fontSize: 13),
                                                    ).p4,
                                                  ))
                                              .toList()))
                                ],
                              ),
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
                        PopupMenuItem(
                          value: 0,
                          child: Text(Words.delete),
                        ),
                      ];
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.primaryText.withAlpha(10)),
                      child: Icon(Icons.more_vert, color: Fav.design.primaryText.withAlpha(180)),
                    ),
                    onSelected: (value) async {
                      if (value == 0) {
                        var sure = await Over.sure();
                        if (sure == true) await controller.save(delete: true);
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
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
