import 'package:mcg_extension/mcg_extension.dart';

class Person {
  dynamic lastUpdate;
  bool? aktif;
  String? key;
  String? imgUrl;
  List<PersonCategory>? categories;

  String? name;
  String? tc;
  String? tel1;
  String? tel2;
  String? mail;
  String? adres;
  String? exp;

  ///Tedarikci ise ac
  String? contactName;
  String? contactTel;
  String? contactMail;
  String? contactExp;
  String? customerNumber;
  String? taxNumber;

  Person({this.lastUpdate, this.key, this.name, this.categories});

  Person.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['lastUpdate'];
    aktif = snapshot['aktif'] ?? true;
    imgUrl = snapshot['imgUrl'];
    categories = J.jEnumList(snapshot['categories'], PersonCategory.values, []);

    ///notcrypted
    name = snapshot['name'];
    tc = snapshot['tc'];
    tel1 = snapshot['tel1'];
    tel2 = snapshot['tel2'];
    mail = snapshot['mail'];
    adres = snapshot['adres'];
    exp = snapshot['exp'];

    contactName = snapshot['cN'];
    contactTel = snapshot['cTel'];
    contactMail = snapshot['cMail'];
    contactExp = snapshot['cE'];
    customerNumber = snapshot['cNo'];
    taxNumber = snapshot['cTax'];

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key!)!;
      name = decryptedData['name'];
      tc = decryptedData['tc'];
      tel1 = decryptedData['tel1'];
      tel2 = decryptedData['tel2'];
      mail = decryptedData['mail'];
      adres = decryptedData['adres'];
      exp = decryptedData['exp'];

      contactName = decryptedData['cN'];
      contactTel = decryptedData['cTel'];
      contactMail = decryptedData['cMail'];
      contactExp = decryptedData['cE'];
      customerNumber = decryptedData['cNo'];
      taxNumber = decryptedData['cTax'];
    }
  }

  Map<String, dynamic> toJson(String key) {
    final _data = <String, dynamic>{
      'lastUpdate': lastUpdate,
      'aktif': aktif,
      'imgUrl': imgUrl,
      'categories': categories?.map((e) => e.name).toList(),
    };
    final _data2 = <String, dynamic>{
      'name': name,
      'tc': tc,
      'tel1': tel1,
      'tel2': tel2,
      'mail': mail,
      'adres': adres,
      'exp': exp,
      'cN': contactName,
      'cTel': contactTel,
      'cE': contactExp,
      'cNo': customerNumber,
      'cTax': taxNumber,
      'cMail': contactMail,
    };
    _data['enc'] = _data2.encrypt(key);
    // if (!cryptModel) {
    //   _data.addAll(_data2);
    // } else {

    // }

    return _data;
  }

  String get getSearchText => name.toSearchCase();

  bool get isEmployee => categories?.contains(PersonCategory.employee) == true;
  bool get isSupplier => categories?.contains(PersonCategory.supplier) == true;
}

enum PersonCategory { employee, supplier }
