import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/class.dart';
import '../../../main/menu_list_helper.dart';
import '../copy_another_term_helper.dart';
import 'clsastypes.dart';
import 'controller.dart';

class ClassList extends StatelessWidget {
  final Class? initialItem;
  ClassList({this.initialItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassListController>(
        init: ClassListController(initialItem: initialItem),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'classlist'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final Widget _otherItems = MyPopupMenuButton(
              itemBuilder: (context) {
                return <PopupMenuEntry>[PopupMenuItem(value: 3, child: Text('copyanotherterm'.translate)), if (MenuList.hasTimeTable()) PopupMenuItem(value: 4, child: Text('classgroups'.translate))];
              },
              child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(top: 0, right: 8, bottom: 0, left: 0),
              onSelected: (value) async {
                if (value == 3) {
                  CopyFromAnotherTermHelper.copyClass().unawaited;
                } else if (value == 4) {
                  await Fav.to(ClassTypes());
                }
              });

          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'classlist'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_otherItems, _newButton],
                  mainTrailingActions: [_otherItems, _newButton],
                  bothTrailingActions: [_otherItems, _newButton],
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
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID! + 'classlist',
                    listviewFirstWidget: Column(
                      children: [
                        MySearchBar(
                          onChanged: (text) {
                            controller.makeFilter(text);
                            controller.update();
                          },
                          resultCount: controller.filteredItemList.length,
                          initialText: controller.filteredText,
                        ).px4,
                        if (AppVar.appBloc.hesapBilgileri.isEkolOrUni)
                          AdvanceDropdown(
                            padding: Inset(4),
                            items: [
                              DropdownItem(name: 'all'.translate, value: -1),
                              DropdownItem(name: 'classtype0'.translate, value: 0),
                              DropdownItem(name: 'classtype1'.translate, value: 1),
                              ...AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!.entries
                                  .map((item) => DropdownItem(
                                        name: item.value,
                                        value: int.parse(item.key.toString().replaceAll('t', '')),
                                      ))
                                  .toList()
                            ],
                            onChanged: (dynamic value) {
                              controller.filteredClassType = value;
                              controller.makeFilter(controller.filteredText);
                              controller.update();
                            },
                            initialValue: controller.filteredClassType,
                          ),
                      ],
                    ),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  AnimatedGroupWidget(
                                    children: <Widget>[
                                      MyTextFormField(
                                        initialValue: controller.itemData!.name,
                                        labelText: "name".translate,
                                        hintText: "maxfivecharacter".translate,
                                        iconData: MdiIcons.account,
                                        validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: AppVar.appBloc.hesapBilgileri.isEkid ? null : 5),
                                        onSaved: (value) {
                                          controller.itemData!.name = value;
                                        },
                                      ),
                                      if (AppVar.appBloc.hesapBilgileri.isEkolOrUni)
                                        MyTextFormField(
                                          initialValue: controller.itemData!.longName,
                                          labelText: "classlongname".translate,
                                          iconData: MdiIcons.account,
                                          validatorRules: ValidatorRules(req: true, minLength: 1),
                                          onSaved: (value) {
                                            controller.itemData!.longName = value;
                                          },
                                        ),
                                      if (MenuList.hasTimeTable())
                                        MyDropDownField(
                                          onChanged: (value) {
                                            controller.isCourseClass = (value == 0);
                                            controller.update();
                                          },
                                          canvasColor: Fav.design.dropdown.canvas,
                                          initialValue: controller.itemData!.classType,
                                          name: "classtype".translate,
                                          iconData: MdiIcons.humanMaleBoard,
                                          color: Colors.deepPurpleAccent,
                                          items: [
                                            DropdownMenuItem(value: 0, child: Text('classtype0'.translate, style: TextStyle(color: Fav.design.primaryText))),
                                            DropdownMenuItem(value: 1, child: Text('classtype1'.translate, style: TextStyle(color: Fav.design.primaryText))),
                                            ...AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!.entries
                                                .map((item) => DropdownMenuItem(
                                                      child: Text(
                                                        item.value!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      value: int.parse(item.key.toString().replaceAll('t', '')),
                                                    ))
                                                .toList()
                                          ],
                                          onSaved: (value) {
                                            controller.itemData!.classType = value;
                                          },
                                        ),
                                      //todo kontrol et belki bir asasgidadir  if (isCourseClass != false)
                                      MyDropDownField(
                                        canvasColor: Fav.design.dropdown.canvas,
                                        initialValue: controller.itemData!.classTeacher,
                                        name: "classteacher".translate,
                                        iconData: MdiIcons.humanMaleBoard,
                                        color: Colors.deepPurpleAccent,
                                        items: controller.teacherDropDownList,
                                        onSaved: (value) {
                                          controller.itemData!.classTeacher = value;
                                        },
                                      ),
                                      if (AppVar.appBloc.hesapBilgileri.isEkid)
                                        MyDropDownField(
                                          initialValue: controller.itemData!.classTeacher2,
                                          name: "teacher".translate + " 2",
                                          iconData: MdiIcons.humanMaleBoard,
                                          color: Colors.amber,
                                          items: controller.teacherDropDownList,
                                          onSaved: (value) {
                                            controller.itemData!.classTeacher2 = value;
                                          },
                                        ),
                                      if (AppVar.appBloc.hesapBilgileri.isEkolOrUni && MenuList.hasQBank() && controller.isCourseClass)
                                        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          MyDropDownField(
                                            canvasColor: Fav.design.dropdown.canvas,
                                            initialValue: controller.itemData!.classLevel,
                                            name: "classLevel".translate,
                                            iconData: MdiIcons.humanMaleBoard,
                                            color: Colors.deepPurpleAccent,
                                            items: ["0", '5', '6', '7', '8', '9', '10', '11', '12', '20', '30', '40', '41']
                                                .map((item) => DropdownMenuItem(
                                                    value: item,
                                                    child: Text(
                                                      ('classlevel' + item).translate,
                                                      style: TextStyle(color: Fav.design.primaryText),
                                                    )))
                                                .toList(),
                                            onSaved: (value) {
                                              controller.itemData!.classLevel = value;
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Text(
                                              'yearlevelqbankhint'.translate,
                                              style: TextStyle(color: Fav.design.disablePrimary, fontSize: 11),
                                            ),
                                          )
                                        ]),
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
                                      saveLocation: AppVar.appBloc.hesapBilgileri.kurumID! + '/' + AppVar.appBloc.hesapBilgileri.termKey! + '/' + "UserProfileImages",
                                      initialValue: controller.itemData!.imgUrl,
                                      onSaved: (value) {
                                        controller.itemData!.imgUrl = value;
                                      },
                                    ),
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
                                              .where((e) => e.classKeyList.contains(controller.selectedItem!.key))
                                              .map((e) => Center(
                                                    child: Text(
                                                      e.name!,
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
            key: controller.scaffoldKey,
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
