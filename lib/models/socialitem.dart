import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcg_database/fetcherboxes/helper.dart';
import 'package:mcg_database/firestore/firestore.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

class SocialItem extends DatabaseItem {
  String key;
  bool aktif = true;
  String? content;
  List<String>? imgList;
  List<String>? targetList;
  String? senderName;
  String? senderKey;
  String? senderImgUrl;
  dynamic timeStamp;
  bool? isPublish;
  String? youtubeLink;
  String? videoLink;
  String? videoThumb;

  SocialItem.create(this.key);

  bool get isVideo => !isPhoto && (youtubeLink.safeLength > 6 || videoLink.safeLength > 6);
  bool get isPhoto => imgList != null && imgList!.isNotEmpty;
  int get time => timeStamp is int
      ? timeStamp
      : (timeStamp is Timestamp)
          ? (timeStamp as Timestamp).millisecondsSinceEpoch
          : 0;

  SocialItem.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    timeStamp = snapshot['timeStamp'];
    isPublish = snapshot['isPublish'];

    ///notcrypted
    youtubeLink = snapshot['youtubeLink'];
    content = snapshot['content'];
    targetList = snapshot['targetList'] == null ? null : List<String>.from(snapshot['targetList']);
    imgList = snapshot['imgList'] == null ? null : List<String>.from(snapshot['imgList']);
    senderName = snapshot['senderName'];
    senderKey = snapshot['senderKey'];
    senderImgUrl = snapshot['senderImgUrl'];
    videoLink = snapshot['videoLink'];
    videoThumb = snapshot['videoThumb'];
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;
      youtubeLink = decryptedData['youtubeLink'];
      content = decryptedData['content'];
      targetList = decryptedData['targetList'] == null ? null : List<String>.from(decryptedData['targetList']);
      imgList = decryptedData['imgList'] == null ? null : List<String>.from(decryptedData['imgList']);
      senderName = decryptedData['senderName'];
      senderKey = decryptedData['senderKey'];
      senderImgUrl = decryptedData['senderImgUrl'];
      videoLink = decryptedData['videoLink'];
      videoThumb = decryptedData['videoThumb'];
    }
  }

  SocialItem.fromJsonForFirestoreData(Map snapshot, this.key) {
    aktif = snapshot['aktif'];
    timeStamp = snapshot['lastUpdate'];
    isPublish = snapshot['isPublish'];

    ///notcrypted
    youtubeLink = snapshot['youtubeLink'];
    content = snapshot['content'];
    targetList = snapshot['targetList'] == null ? null : List<String>.from(snapshot['targetList']);
    imgList = snapshot['imgList'] == null ? null : List<String>.from(snapshot['imgList']);
    senderName = snapshot['senderName'];
    senderKey = snapshot['senderKey'];
    senderImgUrl = snapshot['senderImgUrl'];
    videoLink = snapshot['videoLink'];
    videoThumb = snapshot['videoThumb'];
    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;
      youtubeLink = decryptedData['youtubeLink'];
      content = decryptedData['content'];
      targetList = decryptedData['targetList'] == null ? null : List<String>.from(decryptedData['targetList']);
      imgList = decryptedData['imgList'] == null ? null : List<String>.from(decryptedData['imgList']);
      senderName = decryptedData['senderName'];
      senderKey = decryptedData['senderKey'];
      senderImgUrl = decryptedData['senderImgUrl'];
      videoLink = decryptedData['videoLink'];
      videoThumb = decryptedData['videoThumb'];
    }
  }

  Map<String, dynamic> mapForSave(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      "timeStamp": timeStamp,
      "isPublish": isPublish,
    };

    data.addAll({
      "content": content,
      "targetList": targetList,
      "imgList": imgList,
      "senderName": senderName,
      "senderKey": senderKey,
      "senderImgUrl": senderImgUrl,
      "youtubeLink": youtubeLink,
      "videoLink": videoLink,
      "videoThumb": videoThumb,
    });

    return data;
  }

  Map<String, dynamic> toJsonForFirestore(String key) {
    final data = <String, dynamic>{
      "aktif": aktif,
      "lastUpdate": firestoreTime,
      "isPublish": isPublish,
    };

    data['enc'] = {
      "content": content,
      "targetList": targetList,
      "imgList": imgList,
      "senderName": senderName,
      "senderKey": senderKey,
      "senderImgUrl": senderImgUrl,
      "youtubeLink": youtubeLink,
      "videoLink": videoLink,
      "videoThumb": videoThumb,
    }.encrypt(key);

    return data;
  }

  String get getDateText => time.dateFormat("d-MMM, HH:mm");

  @override
  bool active() => aktif != false;
}
