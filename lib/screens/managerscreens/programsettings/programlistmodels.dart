import 'package:flutter/foundation.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class TimesModel extends DatabaseItem {
  dynamic timeStamp;
  int? programTypes = 0;
  Set<String>? activeDays;
  int? schoolStartTime = 480;
  int? schoolEndTime = 1080;

  int? _weekdaysLessonCount;
  int? _weekendLessonCount;
  List<List<int?>>? _weekdaysLessonTimes;
  List<List<int?>>? _weekendsLessonTimes;

  ///todo bunlari silinecek
  // int get weekdaysLessonCount => _weekdaysLessonCount;
  // int get weekendLessonCount => _weekendLessonCount;
  // List<List<int>> get weekdaysLessonTimes => _weekdaysLessonTimes;
  // List<List<int>> get weekendsLessonTimes => _weekendsLessonTimes;

  ///
  int? getWeekDaysLessonCountForSetup() {
    _weekdaysLessonCount ??= 1;
    return _weekdaysLessonCount;
  }

  int? get getWeekDaysLessonCountForUse {
    if (programTypes == 0) {
      _weekdaysLessonCount ??= 1;
      return _weekdaysLessonCount;
    } else {
      return Iterable.generate(5, (i) => getDayLessonCount((i + 1).toString())).fold<int?>(0, (p, e) => e! > p! ? e : p);
    }
  }

  int? get getWeekEndLessonCountForUse {
    if (programTypes == 0) {
      _weekendLessonCount ??= 1;
      return _weekendLessonCount;
    } else {
      return Iterable.generate(2, (i) => getDayLessonCount((i + 6).toString())).fold<int?>(0, (p, e) => e! > p! ? e : p);
    }
  }

  void setWeekDaysLessonCount(int value) {
    _weekdaysLessonCount = value;
    while (_weekdaysLessonTimes!.length != value) {
      if (_weekdaysLessonTimes!.length < value) {
        _weekdaysLessonTimes!.add([0, 0]);
      } else {
        _weekdaysLessonTimes!.removeLast();
      }
    }
  }

  void setWeekDaysLessonNoTimes(int lessonNo, int index, int? value) {
    _weekdaysLessonTimes ??= [];
    while (_weekdaysLessonTimes!.length < lessonNo) {
      _weekdaysLessonTimes!.add([0, 0]);
    }
    _weekdaysLessonTimes![lessonNo][index] = value;
  }

  void setWeekEndLessonNoTimes(int lessonNo, int index, int? value) {
    _weekendsLessonTimes ??= [];
    while (_weekendsLessonTimes!.length < lessonNo) {
      _weekendsLessonTimes!.add([0, 0]);
    }
    _weekendsLessonTimes![lessonNo][index] = value;
  }

  int? getWeekEndLessonCountForSetup() {
    _weekendLessonCount ??= 1;
    return _weekendLessonCount;
  }

  void setWeekEndLessonCount(int value) {
    _weekendLessonCount = value;
    while (_weekendsLessonTimes!.length != value) {
      if (_weekendsLessonTimes!.length < value) {
        _weekendsLessonTimes!.add([0, 0]);
      } else {
        _weekendsLessonTimes!.removeLast();
      }
    }
  }

  ///{'d1':8,'d2':9}
  Map<String, int> _dayLessonCounts = {};
  int? getDayLessonCount(String day) {
    if (programTypes == 0) {
      if (int.parse(day) < 6) return _weekdaysLessonCount;
      return _weekendLessonCount;
    } else {
      // _dayLessonCounts ??= {};
      _dayLessonCounts['d$day'] ??= 1;
      return _dayLessonCounts['d$day'];
    }
  }

  void setDayLessonCount(String day, int value) {
    // _dayLessonCounts ??= {};
    _dayLessonCounts['d$day'] = value;

    _dayLessonTimes['d$day'] ??= [];
    while (_dayLessonTimes['d$day']!.length != value) {
      if (_dayLessonTimes['d$day']!.length < value) {
        _dayLessonTimes['d$day']!.add([0, 0]);
      } else {
        _dayLessonTimes['d$day']!.removeLast();
      }
    }
  }

  // {'d1':[[0,0],[0.0]],'d2':[]}
  Map<String, List<List<int?>>> _dayLessonTimes = {};

  ///  return tpe [0,0];
  List<int?> getDayLessonNoTimes(String _day, int lessonNo) {
    final day = int.parse(_day);
    if (programTypes == 0) {
      if (day < 6) {
        _weekdaysLessonTimes ??= [];
        while (_weekdaysLessonTimes!.length < lessonNo + 1) {
          _weekdaysLessonTimes!.add([0, 0]);
        }
        return _weekdaysLessonTimes![lessonNo];
      } else {
        _weekendsLessonTimes ??= [];
        while (_weekendsLessonTimes!.length < lessonNo + 1) {
          _weekendsLessonTimes!.add([0, 0]);
        }
        return _weekendsLessonTimes![lessonNo];
      }
    } else {
      // _dayLessonTimes ??= {};
      _dayLessonTimes['d$day'] ??= [];
      while (_dayLessonTimes['d$day']!.length < lessonNo + 1) {
        _dayLessonTimes['d$day']!.add([0, 0]);
      }

      return _dayLessonTimes['d$day']![lessonNo];
    }
  }

  void setDayLessonNoTimes(String day, int lessonNo, int index, int? value) {
    // _dayLessonTimes ??= {};
    _dayLessonTimes['d$day'] ??= [];
    while (_dayLessonTimes['d$day']!.length < lessonNo) {
      _dayLessonTimes['d$day']!.add([0, 0]);
    }
    _dayLessonTimes['d$day']![lessonNo][index] = value;
  }

  TimesModel() {
    programTypes = 0;

    activeDays = {'1', '2', '3', '4', '5'};
    _weekdaysLessonCount = 5;
    _weekendLessonCount = 5;
    _weekdaysLessonTimes = [
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0]
    ];
    _weekendsLessonTimes = [
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0],
      [0, 0]
    ];
  }

  TimesModel.fromJson(Map value) {
    value.forEach((key, value) {
      if (key == "weekdaysLessonCount") {
        _weekdaysLessonCount = value;
      } else if (key == "weekendLessonCount") {
        _weekendLessonCount = value;
      } else if (key == "dayLessonCounts") {
        _dayLessonCounts = Map<String, int>.from(value ?? {});
      } else if (key == "activeDays") {
        activeDays = Set<String>.from(value);
      } else if (key == "weekdaysLessonTimes") {
        _weekdaysLessonTimes = [];
        (value as List).forEach((item) {
          _weekdaysLessonTimes!.add(List<int?>.from(item));
        });
      } else if (key == "weekendsLessonTimes") {
        _weekendsLessonTimes = [];
        (value as List).forEach((item) {
          _weekendsLessonTimes!.add(List<int?>.from(item));
        });
      } else if (key == "dayLessonTimes") {
        _dayLessonTimes = Map<String, List<List<int?>>>.from((value as Map).map((day, times) => MapEntry(day, List<List<int>>.from((times as List).map((e) => List<int>.from(e))).toList())));
      } else if (key == "timeStamp") {
        timeStamp = value;
      } else if (key == "programTypes") {
        programTypes = value;
      } else if (key == "schoolStartTime") {
        schoolStartTime = value;
      } else if (key == "schoolEndTime") {
        schoolEndTime = value;
      }
    });
  }

  Map<String, dynamic> mapForSave() {
    if (programTypes == 1) {
      _weekdaysLessonCount = _dayLessonCounts.entries.fold<int>(0, (p, e) => p > e.value ? p : e.value);
      _weekendLessonCount = _weekdaysLessonCount;
      _weekdaysLessonTimes = _dayLessonTimes.entries.fold<List<List<int?>>>([], (p, e) => p.length > e.value.length ? p : e.value);
      _weekendsLessonTimes = _weekdaysLessonTimes;
    }

    return {
      "weekdaysLessonCount": _weekdaysLessonCount,
      "weekendLessonCount": _weekendLessonCount,
      "activeDays": List.from(activeDays!),
      "weekdaysLessonTimes": _weekdaysLessonTimes,
      "weekendsLessonTimes": _weekendsLessonTimes,
      "dayLessonCounts": _dayLessonCounts,
      "dayLessonTimes": _dayLessonTimes,
      "programTypes": programTypes,
      "timeStamp": timeStamp,
      "schoolEndTime": schoolEndTime,
      "schoolStartTime": schoolStartTime,
    };
  }

  ///Kaydedilebilecek durumdami  kontrol eder
  bool validate() {
    String? error;
    if (programTypes == 0) {
      if (_weekdaysLessonTimes!.any((item) => item.first! >= item.last!)) {
        error = 'incompatiblehours1'.translate;
      }

      if (_weekdaysLessonTimes!.any((item) => item.first! < schoolStartTime! || item.last! > schoolEndTime!)) {
        error = 'incompatiblehours3'.translate;
      }

      // log(_weekendsLessonTimes);
      // log(mapForSave());
      if (_weekendsLessonTimes!.any((item) => item.first! >= item.last!)) {
        error = 'incompatiblehours1'.translate;
      }

      if (_weekendsLessonTimes!.any((item) => item.first! < schoolStartTime! || item.last! > schoolEndTime!)) {
        error = 'incompatiblehours3'.translate;
      }

      for (var i = 1; i < _weekdaysLessonTimes!.length; i++) {
        if (_weekdaysLessonTimes![i].first! <= _weekdaysLessonTimes![i - 1].last!) {
          error = 'incompatiblehours2'.translate;
        }
      }
      for (var i = 1; i < _weekendsLessonTimes!.length; i++) {
        if (_weekendsLessonTimes![i].first! <= _weekendsLessonTimes![i - 1].last!) {
          error = 'incompatiblehours2'.translate;
        }
      }
    } else {
      _dayLessonTimes.forEach((day, times) {
        if (times.any((item) => item.first! >= item.last!)) {
          log('gg');
          error = 'incompatiblehours1'.translate;
        }
        if (times.any((item) => item.first! < schoolStartTime! || item.last! > schoolEndTime!)) {
          log('hh');
          error = 'incompatiblehours3'.translate;
        }
        for (var i = 1; i < times.length; i++) {
          if (times[i].first! <= times[i - 1].last!) {
            log('jj');
            error = 'incompatiblehours2'.translate;
          }
        }
      });
    }
    if (error != null) error.showAlert();
    return error == null;
  }

  int get maxLessonCountADay {
    return Iterable.generate(8).fold<int>(0, (p, e) {
      final _lessonCount = getDayLessonCount('${e + 1}')!;
      return _lessonCount > p ? _lessonCount : p;
    });
  }

  @override
  bool active() => true;
}

