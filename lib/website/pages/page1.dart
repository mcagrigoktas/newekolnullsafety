import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../assets.dart';
import '../controller.dart';
import 'appbar.dart';

class WebSitePage1 extends StatelessWidget {
  WebSitePage1();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Stack(
      children: [
        ..._BackgroundItems.get(context),
        Positioned.fill(
          child: Padding(
            padding: _controller.pagePadding(context),
            child: Column(
              children: [
                WebsiteAppBar(),
                Expanded(
                    child: _controller.isLargeScreen(context)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Center(
                                          child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _Page1Text1(),
                                      16.heightBox,
                                      _Page1Text2(),
                                      16.heightBox,
                                      _DemoButton(),
                                    ],
                                  ))),
                                  32.widthBox,
                                  Expanded(child: _ImageWidget()),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(flex: 7, child: FittedBox(child: _Page1Text1())),
                              8.heightBox,
                              Expanded(flex: 12, child: Center(child: _ImageWidget())),
                              8.heightBox,
                              _Page1Text2(),
                              8.heightBox,
                              _DemoButton(),
                              8.heightBox,
                            ],
                          )),
                PageArrowIcon(0, true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundItems {
  _BackgroundItems._();
  static List<Widget> get(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return [
      Positioned.fill(
          child: Container(
        decoration: BoxDecoration(gradient: _controller.backgroundGradient),
      )),
      Align(
        alignment: _controller.isLargeScreen(context) ? Alignment(-0.3, -0.8) : Alignment(0.0, -0.3),
        child: Shape1Animation(),
      ),
      // Align(
      //   alignment: Alignment.topLeft,
      //   child: Container(
      //     width: context.width / 4,
      //     height: context.screenWidth / 4,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.only(bottomRight: Radius.circular(context.width / 8)),
      //         gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
      //           Color(0xffF3FDF5),
      //           _controller.backgroundColor.withOpacity(0.0),
      //         ])),
      //   ),
      // ),
      // Align(
      //   alignment: Alignment.topRight,
      //   child: Container(
      //     width: context.width / 4,
      //     height: context.screenWidth / 4,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.only(bottomLeft: Radius.circular(context.width / 8)),
      //         gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [
      //           Color(0xffF3FDF5),
      //           _controller.backgroundColor.withOpacity(0.0),
      //         ])),
      //   ),
      // ),
    ];
  }
}

class _Page1Text1 extends StatelessWidget {
  _Page1Text1();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ('a_1'.translate.safeLength > 0) 'a_1'.translate.text.color(_controller.textColor).bold.fontSize(42).make().pb8,
          Row(
            children: [
              ' ${"a_digital".translate}  '
                  .text
                  .color(_controller.page1TextColor)
                  .fontSize(36)
                  .bold
                  .italic
                  .make()
                  .stadium(background: _controller.textColor)
                  .paddingOnly(top: 4, bottom: 4, right: 8)
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(delay: 3000.ms, duration: 900.milliseconds, blendMode: _controller.getBlendMode()),
              'and'.translate.text.color(_controller.textColor).bold.fontSize(36).make(),
              ' ${"a_social".translate}  '
                  .text
                  .color(_controller.page1TextColor)
                  .fontSize(36)
                  .bold
                  .italic
                  .make()
                  .stadium(background: _controller.textColor)
                  .paddingOnly(top: 4, bottom: 4, right: 8, left: 8)
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(delay: 3000.ms, duration: 900.milliseconds, blendMode: _controller.getBlendMode())
            ],
          ),
          if ('a_2'.translate.safeLength > 0) 'a_2'.translate.text.color(_controller.textColor).fontSize(42).bold.make().pt8,
        ],
      ),
    )
        .animate()
        .move(
          delay: 100.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn();
  }
}

class _Page1Text2 extends StatelessWidget {
  _Page1Text2();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'page1_s'
        .translate
        .text
        .fontSize(18)
        .color(_controller.textColor)
        .make()
        .animate()
        .move(
          delay: 140.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn();
  }
}

