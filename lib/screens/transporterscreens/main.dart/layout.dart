import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../main/widgets/user_profile_widget/user_profile_image.dart';
import 'controller.dart';

class TransporterMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: TransporterMainController(),
        builder: (dynamic controller) {
          if (controller.logoGosterilecek) return Container(color: Fav.design.scaffold.background);

          return AppScaffold(
              topBar: TopBar.oneChild(
                  child: Row(
                children: [
                  16.widthBox,
                  Expanded(child: UserProfileImage()),
                  _SchoolInfoWidget(),
                  16.widthBox,
                ],
              )),
              body: Body.child(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RiveSimpeLoopAnimation.asset(
                    url: Assets.rive.ekolRIV,
                    artboard: 'SCHOOL_BUS',
                    animation: 'drive',
                    width: 250,
                    heigth: 170,
                    changeChildColorMap: {
                      'line_strokes': Fav.design.primaryText.withOpacity(0.6),
                      'front_tire_shape': Fav.design.primaryText.withOpacity(0.6),
                      'back_tire_shape': Fav.design.primaryText.withOpacity(0.6),
                    },
                  ),
                  48.heightBox,
                  SizedBox(
                    width: 320,
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          color: Fav.design.others['scaffold.background'],
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Fav.design.primary,
                              ),
                              borderRadius: BorderRadius.circular(4)),
                          child: Column(
                            children: [
                              320.widthBox,
                              (DateTime.now().dateFormat()).translate.text.bold.fontSize(20).color(Fav.design.primary).make(),
                            ],
                          ).py2,
                        ),
                        4.heightBox,
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.startBusRide(1);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Fav.design.primary, fixedSize: Size(200, 96)),
                                child: FittedBox(
                                    child: Column(
                                  children: [
                                    ('busridetype1'.translate).text.fontSize(24).bold.color(Colors.white).make(),
                                    ('startbusride'.translate).text.fontSize(16).color(Colors.white).make(),
                                  ],
                                )),
                              ),
                            ),
                            4.widthBox,
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.startBusRide(2);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Fav.design.primary, fixedSize: Size(200, 96)),
                                child: FittedBox(
                                    child: Column(
                                  children: [
                                    ('busridetype2'.translate).text.fontSize(24).bold.color(Colors.white).make(),
                                    ('startbusride'.translate).text.fontSize(16).color(Colors.white).make(),
                                  ],
                                )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  32.heightBox,
                  MyFlatButton(
                    onPressed: controller.showExistingBusRide,
                    text: 'pastbusride'.translate,
                    boldText: true,
                  )
                ],
              )));
        });
  }
}

class _SchoolInfoWidget extends StatelessWidget {
  _SchoolInfoWidget();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (context.screenWidth > 600)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (AppVar.appBloc.schoolInfoService!.singleData?.name ?? '').text.fontSize(14).color(Fav.design.primaryText).bold.make(),
              (AppVar.appBloc.schoolInfoService!.singleData?.slogan ?? '').text.fontSize(12).color(Fav.design.primaryText).make(),
            ],
          ).pr8,
        CircularProfileAvatar(backgroundColor: Colors.white, imageUrl: AppVar.appBloc.schoolInfoService!.singleData!.logoUrl, radius: 18, borderWidth: 1, elevation: 2),
      ],
    );
  }
}
