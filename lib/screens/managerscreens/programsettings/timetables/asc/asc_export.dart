import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:xml/xml.dart';

import '../../../../../appbloc/appvar.dart';
import '../../programlistmodels.dart';

class AscExportHelper {
  AscExportHelper._();
  static void export() {
    final _data = _createXmlString();
    log(_data);
    DownloadManager.saveStringAndDownloadToDisk(text: _data, fileName: 'ASCImportfile${DateTime.now().millisecondsSinceEpoch.dateFormat('d-MMM, HH:mm')}.xml');
  }

  static String _createXmlString() {
    final _builder = XmlBuilder();
    _builder.element('timetable', attributes: {
      'importtype': 'database',
      'options': 'idprefix:MyApp,lessonsincludeclasseswithoutstudents',
      'displayname': 'Ecoll Export',
    }, nest: () {
      // _addPeriods(_builder);
      _addDaysDef(_builder);
      _addTeachers(_builder);
      _addClasses(_builder);
      _addBranches(_builder);
      _addLessons(_builder);
    });
    final _document = _builder.buildDocument();
    return _document.toXmlString();
  }

  static void _addTeachers(XmlBuilder _builder) {
    _builder.element('teachers', attributes: {
      'options': '',
      'columns': 'id,name,short',
    }, nest: () {
      AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
        _builder.element('teacher', attributes: {
          'id': teacher.key,
          'name': teacher.name.changeTurkishCharacter!,
          'short': teacher.name.changeTurkishCharacter.onlyCapitalLetters!,
        });
      });
    });
  }

  static void _addClasses(XmlBuilder _builder) {
    _builder.element('classes', attributes: {
      'options': 'canadd,export:silent',
      'columns': 'id,name,short',
    }, nest: () {
      AppVar.appBloc.classService!.dataList.forEach((sinif) {
        _builder.element('class', attributes: {
          'id': sinif.key,
          'name': sinif.longName.changeTurkishCharacter!,
          'short': sinif.name.changeTurkishCharacter!,
        });
      });
    });
  }

  static void _addBranches(XmlBuilder _builder) {
    _builder.element('subjects', attributes: {
      'options': 'canadd,export:silent',
      'columns': 'id,name,short',
    }, nest: () {
      AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
        final _classKey = lesson.classKey!;
        final _class = AppVar.appBloc.classService!.dataListItem(_classKey);
        if (_class != null && _class.aktif != false) {
          _builder.element('subject', attributes: {
            'id': lesson.key,
            'name': lesson.longName.changeTurkishCharacter!,
            'short': lesson.name.changeTurkishCharacter!,
          });
        }
      });
    });
  }

  static void _addLessons(XmlBuilder _builder) {
    _builder.element('lessons', attributes: {
      'options': 'canadd,export:silent',
      'columns': 'id,subjectid,classids,groupids,teacherids,classroomids,periodspercard,periodsperweek,daysdefid,weeksdefid,termsdefid,seminargroup,capacity,partner_id',
    }, nest: () {
      AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
        final _classKey = lesson.classKey!;
        final _class = AppVar.appBloc.classService!.dataListItem(_classKey);
        if (_class != null && _class.aktif != false) {
          int? _cardSize;
          if (lesson.distribution.safeLength > 0) {
            _cardSize = int.tryParse(lesson.distribution!.substring(0, 1));
          }
          _builder.element('lesson', attributes: {
            'id': "L" + lesson.key,
            'classids': lesson.classKey!,
            'subjectid': lesson.key,
            'periodspercard': (_cardSize ?? ((lesson.count ?? 1) > 1 ? 2 : 1)).toString(),
            'periodsperweek': "${(lesson.count ?? 1)}.0",
            'teacherids': lesson.teacher!,
            'classroomids': '',
            'groupids': '',
            'capacity': '*',
            'seminargroup': '',
            'termsdefid': '',
            'weeksdefid': '',
            'daysdefid': '',
            'partner_id': '',
          });
        }
      });
    });
  }

  // ignore: unused_element
  static void _addPeriods(XmlBuilder _builder) {
    final TimesModel _timeService = AppVar.appBloc.schoolTimesService!.dataList.last;
    _builder.element('periods', attributes: {
      'options': 'canadd,export:silent',
      'columns': 'period,name,short,starttime,endtime',
    }, nest: () {
      for (int i = 1; i < 8; i++) {
        if (_timeService.activeDays!.contains(i.toString())) {
          _builder.element('period', attributes: {
            'name': '$i',
            'short': '$i',
            'period': '$i',
            'starttime': _formatTime(_timeService.getDayLessonNoTimes(i.toString(), 0).first),
            'endtime': _formatTime(_timeService.getDayLessonNoTimes(i.toString(), _timeService.getDayLessonCount(i.toString())! - 1).last),
          });
        }
      }
    });
  }

  static void _addDaysDef(XmlBuilder _builder) {
    final TimesModel _timeService = AppVar.appBloc.schoolTimesService!.dataList.last;
    _builder.element('daysdefs', attributes: {
      'options': 'canadd,export:silent',
      'columns': 'id,days,name,short',
    }, nest: () {
      _builder.element('daysdef', attributes: {
        'id': '10',
        'name': 'anyday'.translate.changeTurkishCharacter!,
        'short': 'X',
        'days': '1000000,0100000,0010000,0001000,0000100,0000010,0000001',
      });
      _builder.element('daysdef', attributes: {
        'id': '9',
        'name': 'everyday'.translate.changeTurkishCharacter!,
        'short': 'E',
        'days': '1111111',
      });
      for (int i = 1; i < 8; i++) {
        if (_timeService.activeDays!.contains(i.toString())) {
          _builder.element('daysdef', attributes: {
            'id': '$i',
            'name': McgFunctions.getDayNameFromDayOfWeek(i).changeTurkishCharacter!,
            'short': McgFunctions.getDayNameFromDayOfWeek(i, format: 'E').changeTurkishCharacter!,
            'days': i == 1
                ? '1000000'
                : i == 2
                    ? '0100000'
                    : i == 3
                        ? '0010000'
                        : i == 4
                            ? '0001000'
                            : i == 5
                                ? '0000100'
                                : i == 6
                                    ? '0000010'
                                    : '0000001',
          });
        }
      }
    });
  }

  static String _formatTime(int? time) {
    if (time == null) return '';
    return '${time ~/ 60}:${(time % 60).toString().padLeft(2, "0")}';
  }
}
