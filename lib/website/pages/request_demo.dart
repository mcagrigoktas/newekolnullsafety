import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../assets.dart';
import '../controller.dart';
import '../widgets/divider.dart';

class WebSiteDemoReqPage extends StatelessWidget {
  WebSiteDemoReqPage();
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
                PageArrowIcon(5, false),
                if (_controller.isLargeScreen(context)) 32.heightBox,
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    8.heightBox,
                    _PageN1(),
                    8.heightBox,
                    WebsiteDivider(),
                    8.heightBox,
                    'reqh1'
                        .translate
                        .text
                        .color(Colors.black)
                        .fontSize(16)
                        .make()
                        .px8
                        .animate()
                        .move(
                          delay: 180.ms,
                          curve: Curves.easeInOutSine,
                          duration: 600.ms,
                          begin: Offset(0, 80),
                        )
                        .fadeIn(),
                    8.heightBox,
                    Expanded(child: _Form()),
                    8.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Image.asset(
                            Assets.images.googlePlayPNG,
                            height: 75,
                          ),
                          onTap: () {
                            'https://play.google.com/store/apps/details?id=com.kazanim.dersprogrami'.launch(LaunchType.url);
                          },
                        ),
                        16.widthBox,
                        GestureDetector(
                          child: Image.asset(
                            Assets.images.appStorePNG,
                            height: 75,
                          ),
                          onTap: () {
                            'https://apps.apple.com/us/app/speedsis/id1672807550'.launch(LaunchType.url);
                          },
                        ),
                        16.widthBox,
                        GestureDetector(
                          child: Image.asset(
                            Assets.images.appgalleryPNG,
                            height: 75,
                          ),
                          onTap: () {
                            'https://appgallery.huawei.com/app/C107717267'.launch(LaunchType.url);
                          },
                        ),
                      ],
                    )
                        .animate()
                        .move(
                          delay: 240.ms,
                          curve: Curves.easeInOutSine,
                          duration: 600.ms,
                          begin: Offset(0, 80),
                        )
                        .fadeIn(),
                    8.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: MdiIcons.instagram.icon.size(32).color('c32aa3'.parseColor).make(),
                          onTap: () {
                            'https://www.instagram.com/speedsistech/'.launch(LaunchType.url);
                          },
                        ),
                        16.widthBox,
                        GestureDetector(
                          child: MdiIcons.twitter.icon.size(32).color('1da1f2'.parseColor).make(),
                          onTap: () {
                            'https://twitter.com/Speedsistech'.launch(LaunchType.url);
                          },
                        ),
                        16.widthBox,
                        GestureDetector(
                          child: MdiIcons.youtube.icon.size(32).color('ff0000'.parseColor).make(),
                          onTap: () {
                            'https://www.youtube.com/@speedsistech'.launch(LaunchType.url);
                          },
                        ),
                      ],
                    )
                        .animate()
                        .move(
                          delay: 240.ms,
                          curve: Curves.easeInOutSine,
                          duration: 600.ms,
                          begin: Offset(0, 80),
                        )
                        .fadeIn(),
                    8.heightBox,
                  ],
                )),
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
      Positioned(
          top: context.screenHeight / 2,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(gradient: _controller.backgroundGradient),
          )),
      Align(
        alignment: Alignment.bottomRight,
        child: Shape1Animation(),
      ),
      Align(
        alignment: Alignment.bottomLeft,
        child: Shape1Animation(),
      ),
    ];
  }
}

class _PageN1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return 'req_demo'
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

class _Form extends StatelessWidget {
  _Form();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<WebSiteController>();
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Align(alignment: Alignment.topLeft, child: 'info'.translate.text.bold.color(Colors.black).fontSize(16).make()).pl16,
                      8.heightBox,
                      MyTextFormField(
                        labelText: 'name'.translate,
                        iconData: Icons.person,
                        iconColor: Colors.black,
                      ),
                      MyTextFormField(
                        iconData: Icons.school,
                        iconColor: Colors.black,
                        labelText: 'schoolname'.translate,
                      ),
                      MyTextFormField(
                        iconData: Icons.mail,
                        iconColor: Colors.black,
                        labelText: 'mail'.translate,
                      ),
                      MyTextFormField(
                        iconData: Icons.message,
                        iconColor: Colors.black,
                        maxLines: 4,
                        labelText: 'message'.translate,
                      ),
                      ElevatedButton(
                        child: 'send'.translate.text.color(Colors.white).fontSize(18).make(),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _controller.buttonColor,
                          shape: StadiumBorder(),
                          visualDensity: VisualDensity.comfortable,
                        ),
                      ).pr16
                    ],
                  ).p16)
              .p16
              .animate()
              .move(
                delay: 180.ms,
                curve: Curves.easeInOutSine,
                duration: 600.ms,
                begin: Offset(0, 80),
              )
              .fadeIn(),
        ),
      ),
    );
  }
}
