import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Student extends DatabaseItem {
  String? key;
  bool aktif = true;
  String? name;
  String? no;
  String? tc;
  String? username;
  String? password;
  String? class0;
  // String class1;
  Map<String, String?> groupList = {};
  int? birthday;
  bool? genre;
  String? blood;
  String? studentPhone;
  String? motherName;
  String? motherMail;
  String? motherPhone;
  String? motherJob;
  int? motherBirthday;
  String? fatherName;
  String? fatherMail;
  String? fatherPhone;
  String? fatherJob;
  int? fatherBirthday;
  String? allergy;
  String? adress;
  String? explanation;
  String? imgUrl;
  String? transporter;
  int? startTime;
  dynamic lastUpdate;
  int? parentState;
  String? parentPassword1;
  String? parentPassword2;
  bool? passwordChangedByUser;
  bool? parent1PasswordChangedByUser;
  bool? parent2PasswordChangedByUser;

  Map? flavorad;
  Map? otherdata;

  Student();

  Student.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    imgUrl = snapshot['imgUrl'];
    lastUpdate = snapshot['lastUpdate'];
    passwordChangedByUser = snapshot['pCU'] ?? false;
    parent1PasswordChangedByUser = snapshot['pCU1'] ?? false;
    parent2PasswordChangedByUser = snapshot['pCU2'] ?? false;

    ///notcrypted
    name = snapshot['name'];
    no = snapshot['no'];
    tc = snapshot['tc'];
    username = snapshot['username'];
    password = snapshot['password'];
    parentPassword1 = snapshot['pp1'];
    parentPassword2 = snapshot['pp2'];
    parentState = snapshot['pST'];
    class0 = snapshot['class0'] ?? snapshot['class_'];
    birthday = snapshot['bd'] ?? snapshot['birthday'];
    genre = snapshot['gd'] ?? snapshot['genre'];
    blood = snapshot['bld'] ?? snapshot['blood'];
    studentPhone = snapshot['sP'];
    motherName = snapshot['mN'] ?? snapshot['motherName'];
    motherMail = snapshot['mM'] ?? snapshot['motherMail'];
    motherPhone = snapshot['mP'] ?? snapshot['motherPhone'];
    motherJob = snapshot['mJ'] ?? snapshot['motherJob'];
    motherBirthday = snapshot['mB'] ?? snapshot['motherBirthday'];
    fatherName = snapshot['fN'] ?? snapshot['fatherName'];
    fatherMail = snapshot['fM'] ?? snapshot['fatherMail'];
    fatherPhone = snapshot['fP'] ?? snapshot['fatherPhone'];
    fatherJob = snapshot['fJ'] ?? snapshot['fatherJob'];
    fatherBirthday = snapshot['fB'] ?? snapshot['fatherBirthday'];
    allergy = snapshot['allergy'];
    explanation = snapshot['exp'] ?? snapshot['explanation'];
    adress = snapshot['adress'];
    transporter = snapshot['trp'] ?? snapshot['transporter'];
    startTime = snapshot['sT'] ?? snapshot['startTime'];
    flavorad = snapshot['flv'] ?? {};
    otherdata = snapshot['o'] ?? {};

    if (snapshot['class1'] != null && !groupList.containsKey('t1')) groupList['t1'] = snapshot['class1'];
    if (snapshot['gl'] != null) groupList.addAll(Map<String, String?>.from(snapshot['gl']));
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;

      name = decryptedData['name'];
      no = decryptedData['no'];
      tc = decryptedData['tc'];
      username = decryptedData['username'];
      password = decryptedData['password'];
      parentPassword1 = decryptedData['pp1'];
      parentPassword2 = decryptedData['pp2'];
      parentState = decryptedData['pST'];
      class0 = decryptedData['class0'];
      birthday = decryptedData['bd'];
      genre = decryptedData['gd'];
      blood = decryptedData['bld'];
      studentPhone = decryptedData['sP'];
      motherName = decryptedData['mN'];
      motherMail = decryptedData['mM'];
      motherPhone = decryptedData['mP'];
      motherJob = decryptedData['mJ'];
      motherBirthday = decryptedData['mB'];
      fatherName = decryptedData['fN'];
      fatherMail = decryptedData['fM'];
      fatherPhone = decryptedData['fP'];
      fatherJob = decryptedData['fJ'];
      fatherBirthday = decryptedData['fB'];
      allergy = decryptedData['allergy'];
      explanation = decryptedData['exp'];
      adress = decryptedData['adress'];
      transporter = decryptedData['trp'];
      startTime = decryptedData['sT'];
      flavorad = decryptedData['flv'] ?? {};
      otherdata = decryptedData['o'] ?? {};

      if (decryptedData['class1'] != null && !groupList.containsKey('t1')) groupList['t1'] = decryptedData['class1'];

      if (decryptedData['gl'] != null) {
        try {
          groupList.addAll(Map<String, String?>.from(decryptedData['gl']));
        } catch (e) {
          log(e);
        }
      }
    }
  }

  Map<String, dynamic> mapForSave(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      "lastUpdate": lastUpdate,
      "imgUrl": imgUrl,
      "pCU": passwordChangedByUser,
      "pCU1": parent1PasswordChangedByUser,
      "pCU2": parent2PasswordChangedByUser,
    };

    data['enc'] = {
      "name": name,
      "no": no,
      "tc": tc,
      "username": username,
      "password": password,
      "pp1": parentPassword1,
      "pp2": parentPassword2,
      "pST": parentState,
      "class0": class0,
      // "class1":class1,
      "gl": groupList,
      "bd": birthday,
      "gd": genre,
      "bld": blood,
      "sP": studentPhone,
      "mN": motherName,
      "mM": motherMail,
      "mP": motherPhone,
      "mJ": motherJob,
      "mB": motherBirthday,
      "fN": fatherName,
      "fM": fatherMail,
      "fP": fatherPhone,
      "fJ": fatherJob,
      "fB": fatherBirthday,
      "allergy": allergy,
      "adress": adress,
      "exp": explanation,
      "trp": transporter,
      "sT": startTime,
      "flv": flavorad,
      "o": otherdata,
    }.encrypt(key);
    return data;
  }

  String getSearchText() => (name! +
          no.toString() +
          explanation.toString() +
          // DateFormat(  "dateformat")).format(DateTime.fromMillisecondsSinceEpoch(birthday))+
          (genre == true ? "genre1".translate : "genre2".translate))
      .toSearchCase();

  List<String> get classKeyList => List<String>.from(groupList.values.toList()
    ..add(class0)
    ..removeWhere((element) => element.toString() == 'null'));

  @override
  bool active() => aktif != false;
}

extension StudentExtension on Student {
  dynamic getOtherData(String key) => (otherdata ?? {})[key];
  void setOtherData(String key, dynamic value) => (otherdata ??= {})[key] = value;
  double? get getLatitude => getOtherData('latitude');
  double? get getLongitude => getOtherData('longitude');
  void setLongitude(double value) => setOtherData('longitude', value);
  void setLatitude(double value) => setOtherData('latitude', value);
}
