import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../programlistmodels.dart';
import 'controller.dart';

class TimeTable extends StatelessWidget {
  final _controller = Get.find<TimaTableEditController>();

  @override
  Widget build(BuildContext context) {
    final _filteredClassList = _controller.classList.where((sinif) => _controller.timeTableSettings.visibleClass!.contains(sinif.key)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _TopBar(
          timeTableSettings: _controller.timeTableSettings,
          controller: _controller.scrollControllerTopBar,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AbsorbPointer(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    controller: _controller.scrollControllerLeft,
                    child: Column(
                      children: <Widget>[
                        ..._filteredClassList
                            .map((sinif) => _ClassProgramNames(
                                  timeTableSettings: _controller.timeTableSettings,
                                  sinif: sinif,
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      controller: _controller.scrollControllerBottom,
                      child: SizedBox(
                        width: _controller.timeTableSettings.visibleDays!.fold<double>(0.0, ((previousValue, element) => previousValue + ((_controller.timeTableSettings.cellWidth + 2) * _controller.timesModel!.getDayLessonCount(element)!))),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.vertical,
                          controller: _controller.scrollControllerRigth,
                          itemCount: _filteredClassList.length,
                          itemBuilder: (context, index) {
                            var sinif = _filteredClassList[index];
                            return _ClassProgram(
                              timeTableSettings: _controller.timeTableSettings,
                              sinif: sinif,
                              programData: _controller.programData,
                            );
                          },
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final TimeTableSettings? timeTableSettings;
  final ScrollController? controller;
  _TopBar({this.timeTableSettings, this.controller});

  final _controller = Get.find<TimaTableEditController>();
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Padding(
        padding: EdgeInsets.only(left: timeTableSettings!.classNameWidth + 2),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DayNames(
                timeTableSettings: timeTableSettings,
                timesModel: _controller.timesModel,
              ),
              _LessonHours(
                timeTableSettings: timeTableSettings,
                timesModel: _controller.timesModel,
              ),
              _LessonNumbers(
                timeTableSettings: timeTableSettings,
                timesModel: _controller.timesModel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonHours extends StatelessWidget {
  final TimeTableSettings? timeTableSettings;
  final TimesModel? timesModel;
  _LessonHours({this.timeTableSettings, this.timesModel});

  String _timeToString(int? value) => value == null ? '' : value.timeToString;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ...timeTableSettings!.visibleDays!.map((day) => Row(
              children: Iterable.generate(timesModel!.getDayLessonCount(day)!)
                  .map((lessonNo) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Fav.design.scaffold.accentBackground,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Fav.design.primaryText.withAlpha(20)),
                          //          boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)],
                        ),
                        width: timeTableSettings!.cellWidth,
                        height: timeTableSettings!.lessonNumberHeight,
                        margin: const EdgeInsets.all(1),
                        child: Text(
                          _timeToString(timesModel!.getDayLessonNoTimes(day, lessonNo).first),
                          //  '${timeToString((int.tryParse(day) > 5 ? timesModel.weekendsLessonTimes : timesModel.weekdaysLessonTimes)[lessonNo].first ?? 0)}',
                          style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
                        ),
                      ))
                  .toList(),
            ))
      ],
    );
  }
}

class _LessonNumbers extends StatelessWidget {
  final TimeTableSettings? timeTableSettings;
  final TimesModel? timesModel;
  _LessonNumbers({this.timeTableSettings, this.timesModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ...timeTableSettings!.visibleDays!.map((day) {
          return Row(
            children: Iterable.generate(timesModel!.getDayLessonCount(day)!)
                .map((lessonNo) => Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Fav.design.scaffold.accentBackground,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: Fav.design.primaryText.withAlpha(20)),
                        //                 boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)],
                      ),
                      width: timeTableSettings!.cellWidth,
                      height: timeTableSettings!.lessonNumberHeight,
                      margin: const EdgeInsets.all(1),
                      child: Text(
                        '${lessonNo + 1}',
                        style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
                      ),
                    ))
                .toList(),
          );
        })
      ],
    );
  }
}

class _DayNames extends StatelessWidget {
  final TimeTableSettings? timeTableSettings;
  final TimesModel? timesModel;
  _DayNames({this.timeTableSettings, this.timesModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ...timeTableSettings!.visibleDays!.map((day) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Fav.design.scaffold.accentBackground,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Fav.design.primaryText.withAlpha(20)),
              ),
              width: (timeTableSettings!.cellWidth + 2) * timesModel!.getDayLessonCount(day)! - 2.0,
              height: timeTableSettings!.cellHeight,
              margin: const EdgeInsets.all(1),
              child: Text(
                DateTime(2019, 7, int.tryParse(day)!).dateFormat('EEEE'),
                style: TextStyle(color: Fav.design.primaryText),
              ),
            ))
      ],
    );
  }
}

class _ClassProgram extends StatelessWidget {
  final TimeTableSettings? timeTableSettings;
  final Class? sinif;
  final Map? programData;

  final _controller = Get.find<TimaTableEditController>();
  _ClassProgram({this.timeTableSettings, this.sinif, this.programData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ...timeTableSettings!.visibleDays!.map((day) => Row(
              children: Iterable.generate(_controller.timesModel!.getDayLessonCount(day)!).map(
                (lessonNo) {
                  final gestureKey = GlobalKey();
                  final _data = ((_controller.caches[(programData![sinif!.key] ?? {})['$day-${lessonNo + 1}']]) ?? {});
                  final lessonName = _data['lessonName'] ?? '';
                  return GestureDetector(
                    key: gestureKey,
                    onTap: () {
                      _controller.boxOnSelect(context, day, lessonNo, gestureKey, sinif!);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: timeTableSettings!.boxColorIsTeacher
                            ? (_data['teacherColor'] ?? (AppVar.appBloc.hesapBilgileri.isEkid ? const Color(0xfff3f3f3) : const Color(0xff24262A)))
                            : (_data['lessonColor'] ?? (AppVar.appBloc.hesapBilgileri.isEkid ? const Color(0xfff3f3f3) : const Color(0xff24262A))),
                        borderRadius: BorderRadius.circular(4.0),
                        //         boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)],
                      ),
                      width: timeTableSettings!.cellWidth,
                      height: timeTableSettings!.cellHeight,
                      margin: const EdgeInsets.all(1),
                      child: lessonName == null
                          ? null
                          : Text(
                              lessonName,
                              style: TextStyle(color: AppVar.appBloc.hesapBilgileri.isEkid ? Colors.white : Fav.design.primaryText),
                            ),
                    ),
                  );
                },
              ).toList(),
            ))
      ],
    );
  }
}

class _ClassProgramNames extends StatelessWidget {
  final TimeTableSettings? timeTableSettings;
  final Class? sinif;

  _ClassProgramNames({
    this.timeTableSettings,
    this.sinif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Fav.design.scaffold.accentBackground,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Fav.design.primaryText.withAlpha(20)),
        //   boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)],
      ),
      width: timeTableSettings!.classNameWidth,
      height: timeTableSettings!.cellHeight,
      margin: const EdgeInsets.all(1),
      child: Text(
        sinif!.name.length > 5 ? sinif!.name.substring(0, 5) : sinif!.name,
        style: TextStyle(color: Fav.design.primaryText),
      ),
    );
  }
}
