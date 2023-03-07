// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/appfunctions.dart';
// import '../../../models/allmodel.dart';
// import '../../managerscreens/programsettings/helper.dart';
// import '../../managerscreens/programsettings/programlistmodels.dart';
// import '../../p2p/freestyle/model.dart';
// import '../../p2p/freestyle/otherscreens/p2pdetail/controller.dart';
// import '../../p2p/freestyle/otherscreens/p2pdetail/layout.dart';
// import '../../portfolio/model.dart';
// import '../lessondetail/lessondetailteacher.dart';
// import '../widgets.dart';

// class TeacherTimeTable extends StatefulWidget {
//   @override
//   _TeacherTimeTableState createState() => _TeacherTimeTableState();
// }

// class _TeacherTimeTableState extends State<TeacherTimeTable> {
//   final TimeTableSettings timeTableSettings = TimeTableSettings();
//   final times = AppVar.appBloc.schoolTimesService.dataList.last;

//   final _lessonList = TeacherFunctions.getLessonList();

//   List<ProgramItem> _programData;
//   DateTime _selectedWeekTime;
//   List<P2Pmodel> _p2pData;

//   Widget _buildWidget = SizedBox();
//   @override
//   void initState() {
//     final _sturdyProgram = ProgramHelper.getLastSturdyProgram();
//     _programData = ProgramHelper.getTeacherAllLessonFromTimeTable(AppVar.appBloc.hesapBilgileri.uid, _sturdyProgram);

//     _selectedWeekTime = Fav.readSeasonCache<DateTime>('selectedWeekTimeForTimeTable', DateTime.now());

//     _p2pData = AppVar.appBloc.portfolioService == null
//         ? []
//         : AppVar.appBloc.portfolioService.dataList
//             .where((element) {
//               if (element.portfolioType != PortfolioType.p2p) return false;
//               final model = element.data<P2Pmodel>();
//               return model.week == _selectedWeekTime.weekOfYear;
//             })
//             .map((e) => e.data<P2Pmodel>())
//             .toList();

//     if (Fav.readSeasonCache('seeListTypeTimeTable', false)) {
//       _buildWidget = Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
//         child: Wrap(
//           runSpacing: 2,
//           spacing: 2,
//           crossAxisAlignment: WrapCrossAlignment.center,
//           alignment: WrapAlignment.center,
//           children: [
//             ..._lessonList
//                 .map((lesson) => TimeTableLessonCellWidget(
//                       onTap: () {
//                         Fav.to(LessonDetailTeacher(lesson: AppVar.appBloc.lessonService.dataListItem(lesson.key), classKey: lesson.classKey));
//                       },
//                       boxColor: Color(int.tryParse('0xff${lesson.color}')),
//                       text1: AppVar.appBloc.classService.dataList.singleWhere((sinif) => sinif.key == lesson.classKey, orElse: () => Class()..name = '').name,
//                       text2: lesson.name,
//                     ))
//                 .toList()
//               ..addAll(_p2pData.map((item) {
//                 return TimeTableLessonCellWidget(
//                   onTap: () {
//                     Fav.to(P2PDetail(), binding: BindingsBuilder(() => Get.put<P2PDetailController>(P2PDetailController(item))));
//                   },
//                   boxColor: Colors.black,
//                   text1Style: const TextStyle(color: Colors.white),
//                   text1: '📖',
//                   boxShadowColor: const Color(0xff24262A).withAlpha(180),
//                 );
//               }).toList())
//           ],
//         ),
//       );
//     } else {
//       final cellWidth = timeTableSettings.cellWidth * 3 / 2;
//       final cellHeight = timeTableSettings.cellHeight;
//       const double titlePanelSize = kIsWeb ? 90 : 60;
//       const double timePanelSize = 42;

//       int maxHour;
//       int minHour;

//       List<TimePlannerTask> tasks = [];
//       _programData.forEach((e) {
//         final day = e.day;
//         final lessonNo = e.lessonNo;
//         final Lesson lesson = e.lesson;
//         final String classKey = e.lesson.classKey;
//         final lessonTimeInfo = times.getDayLessonNoTimes('$day', lessonNo - 1);

//         maxHour ??= lessonTimeInfo.max;
//         if (lessonTimeInfo.max > maxHour) maxHour = lessonTimeInfo.max;
//         minHour ??= lessonTimeInfo.min;
//         if (lessonTimeInfo.min < minHour) minHour = lessonTimeInfo.min;

