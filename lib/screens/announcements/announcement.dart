import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../adminpages/screens/evaulationadmin/exams/model.dart';

class Announcement extends DatabaseItem implements Reliable {
  String key;
  bool aktif = true;
  String? title;
  dynamic timeStamp;
  bool? isPublish;
  String? content;
  List<String>? targetList;
  List<String>? imgList;
  List<String>? fileList;
  String? url;
  String? senderName;
  String? senderKey;
  bool? isPinned;
  String? surveyKey;

  Map? extraData;
  dynamic createTime;

  Announcement.create(this.key);

  Announcement.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    timeStamp = snapshot['timeStamp'];
    createTime = snapshot['cT'] ?? snapshot['timeStamp'];
    isPublish = snapshot['isPublish'];
    isPinned = snapshot['isPinned'];

    ///notcrypted
    title = snapshot['title'];
    content = snapshot['content'];
    targetList = snapshot['targetList'] == null ? null : List<String>.from(snapshot['targetList']);
    imgList = snapshot['imgList'] == null ? null : List<String>.from(snapshot['imgList']);
    fileList = snapshot['fileList'] == null ? null : List<String>.from(snapshot['fileList']);
    url = snapshot['url'];
    senderName = snapshot['senderName'];
    senderKey = snapshot['senderKey'];
    surveyKey = snapshot['surveyKey'];
    extraData = snapshot['ed'];
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;
      title = decryptedData['title'];
      content = decryptedData['content'];
      targetList = decryptedData['targetList'] == null ? null : List<String>.from(decryptedData['targetList']);
      imgList = decryptedData['imgList'] == null ? null : List<String>.from(decryptedData['imgList']);
      fileList = decryptedData['fileList'] == null ? null : List<String>.from(decryptedData['fileList']);
      url = decryptedData['url'];
      senderName = decryptedData['senderName'];
      senderKey = decryptedData['senderKey'];
      surveyKey = decryptedData['surveyKey'];
      extraData = decryptedData['ed'];
    }
  }

  Map<String, dynamic> mapForSave(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      "timeStamp": timeStamp,
      "isPublish": isPublish,
      "isPinned": isPinned,
      "cT": createTime,
    };

    data.addAll({
      "title": title,
      "content": content,
      "targetList": targetList,
      "imgList": imgList,
      "fileList": fileList,
      "url": url,
      "senderName": senderName,
      "senderKey": senderKey,
      "surveyKey": surveyKey,
      "ed": extraData,
    });

    return data;
  }

  List<ExamFile>? get examFileList {
    if (extraData == null) return null;
    if (extraData!['examFileList'] == null) return null;
    return (extraData!['examFileList'] as List).map((e) => ExamFile.fromJson(e)).toList();
  }

  //String get getDateText => (timeStamp is int) ? (timeStamp as int).dateFormat("d-MMM, HH:mm") : '';
  String get getCreteTimeText => (createTime is int) ? (createTime as int).dateFormat("d-MMM, HH:mm") : '';

  Map? get onlineForms {
    if (extraData == null) return null;
    return extraData!['onlineForms'];
  }

  Map? get examInfo {
    if (extraData == null) return null;
    return extraData!['examInfo'];
  }

  @override
  bool active() => aktif != false;

  @override
  bool get isReliable => key.safeLength > 1 && title.safeLength > 1;
}
