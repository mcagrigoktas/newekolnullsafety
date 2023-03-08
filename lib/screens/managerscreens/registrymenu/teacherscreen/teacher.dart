import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Teacher extends DatabaseItem implements Reliable {
  String key;
  String name = '';
  bool aktif = true;

  String? username;
  String? password;
  int? birthday;
  String? phone;
  String? mail;
  String? adress;
  String? explanation;
  String? imgUrl;

  String? tc;
  String? color;

  bool? seeAllClass;
  dynamic lastUpdate;
  Map? otherData;
  List<String>? branches;
  bool? passwordChangedByUser;
  // int teacherType;

  Teacher.create(this.key);

  Teacher.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    lastUpdate = snapshot['lastUpdate'];
    imgUrl = snapshot['imgUrl'];
    otherData = snapshot['otherData'] ?? {};
    passwordChangedByUser = snapshot['pCU'] ?? false;

    ///notcrypted
    name = snapshot['name'] ?? '';
    explanation = snapshot['explanation'];
    password = snapshot['password'];
    username = snapshot['username'];
    birthday = snapshot['birthday'];
    phone = snapshot['phone'];
    mail = snapshot['mail'];
    adress = snapshot['adress'];
    tc = snapshot['tc'];
    color = snapshot['color'];
    branches = List<String>.from(snapshot['branches'] ?? []);
    seeAllClass = snapshot['seeAllClass'] ?? false;

    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;

      name = decryptedData['name'];
      explanation = decryptedData['explanation'];
      password = decryptedData['password'];
      username = decryptedData['username'];
      birthday = decryptedData['birthday'];
      phone = decryptedData['phone'];
      mail = decryptedData['mail'];
      adress = decryptedData['adress'];
      tc = decryptedData['tc'];
      color = decryptedData['color'];
      branches = List<String>.from(decryptedData['branches'] ?? []);
      seeAllClass = decryptedData['seeAllClass'] ?? false;
    }
  }

  Map<String, dynamic> mapForSave(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      "lastUpdate": lastUpdate,
      "imgUrl": imgUrl,
      "otherData": otherData,
      "pCU": passwordChangedByUser,
    };

    data['enc'] = {
      "name": name,
      "username": username,
      "explanation": explanation,
      "password": password,
      "birthday": birthday,
      "phone": phone,
      "mail": mail,
      "adress": adress,
      "tc": tc,
      "color": color,
      "branches": branches,
      "seeAllClass": seeAllClass,
    }.encrypt(key);

    return data;
  }

  String get getSearchText => (name + explanation.toString()).toSearchCase();

  @override
  bool active() => aktif != false;

  @override
  bool get isReliable => key.safeLength > 1 && name.safeLength > 1;
}
