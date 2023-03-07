import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../screens/loginscreen/loginscreen.dart';
import '../controller.dart';

class WebsiteAppBar extends StatelessWidget {
  WebsiteAppBar();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Padding(
      padding: EdgeInsets.only(top: context.screenTopPadding + 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!_controller.isLargeScreen(context))
            Icons.menu_sharp.icon.onPressed(() {
              Scaffold.of(context).openDrawer();
            }).make(),
          'SPEEDSIS'.translate.text.bold.fontSize(18).color(_controller.textColor).make().pr8,
          SizedBox(
              width: 40,
              height: 20,
              child: PopupMenuButton(
                constraints: BoxConstraints(maxWidth: 70),
                position: PopupMenuPosition.under,
                child: SvgPicture.asset('assets/localization/flags/${_controller.lang}.svg'),
                initialValue: _controller.lang,
                itemBuilder: (context) {
                  return _controller.langList
                      .map(
                        (e) => PopupMenuItem(
                          value: e,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/localization/flags/$e.svg',
                              width: 40,
                              height: 20,
                            ),
                          ),
                          onTap: () async {
                            await Fav.preferences.setString(webSiteLangPrefKey, e);
                            await 200.wait;
                            AppVar.appConfig.ekolRestartApp!(true);
                          },
                        ),
                      )
                      .toList();
                },
              )),
          Expanded(
            child: _controller.isLargeScreen(context)
                ? Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1000),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...[
                              ['menu1', 0],
                              ['menu2', 1],
                              ['menu3', 2],
                              ['menu4', 3],
                              ['menu5', 4],
                            ]
                                .map((e) => TextButton(
                                      child: (e[0] as String).translate.text.color(_controller.textColor).fontSize(18).make(),
                                      onPressed: () {
                                        _controller.pageController.animateToPage(e[1] as int, duration: 300.ms, curve: Curves.ease);
                                      },
                                      style: TextButton.styleFrom(shape: StadiumBorder()),
                                    ).px2)
                                .toList()
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ),
          ElevatedButton(
            child: 'signin'.translate.text.color(Colors.white).fontSize(18).make(),
            onPressed: () {
              Fav.to(EkolSignInPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _controller.buttonColor,
              shape: StadiumBorder(),
              visualDensity: VisualDensity.comfortable,
            ),
          ).pl16,
        ],
      ),
    );
  }
}