class _DemoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return ElevatedButton(
      child: 'req_demo'.translate.text.color(Colors.white).fontSize(18).make(),
      onPressed: () {
        _controller.pageController.animateToPage(5, duration: 500.milliseconds, curve: Curves.ease);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _controller.buttonColor,
        shape: StadiumBorder(),
        visualDensity: VisualDensity.comfortable,
      ),
    )
        .animate()
        .move(
          delay: 180.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn();
  }
}

class _ImageWidget extends StatelessWidget {
  _ImageWidget();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                Assets.website.webSiteImg1PNG,
                width: 400,
              ),
            )
                .animate()
                .move(
                  delay: 180.ms,
                  curve: Curves.easeInOutSine,
                  duration: 600.ms,
                  begin: Offset(0, 80),
                )
                .fadeIn(),
            Padding(
              padding: EdgeInsets.only(top: 300, left: 200),
              child: Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      Assets.website.t1PNG,
                      width: 36,
                      height: 36,
                    ),
                    4.widthBox,
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          'name3'.translate.text.color(_controller.textColor).bold.fontSize(10).make(),
                          'content3'.translate.text.color(_controller.textColor).fontSize(10).make(),
                        ],
                      ),
                    ),
                  ],
                ).p8,
              ).animate(delay: 750.ms).scale(curve: Curves.easeInOutSine, duration: 600.ms, alignment: Alignment.topRight).fadeIn(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 110, left: 30),
              child: Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    'notifications'.translate.toUpperCase().text.color(_controller.buttonColor).fontSize(10).bold.make(),
                    8.heightBox,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Assets.website.t3PNG,
                          width: 36,
                          height: 36,
                        ),
                        4.widthBox,
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              'name1'.translate.text.color(_controller.textColor).fontSize(10).bold.make(),
                              'content1'.translate.text.color(_controller.textColor).fontSize(10).make(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    4.heightBox,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Assets.website.t2PNG,
                          width: 36,
                          height: 36,
                        ),
                        4.widthBox,
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              'name2'.translate.text.color(_controller.textColor).fontSize(10).bold.make(),
                              'content2'.translate.text.color(_controller.textColor).fontSize(10).make(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ).p8,
              )
                  .animate(
                    delay: 750.ms,
                  )
                  .scale(curve: Curves.easeInOutSine, duration: 600.ms, alignment: Alignment.bottomLeft)
                  .fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

class WebSiteDrawer extends StatelessWidget {
  WebSiteDrawer();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();

    return Container(
      color: _controller.buttonColor,
      child: Column(
        children: AnimateList(interval: 200.ms, effects: [
          SlideEffect(begin: Offset(-0.2, 0))
        ], children: [
          Expanded(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                      _controller.pageController.animateToPage(0, duration: 300.ms, curve: Curves.ease);
                    },
                    child: Center(child: 'menu1'.translate.text.color(Colors.white).fontSize(24).make())),
                Divider(color: Colors.white, height: 1),
                TextButton(
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                      _controller.pageController.animateToPage(1, duration: 300.ms, curve: Curves.ease);
                    },
                    child: Center(child: 'menu2'.translate.text.color(Colors.white).fontSize(24).make())),
                Divider(color: Colors.white, height: 1),
                TextButton(
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                      _controller.pageController.animateToPage(2, duration: 300.ms, curve: Curves.ease);
                    },
                    child: Center(child: 'menu3'.translate.text.color(Colors.white).fontSize(24).make())),
                Divider(color: Colors.white, height: 1),
                TextButton(
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                      _controller.pageController.animateToPage(3, duration: 300.ms, curve: Curves.ease);
                    },
                    child: Center(child: 'menu4'.translate.text.color(Colors.white).fontSize(24).make())),
                Divider(color: Colors.white, height: 1),
                TextButton(
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                      _controller.pageController.animateToPage(4, duration: 300.ms, curve: Curves.ease);
                    },
                    child: Center(child: 'menu5'.translate.text.color(Colors.white).fontSize(24).make())),
              ],
            )),
          ),
          Icons.arrow_back_ios.icon.color(Colors.white).onPressed(() {
            Scaffold.of(context).closeDrawer();
          }).make(),
          64.heightBox,
        ]),
      ),
    );
  }
}
