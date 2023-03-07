import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../timetable/widgets.dart';
import 'controller.dart';
import 'controllerhelper.dart';
import 'model.dart';

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<P2PController>();

    return LayoutBuilder(
      builder: (context, constratints) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: TimePlanner(
                key: controller.timePlannerKey,
                topLeftWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ('week'.translate + ' ' + controller.selectedWeekTime.weekOfYear.toString()).text.fontSize(8).bold.color(Fav.design.primaryText).make(),
                    Row(
                      children: [
                        Icons.arrow_left.icon.color(Colors.white).padding(0).size(17).onPressed(controller.previousWeek).make().circleBackground(background: Fav.design.primary).pl2,
                        2.widthBox,
                        Icons.arrow_right.icon.color(Colors.white).padding(0).size(17).onPressed(controller.nextWeek).make().circleBackground(background: Fav.design.primary).pr2,
                      ],
                    ),
                  ],
                ),
                visibleNonSettledTask: false,
                mainVerticalController: controller.timaTableVerticalController,
                startHour: controller.tableStartHour,
                endHour: controller.tableEndHour,
                style: TimePlannerStyle(
                  cellWidth: (constratints.maxWidth - 48) / 7,
                  cellHeight: controller.cellHeight,
                ),
                currentTimeAnimation: false,
                headers: P2PControllerHelper.timeTableHeader(controller.selectedWeekTime),
                tasks: controller.eventList.map<TimePlannerTask>((e) {
                  Widget current;
                  BoxDecoration? decoration;
                  if (e.eventType == EventType.timetableTeacher) {
                    current = TimeTableLessonCellWidget(
                      boxColor: Colors.black,
                      autoFitChild: true,
                      text1: e.title,
                      text2: e.subTitle,
                      boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    );
                  } else if (e.eventType == EventType.timetableStudent) {
                    current = TimeTableLessonCellWidget(
                      boxColor: Colors.black,
                      text1: e.title,
                      text2: e.subTitle,
                      autoFitChild: true,
                      boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    );
                  } else if (e.eventType == EventType.empty) {
                    final _color = controller.selectedEvent == e ? Colors.blue : Fav.design.primaryText;
                    current = Container(
                      margin: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _color.withAlpha(20),
                          _color.withAlpha(20),
                        ]),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Fav.design.primaryText, width: 1, style: BorderStyle.solid),
                      ),
                    );
                    // current = TimeTableLessonCellWidget(
                    //   boxColor: controller.selectedEvent == e ? Colors.blue : const Color(0xffdddddd),
                    //   //   child: Center(child: Icons.done.icon.padding(0).color(Colors.white).size(16).make()),
                    //   boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    // );
                    //  decoration = BoxDecoration(gradient: controller.selectedEvent == e ? Colors.blue.hueGradient : e.color.hueGradient, borderRadius: BorderRadius.circular(2));
                  } else if (e.eventType == EventType.p2p) {
                    current = MyPopupMenuButton(
                        padding: EdgeInsets.zero,
                        child: TimeTableLessonCellWidget(
                          boxColor: Colors.blueAccent,
                          autoFitChild: true,
                          text1: e.title.safeLength < 20 ? e.title : e.title!.split('\n').map((item) => item.capitalLettersJoin(characterCount: e.title.safeLength > 60 ? 1 : 3)).join(' '),
                          boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                        ),
                        onSelected: (value) {
                          if (value == 1) {
                            controller.deleteP2PEvent(e);
                          }
                        },
                        itemBuilder: (context) {
                          return <PopupMenuEntry>[
                            PopupMenuItem(value: -1, child: Text(e.title ?? '', style: TextStyle(color: Fav.design.primaryText))),
                            const PopupMenuDivider(),
                            PopupMenuItem(value: 1, child: Text(Words.delete, style: TextStyle(color: Fav.design.primaryText))),
                          ];
                        });
                  } else if (e.eventType == EventType.studentP2POtherTeacher) {
                    current = TimeTableLessonCellWidget(
                      text1: e.title,
                      autoFitChild: true,
                      boxColor: Colors.amber[900],
                      // child: FittedBox(child: Center(child: Icons.done.icon.padding(0).color(Colors.white).size(14).make())),
                      boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    );
                  } else {
                    current = Container();
                    decoration = BoxDecoration(gradient: e.color!.hueGradient, borderRadius: BorderRadius.circular(2));
                  }

                  if (decoration != null) {
                    current = Container(
                      child: current,
                      margin: const EdgeInsets.all(1.0),
                      decoration: decoration,
                    );
                  }

                  if (e.eventType == EventType.empty) {
                    if (isWeb) {
                      current = MouseRegion(
                        onEnter: (o) {},
                        onExit: (o) {
                          controller.mouseOnTime.last = 0;
                          controller.mouseOnTime.first = 0;
                        },
                        onHover: (o) {
                          final double y = o.localPosition.dy;
                          final double eventHeight = controller.cellHeight * (e.endMinute - e.startMinute) / 60;
                          final double time = e.startMinute + (y / eventHeight) * (e.endMinute - e.startMinute);
                          final hour = time ~/ 60;
                          num minute = time % 60;
                          minute = P2PControllerHelper.minuteEditor(minute);
                          controller.mouseOnTime.last = hour * 60 + (minute as int);

                          ///
                          controller.mouseOnTime.first = o.position.dx.toInt();
                        },
                        child: GestureDetector(
                          child: current,
                          onDoubleTap: () {
                            controller.smashEvent(e);
                          },
                          onTapDown: (tapDetails) {
                            controller.selectEmptyEvent(e, tapDetails);
                          },
                        ),
                      );
                    } else {
                      current = GestureDetector(
                        child: current,
                        onTap: () {
                          controller.selectEmptyEvent(e);
                        },
                      );
                    }
                  }
                  return TimePlannerTask(
                    dateTime: TimePlannerDateTime(day: e.day!, hour: e.startMinute ~/ 60, minutes: e.startMinute % 60),
                    minutesDuration: e.endMinute - e.startMinute,
                    daysDuration: 1,
                    child: current,
                  );
                }).toList(),
              ),
            ),
            if (isWeb)
              Obx(() {
                return Positioned(
                    left: controller.mouseOnTime.first.toDouble() - controller.teacherStudentListWidth! - (controller.isStudentRequestMenuOpen ? controller.studentRequestMenuWidth! : 0.0) + 4,
                    top: ((controller.cellHeight * ((controller.mouseOnTime.last ~/ 60) - controller.tableStartHour)) + (((controller.mouseOnTime.last % 60) * controller.cellHeight) / 60)).toDouble() + 48.0 - controller.timaTableVerticalControllerPosition - 4,
                    child: (controller.mouseOnTime.last == 0 ? '--:--' : (controller.mouseOnTime.last.timeToString)).text.fontSize(10).color(Colors.white).make().stadium(
                          background: Fav.design.primary,
                        ));
              }),
          ],
        );
      },
    );
  }
}

class EventForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<P2PController>();
    return Center(
      child: SizedBox(
        width: (context.width - 32).clamp(280.0, 560.0),
        //height: 300,
        child: Material(
          color: Colors.transparent,
          child: Card(
            color: Fav.design.card.background,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              McgFunctions.getDayNameFromDayOfWeek((controller.selectedDay ?? 0) + 1).text.color(Fav.design.card.text).fontSize(16).bold.make(),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250),
                child: Row(
                  children: [
                    Expanded(child: 'hour'.translate.text.color(Fav.design.card.text).fontSize(16).bold.make()),
                    SizedBox(
                      width: 80,
                      child: Obx(
                        () => DropDownMenu(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          onChanged: (dynamic value) {
                            controller.selectedHour.value = value;
                          },
                          items: controller.selectedEvent == null
                              ? []
                              : Iterable.generate(
                                  controller.selectedEvent!.endMinute ~/ 60 - controller.selectedEvent!.startMinute ~/ 60 + 1,
                                ).map((hour) => DropdownItem(value: controller.selectedEvent!.startMinute ~/ 60 + hour, name: (controller.selectedEvent!.startMinute ~/ 60 + hour).toString().padLeft(2, '0'))).toList(),
                          value: controller.selectedHour.value,
                        ),
                      ),
                    ),
                    ':'.text.color(Fav.design.card.text).fontSize(16).bold.make().px2,
                    SizedBox(
                      width: 80,
                      child: Obx(
                        () => DropDownMenu(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          placeHolderText: 'minute'.translate,
                          onChanged: (dynamic value) {
                            controller.selectedMinute.value = value;
                          },
                          items: controller.selectedEvent == null ? [] : Iterable.generate(12).map((minute) => DropdownItem(value: minute * 5, name: (minute * 5).toString().padLeft(2, '0'))).toList(),
                          value: controller.selectedMinute.value,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250),
                child: Row(
                  children: [
                    Expanded(child: 'duration'.translate.text.color(Fav.design.card.text).fontSize(16).bold.make()),
                    SizedBox(
                      width: 80,
                      child: Obx(() => DropDownMenu(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            onChanged: (dynamic value) {
                              controller.selectedLessonDuration.value = value;
                            },
                            items: Iterable.generate(12, (i) => i * 5 + 5).map((hour) => DropdownItem(value: hour, name: hour.toString().padLeft(2, '0'))).toList(),
                            value: controller.selectedLessonDuration.value,
                          )),
                    ),
                  ],
                ),
              ),
              MyTextField(
                controller: controller.noteController,
                hintText: 'note'.translate,
                maxLines: 1,
              ),
              8.heightBox,
              Row(
                children: [
                  ('teacher'.translate + ': ').text.color(Fav.design.card.text).fontSize(16).bold.make(),
                  Expanded(child: AppVar.appBloc.teacherService!.dataListItem(controller.selectedTeacher!)!.name.text.color(Fav.design.card.text).fontSize(14).make()),
                ],
              ).pb8,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ((controller.selectedStudentList.length == 1 ? 'student' : 'studentlist').translate + ': ').text.color(Fav.design.card.text).fontSize(16).bold.make(),
                  Expanded(child: controller.selectedStudentList.fold<String>('', (p, e) => p + ' ' + AppVar.appBloc.studentService!.dataListItem(e!)!.name!).text.color(Fav.design.card.text).fontSize(14).make())
                ],
              ).pb8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyRaisedButton(
                    text: 'cancel'.translate,
                    color: Fav.design.elevatedButton.variantBackground,
                    onPressed: () {
                      if (!controller.isLoading) {
                        controller.selectedEvent = null;
                        controller.noteController.text = '';
                        controller.pageUpdate();
                        Get.back();
                      }
                    },
                  ),
                  MyProgressButton(
                    label: Words.save,
                    onPressed: controller.saveEvent,
                    isLoading: controller.isLoading,
                  ),
                ],
              ).pt8,
            ]).p16,
          ),
        ),
      ),
    );
  }
}
