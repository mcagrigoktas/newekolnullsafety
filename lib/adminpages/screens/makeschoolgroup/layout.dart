import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../localization/usefully_words.dart';
import 'controller.dart';
import 'school_group.dart';

class MakeSchoolGroup extends StatelessWidget {
  MakeSchoolGroup();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MakeSchoolGroupController>(
        init: MakeSchoolGroupController(),
        builder: (controller) {
          final Widget _newButton = AddIcon(onPressed: controller.clickNewItem);
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'School Group'.translate)
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
                  detailLeadingTitle: 'School Group'.translate,
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
                    pageStorageKey: 'SchoolGroup',
                    listviewFirstWidget: MySearchBar(
                      onChanged: (text) {
                        controller.makeFilter(text);
                        controller.update();
                      },
                      resultCount: controller.filteredItemList.length,
                    ).p4,
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
                      child: AnimatedGroupWidget(
                        children: <Widget>[
                          IgnorePointer(
                            ignoring: controller.newItem == null,
                            child: Column(
                              children: [
                                AdvanceDropdown<SchoolGroupForWhat>(
                                  initialValue: controller.itemData!.forWhat,
                                  name: "Hangi Menu Icin".translate,
                                  iconData: MdiIcons.account,
                                  validatorRules: ValidatorRules(req: true, minLength: 1),
                                  onSaved: (value) {
                                    controller.itemData!.forWhat = value;
                                  },
                                  items: [
                                    [SchoolGroupForWhat.education, 'EducationList']
                                  ].map((e) => DropdownItem<SchoolGroupForWhat>(name: e.last as String, value: e.first as SchoolGroupForWhat)).toList(),
                                ),
                                'Kaydedildikten Sonra Degistirilemez. Dikkatli secin'.text.color(Colors.amber).fontSize(10).make()
                              ],
                            ),
                          ).pb12,
                          MyTextFormField(
                            initialValue: controller.itemData!.name,
                            labelText: "name".translate,
                            iconData: MdiIcons.account,
                            validatorRules: ValidatorRules(req: true, minLength: 6),
                            onSaved: (value) {
                              controller.itemData!.name = value;
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
                          MyMultiSelect(
                            iconData: MdiIcons.viewList,
                            context: context,
                            items: controller.serverList.map((e) => MyMultiSelectItem(e.key, e.key)).toList(),
                            title: 'Kurum Listesi',
                            initialValue: controller.itemData!.schoolIdList!,
                            onSaved: (value) {
                              controller.itemData!.schoolIdList = value;
                            },
                          ),
                          MyMultiSelect(
                            iconData: MdiIcons.viewList,
                            context: context,
                            items: controller.superManagerList.map((e) => MyMultiSelectItem(e.superManagerServerId!, e.superManagerServerId!)).toList(),
                            title: 'Hangi genel mudurlukler bu grubu gorebilsin',
                            initialValue: controller.itemData!.generalManagersWhoCanSee!,
                            onSaved: (value) {
                              controller.itemData!.generalManagersWhoCanSee = value;
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
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
