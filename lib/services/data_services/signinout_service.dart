part of '../dataservice.dart';

class SignInOutService {
  SignInOutService._();

  static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static dynamic get _realTime => databaseTime;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

//! GETDATASERVICE

  //Ilk Login olan kullanicilarin listesini ceker
  static Future<Snap?> getLoginList() => _databaseLogss.once('${StringHelper.schools}/$_kurumId/$_termKey/FirstLogin');

//Butun token listesi referansi
  //static Reference dbTokenList() => Reference(_databaseLogss, '${StringHelper.schools}/$_kurumId/$_termKey/Tokens');
  static Reference dbTokenList2TM() => Reference(_databaseLogss, '${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TM');
  static Reference dbTokenList2TSM() => Reference(_databaseLogss, '${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM');

  //Belli bir kullanicinin token referansi
  //static Reference dbTokenUser(String key) => Reference(_databaseLogss, '${StringHelper.schools}/$_kurumId/$_termKey/Tokens/$key');

  // Username ve Password ile kullanıcının sadece varlığını ve giriş türünü çeker.
  static Future<Snap?> checkUser(String username, String password, String? serverId) => _database11.once('${StringHelper.schools}/$serverId/CheckList/${username + password}');

  // Butun kullanici adi sifrelerini checklist kismindan alir. Sadece kurum idarecileri alabilir
  static Future<Snap?> checkAllCheckListValues() => _database11.once('${StringHelper.schools}/$_kurumId/CheckList');

  //Okulun kullandığı aktif dönemi getirir
  static Future<Snap?> checkTerm(String? serverId) => _database11.once('${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm');

  //Gmail ile giris yapilabilmesi icin  mail listesine bakar
  static Future<Snap?> dbGetMailData(String mail) => _database11.once('MailList/$mail/key1');

  //demookul bilgilerini getirir
  static Future<Snap?> getDemoInfo(String username, String password) => _database11.once('DemoPasswordList/${username + password}');

  //QrCodeLoginReferansi
  static Reference dbQrCodeLogin(String? key) => Reference(_databaseLogss, 'QRCodeLogin/$key');
//! SETDATASERVICE

//Ilk Login olmanin tamamlandigi bilgisini Ekler
  static Future firstLoginSuccess(String? kurumId, String? termKey, String? uid, String? kvkkVersion) {
    Map<String, dynamic> updates = {};
    updates['/${StringHelper.schools}/$kurumId/$termKey/FirstLogin/$uid'] = true;
    if (kvkkVersion != null) updates['/${StringHelper.schools}/$kurumId/$termKey/KVKKCheckList/$uid'] = kvkkVersion;
    return _databaseLogss.update(updates);
  }

  // Idareci icin Okul bilgilerine idarecinin son login zamanini kaydeder
  static Future<void> saveManagerLoginedTime() {
    return _database11.set('Okullar/$_kurumId/SchoolData/InfoForManager/mLT', _realTime);
  }

  // Kullanicinin push notification tokenini kaydeder
  //static Future<void> dbAddToken(String token) => _databaseLogss.set('${StringHelper.schools}/$_kurumId/$_termKey/Tokens/$_uid/$token', true);
  static Future<void> dbAddToken2(String token, String deviceName) {
    Map<String, dynamic> updates = {};

    final uidkey = AppVar.appBloc.hesapBilgileri.girisTuru.toString() + '-G-' + _uid!;

    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$uidkey/lastUpdate'] = _realTime;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$uidkey/tl/$token'] = deviceName ;

    ParentStateHelper.addTokenValuesForParents(updates, _kurumId, _termKey, _uid, _realTime, deviceName, token);

    if (AppVar.appBloc.hesapBilgileri.gtMT || AppVar.appBloc.hesapBilgileri.gtTransporter) {
      updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TM/$uidkey/lastUpdate'] = _realTime;
      updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TM/$uidkey/tl/$token'] = deviceName ;
    }

    // if (updates.isNotEmpty)
    return _databaseLogss.update(updates).then((value) {
      if (AppVar.appBloc.hesapBilgileri.gtS) {
        _database11.runTransaction('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.tokenListForManagerTeacher}', 1);
      } else {
        _database11.runTransaction('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.tokenListForStudent}', 1);
        _database11.runTransaction('${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/${VersionListEnum.tokenListForManagerTeacher}', 1);
      }
    });
  }

  // Kullanicinin push notification tokenini siller
  //static void dbDeleteToken(String kurumId, String termKey, String uid, String token) => _databaseLogss.set('${StringHelper.schools}/$kurumId/$termKey/Tokens/$uid/$token', null);
  static void dbDeleteToken2(String? kurumId, String? termKey, String uid, String token) {
    Map<String, dynamic> updates = {};

    final uidkey = AppVar.appBloc.hesapBilgileri.girisTuru.toString() + '-G-' + uid;

    updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TSM/$uidkey/lastUpdate'] = _realTime;
    updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TSM/$uidkey/tl/$token'] = null;

    if (AppVar.appBloc.hesapBilgileri.isParent == true) {
      final parentUidkey = '40-G-' + _uid!;
      final parentUidkey2 = '42-G-' + _uid!;
      updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TSM/$parentUidkey/lastUpdate'] = _realTime;
      updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TSM/$parentUidkey/tl/$token'] = null;

      updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TSM/$parentUidkey2/lastUpdate'] = _realTime;
      updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TSM/$parentUidkey2/tl/$token'] = null;
    }

    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TM/$uidkey/lastUpdate'] = _realTime;
      updates['/${StringHelper.schools}/$kurumId/$termKey/Tokens2/TM/$uidkey/tl/$token'] = null;
    }

    ///Istersen version listide yukardaki gibi guncelleyerek bildirim gellmemsini hizlandirabilirsin;
    _databaseLogss.update(updates);
  }

  //Gmail ile giris yapilabilmesi icin bilgileri mail listesine ekler
  static void dbAddMailList(String mail, data) => _database11.set('MailList/$mail/key1', data);
}
