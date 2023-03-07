class AnswerKeyModel {
  int? bookLetCount;
  bool? earningsIsActive;
  AnswerKeyLocation? answerKeyLocation;

  String lessonanswers(String bookletkey, String lessonkey) => datas[bookletkey + lessonkey + 'answers'] ?? '';
  String lessonearnings(String bookletkey, String lessonkey) => datas[bookletkey + lessonkey + 'earnings'] ?? '';
  String lessonWQuestionAnswer(String bookletkey, String lessonkey, int questionNo) => datas[bookletkey + lessonkey + '-w$questionNo' + 'answers'] ?? '';
  String lessonWQuestionEarning(String bookletkey, String lessonkey, int questionNo) => datas[bookletkey + lessonkey + '-w$questionNo' + 'earnings'] ?? '';

  ///key: bookletkey + lessonkey + answers OR bookletkey + lessonkey +  earnings OR booklletkey + name
  ///value:
  Map<String, dynamic> datas = {};
  AnswerKeyModel({
    this.bookLetCount,
    this.earningsIsActive,
    this.answerKeyLocation,
  });

  AnswerKeyModel.fromJson(Map snapshot) {
    bookLetCount = snapshot['bookLetCount'];
    earningsIsActive = snapshot['earningsIsActive'] ?? false;
    datas = Map<String, dynamic>.from(snapshot['datas'] ?? {});
    answerKeyLocation = snapshot['answerKeyLocation'] == null ? null : AnswerKeyLocation.values.singleWhere((element) => element.toString() == snapshot['answerKeyLocation']);
  }

  Map<String, dynamic> mapForSave() {
    return {
      "bookLetCount": bookLetCount,
      "earningsIsActive": earningsIsActive,
      "datas": datas,
      "answerKeyLocation": answerKeyLocation?.toString(),
    };
  }
}

enum AnswerKeyLocation {
  menu,
  opticForm,
}

class AnswerKeyImportModel {
  String? testName;
  int? aNo;
  int? bNo;
  int? cNo;
  int? dNo;
  String? answer;
  String? earningText;
  AnswerKeyImportModel({this.aNo, this.bNo, this.cNo, this.dNo, this.answer, this.earningText, this.testName});

  @override
  String toString() {
    return 'TestName:$testName Ano:$aNo Bno:$bNo Anser:$answer EarningText:$earningText Cno:$cNo Dno:$dNo';
  }
}
