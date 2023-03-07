import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../localization/localization.dart';
import 'controller.dart';
import 'pages/page1.dart';
import 'pages/page2.dart';
import 'pages/page3.dart';
import 'pages/page4.dart';
import 'pages/page5.dart';
import 'pages/request_demo.dart';

class WebSiteLayout extends StatefulWidget {
  WebSiteLayout();

  @override
  State<WebSiteLayout> createState() => _WebSiteLayoutState();
}

class _WebSiteLayoutState extends State<WebSiteLayout> {
  bool _initComplated = false;
  late WebSiteController _controller;
  @override
  void initState() {
    if (isDebugMode) Animate.restartOnHotReload = true;
    _controller = Get.findOrPut<WebSiteController>(createFunction: () => WebSiteController());
    _init();
    super.initState();
  }

  Future<void> _init() async {
    await Lang.setWebSiteLocalization();
    setState(() {
      _initComplated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebSiteController>(builder: (controller) {
      if (_initComplated == false)
        return Scaffold(
            body: Center(
          child: CircularProgressIndicator(
            color: _controller.buttonColor,
          ),
        ));
      return Scaffold(
        backgroundColor: Colors.white,
        drawer: !_controller.isLargeScreen(context)
            ? Drawer(
                width: context.screenWidth,
                child: WebSiteDrawer(),
              )
            : null,
        body: PageView.builder(
          controller: controller.pageController,
          pageSnapping: true,
          dragStartBehavior: DragStartBehavior.start,
          allowImplicitScrolling: false,
          physics: PlatformFunctions.isHtmlRenderer() ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: 6,
          itemBuilder: (context, index) {
            if (index == 0) return WebSitePage1();
            if (index == 1) return WebSitePage2();
            if (index == 2) return WebSitePage3();
            if (index == 3) return WebSitePage4();
            if (index == 4) return WebSitePage5();
            if (index == 5) return WebSiteDemoReqPage();
            return Container(color: MyPalette.getRandomColor());
          },
        ),
      );
    });
  }
}
