import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../helpers/glassicons.dart';
import '../../main/macos_dock/macos_dock.dart';
import 'appointment_widget.dart';

class AgendaWidgetContent extends StatelessWidget {
  AgendaWidgetContent();
  final controller = Get.find<MacOSDockController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _now = DateTime.now();
      final _agendaItemList = <Appointment>[];

//? Ders programi ajandaya ekleniyor simdilik eklemiyor timetable helperea bakabilirsin
      //     if (controller.timeTableAgendaList() != null) _agendaItemList.addAll(controller.timeTableAgendaList());

      //? Birebirler ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.p2pAgendaList());

      //? Ev odevleri ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.homeWorkAgendaList());

      //? Ders sinavlari ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.lessonExamAgendaList());

      //? LiveBroadCast ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.liveBroadCastAgendaList());

      //? Video Chat ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.videoChatAgendaList());

      //? Exam List ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.examAgendaList());

      //? Dogum gunleri ajandaya ekleniyor
      _agendaItemList.addAllIfNotNull(controller.birthDayAgendaList());

      final _dataSource = AgendaItemDataSource(_agendaItemList);
      final CalendarController calendarController = CalendarController()..selectedDate = DateTime.now();
      calendarController.view = Fav.preferences.getEnum<CalendarView>('agendaViewType', CalendarView.values, CalendarView.month);

      //? Bunu delaydan cikarinca widget cizilemez
      () {
        controller.agendaBadge.value = _agendaItemList.where((element) => element.startTime.isToday == true).length;
      }.delay(1);

      return LayoutBuilder(builder: (context, constraints) {
        double _height = constraints.maxHeight;
        final agendaViewHeight = constraints.maxHeight / 2.75;
        //? tahmini header icin ayrilan yer dusuldu
        _height -= 40;
        _height -= agendaViewHeight;

        return SfCalendar(
          controller: calendarController,
          allowViewNavigation: true,
          allowedViews: [
            CalendarView.month,
            CalendarView.schedule,
          ],
          showCurrentTimeIndicator: true,

          viewNavigationMode: ViewNavigationMode.snap,
          todayHighlightColor: GlassIcons.agenda.color,
          showWeekNumber: false,
          cellBorderColor: Fav.design.primaryText.withAlpha(128),
          //  showNavigationArrow: true,
          cellEndPadding: 5,
          view: CalendarView.month,
          initialSelectedDate: DateTime.now(),
          firstDayOfWeek: 1,

          dataSource: _dataSource,
          selectionDecoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2), side: BorderSide(color: GlassIcons.agenda.color!)),
          ),
          appointmentBuilder: (context, details) {
            if (details.appointments.length != 1) return Container();
            return AppointmentWidget(appointment: details.appointments.first);
          },

          monthCellBuilder: (context, details) {
            bool _isToday = details.date.year == _now.year && details.date.month == _now.month && details.date.day == _now.day;

            return Container(
              alignment: Alignment.center,
              decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: Fav.design.primaryText.withAlpha(40), width: 0.8))),
              child: Column(
                children: [
                  Spacer(flex: 3),
                  _isToday ? CircleAvatar(radius: 12, backgroundColor: GlassIcons.agenda.color, child: details.date.dateFormat('d').text.autoSize.color(Colors.white).bold.make().p4) : details.date.dateFormat('d').text.bold.make(),
                  Spacer(flex: 2),
                  if (details.appointments.isNotEmpty == true)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            details.appointments.length.clamp(0, 5),
                            (index) => CircleAvatar(
                                  backgroundColor: (details.appointments[index] as Appointment).color,
                                  radius: 2.7,
                                ).px1))
                  else
                    SizedBox(
                      height: 5.4,
                    ),
                  Spacer(flex: 3),
                ],
              ),
            );
          },
          onViewChanged: (details) {
            Fav.preferences.setEnum('agendaViewType', calendarController.view!);
          },
          monthViewSettings: MonthViewSettings(
            showAgenda: true,
            appointmentDisplayMode: MonthAppointmentDisplayMode.none,
            agendaViewHeight: agendaViewHeight,
            agendaItemHeight: 44,
            agendaStyle: AgendaStyle(),
            numberOfWeeksInView: (_height ~/ 48).clamp(1, 6),
            monthCellStyle: MonthCellStyle(),
          ),
          scheduleViewMonthHeaderBuilder: (context, details) {
            return Container(
              color: GlassIcons.agenda.color,
              alignment: Alignment.center,
              child: details.date.dateFormat('MMMM yyyy').text.color(Colors.white).fontSize(18).make(),
            );
          },
          scheduleViewSettings: ScheduleViewSettings(
              appointmentItemHeight: 44,
              monthHeaderSettings: MonthHeaderSettings(
                backgroundColor: GlassIcons.agenda.color!,
                height: 36,
                textAlign: TextAlign.center,
              )),
          timeSlotViewSettings: TimeSlotViewSettings(
            timeFormat: 'HH:mm',
          ),
        ).p8;
      });
    });
  }
}

class AgendaItemDataSource extends CalendarDataSource<Appointment> {
  AgendaItemDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return itemList[index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return itemList[index].endTime;
  }

  @override
  String getSubject(int index) {
    return itemList[index].subject;
  }

  @override
  Color getColor(int index) {
    return itemList[index].color;
  }

  @override
  bool isAllDay(int index) {
    return itemList[index].isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    return itemList[index].recurrenceRule;
  }

  @override
  List<Object>? getResourceIds(int index) {
    return itemList[index].resourceIds;
  }

  List<Appointment> get itemList => List<Appointment>.from(appointments!);
}

class RecurrenceRule {
  //? https://help.syncfusion.com/flutter/calendar/appointments#recurrence-appointment
  late String rules;
  RecurrenceRule(
    Freq freq, {
    int? interval,
    int? count,
    List<int>? byDay,
  }) {
    rules = 'FREQ=' + freq.name;
    if (interval != null) rules += ';INTERVAL=$interval';
    if (count != null) rules += ';COUNT=$count';
    if (byDay != null) rules += ';BYDAY=${_byDayConvert(byDay)}';
  }

  String? _byDayConvert(List<int> byDay) {
    String? byDayText = '';
    if (byDay.contains(1)) byDayText += 'MO,';
    if (byDay.contains(2)) byDayText += 'TU,';
    if (byDay.contains(3)) byDayText += 'WE,';
    if (byDay.contains(4)) byDayText += 'TH,';
    if (byDay.contains(5)) byDayText += 'FR,';
    if (byDay.contains(6)) byDayText += 'SA,';
    if (byDay.contains(7)) byDayText += 'SU,';
    if (byDayText.lastXcharacter(1) == ',') byDayText = byDayText.firstXcharacter(byDayText.length - 1);
    return byDayText;
  }
}

class ResourceIdRule {
  List<Object> idList = [];
  ResourceIdRule(AgendaGroup group, {List<Object>? otherKeys}) {
    idList.add(group.name);
    if (otherKeys != null) idList.addAll(otherKeys);
  }
}

enum Freq {
  DAILY,
  WEEKLY,
  MONTHLY,
  YEARLY,
}
