import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Class extends DatabaseItem implements Reliable {
  String key;
  String name = '';
  bool aktif = true;

  String? longName;
  String? explanation;
  String? classTeacher;
  String? classTeacher2;
  String? imgUrl;

  //0 Normal sinif 1. Etud sinifi
  int? classType;

  String? classLevel;
  int? lastUpdate;

  Class.create(this.key);

  Class.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    lastUpdate = snapshot['lastUpdate'];

    ///notcrypted
    name = snapshot['name'] ?? '';
    longName = snapshot['longName'];
    explanation = snapshot['explanation'];
    classTeacher = snapshot['classTeacher'] ?? snapshot['teacher1'];
    classTeacher2 = snapshot['classTeacher2'] ?? snapshot['teacher2'];
    imgUrl = snapshot['imgUrl'];
    classType = snapshot['classType'] ?? 0;
    classLevel = snapshot['classLevel'];
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;
      name = decryptedData['name'];
      longName = decryptedData['longName'];
      explanation = decryptedData['explanation'];
      classTeacher = decryptedData['classTeacher'];
      classTeacher2 = decryptedData['classTeacher2'];
      imgUrl = decryptedData['imgUrl'];
      classType = decryptedData['classType'] ?? 0;
      classLevel = decryptedData['classLevel'];
    }
  }

  Map<String, dynamic> mapForSave(String? key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      'lastUpdate': lastUpdate,
    };

    data.addAll({
      "name": name,
      "explanation": explanation,
      "imgUrl": imgUrl,
      "classType": classType,
      "classLevel": classLevel,
      "classTeacher": classTeacher,
      "classTeacher2": classTeacher2,
      "longName": longName,
    });

    return data;
  }

  String get getSearchText => (name.toString() + longName.toString() + explanation.toString()).toSearchCase();

  @override
  bool active() => aktif != false;

  @override
  bool get isReliable => key.safeLength > 1 && name.safeLength > 1;
}
