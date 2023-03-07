class HomeWorkCheck {
  String? noteText;
  String? lessonKey;
  String? title;
  String? content;
  String? key;
  //1 odev 2 sinav
  int? tur;
  int? date;

  HomeWorkCheck({this.noteText, this.lessonKey, this.title, this.content, this.tur, this.date});

  HomeWorkCheck.fromJson(Map snapshot, this.key) {
    noteText = snapshot['n'];
    lessonKey = snapshot['l'];
    title = snapshot['t'];
    content = snapshot['c'];
    tur = snapshot['tur'];
    date = snapshot['d'];
  }

  Map<String, dynamic> toJson() {
    return {
      'n': noteText,
      'l': lessonKey,
      't': title,
      'c': content,
      'tur': tur,
      'd': date,
    };
  }
}
