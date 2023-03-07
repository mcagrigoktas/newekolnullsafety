import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Transporter extends DatabaseItem {
  String? key;
  String? username;
  String? password;
  String? profileName;
  String? explanation;
  String? driverName;
  String? employeeName;
  String? driverPhone;
  String? employeePhone;
  String? plate;
  bool? aktif = true;
  int? lastUpdate;

  Transporter();

  Transporter.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'];
    lastUpdate = snapshot['lastUpdate'];
    profileName = snapshot['pn'] ?? snapshot['profileName'];

    ///notcrypted

    explanation = snapshot['explanation'];
    driverName = snapshot['driverName'];
    employeeName = snapshot['employeeName'];
    driverPhone = snapshot['driverPhone'];
    employeePhone = snapshot['employeePhone'];
    plate = snapshot['plate'];
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;
      username = decryptedData['u'];
      password = decryptedData['p'];
      profileName ??= decryptedData['pn'] ?? decryptedData['profileName'];
      explanation = decryptedData['e'] ?? decryptedData['explanation'];
      driverName = decryptedData['dn'] ?? decryptedData['driverName'];
      employeeName = decryptedData['en'] ?? decryptedData['employeeName'];
      driverPhone = decryptedData['dp'] ?? decryptedData['driverPhone'];
      employeePhone = decryptedData['ep'] ?? decryptedData['employeePhone'];
      plate = decryptedData['pl'] ?? decryptedData['plate'];
    }
  }

  Map<String, dynamic> mapForSave(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      'lastUpdate': lastUpdate,
      "pn": profileName,
    };
    data['enc'] = {
      "u": username,
      "p": password,
      "e": explanation,
      "dn": driverName,
      "en": employeeName,
      "dp": driverPhone,
      "ep": employeePhone,
      "pl": plate,
    }.encrypt(key);
    return data;
  }

  String get getSearchText => (profileName! + explanation.toString() + plate.toString()).toLowerCase();

  @override
  bool active() => aktif != false;
}
