import 'dart:core';

import 'package:mcg_database/mcg_database.dart';

//todonullsafety remove this value
//bool get cryptModel => Get.find<RemoteControlValues>().cryptedMap == true;

class MarketData {
  String name;
  String androidUrl;
  String iosUrl;
  String saver;
  String webUrl;
  MarketData(this.name, this.androidUrl, this.iosUrl, this.saver, this.webUrl);
}

class DailyReport {
  String? key;
  String? header;
  bool? hasOption;
  List<String>? options;
  int? tur;
  String? iconName = 'et14c.png';

  DailyReport({this.key, this.header, this.hasOption, this.options, this.tur, this.iconName});

  DailyReport.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "header") {
        header = value;
      } else if (key == "hasOption") {
        hasOption = value;
      } else if (key == "options") {
        options = List<String>.from(value ?? []);
      } else if (key == "tur") {
        tur = value;
      } else if (key == "iconName") {
        iconName = value;
      } else if (key == "key") {
        this.key = value;
      }
    });
  }

  Map<String, dynamic> mapForSave() {
    return {
      "header": header,
      "hasOption": hasOption,
      "options": options,
      "tur": tur,
      "iconName": iconName,
      "key": key,
    };
  }

  String get iconUrl => "https://firebasestorage.googleapis.com/v0/b/elseifekid.appspot.com/o/appimages%2Ficons%2F" + iconName! + "?alt=media";
}

enum StickerStatus { active, deactive, past }

enum StickerTypes { reward, text, choosable }

class Sticker extends DatabaseItem {
  String? key;
  String? title;
  String? content;
  String? iconName = 'et14c.png';
  StickerTypes? type;
  bool? isHome;
  StickerStatus? status;
  dynamic extraData;
  String? classKey;
  int? lastUpdate;

  Sticker({this.key, this.title, this.content, this.type, this.isHome, this.iconName, this.status, this.extraData, this.classKey, this.lastUpdate});

  Sticker.fromJson(Map snapshot, this.key) {
    snapshot.forEach((key, value) {
      if (key == "title") {
        title = value;
      } else if (key == "content") {
        content = value;
      } else if (key == "iconName") {
        iconName = value;
      } else if (key == "type") {
        type = StickerTypes.values[value];
      } else if (key == "isHome") {
        isHome = value;
      } else if (key == "status") {
        status = StickerStatus.values[value];
      } else if (key == "classKey") {
        classKey = value;
      } else if (key == "extraData") {
        extraData = value;
      } else if (key == "lastUpdate") {
        lastUpdate = value;
      }
    });
  }

  Map<String, dynamic> mapForSave() {
    return {
      "title": title,
      "content": content,
      "iconName": iconName,
      "type": StickerTypes.values.indexOf(type!),
      "isHome": isHome,
      "status": StickerStatus.values.indexOf(status!),
      "extraData": extraData,
      "classKey": classKey,
      'key': key,
      'lastUpdate': lastUpdate,
    };
  }

  String get iconUrl => "https://firebasestorage.googleapis.com/v0/b/elseifekid.appspot.com/o/appimages%2Ficons%2F" + iconName! + "?alt=media";

  @override
  bool active() => true;
}

class Medicine {
  String? name, content;
  Medicine.fromJson(Map snapshot) {
    content = snapshot['content'];
    name = snapshot['name'];
  }
}

class MedicineProfile extends DatabaseItem {
  String key;
  String? content;
  int? startDate, endDate;
  String? studentKey;
  late List<Medicine> medicineList;
  bool? aktif;
  Map? medicineReport;
  int? timeStamp;

  MedicineProfile.fromJson(Map snapshot, this.key) {
    snapshot.forEach((key, value) {
      if (key == "aktif") {
        aktif = value;
      } else if (key == "content") {
        content = value;
      } else if (key == "startDate") {
        startDate = value;
      } else if (key == "endDate") {
        endDate = value;
      } else if (key == "studentKey") {
        studentKey = value;
      } else if (key == "medicineReport") {
        medicineReport = value ?? {};
      } else if (key == "medicinelist") {
        medicineList = (value as List).map((m) => Medicine.fromJson(m)).toList();
      } else if (key == "timeStamp") {
        timeStamp = value;
      }
    });
  }