//         if (lesson != null) {
//           final current = TimeTableLessonCellWidget(
//             onTap: () {
//               Fav.to(LessonDetailTeacher(lesson: AppVar.appBloc.lessonService.dataListItem(lesson.key), classKey: classKey));
//             },
//             boxColor: lesson.color.parseColor,
//             text1: AppVar.appBloc.classService.dataList.singleWhere((sinif) => sinif.key == classKey, orElse: () => Class()..name = '').name,
//             text2: lesson.name,
//             boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
//           );

//           tasks.add(TimePlannerTask(
//             dateTime: TimePlannerDateTime(day: day - 1, hour: lessonTimeInfo.first ~/ 60, minutes: lessonTimeInfo.first % 60),
//             minutesDuration: lessonTimeInfo.last - lessonTimeInfo.first,
//             daysDuration: 1,
//             child: current,
//           ));
//         }
//       });

//       _p2pData.forEach((item) {
//         final day = item.day;
//         final startTime = item.startTime;
//         final duration = item.duration;

//         maxHour ??= startTime + duration;
//         if (startTime + duration > maxHour) maxHour = startTime + duration;
//         minHour ??= startTime;
//         if (startTime < minHour) minHour = startTime;

//         final current = TimeTableLessonCellWidget(
//           onTap: () {
//             Fav.to(P2PDetail(), binding: BindingsBuilder(() => Get.put<P2PDetailController>(P2PDetailController(item))));
//           },
//           boxColor: Colors.black,
//           text1Style: const TextStyle(color: Colors.white),
//           text1: '📖',
//           boxShadowColor: const Color(0xff24262A).withAlpha(180),
//         );
//         tasks.add(TimePlannerTask(
//           dateTime: TimePlannerDateTime(day: day, hour: startTime ~/ 60, minutes: startTime % 60),
//           minutesDuration: duration,
//           daysDuration: 1,
//           child: current,
//         ));
//       });
//       _buildWidget = TimePlanner(
//         key: Key('Key$_selectedWeekTime'),
//         height: timePanelSize + 7 * cellHeight,
//         startHour: [minHour ~/ 60, times.schoolStartTime ~/ 60].max,
//         endHour: [maxHour ~/ 60, times.schoolEndTime ~/ 60].min + 1,
//         topLeftWidget: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ('week'.translate + ' ' + _selectedWeekTime.weekOfYear.toString()).text.fontSize(8).bold.color(Fav.design.primaryText).make(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icons.arrow_left.icon
//                     .color(Colors.white)
//                     .padding(0)
//                     .size(17)
//                     .onPressed(() {
//                       Fav.writeSeasonCache('selectedWeekTimeForTimeTable', _selectedWeekTime.subtract(7.days));
//                       AppVar.appBloc.tableProgramService.refresh();
//                     })
//                     .make()
//                     .circleBackground(background: Fav.design.primary)
//                     .pl2,
//                 2.widthBox,
//                 Icons.arrow_right.icon
//                     .color(Colors.white)
//                     .padding(0)
//                     .size(17)
//                     .onPressed(() {
//                       Fav.writeSeasonCache('selectedWeekTimeForTimeTable', _selectedWeekTime.add(7.days));
//                       AppVar.appBloc.tableProgramService.refresh();
//                     })
//                     .make()
//                     .circleBackground(background: Fav.design.primary)
//                     .pr2
//               ],
//             ),
//           ],
//         ),
//         style: TimePlannerStyle(
//           cellWidth: cellWidth,
//           cellHeight: cellHeight,
//           timePlannerDirection: TimePlannerDirection.horizontal,
//           titlePanelSize: titlePanelSize,
//           timePanelSize: timePanelSize,
//         ),
//         currentTimeAnimation: false,
//         headers: Iterable.generate(7, (i) => i + 1)
//             .map((e) => TimePlannerTitle(
//                   child: TimeTableLessonCellWidget(
//                     width: titlePanelSize,
//                     text1: McgFunctions.getDayNameFromDayOfWeek(e, format: 'EEE'),
//                     boxColor: Fav.design.bottomNavigationBar.background,
//                     boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
//                     text1Style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
//                   ),
//                 ))
//             .toList(),
//         tasks: tasks,
//       ).pb8;
//     }

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _buildWidget;
//   }
// }
