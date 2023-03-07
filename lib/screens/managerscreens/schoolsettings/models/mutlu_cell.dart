import 'dart:convert';

import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../flavors/appconfig.dart';

class SmSConfig {
  Map? data;

  SmSConfig.fromData(this.data);

  SmSConfig.fromJson(String? stringData) {
    if (stringData != null) {
      data = jsonDecode(stringData.unMix!);
    }
  }

  String? toJsonString() => data == null ? null : jsonEncode(data).mix;

  bool get isSturdy {
    if (data == null) return false;
    if (AppVar.appBloc.appConfig.smsCountry == Country.tr) {
      final _config = MutluCellConfig.fromJson(data!);
      return _config.isSturdy;
    }
    return false;
  }

  T? config<T>() {
    if (!isSturdy) return null;
    if (AppVar.appBloc.appConfig.smsCountry == Country.tr) {
      return MutluCellConfig.fromJson(data!) as T;
    }
    return null;
  }
}

class MutluCellConfig {
  String? username;
  String? password;
  String? originator;

  MutluCellConfig({this.username, this.password, this.originator});

  MutluCellConfig.fromJson(Map snapshot) {
    username = snapshot['username'];
    password = snapshot['password'];
    originator = snapshot['originator'] ?? '';
  }

  bool get isSturdy => username.safeLength > 3 && password.safeLength > 3;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'originator': originator,
    };
  }
}
