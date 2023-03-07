import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../assets.dart';
import '../controller.dart';
import '../widgets/divider.dart';

class WebSitePage3 extends StatelessWidget {
  WebSitePage3();
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
                PageArrowIcon(2, false),
                Expanded(
                  child: _controller.isLargeScreen(context)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            32.heightBox,
                            _Page3N1(),
                            12.heightBox,
                            WebsiteDivider(),
                            12.heightBox,
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
                            _Page3N1(),
                            8.heightBox,
                            WebsiteDivider(),
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
                PageArrowIcon(2, true),
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
          child: RotatedBox(
        quarterTurns: 2,
        child: ClipPath(
          clipper: WebSiteWaveClipper(),
          child: Container(
            decoration: BoxDecoration(gradient: _controller.backgroundGradient),
          ),
        ),
      )),
      Align(
        alignment: _controller.isLargeScreen(context) ? Alignment(0.9, 0.9) : Alignment(1.1, 1.1),
        child: Shape2Animation(),
      ),
      // Align(
      //   alignment: Alignment.bottomLeft,
      //   child: Container(
      //     width: context.width / 4,
      //     height: context.screenWidth / 4,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.only(topRight: Radius.circular(context.width / 8)),
      //         gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
      //           Color(0xffF3FDF5),
      //           _controller.backgroundColor.withOpacity(0.0),
      //         ])),
      //   ),
      // ),
      // Align(
      //   alignment: Alignment.bottomRight,
      //   child: Container(
      //     width: context.width / 4,
      //     height: context.screenWidth / 4,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.only(topLeft: Radius.circular(context.width / 8)),
      //         gradient: LinearGradient(begin: Alignment.bottomRight, end: Alignment.topLeft, colors: [
      //           Color(0xffF3FDF5),
      //           _controller.backgroundColor.withOpacity(0.0),
      //         ])),
      //   ),
      // ),
    ];
  }
}

class _Page3N1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'menu3'
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

class _ImageWidget extends StatelessWidget {
  _ImageWidget();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Center(
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
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              Assets.website.s1PNG,
              fit: BoxFit.cover,
            ),
          ),
        ),
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
            children: Iterable.generate(3).map((e) => _FeaturesListTile(e + 1)).toList(),
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
            Flexible(child: 'p3t$count'.translate.text.bold.color(Colors.black).fontSize(16).make()),
          ],
        ),
        8.heightBox,
        'p3t${count}1'.translate.text.color(Colors.black).fontSize(16).make(),
      ],
    ).py8;
  }
}
