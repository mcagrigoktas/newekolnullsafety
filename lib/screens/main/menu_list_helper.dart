import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';

class MenuList {
  MenuList._();

  static List<String>? fullMenuList() => _menuList;

  static final Map<String?, List<String>> __menuList = {};
  static String _menuListPrefKey(String? kurumId) => '${kurumId}menuList';

  static List<String>? get _menuList {
    if (__menuList.containsKey(AppVar.appBloc.hesapBilgileri.kurumID) != true) {
      final _schoolInfoMenuList = AppVar.appBloc.schoolInfoService?.singleData?.menuList ?? [];
      final _preferencesMenuList = Fav.preferences.getStringList(_menuListPrefKey(AppVar.appBloc.hesapBilgileri.kurumID), [])!;
      __menuList[AppVar.appBloc.hesapBilgileri.kurumID] = {
        ..._schoolInfoMenuList,
        ..._preferencesMenuList,
      }.toList();

      if (_schoolInfoMenuList.isEmpty || (_schoolInfoMenuList..sort()).join() != (_preferencesMenuList..sort()).join()) {
        Future.delayed(5.seconds).then((value) async {
          final _newSchoolInfoMenuList = AppVar.appBloc.schoolInfoService?.singleData?.menuList;
          if (_newSchoolInfoMenuList == null) return;
          if ((_newSchoolInfoMenuList..sort()).join() != (_preferencesMenuList..sort()).join()) {
            await savePreferences(kurumId: AppVar.appBloc.hesapBilgileri.kurumID, menuList: _newSchoolInfoMenuList);
            AppVar.appBloc.appConfig.ekolRestartApp!(true);
          }
        });
      }
    }
    return __menuList[AppVar.appBloc.hesapBilgileri.kurumID];
  }

  static bool hasPreRegistration() => _menuList!.contains(MenuListItem.preregistration.name);
  static bool hasTimeTable() => _menuList!.contains(MenuListItem.timetable.name);
  static bool hasSurvey() => _menuList!.contains(MenuListItem.survey.name);
  static bool hasPortfolio() => _menuList!.contains(MenuListItem.portfolio.name);
  static bool hasEvaulation() => _menuList!.contains(MenuListItem.evaulation.name);
  static bool hasAccounting() => _menuList!.contains(MenuListItem.accounting.name);
  static bool hasHealthcare() => _menuList!.contains(MenuListItem.healthcare.name);
  static bool hasTransporter() => _menuList!.contains(MenuListItem.transporter.name);
  static bool hasBirthdayList() => _menuList!.contains(MenuListItem.birthdaylist.name);
  static bool hasQBank() => _menuList!.contains(MenuListItem.qbank.name);
  static bool hasLivebroadcast() => _menuList!.contains(MenuListItem.livebroadcast.name);
  static bool hasVideoLesson() => _menuList!.contains(MenuListItem.videolesson.name);
  static bool hasStickers() => _menuList!.contains(MenuListItem.stickers.name);
  static bool hasDailyReport() => _menuList!.contains(MenuListItem.dailyreport.name);
  static bool hasMessages() => _menuList!.contains(MenuListItem.messages.name);
  static bool hasSocialNetwork() => _menuList!.contains(MenuListItem.socialnetwork.name);
  static bool hasSimpleP2P() => _menuList!.contains(MenuListItem.p2ptype2.name);
  static bool hasFoodMenu() => _menuList!.contains(MenuListItem.foodmenu.name);

  static Future<void> savePreferences({required String? kurumId, required List menuList, bool refreshMenuList = false}) async {
    await Fav.preferences.setStringList(_menuListPrefKey(kurumId), List<String>.from(menuList));

    if (refreshMenuList) {
      __menuList.clear();
      _menuList;
    }
  }
}

enum MenuListItem {
  preregistration,
  timetable,
  survey,
  portfolio,
  evaulation,
  accounting,
  healthcare,
  transporter,
  birthdaylist,
  qbank,
  livebroadcast,
  videolesson,
  stickers,
  dailyreport,
  messages,
  socialnetwork,
  p2ptype2,
  foodmenu,
}
