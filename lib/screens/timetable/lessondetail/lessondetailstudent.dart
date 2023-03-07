import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/allmodel.dart';
import '../../eders/livebroadcast/broadcaststarter/broadcaststarthelper.dart';
import '../../main/menu_list_helper.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../../p2p/freestyle/otherscreens/studentrequest/controller.dart';
import '../../p2p/freestyle/otherscreens/studentrequest/layout.dart';
import '../../p2p/simple/reserve_p2p/layout.dart';
import '../homework_helper.dart';
import '../modelshw.dart';
import 'item_list.dart';

class LessonDetailStudent extends StatelessWidget {
  final Lesson? lesson;
  final String? classKey;
  LessonDetailStudent({this.lesson, this.classKey});

  @override
  Widget build(BuildContext context) {
    HomeWorkHelper.saveLastLoginTime(lesson!.key);
    final Class? sinif = AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == classKey);

    if (sinif == null) {
      return AppScaffold(
        topBar: TopBar(leadingTitle: 'back'.translate),
        body: Body.child(
          child: Center(child: Text('classnotfound'.translate)),
        ),
      );
    }

    Widget current = HomeWorkList(
      classKey: classKey,
      lessonKey: lesson!.key,
    );

    return AppScaffold(
      floatingActionButton: UserPermissionList.hasStudentCanP2PRequest() || MenuList.hasSimpleP2P()
          ? FloatingActionButton(
              mini: true,
              onPressed: () async {
                final itemMap = {0: 'requestp2p'.translate};
                final value = await itemMap.selectOne<int>(title: 'chooseprocess'.translate);
                if (value == 0) {
                  if (MenuList.hasSimpleP2P() && UserPermissionList.hasStudentRequestThenTeacherApprove() == false) {
                    await Fav.to(ReserveP2PLayout());
                  } else {
                    await Fav.guardTo(StudentRequest(), binding: BindingsBuilder(() => Get.put<StudentRequestController>(StudentRequestController(lesson))));
                  }
                }
              },
              backgroundColor: Fav.design.primary,
              child: const Icon(Icons.more_vert, color: Colors.white),
            )
          : null,
      topBar: TopBar(leadingTitle: 'mylessons'.translate, middle: sinif.name.text.bold.make(), trailingActions: [BroadcastHelper.broadcastLessonStartWidget(lesson!)]),
      topActions: TopActionsTitle(title: lesson!.longName!),
      body: Body.child(child: current),
    );
  }
}

class HomeWorkList extends StatefulWidget {
  final String? classKey;
  final String? lessonKey;
  HomeWorkList({this.classKey, this.lessonKey});

  @override
  _HomeWorkListState createState() => _HomeWorkListState();
}

class _HomeWorkListState extends State<HomeWorkList> {
  List<HomeWork> hwList = [];

  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    subscription = AppVar.appBloc.homeWorkService!.stream.listen((_) {
      getData();
    });
  }

  void getData() {
    hwList = [...AppVar.appBloc.homeWorkService!.dataList];

    hwList.removeWhere((homework) {
      if (homework.aktif == false) return true;
      if (homework.isPublish != true) return true;
      if (homework.classKey != widget.classKey) return true;
      if (homework.lessonKey != widget.lessonKey) return true;

      return false;
    });
    hwList.sort((a, b) => (b.checkDate ?? b.timeStamp) - (a.checkDate ?? a.timeStamp));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return hwList.isEmpty ? Center(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS)) : HomeworkPageItemList(hwList);
  }
}
