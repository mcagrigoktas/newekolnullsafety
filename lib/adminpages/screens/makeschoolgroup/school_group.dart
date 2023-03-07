import 'package:mcg_extension/mcg_extension.dart';

class SchoolGroup {
  String? key;
  String? name;
  String? exp;
  List<String>? schoolIdList;
  List<String>? existingIdList;
  List<String>? generalManagersWhoCanSee;
  bool? aktif;
  SchoolGroupForWhat? forWhat;

  SchoolGroup();

  SchoolGroup.createNew() {
    key = 'SchoolGroup' + 6.makeKey;
    aktif = true;
    forWhat = SchoolGroupForWhat.education;
  }

  SchoolGroup.fromJson(Map snapshot, String this.key) {
    aktif = snapshot['aktif'] ?? true;
    forWhat = J.jEnum(snapshot['forWhat'], SchoolGroupForWhat.values, SchoolGroupForWhat.education);
    final decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;

    name = decryptedData['name'];
    exp = decryptedData['exp'];
    schoolIdList = List<String>.from(decryptedData['sL'] ?? []);
    existingIdList = List<String>.from(decryptedData['eSL'] ?? []);
    generalManagersWhoCanSee = List<String>.from(decryptedData['gmL'] ?? []);
  }

  Map<String, dynamic> mapForSave() {
    final data = <String, dynamic>{
      'aktif': aktif,
      'forWhat': forWhat!.name,
    };

    data['enc'] = {
      "name": name,
      "exp": exp,
      "sL": schoolIdList,
      "eSL": existingIdList,
      "gmL": generalManagersWhoCanSee,
    }.encrypt(key!);

    return data;
  }

  String get getSearchText => (name! + exp.toString()).toLowerCase();
}

enum SchoolGroupForWhat { education }
