import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import 'controller.dart';
import 'layout.student_list_widget.dart';
import 'layout.student_request_list_widget.dart';
import 'layout.teacher_list_widget.dart';
import 'layout.timetable_widget.dart';
import 'otherscreens/limitations/controller.dart';
import 'otherscreens/limitations/layout.dart';

class P2PMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (AppVar.appBloc.schoolTimesService?.dataList == null || AppVar.appBloc.schoolTimesService!.dataList.isEmpty) {
      return AppScaffold(
          topBar: TopBar(leadingTitle: 'menu1'.translate),
          body: Body.child(
              child: EmptyState(
            text: 'schooltimeswarning'.translate,
          )));
    }
    return GetBuilder<P2PController>(
        init: P2PController(),
        builder: (controller) {
          return AppScaffold(
              topBar: TopBar(
                middle: 'p2pmenuname'.translate.text.color(Fav.design.primary).bold.make(),
                leadingTitle: 'menu1'.translate,
                trailingActions: [
                  Tooltip(message: 'studentrequesttext1'.translate, child: Icons.collections_bookmark_outlined.icon.color(controller.isRequestHourHideble ? Fav.design.appBar.text : Fav.design.appBar.text.withAlpha(130)).onPressed(controller.toggleRequestClickable).make()),
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 0, child: Text('teacherlimitations'.translate)),
                        if (UserPermissionList.hasStudentCanP2PRequest() == true) PopupMenuItem(value: 1, child: Text('openstudentrequest'.translate)),
                      ];
                    },
                    child: Container(margin: const EdgeInsets.only(left: 16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.customDesign4.primary), child: const Icon(Icons.more_vert, color: Colors.white)),
                    onSelected: (value) async {
                      if (value == 0) {
                        final result = await Fav.guardTo(P2PLimitations(), binding: BindingsBuilder(() => Get.put<P2PLimitationsController>(P2PLimitationsController())));
                        if (result != null) {
                          controller.teacherLimitations = result;
                          controller.setupEventList();
                        }
                      } else if (value == 1) {
                        controller.isStudentRequestMenuOpen = !controller.isStudentRequestMenuOpen;
                        controller.update();
                      }
                    },
                  )
                ],
              ),
              body: Body.child(
                withKeyboardCloserGesture: true,
                child: Center(
                  child: context.screenWidth < 600
                      ? Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(child: P2PStudentList()),
                                  if (controller.isStudentRequestMenuOpen) Expanded(child: StudentRequestList()),
                                  Expanded(child: P2PTeacherList()),
                                ],
                              ),
                            ),
                            Expanded(child: Agenda()),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            if (controller.isStudentRequestMenuOpen) SizedBox(width: controller.studentRequestMenuWidth, child: StudentRequestList()),
                            SizedBox(width: controller.teacherStudentListWidth, child: P2PStudentList()),
                            Expanded(child: Agenda()),
                            SizedBox(width: controller.teacherStudentListWidth, child: P2PTeacherList()),
                          ],
                        ),
                ),
              ));
        });
  }
}
