class RollCallStudentModel {
  int? date;

  String? classKey;
  int? value;

  bool? isEkid = false;
  String? key;
  dynamic lastUpdate;

  ///? Ekidde asagidakiler bulunmaz
  int? lessonNo;
  String? lessonName;
  String? lessonKey;

  RollCallStudentModel({this.date, this.classKey, this.isEkid, this.key, this.lessonKey, this.lessonName, this.lessonNo, this.value});

  RollCallStudentModel.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['lastUpdate'];
    date = snapshot['date'];
    lessonName = snapshot['lessonName'];
    lessonKey = snapshot['lessonKey'];
    classKey = snapshot['classKey'];
    value = snapshot['value'];
    lessonNo = snapshot['lessonNo'];
    isEkid = snapshot['isEkid'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdate': lastUpdate,
      'date': date,
      'lessonName': lessonName,
      'lessonKey': lessonKey,
      'classKey': classKey,
      'value': value,
      'lessonNo': lessonNo,
      'isEkid': isEkid,
    };
  }
}
