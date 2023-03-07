import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/class.dart';
import '../../../models/lesson.dart';
import '../../p2p/freestyle/model.dart';
import '../registrymenu/teacherscreen/teacher.dart';
import 'programlistmodels.dart';

class ProgramItem {
  int? day;
  int? lessonNo;
  Lesson? lesson;

  ///Birlestirilmis siniflar programda gozukecekse birlestirilmis siniflarin isim listesini tutar
  String? classTypeName;

  ProgramItem();
}

class ProgramHelper {
  ProgramHelper._();

  static Map getLastSturdyProgram({TimesModel? timesModel}) {
    final _times = timesModel ?? AppVar.appBloc.schoolTimesService!.dataList.last;
    var _programData = AppVar.appBloc.tableProgramService!.takeData(1).entries.first.value['classProgram'];
    return ProgramHelper.makeProgramSturdy(_programData, _times);
  }

  static Map makeProgramSturdy(Map? programData, TimesModel? timesModel) {
    final Map _programData = json.decode(json.encode(programData));
    final _mustDeleteClassList = [];
    // Eger gun yada saat acik degilse o saat ve gundeki yazilmis dersleri kaldirir
    // [_duplicateCache] Ogretmenin ayni saate baska dersi varsa siler
    Set<String?> _duplicateCache = {};

    _programData.forEach((classKey, classProgram) {
      final _class = AppVar.appBloc.classService!.dataListItem(classKey);
      if (_class == null) _mustDeleteClassList.add(classKey);

      var mustDelete = [];
      (classProgram as Map).entries.forEach((entry) {
        final timeKey = entry.key;
        final _lessonKey = entry.value;
        final _lesson = AppVar.appBloc.lessonService!.dataListItem(_lessonKey);

        if (_lesson == null) {
          mustDelete.add(timeKey);
        } else if (_lesson.teacher != null && _duplicateCache.contains(timeKey + _lesson.teacher)) {
          mustDelete.add(timeKey);
        } else {
          final day = (timeKey as String).split('-').first;
          final hour = timeKey.split('-').last;
          if (!timesModel!.activeDays!.contains(day)) {
            mustDelete.add(timeKey);
          } else if (timesModel.getDayLessonCount(day)! < int.tryParse(hour)!) {
            mustDelete.add(timeKey);
          }
        }

        if (_lesson != null && _lesson.teacher != null) _duplicateCache.add(timeKey + _lesson.teacher);
      });
      mustDelete.forEach((key) {
        classProgram.remove(key);
      });
    });
    _programData.removeWhere((key, value) => _mustDeleteClassList.contains(key));
    return _programData;
  }

//!program data sturdy olarak gelsin
  static List<ProgramItem> getTeacherAllLessonFromTimeTable(String? teacherKey, Map programData) {
    List<ProgramItem> _data = [];

    programData.forEach((classKey, value) {
      final Map classProgramData = value;
      classProgramData.forEach((time, lessonKey) {
        var lesson = AppVar.appBloc.lessonService!.dataListItem(lessonKey);
        if (lesson != null && lesson.teacher == teacherKey) {
          final day = (time as String).split('-').first;
          final lessonNo = time.toString().split('-').last;
          final item = ProgramItem()
            ..lesson = lesson
            ..day = int.parse(day)
            ..lessonNo = int.parse(lessonNo);

          _data.add(item);
        }
      });
    });

    return _data;
  }

//!program data sturdy olarak gelsin
  static List<ProgramItem> getClassAllLessonFromTimeTable(String? classKey, Map programData) {
    List<ProgramItem> _resultList = [];

    if (programData[classKey] == null) return _resultList;
    final Map classProgramData = programData[classKey];

    ///Burada birlestirilmis siniflarin datasi eklenecek
    final _contacatenatedClassData = ProgramHelper.getClassTypeAndClassAnalyseData()!;

    final _classReletaionList = _contacatenatedClassData[classKey] ?? {};
    _classReletaionList.forEach((concatenatedClass) {
      final _concatenatedClassProgram = programData[concatenatedClass] ?? {};

      final _otherClass = AppVar.appBloc.classService!.dataListItem(concatenatedClass!)!;
      final _classTypeName = AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!['t' + _otherClass.classType.toString()];

      _concatenatedClassProgram.entries.forEach((programItemEntry) {
        if (_otherClass.classType != null && _classTypeName != null) {
          if (classProgramData[programItemEntry.key] == null || (classProgramData[programItemEntry.key] is String && AppVar.appBloc.lessonService!.dataList.singleWhereOrNull((lesson) => lesson.key == classProgramData[programItemEntry.key]) == null)) {
            classProgramData[programItemEntry.key] = [_classTypeName];
          } else if (classProgramData[programItemEntry.key] is String) {
            //Bisey Yapma

          } else if (classProgramData[programItemEntry.key] is List) {
            classProgramData[programItemEntry.key] = {...(classProgramData[programItemEntry.key] as List), _classTypeName}.toList();
          }
        }
      });
    });

    ///Bitti
    classProgramData.forEach((time, lessonKey) {
      if (lessonKey is List) {
        final _name = lessonKey.fold<String>('', (p, classTypeName) {
          return p.contains(classTypeName) ? p : (p += ' $classTypeName');
        });
        final day = (time as String).split('-').first;
        final lessonNo = time.toString().split('-').last;
        final item = ProgramItem()
          ..classTypeName = _name
          ..day = int.parse(day)
          ..lessonNo = int.parse(lessonNo);

        _resultList.add(item);
      } else {
        var lesson = AppVar.appBloc.lessonService!.dataListItem(lessonKey);
        if (lesson != null) {
          final day = (time as String).split('-').first;
          final lessonNo = time.toString().split('-').last;
          final item = ProgramItem()
            ..lesson = lesson
            ..day = int.parse(day)
            ..lessonNo = int.parse(lessonNo);

          _resultList.add(item);
        }
      }
    });

    log(_resultList.length);

    return _resultList;
  }

