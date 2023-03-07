import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'examtypes/controller.dart';
import 'examtypes/examtypedefine.dart';
import 'examtypes/model.dart';
import 'helper.dart';
import 'opticformtypes/controller.dart';
import 'opticformtypes/opticformdefine.dart';

class EvaluationAdminMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'back'.translate),
      topActions: TopActionsTitle(title: "evaulationscreenname".translate),
      body: Body.singleChildScrollView(
        child: AnimatedGroupWidget(
          children: <Widget>[
            MenuButton(
              name: "Exam type define".translate,
              iconData: MdiIcons.cashRegister,
              gradient: MyPalette.getGradient(12),
              onTap: () {
                Fav.to(ExamTypeDefine(), binding: BindingsBuilder(() => Get.put<ExamTypeController>(ExamTypeController(EvaulationUserType.admin))));
              },
            ),
            MenuButton(
              name: "opticalforms".translate,
              iconData: MdiIcons.cashRegister,
              gradient: MyPalette.getGradient(13),
              onTap: showExamTypeList,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showExamTypeList() async {
    OverLoading.show();
    Get.put(ExamTypeController(EvaulationUserType.admin));
    await 2000.wait;
    await OverLoading.close();
    ExamTypeController controller = Get.find();

    final value = await controller.allExamType.fold<Map>({}, (p, e) => p..[e] = e.name).selectOne(title: 'examtype'.translate);
    if (value is ExamType) {
      await Fav.to(OpticFormDefine(), binding: BindingsBuilder(() => Get.put<OpticFormDefineController>(OpticFormDefineController(value, EvaulationUserType.admin))));
    }
  }
}