  @override
  bool active() => aktif != false;
}

class Odeme {
  int? tarih;
  double? miktar;
  int? faturaNo;
  int? kasaNo;
  Odeme();

  Odeme.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "tarih") {
        tarih = value;
      } else if (key == "faturaNo") {
        faturaNo = value;
      } else if (key == "kasaNo") {
        kasaNo = value;
      } else if (key == "miktar") {
        miktar = (value as num).toDouble();
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {
      "tarih": tarih,
      "miktar": miktar,
      "faturaNo": faturaNo,
      "kasaNo": kasaNo,
    };
  }
}

class Indirim {
  String? name;

  ///0 oran 1 fiyat
  /// 0 oldugunda indirim yuzde olarak  hesaplanir 1  oldugunda total ucretten fiyat  olarak dusulur
  /// oran hem yuzde hemde ucret yerine gececek billgiyi kullanir
  int? type;
  int? oran;

  Indirim();

  Indirim.fromJson(Map snapshot) {
    name = snapshot['name'];
    oran = snapshot['oran'];
    type = snapshot['type'] ?? 0;
  }
  Map<String, dynamic> mapForSave() {
    return {
      "name": name,
      "oran": oran,
      "type": type ?? 0,
    };
  }
}

class TaksitModel {
  bool? aktif;
  String? name;
  int? tarih;
  double? tutar;
  List<Odeme>? odemeler;

  TaksitModel();

  TaksitModel.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "aktif") {
        aktif = value;
      } else if (key == "name") {
        name = value;
      } else if (key == "tarih") {
        tarih = value;
      } else if (key == "tutar") {
        tutar = (value as num).toDouble();
      } else if (key == "odemeler") {
        odemeler = (value as List).map((m) => Odeme.fromJson(m)).toList();
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif,
      "name": name,
      "tarih": tarih,
      "tutar": tutar,
      "odemeler": odemeler?.map((odeme) => odeme.mapForSave()).toList(),
    };
  }
}

class EkBaslangicTutari {
  String? name;
  double? value;

  EkBaslangicTutari();

  EkBaslangicTutari.fromJson(Map snapshot) {
    name = snapshot['name'];
    value = snapshot['value'] == null ? null : (snapshot['value'] as num).toDouble();
  }
  Map<String, dynamic> mapForSave() {
    return {
      "name": name,
      "value": value,
    };
  }
}

class PaymentModel {
  int? odemeTuru; //0 Pesin 1 Taksitli
  int? sozlesmeTarihi;
  int? ilkTaksitTarihi;
  TaksitModel? pesinat;
  TaksitModel? pesinUcret; //Tek odemede pesinat dusunce kalan ucret
  int? taksitSayisi;
  double? baslangicTutari;

  double? tutar;
  List<TaksitModel>? taksitler;
  List<Indirim>? indirimler;
  List<EkBaslangicTutari>? ekBaslangicTutari;
  bool aktif = true;
  Map? notes;

  PaymentModel();

