import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/print/registrymenuprint.dart';
import '../../../../localization/usefully_words.dart';
import 'controller.dart';
import 'model.dart';

class PreRegistrationList extends StatelessWidget {
  PreRegistrationList();

  @override
  Widget build(BuildContext context) {
    // DataZip.cryptAndZip(AppVar.appBloc.studentService.data);

    return GetBuilder<PreRegistrationListController>(
        init: PreRegistrationListController(),
        builder: (controller) {
          final Widget _newButton = AddIcon(onPressed: controller.clickNewItem);
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'preregister'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final Widget _exportItems = MyPopupMenuButton(
            itemBuilder: (context) {
              return <PopupMenuEntry>[
                PopupMenuItem(value: 2, child: Text(Words.print)),
              ];
            },
            child: MoreIcon(),
            onSelected: (value) {
              if (value == 2) {
                RegistryMenuPrint.printPreRegisterList(context, controller.itemList);
              }
            },
          );
          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'preregister'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_exportItems, _newButton],
                  mainTrailingActions: [_exportItems, _newButton],
                  bothTrailingActions: [_exportItems, _newButton],
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
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'preregister',
                    listviewFirstWidget: Column(
                      children: [
                        MySearchBar(
                          onChanged: (text) {
                            controller.makeFilter(text);
                            controller.update();
                          },
                          resultCount: controller.filteredItemList.length,
                        ).px4,
                        AdvanceDropdown<PreRegisterStatus>(
                            padding: Inset(4),
                            initialValue: controller.filteredStatus,
                            items: [
                              DropdownItem<PreRegisterStatus>(name: 'preregisterstatus1'.translate, value: PreRegisterStatus.aktif),
                              DropdownItem<PreRegisterStatus>(name: 'preregisterstatus2'.translate, value: PreRegisterStatus.saved),
                              DropdownItem<PreRegisterStatus>(name: 'preregisterstatus3'.translate, value: PreRegisterStatus.cancelled),
                            ],
                            onChanged: (value) {
                              controller.filteredStatus = value;
                              controller.makeFilter(controller.filteredText);
                              controller.update();
                            }),
                      ],
                    ),
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].name,
                      onTap: () {
                        controller.selectPerson(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 720,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: <Widget>[
                          AnimatedGroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                initialValue: controller.itemData!.name,
                                labelText: "namesurname".translate,
                                iconData: MdiIcons.account,
                                validatorRules: ValidatorRules(req: true, minLength: 6),
                                onSaved: (value) {
                                  controller.itemData!.name = value;
                                },
                              ),
                              MyTextFormFieldWithCounter(
                                initialValue: controller.itemData!.tc,
                                labelText: "tc".translate,
                                iconData: MdiIcons.card,
                                iconColor: Colors.deepOrangeAccent,
                                validatorRules: ValidatorRules(noGap: true),
                                onSaved: (value) {
                                  controller.itemData!.tc = value;
                                },
                              ),
                              MyDatePicker(
                                initialValue: controller.itemData!.birthday,
                                title: "birthday".translate,
                                firstYear: 1990,
                                lastYear: 2025,
                                onSaved: (value) {
                                  controller.itemData!.birthday = value;
                                },
                              ),
                              AdvanceDropdown<bool>(
                                initialValue: controller.itemData!.gender,
                                name: "genre".translate,
                                iconData: MdiIcons.genderMaleFemale,
                                items: [
                                  DropdownItem(child: "genre1".translate.text.make(), value: false),
                                  DropdownItem(child: "genre2".translate.text.make(), value: true),
                                ],
                                onSaved: (value) {
                                  controller.itemData!.gender = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.itemData!.fatherName,
                                labelText: "father".translate + " " + "name2".translate,
                                iconData: MdiIcons.account,
                                onSaved: (value) {
                                  controller.itemData!.fatherName = value;
                                },
                              ),
                              if (AppVar.appBloc.hesapBilgileri.gtM)
                                MyTextFormField(
                                  initialValue: controller.itemData!.fatherPhone,
                                  labelText: "father".translate + " " + "phone".translate,
                                  iconData: MdiIcons.phone,
                                  validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                  keyboardType: TextInputType.phone,
                                  onSaved: (value) {
                                    controller.itemData!.fatherPhone = value;
                                  },
                                ),
                              MyTextFormField(
                                initialValue: controller.itemData!.motherName,
                                labelText: "mother".translate + " " + "name2".translate,
                                iconData: MdiIcons.account,
                                onSaved: (value) {
                                  controller.itemData!.motherName = value;
                                },
                              ),
                              if (AppVar.appBloc.hesapBilgileri.gtM)
                                MyTextFormField(
                                  initialValue: controller.itemData!.motherPhone,
                                  labelText: "mother".translate + " " + "phone".translate,
                                  iconData: MdiIcons.phone,
                                  validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                  keyboardType: TextInputType.phone,
                                  onSaved: (value) {
                                    controller.itemData!.motherPhone = value;
                                  },
                                ),
                            ],
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
                          MyTextFormField(
                            initialValue: controller.itemData!.not1,
                            maxLines: null,
                            hintText: "...".translate,
                            labelText: "note".translate + ' 1',
                            iconData: MdiIcons.information,
                            onSaved: (value) {
                              controller.itemData!.not1 = value;
                            },
                          ),
                          MyTextFormField(
                            initialValue: controller.itemData!.not2,
                            maxLines: null,
                            hintText: "...".translate,
                            labelText: "note".translate + ' 2',
                            iconData: MdiIcons.information,
                            onSaved: (value) {
                              controller.itemData!.not2 = value;
                            },
                          ),
                          MyTextFormField(
                            initialValue: controller.itemData!.not3,
                            maxLines: null,
                            hintText: "...".translate,
                            labelText: "note".translate + ' 3',
                            iconData: MdiIcons.information,
                            onSaved: (value) {
                              controller.itemData!.not3 = value;
                            },
                          ),
                        ],
                      ),
                    ));
          }

          RBottomBar? _bottomBar;
          if (controller.itemData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedItem != null && controller.selectedItem!.status != PreRegisterStatus.cancelled)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 0, child: Text(Words.delete)),
                        const PopupMenuDivider(),
                        PopupMenuItem(value: 1, child: Text('movetosaved'.translate)),
                      ];
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.primaryText.withAlpha(10)),
                      child: Icon(Icons.more_vert, color: Fav.design.primaryText.withAlpha(180)),
                    ),
                    onSelected: (value) async {
                      if (value == null) return;
                      var sure = await Over.sure();
                      if (sure != true) return;
                      if (value == 0) {
                        await controller.delete();
                      } else if (value == 1) {
                        await controller.move();
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
