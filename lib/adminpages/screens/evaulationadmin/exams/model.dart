import 'package:mcg_extension/mcg_extension.dart';

import '../answerkeyspage/model.dart';
import '../examtypes/model.dart';
import '../helper.dart';
import '../opticformtypes/model.dart';
import 'bookletdefine/model.dart';

class Exam {
  bool? aktif;
  dynamic lastUpdate;
  String? key;
  String? name;
  String? explanation;
  int? date;
  Map? examTypeData;
  String? examTypeKey;
  //seison no -> opticformdata
  Map<String, Map>? opticFormData;
  //seison no -> OnlineFormSettingsModel
  Map<String, BookLetModel?>? bookLetsData;
  Map<String, String>? opticFormKeyMap;
  AnswerKeyModel? answerEarningData;
  List<String>? kurumIdList;

  ///KurumId
  ///   => SesionNo : ExamFils
  Map<String, Map<String, ExamFile?>> seisonDatFiles = {};
  List<ExamFile> examBookLetFiles = [];
  //0 opticform 1 onlineform 2 opticAndOnline
  int? formTypeValue;
  String? resultsUrl;
  Map<String?, bool>? resultSendedToStudent;
  EvaulationUserType? userType;
  String? savedBy;

  Map existinAnnouncementData = {};

  Exam();

  Exam.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    lastUpdate = snapshot['lastUpdate'];
    name = snapshot['name'];
    explanation = snapshot['explanation'];
    date = snapshot['date'];
    resultSendedToStudent = Map<String?, bool>.from(snapshot['resultSendedToStudent'] ?? {});
    examTypeData = snapshot['examTypeData'];
    examTypeKey = snapshot['examTypeKey'];
    opticFormData = snapshot['opticFormData'] == null ? null : Map<String, Map>.from(snapshot['opticFormData']);
    opticFormKeyMap = snapshot['opticFormKeyMap'] == null ? null : Map<String, String>.from(snapshot['opticFormKeyMap']);
    answerEarningData = snapshot['answerEarningData'] == null ? null : AnswerKeyModel.fromJson(snapshot['answerEarningData']);

    seisonDatFiles = ((snapshot['seisonDatFiles'] ?? {}) as Map).map((kurumId, value) => MapEntry(kurumId, (value as Map).map((seisonNo, examfile) => MapEntry(seisonNo, ExamFile.fromJson(examfile)))));
    examBookLetFiles = ((snapshot['examBookLetFiles'] ?? []) as List).map((e) => ExamFile.fromJson(e)).toList();
    formTypeValue = snapshot['formType'] ?? 0;
    resultsUrl = snapshot['resultsUrl'];
    kurumIdList = snapshot['kurumIdList'] == null ? null : List<String>.from(snapshot['kurumIdList']);
    userType = EvaulationUserType.values.singleWhereOrNull((element) => element.toString() == snapshot['userType']);
    savedBy = snapshot['savedBy'];
    existinAnnouncementData = snapshot['eAD'] ?? {};
    bookLetsData = snapshot['oFD'] == null ? null : (snapshot['oFD'] as Map).map((seisonNo, value) => MapEntry(seisonNo, BookLetModel.fromJson(value)));
  }

  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif,
      "lastUpdate": lastUpdate,
      "name": name,
      "explanation": explanation,
      "date": date,
      "resultSendedToStudent": resultSendedToStudent,
      "examTypeData": examTypeData,
      "examTypeKey": examTypeKey,
      "opticFormData": opticFormData,
      "opticFormKeyMap": opticFormKeyMap,
      "answerEarningData": answerEarningData?.mapForSave(),
      "seisonDatFiles": (seisonDatFiles).map((kurumId, value) => MapEntry(kurumId, value.map((seisonNo, examFile) => MapEntry(seisonNo, examFile?.mapForSave())))),
      "examBookLetFiles": (examBookLetFiles).map((e) => e.mapForSave()).toList(),
      "formType": formTypeValue,
      "resultsUrl": resultsUrl,
      "kurumIdList": kurumIdList,
      "savedBy": savedBy,
      "userType": userType.toString(),
      "eAD": existinAnnouncementData,
      "oFD": bookLetsData?.map((seisonNo, value) => MapEntry(seisonNo, value!.mapForSave())),
    };
  }

  Map<String, dynamic> mapForStudent() {
    return {
      "name": name,
      "explanation": explanation,
      "date": date,
    };
  }

  ExamType? get examType => examTypeData == null ? null : ExamType.fromJson(examTypeData!, examTypeKey);
  OpticFormModel? opticForm(int seisonNo) => opticFormData == null || opticFormData!['seison$seisonNo'] == null ? null : OpticFormModel.fromJson(opticFormData!['seison$seisonNo']!);
  BookLetModel? onlineForm(int seisonNo) => bookLetsData == null || bookLetsData!['seison$seisonNo'] == null ? null : bookLetsData!['seison$seisonNo'];

  FormTypes get formType => FormTypes.values[formTypeValue!];

  bool get notGood => savedBy.safeLength < 1 || kurumIdList == null || kurumIdList!.isEmpty || userType == null;

  String get getSearchText => ((name ?? '') + (explanation ?? '') + (kurumIdList?.join('') ?? '')).toSearchCase();
}

