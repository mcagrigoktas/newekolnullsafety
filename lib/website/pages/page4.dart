import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../assets.dart';
import '../controller.dart';
import '../widgets/divider.dart';

class WebSitePage4 extends StatelessWidget {
  WebSitePage4();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Stack(
      children: [
        ..._BackgroundItems.get(context),
        Positioned.fill(
          child: Padding(
            padding: _controller.pagePadding(context, 0),
            child: Column(
              children: [
                PageArrowIcon(3, false),
                Expanded(
                  child: _controller.isLargeScreen(context)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            16.heightBox,
                            _Page4N1(),
                            12.heightBox,
                            WebsiteDivider(),
                            12.heightBox,
                            _Page4N2(),
                            _Page4N3(),
                            24.heightBox,
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: _ImageWidget()),
                                  32.widthBox,
                                  Expanded(child: _Features(800)),
                                ],
                              ),
                            ),
                            32.heightBox,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Page4N1(),
                            8.heightBox,
                            WebsiteDivider(),
                            8.heightBox,
                            _Page4N2(),
                            _Page4N3(),
                            8.heightBox,
                            Expanded(
                              child: PageView(
                                controller: PageController(viewportFraction: 0.8),
                                children: [SizedBox(width: context.width / 2, child: _ImageWidget()), _Features(100)],
                              ),
                            ),
                          ],
                        ),
                ),
                PageArrowIcon(3, true),
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
          child: ClipPath(
        clipper: WebSiteWaveClipper(),
        child: Container(
          decoration: BoxDecoration(gradient: _controller.backgroundGradient),
        ),
      )),
      Align(
        alignment: _controller.isLargeScreen(context) ? Alignment(0.3, -0.3) : Alignment(0.0, -0.5),
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

class _Page4N1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'menu4'
        .translate
        .text
        .bold
        .fontSize(36)
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

class _Page4N2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 'p4h2'
        .translate
        .text
        .color(Colors.black)
        .fontSize(22)
        .center
        .bold
        .make()
        .animate()
        .move(
          delay: 140.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn()
        .px8;
  }
}

class _Page4N3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 'p4h1'
        .translate
        .text
        .center
        .color(Colors.black)
        .fontSize(16)
        .make()
        .animate()
        .move(
          delay: 140.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn()
        .px8;
  }
}

class _ImageWidget extends StatelessWidget {
  _ImageWidget();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Center(
      child: Stack(
        children: [
          Transform.scale(
              scale: 0.95,
              alignment: Alignment.bottomLeft,
              child: Transform.rotate(
                  alignment: Alignment.bottomLeft,
                  angle: -pi / 10,
                  child: AspectRatio(
                    aspectRatio: 1080 / 2280,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.black87,
                          width: 8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          Assets.website.s2PNG,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ))),
          AspectRatio(
            aspectRatio: 1080 / 2280,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.black87,
                  width: 8,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  Assets.website.s3PNG,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      )
          .animate()
          .move(
            delay: 180.ms,
            curve: Curves.easeInOutSine,
            duration: 600.ms,
            begin: Offset(0, 80),
          )
          .fadeIn()
          .shimmer(delay: 4000.ms, duration: 1000.ms, blendMode: _controller.getBlendMode()),
    );
  }
}

class _Features extends StatelessWidget {
  final int delay;
  _Features(this.delay);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AnimateList(
            effects: [ThenEffect(delay: delay.milliseconds), SlideEffect(duration: 500.milliseconds, begin: Offset(0, 1.1)), FadeEffect(duration: 500.milliseconds)],
            interval: 300.milliseconds,
            children: [
              ...Iterable.generate(5).map((e) => _FeaturesListTile(e + 1)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturesListTile extends StatelessWidget {
  final int? count;

  _FeaturesListTile(this.count);
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: _controller.buttonColor, radius: 8),
            12.widthBox,
            Flexible(child: 'p4t$count'.translate.text.bold.color(Colors.black).fontSize(16).make()),
          ],
        ),
        4.heightBox,
        'p4t${count}1'.translate.text.color(Colors.black).fontSize(16).make(),
      ],
    ).py8;
  }
}
