import '../appbloc/databaseconfig.dart';
import '../helpers/stringhelper.dart';
import 'appconfig.dart';
import 'themelist/helper.dart';

class AppConfigs {
  AppConfigs._();

  static AppConfig getAppConfigs(FlavorType flavorType) {
    if (flavorType == FlavorType.aci) return aci;
    if (flavorType == FlavorType.taktikbende) return taktikbende;
    if (flavorType == FlavorType.datatac) return datatac;
    if (flavorType == FlavorType.datatacekid) return datatacekid;
    if (flavorType == FlavorType.elseif) return elseif;
    if (flavorType == FlavorType.elseifekid) return elseifekid;
    if (flavorType == FlavorType.golbasi) return golbasi;
    if (flavorType == FlavorType.muradiye) return muradiye;
    if (flavorType == FlavorType.teknokent) return teknokent;
    if (flavorType == FlavorType.acilim) return acilim;
    if (flavorType == FlavorType.tua) return tua;
    if (flavorType == FlavorType.speedsis) return speedsis;

    throw (Exception('Bilinmeyen flavor turu'));
  }

  static const String goldenTeknikDestekGmail = 'goldenteknikdestek@gmail.com';
  static const String goldenTeknikDestekPhone = '+908505500606';

  static String get firebaseFavIconDataStoragePrefix => 'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o/01asset%2Ffavicons%2F';
  static String get firebaseFavIconDataStorageSuffix => '?alt=media';

  static AppConfig get aci => AppConfig(
      flavorType: FlavorType.aci,
      appName: StringHelper.acikoleji,
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['aci']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}aciflavor%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //  ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get taktikbende => AppConfig(
      flavorType: FlavorType.taktikbende,
      appName: StringHelper.taktikbende,
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['taktikbende']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}taktikbende%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //   ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get datatac => AppConfig(
      flavorType: FlavorType.datatac,
      appName: "Smat College",
      databaseVersion: 0,
      technicalSupportMail: 'support@smatapp.com',
      technicalSupportPhone: '+23492919841',
      marketData: DatabaseStarter.marketLinks['datatac']!,
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //   ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: false),
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get datatacekid => AppConfig(
      flavorType: FlavorType.datatacekid,
      appName: "Smat",
      databaseVersion: 0,
      technicalSupportMail: 'support@smatapp.com',
      technicalSupportPhone: '+23492919841',
      marketData: DatabaseStarter.marketLinks['datatacekid']!,
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //  ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: false),
      googleTextThemeList: [
        AvailableGoogleFonts.balsamiq,
        AvailableGoogleFonts.alata,
      ]);

  static AppConfig get elseif => AppConfig(
      flavorType: FlavorType.elseif,
      appName: "E-Coll",
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['elseif']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}elseifflavor%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //   ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get speedsis => AppConfig(
      flavorType: FlavorType.speedsis,
      appName: "SpeedSIS",
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['speedsis']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}speedsis%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.us),
      //  smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get elseifekid => AppConfig(
      flavorType: FlavorType.elseifekid,
      appName: "Ekid+",
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['elseifekid']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}elseifflavor%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //   ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.balsamiq,
        AvailableGoogleFonts.alata,
      ]);

  static AppConfig get golbasi => AppConfig(
      flavorType: FlavorType.golbasi,
      appName: "Eğitim Platformu",
      databaseVersion: 0,
      technicalSupportMail: 'internalbilisim@gmail.com',
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['golbasi']!,
      serverIdList: ['golbasibelediyesi'],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get muradiye => AppConfig(
      flavorType: FlavorType.muradiye,
      appName: "Muradiye Eğitim Kurumları",
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['muradiye']!,
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //      ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.balsamiq,
        AvailableGoogleFonts.alata,
      ]);

  static AppConfig get teknokent => AppConfig(
      flavorType: FlavorType.teknokent,
      appName: StringHelper.teknokentKoleji,
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['teknokent']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}teknokentflavor%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
        //    ThemeListModel.ekidTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get acilim => AppConfig(
      flavorType: FlavorType.acilim,
      appName: StringHelper.acilim,
      databaseVersion: 0,
      technicalSupportMail: goldenTeknikDestekGmail,
      technicalSupportPhone: goldenTeknikDestekPhone,
      marketData: DatabaseStarter.marketLinks['acilim']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}acilimflavor%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: true, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);

  static AppConfig get tua => AppConfig(
      flavorType: FlavorType.tua,
      appName: StringHelper.tua,
      databaseVersion: 2,
      technicalSupportMail: '',
      technicalSupportPhone: '',
      marketData: DatabaseStarter.marketLinks['tua']!,
      favIconData: ['${firebaseFavIconDataStoragePrefix}tuaflavor%2F', firebaseFavIconDataStorageSuffix],
      themeList: [
        ThemeListModel.ekolLightTheme(),
        ThemeListModel.ekolDarkTheme(),
      ],
      kvkkSettings: KVKKSettings(isRequired: false, country: KVKKCountry.tr),
      smsCountry: Country.tr,
      googleTextThemeList: [
        AvailableGoogleFonts.alata,
        AvailableGoogleFonts.balsamiq,
      ]);
}