  static List<ProgramItem> getStudentAllLessonFromTimeTable(List<Class?> sinifList) {
    List<ProgramItem> _data = [];
    AppVar.appBloc.tableProgramService!.takeData(1).forEach((key, value) {
      if (value['classProgram'] != null) {
        sinifList.forEach((sinif) {
          final program = Map<String, String>.from(value['classProgram'][sinif!.key] ?? {});
          program.forEach((time, lessonKey) {
            var lesson = AppVar.appBloc.lessonService!.dataListItem(lessonKey);
            if (lesson != null) {
              final day = (time).split('-').first;
              final lessonNo = (time).toString().split('-').last;
              final item = ProgramItem()
                ..lesson = lesson
                ..day = int.parse(day)
                ..lessonNo = int.parse(lessonNo);

              _data.add(item);
            }
          });
        });
      }
    });
    return _data;
  }

  static List<TimeTableP2PEvent> getTeacherEventListFromProgram(String? teacherKey) {
    var _programData = ProgramHelper.getLastSturdyProgram();
    List<TimeTableP2PEvent> eventList = [];
    final teacherProgram = getTeacherAllLessonFromTimeTable(teacherKey, _programData);
    teacherProgram.forEach((item) {
      final time = AppVar.appBloc.schoolTimesService!.dataList.last.getDayLessonNoTimes(item.day.toString(), item.lessonNo! - 1);
      final startTime = time.first!;
      final endTime = time.last!;

      eventList.add(TimeTableP2PEvent(
        id: 'lesson${10.makeKey}',
        color: Colors.red,
        title: item.lesson!.name,
        day: item.day! - 1,
        startMinute: startTime,
        endMinute: endTime,
        eventType: EventType.timetableTeacher,
      ));
    });
    return eventList;
  }

  static List<TimeTableP2PEvent> getStudentEventListFromProgram(String studentKey) {
    final student = AppVar.appBloc.studentService!.dataListItem(studentKey)!;

    List<TimeTableP2PEvent> eventList = [];
    final studentProgram = getStudentAllLessonFromTimeTable(student.classKeyList.map((e) => AppVar.appBloc.classService!.dataListItem(e)).toList()..removeWhere((element) => element == null));

    studentProgram.forEach((item) {
      final time = AppVar.appBloc.schoolTimesService!.dataList.last.getDayLessonNoTimes(item.day.toString(), item.lessonNo! - 1);
      final startTime = time.first!;
      final endTime = time.last!;

      eventList.add(TimeTableP2PEvent(
        id: 'lesson${10.makeKey}',
        color: Colors.orangeAccent,
        title: item.lesson!.name,
        day: item.day! - 1,
        startMinute: startTime,
        endMinute: endTime,
        eventType: EventType.timetableStudent,
      ));
    });
    return eventList;
  }

