import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../../../appbloc/appvar.dart';
import '../../controller.dart';

class HereButton extends StatelessWidget {
  HereButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();

    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      return 'startrollcallhint'.translate.text.color(Colors.white).make().stadium(background: Colors.red);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyRaisedButton(
          text: 'here'.translate,
          onPressed: controller.iAmHere,
          boldText: true,
          color: Colors.green,
        ),
        if (controller.strudentIAmHereSended) 'rollcallsaved'.translate.text.make().pl8,
      ],
    );
  }
}
