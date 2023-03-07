import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../reserve_p2p/layout.dart';
import 'controller.dart';
import 'model.dart';

class P2PEditLayoutPage extends StatelessWidget {
  P2PEditLayoutPage();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<P2PEditLayoutController>(
      init: P2PEditLayoutController(),
      builder: (controller) {
        return AppScaffold(
          topBar: TopBar(
              leadingTitle: 'back'.translate,
              backButtonPressed: () {
                Get.off(ReserveP2PLayout());
              }),
          topActions: TopActionsTitleWithChild(
              title: TopActionsTitle(title: 'setp2ptime'.translate),
              child: AdvanceDropdown(
                onChanged: (dynamic value) {
                  controller.teacherDropdownValue = value;
                  controller.update();
                },
                initialValue: controller.teacherDropdownValue,
                items: AppVar.appBloc.teacherService!.dataList.map((e) => DropdownItem(value: e.key, name: e.name)).toList()..insert(0, DropdownItem(value: 'school', name: 'schoolp2ptimes'.translate)),
              )),
          body: controller.isPageLoading ? Body.circularProgressIndicator() : Body.child(child: controller.teacherDropdownValue == 'school' ? _SchoolTimeList() : _TeacherTimeList()),
          bottomBar: BottomBar.row(children: [
            MyProgressButton(
              onPressed: controller.save,
              label: Words.save,
              isLoading: controller.isLoading,
            ),
          ]),
        );
      },
    );
  }
}

class _SchoolTimeList extends StatelessWidget {
  _SchoolTimeList();
  P2PEditLayoutController get controller => Get.find<P2PEditLayoutController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MyRaisedButton(
              text: 'clear'.translate,
              onPressed: () {
                controller.schoolDraftData.clearSchoolP2pDraftItems();
                controller.update();
              },
            ).pr16,
            MyRaisedButton(
              text: 'add'.translate,
              onPressed: controller.addItemsForSchoolDraft,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[1, 2, 3, 4, 5, 6, 7].map((dayNo) {
                  final _itemList = controller.schoolDraftData.getDayP2pSchoolDraftItems(dayNo);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      McgFunctions.getDayNameFromDayOfWeek(dayNo).toUpperCase().text.bold.color(Fav.design.primaryText).make(),
                      4.heightBox,
                      if (_itemList.isEmpty)
                        'norecords'.translate.text.make()
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._itemList
                                .map((item) => MaterialButton(
                                      color: Colors.green,
                                      key: ValueKey(item.key),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          (item.startTime!.timeToString + '-' + item.endTime!.timeToString).text.color(Colors.white).make(),
                                          8.widthBox,
                                          Icons.cancel.icon
                                              .padding(0)
                                              .onPressed(() {
                                                controller.schoolDraftData.removeItemInSchoolDraftItems(item.key);
                                                controller.update();
                                              })
                                              .color(Colors.white)
                                              .make(),
                                        ],
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      onPressed: () {},
                                    ))
                                .toList(),
                          ],
                        ),
                    ],
                  ).py4;
                }).toList()
              ],
            ),
          ),
        )
      ],
    ).p16;
  }
}

class _TeacherTimeList extends StatelessWidget {
  _TeacherTimeList();
  P2PEditLayoutController get controller => Get.find<P2PEditLayoutController>();

  @override
  Widget build(BuildContext context) {
    final _fullItemList = controller.schoolDraftData.p2pTeacherTimesDraftItems(controller.teacherDropdownValue);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icons.circle.icon.size(16).color(Colors.green).make(),
            'active'.translate.text.make(),
            Icons.circle.icon.size(16).color(Colors.red).make(),
            'passive'.translate.text.make(),
            Icons.circle.icon.size(16).color(Colors.cyan).make(),
            'p2pteacherhasprogram'.translate.text.make(),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[1, 2, 3, 4, 5, 6, 7].map((dayNo) {
                  final _itemList = _fullItemList.where((e) => e.dayNo == dayNo).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      McgFunctions.getDayNameFromDayOfWeek(dayNo).toUpperCase().text.bold.color(Fav.design.primaryText).make(),
                      4.heightBox,
                      if (_itemList.isEmpty)
                        'norecords'.translate.text.make()
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._itemList
                                .map((item) => MaterialButton(
                                      key: ValueKey(item.key),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      color: item.disableType == P2PDisableType.disable
                                          ? Colors.red
                                          : item.disableType == P2PDisableType.program
                                              ? Colors.cyan
                                              : item.disableType == P2PDisableType.active
                                                  ? Colors.green
                                                  : Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          (item.startTime!.timeToString + '-' + item.endTime!.timeToString).text.color(Colors.white).make(),
                                          8.widthBox,
                                          (item.disableType == P2PDisableType.disable
                                                  ? Icons.lock
                                                  : item.disableType == P2PDisableType.program
                                                      ? Icons.lock
                                                      : item.disableType == P2PDisableType.active
                                                          ? Icons.lock_open
                                                          : Icons.lock)
                                              .icon
                                              .padding(0)
                                              .color(Colors.white)
                                              .make(),
                                        ],
                                      ),
                                      onPressed: () {
                                        controller.schoolDraftData.toggleTeacherDisabledValue(controller.teacherDropdownValue, item.key);
                                        controller.update();
                                      },
                                    ))
                                .toList(),
                          ],
                        ),
                    ],
                  ).py4;
                }).toList()
              ],
            ).p16,
          ),
        ),
      ],
    );
  }
}
