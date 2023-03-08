import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../eders/livebroadcast/broadcaststarter/broadcaststarthelper.dart';
import '../../eders/livebroadcast/makeprogram/makeremotelessonprogram.dart';
import '../../managerscreens/programsettings/route_managament.dart';
import '../../rollcall/ekolrollcallteacher.dart';
import '../homework_helper.dart';
import '../modelshw.dart';
import 'addhomework.dart';
import 'item_list.dart';

class LessonDetailTeacher extends StatefulWidget {
  final Lesson? lesson;
  final String? classKey;
  final String? previousMenuName;
  LessonDetailTeacher({this.lesson, this.classKey, this.previousMenuName});

  @override
  State<LessonDetailTeacher> createState() => _LessonDetailTeacherState();
}

class _LessonDetailTeacherState extends State<LessonDetailTeacher> {
  Future<void> add(Class sinif) async {
    var value = await OverBottomSheet.show(BottomSheetPanel.simpleGroup(title: 'chooseprocess'.translate, groups: [
      BottomSheetGroup(
        items: [
          BottomSheetItem(name: 'makerollcall'.translate, value: 0, icon: Icons.assignment_ind),
        ],
      ),
      BottomSheetGroup(
        items: [
          BottomSheetItem(name: 'addhomework'.translate, value: 1, icon: Icons.work),
          BottomSheetItem(name: 'addexamtime'.translate, value: 2, icon: Icons.assignment),
          BottomSheetItem(name: 'addlessonnote'.translate, value: 3, icon: Icons.note_add),
        ],
      ),
      BottomSheetGroup(
        items: [
          BottomSheetItem(name: 'addremotelesson'.translate, value: 4, icon: Icons.settings_remote),
        ],
      ),
      BottomSheetGroup(
        items: [
          BottomSheetItem(name: (sinif.name) + ' ' + 'weeklytimetable'.translate, value: 5, icon: Icons.table_chart_sharp),
        ],
      ),
    ]));
    // log(_value);

    if (value == 1) {
      await Fav.to(AddHomeWork(sinif: sinif, lesson: widget.lesson, tur: 1));
    }
    if (value == 2) {
      await Fav.to(AddHomeWork(sinif: sinif, lesson: widget.lesson, tur: 2));
    }
    if (value == 3) {
      await Fav.to(AddHomeWork(sinif: sinif, lesson: widget.lesson, tur: 3));
    }
    if (value == 4) {
      var result = await Fav.to(MakeRemoteLessonProgram(lesson: widget.lesson));
      if (result == true) {
        Get.back();
        OverAlert.saveSuc();
      }
    }
    if (value == 0) {
      await Fav.to(EkolRollCallTeacher(sinif: sinif, lesson: widget.lesson));
    }
    if (value == 5) {
      await TimeTablesMainRoutes.goClassProgram(initialItem: sinif);
    }
  }

  List<HomeWork> hwList = [];
  void getData(List<HomeWork> data) {
    hwList = [...data];
    // data?.forEach((key, value) {
    //   hwList.add(HomeWork.fromJson(value, key));
    // });
    hwList.removeWhere((homework) {
      if (homework.aktif == false) return true;

      if (homework.classKey != widget.classKey) return true;

      if (homework.lessonKey != widget.lesson!.key) return true;

      return false;
    });
    hwList.sort((a, b) => (b.checkDate ?? b.timeStamp) - (a.checkDate ?? a.timeStamp));
    if (mounted) setState(() {});
  }

  StreamSubscription? subscription;
  MiniFetcher<HomeWork>? _fetcher;

  ///Idareci surekli girip cikmasin diye yavaslatma koydum
  bool delayTimeFinished = AppVar.appBloc.hesapBilgileri.gtT;

  @override
  void initState() {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      subscription = AppVar.appBloc.homeWorkService!.stream.listen((_) {
        getData(AppVar.appBloc.homeWorkService!.dataList);
      });
    } else if (AppVar.appBloc.hesapBilgileri.gtM) {
      final _techerKey = widget.lesson!.teacher!;
      final _teacher = AppVar.appBloc.teacherService!.dataListItem(_techerKey);
      if (_teacher != null) {
        _fetcher = MiniFetcher<HomeWork>(
          '${AppVar.appBloc.hesapBilgileri.kurumID}$_techerKey${AppVar.appBloc.hesapBilgileri.termKey}HomeWork',
          FetchType.LISTEN,
          queryRef: HomeWorkService.dbUserHomeWorkRef(_techerKey),
          jsonParse: (key, value) => HomeWork.fromJson(value, key),
          maxCount: 1000,
          multipleData: true,
          removeFunction: (a) => a.teacherKey == null,
          lastUpdateKey: 'timeStamp',
        );
        subscription = _fetcher!.stream.listen((event) {
          getData(_fetcher!.dataList);
        });
        Future.delayed(
          (5000.random).milliseconds,
          () {
            if (mounted)
              setState(() {
                delayTimeFinished = true;
              });
          },
        );
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    HomeWorkHelper.saveLastLoginTime(widget.lesson!.key);
    subscription?.cancel();
    _fetcher?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Class? sinif = AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == widget.classKey);

    if (sinif == null || subscription == null) {
      return AppScaffold(
        topBar: TopBar(leadingTitle: widget.previousMenuName ?? 'back'.translate),
        body: Body.child(
            child: Center(
                child: Text(
          sinif == null ? 'classnotfound'.translate : 'teachernotfound'.translate,
          style: TextStyle(color: Fav.design.primaryText),
        ))),
      );
    }

    if (delayTimeFinished == false && AppVar.appBloc.hesapBilgileri.gtM) {
      return AppScaffold(topBar: TopBar(leadingTitle: widget.previousMenuName ?? 'back'.translate), body: Body.circularProgressIndicator());
    }

    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        mini: false,
        onPressed: () {
          add(sinif);
        },
        backgroundColor: Fav.design.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      topBar: TopBar(middle: sinif.name.text.bold.make(), leadingTitle: widget.previousMenuName ?? 'back'.translate, trailingActions: [BroadcastHelper.broadcastLessonStartWidget(widget.lesson!)]),
      topActions: TopActionsTitle(title: widget.lesson!.longName!),
      body: Body.child(child: HomeWorkList(hwList: hwList)),
    );
  }
}

class HomeWorkList extends StatelessWidget {
  final List<HomeWork>? hwList;
  HomeWorkList({this.hwList});

  @override
  Widget build(BuildContext context) {
    return hwList!.isEmpty ? Center(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS)) : HomeworkPageItemList(hwList);
  }
}
