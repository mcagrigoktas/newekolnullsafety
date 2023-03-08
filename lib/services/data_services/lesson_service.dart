part of '../dataservice.dart';

class LessonService {
  LessonService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;
  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Ders Listesi Referansı
  static Reference dbLessonListRef() => Reference(_database11, 'Okullar/$_kurumId/$_termKey/Lessons');

//! SETDATASERVICE

  // Ders Kaydeder
  static Future<void> saveLesson(Lesson lesson, String existingKey) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey] = lesson.mapForSave(existingKey)..['lastUpdate'] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Lessons'] = _realTime;
    return _database11.update(updates).then((value) {
      makeBundle();
    });
  }

//Sinif Listesini kaydeder
  static Future<void> saveMultipleLesson(List<Lesson> itemList) async {
    Map<String, dynamic> updates = {};

    itemList.forEach((lesson) {
      updates['/Okullar/$_kurumId/$_termKey/Lessons/' + lesson.key] = lesson.mapForSave(lesson.key)..['lastUpdate'] = _realTime;
    });
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Lessons'] = _realTime;

    return _database11.update(updates).then((value) {
      makeBundle();
    });
  }

// Ders Siler
  static Future<void> deleteLesson(String existingKey, {bool recover = false}) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/aktif"] = recover;
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/lastUpdate"] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Lessons'] = _realTime;
    return _database11.update(updates);
  }

  // Derse Canli Yayin Ekler
  static Future<void> saveLessonBroadcastProgram(existingKey, remoteLessonActive, livebroadcasturltype, broadcastLink, broadcastData) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/remoteLessonActive"] = remoteLessonActive;
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/livebroadcasturltype"] = livebroadcasturltype;
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/broadcastLink"] = broadcastLink;
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/broadcastData"] = broadcastData;
    updates['/Okullar/$_kurumId/$_termKey/Lessons/' + existingKey + "/lastUpdate"] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Lessons'] = _realTime;

    return _database11.update(updates);
  }

  static Future<void> makeBundle() async {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;
    return () {
      AppVar.appBloc.lessonService?.makeBundle();
    }.delay(1500);
  }
}
