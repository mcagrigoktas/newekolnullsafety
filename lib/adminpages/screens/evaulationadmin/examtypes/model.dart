import 'package:mcg_extension/mcg_extension.dart';

import '../helper.dart';

class ExamType {
  bool? aktif;
  bool? isPublished;
  String? key;
  dynamic lastUpdate;
  String? name;
  String? explanation;
  String? countryCode;
  String? lessonLayoutCode;
  String? scoreLayoutCode;
  int? numberOfSeison;
  List<ExamTypeLesson>? lessons;
  List<Scoring>? scoring;
  List<String>? studentGroupType;
  EvaulationUserType? userType;
  String? savedBy;

  ExamType({this.lastUpdate});

  ExamType.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    isPublished = snapshot['iP'] ?? false;
    lastUpdate = snapshot['lastUpdate'];
    name = snapshot['n'];
    explanation = snapshot['e'];
    countryCode = snapshot['c'];
    lessonLayoutCode = snapshot['lL'] ?? '';
    scoreLayoutCode = snapshot['sL'] ?? '';

    numberOfSeison = snapshot['sn'] ?? 1;

    // var a = (snapshot['lessons'] ?? []).map<ExamTypeLesson>((item) => ExamTypeLesson.fromJson(item)).toList();

    lessons = ((snapshot['lessons'] ?? []) as List).map((item) => ExamTypeLesson.fromJson(item)).toList();
    scoring = ((snapshot['scoring'] ?? []) as List).map((item) => Scoring.fromJson(item)).toList();

    userType = EvaulationUserType.values.singleWhereOrNull((element) => element.toString() == snapshot['userType']) ?? EvaulationUserType.admin;
    savedBy = snapshot['savedBy'] ?? EvaulationUserType.admin.toString();
  }

  Map<String, dynamic> mapForSave() {
    return {
      "k": key,
      "aktif": aktif ?? true,
      "iP": isPublished ?? false,
      "lastUpdate": lastUpdate,
      "n": name,
      "e": explanation,
      "c": countryCode,
      "lL": lessonLayoutCode,
      "sL": scoreLayoutCode,
      "sn": numberOfSeison,
      "lessons": lessons?.map((e) => e.mapForSave()).toList(),
      "scoring": scoring?.map((e) => e.mapForSave()).toList(),
      "savedBy": savedBy,
      "userType": (userType ?? EvaulationUserType.admin).toString(),
    };
  }

  Map<String, dynamic> mapForStudent() {
    return {
      "k": key,
      "n": name,
      "e": explanation,
      "lL": lessonLayoutCode,
      "sL": scoreLayoutCode,
      "sn": numberOfSeison,
      "lessons": lessons?.map((e) => e.mapForStudent()).toList(),
      "scoring": scoring?.map((e) => e.mapForStudent()).toList(),
    };
  }
}

class ExamTypeLesson {
  String? name;
  String? key;
  String? earninglist;
  String? formuleKey;
  int? questionCount;

  ///acik ucllu soru
  int? wQuestionCount;
  String? wFormuleKey;
  int? seisonNo;
  String? groupKey;
  int? numberOfOptions;
  int? rightWrongRate;

  ExamTypeLesson.create()
      : name = '',
        earninglist = '',
        formuleKey = '',
        questionCount = 15,
        wQuestionCount = 0,
        wFormuleKey = '',
        seisonNo = 1,
        numberOfOptions = 5,
        rightWrongRate = 4,
        key = 5.makeKey,
        groupKey = '';

  ExamTypeLesson.fromJson(Map snapshot) {
    name = snapshot['n'];
    key = snapshot['key'];
    earninglist = snapshot['eL'];
    formuleKey = snapshot['f'];
    wFormuleKey = snapshot['wF'];
    questionCount = snapshot['qC'] ?? 15;
    wQuestionCount = snapshot['wQC'] ?? 0;
    seisonNo = snapshot['sNo'];
    numberOfOptions = snapshot['nOfO'];
    rightWrongRate = snapshot['rWR'];
    groupKey = snapshot['gK'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      "n": name,
      "key": key,
      "eL": earninglist,
      "f": formuleKey,
      "wF": wFormuleKey,
      "qC": questionCount,
      "wQC": wQuestionCount,
      "sNo": seisonNo,
      "nOfO": numberOfOptions,
      "rWR": rightWrongRate,
      "gK": groupKey,
    };
  }

  Map<String, dynamic> mapForStudent() {
    return {
      "n": name,
      "key": key,
      "f": formuleKey,
      "qC": questionCount,
      "wQC": wQuestionCount,
      "wF": wFormuleKey,
      "sNo": seisonNo,
      "gK": groupKey,
      "nOfO": numberOfOptions,
    };
  }
}

class Scoring {
  String? name;
  double? maxValue;
  double? minValue;
  String? formule;
  String? groupKey;
  String? key;
  Scoring();

  Scoring.create()
      : formule = '',
        groupKey = '',
        key = 4.makeKey,
        name = '';
  Scoring.fromJson(Map snapshot) {
    name = snapshot['n'];
    formule = snapshot['f'];
    groupKey = snapshot['gK'];
    maxValue = ((snapshot['maxV'] ?? 500) as num).toDouble();
    minValue = ((snapshot['minV'] ?? -100) as num).toDouble();
    key = snapshot['key'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      "n": name,
      "f": formule,
      "gK": groupKey,
      "minV": minValue,
      "maxV": maxValue,
      "key": key,
    };
  }

  Map<String, dynamic> mapForStudent() {
    return {
      "n": name,
      "gK": groupKey,
      "minV": minValue,
      "maxV": maxValue,
      "key": key,
    };
  }
}