class TimeTableSettings {
  bool boxColorIsTeacher = false; // true teacher false lesson color
  List<String>? visibleDays = [];
  List<String?>? visibleClass = [];

  double cellWidth = kIsWeb ? 70 : 50;
  double cellHeight = kIsWeb ? 42 : 30;
  double classNameWidth = kIsWeb ? 70 : 50;
  double lessonNumberHeight = kIsWeb ? 21 : 15;

  int? size = isWeb ? 1 : 2;

  TimeTableSettings() {
    size = Fav.preferences.getInt('TimeTableCellSize', isWeb ? 1 : 2);
    changeCellSize(size!);
  }

  void changeCellSize(int size) {
    this.size = size;
    Fav.preferences.setInt('TimeTableCellSize', size);
    if (size == 1) {
      cellWidth = kIsWeb ? 56 : 40;
      cellHeight = kIsWeb ? 35 : 24;
      classNameWidth = kIsWeb ? 56 : 40;
      lessonNumberHeight = kIsWeb ? 17 : 12;
    } else if (size == 2) {
      cellWidth = kIsWeb ? 70 : 50;
      cellHeight = kIsWeb ? 42 : 30;
      classNameWidth = kIsWeb ? 70 : 50;
      lessonNumberHeight = kIsWeb ? 21 : 15;
    } else if (size == 3) {
      cellWidth = kIsWeb ? 77 : 55;
      cellHeight = kIsWeb ? 46 : 33;
      classNameWidth = kIsWeb ? 77 : 55;
      lessonNumberHeight = kIsWeb ? 23 : 17;
    }
  }
}
