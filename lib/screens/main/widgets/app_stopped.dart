import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../loginscreen/loginscreen.dart';

class AppStoped extends StatelessWidget {
  AppStoped();
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RiveSimpeLoopAnimation.asset(
            url: Assets.rive.ekolRIV,
            artboard: 'WARNING',
            animation: 'alert',
            width: 152,
            heigth: 152,
          ),
          16.heightBox,
          (AppVar.appBloc.hesapBilgileri.gtMT ? 'accountstoped' : 'accountstopedforstudent').translate.text.color(Colors.white).fontSize(28).make(),
          16.heightBox,
          MyRaisedButton(
            onPressed: () {
              Fav.to(EkolSignInPage());
            },
            text: 'signin'.translate,
          )
        ],
      ),
    );
  }
}
