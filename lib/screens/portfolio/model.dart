import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../adminpages/screens/evaulationadmin/exams/model.dart';
import '../../adminpages/screens/evaulationadmin/examtypes/model.dart';
import '../p2p/freestyle/model.dart';
import '../rollcall/model.dart';
import '../timetable/homework/homework_check_helper.dart';

class Portfolio extends DatabaseItem {
  dynamic lastUpdate;
  String? key;
  bool? aktif;
  PortfolioType? portfolioType;
  Map? _data;
  Portfolio(this._data, {this.lastUpdate, this.portfolioType, this.aktif, this.key});

  T? data<T>() {
    if (portfolioType == PortfolioType.examreport) return PortfolioExamReport(_data) as T;
    if (portfolioType == PortfolioType.p2p) return P2PModel.fromJson(_data!, key) as T;
    if (portfolioType == PortfolioType.rollcall) return RollCallStudentModel.fromJson(_data!, key) as T;
    if (portfolioType == PortfolioType.homeworkCheck) return HomeWorkCheck.fromJson(_data!, key) as T;
    if (portfolioType == PortfolioType.examCheck) return HomeWorkCheck.fromJson(_data!, key) as T;
    return null;
  }

  Portfolio.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['lastUpdate'];
    _data = snapshot['data'];
    aktif = snapshot['aktif'] ?? true;
    portfolioType = PortfolioType.values.firstWhereOrNull((element) => snapshot['portfolioType'] == element.toString());
  }

  Map<String, dynamic> mapForSave() {
    return {
      "lastUpdate": lastUpdate,
      "data": _data,
      "key": key,
      "aktif": aktif,
      "portfolioType": portfolioType.toString(),
    };
  }

  @override
  bool active() => aktif != false;
}

enum PortfolioType {
  examreport,
  p2p,
  rollcall,
  homeworkCheck,
  examCheck,
}

class PortfolioExamReport {
  final Map? _data;
  PortfolioExamReport(this._data);
  ExamType get examType => ExamType.fromJson(_data!['examType'], null);
  ResultModel get result => ResultModel.fromJson(_data!['examData']);
  Exam get exam => Exam.fromJson(_data!['exam'], null);
  Map<String, String>? get earningResultKeyMap => _data!['earningResultKeyMap'] == null ? null : Map<String, String>.from(_data!['earningResultKeyMap']);
}
