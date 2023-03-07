import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../services/remote_control.dart';
import 'appvar.dart';
import 'databaseconfig.dart';

class JWTData {
  JWTAlgorithm? algorithm;
  JWTKey? jwtKey;
  JWT? jwt;

  JWTData({this.algorithm, this.jwt, this.jwtKey});
}

class Jwt {
  static String _makeToken(JWTData data) {
    return data.jwt!.sign(
      data.jwtKey!,
      algorithm: data.algorithm!,
    );
  }

  static const _audince = 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit';

  static Future<String?> getUserAuthToken({required String kurumID, required String uid, int? girisTuru, bool? iM, bool? iT, bool? iS}) async {
    String? token;
    try {
      final jwt = JWT(
        {
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1000,
          'uid': kurumID + '_' + girisTuru.toString() + '_' + uid,

          'claims': {
            's': 'a4t5',
            if (iM == true) 'iM': iM,
            if (iT == true) 'iT': iT,
            if (iS == true) 'iS': iS,
            'kI': kurumID,
            'uk': uid,
          }
          //'a': 6.makeKey,
        },
        audience: Audience.one(_audince),
        issuer: DatabaseStarter.databaseConfig.serviceAccountEmail,
        subject: DatabaseStarter.databaseConfig.serviceAccountEmail,
      );

      JWTData jwtData = JWTData(
        jwt: jwt,
        jwtKey: RSAPrivateKey(DatabaseStarter.databaseConfig.privateKey!),
        algorithm: JWTAlgorithm.RS256,
      );

      token = await compute(_makeToken, jwtData);
    } catch (err) {
      return token;
    }

    return token;
  }

  static String? getJitsiJwtToken({
    String? domain,
    String? channelKey,
    String? name,
    String? id,
  }) {
    final jitsiTokenData = Get.find<RemoteControlValues>().jitsiJwtInfo(domain);
    if (jitsiTokenData == null) return null;
    String? token;
    try {
      final jwt = JWT(
        {
          "context": {
            "user": {
              "avatar": "https://eokul.fra1.digitaloceanspaces.com/01asset/user.png",
              "name": name,
              "email": "",
              "id": id,
            },
            "group": AppVar.appBloc.hesapBilgileri.kurumID,
          },
          "aud": jitsiTokenData[3],
          "iss": jitsiTokenData[2],
          'sub': jitsiTokenData[1],
          'room': channelKey,
          'exp': DateTime.now().millisecondsSinceEpoch / 1000 + 1000,
        },
        audience: jitsiTokenData[3],
        issuer: jitsiTokenData[2],
        subject: '*',
      );

      if (jitsiTokenData[4] == 1) {
        token = jwt.sign(RSAPrivateKey(jitsiTokenData[0]), algorithm: JWTAlgorithm.RS256);
      } else {
        token = jwt.sign(SecretKey(jitsiTokenData[0]), algorithm: JWTAlgorithm.HS256);
      }
    } catch (err) {
      return token;
    }

    return token;
  }
}
