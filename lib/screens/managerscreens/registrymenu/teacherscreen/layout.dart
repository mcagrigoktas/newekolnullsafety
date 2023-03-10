import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';
import 'package:widgetpackage/mycolorpicker.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/exporthelper.dart';
import '../../../../helpers/print/registrymenuprint.dart';
import '../../../../localization/usefully_words.dart';
import '../../../importpages/importpagemain.dart';
import '../copy_another_term_helper.dart';
import 'branches.dart';
import 'controller.dart';
import 'teacher.dart';

class TeacherList extends StatelessWidget {
  final Teacher? initialItem;
  TeacherList({this.initialItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TeacherListController>(
        init: TeacherListController(initialItem: initialItem),
        builder: (controller) {
          final Widget _newButton = AddIcon(onPressed: controller.clickNewItem);
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : Words.teacherList)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final Widget _sendSmsButton = Tooltip(
            message: 'sendusername1'.translate,
            child: MdiIcons.share.icon.color(Fav.design.appBar.text).onPressed(controller.sendSMS).make(),
          );

          final Widget _exportItems = MyPopupMenuButton(
            itemBuilder: (context) {
              return <PopupMenuEntry>[
                PopupMenuItem(value: 3, child: Text('copyanotherterm'.translate)),
                PopupMenuItem(value: 0, child: Text('fromexcell'.translate)),
                if (kIsWeb) PopupMenuItem(value: 1, child: Text('exportexcell'.translate)),
                PopupMenuItem(value: 2, child: Text(Words.print)),
              ];
            },
            child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(right: 8),
            onSelected: (value) async {
              if (value == 0) {
                Fav.to(ImportPageMain(menuNo: 11)).unawaited;
              } else if (value == 1) {
                ExportHelper.exportTeacherList();
              } else if (value == 2) {
                RegistryMenuPrint.printTeacherList(context).unawaited;
              } else if (value == 3) {
                CopyFromAnotherTermHelper.copyTeacher().unawaited;
              }
            },
          );
          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: Words.teacherList,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_newButton, if (controller.selectedItem != null) _sendSmsButton, _exportItems],
                  mainTrailingActions: [_newButton, _exportItems],
                  bothTrailingActions: [_newButton, if (controller.selectedItem != null) _sendSmsButton, _exportItems],
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
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'teacherList',
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
                              Row(
                                children: [
                                  Expanded(
                                    child: MyMultiSelect(
                                        iconData: MdiIcons.book,
                                        initialValue: controller.itemData!.branches ?? [],
                                        name: 'branch'.translate,
                                        onSaved: (value) {
                                          controller.itemData!.branches = value;
                                        },
                                        context: context,
                                        items: AppVar.appBloc.schoolInfoService!.singleData!.branchList.map((e) => MyMultiSelectItem(e, e)).toList(),
                                        title: 'branchlist'.translate),
                                  ),
                                  Tooltip(
                                    message: 'editbranchlist'.translate,
                                    child: Icons.settings.icon
                                        .onPressed(() {
                                          Fav.to(BranchesPage(previousMenuName: Words.teacherList));
                                        })
                                        .color(Fav.design.primaryText)
                                        .padding(0)
                                        .size(18)
                                        .make(),
                                  ),
                                  16.widthBox,
                                ],
                              ),
                              MyDatePicker(
                                initialValue: controller.itemData!.birthday,
                                title: "birthday".translate,
                                firstYear: 1950,
                                lastYear: 2025,
                                onSaved: (value) {
                                  controller.itemData!.birthday = value;
                                },
                              ),
                              MyColorPicker(
                                initialValue: controller.itemData!.color,
                                title: "selectcolor".translate,
                                onSaved: (value) {
                                  controller.itemData!.color = value;
                                },
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
                              MyTextFormField(
                                initialValue: controller.itemData!.mail,
                                labelText: "mail".translate,
                                iconData: MdiIcons.at,
                                onSaved: (value) {
                                  controller.itemData!.mail = value.trim();
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.itemData!.adress,
                                maxLines: null,
                                hintText: "...".translate,
                                labelText: "adres".translate,
                                iconData: MdiIcons.mapMarker,
                                onSaved: (value) {
                                  controller.itemData!.adress = value;
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
                              AdvanceDropdown<bool>(
                                // canvasColor: Fav.design.dropdown.canvas,
                                initialValue: controller.itemData!.seeAllClass ?? false,
                                name: "teacherseeclasslist0".translate,
                                iconData: MdiIcons.accountKey,
                                //  color: Colors.red,

                                items: ['teacherseeclasslist1', 'teacherseeclasslist2'].map((text) => DropdownItem(value: text == 'teacherseeclasslist1' ? false : true, name: text.translate)).toList(),
                                onSaved: (value) {
                                  controller.itemData!.seeAllClass = value;
                                },
                              ),
                            ],
                          ),
                          Align(
                            child: MyPhotoUploadWidget(
                              avatarImage: true,
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
          if (controller.itemData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedItem != null)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 0, child: Text(Words.delete)),
                        // const PopupMenuDivider(),
                        //  PopupMenuItem(value: 1, child: Text('copyotherterm'.translate)),
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

                      // else if (value == 1) {
                      //   await controller.copy();
                      // }
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
