import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../models/accountdata.dart';
import '../appconfig.dart';
import 'ekol_dark.dart';
import 'ekol_light.dart';
import 'materialtheme.dart';
import 'qbank_dark.dart';
import 'qbank_light.dart';

enum AvailableGoogleFonts { alata, balsamiq }

class ThemeHelper {
  ThemeHelper._();
  //static const _defaultWebThemeLightDark = false;
  static ThemeData getThemeData() {
    var _googleTextTheme = _getGoogleFontsTextThemeFromPreferences();
    _googleTextTheme ??= _getGoogleFontsTextThemeFromAppConfigs();
    final _textTheme = _getGoogleTextThemeFromAvailableGoogleFontsName(_googleTextTheme, Fav.design.themeData.textTheme);
    final _themeData = Fav.design.themeData.copyWith(textTheme: _textTheme);
    return _themeData;
  }

  static AvailableGoogleFonts _getGoogleFontsTextThemeFromAppConfigs() => Get.find<AppConfig>().googleTextThemeList.first;

  static AvailableGoogleFonts? _getGoogleFontsTextThemeFromPreferences() {
    if (Fav.preferences.getString('gfontname') == null) return null;
    return AvailableGoogleFonts.values.singleWhereOrNull((element) => element.name == Fav.preferences.getString('gfontname'));
  }

  static Future<void> setGoogleFontsTextThemeNameToPreferences(String name) {
    return Fav.preferences.setString('gfontname', name);
  }

  static void _setDefaultFontsTextThemeNameToPreferences(bool isEkid) {
    if (Fav.preferences.getString('gfontname') == null) {
      if (isEkid) {
        Fav.preferences.setString('gfontname', AvailableGoogleFonts.balsamiq.name);
      } else {
        Fav.preferences.setString('gfontname', AvailableGoogleFonts.alata.name);
      }
    }
  }

  static TextTheme _getGoogleTextThemeFromAvailableGoogleFontsName(AvailableGoogleFonts font, TextTheme textTheme) {
    if (font == AvailableGoogleFonts.alata) return GoogleFonts.alataTextTheme(textTheme);
    if (font == AvailableGoogleFonts.balsamiq) return GoogleFonts.balsamiqSansTextTheme(textTheme);
    return GoogleFonts.alataTextTheme(textTheme);
  }

  static String _getDefaultTheme() {
    final appConfig = Get.find<AppConfig>();
    // if ((!kIsWeb && (hesapBilgileri?.isEkid == true))) return 'Ekid.theme';
    // if (isWeb && _defaultWebThemeLightDark) return appConfig.themeList.first.key;
    if (appConfig.themeList.any((element) => element.key == ThemeListModel.ekolLightKey)) return ThemeListModel.ekolLightKey;

    return appConfig.themeList.first.key;
  }

  static SystemUiOverlayStyle _darkUiOverlayStyle() {
    return SystemUiOverlayStyle(
      systemNavigationBarColor: Fav.design.bottomNavigationBar.background.withOpacity(1.0),
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    );
  }

  static SystemUiOverlayStyle _lightUiOverlayStyle() {
    return SystemUiOverlayStyle(
      systemNavigationBarColor: Fav.design.bottomNavigationBar.background.withOpacity(1.0),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    );
  }

  static void setEkolTheme(HesapBilgileri? hesapBilgileri) {
    if (hesapBilgileri != null) _setDefaultFontsTextThemeNameToPreferences(hesapBilgileri.isEkid);
    final theme = Fav.preferences.getString('ekolThemeV2', _getDefaultTheme());

    if (theme == ThemeListModel.ekolLightKey) {
      Get.appController.design = EkolLight.theme;
      SystemChrome.setSystemUIOverlayStyle(_darkUiOverlayStyle());
    } else if (theme == ThemeListModel.ekolDarkKey) {
      Get.appController.design = EkolDark.theme;
      SystemChrome.setSystemUIOverlayStyle(_lightUiOverlayStyle());
    } else if (theme == ThemeListModel.ekolMaterialLightKey) {
      Get.appController.design = EkolMaterialLightTheme.theme;
      SystemChrome.setSystemUIOverlayStyle(_darkUiOverlayStyle());
    } else {
      Get.appController.design = EkolDark.theme;
      SystemChrome.setSystemUIOverlayStyle(_lightUiOverlayStyle());
    }
  }

