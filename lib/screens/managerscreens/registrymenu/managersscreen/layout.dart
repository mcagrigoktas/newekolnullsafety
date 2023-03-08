import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import 'controller.dart';
import 'manager.dart';

class ManagerList extends StatelessWidget {
  final Manager? initialItem;
  ManagerList({this.initialItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManagerListController>(
        init: ManagerListController(initialItem: initialItem),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();

          final Widget _sendSmsButton = Tooltip(
            message: 'sendusername1'.translate,
            child: MdiIcons.share.icon.color(Fav.design.appBar.text).onPressed(controller.sendSMS).make(),
          );

          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'managerlist'.translate)
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
                  detailLeadingTitle: 'managerlist'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [
                    _newButton,
                    if (controller.selectedItem != null) _sendSmsButton,
                  ],
                  mainTrailingActions: [_newButton],
                  bothTrailingActions: [
                    _newButton,
                    if (controller.selectedItem != null) _sendSmsButton,
                  ],
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
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'managerlist',
                    listviewFirstWidget: MySearchBar(
                      onChanged: (text) {
                        controller.makeFilter(text);
                        controller.update();
                      },
                      resultCount: controller.filteredItemList.length,
                      initialText: controller.filteredText,
                    ).p4,
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].name,
                      onTap: () {
                        controller.selectPerson(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                      imgUrl: controller.filteredItemList[index].imgUrl,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : controller.itemData!.key == 'Manager1'
                    ? Body.child(child: EmptyState(text: 'mainmanagercantchange'.translate))
                    : Body.singleChildScrollView(
                        maxWidth: 720,
                        withKeyboardCloserGesture: true,
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: <Widget>[
                              MyTextFormField(
                                initialValue: controller.itemData!.name,
                                labelText: "name".translate,
                                iconData: MdiIcons.account,
                                validatorRules: ValidatorRules(req: true, minLength: 2),
                                onSaved: (value) {
                                  controller.itemData!.name = value;
                                },
                              ),
                              AnimatedGroupWidget(
                                children: <Widget>[
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
                                  IgnorePointer(
                                    ignoring: controller.isPasswordMustHide,
                                    child: MyTextFormField(
                                      obscureText: controller.isPasswordMustHide,
                                      initialValue: controller.itemData!.password,
                                      hintText: "sixcharacter".translate,
                                      labelText: "password".translate,
                                      iconData: MdiIcons.key,
                                      validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
                                      onSaved: (value) {
                                        controller.itemData!.password = value;
                                      },
                                    ),
                                  ),
                                  MyTextFormField(
                                    initialValue: controller.itemData!.phone,
                                    labelText: "phone".translate,
                                    iconData: MdiIcons.phone,
                                    validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                    keyboardType: TextInputType.phone,
                                    onSaved: (value) {
                                      controller.itemData!.phone = value;
                                    },
                                  ),
                                  MyMultiSelect(
                                    title: "authoritypages".translate,
                                    context: context,
                                    initialValue: controller.itemData!.authorityList ?? [],
                                    iconData: MdiIcons.tag,
                                    onSaved: (value) {
                                      controller.itemData!.authorityList = value;
                                    },
                                    name: "authoritypages".translate,
                                    items: controller.availebleAuthority().keys.map((key) => MyMultiSelectItem(key, controller.availebleAuthority()[key]!)).toList(),
                                    validatorRules: ValidatorRules(),
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
                              Align(
                                child: MyPhotoUploadWidget(
                                  saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "UserProfileImages",
                                  initialValue: controller.itemData!.imgUrl,
                                  onSaved: (value) {
                                    controller.itemData!.imgUrl = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ));
          }

          RBottomBar? _bottomBar;
          if (controller.itemData != null && controller.itemData!.key != 'Manager1' && (controller.visibleScreen == VisibleScreen.detail)) {
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
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.primaryText.withAlpha(10)),
                      child: Icon(Icons.more_vert, color: Fav.design.primaryText.withAlpha(180)),
                    ),
                    onSelected: (value) async {
                      if (value == 0) {
                        var sure = await Over.sure();
                        if (sure == true) await controller.delete();
                      }
                    },
                  ),
                // ConfirmButton(
                //   title: Words.delete,
                //   sureText: 'sure'.translate,
                //   iconData: Icons.delete,
                //   yesPressed: controller.delete,
                // ).pl16,
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
