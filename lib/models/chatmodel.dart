import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';

String get _iV => AppVar.appBloc.hesapBilgileri.kurumID + 'bu6gdtra';

class MesaggingPreview extends DatabaseItem {
  String? senderKey;
  String? senderName;
  String? senderImgUrl;
  String? lastMessage;
  bool? owner;
  bool? isParent;
  dynamic timeStamp;
  int? targetGirisTuru;
  int? userGirisTuru;
  int? parentNo;

  bool get isManagerAndTeacherChats => targetGirisTuru! < 25 && userGirisTuru! < 25;

  MesaggingPreview({
    this.senderKey,
    this.senderName,
    this.senderImgUrl,
    this.lastMessage,
    this.timeStamp,
    this.isParent,
    this.targetGirisTuru,
    this.userGirisTuru,
    this.parentNo,
  });

  MesaggingPreview.fromJson(Map snapshot, this.senderKey) {
    timeStamp = snapshot['timeStamp'];
    owner = snapshot['owner'];
    isParent = snapshot['isParent'] ?? false;
    parentNo = snapshot['parentNo'] ?? 1;

    ///notcrypted
    senderName = snapshot['senderName'];
    senderImgUrl = snapshot['senderImgUrl'];
    lastMessage = snapshot['lastMessage'];

    //notcrypted

    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(_iV)!;
      senderName = decryptedData['senderName'];
      senderImgUrl = decryptedData['senderImgUrl'];
      lastMessage = decryptedData['lastMessage'];
    }
  }

  Map<String, dynamic> mapForSave() {
    final data = <String, dynamic>{
      "timeStamp": databaseTime,
      'isParent': isParent,
      if (parentNo == 2) 'parentNo': parentNo,
    };
    data.addAll({
      "senderName": senderName,
      "senderImgUrl": senderImgUrl,
      "lastMessage": lastMessage,
    });

    return data;
  }

  String get getDateText => (timeStamp as int?)!.dateFormat("d-MMM, HH:mm");

//?Mesaj listesinde kisinin yonetici yada ogretmense bransi yazmasi icin
  String? additionalInfo;

  @override
  bool active() => true;
}

// extension ChatModelExtension on ChatModel {
//   bool get backgroundIsNeccecary {
//     if (audioUrl != null) return false;
//     if (videoUrl != null) return false;
//     if (imageUrl != null || imgList != null) return false;

//     return true;
//   }
// }

class ChatModel {
  bool? aktif;
  bool? owner;
  dynamic timeStamp;
  String? imageUrl;
  List<String>? imgList;
  String? videoUrl;
  String? audioUrl;
  String? fileUrl;
  String? thumbnailUrl;
  String? message;
  bool? isParent;
  int? parentNo;
  String? key;
  bool? withSms;
  ChatModel();
  ChatModel.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    owner = snapshot['owner'];
    timeStamp = snapshot['timeStamp'];
    isParent = snapshot['isParent'] ?? false;
    parentNo = snapshot['parentNo'] ?? 1;
    withSms = snapshot['ws'] ?? false;

    ///notcrypted
    imageUrl = snapshot['imageUrl'];
    imgList = snapshot['imgList'] == null ? null : List<String>.from(snapshot['imgList']);
    videoUrl = snapshot['videoUrl'];
    audioUrl = snapshot['audioUrl'];
    thumbnailUrl = snapshot['thumbnailUrl'];
    fileUrl = snapshot['fileUrl'];
    message = (snapshot['message'] as String).trim();
    //notcrypted
    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(_iV)!;

      imageUrl = decryptedData['imageUrl'];
      imgList = decryptedData['imgList'] == null ? null : List<String>.from(decryptedData['imgList']);
      videoUrl = decryptedData['videoUrl'];
      audioUrl = decryptedData['audioUrl'];
      thumbnailUrl = decryptedData['thumbnailUrl'];
      fileUrl = decryptedData['fileUrl'];
      message = (decryptedData['message'] as String).trim();
    }
  }

  Map<String, dynamic> mapForSave() {
    final data = <String, dynamic>{
      if (aktif == false) 'aktif': aktif,
      'owner': owner,
      'timeStamp': timeStamp,
      'isParent': isParent,
      'parentNo': parentNo ?? 1,
      'ws': withSms,
    };
    data.addAll({
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileUrl': fileUrl,
      'message': message,
      'imgList': imgList,
    });

    return data;
  }

  String get timeStampText => (timeStamp as int?)!.dateFormat("d-MMM, HH:mm");
}

class LiveLessonChatModel {
  String? senderKey;
  String? senderName;
  String? senderImageUrl;
  int? senderGirisTuru;
  dynamic timeStamp;
  String? imageUrl;
  String? fileUrl;
  String? message;
  bool? raiseHand;
  LiveLessonChatModel();

  LiveLessonChatModel.fromJson(Map snapshot) {
    timeStamp = snapshot['timeStamp'];

    ///notcrypted
    senderKey = snapshot['sK'];
    senderName = snapshot['sN'];
    senderImageUrl = snapshot['sIU'];
    senderGirisTuru = snapshot['sGT'];
    imageUrl = snapshot['iU'];
    fileUrl = snapshot['fU'];
    message = snapshot['m'];
    raiseHand = snapshot['rH'];
    //notcrypted
    if (snapshot['enc'] != null) {
      final decryptedData = (snapshot['enc'] as String?)!.decrypt(_iV)!;
      senderKey = decryptedData['sK'];
      senderName = decryptedData['sN'];
      senderImageUrl = decryptedData['sIU'];
      senderGirisTuru = decryptedData['sGT'];
      imageUrl = decryptedData['iU'];
      fileUrl = decryptedData['fU'];
      message = decryptedData['m'];
      raiseHand = decryptedData['rH'];
    }
  }
  Map<String, dynamic> mapForSave() {
    final data = <String, dynamic>{
      "timeStamp": timeStamp,
    };

    data.addAll({
      "sK": senderKey,
      "sIU": senderImageUrl,
      "sN": senderName,
      'sGT': senderGirisTuru,
      "iU": imageUrl,
      "fU": fileUrl,
      "m": message,
      "rH": raiseHand,
    });

    return data;
  }

  String get timeStampText => (timeStamp as int?)!.dateFormat('HH:mm');

  bool get messageIsEmpty => fileUrl == null && imageUrl == null && message.safeLength < 1 && raiseHand == false;
}