enum FormTypes { optic, online, opticAndOnline }

extension FormTypesExtension on FormTypes {
  bool get isOpticFormActive => this == FormTypes.optic || this == FormTypes.opticAndOnline;
  bool get isOnlineFormActive => this == FormTypes.online || this == FormTypes.opticAndOnline;
}

class ExamFile {
  String? url;
  String? name;
  int? seisonNo;
  bool? isPublish;
  ExamFileType? examFileType;

  ExamFile({this.url, this.name, this.seisonNo, this.isPublish, this.examFileType});

  ExamFile.fromJson(Map snapshot) {
    name = snapshot['name'];
    seisonNo = snapshot['seisonNo'];
    url = snapshot['url'];
    isPublish = snapshot['isPublish'] ?? false;
    examFileType = snapshot['eFT'] == null ? null : ExamFileType.values.singleWhere((element) => element.toString() == snapshot['eFT']);
  }

  Map<String, dynamic> mapForSave() {
    return {
      "name": name,
      "seisonNo": seisonNo,
      "url": url,
      "isPublish": isPublish,
      "eFT": examFileType?.toString(),
    };
  }
}

enum ExamFileType {
  file,
  url,
  youtubeVideo,
}

class ResultModel {
  String? studentNameOnOpticForm;
  String? studentNoOnOpticForm;
  String? studentIdOnOpticForm;
  String? studentClassOnOpticForm;
  String? studentKey;
  String? rSName;
  String? rSNo;
  String? rSClass;

  String? studentSection;
  List<String?>? bookletTypes;

  Map<String?, TestResultModel>? testResults = {};
  Map<String?, ScorResultModel>? scoreResults = {};

  /// okunan son sezon noyu ceker eger birden fazla seizon lu sinav  varsa kontrol icin gerekir
  int lastSeisonNo = -1;

  ResultModel();

  ResultModel.fromJson(Map snapshot) {
    studentNameOnOpticForm = snapshot['sNaOF'];
    studentNoOnOpticForm = snapshot['sNoOF'];
    studentIdOnOpticForm = snapshot['sIdOF'];
    studentClassOnOpticForm = snapshot['sCOF'];
    studentKey = snapshot['sK'];
    rSName = snapshot['rSN'];
    rSNo = snapshot['rSNo'];
    rSClass = snapshot['rSC'];

    studentSection = snapshot['sS'];
    bookletTypes = snapshot['bT'] is List ? List<String>.from(snapshot['bT']) : [];

    testResults = snapshot['tR'] == null ? null : (snapshot['tR'] as Map).map((key, value) => MapEntry(key, TestResultModel.fromJson(value)));
    scoreResults = snapshot['sR'] == null ? null : (snapshot['sR'] as Map).map((key, value) => MapEntry(key, ScorResultModel.fromJson(value)));
  }

  Map<String, dynamic> mapForSave() {
    return {
      "snof": studentNameOnOpticForm,
      "sNoOF": studentNoOnOpticForm,
      "sIdOF": studentIdOnOpticForm,
      "sCOF": studentClassOnOpticForm,
      "sK": studentKey,
      "rSN": rSName,
      "rSNo": rSNo,
      "rSC": rSClass,
      "sS": studentSection,
      "bT": bookletTypes,
      "tR": testResults?.map((key, value) => MapEntry(key, value.mapForSave())),
      "sR": scoreResults?.map((key, value) => MapEntry(key, value.mapForSave())),
    };
  }

  int get totalTrue {
    int total = 0;
    testResults?.forEach((key, value) {
      total += value.d ?? 0;
    });
    return total;
  }

  int get totalFalse {
    int total = 0;
    testResults?.forEach((key, value) {
      total += value.y ?? 0;
    });
    return total;
  }

  int get totalBlank {
    int total = 0;
    testResults?.forEach((key, value) {
      total += value.b ?? 0;
    });
    return total;
  }

  double get totalNet {
    double total = 0;
    testResults?.forEach((key, value) {
      total += value.n ?? 0;
    });
    return total;
  }

