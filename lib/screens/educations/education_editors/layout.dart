import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../localization/usefully_words.dart';
import 'controller.dart';
import 'model.dart';

class EducationList extends StatelessWidget {
  EducationList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EducationListController>(
        init: EducationListController(),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'educationlist'.translate)
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
                  detailLeadingTitle: 'educationlist'.translate,
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
                    pageStorageKey: 'ADeducationlist',
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
                        controller.selectItem(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.child(
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: controller.treeViewController == null
                          ? SizedBox()
                          : FormStack(
                              children: [
                                FormStackItem(
                                    name: 'bookinfo'.translate,
                                    child: AnimatedGroupWidget(
                                      children: [
                                        MyMultiSelect(
                                          iconData: Icons.search,
                                          context: context,
                                          miniChip: true,
                                          items: controller.schoolPackageList.map((e) => MyMultiSelectItem(e.key, e.name!)).toList() as List<MyMultiSelectItem<String>>,
                                          initialValue: controller.itemData!.serverIdList as List<String>? ?? [],
                                          title: 'choosetarget'.translate,
                                          name: 'choosetarget'.translate,
                                          onSaved: (value) {
                                            controller.itemData!.serverIdList = value;
                                          },
                                        ),
                                        MyTextFormField(
                                          onSaved: (text) {
                                            controller.itemData!.name = text;
                                          },
                                          onChanged: (text) {
                                            controller.itemData!.name = text;
                                          },
                                          initialValue: controller.itemData!.name,
                                          labelText: 'name'.translate,
                                          iconData: Icons.app_registration_outlined,
                                          validatorRules: ValidatorRules(req: true, minLength: 3),
                                        ),
                                        MyTextFormField(
                                          onSaved: (text) {
                                            controller.itemData!.exp = text;
                                          },
                                          onChanged: (text) {
                                            controller.itemData!.exp = text;
                                          },
                                          maxLines: null,
                                          initialValue: controller.itemData!.exp,
                                          labelText: 'aciklama'.translate,
                                          iconData: Icons.app_registration_outlined,
                                          validatorRules: ValidatorRules(req: true, minLength: 0),
                                        ),
                                        MyMultiSelect(
                                          title: "classLevel".translate,
                                          validatorRules: ValidatorRules(minLength: 1),
                                          context: context,
                                          initialValue: controller.itemData!.classLevelList!,
                                          name: "classLevel".translate,
                                          iconData: MdiIcons.humanMaleBoard,
                                          items: ["0", '5', '6', '7', '8', '9', '10', '11', '12', '20', '30', '40', '41'].map((item) => MyMultiSelectItem(item, ('classlevel' + item).translate)).toList(),
                                          onSaved: (value) {
                                            controller.itemData!.classLevelList = value;
                                          },
                                        ),
                                        MyPhotoUploadWidget(
                                          validatorRules: ValidatorRules(req: true),
                                          saveLocation: controller.fileSaveLocation,
                                          initialValue: controller.itemData!.imgUrl,
                                          onSaved: (value) {
                                            controller.itemData!.imgUrl = value;
                                          },
                                        )
                                      ],
                                    )),
                                FormStackItem(
                                    name: 'bookcontents'.translate,
                                    child: IndexedTreeView<EducationNode>(
                                      initialItem: controller.initialRoot,
                                      controller: controller.treeViewController as IndexedTreeViewController<EducationNode>?,
                                      expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
                                      expansionIndicator: ExpansionIndicator(expandIcon: SizedBox(), collapseIcon: SizedBox()),
                                      shrinkWrap: true,
                                      showRootNode: true,
                                      indentPadding: 32,
                                      builder: (context, level, item) => item.isRoot
                                          ? Builder(builder: (context) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  item.children.isNotEmpty
                                                      ? Icons.arrow_drop_down_circle_sharp.icon.color(Fav.design.primary).onPressed(() {
                                                          controller.treeViewController!.toggleNodeExpandCollapse(item);
                                                        }).make()
                                                      : SizedBox(width: 32),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 16.0),
                                                    child: OutlinedButton.icon(
                                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
                                                      icon: Icon(Icons.add_circle),
                                                      label: Text("add".translate),
                                                      onPressed: () {
                                                        item.add(EducationNode.create());
                                                        controller.update();
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 16.0),
                                                    child: OutlinedButton.icon(
                                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
                                                      icon: Icon(Icons.delete),
                                                      label: Text("clear".translate),
                                                      onPressed: () {
                                                        controller.treeViewController!.root.clear();
                                                        controller.update();
                                                      },
                                                    ),
                                                  ),
                                                  FileUploadWidget(
                                                    name: 'PDF',
                                                    initialValue: controller.itemData!.pdf1 == null
                                                        ? null
                                                        : FileResult(
                                                            url: controller.itemData!.pdf1!,
                                                            name: 'uploadedfile'.translate,
                                                          ),
                                                    saveLocation: controller.fileSaveLocation,
                                                    maxSizeMB: 50,
                                                    onSaved: (value) {
                                                      if (value != null) {
                                                        controller.itemData!.pdf1 = value.url;
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            })
                                          : Card(
                                              color: Fav.design.card.background,
                                              child: ListTile(
                                                leading: item.children.isNotEmpty
                                                    ? Icons.arrow_drop_down_circle_sharp.icon.color(Fav.design.primary).onPressed(() {
                                                        controller.treeViewController!.toggleNodeExpandCollapse(item);
                                                      }).make()
                                                    : SizedBox(width: 32),
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: AdvanceDropdown<EducationNodeType>(
                                                        iconData: Icons.merge_type,
                                                        padding: EdgeInsets.all(0),
                                                        items: [
                                                          DropdownItem(value: EducationNodeType.none, name: 'header'.translate),
                                                          // DropdownItem(value: EducationNodeType.youtube, name: 'Youtube video'),
                                                          DropdownItem(value: EducationNodeType.video, name: 'Video'),
                                                          DropdownItem(value: EducationNodeType.pdfReadPage, name: 'Pdf page'),
                                                        ],
                                                        initialValue: item.type ?? EducationNodeType.none,
                                                        name: 'type'.translate,
                                                        onChanged: (value) {
                                                          item.type = value;
                                                        },
                                                        validatorRules: ValidatorRules(req: true),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: MyTextFormField(
                                                        padding: Inset.h(2),
                                                        labelText: 'header'.translate,
                                                        onChanged: (value) {
                                                          item.title = value;
                                                        },
                                                        initialValue: item.title,
                                                        validatorRules: ValidatorRules(req: true, minLength: 2),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: MyTextFormField(
                                                        maxLines: null,
                                                        padding: Inset.h(2),
                                                        labelText: 'content'.translate,
                                                        onChanged: (value) {
                                                          item.subTitle = value;
                                                        },
                                                        initialValue: item.subTitle,
                                                        validatorRules: ValidatorRules(),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: MyTextFormField(
                                                        maxLines: null,
                                                        padding: Inset.h(2),
                                                        labelText: 'Data'.translate,
                                                        onChanged: (value) {
                                                          item.data1 = value;
                                                        },
                                                        initialValue: item.data1,
                                                        validatorRules: ValidatorRules(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                dense: true,
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () => item.delete(),
                                                      icon: Icon(Icons.delete, color: Colors.red),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        item.add(EducationNode.create());
                                                        controller.update();
                                                      },
                                                      icon: Icon(Icons.add_circle, color: Colors.green),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ).pr32)
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
                    child: Container(margin: const EdgeInsets.only(left: 16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.customDesign4.primary), child: const Icon(Icons.more_vert, color: Colors.white)),
                    onSelected: (value) async {
                      if (value == 0) {
                        var sure = await Over.sure();
                        if (sure == true) await controller.save(isDelete: true);
                      }
                    },
                  ),
                const Spacer(),
                if (controller.selectedItem != null)
                  MyProgressButton(
                    color: MyPalette.getBaseColor(3),
                    onPressed: controller.preview,
                    label: 'preview'.translate,
                  ).pr16,
                MyProgressButton(
                  onPressed: () {
                    controller.save(isPublish: true);
                  },
                  label: Words.save + ' ' + 'and'.translate + ' ' + 'publish'.translate,
                  isLoading: controller.isSaving,
                ).pr16,
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
