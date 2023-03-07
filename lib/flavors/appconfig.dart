import 'package:mcg_extension/mcg_extension.dart';

import '../models/allmodel.dart';
import 'themelist/helper.dart';

class AppConfig {
  String appName;

  Function(bool, [Map])? ekolRestartApp;
  Function(bool?)? qbankRestartApp;
  final String? technicalSupportMail;
  final String? technicalSupportPhone;
  MarketData? marketData;

  final AppType appType;
  List<String>? serverIdList;
  final int databaseVersion;
  List<String>? favIconData;
  final List<ThemeListModel> themeList;
  Map? otherData;
  String webUrlAdress;
  FlavorType flavorType;
  KVKKSettings? kvkkSettings;
  Country? smsCountry;
  List<AvailableGoogleFonts> googleTextThemeList;
  final String languageFolder;

  AppConfig({
    this.appName = "Else If",
    this.ekolRestartApp,
    this.qbankRestartApp,
    this.technicalSupportMail,
    this.technicalSupportPhone,
    this.marketData,
    this.appType = AppType.ekol,
    this.serverIdList,
    this.databaseVersion = 0,
    this.favIconData,
    required this.themeList,
    this.otherData,
    this.webUrlAdress = '',
    this.flavorType = FlavorType.elseif,
    this.kvkkSettings,
    this.smsCountry,
    required this.googleTextThemeList,
    this.languageFolder = 'ekol',
  }) {
    otherData ??= {};
  }
}

enum AppType { qbank, ekol }

enum FlavorType {
  aci,
  datatac,
  datatacekid,
  elseif,
  elseifekid,
  golbasi,
  muradiye,
  teknokent,
  taktikbende,
  acilim,
  tua,
  speedsis,

  ///
  qbank,
  smatqbank,
  tarea,
}

class KVKKSettings {
  bool isRequired;
  KVKKCountry country;

  KVKKSettings({this.isRequired = false, this.country = KVKKCountry.tr});

  String get labalText_1 => ('pp_text_' + country.name).translate;
  String get url_1 {
    if (('pp_url_' + country.name).translate.startsWithHttp) return ('pp_url_' + country.name).translate;
    return ('pp_url_' + 'us').translate;
  }

  String get errText_1 => ('pp_text_err_' + country.name).translate;
  String get kvkkUrlVersion => country == KVKKCountry.tr ? 'V1' : 'V1';
}

enum KVKKCountry { tr, us }

enum Country { tr }

// const kvkkTextTurkey = 'Kullanım koşullarını ve açık rıza metnini kabul ediyorum.';
// const kvkkTextTurkeyErr = 'Dikkat!\n\nGiriş yapabilmek için kullanım koşullarını ve açık rıza metnini kabul etmeniz gerekiyor.';
// const kvkkUrlTurkey = 'https://www.ecollmobile.com/gizlilik-politikasi/';
// const kvkkUrlVersionTurkey = 'V1';
//https://www.ecollmobile.com/privacy-policy/