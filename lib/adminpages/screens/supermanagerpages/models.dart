import 'package:mcg_extension/mcg_extension.dart';

class SuperManagerModel {
  bool? passwordChangedByUser;
  String? name;
  String? key;
  String? username;
  String? password;
  String? superManagerServerId;
  List<SuperManagerSchoolInfoModel>? schoolDataList;
  String? saver;
  SuperManagerModel();

  SuperManagerModel.fromJson(Map snapshot, this.key) {
    passwordChangedByUser = snapshot["pCU"] ?? false;

    ///notcrypted
    username = snapshot["username"] ?? "";
    password = snapshot["password"] ?? "";
    superManagerServerId = snapshot["superManagerServerId"] ?? "";
    schoolDataList = J.jClassList(snapshot["schoolDataList"] ?? [], (p0) => SuperManagerSchoolInfoModel.fromJson(p0));
    saver = snapshot["saver"] ?? "";
    name = snapshot["name"] ?? "Genel mudurluk";

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;

      username = decryptedData["username"] ?? "";
      password = decryptedData["password"] ?? "";
      superManagerServerId = decryptedData["superManagerServerId"] ?? "";
      schoolDataList = J.jClassList(decryptedData["schoolDataList"] ?? [], (p0) => SuperManagerSchoolInfoModel.fromJson(p0));
      saver = decryptedData["saver"] ?? "";
      name = decryptedData["name"] ?? "Genel mudurluk";
    }
  }

  Map<String, dynamic> toJson() {
    //  return {
    //   "username": username,
    //   "password": password,
    //   "superManagerServerId": superManagerServerId,
    //   "schoolDataList": schoolDataList,
    //   "saver": saver,
    //   "name": name,
    // };
    final data = <String, dynamic>{
      "pCU": passwordChangedByUser,
    };
    data['enc'] = {
      "username": username,
      "password": password,
      "superManagerServerId": superManagerServerId,
      "schoolDataList": schoolDataList?.map((e) => e.toJson()).toList(),
      "saver": saver,
      "name": name,
    }.encrypt(key!);
    return data;
  }
}

class SuperManagerSchoolInfoModel {
  String? schoolName;
  String? serverId;
  SuperManagerSchoolInfoModel({this.serverId, this.schoolName});

  SuperManagerSchoolInfoModel.fromJson(Map snapshot) {
    schoolName = snapshot["schoolName"] ?? "";
    serverId = snapshot["serverId"] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "schoolName": schoolName,
      "serverId": serverId,
    };
  }
}
