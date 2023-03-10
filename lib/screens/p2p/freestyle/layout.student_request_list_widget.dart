import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import 'controller.dart';
import 'otherscreens/studentrequest/model.dart';

class StudentRequestList extends StatelessWidget {
  StudentRequestList();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<P2PController>();

    final _waitingRequests = <P2PRequest>[];
    final _completedRequests = <P2PRequest>[];
    final _otherRequests = <P2PRequest>[];

    final _otherRequestKeyList = Fav.preferences.getLimitedStringList('P2POtherItems', []);

    controller.studenRequests.forEach((element) {
      if (controller.filteredClass == 'all' || AppVar.appBloc.studentService!.dataListItem(element.studentKey!)!.classKeyList.contains(controller.filteredClass)) {
        if (controller.isRequestOk(element)) {
          _completedRequests.add(element);
        } else if (_otherRequestKeyList!.contains(element.week.toString() + element.key!)) {
          _otherRequests.add(element);
        } else {
          _waitingRequests.add(element);
        }
      }
    });

    _waitingRequests.sort((a, b) => a.lastUpdate - b.lastUpdate);
    _completedRequests.sort((a, b) => a.lastUpdate - b.lastUpdate);

    if (controller.studenRequests.isEmpty) return EmptyState();
    return Container(
      decoration: BoxDecoration(color: Fav.design.scaffold.accentBackground, borderRadius: BorderRadius.only(topRight: Radius.circular(8))),
      child: Column(
        children: [
          AdvanceDropdown<String>(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              initialValue: controller.filteredClass,
              searchbarEnableLength: 1000,
              items: AppVar.appBloc.classService!.dataList
                  .where((element) {
                    if (controller.classListContainsClassTypes) return true;
                    return element.classType == 0;
                  })
                  .map((e) => DropdownItem(name: e.name, value: e.key))
                  .toList()
                ..insert(0, DropdownItem(name: 'allclass'.translate, value: 'all')),
              onChanged: (value) {
                controller.filteredClass = value;
                controller.update();
              }),
          Expanded(
            child: FormStack(useDropDown: true, children: [
              ...[0, 1, 2]
                  .map((e) => FormStackItem(
                      name: e == 0
                          ? 'waitingrequest'.translate
                          : e == 1
                              ? 'completed'.translate
                              : 'other'.translate,
                      child: Column(
                        children: [
                          if (e == 2) 'p2potherrequesthint'.translate.text.center.color(Fav.design.primaryText).fontSize(8).make().p4,
                          Expanded(
                            child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Container(color: Fav.design.primaryText.withAlpha(50), width: double.infinity, height: 0.8);
                                },
                                padding: const EdgeInsets.only(top: 8),
                                itemCount: e == 0
                                    ? _waitingRequests.length
                                    : e == 1
                                        ? _completedRequests.length
                                        : _otherRequests.length,
                                itemBuilder: (context, index) {
                                  final _request = e == 0
                                      ? _waitingRequests[index]
                                      : e == 1
                                          ? _completedRequests[index]
                                          : _otherRequests[index];
                                  final _student = AppVar.appBloc.studentService!.dataListItem(_request.studentKey!);
                                  final _lesson = AppVar.appBloc.lessonService!.dataListItem(_request.lessonKey!);
                                  final _teacher = AppVar.appBloc.teacherService!.dataListItem(_lesson?.teacher ?? 'yooook');
                                  final _class = AppVar.appBloc.classService!.dataListItem(_student?.class0 ?? 'yoook');

                                  return GestureDetector(
                                    onTap: () async {
                                      await controller.selectRequest(_request);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      color: controller.selectedRequest?.key == _request.key
                                          ? Fav.design.primary.withAlpha(30)
                                          : index.isOdd
                                              ? Fav.design.scaffold.background
                                              : Fav.design.scaffold.accentBackground,
                                      child: Row(
                                        children: [
                                          if (e == 1) Icons.done.icon.color(Colors.green).make(),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    if (_class != null) _class.name.text.fontSize(9).color(Colors.white).make().stadium(background: Colors.redAccent, padding: const EdgeInsets.all(2)).pr8,
                                                    if (_student != null) Expanded(child: _student.name.text.autoSize.maxLines(1).color(Fav.design.primaryText).make()),
                                                    8.widthBox,
                                                    (_request.lastUpdate as int?)!.dateFormat('dd-MMM, HH:mm').text.fontSize(8).color(Fav.design.primaryText.withAlpha(150)).make(),
                                                    4.widthBox,
                                                    if (e == 0 || e == 2)
                                                      Tooltip(
                                                          message: 'p2pmoveotherhint'.translate,
                                                          child: Icons.move_down_rounded.icon
                                                              .onPressed(() async {
                                                                if (e == 0) {
                                                                  await Fav.preferences.addLimitedStringList('P2POtherItems', _request.week.toString() + _request.key!, maxNumber: 1000);
                                                                } else if (e == 2) {
                                                                  await Fav.preferences.removeThisStringInStringList('P2POtherItems', _request.week.toString() + _request.key!);
                                                                }

                                                                controller.update();
                                                              })
                                                              .size(12)
                                                              .color(Fav.design.primaryText)
                                                              .padding(0)
                                                              .make())
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    if (_lesson != null) _lesson.name.text.fontSize(9).color(Colors.white).make().stadium(background: Colors.teal, padding: const EdgeInsets.all(2)).pr8,
                                                    if (_teacher != null) Expanded(child: _teacher.name.text.bold.color(Fav.design.primaryText).maxLines(1).make()),
                                                  ],
                                                ),
                                                Wrap(
                                                  crossAxisAlignment: WrapCrossAlignment.start,
                                                  alignment: WrapAlignment.start,
                                                  runAlignment: WrapAlignment.start,
                                                  children: [
                                                    ..._request.dayList!.map((e) => McgFunctions.getDayNameFromDayOfWeek(e!, format: 'EEE').text.fontSize(8).color(Colors.white).make().stadium(background: Colors.purple, padding: const EdgeInsets.all(2))).toList(),
                                                    8.widthBox,
                                                    _request.startHour!.timeToString.text.fontSize(9).color(Colors.white).make().stadium(background: Colors.blueAccent, padding: const EdgeInsets.all(2)),
                                                    '-'.text.make(),
                                                    _request.endHour!.timeToString.text.fontSize(9).color(Colors.white).make().stadium(background: Colors.blueAccent, padding: const EdgeInsets.all(2)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      )))
                  .toList(),
            ]).px2,
          ),
        ],
      ),
    );
  }
}