  PaymentModel.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "aktif") {
        aktif = value;
      } else if (key == "odemeTuru") {
        odemeTuru = value;
      } else if (key == "sozlesmeTarihi") {
        sozlesmeTarihi = value;
      } else if (key == "ilkTaksitTarihi") {
        ilkTaksitTarihi = value;
      } else if (key == "pesinat") {
        pesinat = TaksitModel.fromJson(value);
      } else if (key == "pesinUcret") {
        pesinUcret = TaksitModel.fromJson(value);
      } else if (key == "taksitSayisi") {
        taksitSayisi = value;
      } else if (key == "baslangicTutari") {
        baslangicTutari = (value as num).toDouble();
      } else if (key == "ekBaslangicTutari") {
        ekBaslangicTutari = (value as List).map((m) => EkBaslangicTutari.fromJson(m)).toList();
      } else if (key == "tutar") {
        tutar = (value as num).toDouble();
      } else if (key == "taksitler") {
        taksitler = (value as List).map((m) => TaksitModel.fromJson(m)).toList();
      } else if (key == "indirimler") {
        indirimler = (value as List).map((m) => Indirim.fromJson(m)).toList();
      } else if (key == "notes") {
        notes = value;
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {
      'aktif': aktif,
      "odemeTuru": odemeTuru,
      "sozlesmeTarihi": sozlesmeTarihi,
      "ilkTaksitTarihi": ilkTaksitTarihi,
      "pesinat": pesinat!.mapForSave(),
      "pesinUcret": pesinUcret?.mapForSave(),
      "taksitSayisi": taksitSayisi,
      "baslangicTutari": baslangicTutari,
      "ekBaslangicTutari": ekBaslangicTutari!.map((item) => item.mapForSave()).toList(),
      "tutar": tutar,
      "taksitler": taksitler?.map((taksit) => taksit.mapForSave()).toList(),
      "indirimler": indirimler!.map((taksit) => taksit.mapForSave()).toList(),
      "notes": notes,
    };
  }
}

class FaturaModel {
  bool? aktif;
  int? kasaNo;
  String? paymentName;
  String? paymentTypeKey;
  String? personKey;
  int? tarih;
  double? tutar;
  String? key;
  FaturaModel();

  FaturaModel.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'];
    kasaNo = snapshot['kasaNo'];
    paymentName = snapshot['paymentName'];
    paymentTypeKey = snapshot['paymentTypeKey'];
    personKey = snapshot['personKey'];
    tarih = snapshot['tarih'];
    tutar = ((snapshot['tutar'] ?? 0) as num).toDouble();
  }
  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif,
      "kasaNo": kasaNo,
      "paymentName": paymentName,
      "paymentTypeKey": paymentTypeKey,
      "personKey": personKey,
      "tarih": tarih,
      "tutar": tutar,
    };
  }

  String get faturaNo => key!.replaceAll('fatura', '');
}

class VideoLessonModel {
  int? startTime;
  int? endTime;
  bool? aktif;
  String? studentKey;
  int? state; //0 empty 1 reserved
  int? logCallingDuration;

  VideoLessonModel();

  VideoLessonModel.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "aktif") {
        aktif = value;
      } else if (key == "startTime") {
        startTime = value;
      } else if (key == "endTime") {
        endTime = value;
      } else if (key == "studentKey") {
        studentKey = value;
      } else if (key == "state") {
        state = value;
      } else if (key == "logCallingDuration") {
        logCallingDuration = value;
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {"aktif": aktif, "startTime": startTime, "endTime": endTime, "studentKey": studentKey, "state": state, "logCallingDuration": logCallingDuration};
  }
}

class VideoLessonProgramModel extends DatabaseItem {
  String? teacherKey;
  String? lessonName;
  int? lessonDuration;
  int? lessonCount;
  int? lessonCountForBreak;
  int? breakDuration;
  int? pauseDuration;
  String? explanation;
  int? startTime;
  int? endTime;
  int? blockDay;
  bool? aktif;
  dynamic timeStamp;
  late List<VideoLessonModel> lessons;
  List<String>? targetList;
  String? key;

  VideoLessonProgramModel();

