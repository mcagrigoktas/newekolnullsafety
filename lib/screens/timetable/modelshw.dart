import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class HomeWork extends DatabaseItem {
  String? key;
  bool? aktif = true;
  String? title;
  dynamic timeStamp;
  int? checkDate;
  bool? isPublish;
  String? content;
  List<String>? imgList;
  List<String>? fileList;
  String? url;
  String? lessonName;
  String? teacherKey;
  String? classKey;
  String? className;
  String? lessonKey;
  //1 odev 2 sinav 3 note
  int? tur;
  String? checkNote;
  String? savedBy;

  HomeWork();

  HomeWork.fromJson(Map snapshot, this.key) {
    title = snapshot['title'];
    timeStamp = snapshot['timeStamp'] ?? 0;
    tur = snapshot['tur'];
    classKey = snapshot['classKey'];
    className = snapshot['className'];
    lessonKey = snapshot['lessonKey'];
    checkDate = snapshot['checkDate'];
    isPublish = snapshot['isPublish'];
    content = snapshot['content'];
    imgList = snapshot['imgList'] == null ? null : List<String>.from(snapshot['imgList']);
    fileList = snapshot['fileList'] == null ? null : List<String>.from(snapshot['fileList']);
    url = snapshot['url'];
    lessonName = snapshot['lessonName'];
    teacherKey = snapshot['senderKey'];
    aktif = snapshot['aktif'];
    checkNote = snapshot['checkNote'];
    savedBy = snapshot['sB'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif,
      "title": title,
      "tur": tur,
      "timeStamp": timeStamp,
      "classKey": classKey,
      "className": className,
      "lessonKey": lessonKey,
      "isPublish": isPublish,
      "content": content,
      "checkDate": checkDate,
      "imgList": imgList,
      "fileList": fileList,
      "url": url,
      "lessonName": lessonName,
      "senderKey": teacherKey,
      "checkNote": checkNote,
      "sB": savedBy,
    };
  }

  String get getTimeStampText => (timeStamp as int?)!.dateFormat("d-MMM");
  String get getEndDateText => checkDate!.dateFormat("d-MMM");

  @override
  bool active() => aktif != false;
}
