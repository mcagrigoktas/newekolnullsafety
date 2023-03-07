/* 0 Geliştirme hesabı */
//class QBankHesapBilgileri {
//
//  String name="";
//  String imgUrl="";
//  String uid = "Anonim";
//  bool girisYapildi = false;
//  String username;
//  String password;
//
//  QBankHesapBilgileri();
//
//  @override
//  String toString() {
//    Map hesapBilgileriMap = {
//      "name": name,
//      "imgUrl":imgUrl,
//      "uid": uid,
//      "girisYapildi":girisYapildi,
//      "username":username,
//      "password":password,
//    };
//    return json.encode(hesapBilgileriMap);
//  }
//
//  setHesapBilgileri(String hesapBilgileri){
//    if(hesapBilgileri.length<1){return;}
//    Map hesapBilgileriMap = json.decode(hesapBilgileri);
//    name = hesapBilgileriMap["name"];
//    imgUrl = hesapBilgileriMap["imgUrl"];
//    uid = hesapBilgileriMap["uid"];
//    username=hesapBilgileriMap["username"];
//    password=hesapBilgileriMap["password"];
//    girisYapildi= hesapBilgileriMap["girisYapildi"];
//  }
//
//  reset(){
//    name="";imgUrl="";uid = "Anonim";girisYapildi = false;
//  }
//
//
//
//}

import 'dart:io';

import 'package:elseifekol/appbloc/appvar.dart';
import 'package:flutter/foundation.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdfx/pdfx.dart';

class PurchasedBookData {
  int? status; //10 satin alindi 0 bos 1 islem yapiliyor -1 red
  String? bookKey;
  dynamic purchasedDate;
  int? puchasedLimitDay;
  String? purchasedPrice;
  String? purchasedCode;
  Map? extraData;
  String? uid;
  String? invoiceKey;
  int? satinAlmaTuru; //0 bedava 1 iyzico 2 market

  PurchasedBookData({this.bookKey, this.puchasedLimitDay, this.purchasedDate, this.purchasedPrice, this.purchasedCode, this.extraData, this.status, this.satinAlmaTuru, this.invoiceKey, this.uid});

  PurchasedBookData.fromJson(Map json)
      : bookKey = json["bookKey"],
        purchasedDate = json["purchasedDate"],
        puchasedLimitDay = json["puchasedLimitDay"] is int ? json["puchasedLimitDay"] : (int.tryParse(json["puchasedLimitDay"] ?? '0') ?? 0),
        purchasedPrice = json["purchasedPrice"],
        purchasedCode = json["purchasedCode"],
        extraData = json["extraData"],
        invoiceKey = json["invoiceKey"],
        satinAlmaTuru = json["satinAlmaTuru"],
        uid = json["uid"],
        status = json["status"];

  Map<String, dynamic> mapForSave() {
    return {
      "bookKey": bookKey,
      "purchasedDate": purchasedDate,
      "puchasedLimitDay": puchasedLimitDay,
      "purchasedPrice": purchasedPrice,
      "purchasedCode": purchasedCode,
      "extraData": extraData,
      "invoiceKey": invoiceKey,
      "satinAlmaTuru": satinAlmaTuru,
      "uid": uid,
      "status": status,
      // "priceDay": priceDay,
    };
  }

  bool get isDateEnd {
    if (purchasedDate == null) {
      return false;
    }
    if (puchasedLimitDay == 0) {
      puchasedLimitDay = 3650;
    }
    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(purchasedDate)).inDays > puchasedLimitDay!;
  }
}

enum BookPriceStatus { FREE, PAID, FREE_TO_INSTUTION }