  /// sinif programlari listesinde birlestirilmis siniflarin programi gozukmuyordu.
  /// burada ogrecilerin siniflarina bakilarak o ogrencinin birlestirilmis siniflarinada bakilarak normal siniflar ile birlstirilmis siniflar arasinda bag kurulur
  /// bu  bagdan faydalanilarak sinif programinda birlestirilmis sinifin derside gosterilir.
  /// Donus tipi Key sinif key value birlestiirlmis sinif key listesi
  static Map<String?, Set<String?>>? _classTypeAndClassAnalyseData;
  static Map<String?, Set<String?>>? getClassTypeAndClassAnalyseData() {
    //if (_classTypeAndClassAnalyseData != null) return _classTypeAndClassAnalyseData;
    _classTypeAndClassAnalyseData = {};
    AppVar.appBloc.studentService!.dataList.forEach((student) {
      final _sinif = student.class0;
      if (_sinif.safeLength > 0) {
        final Set<String?> _existingData = _classTypeAndClassAnalyseData![_sinif] ?? {};
        _existingData.addAll(student.classKeyList..remove(_sinif));
        _classTypeAndClassAnalyseData![_sinif] = _existingData;
      }
    });
    return _classTypeAndClassAnalyseData;
  }

// [showEmptyStateTeacher] fonksiyonu icin gun ders saati -> ogretmen listesi seklinde programi verir
// doun tipi {1-2:[teacher1,teacher2]}
  static Map<String, Set<String?>> _getDayTeacherBasedProgram() {
    Map<String, Set<String?>> _data = {};
    AppVar.appBloc.tableProgramService!.takeData(1).forEach((key, value) {
      final Map allClassProgramData = value['classProgram'] ?? {};
      allClassProgramData.forEach((classKey, value) {
        final Map classProgramData = value;
        classProgramData.forEach((time, lessonKey) {
          var lesson = AppVar.appBloc.lessonService!.dataListItem(lessonKey);
          if (lesson != null) {
            _data[time] ??= {};
            _data[time]!.add(lesson.teacher);
          }
        });
      });
    });
    return _data;
  }

  /// ders programina gore bosta olan ogretmeni bulmaya yarar
  static void showEmptyStateTeacher() {
    final TimesModel _times = AppVar.appBloc.schoolTimesService!.dataList.last;
    // log(_times.mapForSave());
    final _day = DateTime.now().weekday;
    final _nowMinuteTime = DateTime.now().hour * 60 + DateTime.now().minute;
    final _programData = _getDayTeacherBasedProgram();

    // times validate yapmak lazim olabilir. ama bazen durduk yerde [0, 0] diye ders saati ekliyor
    //  if (_times.validate()) {
    int? _currentLesson;
    for (var i = 0; i < _times.getDayLessonCount(_day.toString())!; i++) {
      final _lessonTimes = _times.getDayLessonNoTimes(_day.toString(), i);
      if (_lessonTimes.first! <= _nowMinuteTime && _lessonTimes.last! >= _nowMinuteTime) {
        _currentLesson = i + 1;
      }
    }
    List<Teacher> _emptyTacherList = AppVar.appBloc.teacherService!.dataList.where((teacher) {
      if (_programData['$_day-$_currentLesson'] == null) return true;

      return !_programData['$_day-$_currentLesson']!.contains(teacher.key);
    }).toList();

    //! Istersen kalan ogretmenlerin birebiri var mi kontrolde ettirebilirsen burda filtrele

    OverPage.openModelBottomWithListView(
      itemBuilder: (context, index) {
        final _teacher = _emptyTacherList[index];
        return Container(
          color: Fav.design.primaryText.withAlpha(index.isEven ? 10 : 0),
          child: Text(_teacher.name!, style: TextStyle(color: Fav.design.primaryText, fontSize: 14)).px16.py8,
        );
      },
      itemCount: _emptyTacherList.length,
      extraWidget: (_emptyTacherList.length.toString() + ' ' + 'teacher'.translate).text.make(),
      title: 'emptystateteacherlist'.translate,
    );
    // }
  }
}
