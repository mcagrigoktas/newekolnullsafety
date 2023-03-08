import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../common_p2p_helper.dart';
import '../edit_p2p_draft/layout.dart';
import '../edit_p2p_draft/model.dart';
import 'controller.dart';

class ReserveP2PLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReserveP2PController>(
      init: ReserveP2PController(),
      builder: (controller) {
        return AppScaffold(
            topBar: TopBar(leadingTitle: 'back'.translate, trailingActions: [
              if (AppVar.appBloc.hesapBilgileri.gtM)
                MyMiniRaisedButton(
                    onPressed: () {
                      Get.off(P2PEditLayoutPage());
                    },
                    text: 'setp2ptime'.translate)
            ]),
            topActions: TopActionsTitleWithChild(
                title: TopActionsTitle(title: 'requestp2p'.translate),
                child: Column(
                  children: [
                    AdvanceDropdown(
                      iconData: Icons.calendar_today,
                      name: 'week'.translate,
                      initialValue: controller.selectedWeek,
                      nullValueText: 'week'.translate,
                      items: CommonP2PHelper.weekItems,
                      validatorRules: ValidatorRules(req: true),
                      onChanged: (dynamic value) {
                        controller.weekChange(value);
                      },
                    ),
                    if (!AppVar.appBloc.hesapBilgileri.gtT)
                      AdvanceDropdown<String>(
                        name: Words.teacherList,
                        onChanged: controller.teacherChange,
                        initialValue: controller.selectedTeacher,
                        items: controller.dropDownItemList,
                      ),
                  ],
                )),
            body: controller.isLoading
                ? Body.circularProgressIndicator()
                : Body.child(
                    child: Column(
                    children: [
                      if (controller.selectedWeek == null)
                        EmptyState(text: Words.chooseDate)
                      else if (controller.selectedTeacher == null)
                        EmptyState(text: 'chooseteacher'.translate)
                      else
                        Expanded(child: AppVar.appBloc.hesapBilgileri.gtS ? _TeacherTimeListForStudent() : _TeacherTimeListForTeacherOrManager()),
                    ],
                  )));
      },
    );
  }
}

class _TeacherTimeListForTeacherOrManager extends StatelessWidget {
  _TeacherTimeListForTeacherOrManager();
  ReserveP2PController get controller => Get.find<ReserveP2PController>();

  @override
  Widget build(BuildContext context) {
    final _fullItemList = controller.schoolDraftData.p2pTeacherTimesDraftItems(controller.selectedTeacher);

    if (_fullItemList.isEmpty) {
      return EmptyState(
        text: 'p2pdraftemptyerr'.translate,
      );
    }

    return Column(
      children: [
        _Legand(),
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
                            ..._itemList.map((item) {
                              final weekData = controller.selectedWeekP2pData.getWeekRecordForThisItem(item, controller.selectedTeacher, controller.selectedWeek);

                              final color = weekData?.maxStudentCount == 0
                                  ? Colors.red
                                  : weekData?.isFull == true
                                      ? Colors.purpleAccent
                                      : item.disableType == P2PDisableType.disable
                                          ? Colors.red
                                          : item.disableType == P2PDisableType.program
                                              ? Colors.cyan
                                              : item.disableType == P2PDisableType.active
                                                  ? Colors.green
                                                  : Colors.red;

                              return MaterialButton(
                                key: ValueKey(item.key),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                color: color,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      children: [
                                        (item.startTime!.timeToString + '-' + item.endTime!.timeToString).text.color(Colors.white).make(),
                                        if (weekData?.studentListData?.isNotEmpty == true)
                                          (weekData!.studentListData!.values.first.safeSubString(0, 15)! + (weekData.studentListData!.values.length > 1 ? (' +' + (weekData.studentListData!.values.length - 1).toString() + ' ' + 'person'.translate) : ''))
                                              .text
                                              .color(Colors.purpleAccent)
                                              .fontSize(8)
                                              .make()
                                              .rounded(borderRadius: 2, background: Fav.design.scaffold.background, padding: Inset.hv(4, 0))
                                      ],
                                    ),
                                    if (item.disableType == P2PDisableType.disable || item.disableType == P2PDisableType.program)
                                      Icons.lock.icon.padding(0).color(Colors.white).make().pl8
                                    else if (weekData != null && weekData.maxStudentCount! > 1)
                                      weekData.maxStudentCount.toString().text.color(color).make().p2.circleBackground(background: Colors.white).pl8,
                                  ],
                                ),
                                onPressed: () {
                                  if (weekData != null || item.disableType == P2PDisableType.active) {
                                    controller.teacherReserveMenu(item, weekData);
                                  }
                                },
                              );
                            }).toList(),
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

class _TeacherTimeListForStudent extends StatelessWidget {
  _TeacherTimeListForStudent();
  ReserveP2PController get controller => Get.find<ReserveP2PController>();

