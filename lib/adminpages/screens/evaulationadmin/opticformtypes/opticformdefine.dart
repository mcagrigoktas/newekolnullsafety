import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../localization/usefully_words.dart';
import '../../../../screens/managerscreens/registrymenu/copy_another_term_helper.dart';
import '../helper.dart';
import 'controller.dart';
import 'model.dart';

class OpticFormDefine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpticFormDefineController>(
      builder: (controller) {
        final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.addItem).make();
        final Widget _middle = (controller.dataIsNew
                ? 'new'.translate
                : controller.selectedItem != null
                    ? controller.selectedItem!.name
                    : 'opticalforms'.translate)
            .text
            .bold
            .color(Fav.design.primary)
            .maxLines(1)
            .fontSize(18)
            .autoSize
            .make();

        final Widget trailingActions = MyPopupMenuButton(
          itemBuilder: (context) {
            return <PopupMenuEntry>[
              PopupMenuItem(value: 3, child: Text('copyanotherterm'.translate)),
            ];
          },
          child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(top: 0, right: 8, bottom: 0, left: 0),
          onSelected: (value) async {
            if (value == 3) {
              CopyFromAnotherTermHelper.copyOpticForm(controller.examType).unawaited;
            }
          },
        );

        final _topBar = controller.dataIsNew
            ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.deSelectItem, middle: _middle)
            : RTopBar(
                mainLeadingTitle: 'back'.translate,
                leadingTitleMainEqualBoth: true,
                detailBackButtonPressed: controller.deSelectItem,
                detailLeadingTitle: 'opticalforms'.translate,
                bothMiddle: _middle,
                mainMiddle: _middle,
                detailMiddle: _middle,
                detailTrailingActions: [_newButton, if (controller.girisTuru == EvaulationUserType.school) trailingActions],
                mainTrailingActions: [_newButton, if (controller.girisTuru == EvaulationUserType.school) trailingActions],
                bothTrailingActions: [_newButton, if (controller.girisTuru == EvaulationUserType.school) trailingActions],
              );

        Body? _leftBody;
        Body? _rightBody;
        if (controller.isPageLoading) {
          _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
        } else {
          final _filteredAllOpticFormList = controller.getFilteredAllOpticFormList();
          _leftBody = controller.dataIsNew == true
              ? null
              : Body.listviewBuilder(
                  pageStorageKey: 'adminopticformdefinelist',
                  itemCount: _filteredAllOpticFormList.length,
                  itemBuilder: (context, index) {
                    var item = _filteredAllOpticFormList[index];
                    return MyCupertinoListTile(
                      onTap: () {
                        controller.selectItem(item);
                      },
                      title: (controller.girisTuru == item.userType ? '' : '(*) ') + item.name!,
                      isSelected: controller.selectedItem?.key == item.key,
                    );
                  },
                );

          _rightBody = controller.dataIsNew == false && controller.selectedItem == null
              ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
              : Body.singleChildScrollView(
                  maxWidth: 720,
                  withKeyboardCloserGesture: true,
                  child: Column(
                    children: [
                      if (controller.girisTuru != controller.selectedItem?.userType)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)), color: Fav.design.primary),
                          child: ('(*) ' + "opticformdefineradmin".translate).text.color(Colors.white).center.make(),
                        ),
                      MyForm(
                        formKey: controller.formKey,
                        child: AbsorbPointer(
                          absorbing: !controller.elementCanBeChange(controller.selectedItem),
                          child: Column(
                            children: [
                              Opacity(
                                opacity: controller.dataIsNew ? 1.0 : 0.75,
                                child: AbsorbPointer(
                                  absorbing: !controller.dataIsNew,
                                  child: AdvanceDropdown<int>(
                                    name: 'seisonno'.translate,
                                    nullValueText: ''.translate,
                                    validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
                                    iconData: Icons.alt_route_outlined,
                                    initialValue: controller.selectedItem?.seisonNo,
                                    onSaved: (value) => controller.selectedItem!.seisonNo = value,
                                    onChanged: (value) {
                                      controller.selectedItem = OpticFormModel.create(controller.examType!, controller.girisTuru, seisonNo: value);
                                      controller.update();
                                    },
                                    items: Iterable.generate(controller.examType!.numberOfSeison!, (e) => e + 1).map((e) => DropdownItem(value: e, name: e.toString())).toList(),
                                  ),
                                ),
                              ),
                              AnimatedGroupWidget(
                                children: [
                                  MyTextFormField(
                                    labelText: 'name'.translate,
                                    hintText: 'rememberhint'.translate,
                                    validatorRules: ValidatorRules(req: true, minLength: 4),
                                    iconData: Icons.nat,
                                    initialValue: controller.selectedItem?.name,
                                    onSaved: (value) => controller.selectedItem!.name = value,
                                  ),
                                  MyTextFormField(
                                    labelText: 'aciklama'.translate,
                                    hintText: 'rememberhint'.translate,
                                    validatorRules: ValidatorRules(req: true, minLength: 20),
                                    iconData: Icons.devices,
                                    initialValue: controller.selectedItem?.explanation,
                                    onSaved: (value) => controller.selectedItem!.explanation = value,
                                  ),
                                ],
                              ),
                              ...([
                                controller.selectedItem!.studentNameData,
                                controller.selectedItem!.studentNumberData,
                                controller.selectedItem!.studentIdData,
                                controller.selectedItem!.studentClassData,
                                controller.selectedItem!.studentSectionData,
                                controller.selectedItem!.bookletTypeData,
                                ...controller.selectedItem!.lessonsData!.values,
                              ])
                                  .map<Widget>((e) => Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Container(
                                              child: e!.dataName.text.bold.make(),
                                            ).px8,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: MyTextFormField(
                                              padding: EdgeInsets.zero,
                                              labelText: 'startindex'.translate,
                                              initialValue: e.start.toString(),
                                              onSaved: (value) => e.start = int.parse(value),
                                              validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 0),
                                            ).px4,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: MyTextFormField(
                                              padding: EdgeInsets.zero,
                                              labelText: 'endindex'.translate,
                                              validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
                                              initialValue: e.end.toString(),
                                              onSaved: (value) => e.end = int.parse(value),
                                            ).px4,
                                          ),
                                        ],
                                      ).py8)
                                  .toList(),
                            ],
                          ),
                        ),
                      ).px16,
                    ],
                  ));
        }

        RBottomBar? _bottomBar;
        if (controller.selectedItem != null && controller.elementCanBeChange(controller.selectedItem)) {
          Widget _bottomChild = Row(
            children: [
              if (controller.selectedItem != null && !controller.dataIsNew)
                MyPopupMenuButton(
                  itemBuilder: (context) {
                    return <PopupMenuEntry>[
                      PopupMenuItem(value: 0, child: Text(Words.delete)),
                    ];
                  },
                  child: Container(margin: const EdgeInsets.only(left: 16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.customDesign4.primary), child: const Icon(Icons.more_vert, color: Colors.white)),
                  onSelected: (value) async {
                    if (value == 0) {
                      var sure = await Over.sure(message: controller.selectedItem!.name! + '\n' + 'deleterecorderr'.translate);
                      if (sure == true) await controller.deleteItem();
                    }
                  },
                ),
              if (controller.girisTuru == EvaulationUserType.admin)
                SizedBox(
                  width: 160,
                  child: MySwitch(
                    name: 'publish'.translate,
                    initialValue: controller.selectedItem!.isPublished,
                    onChanged: (value) => controller.selectedItem!.isPublished = value,
                  ).px4,
                ),
              const Spacer(),
              MyProgressButton(onPressed: controller.saveItem, label: Words.save, isLoading: controller.isLoading).pr12,
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
      },
    );
  }
}
