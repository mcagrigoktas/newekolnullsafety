import 'dart:convert';

import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';
import '../qbank/models/models.dart';
import '../screens/main/widgets/user_profile_widget/user_image_helper.dart';
import 'allmodel.dart';

class HesapBilgileri {
  static const String _preferencesKey = 'ekolUserM';

  bool girisYapildi = false;
  String termKey = '';
  String kurumID = '';
  String uid = '';
  int girisTuru = -1; //200 super manager 10 manager 20 ogretmen 30 ogrenci 40 veli 90 servis

  int? demoTime;
  String? signInToken;

  String? genelMudurlukId;
  String? name = "";
  String? imgUrl = "";

  String? class0 = "sinifiyok";
// String class1 = "sinifiyok";
  Map<String, String?> groupList = {};
  bool? teacherSeeAllClass;
  List<String> authorityList = [];

  String? username;
  String? password;
  String schoolType = 'ekol';
  bool isParent = false;
  int? parentNo = 1;
  int? parentState = 1;
  Map otherData = {};
  int databaseVersion = 0;
  Map? genelMudurlukGroupList;

  Map? userData;

  Map mapForSave() {
    return {
      "name": name,
      "imgUrl": imgUrl,
      "girisTuru": girisTuru,
      "uid": uid,
      "girisYapildi": girisYapildi,
      "class0": class0,
      "groupList": groupList,
      // "class1":class1,
      "authorityList": authorityList,
      "teacherSeeAllClass": teacherSeeAllClass,
      "signInToken": signInToken,
      "kurumID": kurumID,
      "genelMudurlukId": genelMudurlukId,
      "termKey": termKey,
      "username": username,
      "password": password,
      "schoolType": schoolType,
      "demoTime": demoTime,
      "isParent": isParent,
      'otherData': otherData,
      'databaseVersion': databaseVersion,
      'parentNo': parentNo ?? 1,
      'parentState': parentState ?? 1,
      'gmgl': genelMudurlukGroupList,
      'userData': userData,
    };
  }

  @override
  String toString() {
    return json.encode(mapForSave());
  }

  void setHesapBilgileri({String? accountInfo}) {
    String hesapBilgileri = accountInfo ?? readPreferences();

    if (hesapBilgileri.isEmpty) return;

    Map hesapBilgileriMap = json.decode(hesapBilgileri);
    termKey = hesapBilgileriMap["termKey"];
    uid = hesapBilgileriMap["uid"];
    kurumID = hesapBilgileriMap["kurumID"];
    girisTuru = hesapBilgileriMap["girisTuru"];

    name = hesapBilgileriMap["name"];
    imgUrl = hesapBilgileriMap["imgUrl"];

    girisYapildi = hesapBilgileriMap["girisYapildi"];
    class0 = hesapBilgileriMap["class0"] == null || hesapBilgileriMap["class0"] == '' ? "sinifiyok" : hesapBilgileriMap["class0"];
    groupList = hesapBilgileriMap['groupList'] != null ? Map<String, String?>.from(hesapBilgileriMap['groupList']) : Map<String, String?>.from({});
    if (hesapBilgileriMap["class1"] != null && !groupList.containsKey('t1')) {
      groupList['t1'] = hesapBilgileriMap["class1"];
    }
    //  class1= hesapBilgileriMap["class1"] ==null || hesapBilgileriMap["class1"]=='' ? "sinifiyok" : hesapBilgileriMap["class1"];
    teacherSeeAllClass = hesapBilgileriMap["teacherSeeAllClass"] ?? false;
    authorityList = List<String>.from(hesapBilgileriMap["authorityList"] ?? []);

    genelMudurlukId = hesapBilgileriMap["genelMudurlukId"];
    signInToken = hesapBilgileriMap["signInToken"];
    username = hesapBilgileriMap["username"];
    password = hesapBilgileriMap["password"];
    schoolType = hesapBilgileriMap["schoolType"] ?? 'ekid';
    demoTime = hesapBilgileriMap["demoTime"];
    isParent = hesapBilgileriMap["isParent"] ?? false;
    otherData = hesapBilgileriMap["otherData"] ?? {};
    databaseVersion = hesapBilgileriMap["databaseVersion"] ?? 0;
    parentNo = hesapBilgileriMap["parentNo"];
    parentState = hesapBilgileriMap["parentState"] ?? 1;
    genelMudurlukGroupList = hesapBilgileriMap["gmgl"];
    userData = hesapBilgileriMap["userData"];
  }