  @override
  Widget build(BuildContext context) {
    final _fullItemList = controller.schoolDraftData.p2pTeacherTimesDraftItems(controller.selectedTeacher);
    return Column(
      children: [
        _Legand(),
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
                            ..._itemList.map((item) {
                              final weekData = controller.selectedWeekP2pData.getWeekRecordForThisItem(item, controller.selectedTeacher, controller.selectedWeek);
                              bool reservedToMe = weekData != null && AppVar.appBloc.hesapBilgileri.gtS && weekData.studentListIncludeMe;
                              bool iAmInTargetList = true;

                              if (weekData != null && weekData.targetList != null && weekData.targetList!.isNotEmpty) {
                                iAmInTargetList = AppVar.appBloc.hesapBilgileri.classKeyList.any((element) => weekData.targetList!.contains(element));
                              }

                              final color = weekData?.maxStudentCount == 0
                                  ? Colors.red
                                  : reservedToMe
                                      ? Colors.brown
                                      : weekData?.isFull == true
                                          ? Colors.purpleAccent
                                          : iAmInTargetList == false
                                              ? Colors.red
                                              : item.disableType == P2PDisableType.disable
                                                  ? Colors.red
                                                  : item.disableType == P2PDisableType.program
                                                      ? Colors.cyan
                                                      : item.disableType == P2PDisableType.active
                                                          ? Colors.green
                                                          : Colors.red;

                              return MaterialButton(
                                key: ValueKey(item.key),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                color: color,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    (item.startTime!.timeToString + '-' + item.endTime!.timeToString).text.color(Colors.white).make(),
                                    if (item.disableType == P2PDisableType.disable || item.disableType == P2PDisableType.program || weekData?.isFull == true)
                                      Icons.lock.icon.padding(0).color(Colors.white).make().pl8
                                    else if (weekData != null && weekData.maxStudentCount! - weekData.studentListData!.length > 1)
                                      (weekData.maxStudentCount! - weekData.studentListData!.length).toString().text.color(color).make().p2.circleBackground(background: Colors.white).pl8,
                                  ],
                                ),
                                onPressed: () {
                                  if (!iAmInTargetList) return;
                                  if (reservedToMe || item.disableType == P2PDisableType.active) {
                                    if (reservedToMe || weekData?.isFull != true) {
                                      controller.makeRezerveForStudent(item, weekData, cancelReserve: reservedToMe == true);
                                    }
                                  }
                                },
                              );
                            }).toList(),
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

class _Legand extends StatelessWidget {
  _Legand();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (AppVar.appBloc.hesapBilgileri.gtS) Icons.circle.icon.size(16).color(Colors.brown).make(),
        if (AppVar.appBloc.hesapBilgileri.gtS) 'belongsyou'.translate.text.make(),
        Icons.circle.icon.size(16).color(Colors.green).make(),
        'active'.translate.text.make(),
        Icons.circle.icon.size(16).color(Colors.purpleAccent).make(),
        'reserved'.translate.text.make(),
        Icons.circle.icon.size(16).color(Colors.red).make(),
        'passive'.translate.text.make(),
        Icons.circle.icon.size(16).color(Colors.cyan).make(),
        'p2pteacherhasprogram'.translate.text.make(),
      ],
    );
  }
}
