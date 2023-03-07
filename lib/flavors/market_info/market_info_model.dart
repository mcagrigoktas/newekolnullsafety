import 'dart:convert';

import 'package:mcg_extension/mcg_extension.dart';

class MarketInfoModel {
  String? username;
  String? password;
  String? kurumId;
  String? androidUrl;
  String? iosUrl;
  String? webUrl;
  String? schoolName;
  String? schoolLogoUrl;
  String? name;

  MarketInfoModel({
    this.username,
    this.password,
    this.kurumId,
    this.androidUrl,
    this.iosUrl,
    this.webUrl,
    this.schoolName,
    this.schoolLogoUrl,
    this.name,
  });

  MarketInfoModel.fromJson(String? _cryptedConfig) {
    _cryptedConfig = _cryptedConfig.unMix;
    _cryptedConfig = utf8.decode(base64Decode(_cryptedConfig!));
    Map<String, dynamic> _config = json.decode(_cryptedConfig);

    username = _config['u'];
    password = _config['p'];
    kurumId = _config['k'];
    androidUrl = _config['and'];
    iosUrl = _config['ios'];
    webUrl = _config['web'];
    schoolName = _config['sn'];
    schoolLogoUrl = _config['sl'];
    name = _config['n'];
  }

  String? toJsonString() {
    final _jsonData = _toJson();
    final _a = json.encode(_jsonData);
    final _b = base64Encode(utf8.encode(_a));
    return _b.mix;
  }

  Map<String, dynamic> _toJson() {
    return {
      'u': username,
      'p': password,
      'k': kurumId,
      'and': androidUrl,
      'ios': iosUrl,
      'web': webUrl,
      'sn': schoolName,
      'sl': schoolLogoUrl,
      'n': name,
    };
  }
}
