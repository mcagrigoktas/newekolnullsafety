import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../controller.dart';
import '../widgets/divider.dart';

class WebSitePage2 extends StatelessWidget {
  WebSitePage2();
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
                PageArrowIcon(1, false),
                Expanded(
                  child: _controller.isLargeScreen(context)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            32.heightBox,
                            _Page2N1(),
                            12.heightBox,
                            WebsiteDivider(),
                            12.heightBox,
                            _Page2Text1(),
                            32.heightBox,
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 960),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: _CountContainer('students'.translate, '100k+')),
                                      48.widthBox,
                                      Expanded(child: _CountContainer('schools'.translate, '500+')),
                                      48.widthBox,
                                      Expanded(child: _SchoolsContainer()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            32.heightBox,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Page2N1(),
                            8.heightBox,
                            WebsiteDivider(),
                            8.heightBox,
                            _Page2Text1(),
                            8.heightBox,
                            Expanded(
                              child: FittedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _CountContainer('students'.translate, '100k+'),
                                    16.heightBox,
                                    _CountContainer('schools'.translate, '500+'),
                                    16.heightBox,
                                    _SchoolsContainer(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                PageArrowIcon(1, true),
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
      Align(
        alignment: _controller.isLargeScreen(context) ? Alignment(0.9, 0.9) : Alignment(1.1, 1.1),
        child: Shape3Animation(),
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

class _Page2N1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'menu2'
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

class _Page2Text1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'page2_s'
        .translate
        .text
        .center
        .fontSize(18)
        .color(_controller.textColor)
        .make()
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

class _CountContainer extends StatelessWidget {
  final String name;
  final String count;
  _CountContainer(this.name, this.count);
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Card(
      elevation: 20,
      shadowColor: _controller.backgroundColor.withOpacity(0.32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(gradient: _controller.boxgroundGradient, borderRadius: BorderRadius.circular(16)),
        width: 250,
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              count.text.color(Colors.white).fontSize(48).bold.make(),
              16.heightBox,
              name.text.color(Colors.white).fontSize(36).bold.make(),
            ],
          ),
        ),
      ),
    )
        .animate()
        .move(
          delay: 240.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn();
  }
}

class _SchoolsContainer extends StatefulWidget {
  _SchoolsContainer();

  @override
  State<_SchoolsContainer> createState() => _SchoolsContainerState();
}

class _SchoolsContainerState extends State<_SchoolsContainer> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Card(
      elevation: 20,
      shadowColor: _controller.backgroundColor.withOpacity(0.32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(gradient: _controller.boxgroundGradient, borderRadius: BorderRadius.circular(16)),
        width: 250,
        height: 250,
        child: Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withAlpha(220), borderRadius: BorderRadius.circular(16)),
          child: Center(
            key: ValueKey('Anim$count X'),
            child: MyCachedImage(
              width: 200,
              height: 200,
              fit: BoxFit.fitWidth,
              placeholder: false,
              imgUrl: 'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o/01asset%2Fwebsite_schools%2Fs' + count.toString() + '.png?alt=media',
            )
                .animate()
                .fadeIn(delay: count == 0 ? 800.ms : 0.ms, duration: 600.ms)
                .then(delay: 400.ms)
                .shimmer(duration: 1800.ms, blendMode: _controller.getBlendMode())
                .shake(hz: 4, curve: Curves.easeInOutCubic)
                .scaleXY(end: 1.1, duration: 600.ms)
                .then(delay: 1800.ms)
                .scaleXY(end: 1 / 1.1)
                .then(delay: 200.ms)
                .fadeOut(
                  duration: 600.ms,
                )
                .callback(callback: (value) {
              if (value == false && mounted) {
                setState(() {
                  count++;
                  count = count % 10;
                });
              }
            }),
          ),
        ),
      ),
    )
        .animate()
        .move(
          delay: 240.ms,
          curve: Curves.easeInOutSine,
          duration: 600.ms,
          begin: Offset(0, 80),
        )
        .fadeIn();
  }
}
