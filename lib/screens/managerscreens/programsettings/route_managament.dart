import 'package:mcg_extension/mcg_extension.dart';

import '../../../models/class.dart';
import '../registrymenu/teacherscreen/teacher.dart';
import 'checkprogram/classprogram/layout.dart' deferred as class_program;
import 'checkprogram/teacheprogram/layout.dart' deferred as teacher_program;
import 'schooltimes/schooltimes.dart' deferred as school_times;
import 'timetables/layout.dart' deferred as edit_time_tables;

class TimeTablesMainRoutes {
  TimeTablesMainRoutes._();

  static Future<void>? goEditTimeTables() async {
    OverLoading.show();
    await edit_time_tables.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(edit_time_tables.TimeTableEditView());
  }

  static Future<void>? goSchoolTimes() async {
    OverLoading.show();
    await school_times.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(school_times.SchoolTimes());
  }

  static Future<void>? goTeacherProgram({Teacher? initialItem}) async {
    OverLoading.show();
    await teacher_program.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(teacher_program.CheckTeacherProgram(
      initialItem: initialItem,
    ));
  }

  static Future<void>? goClassProgram({Class? initialItem}) async {
    OverLoading.show();
    await class_program.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(class_program.CheckClassProgram(
      initialItem: initialItem,
    ));
  }
}
