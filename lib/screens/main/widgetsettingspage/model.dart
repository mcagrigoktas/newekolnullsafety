class WidgetModel {
  String? key;
  String? typeKey;
  String? _stringInfo1;
  String? _stringInfo2;
  String? name;
  int? _intInfo1;
  List<String>? targetList;

  WidgetModel({this.typeKey});

  WidgetModel.fromJson(Map snapshot, this.key) {
    typeKey = snapshot['t'];
    _stringInfo1 = snapshot['s1'];
    _stringInfo2 = snapshot['s2'];
    name = snapshot['n'];
    _intInfo1 = snapshot['i1'];
    targetList = List<String>.from(snapshot['tl'] ?? ['onlyteachers']);
  }

  Map<String, dynamic> toJson() {
    return {
      't': typeKey,
      's1': _stringInfo1,
      's2': _stringInfo2,
      'n': name,
      'i1': _intInfo1,
      'tl': targetList,
      'key': key,
    };
  }

//ignore: unnecessary_getters_setters
  String? get linkWidgetUrl => _stringInfo1;
//ignore: unnecessary_getters_setters
  set linkWidgetUrl(String? url) {
    _stringInfo1 = url;
  }

//ignore: unnecessary_getters_setters
  String? get linkWidgetImageUrl => _stringInfo2;
  //ignore: unnecessary_getters_setters
  set linkWidgetImageUrl(String? url) {
    _stringInfo2 = url;
  }

//ignore: unnecessary_getters_setters
  int get countTime => _intInfo1 ?? 0;
//ignore: unnecessary_getters_setters
  set countTime(int milliseconds) {
    _intInfo1 = milliseconds;
  }

  bool get isLinkWidget => typeKey == 'linkwidget';
  bool get isCounterWidget => typeKey == 'counterwidget';
}
