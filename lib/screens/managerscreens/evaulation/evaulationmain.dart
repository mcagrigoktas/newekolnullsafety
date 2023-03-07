import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../adminpages/screens/evaulationadmin/examtypes/controller.dart';
import '../../../adminpages/screens/evaulationadmin/examtypes/examtypedefine.dart';
import '../../../adminpages/screens/evaulationadmin/examtypes/model.dart';
import '../../../adminpages/screens/evaulationadmin/helper.dart';
import '../../../adminpages/screens/evaulationadmin/opticformtypes/controller.dart';
import '../../../adminpages/screens/evaulationadmin/opticformtypes/opticformdefine.dart';
import '../../../adminpages/screens/evaulationadmin/route_management.dart';

class EvaluationMain extends StatelessWidget {
  final EvaulationUserType girisTuru;
  EvaluationMain(this.girisTuru);
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'back'.translate),
      topActions: TopActionsTitle(title: "evaulationscreenname".translate),
      body: Body.singleChildScrollView(
        child: Column(
          children: <Widget>[
            8.heightBox,
            AnimatedGroupWidget(
              children: <Widget>[
                MenuButton(
                  name: "evaulationexams".translate,
                  iconData: MdiIcons.cashRegister,
                  gradient: MyPalette.getGradient(12),
                  onTap: () {
                    EvaulationMainRoutes.goExamDefinePage(girisTuru);
                  },
                ),
                MenuButton(
                  name: "opticalforms".translate,
                  iconData: MdiIcons.cashRegister,
                  gradient: MyPalette.getGradient(12),
                  onTap: showExamTypeList,
                ),
                if (girisTuru == EvaulationUserType.school)
                  MenuButton(
                    name: "examtypes".translate,
                    iconData: MdiIcons.cashRegister,
                    gradient: MyPalette.getGradient(23),
                    onTap: () {
                      Fav.to(ExamTypeDefine(), binding: BindingsBuilder(() => Get.put<ExamTypeController>(ExamTypeController(girisTuru))));
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///Bunun treeviewdede bir Kopyasi var
  Future<void> showExamTypeList() async {
    OverLoading.show();
    Get.put(ExamTypeController(girisTuru));
    await 2000.wait;
    await OverLoading.close();
    ExamTypeController controller = Get.find();

    final value = await controller.allExamType.fold<Map>({}, (p, e) => p..[e] = e.name).selectOne(title: 'examtype'.translate);
    if (value is ExamType) {
      await Fav.to(OpticFormDefine(), binding: BindingsBuilder(() => Get.put<OpticFormDefineController>(OpticFormDefineController(value, girisTuru))));
    }
  }
}
