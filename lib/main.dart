// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'flavors/appconfig.dart';
import 'flavors/appconfigs.dart';
import 'flavors/appentry/ekolappentry.dart';
import 'flavors/mainhelper.dart';

Future<void> main() async {
  if (!isWeb) return runApp(const Center(child: Text('Only Web')));

  final _flavorType = WebStartHelper.getFlavorType();
  final appConfig = Get.put<AppConfig>(AppConfigs.getAppConfigs(_flavorType), permanent: true);
  var adres = PlatformFunctions.getAdress();
  appConfig.webUrlAdress = adres;

  WebStartHelper.overrideAppName();
  WebStartHelper.overrideFavIconSetup();
  PlatformFunctions.changeFavIcon(appConfig.favIconData![0], pathSuffix: appConfig.favIconData![1]);
  WebStartHelper.overrideMarketLinks();
  WebStartHelper.overrideThemeList();
  //await DatabaseStarter.webFirebaseInit();
  await MainHelper().initializeBeforeRunApp();

  WebStartHelper.overrideDebugMode();
  runApp(AppEntry());
}

class WebStartHelper {
  WebStartHelper._();

  static FlavorType getFlavorType() {
    var adres = PlatformFunctions.getAdress();

//? Buraya ekleyecegin seye gore firebase setup a da biseyler eklemen gerek

    if (adres.contains('acidijitalokul')) return FlavorType.aci;
    if (adres.contains('teknokentmobil')) return FlavorType.teknokent;
    if (adres.contains('ecollmeet')) return FlavorType.elseif;
    if (adres.contains('mycollege.dev')) return FlavorType.datatac;
    if (adres.contains('mycollege.dev')) return FlavorType.datatacekid;
    if (adres.contains('acilimdijital')) return FlavorType.acilim;
    if (adres.contains('tuaacademy')) return FlavorType.tua;
    if (adres.contains('speedsis')) return FlavorType.speedsis;

    return FlavorType.elseif;
  }

  static void overrideAppName() {
    var adres = PlatformFunctions.getAdress();
    final AppConfig appConfig = Get.find<AppConfig>();
    //? Example
    //if (adres.contains('adres.com')) appConfig.appName = 'AppName';
  }

  static void overrideFavIconSetup() {
    final AppConfig appConfig = Get.find<AppConfig>();
    var adres = appConfig.webUrlAdress;
    if (adres.contains('mycollege.dev')) {
      appConfig.favIconData = ['${AppConfigs.firebaseFavIconDataStoragePrefix}datatac%2F', AppConfigs.firebaseFavIconDataStorageSuffix];
    } else if (appConfig.favIconData == null || appConfig.favIconData!.length < 2) {
      appConfig.favIconData = ['${AppConfigs.firebaseFavIconDataStoragePrefix}elseifflavor%2F', AppConfigs.firebaseFavIconDataStorageSuffix];
    }
  }

  static void overrideMarketLinks() {
    if (!kIsWeb) return;
    final AppConfig appConfig = Get.find<AppConfig>();
    var adres = appConfig.webUrlAdress;

    //? Example
    //  if (adres.contains('adres.com')) {
    //     appConfig.marketData = DatabaseStarter.marketLinks['adres'];
    //   }
  }

  static void overrideThemeList() {
    if (!kIsWeb) return;
    final AppConfig appConfig = Get.find<AppConfig>();
    var adres = appConfig.webUrlAdress;
//? Example
    // if (adres.contains('adres.com')) {
    //   appConfig.themeList.removeWhere((element) => element.key != 'Adres.theme');
    // }
  }

  static void overrideDebugMode() {
    if (1 > 1 && kDebugMode) {
      //? Debugda override etmek istediklerini ekle
    }
  }
}
