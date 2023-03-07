import 'package:mcg_extension/mcg_extension.dart';

class LiveBroadcastZoomModel {
  String? startUrl;
  String? joinUrl;
  int? meetingId;
  int? createTime;
  String? apiKeySecret;
  String? password;

  LiveBroadcastZoomModel({this.apiKeySecret, this.createTime, this.meetingId, this.joinUrl, this.startUrl, this.password});

  LiveBroadcastZoomModel.fromJson(Map snapshot) {
    startUrl = snapshot['startUrl'];
    meetingId = snapshot['meetingId'];
    joinUrl = snapshot['joinUrl'];
    createTime = snapshot['createTime'];
    apiKeySecret = snapshot['aks'] == null ? null : (snapshot['aks'] as String?).unMix;
    password = snapshot['password'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      "startUrl": startUrl,
      "meetingId": meetingId,
      "joinUrl": joinUrl,
      "createTime": createTime,
      "aks": apiKeySecret?.mix,
      "password": password,
    };
  }
}