class Kitap extends DatabaseItem {
  List<String> privacy; //kurum gizliligi
  List<String> privacy2; //Apk gizliligi
  String? editorPrivacy;
  String? seviye;
  String bookKey;
  String? primaryColor;
  String? name1;
  String? name2;
  String? className1;
  String? className2; // Satin alma menusunde grup ismi olarak
  String? aciklama;
  String? status;
  String? version;
  String? versionName;
  String? imgUrl;
  final String? _price;
  final String? _price2;
  final String? _price3;
  final String? _priceCode; //Android Code
  final String? _priceCode2; //Ios code
  final String? _creditCardStatus; //0 pasif 1 sadece android 2 her ikiside
  String? priceDay;
  String? invoiceKey;
  final String? _priceStatus;
  String? versionRelease;
  String sira;
  bool coverName;
  int lastUpdate;

  ///o norma 1 deneme kitabi
  final String _bookType;

  BookPriceStatus get priceStatus {
    return _priceStatus == '0' ? BookPriceStatus.FREE : (_priceStatus == '2' ? BookPriceStatus.FREE_TO_INSTUTION : BookPriceStatus.PAID);
  }

  Kitap.fromJson(Map json, this.bookKey)
      : seviye = json["classLevel"],
        primaryColor = json["color1"],
        name1 = json["bookName1"],
        name2 = json["bookName2"],
        className1 = json["className1"],
        className2 = json["className2"],
        aciklama = json["other"],
        status = json["status"],
        version = json["version"],
        versionName = json["versionName"],
        imgUrl = json["imgUrl"],
        _price = json["price"],
        _price2 = json["price2"],
        _price3 = json["price3"],
        _priceCode = json["priceCode"],
        _priceCode2 = json["priceCode2"],
        _creditCardStatus = json["creditCardStatus"],
        priceDay = json["priceDay"],
        _priceStatus = json["priceStatus"],
        versionRelease = json["versionRelease"],
        sira = json["sira"] ?? "1",
        invoiceKey = json["invoiceKey"],
        privacy = List<String>.from(json["privacy"] ?? {}),
        privacy2 = List<String>.from(json["privacy2"] ?? {}),
        editorPrivacy = json["editorPrivacy"],
        coverName = json["coverName"] == '0' ? false : true,
        lastUpdate = json["lastUpdate"] ?? 0,
        _bookType = json["bookType"] ?? '0';

  bool get creditCardStatus {
    if (_creditCardStatus == '0') return false;

    if (kIsWeb) return true;

    if (_creditCardStatus == '1' && Platform.isIOS) return false;

    if (_creditCardStatus == '2') return true;

    return true;
  }

  String? get price {
    //todo web icin satin alinamaz yazabilirsin
    if (kIsWeb) return '';
    if (_creditCardStatus == '0') {
      if (Platform.isAndroid) return _price2;

      if (Platform.isIOS) return _price3;
    }
    if (_creditCardStatus == '1') {
      if (Platform.isAndroid) return _price;

      if (Platform.isIOS) return _price3;
    }
    return _price;
  }

  String get priceCode {
    if (kIsWeb) return 'codeempty';
    if (Platform.isAndroid) return _priceCode ?? 'codeempty';
    if (Platform.isIOS) return _priceCode2 ?? 'codeempty';

    return '';
  }

  bool get isDeneme => _bookType == '1';

  @override
  bool active() => status == '50';
}

class Test {
  final String? testKey;
  String? name;
  String? aciklama;
  int? sure;
  bool? anindaKontrol;
  //? Silme int? _testType;
  String? pdfUrl;
  List<Question> questions = [];

  Test.fromJson(Map testJSON, this.testKey) {
    testJSON.forEach((key, value) {
      if (key == "testInfo") {
        name = testJSON["testInfo"]["name2"];
        aciklama = testJSON["testInfo"]["aciklama"];
        sure = testJSON["testInfo"]["sure"];
        anindaKontrol = testJSON["testInfo"]["anindaKontrol"];
        //   _testType = testJSON["testInfo"]["testType"] ?? 0;
        pdfUrl = testJSON["testInfo"]["pdfUrl"];
      } else {
        questions.add(Question.fromJson(key, value));
      }

      questions.sort((question1, question2) => question1.key.compareTo(question2.key));
      if (sure == 0) {
        sure = questions.length;
      }
      if (sure == 0) {
        sure = 1;
      }
    });
  }