  static void setQbankTheme() {
    final theme = Fav.preferences.getString('qbankThemeV2', ThemeListModel.qbankDarkKey);

    if (theme == ThemeListModel.qbankDarkKey) {
      Get.appController.secondaryDesign = QBankDark.theme;
      if (AppVar.appConfig.appType == AppType.qbank) {
        Get.appController.design = EkolDark.theme;
      }
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else if (theme == ThemeListModel.qbankLightKey) {
      if (AppVar.appConfig.appType == AppType.qbank) {
        Get.appController.design = EkolLight.theme;
      }
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      Get.appController.secondaryDesign = QBankLight.theme;
    } else {
      Get.appController.secondaryDesign = QBankDark.theme;
      if (AppVar.appConfig.appType == AppType.qbank) {
        Get.appController.design = EkolDark.theme;
      }
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
  }

  static Future<void> openThemeSelector() async {
    if (AppVar.appBloc.hesapBilgileri.kurumID == 'demookul') {
      AppVar.appBloc.appConfig.themeList.clear();
      // AppVar.appBloc.appConfig.themeList.add(ThemeListModel.ekidTheme());
      AppVar.appBloc.appConfig.themeList.add(ThemeListModel.ekolDarkTheme());
      AppVar.appBloc.appConfig.themeList.add(ThemeListModel.ekolLightTheme());
      AppVar.appBloc.appConfig.themeList.add(ThemeListModel.ekolMaterialLightTheme());
    }

    final String _theme = await OverBottomSheet.show(
      BottomSheetPanel.simpleList(
        title: 'changethemeekol'.translate,
        items: AppVar.appBloc.appConfig.themeList.map((e) => BottomSheetItem<String>(value: e.key, name: e.name.translate)).toList(),
        bottomSheetPanelHeight: BottomSheetPanelHeight.L,
      ),
    );

    if (_theme.safeLength > 3) {
      await Fav.preferences.setString('ekolThemeV2', _theme);
      Get.changeTheme(getThemeData());
      AppVar.appBloc.appConfig.ekolRestartApp!(true);
    }
  }

  static Future<void> openFontSelector() async {
    final _theme = await OverBottomSheet.show(BottomSheetPanel.simpleList(
      title: 'fonttypes'.translate,
      items: AppVar.appBloc.appConfig.googleTextThemeList.map((e) {
        final _index = AppVar.appBloc.appConfig.googleTextThemeList.indexOf(e) + 1;
        final _isActiveFontType = Get.textTheme.bodyText1?.fontFamily?.toLowerCase().contains(e.name.toLowerCase()) == true;

        return BottomSheetItem(name: 'fonttype'.translate + ': ' + _index.toString(), value: e.name, itemColor: _isActiveFontType == true ? Fav.design.primary : null);
      }).toList(),
    ));
    if (_theme == null) return;
    await setGoogleFontsTextThemeNameToPreferences(_theme);
    Get.changeTheme(getThemeData());
    await 200.wait;
    AppVar.appBloc.appConfig.ekolRestartApp!(true);
  }
}

class ThemeListModel {
  static const ekolLightKey = 'EkolLight.theme';
  static const ekolDarkKey = 'EkolDark.theme';
  static const ekolMaterialLightKey = 'EkolMaterialLight.theme';
  static const qbankDarkKey = 'QBankDark.theme';
  static const qbankLightKey = 'QBankLight.theme';

  String name;
  String key;
  ThemeListModel(this.key, this.name);

  ThemeListModel.ekolLightTheme()
      : key = ekolLightKey,
        name = 'lighttheme';
  ThemeListModel.ekolMaterialLightTheme()
      : key = ekolMaterialLightKey,
        name = 'lighttheme2';

  ThemeListModel.ekolDarkTheme()
      : key = ekolDarkKey,
        name = 'darktheme';

  ThemeListModel.qbankDarkTheme()
      : key = qbankDarkKey,
        name = 'darktheme';
  ThemeListModel.qbankLightTheme()
      : key = qbankLightKey,
        name = 'lighttheme';
}