  int get totalWTrue {
    int total = 0;
    testResults?.forEach((key, value) {
      total += value.wd ?? 0;
    });
    return total;
  }

  int get totalWFalse {
    int total = 0;
    testResults?.forEach((key, value) {
      total += value.wy ?? 0;
    });
    return total;
  }

  int get totalWBlank {
    int total = 0;
    testResults?.forEach((key, value) {
      total += value.wb ?? 0;
    });
    return total;
  }
}

class TestResultModel {
  int? d = 0;
  int? y = 0;
  int? b = 0;
  double? n = 0;
  int? wd = 0;
  int? wy = 0;
  int? wb = 0;
  double? generalAwerage = -1;
  double? schoolAwerage = -1;
  double? classAwerage = -1;
  String? studentAnswers;
  String? realAnswers;
  Map<String?, Map<String, int>>? earningResults;
  Map<String, Map<String, int>>? wEarningResults;

  TestResultModel({this.d, this.y, this.b, this.wb, this.wd, this.wy, this.n, this.classAwerage, this.generalAwerage, this.schoolAwerage, this.studentAnswers, this.realAnswers, this.earningResults, this.wEarningResults});

  TestResultModel.fromJson(Map snapshot) {
    d = snapshot['d'] ?? 0;
    y = snapshot['y'] ?? 0;
    b = snapshot['b'] ?? 0;
    n = ((snapshot['n'] ?? 0.0) as num).toDouble();
    wd = snapshot['wd'] ?? 0;
    wy = snapshot['wy'] ?? 0;
    wb = snapshot['wb'] ?? 0;
    generalAwerage = ((snapshot['gA'] ?? -1) as num).toDouble();
    schoolAwerage = ((snapshot['sA'] ?? -1) as num).toDouble();
    classAwerage = ((snapshot['cA'] ?? -1) as num).toDouble();
    studentAnswers = snapshot['sAN'] ?? '';
    realAnswers = snapshot['rAN'] ?? '';
    earningResults = snapshot['eR'] == null ? null : (snapshot['eR'] as Map).map((earning, value) => MapEntry(earning, Map<String, int>.from(value)));
    wEarningResults = snapshot['wER'] == null ? null : (snapshot['wER'] as Map).map((earning, value) => MapEntry(earning, Map<String, int>.from(value)));
  }

  Map<String, dynamic> mapForSave() {
    return {
      "d": d,
      "y": y,
      "b": b,
      "n": n,
      "wd": wd,
      "wy": wy,
      "wb": wb,
      "gA": generalAwerage,
      "sA": schoolAwerage,
      "cA": classAwerage,
      "sAN": studentAnswers,
      "rAN": realAnswers,
      "eR": earningResults,
      "wER": wEarningResults,
    };
  }
}

class ScorResultModel {
  String? scoreKey;
  double score = 0;
  String? groupKey;
  String? name;
  int? generalOrder;
  int? schoolOrder;
  int? classOrder;
  int? generalStudentCount;
  int? schoolStudentCount;
  int? classStudentCount;

  double? generalAwerage = -1;
  double? schoolAwerage = -1;
  double? classAwerage = -1;

  ScorResultModel({this.score = 0, this.scoreKey, this.groupKey, this.name, this.classOrder, this.generalOrder, this.schoolOrder, this.classAwerage, this.generalAwerage, this.schoolAwerage, this.generalStudentCount, this.classStudentCount, this.schoolStudentCount});

  ScorResultModel.fromJson(Map snapshot) {
    score = ((snapshot['s'] ?? 0) as num).toDouble();
    groupKey = snapshot['gK'];
    scoreKey = snapshot['sK'] ?? name.removeNonEnglishCharacter;
    name = snapshot['n'];
    generalOrder = snapshot['gO'];
    schoolOrder = snapshot['sO'];
    classOrder = snapshot['cO'];
    generalStudentCount = snapshot['gC'];
    schoolStudentCount = snapshot['sC'];
    classStudentCount = snapshot['cC'];
    generalAwerage = ((snapshot['gA'] ?? -1) as num).toDouble();
    schoolAwerage = ((snapshot['sA'] ?? -1) as num).toDouble();
    classAwerage = ((snapshot['cA'] ?? -1) as num).toDouble();
  }

  Map<String, dynamic> mapForSave() {
    return {
      "s": score,
      "gK": groupKey,
      "sK": scoreKey,
      "n": name,
      "gO": generalOrder,
      "sO": schoolOrder,
      "cO": classOrder,
      "gA": generalAwerage,
      "sA": schoolAwerage,
      "cA": classAwerage,
      "cC": classStudentCount,
      "sC": schoolStudentCount,
      "gC": generalStudentCount,
    };
  }
}
