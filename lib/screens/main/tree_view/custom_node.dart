import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';

class SidebarNode extends ExpandableSideBarNode {
  static String get favoriteUsageSeasonCacheKey => '${AppVar.appBloc.hesapBilgileri.uid}favoritesusage';
  String get usagePrefKey => AppVar.appBloc.hesapBilgileri.uid + name! + '_usage';
  SidebarNode({String? name, Function()? onTap, IconData? icon = Icons.question_answer}) {
    this.name = name;
    //? Breaking key silindi
    // this.key = key;
    this.icon = icon;
    if (onTap != null) {
      this.onTap = () {
        Fav.preferences.setInt(usagePrefKey, Fav.preferences.getInt(usagePrefKey, 0)! + 1);
        onTap();
      };
      if (Fav.preferences.getInt(usagePrefKey, 0)! > 0) {
        (Fav.readSeasonCache(favoriteUsageSeasonCacheKey) as Map<String?, FavoriteUsage>)[name] = FavoriteUsage()
          ..name = name
          ..usageCount = Fav.preferences.getInt(AppVar.appBloc.hesapBilgileri.uid + name!, 0)
          ..node = this;
      }
    }
  }
}

class FavoriteUsage {
  String? name;
  int? usageCount;
  SidebarNode? node;
  FavoriteUsage({this.name, this.usageCount, this.node});
}
