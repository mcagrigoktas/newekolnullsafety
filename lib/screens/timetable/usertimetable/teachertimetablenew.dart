import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../managerscreens/programsettings/helper.dart';
import '../../managerscreens/programsettings/programlistmodels.dart';
import '../lessondetail/lessondetailteacher.dart';
import '../rehberlikwidget.dart';
import '../widgets.dart';

class TeacherTimeTableNew extends StatefulWidget {
  @override
  State<TeacherTimeTableNew> createState() => _TeacherTimeTableNewState();
}

class _TeacherTimeTableNewState extends State<TeacherTimeTableNew> {
  final TimeTableSettings timeTableSettings = TimeTableSettings();
  final times = AppVar.appBloc.schoolTimesService!.dataList.last;
  final _lessonList = TeacherFunctions.getLessonList();
  late List<ProgramItem> _programData;

  Widget _currentWidget = SizedBox();

  @override
  void initState() {
    setupWidget();
    super.initState();
  }

  void setupWidget() {
    final _sturdyProgram = ProgramHelper.getLastSturdyProgram();
    _programData = ProgramHelper.getTeacherAllLessonFromTimeTable(AppVar.appBloc.hesapBilgileri.uid, _sturdyProgram);

    if (_programData.isEmpty || Fav.readSeasonCache('seeListTypeTimeTable', false)!) {
      _currentWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Wrap(
          runSpacing: 2,
          spacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: _lessonList
              .map<Widget>((lesson) => TimeTableLessonCellWidget(
                    onTap: () {
                      Fav.to(LessonDetailTeacher(lesson: AppVar.appBloc.lessonService!.dataListItem(lesson.key), classKey: lesson.classKey));
                    },
                    boxColor: lesson.color.parseColor,
                    text1: AppVar.appBloc.classService!.dataListItem(lesson.classKey!)?.name ?? '',
                    text2: lesson.name,
                    boxShadowColor: const Color(0xff24262A).withAlpha(180),
                  ))
              .toList()
            ..add(RehberlikWidget()),
        ),
      );
      return;
    }

    //? Derslerin olmadigi gunlerin kaldirilmasi icin bu kod gerekli
    final Set<int?> activeDays = {1, 2, 3, 4, 5};
    _programData.forEach((_programItem) {
      activeDays.add(_programItem.day);
    });

    _currentWidget = Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (activeDays.any((value) => [1, 2, 3, 4, 5].contains(value)))
              Row(children: <Widget>[
                TimeTableLessonCellWidget(
                  width: 50,
                  height: 30,
                ),
                for (var i = 1; i < times.getWeekDaysLessonCountForUse! + 1; i++)
                  TimeTableLessonCellWidget(
                    width: 50,
                    height: 30,
                    boxColor: Fav.design.bottomNavigationBar.background,
                    boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    text1: '$i',
                    text2: times.getDayLessonNoTimes('1', i - 1).first!.timeToString,
                    text1Style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                    text2Style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
                    autoFitChild: true,
                  ),

//
              ]),
            ...[1, 2, 3, 4, 5].where((day) => activeDays.contains(day)).map((day) {
              final dayName = McgFunctions.getDayNameFromDayOfWeek(day, format: 'EEE');
              return Row(
                children: <Widget>[
                  TimeTableLessonCellWidget(
                    width: 50,
                    height: 30,
                    text1: dayName,
                    boxColor: Fav.design.bottomNavigationBar.background,
                    boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    text1Style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                  ),

//
                  for (var i = 1; i < times.getWeekDaysLessonCountForUse! + 1; i++) getCell(day, i)
                ],
              );
            }).toList(),
            if (activeDays.any((value) => value == 6 || value == 7))
              Row(children: <Widget>[
                TimeTableLessonCellWidget(
                  width: 50,
                  height: 30,
                ),
                for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekEndLessonCountForUse! + 1; i++)
                  TimeTableLessonCellWidget(
                    width: 50,
                    height: 30,
                    boxColor: Fav.design.bottomNavigationBar.background,
                    boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    text1: '$i',
                    text2: times.getDayLessonNoTimes('6', i - 1).first!.timeToString,
                    text1Style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                    text2Style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
                    autoFitChild: true,
                  ),
              ]).pt4,
            ...[6, 7].where((day) => activeDays.contains(day)).map((day) {
              final dayName = McgFunctions.getDayNameFromDayOfWeek(day, format: 'EEE');
              return Row(
                children: <Widget>[
                  TimeTableLessonCellWidget(
                    width: 50,
                    height: 30,
                    text1: dayName,
                    boxColor: Fav.design.bottomNavigationBar.background,
                    boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
                    text1Style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                  ),
                  for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekEndLessonCountForUse! + 1; i++) getCell(day, i)
                ],
              );
            }).toList(),
            4.heightBox,
            RehberlikWidget(),
            'timetablesh'.translate.text.maxLines(1).color(Fav.design.primaryText.withAlpha(100)).fontSize(9).autoSize.make().pl8,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _currentWidget;
  }

  Widget getCell(int day, int lessonNo) {
    var item = _programData.firstWhereOrNull((element) => element.day == day && element.lessonNo == lessonNo);

    return TimeTableLessonCellWidget(
      width: 50,
      height: 30,
      child: item == null
          ? SizedBox()
          : RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(text: AppVar.appBloc.classService!.dataListItem(item.lesson!.classKey!)?.name ?? '', style: TextStyle(color: Colors.white, fontSize: 14)),
                TextSpan(text: '\n' + item.lesson!.name, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ]),
            ),
      onTap: item == null
          ? null
          : () {
              Fav.to(LessonDetailTeacher(lesson: item.lesson, classKey: item.lesson!.classKey));
            },
      boxColor: item == null ? Fav.design.bottomNavigationBar.background : item.lesson!.color.parseColor,
      boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
    );
  }
}
