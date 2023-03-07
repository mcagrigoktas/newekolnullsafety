import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../assets.dart';
import '../localization/localization.dart';

const webSiteLangPrefKey = 'WebSiteLang';

class WebSiteController extends GetxController {
  final PageController pageController = PageController(initialPage: 0);
  final _breakPoint = 600.0;
//1B7DF3
  Color get page1TextColor => Color(0xffA6C0F3);
  Color get textColor => '000000'.parseColor;
  Color get buttonColor => 'F1797B'.parseColor;
  Color get backgroundColor => Color(0xff3C7EEE);

  EdgeInsets pagePadding(BuildContext context, [double minHorizontalPaddingMiniScreen = 16, double minHorizontalPaddingLargeScreen = 64]) => EdgeInsets.symmetric(
        horizontal: context.screenWidth < 1600 ? (context.screenWidth > _breakPoint ? minHorizontalPaddingLargeScreen : minHorizontalPaddingMiniScreen) : (context.screenWidth - 1600 - 2 * (64)) / 2,
        vertical: context.screenHeight < 1400 ? 4 : (context.screenHeight - 1400 - 2 * 16) / 2,
      );

  bool isLargeScreen(BuildContext context) => context.screenWidth > 720;

//? Web html renderda shimmer calismiyordu
  BlendMode getBlendMode() => PlatformFunctions.isHtmlRenderer() ? BlendMode.lighten : BlendMode.srcATop;

  LinearGradient get backgroundGradient => LinearGradient(colors: [
        Colors.white,
        backgroundColor.withOpacity(0.7),
        backgroundColor.withOpacity(0.0),
      ], stops: [
        0.0,
        0.7,
        0.88
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  LinearGradient get boxgroundGradient => LinearGradient(colors: [
        Color(0xff5FB4F0),
        backgroundColor,
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter);

  String get lang {
    final _value = langList.firstWhereOrNull((element) {
          final _langCode = Fav.preferences.getString(webSiteLangPrefKey, Lang.locale.languageCode)!;
          return _langCode.contains(element);
        }) ??
        langList.first;
    return _value;
  }

  final langList = ['en', 'az', 'de', 'es', 'fr', 'ru', 'tr'];
}

class WebSiteWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final _waveHeight = (size.height / 15).clamp(0.0, size.width < 600 ? 32 : 96);
    var path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height - _waveHeight);
    path.quadraticBezierTo(size.width * 3 / 4, size.height, size.width / 2, size.height - _waveHeight);
    path.quadraticBezierTo(size.width / 4, size.height - 2 * _waveHeight, 0, size.height - _waveHeight);
    path.lineTo(0.0, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return kDebugMode;
  }
}

class Shape1Animation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: RiveSimpeLoopAnimation.asset(
        hideHtmlRenderer: true,
        animation: 'play',
        artboard: 'SHAPE1',
        url: Assets.rive.ekolwebsiteRIV,
        width: 333,
      ),
    );
  }
}

class Shape3Animation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Opacity(
      opacity: 0.08,
      child: RiveSimpeLoopAnimation.asset(
        hideHtmlRenderer: true,
        animation: 'play',
        artboard: 'SHAPE3',
        url: Assets.rive.ekolwebsiteRIV,
        width: _controller.isLargeScreen(context) ? 200 : 100,
      ),
    );
  }
}

class Shape2Animation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Opacity(
      opacity: 0.06,
      child: RiveSimpeLoopAnimation.asset(
        hideHtmlRenderer: true,
        animation: 'play',
        artboard: 'SHAPE2',
        url: Assets.rive.ekolwebsiteRIV,
        width: _controller.isLargeScreen(context) ? 200 : 100,
      ),
    );
  }
}

class PageArrowIcon extends StatelessWidget {
  final int pageIndex;
  final bool isDownButton;
  PageArrowIcon(this.pageIndex, this.isDownButton);
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return SizedBox(
      width: 36,
      height: 36,
      child: (isDownButton ? Icons.arrow_circle_down : Icons.arrow_circle_up)
          .icon
          .color(_controller.textColor.withOpacity(0.5))
          .onPressed(() {
            _controller.pageController.animateToPage(isDownButton ? pageIndex + 1 : pageIndex - 1, duration: 500.ms, curve: Curves.ease);
          })
          .size(36)
          .padding(0)
          .make()
          .animate()
          .fade(delay: 1000.ms),
    );
  }
}