  String readPreferences() {
    //tododelete 29 temmuz 2023
    final existingData = Fav.preferences.getString(_preferencesKey);
    if (existingData != null && existingData.safeLength > 3) {
      Fav.securePreferences.setString(_preferencesKey, existingData);
      Fav.preferences.remove(_preferencesKey);
      return existingData.unMix!;
    }
    return Fav.securePreferences.getString(_preferencesKey, '')!;
  }

  Future<bool> savePreferences() async {
    await Fav.securePreferences.setString(_preferencesKey, toString());
    await Fav.securePreferences.addItemToMap(UserImageHelper.ekolAllUserPrefKey, kurumID + uid, toString());
    return true;
  }

  void removePreferences() {
    Fav.securePreferences.remove(_preferencesKey);
  }

  void reset() {
    kurumID = '';
    uid = '';
    termKey = '';
    girisTuru = -1;

    teacherSeeAllClass = false;
    username = null;
    password = null;
    genelMudurlukId = null;
    signInToken = null;
    name = "";
    imgUrl = "";

    girisYapildi = false;
    class0 = "sinifiyok";
    groupList = {};
    authorityList.clear();

    schoolType = 'ekid';
    demoTime = null;
    isParent = false;
    genelMudurlukGroupList = null;
    otherData.clear();
    userData?.clear();
  }

  List<String> get classKeyList => List<String>.from(groupList.values.toList()
    ..add(class0 ?? '')
    ..removeWhere((a) => a == null || a == ''));

  String get shortName => name == null ? '' : name!.split(" ").first;

  String get qbankUid => kurumID + girisTuru.toString() + uid;

  bool get isEkid => schoolType == 'ekid';
  bool get isEkol => schoolType == 'ekol';
  bool get isUni => schoolType == 'uni';
  bool get isEkolOrUni => schoolType == 'ekol' || schoolType == 'uni';

  bool get isQbank => schoolType == 'qbank';

  bool get gtT => girisTuru == 20;
  bool get gtS => girisTuru == 30;
  bool get gtM => girisTuru == 10;
  bool get gtTransporter => girisTuru == 90;
  bool get gtMT => girisTuru == 20 || girisTuru == 10;

  bool get isGood => termKey.safeLength > 2 && uid.safeLength > 2 && kurumID.safeLength > 4 && girisYapildi;
  bool get isSturdy => (termKey.safeLength > 2 && uid.safeLength > 2 && kurumID.safeLength > 4) || (kurumID.safeLength > 4 && username.safeLength > 4 && password.safeLength > 4 && kurumID.startsWith('739'));

  String? get zoomApiKey => otherData['zoomApiKey'];
  String? get zoomApiSecret => otherData['zoomApiSecret'];

  List<String> get genelMudurlukEducationList {
    List<String> _result = [kurumID, if (genelMudurlukId.safeLength > 0) genelMudurlukId!];
    if (genelMudurlukGroupList != null && genelMudurlukGroupList!['education'] != null) {
      _result.addAll(List<String>.from((genelMudurlukGroupList!['education'] as Map).keys));
    }

    return _result;
  }
}

extension HesepBilgileriExtension on HesapBilgileri {
  Transporter? get studentTransporter {
    if (userData is! Map) return null;
    final _student = castStudentData()!;
    return AppVar.appBloc.transporterService!.dataListItem(_student.transporter!);
  }

  bool get isUserChangedPassword {
    if (userData is! Map) return false;
    if (gtM && uid == 'Manager1') return true;
    if (gtM) {
      final _manager = castManagerData()!;
      return _manager.passwordChangedByUser == true;
    }
    if (gtT) {
      final _teacher = castTeacherData()!;
      return _teacher.passwordChangedByUser == true;
    }
    if (gtS) {
      // final _student = Student.fromJson(userData, uid);
      return throw ('Ogrenci icin daha yazilmadi parent meselelerinden dolayi');
    }
    return false;
  }

  Teacher? castTeacherData() {
    if (!gtT || (userData is! Map)) return null;
    return Teacher.fromJson(userData!, uid);
  }

  Manager? castManagerData() {
    if (!gtM || (userData is! Map)) return null;
    return Manager.fromJson(userData!, uid);
  }

