import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Lesson extends DatabaseItem {
  String? name;
  String? longName;
  String? classKey;
  String? teacher;
  int? count;
  String? distribution;
  String? color;
  String? explanation;
  String? key;
  bool? aktif = true;
  int? lastUpdate;
  bool? remoteLessonActive;
  int? livebroadcasturltype;
  String? broadcastLink;
  Map? broadcastData;
  String? branch;
  //Map extraData;

  Lesson();

  Lesson.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'];
    lastUpdate = snapshot['lastUpdate'];
    remoteLessonActive = snapshot['remoteLessonActive'] ?? false;
    livebroadcasturltype = snapshot['livebroadcasturltype'];
    broadcastLink = snapshot['broadcastLink'] ?? '';
    broadcastData = snapshot['broadcastData'];

    ///notcrypted
    name = snapshot['name'];
    longName = snapshot['longName'];
    classKey = snapshot['classKey'];
    teacher = snapshot['teacher'];
    count = snapshot['count'];
    distribution = snapshot['distribution'];
    color = snapshot['color'];
    explanation = snapshot['explanation'];
    branch = snapshot['branch'];

    //   extraData = snapshot['extraData'] ?? {};
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;
      name = decryptedData['name'];
      longName = decryptedData['longName'];
      classKey = decryptedData['classKey'];
      teacher = decryptedData['teacher'];
      count = decryptedData['count'];
      distribution = decryptedData['distribution'];
      color = decryptedData['color'];
      explanation = decryptedData['explanation'];
      branch = decryptedData['branch'];

      //   extraData = snapshot['extraData'] ?? {};
    }
  }

  Map<String, dynamic> mapForSave(String? key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      'lastUpdate': lastUpdate,
      'remoteLessonActive': remoteLessonActive,
      'livebroadcasturltype': livebroadcasturltype,
      'broadcastLink': broadcastLink,
      'broadcastData': broadcastData,
    };

    data.addAll({
      "name": name,
      "longName": longName,
      "classKey": classKey,
      "teacher": teacher,
      "count": count,
      "distribution": distribution,
      "color": color,
      "explanation": explanation,
      "branch": branch,

      //   'extraData': extraData,
    });

    return data;
  }

  String get getSearchText => (name.toString() + longName.toString() + explanation.toString()).toLowerCase();

  @override
  bool active() => aktif != false;
}
