import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'model.dart';
import 'otherscreens/studentrequest/model.dart';

class P2PControllerHelper {
  P2PControllerHelper._();
  static List<TimePlannerTitle> timeTableHeader(DateTime time) {
    final weekDay = time.weekday;

    return [
      time.subtract((weekDay - 1).days),
      time.subtract((weekDay - 2).days),
      time.subtract((weekDay - 3).days),
      time.subtract((weekDay - 4).days),
      time.subtract((weekDay - 5).days),
      time.subtract((weekDay - 6).days),
      time.subtract((weekDay - 7).days),
    ]
        .map((e) => TimePlannerTitle(
              title: e.dateFormat('EEE'),
              date: e.dateFormat('d-MMM'),
            ))
        .toList();
  }

  static void addEmptyEvents(int tableStartHour, int tableEndHour, Map<String, List<int?>>? teacherLimitations, List<TimeTableP2PEvent> teacherEventList, P2PRequest? request, bool isRequestHourDeletable) {
    final _tableStartHour = isRequestHourDeletable == false || request == null ? tableStartHour : [tableStartHour, request.startHour! ~/ 60].max;
    final _tableEndHour = isRequestHourDeletable == false || request == null ? tableEndHour : [tableEndHour, request.endHour! ~/ 60].min;

    for (var day = 0; day < 7; day++) {
      if (isRequestHourDeletable == true && request != null && !request.dayList!.contains(day + 1)) continue;
      List<int> blocks = Iterable.generate(288, (i) => i).toList();
      //Saat araligi  disindakiler siliniyor
      //if (day == 0) print('Yazzz: ${_tableEndHour * 12}');
      blocks.removeWhere((element) => element < _tableStartHour * 12 || element >= _tableEndHour * 12);
      if (teacherLimitations != null && teacherLimitations['d${day + 1}'] != null) {
        blocks.removeWhere((element) => element < teacherLimitations['d${day + 1}']!.first! ~/ 60 * 60 / 5 + teacherLimitations['d${day + 1}']!.first! % 60 / 5 || element > teacherLimitations['d${day + 1}']!.last! ~/ 60 * 60 ~/ 5 + teacherLimitations['d${day + 1}']!.last! % 60 ~/ 5);
      }
      //Var  olan etkinlikler siliniyor
      teacherEventList.forEach((event) {
        if (event.day == day) blocks.removeWhere((blok) => event.getBlokOfDay.contains(blok));
      });
      //  if (day == 0) print('Yazzz: $blocks');
      int? baslangic;
      int? control;

      blocks.forEach((element) {
        if (baslangic == null || control == null) {
          baslangic = element;
          control = element;
        } else if (element == blocks.last) {
          teacherEventList.add(TimeTableP2PEvent(
            id: 'lesson${10.makeKey}',
            color: Fav.design.primaryText.withAlpha(50),
            title: '',
            day: day,
            startMinute: baslangic! * 5,
            endMinute: (control! + 1) * 5 + 5,
            eventType: EventType.empty,
          ));
        } else if (element == control! + 1) {
          control = control! + 1;
        } else {
          teacherEventList.add(TimeTableP2PEvent(
            id: 'lesson${10.makeKey}',
            color: Fav.design.primaryText.withAlpha(50),
            title: '',
            day: day,
            startMinute: baslangic! * 5,
            endMinute: (control! + 1) * 5,
            eventType: EventType.empty,
          ));
          baslangic = element;
          control = element;
        }
      });
    }
  }

  static num minuteEditor(num minute) {
    return (minute ~/ 5) * 5;

    // if (minute < 5) {
    //   minute = 0.0;
    // } else if (minute < 10) {
    //   minute = 5.0;
    // } else if (minute < 15) {
    //   minute = 10.0;
    // } else if (minute < 20) {
    //   minute = 15.0;
    // } else if (minute < 25) {
    //   minute = 20.0;
    // } else if (minute < 30) {
    //   minute = 25.0;
    // } else if (minute < 35) {
    //   minute = 30.0;
    // } else if (minute < 40) {
    //   minute = 35.0;
    // } else if (minute < 45) {
    //   minute = 40.0;
    // } else if (minute < 50) {
    //   minute = 45.0;
    // } else if (minute < 55) {
    //   minute = 50.0;
    // } else {
    //   minute = 55.0;
    // }
    // return minute;
  }
}