  VideoLessonProgramModel.fromJson(Map snapshot, this.key) {
    snapshot.forEach((key, value) {
      if (key == "teacherKey") {
        teacherKey = value;
      } else if (key == "lessonName") {
        lessonName = value;
      } else if (key == "lessonDuration") {
        lessonDuration = value;
      } else if (key == "lessonCount") {
        lessonCount = value;
      } else if (key == "lessonCountForBreak") {
        lessonCountForBreak = value;
      } else if (key == "breakDuration") {
        breakDuration = value;
      } else if (key == "pauseDuration") {
        pauseDuration = value;
      } else if (key == "explanation") {
        explanation = value;
      } else if (key == "startTime") {
        startTime = value;
      } else if (key == "endTime") {
        endTime = value;
      } else if (key == "blockDay") {
        blockDay = value;
      } else if (key == "targetList") {
        targetList = List<String>.from(value);
      } else if (key == "timeStamp") {
        timeStamp = value;
      } else if (key == "aktif") {
        aktif = value;
      } else if (key == "lessons") {
        lessons = (value as List).map((m) => VideoLessonModel.fromJson(m)).toList();
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {
      "teacherKey": teacherKey,
      "lessonName": lessonName,
      "lessonDuration": lessonDuration,
      "lessonCountForBreak": lessonCountForBreak,
      "lessonCount": lessonCount,
      "breakDuration": breakDuration,
      "pauseDuration": pauseDuration,
      "explanation": explanation,
      "startTime": startTime,
      "endTime": endTime,
      "blockDay": blockDay,
      "targetList": targetList,
      "timeStamp": timeStamp,
      "aktif": aktif,
      "lessons": lessons.map((lesson) => lesson.mapForSave()).toList(),
    };
  }

  @override
  bool active() => aktif != false;
}

class VideoLessonStudentModel extends DatabaseItem {
  int? startTime;
  int? endTime;
  String? lessonName;
  String? explanation;
  String? teacherKey;
  bool? aktif;
  String? key;

  VideoLessonStudentModel();

  VideoLessonStudentModel.fromJson(Map snapshot, this.key) {
    snapshot.forEach((key, value) {
      if (key == "startTime") {
        startTime = value;
      } else if (key == "endTime") {
        endTime = value;
      } else if (key == "lessonName") {
        lessonName = value;
      } else if (key == "explanation") {
        explanation = value;
      } else if (key == "teacherKey") {
        teacherKey = value;
      } else if (key == "aktif") {
        aktif = value;
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif,
      "startTime": startTime,
      "endTime": endTime,
      "lessonName": lessonName,
      "explanation": explanation,
      "teacherKey": teacherKey,
    };
  }

  @override
  bool active() => aktif != false;
}

class LiveBroadcastModel extends DatabaseItem {
  int? startTime;
  int? endTime;
  String? lessonName;
  String? explanation;
  String? teacherKey;
  bool? aktif;
  String? key;
  String? channelName;
  List<String>? targetList;
  String? broadcastLink;
  //0 zaman ayarli 1 sabitlenmis
  int? timeType;
  dynamic lastUpdate;
  int? livebroadcasturltype;

  Map? broadcastData;

  LiveBroadcastModel();

  LiveBroadcastModel.fromJson(Map snapshot, this.key) {
    startTime = snapshot["startTime"];
    endTime = snapshot["endTime"];
    lastUpdate = snapshot["lastUpdate"];
    lessonName = snapshot["lessonName"];
    explanation = snapshot["explanation"];
    channelName = snapshot["channelName"];
    broadcastLink = snapshot["broadcastLink"];
    timeType = snapshot["timeType"] ?? 0;
    teacherKey = snapshot["teacherKey"];
    aktif = snapshot["aktif"];
    livebroadcasturltype = snapshot["lbut"] ?? ((broadcastLink ?? '').contains('zoom') ? 2 : 1);

    targetList = snapshot["targetList"] == null ? null : List<String>.from(snapshot["targetList"]);
    broadcastData = snapshot['broadcastData'];
  }
  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif,
      "startTime": startTime,
      "endTime": endTime,
      "lastUpdate": lastUpdate,
      "lessonName": lessonName,
      "explanation": explanation,
      "teacherKey": teacherKey,
      "channelName": channelName,
      "broadcastLink": broadcastLink,
      "timeType": timeType,
      "targetList": targetList,
      "lbut": livebroadcasturltype,
      "broadcastData": broadcastData,
    };
  }

  @override
  bool active() => aktif != false;
}
