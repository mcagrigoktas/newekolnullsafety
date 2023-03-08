import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Manager extends DatabaseItem implements Reliable {
  String key;
  bool aktif = true;
  String name = '';

  String? username;
  String? password;
  String? phone;
  String? explanation;
  String? imgUrl;
  List<String>? authorityList;

  dynamic lastUpdate;
  Map? otherData;
  bool? passwordChangedByUser;
  Manager.create(this.key);

  Manager.fromJson(Map snapshot, this.key) {
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
    phone = snapshot['phone'];
    authorityList = List<String>.from(snapshot['authorityList'] ?? []);

    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;
      name = decryptedData['name'];
      explanation = decryptedData['explanation'];
      password = decryptedData['password'];
      username = decryptedData['username'];
      phone = decryptedData['phone'];
      authorityList = List<String>.from(decryptedData['authorityList'] ?? []);
    }
  }

  Map<String, dynamic> mapForSave(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      'lastUpdate': lastUpdate,
      "imgUrl": imgUrl,
      'otherData': otherData,
      "pCU": passwordChangedByUser,
    };
    // if (!cryptModel) {
    //   data.addAll({
    //     "name": name,
    //     "username": username,
    //     "explanation": explanation,
    //     "password": password,
    //     "authorityList": authorityList,
    //   });
    // } else {

    // }
    data['enc'] = {
      "name": name,
      "username": username,
      "phone": phone,
      "explanation": explanation,
      "password": password,
      "authorityList": authorityList,
    }.encrypt(key);

    return data;
  }

  String get getSearchText => (name + explanation.toString()).toSearchCase();

  @override
  bool active() => aktif != false;

  @override
  bool get isReliable => key.safeLength > 1 && name.safeLength > 1;
}
