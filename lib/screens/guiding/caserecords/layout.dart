import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import 'controller.dart';
import 'model.dart';

class CaseRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CaseRecordsController>(
        init: CaseRecordsController(),
        builder: (controller) {
          if (controller.isPasswordChanged == false) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['changepasswordforguide'.translate.text.fontSize(24).center.make().p16, MyRaisedButton(onPressed: Get.back, text: 'back'.translate)],
                ),
              ),
            );
          }

          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();

          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : controller.menuName.translate)
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
                  detailLeadingTitle: controller.menuName.translate,
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
                    pageStorageKey: controller.listViewPageStorageKey,
                    listviewFirstWidget: Column(
                      children: [
                        MySearchBar(
                          onChanged: (text) {
                            controller.makeFilter(text);
                            controller.update();
                          },
                          resultCount: controller.filteredItemList.length,
                          initialText: controller.filteredText,
                        ).p4,
                        AdvanceDropdown(
                          padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
                          items: [
                            DropdownItem(name: 'caserecordA'.translate, value: 0),
                            DropdownItem(name: 'caserecordC'.translate, value: 1),
                          ],
                          onChanged: (dynamic value) {
                            controller.caseRecordStatusDropdownValue = value;
                            controller.makeFilter(controller.filteredText);
                            controller.update();
                          },
                          initialValue: controller.caseRecordStatusDropdownValue,
                        ),
                      ],
                    ),
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) {
                      final CaseRecordModel _item = controller.filteredItemList[index];
                      return MyCupertinoListTile(
                        maxLines: 2,
                        title: _item.listTileName,
                        borderColor: _item.isClosed! ? Colors.red : null,
                        onTap: () {
                          controller.selectItem(_item);
                        },
                        isSelected: _item.key == controller.itemData?.key,
                      );
                    },
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 720,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          IgnorePointer(
                            ignoring: controller.newItem == null,
                            child: Group2Widget(leftItemPercent: 66, children: [
                              Group2Widget(
                                leftItemPercent: 40,
                                children: [
                                  AdvanceDropdown<bool>(
                                    initialValue: controller.itemData!.targetListIsClassList,
                                    items: [
                                      DropdownItem(value: false, name: 'studentlist'.translate),
                                      DropdownItem(value: true, name: 'classlist'.translate),
                                    ],
                                    onChanged: (value) {
                                      controller.itemData!.targetListIsClassList = value;
                                      controller.update();
                                    },
                                    onSaved: (value) {
                                      controller.itemData!.targetListIsClassList = value;
                                      controller.itemData!.targetList!.clear();
                                      controller.update();
                                    },
                                  ),
                                  AdvanceMultiSelectDropdown(
                                      key: ValueKey('CasDW${controller.itemData!.targetListIsClassList}'),
                                      onSaved: (value) {
                                        controller.itemData!.targetList = value as List<String>?;
                                      },
                                      validatorRules: ValidatorRules(req: true, minLength: 1),
                                      name: controller.itemData!.targetListIsClassList == true ? 'chooseclass'.translate : 'choosestudent'.translate,
                                      nullValueText: controller.itemData!.targetListIsClassList == true ? 'chooseclass'.translate : 'choosestudent'.translate,
                                      initialValue: controller.itemData!.targetList,
                                      items: controller.itemData!.targetListIsClassList == true
                                          ? controller.classList.map((e) {
                                              return DropdownItem(name: e!.name, value: e.key);
                                            }).toList()
                                          : controller.studentList!.map((e) {
                                              return DropdownItem(name: e.name, value: e.key);
                                            }).toList()),
                                ],
                              ),
                              AdvanceMultiSelectDropdown(
                                onSaved: (value) {
                                  controller.itemData!.teacherList = value as List<String?>?;
                                },
                                validatorRules: ValidatorRules(req: true, minLength: 1),
                                name: 'chooseteacher'.translate,
                                nullValueText: 'chooseteacher'.translate,
                                initialValue: controller.itemData!.teacherList,
                                items: [
                                  ...AppVar.appBloc.managerService!.dataList,
                                  ...AppVar.appBloc.teacherService!.dataList,
                                ].map((e) {
                                  if (e is Teacher) return DropdownItem(name: e.name, value: e.key);
                                  if (e is Manager) return DropdownItem(name: e.name, value: e.key);
                                  return DropdownItem(name: '-', value: '-');
                                }).toList(),
                              ),
                            ]),
                          ),
                          MiniFormStack(
                            children: [
                              FormStackItem(
                                  name: 'recordsinfo'.translate,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MyTextFormField(
                                        labelText: 'header'.translate,
                                        initialValue: controller.itemData!.name,
                                        iconData: MdiIcons.account,
                                        validatorRules: ValidatorRules(req: true, minLength: 6),
                                        onSaved: (value) {
                                          controller.itemData!.name = value;
                                        },
                                      ),
                                      MyTextFormField(
                                        maxLines: null,
                                        labelText: 'content'.translate,
                                        initialValue: controller.itemData!.content,
                                        iconData: MdiIcons.text,
                                        validatorRules: ValidatorRules(req: true, minLength: 20),
                                        onSaved: (value) {
                                          controller.itemData!.content = value;
                                        },
                                      ),
                                    ],
                                  )),
                              FormStackItem(
                                  name: 'otherinfo'.translate,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MyDatePicker(
                                        title: 'starttime'.translate,
                                        initialValue: controller.itemData!.startDate,
                                        onSaved: (value) {
                                          controller.itemData!.startDate = value;
                                        },
                                      ),
                                      AdvanceDropdown<CaseRecordItemStarter>(
                                        initialValue: controller.itemData!.caseRecordItemStarter,
                                        name: 'poffertomeet'.translate,
                                        items: [
                                          DropdownItem(value: CaseRecordItemStarter.mentor, name: 'mentor'.translate),
                                          DropdownItem(value: CaseRecordItemStarter.parent, name: 'parent'.translate),
                                          DropdownItem(value: CaseRecordItemStarter.student, name: 'student'.translate),
                                          DropdownItem(value: CaseRecordItemStarter.other, name: 'other'.translate),
                                        ],
                                        onSaved: (value) {
                                          controller.itemData!.caseRecordItemStarter = value;
                                          controller.update();
                                        },
                                      ),
                                      //! Ilerde gorusme nedeni eklemek istersen simdiden ayarlandi secenekleri gir yeter
                                      if (1 > 2)
                                        AdvanceDropdown<CaseRecordOpenReason>(
                                          initialValue: controller.itemData!.openReason,
                                          name: 'meetreason'.translate,
                                          items: [
                                            DropdownItem(value: CaseRecordOpenReason.other, name: 'other'.translate),
                                          ],
                                          onSaved: (value) {
                                            controller.itemData!.openReason = value;
                                            controller.update();
                                          },
                                        ),
                                      MySwitch(
                                        name: 'hassensitivedatahint'.translate,
                                        initialValue: controller.itemData!.hasSensitiveData,
                                        onSaved: (value) {
                                          controller.itemData!.hasSensitiveData = value;
                                        },
                                      ),
                                      if (controller.newItem == null)
                                        MyTextFormField(
                                          key: ObjectKey(controller.itemData!.closeReason),
                                          labelText: 'closemeetreason'.translate,
                                          hintText: 'closemeetreasonhint'.translate,
                                          initialValue: controller.itemData!.closeReason,
                                          iconData: MdiIcons.closeBoxOutline,
                                          validatorRules: ValidatorRules(req: false),
                                          onSaved: (value) {
                                            controller.itemData!.closeReason = value;
                                          },
                                        ),
                                    ],
                                  )),
                            ],
                            initialIndex: 0,
                          ),
                          if (controller.selectedItem != null)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    'records'.translate.text.color(Colors.white).make().rounded(background: Fav.design.primary, borderRadius: 4, padding: Inset.hv(32, 6)),
                                    16.widthBox,
                                    if (controller.selectedItem!.teacherList!.contains(AppVar.appBloc.hesapBilgileri.uid))
                                      MaterialButton(
                                        elevation: 0,
                                        color: Fav.design.primary.withAlpha(10),
                                        onPressed: controller.addItem,
                                        child: ('+' + ' ' + 'add'.translate).text.bold.color(Fav.design.primary).make(),
                                      ),
                                  ],
                                ),
                                if (controller.selectedItem!.items == null || controller.selectedItem!.items!.isEmpty)
                                  EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS)
                                else
                                  ...(controller.selectedItem!.items!.reversed).map((e) {
                                    Widget _content = e.content.text.make();
                                    final _deleteButton = Icons.delete.icon.color(Colors.red.withAlpha(80)).onPressed(() async {
                                      final _sure = await Over.sure();
                                      if (_sure == true) {
                                        controller.selectedItem!.items!.remove(e);
                                        await controller.save();
                                      }
                                    }).make();
                                    if (e.type == CaseRecordItemType.documents && e.documentUrl.safeLength > 6) {
                                      _content = Align(
                                          alignment: Alignment.topLeft,
                                          child: TextButton(
                                              style: TextButton.styleFrom(backgroundColor: Fav.design.primaryText.withAlpha(30)),
                                              onPressed: () {
                                                DocumentView.openTypeList(e.documentUrl!);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(child: _content),
                                                  8.widthBox,
                                                  Icons.open_in_new.icon.padding(0).color(Fav.design.primaryText).size(18).make(),
                                                ],
                                              )));
                                    }
                                    if (e.type == CaseRecordItemType.meeting) {
                                      //? Burda sadece ilk ogretmenin adi yaziliyor ama grubun diger elemanlarinida yazdirabilirsin;
                                      var _writer = AppVar.appBloc.teacherService!.dataListItem(e.teacherList!.first!)?.name;
                                      _writer ??= AppVar.appBloc.managerService!.dataListItem(e.teacherList!.first!)?.name;
                                      _content = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _content,
                                          Row(
                                            children: [
                                              if (e.duration != null) (e.duration.toString() + ' ' + 'minute'.translate).text.color(Colors.white).fontSize(10).make().stadium().p2,
                                              (e.meetingType == MeetingType.p2p
                                                      ? 'p2p_m'.translate
                                                      : e.meetingType == MeetingType.online
                                                          ? 'online_m'.translate
                                                          : e.meetingType == MeetingType.phone
                                                              ? 'phone_m'.translate
                                                              : 'other'.translate)
                                                  .text
                                                  .color(Colors.white)
                                                  .fontSize(10)
                                                  .make()
                                                  .stadium(background: Colors.indigoAccent)
                                                  .p2,
                                              if (_writer != null) (_writer).text.color(Colors.white).fontSize(10).make().stadium(background: Colors.pinkAccent).p2,
                                            ],
                                          )
                                        ],
                                      );
                                    }
                                    final Widget _current = Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _content),
                                        if (controller.selectedItem!.teacherList!.contains(AppVar.appBloc.hesapBilgileri.uid)) _deleteButton,
                                      ],
                                    );
                                    return TimelineTile(
                                      beforeLineStyle: LineStyle(color: Fav.design.primaryText.withAlpha(200), thickness: 3),
                                      afterLineStyle: LineStyle(color: Fav.design.primaryText.withAlpha(200), thickness: 3),
                                      // startChild: _dateWidget,
                                      lineXY: 0.0,
                                      alignment: TimelineAlign.start,
                                      endChild: Center(child: _current.p8),
                                      isFirst: controller.selectedItem!.items!.indexOf(e) == controller.selectedItem!.items!.length - 1,
                                      isLast: controller.selectedItem!.items!.indexOf(e) == 0,
                                      indicatorStyle: IndicatorStyle(
                                        indicator: e.date!.dateFormat('dd-MMM\nHH:mm').toUpperCase().text.color(Colors.black).center.autoSize.maxLines(2).bold.make().stadium(
                                            background: e.type == CaseRecordItemType.note
                                                ? Colors.amber
                                                : e.type == CaseRecordItemType.documents
                                                    ? Colors.deepOrangeAccent
                                                    : e.type == CaseRecordItemType.meeting
                                                        ? Colors.tealAccent
                                                        : Colors.greenAccent),
                                        width: 60,
                                        height: 35,
                                        indicatorXY: e.content.safeLength < 250 ? 0.5 : 0.08,
                                      ),
                                    );
                                  }).toList()
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
                if (controller.selectedItem != null && controller.selectedItem!.teacherList!.contains(AppVar.appBloc.hesapBilgileri.uid))
                  ConfirmButton(
                    title: Words.delete,
                    sureText: 'sure'.translate,
                    iconData: Icons.delete,
                    yesPressed: controller.delete,
                  ).pl16,
                const Spacer(),
                if (controller.selectedItem == null || controller.selectedItem!.teacherList!.contains(AppVar.appBloc.hesapBilgileri.uid))
                  MyProgressButton(
                    onPressed: controller.save,
                    label: Words.save,
                    isLoading: controller.isLoading,
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
