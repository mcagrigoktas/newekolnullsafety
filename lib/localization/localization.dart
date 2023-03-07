import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mcg_database/localization.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/localization.dart';

import '../appbloc/appvar.dart';
import '../screens/notification_and_agenda/agenda/localization.dart';
import '../website/controller.dart';

class Lang {
  Lang._();

  static Future<Map<String, String>> _readLangFile(String path) async {
    try {
      final ByteData langByteData = await rootBundle.load('assets/localization/$path.json');
      final langStringData = utf8.decode(langByteData.buffer.asUint8List());
      return Map<String, String>.from(json.decode(langStringData));
    } catch (e) {
      log(e);
      return {};
    }
  }

  static late Locale locale;
  static late Completer<bool> initCompleter;
  static Future<void> setLocalization(Locale? newLocale) async {
    locale = newLocale ?? Locale('en', 'US');
    initCompleter = Completer<bool>();
    Get.appController.localizeDataClear();
    final _prefLangType = Fav.preferences.getString('langType') ?? AppVar.appConfig.languageFolder;
    final trData = await _readLangFile('ekol/tr');
    final enData = await _readLangFile('ekol/en');
    Get.appController.localizeDataAddAll(trData);
    Get.appController.localizeDataAddAll(enData);
    if (locale.languageCode.toLowerCase().contains('tr')) {
      final _trData = _prefLangType == 'ekol' ? trData : await _readLangFile('$_prefLangType/tr');
      Get.appController.localizeDataAddAll(_trData);
    } else if (locale.languageCode.toLowerCase().contains('de')) {
      final _deData = await _readLangFile('$_prefLangType/de');
      Get.appController.localizeDataAddAll(_deData);
    } else if (locale.languageCode.toLowerCase().contains('ru')) {
      final _ruData = await _readLangFile('$_prefLangType/ru');
      Get.appController.localizeDataAddAll(_ruData);
    } else if (locale.languageCode.toLowerCase().contains('az')) {
      final _azData = await _readLangFile('$_prefLangType/az');
      Get.appController.localizeDataAddAll(_azData);
    } else {
      final _enData = _prefLangType == 'ekol' ? enData : await _readLangFile('$_prefLangType/en');
      Get.appController.localizeDataAddAll(_enData);
    }

    Get.appController.localizeDataAddAll(McgExtensionLang.init(locale));
    Get.appController.localizeDataAddAll(McgPhotoVideoCompressLang.init(locale));
    Get.appController.localizeDataAddAll(WidgetPackageLang.init(locale));
    Intl.defaultLocale = Intl.canonicalizedLocale(locale.countryCode.safeLength < 1 ? locale.languageCode : locale.toString());
    initCompleter.complete(true);
    // if (!kReleaseMode) {
    //   2000.wait.then((value) {
    //     final turkishList = LangTurkish.localizedValues.keys.toList();
    //     final englishList = LangEnglish.localizedValues.keys.toList();
    //     englishList.toList().where((element) => !turkishList.contains(element)).forEach((element) => p.info('Turkce dilinde $element eksik'));
    //     turkishList.toList().where((element) => !englishList.contains(element)).forEach((element) => p.info('Ingillizce dilinde $element eksik'));
    //   });
    // }
  }

  static Future<void> setWebSiteLocalization() async {
    final _webSiteLang = Fav.preferences.getString(webSiteLangPrefKey) ?? locale.languageCode.toLowerCase();
    final trData = await _readLangFile('website/tr');
    final enData = await _readLangFile('website/en');
    Get.appController.localizeDataAddAll(trData);
    Get.appController.localizeDataAddAll(enData);
    if (_webSiteLang.contains('tr')) {
      final _trData = await _readLangFile('website/tr');
      Get.appController.localizeDataAddAll(_trData);
    } else if (_webSiteLang.contains('de')) {
      final _deData = await _readLangFile('website/de');
      Get.appController.localizeDataAddAll(_deData);
    } else if (_webSiteLang.contains('ru')) {
      final _ruData = await _readLangFile('website/ru');
      Get.appController.localizeDataAddAll(_ruData);
    } else if (_webSiteLang.contains('az')) {
      final _azData = await _readLangFile('website/az');
      Get.appController.localizeDataAddAll(_azData);
    } else if (_webSiteLang.contains('es')) {
      final _esData = await _readLangFile('website/es');
      Get.appController.localizeDataAddAll(_esData);
    } else if (_webSiteLang.contains('fr')) {
      final _frData = await _readLangFile('website/fr');
      Get.appController.localizeDataAddAll(_frData);
    } else {
      final _enData = await _readLangFile('website/en');
      Get.appController.localizeDataAddAll(_enData);
    }
  }

  static List<LocalizationsDelegate<dynamic>> get delegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ];
}
