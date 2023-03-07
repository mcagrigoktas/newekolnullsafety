import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../questionpage/themeservice.dart';

class QuestionPageController2 {
  bool get tablet => Get.context!.mediaQuery.size.shortestSide > 600;
  bool get portrait => Get.context!.mediaQuery.orientation == Orientation.portrait;

  String get patternImageUrl {
    String patternImageUrl = "assets/pattern/${Fav.secondaryDesign.scaffold.backgroundAsset}schoolpattern.jpg";
    if (Get.context!.mediaQuery.size.shortestSide < 600 && !portrait) {
      patternImageUrl = "assets/pattern/${Fav.secondaryDesign.scaffold.backgroundAsset}schoolpatternpl.png";
    } else if (Get.context!.mediaQuery.size.shortestSide < 600 && portrait) {
      patternImageUrl = "assets/pattern/${Fav.secondaryDesign.scaffold.backgroundAsset}schoolpatternpp.png";
    } else if (!portrait) {
      patternImageUrl = "assets/pattern/${Fav.secondaryDesign.scaffold.backgroundAsset}schoolpatterntl.png";
    } else if (portrait) {
      patternImageUrl = "assets/pattern/${Fav.secondaryDesign.scaffold.backgroundAsset}schoolpatterntp.png";
    }
    return patternImageUrl;
  }

  TestPageThemeModel temayiAyarla() {
    if (Fav.secondaryDesign.brightness == Brightness.dark) {
      return ThemeService.theme1;
    } else if (Fav.secondaryDesign.brightness == Brightness.light) {
      return ThemeService.theme2;
    } else {
      return ThemeService.theme3;
    }
    // else if (themeNo == 3) {
    //   this.theme = theme4;
    // }
  }
}