  int get count => questions.length;
//  TestType get testType => _testType == 1 ? TestType.pdf : TestType.advance;

  Uint8List? pdfByteData;
  Future<void> prepareNecceceryData() async {
    if (pdfUrl.safeLength > 6) {
      final downloaded = await DownloadManager.downloadThenCache(url: pdfUrl!);
      if (downloaded == null) {
        'filedownloaderr'.translate.showAlert();
      } else {
        AppVar.questionPageController.pdfDocument = await PdfDocument.openData(downloaded.byteData);
      }
    }
  }
}

// enum TestType { advance, pdf }
enum QuestionType { SECENEKLI, DY, KLASIK, ESLESTIRME }

class Question {
  ///100=secenekli 101=D-Y  102=Klasik  103=Eslestirme
  int? _questionType;
  String key;
  List<QuestionRow>? soru;
  List<QuestionRow>? options;
  List<QuestionRow>? solution;
  List<String>? optionGroupableList;
  late AnswerData answer;
  late OptionType optionType;

  QuestionType get questionType => _questionType == 103
      ? QuestionType.ESLESTIRME
      : _questionType == 102
          ? QuestionType.KLASIK
          : _questionType == 101
              ? QuestionType.DY
              : QuestionType.SECENEKLI;

  Question.fromJson(this.key, Map json) {
    json.forEach((key, value) {
      if (key == "type") {
        _questionType = json['type'];
      } else if (key == "question") {
        soru = (json['question'] as List).map((item) => QuestionRow.fromJson(item)).toList();
      } else if (key == "options") {
        options = (json['options'] as List).map((item) => QuestionRow.fromJson(item)).toList();
      } else if (key == "solution") {
        solution = (json['solution'] as List).map((item) => QuestionRow.fromJson(item)).toList();
      } else if (key == "optionGroupableList") {
        optionGroupableList = List<String>.from(json['optionGroupableList']);
      } else if (key == "answer") {
        answer = AnswerData.fromJson(json['answer']);
      } else if (key == "optionType") {
        optionType = OptionType.fromJson(json['optionType']);
      }
    });
  }
}

class QuestionRow {
  int? type; //100 sadece yazi,101 sadece resim,102 sol resim sag yazi,103 sol yazi sag resim, 104 youtubevideo
  String? image;
  String? text;
  bool? imageSingleColor;
  int? imageRate;
  String? youtubeVideo;
  Map? widget; // 102 numarali gibi widgetlarda herhangi bir datanin widget olma durumu aslinda her dqtayi widget ta tanimlayabilirdin amam text,image falan surekli kullanildigindan yukarda tanimladin
  dynamic widgetData; //

  void onCreate(Map data) {
    data.forEach((key, value) {
      if (key == "type") {
        type = value;
      } else if (key == "data") {
        onCreateData(value);
      }
    });
  }

  void onCreateData(Map value) {
    image ??= value['image'];
    text ??= (value['text'] as String?)?.trim();
    imageSingleColor ??= value['imageSingleColor'];
    imageRate ??= value['imageRate'];
    youtubeVideo ??= value['youtubeVideo'];
    widget ??= value['widget'];
  }

  QuestionRow({this.type, this.widgetData, this.text}) {
    if (widgetData is Map) onCreateData(widgetData);
  }

  QuestionRow.fromJson(Map snapshot) {
    onCreate(snapshot);
  }
}

class AnswerData {
  int? type;
  String? option;

  AnswerData.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "type") {
        type = value;
      } else if (key == "data") {
        option = value['option'];
      }
    });
  }
}

class OptionType {
  int? type;
  bool? sidebyside;
  int? autoOptionCount;
  bool get isAutoOptionsEnable => autoOptionCount != null;

  OptionType.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "type") {
        type = value;
      } else if (key == "data") {
        sidebyside = value['sidebyside'];
        autoOptionCount = value['secenekSayisi'];
      }
    });
  }
}
