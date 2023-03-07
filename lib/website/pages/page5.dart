import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../controller.dart';
import '../widgets/divider.dart';

class WebSitePage5 extends StatelessWidget {
  WebSitePage5();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return Stack(
      children: [
        ..._BackgroundItems.get(context),
        Positioned.fill(
          child: Padding(
            padding: _controller.pagePadding(context, 0, 0),
            child: Column(
              children: [
                PageArrowIcon(4, false),
                if (_controller.isLargeScreen(context)) 32.heightBox,
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Page5N1(),
                    8.heightBox,
                    WebsiteDivider(),
                    8.heightBox,
                    _Page5N2(),
                    8.heightBox,
                    Expanded(child: _Features(800)),
                  ],
                )),
                PageArrowIcon(4, true),
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
        alignment: _controller.isLargeScreen(context) ? Alignment(0.3, -0.3) : Alignment(0.0, -0.5),
        child: Shape1Animation(),
      ),
    ];
  }
}

class _Page5N1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'menu5'
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

class _Page5N2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 'p5h'
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

class _Features extends StatelessWidget {
  final int delay;
  _Features(this.delay);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: 585),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SizedBox(
                  width: 1200,
                  child: Table(
                    children: [
                      TableRow(children: [...Iterable.generate(4).map((e) => _FeaturesListTile(e + 1))]),
                      TableRow(children: [...Iterable.generate(4).map((e) => _FeaturesListTile(e + 5))]),
                      TableRow(children: [...Iterable.generate(4).map((e) => _FeaturesListTile(e + 9))]),
                    ],
                  )),
            ),
          ),
        ),
      )
          .animate()
          .move(
            delay: 160.ms,
            curve: Curves.easeInOutSine,
            duration: 600.ms,
            begin: Offset(0, 80),
          )
          .fadeIn(),
    );
  }
}

class _FeaturesListTile extends StatefulWidget {
  final int? count;

  _FeaturesListTile(this.count);

  @override
  State<_FeaturesListTile> createState() => _FeaturesListTileState();
}

class _FeaturesListTileState extends State<_FeaturesListTile> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();

    final Widget _current = SizedBox(
      height: 195,
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        shadowColor: _controller.backgroundColor.withOpacity(0.15),
        child: Container(
          decoration: BoxDecoration(gradient: _controller.boxgroundGradient, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      children: [
                        Align(
                          alignment: [Alignment.topLeft, Alignment.topRight, Alignment.bottomRight, Alignment.bottomLeft][widget.count! % 4],
                          child: CircleAvatar(
                            backgroundColor: _controller.buttonColor.withAlpha(130),
                            radius: 20,
                          ),
                        ),
                        Center(
                            child: Image.asset(
                          'assets/website/f${widget.count}.png',
                          width: 48,
                          color: Colors.white,
                        )),
                      ],
                    ),
                  ),
                  16.widthBox,
                  Flexible(child: 'f${widget.count}t'.translate.text.color(Colors.white).bold.fontSize(20).make()),
                ],
              ),
              4.heightBox,
              Expanded(child: 'f${widget.count}t1'.translate.text.color(Colors.white).autoSize.fontSize(16).make()),
            ],
          ).p12,
        ),
      ),
    );

    if (PlatformFunctions.isHtmlRenderer()) return _current;

    return MouseRegion(
      onEnter: (v) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (v) {
        setState(() {
          isHover = false;
        });
      },
      child: _current.p4.animate(target: isHover ? 1 : 0).shimmer(duration: 600.milliseconds, blendMode: _controller.getBlendMode()).flipV(end: -0.1, duration: 200.milliseconds).scaleXY(end: 1.03),
    );
  }
}
