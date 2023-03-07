import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';
import 'package:widgetpackage/mycolorpicker.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../copy_another_term_helper.dart';
import '../teacherscreen/branches.dart';
import 'controller.dart';

class LessonList extends StatelessWidget {
  LessonList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LessonListController>(
        init: LessonListController(),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'lessonlist'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final Widget _otherItems = MyPopupMenuButton(
              itemBuilder: (context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(value: 4, child: Text('copyfromanotherclass'.translate)),
                  PopupMenuItem(value: 3, child: Text('copyanotherterm'.translate)),
                ];
              },
              child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(top: 0, right: 8, bottom: 0, left: 0),
              onSelected: (value) async {
                if (value == 3) {
                  CopyFromAnotherTermHelper.copyLessons().unawaited;
                } else if (value == 4) {
                  CopyFromAnotherTermHelper.copyFromAnotherSameTermClassLessons().unawaited;
                }
              });

          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'lessonlist'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_newButton, _otherItems],
                  mainTrailingActions: [_newButton, _otherItems],
                  bothTrailingActions: [_newButton, _otherItems],
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
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID! + 'lessonlist',
                    listviewFirstWidget: Row(
                      children: [
                        if (controller.filteredClassKey['filteredClassKey'] != null)
                          Expanded(
                            child: AdvanceDropdown(
                              padding: Inset(4),
                              items: controller.classListDropdown,
                              onChanged: (dynamic value) {
                                controller.selectedItem = null;
                                controller.filteredClassKey['filteredClassKey'] = value;
                                controller.makeFilter();
                                controller.update();
                              },
                              initialValue: controller.filteredClassKey['filteredClassKey'],
                            ),
                          ),
                        Text(
                          "${controller.filteredItemList.length}",
                          style: const TextStyle(color: Colors.white),
                        ).p4.circleBackground(background: Fav.design.primary).px8
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
                                labelText: "name".translate,
                                hintText: "maxfourcharacter".translate,
                                iconData: MdiIcons.account,
                                validatorRules: ValidatorRules(req: true, maxLength: 4, minLength: 1),
                                onSaved: (value) {
                                  controller.itemData!.name = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.itemData!.longName,
                                labelText: "longname".translate,
                                iconData: MdiIcons.card,
                                validatorRules: ValidatorRules(req: true, minLength: 4),
                                onSaved: (value) {
                                  controller.itemData!.longName = value;
                                },
                              ),
                              Opacity(
                                opacity: controller.selectedItem != null ? 0.5 : 1,
                                child: AbsorbPointer(
                                  absorbing: controller.selectedItem != null,
                                  child: MyDropDownField(
                                    canvasColor: Fav.design.dropdown.canvas,
                                    initialValue: controller.itemData!.classKey,
                                    name: "class".translate,
                                    iconData: MdiIcons.humanMaleBoard,
                                    color: Colors.black,
                                    items: controller.classListDropdown2,
                                    onSaved: (value) {
                                      controller.itemData!.classKey = value;
                                    },
                                  ),
                                ),
                              ),
                              AdvanceDropdown(
                                iconData: MdiIcons.book,
                                initialValue: controller.itemData!.branch,
                                name: 'branch'.translate,
                                onSaved: (dynamic value) {
                                  controller.itemData!.branch = value;
                                },
                                extraWidget: MyMiniTextButton(
                                  onPressed: () async {
                                    Get.back();
                                    await Fav.to(BranchesPage(previousMenuName: 'lessonlist'.translate));
                                    controller.update();
                                  },
                                  text: 'editbranchlist'.translate,
                                ),
                                items: AppVar.appBloc.schoolInfoService!.singleData!.branchList.map((e) => DropdownItem(name: e, value: e)).toList()..insert(0, DropdownItem(name: 'anitemchoose'.translate, value: null)),
                              ),
                              MyDropDownField(
                                canvasColor: Fav.design.dropdown.canvas,
                                initialValue: controller.itemData!.teacher,
                                name: "teacher".translate,
                                iconData: MdiIcons.humanMaleBoard,
                                color: Colors.black,
                                items: controller.teacherListDropdown,
                                onSaved: (value) {
                                  controller.itemData!.teacher = value;
                                },
                              ),
                              MyDropDownField(
                                canvasColor: Fav.design.dropdown.canvas,
                                initialValue: controller.itemData!.count,
                                name: "weeklycount".translate,
                                iconData: MdiIcons.humanMaleBoard,
                                color: Colors.black,
                                items: Iterable.generate(20).map((number) {
                                  return DropdownMenuItem(value: number + 1, child: Text('${number + 1}', style: TextStyle(color: Fav.design.primaryText)));
                                }).toList(),
                                onSaved: (value) {
                                  controller.itemData!.count = value;
                                },
                              ),
                              if (AppVar.appBloc.hesapBilgileri.isEkolOrUni)
                                MyTextFormField(
                                  initialValue: controller.itemData!.distribution,
                                  hintText: "2+2+1".translate,
                                  labelText: "dist".translate,
                                  iconData: MdiIcons.key,
                                  validatorRules: ValidatorRules(),
                                  onSaved: (value) {
                                    controller.itemData!.distribution = value;
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
