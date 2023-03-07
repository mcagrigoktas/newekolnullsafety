import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class P2PModel {
  bool? aktif;
  String? key;

  dynamic lastUpdate;

  int? week;
  int? day;
  int? startTime;
  int? duration;
  String? channel;

  List<String?>? studentList;
  String? teacherKey;
  String? studentRequestKey;
  String? note;
  bool? rollCall;
  String? studentRequestLessonKey;

  P2PModel();

  P2PModel.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    lastUpdate = snapshot['lastUpdate'];
    week = snapshot['w'];
    day = snapshot['d'];
    startTime = snapshot['sT'];
    duration = snapshot['dur'];
    channel = snapshot['c'];
    studentList = snapshot['sL'] == null ? null : List<String>.from(snapshot['sL']);
    teacherKey = snapshot['t'];
    studentRequestKey = snapshot['sR'];
    note = snapshot['n'];
    rollCall = snapshot['r'];
    studentRequestLessonKey = snapshot['sRl'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      'aktif': aktif,
      'lastUpdate': lastUpdate,
      'w': week,
      'd': day,
      'sT': startTime,
      'dur': duration,
      'c': channel,
      'sL': studentList,
      't': teacherKey,
      'sR': studentRequestKey,
      'sRl': studentRequestLessonKey,
      'n': note,
    };
  }

  Map<String, dynamic> mapForStudentSave() {
    return {
      'lastUpdate': lastUpdate,
      'w': week,
      'd': day,
      'sT': startTime,
      'dur': duration,
      'c': channel,
      't': teacherKey,
      'sRl': studentRequestLessonKey,
    };
  }

  // int get oldstartTimeMilliSecond {
  //   var _time = DateTime.now();
  //   _time = _time.add(Duration(days: (week - _time.weekOfYear) * 7));
  //   int _timeMilliseconds = _time.millisecondsSinceEpoch;
  //   _timeMilliseconds = _timeMilliseconds - Duration(days: _time.weekday - 1).inMilliseconds - Duration(hours: _time.hour).inMilliseconds - Duration(minutes: _time.minute).inMilliseconds - Duration(seconds: _time.second).inMilliseconds;
  //   _timeMilliseconds = _timeMilliseconds + Duration(days: day).inMilliseconds + Duration(minutes: startTime).inMilliseconds;
  //   return _timeMilliseconds;
  // }

//? sadece yilin haftasi bilgisiyle birebirin hangi tarihte oldugunu bulmak zor is
//? Burada lastupdate time a yakin bir tarih oldugu varsayimiyla yakin tarihteki yilin haftalari kontrol ediliyor

  int get startTimeMilliSecond => P2PTimeCalculateHelper.calculateTimeStamp(week, day, startTime, lastUpdate);

  String get startTimeFullText => startTimeMilliSecond.dateFormat('d-MMM-yy HH:mm');
}

class P2PTimeCalculateHelper {
  P2PTimeCalculateHelper._();
//? Haftasi ve gunu bilinen bir birebirin lastupdate degiskeni kullanilarak yaklasik olarak hesaplar
  static int calculateTimeStamp(int? week, int? day, int? startTime, int? lastUpdate) {
    DateTime? _time;

    if (lastUpdate is int) {
      //? Lastupdate timein 3 hafta icerisinde mi
      for (var i = 0; i < 3; i++) {
        final _newTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate).add(Duration(days: i * 7));
        if (_newTime.weekOfYear == week) {
          _time = _newTime;
          break;
        }
      }

//? Lastupdate timein iki ay oncesi ve sonrasi arasinda haftasi bu haftaya esit var mi
//? yukarisi 0,1,2 oldugunda kuvvetli ihtimal ya hizlansin diye
      if (_time == null) {
        for (var i = -8; i < 8; i++) {
          final _newTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate).add(Duration(days: i * 7));
          if (_newTime.weekOfYear == week) {
            _time = _newTime;
            break;
          }
        }
      }
//? Hala bulamazsa
      if (_time == null) {
        for (var i = -16; i < 16; i++) {
          final _newTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate).add(Duration(days: i * 7));
          if (_newTime.weekOfYear == week) {
            _time = _newTime;
            break;
          }
        }
      }
    }

    if (_time == null) {
      var _time = DateTime.now();
      _time = _time.add(Duration(days: (week! - _time.weekOfYear) * 7));
    }

    int _timeMilliseconds = _time!.millisecondsSinceEpoch;
    _timeMilliseconds = _timeMilliseconds - Duration(days: _time.weekday - 1).inMilliseconds - Duration(hours: _time.hour).inMilliseconds - Duration(minutes: _time.minute).inMilliseconds - Duration(seconds: _time.second).inMilliseconds;
    _timeMilliseconds = _timeMilliseconds + Duration(days: day!).inMilliseconds + Duration(minutes: startTime!).inMilliseconds;
    return _timeMilliseconds;
  }
}

class TimeTableP2PEvent {
  final String id;
  final String? title;
  final String? subTitle;
  final Color? color;
  final int? day;
  final int startMinute;
  int endMinute;
  EventType? eventType;

  TimeTableP2PEvent({required this.id, this.title, this.subTitle, this.color, required this.startMinute, required this.endMinute, this.day, this.eventType}) {
    if (endMinute <= startMinute) endMinute = startMinute + 1;
  }

  /// Gunu 5 er dakikalik  bloklara  boldugumuzde hangi blokllari isgal ediyor
  List<int> get getBlokOfDay {
    return Iterable.generate(endMinute ~/ 5 - startMinute ~/ 5, (i) => i + startMinute ~/ 5).toList();
  }
}

enum EventType {
  empty,
  timetableTeacher,
  timetableStudent,
  p2p,
  studentP2POtherTeacher,
}

class P2PLogs {
  dynamic lastUpdate;
  String? key;
  bool? aktif;
  String? teacherKey;
  String? studentKey;
  int? week;
  int? day;
  int? startTime;
  bool? yoklama;

  P2PLogs({this.lastUpdate});

  P2PLogs.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['lastUpdate'];
    aktif = snapshot['a'];
    teacherKey = snapshot['t'];
    studentKey = snapshot['sK'];
    week = snapshot['w'];
    day = snapshot['d'];
    startTime = snapshot['sT'];
    yoklama = snapshot['r'];
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdate': lastUpdate,
      'a': aktif,
      't': teacherKey,
      'sK': studentKey,
      'w': week,
      'd': day,
      'sT': startTime,
      'r': yoklama,
    };
  }
}
