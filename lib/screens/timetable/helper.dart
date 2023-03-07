class TimeTableHelper {
  TimeTableHelper._();

  static void afterTimeTableNewData() {
    calculateAgendaItems();
  }

  static Future<void> calculateAgendaItems() async {
    //? Simdilik ajandaya ders progami eklemekten vazgectim.
    //? Ogrenci kismi yazilmisti test edip eklemek istersen yayinlayabilirsin. Ama ogretmenide eklemen lazim
    //? schoolTimesService gec olusabildiginden delay eklendi
    // await 500.wait;
    // final times = AppVar.appBloc.schoolTimesService.dataList.last;
    // final _timeTableAgendaItems = <Appointment>[];

    // final _now = DateTime.now();
    // final _birAyOncekiPazartesi = _now.subtract(Duration(days: _now.weekday + 28));

    // if (AppVar.appBloc.hesapBilgileri.gtS) {
    //   final _sinifList = StudentFunctions.getClassList();
    //   if (_sinifList.isNotEmpty) {
    //     final _programData = ProgramHelper.getStudentAllLessonFromTimeTable(_sinifList);
    //     _programData.forEach((item) {
    //       final _lessonTimes = times.getDayLessonNoTimes(item.day.toString(), item.lessonNo - 1);
    //       _timeTableAgendaItems.add(Appointment(
    //         subject: item.lesson.longName,
    //         startTime: DateTime(_birAyOncekiPazartesi.year, _birAyOncekiPazartesi.month, _birAyOncekiPazartesi.day + item.day - 1, _lessonTimes.first ~/ 60, _lessonTimes.first % 60),
    //         endTime: DateTime(_birAyOncekiPazartesi.year, _birAyOncekiPazartesi.month, _birAyOncekiPazartesi.day + item.day - 1, _lessonTimes.last ~/ 60, _lessonTimes.last % 60),
    //         color: item.lesson.color.parseColor,
    //         recurrenceRule: RecurrenceRule(Freq.WEEKLY, interval: 1, byDay: [item.day]).rules,
    //         isAllDay: false,
    //         resourceIds: ResourceIdRule(AgendaGroup.timetable, otherKeys: [item.lesson.key]).idList,
    //       ));
    //     });
    //   }
    // } else if (AppVar.appBloc.hesapBilgileri.gtT) {}

    // Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.timetable, _timeTableAgendaItems);
  }
}