  Student? castStudentData() {
    if (!gtS || (userData is! Map)) return null;
    return Student.fromJson(userData!, uid);
  }
}

class QBankHesapBilgileri {
  static const _preferencesKey = 'qBankUserM';
  String? kurumID;
  String? name = "";
  String? imgUrl = "";
  int? girisTuru = -1;
  String? uid;
  String? ekolUid; //Ogrencinin ekoldeki uidsi
  bool? girisYapildi = false;
  List<PurchasedBookData>? purchasedList = [];
  String? termKey;
  String? username;
  String? password;
  String schoolType = 'qbank';
  Map? invoiceData;

  String get shortName {
    if (name == null) {
      return "";
    } else {
      return name!.split(" ").first;
    }
  }

  bool get isEkid => schoolType == 'ekid';
  bool get isEkol => schoolType == 'ekol';
  bool get isQbank => schoolType == 'qbank';
  bool get isUni => schoolType == 'uni';

  @override
  String toString() {
    Map hesapBilgileriMap = {
      "name": name,
      "imgUrl": imgUrl,
      "girisTuru": girisTuru,
      "uid": uid,
      "girisYapildi": girisYapildi,
      "purchasedList": purchasedList!.map((item) => item.mapForSave()).toList(),
      "kurumID": kurumID,
      "termKey": termKey,
      "username": username,
      "password": password,
      "schoolType": schoolType,
      "invoiceData": invoiceData,
      "ekolUid": ekolUid,
    };
    return json.encode(hesapBilgileriMap);
  }

  void setHesapBilgileri() {
    String? hesapBilgileri = readPreferences();

    if (hesapBilgileri.safeLength < 1) return;

    Map hesapBilgileriMap = json.decode(hesapBilgileri!);
    termKey = hesapBilgileriMap["termKey"];
    name = hesapBilgileriMap["name"];
    imgUrl = hesapBilgileriMap["imgUrl"];
    girisTuru = hesapBilgileriMap["girisTuru"];
    uid = hesapBilgileriMap["uid"];
    girisYapildi = hesapBilgileriMap["girisYapildi"];

    purchasedList = ((hesapBilgileriMap["purchasedList"] ?? []) as List).map((item) => PurchasedBookData.fromJson(item)).toList();
    kurumID = hesapBilgileriMap["kurumID"];
    ekolUid = hesapBilgileriMap["ekolUid"];
    username = hesapBilgileriMap["username"];
    password = hesapBilgileriMap["password"];
    invoiceData = hesapBilgileriMap["invoiceData"];
    schoolType = hesapBilgileriMap["schoolType"] ?? 'qbank';

    purchasedList!.removeWhere((item) => item.status != 10);
  }

  String? readPreferences() {
    return Fav.securePreferences.getString(_preferencesKey, '');
  }

  Future<bool> savePreferences() {
    return Fav.securePreferences.setString(_preferencesKey, toString());
  }

  void removePreferences() {
    Fav.securePreferences.remove(_preferencesKey);
  }

  bool checkBookPurchased(String bookKey) {
    if (gtE) {
      return true;
    }
    List<PurchasedBookData> purchasedBook = purchasedList!.where((item) => item.bookKey == bookKey).toList();
    if (purchasedBook.isEmpty) {
      return false;
    }
    purchasedBook.sort((a, b) {
      return a.purchasedDate - b.purchasedDate;
    });

    if (purchasedBook.last.puchasedLimitDay == 0) {
      return true;
    }
    //todo buraya serverdan alinan saatten koy
    if (purchasedBook.last.isDateEnd) {
      return false;
    }
    return true;
  }

  void reset() {
    username = null;
    password = null;
    kurumID = null;
    name = "";
    imgUrl = "";
    girisTuru = -1;
    uid = null;
    girisYapildi = false;
    purchasedList!.clear();
    termKey = null;
    schoolType = 'qbank';
    ekolUid = null;
  }

  bool get gtT => girisTuru == 20;
  bool get gtS => girisTuru == 30;
  bool get gtM => girisTuru == 10;
  bool get gtMT => girisTuru == 20 || girisTuru == 10;
  bool get gtE => girisTuru == 100 || girisTuru == 101;
  bool get gtE1 => girisTuru == 100;
  bool get gtE2 => girisTuru == 101;
}
