class P2PRequest {
  dynamic lastUpdate;
  String? key;
  List<int?>? dayList;
  int? startHour;
  int? endHour;
  String? note;
  int? week;
  String? studentKey;
  String? lessonKey;

  P2PRequest({this.lastUpdate});

  P2PRequest.createDefatult() {
    dayList = [];
    startHour = 600;
    endHour = 1200;
    note = '';
  }

  P2PRequest.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['lu'];
    dayList = snapshot['dl'] == null ? null : List<int>.from(snapshot['dl']);
    startHour = snapshot['sh'];
    endHour = snapshot['eh'];
    note = snapshot['n'];
    week = snapshot['w'];
    studentKey = snapshot['sk'];
    lessonKey = snapshot['lk'];
  }

  Map<String, dynamic> toJson() {
    return {
      'lu': lastUpdate,
      'dl': dayList,
      'sh': startHour,
      'eh': endHour,
      'n': note,
      'w': week,
      'sk': studentKey,
      'lk': lessonKey,
    };
  }
}
