//import 'package:elseifekol/appbloc/appvar.dart';
//import 'package:elseifekol/models/allmodel.dart';
//import 'package:elseifekol/screens/managerscreens/programsettings/programlistmodels.dart';
//import 'package:elseifekol/screens/managerscreens/programsettings/timetables/timetable.dart';
//import 'package:flutter/material.dart';
//
//
//import 'package:mypackage/mywidgets.dart';
//import 'package:rxdart/subjects.dart';
//import 'package:intl/intl.dart';
//
//
//class EkidTimeTablesMain extends StatefulWidget {
//  final AppBloc appBloc;
//  EkidTimeTablesMain({this.appBloc});
//
//  @override
//  _EkidTimeTablesMainState createState() =>   _EkidTimeTablesMainState();
//}
//
//class _EkidTimeTablesMainState extends State<EkidTimeTablesMain>  {
//  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
//  TimeTableSettings timeTableSettings = TimeTableSettings();
//
//  Stream<bool> get stream => _timeTableRefresh.stream;
//  final BehaviorSubject<bool> _timeTableRefresh = BehaviorSubject<bool>.seeded(false);
//  timeTableRefreshSink() {
//    _timeTableRefresh.sink.add(true);
//  }
//
//  Map data = {};
//  Map caches = {};
//
//  bool isControl = true;
//  @override
//  void initState() {
//    super.initState();
//
//    Future.delayed(Duration.zero).then((_) {
//      if (AppVar.appBloc.schoolTimesService?.singleData == null) {
//        Get.back();
//        OverAlert.show(type: AlertType.danger, context: context, text:  'schooltimeswarning'));
//      } else {
//        //todo burda calisma saatleri ekol icin kaldirilabilir mi?
//        final bool isNotSturdy = AppVar.appBloc.hesapBilgileri.isEkid
//            ? ((AppVar.appBloc.classService.dataList?.length ?? 0) == 0 || (AppVar.appBloc.lessonService.dataList?.length ?? 0) == 0 || (AppVar.appBloc.teacherService.dataList?.length ?? 0) == 0)
//            : ((AppVar.appBloc.classService.dataList?.length ?? 0) == 0 || (AppVar.appBloc.lessonService.dataList?.length ?? 0) == 0 || (AppVar.appBloc.teacherService.dataList?.length ?? 0) == 0 || AppVar.appBloc.teacherHoursService.data == null || AppVar.appBloc.classHoursService.data == null);
//
//        if (isNotSturdy) {
//          Get.back();
//          OverAlert.show(type: AlertType.danger, context: context, text:  'timetablewarning1'));
//        } else {
//          GetDataService.dbGetTimetableProgram('Taslak1').once().then((snap) {
//            if (snap.value != null) {
//              this.data = snap.value;
//
//              // Eger gun yada saat acik degilse o saat ve gundeki yazilmis dersleri kaldirir
//              data.forEach((classKey, classProgram) {
//                var mustDelete = [];
//                (classProgram as Map).keys.forEach((timeKey) {
//                  final day = (timeKey as String).split('-').first;
//                  final hour = (timeKey as String).split('-').last;
//                  if (!AppVar.appBloc.schoolTimesService.singleData.activeDays.contains(day)) {
//                    mustDelete.add(timeKey);
//                  } else if ((day == '6' || day == '7') && AppVar.appBloc.schoolTimesService.singleData.weekendLessonCount < int.tryParse(hour)) {
//                    mustDelete.add(timeKey);
//                  } else if ((day == '1' || day == '2' || day == '3' || day == '4' || day == '5') && AppVar.appBloc.schoolTimesService.singleData.weekdaysLessonCount < int.tryParse(hour)) {
//                    mustDelete.add(timeKey);
//                  }
//                });
//                mustDelete.forEach((key) {
//                  classProgram.remove(key);
//                });
//              });
//            }
//            setState(() {
//              timeTableSettings.visibleDays = List<String>.from(AppVar.appBloc.schoolTimesService.singleData.activeDays)..sort((a, b) => a.compareTo(b));
//              timeTableSettings.visibleClass = AppVar.appBloc.classService.dataList.map((sinif) => sinif.key).toList();
//              isControl = false;
//              AppVar.appBloc.lessonService.dataList.forEach((lesson) {
//                Map lessonCaches = {};
//                lessonCaches['lessonColor'] = Color(int.tryParse('0xff${lesson.color ?? "24262A"}'));
//                lessonCaches['lessonName'] = lesson.name;
//                Teacher teacher = AppVar.appBloc.teacherService.dataList.singleWhere((teacher) => teacher.key == lesson.teacher, orElse: () => null);
//                if (teacher == null) {
//                  lessonCaches['teacherColor'] = Color(int.tryParse('0xff24262A'));
//                } else {
//                  lessonCaches['teacherColor'] = Color(int.tryParse('0xff${teacher.color ?? "24262A"}'));
//                  lessonCaches['teacherKey'] = teacher.key;
//                }
//                caches[lesson.key] = lessonCaches;
//              });
//            });
//          });
//        }
//      }
//    });
//  }
//
//  @override
//  void dispose() {
//    _timeTableRefresh.close();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: scaffoldKey,
//      backgroundColor:  Fav.design.scaffold.background,
//      endDrawer: Drawer(
//        child: DrawerWidget(
//          appBloc: AppVar.appBloc,
//          timeTableRefreshSink: timeTableRefreshSink,
//          timeTableSettings: timeTableSettings,
//          data: data,
//        ),
//      ),
//      body: StreamBuilder<Object>(
//          stream: stream,
//          builder: (context, snapshot) {
//            return Column(
//              children: <Widget>[
//                MyAppBar(
//                  title:  'timetables'),
//                  visibleBackButton: true,
//                  trailingWidgets: <Widget>[
//                    IconButton(
//                      icon: Icon(
//                        Icons.menu,
//                        color: Colors.white,
//                      ),
//                      onPressed: () {
//                        scaffoldKey.currentState.openEndDrawer();
//                      },
//                    )
//                  ],
//                ),
//                isControl
//                    ? Expanded(
//                        child: MyProgressIndicator(
//                        isCentered: true,
//                      ))
//                    : Expanded(
//                        child: TimeTable(appBloc: AppVar.appBloc, timeTableSettings: timeTableSettings, data: data, timeTableRefreshSink: timeTableRefreshSink, caches: caches),
//                      ),
//              ],
//            );
//          }),
//    );
//  }
//}
//
//class DrawerWidget extends StatefulWidget {
//  final AppBloc appBloc;
//  final Function timeTableRefreshSink;
//  final TimeTableSettings timeTableSettings;
//  final Map data;
//  DrawerWidget({this.appBloc, this.timeTableRefreshSink, this.timeTableSettings, this.data});
//
//  @override
//  _DrawerWidgetState createState() => _DrawerWidgetState();
//}
//
//class _DrawerWidgetState extends State<DrawerWidget>  {
//  bool isLoadingSave = false;
//  bool isLoadingShare = false;
//
//  clear() async {
//    var sure = await Over.sure();
//    if (sure == true) {
//      widget.data.clear();
//      widget.timeTableRefreshSink();
//    }
//  }
//
//  save() async {
//    var sure = await Over.sure();
//    if (sure == true) {
//      if (Fav.noConnection() ) return;
//
//      setState(() {
//        isLoadingSave = true;
//      });
//
//      SetDataService.saveTimetableProgram(widget.data, 'Taslak1').then((a) {
//        OverAlert.saveSuc();
//        setState(() {
//          isLoadingSave = false;
//        });
//      }).catchError((error) {
//        OverAlert.saveErr();
//        setState(() {
//          isLoadingSave = false;
//        });
//      });
//    }
//  }
//
//  share() async {
//    var sure = await Over.sure();
//    if (sure == true) {
//      if (Fav.noConnection() ) return;
//
//      setState(() {
//        isLoadingShare = true;
//      });
//
//      Map timeTableData = {};
//      timeTableData['classProgram'] = widget.data;
//      timeTableData['timeStamp'] = AppVar.appBloc.realTime;
//      timeTableData['times'] = AppVar.appBloc.schoolTimesService.singleData.mapForSave();
//
//      SetDataService.saveTimetableProgram(widget.data, 'Taslak1');
//
//      SetDataService.shareTimetableProgram(timeTableData).then((a) {
//        OverAlert.saveSuc();
//        setState(() {
//          isLoadingShare = false;
//        });
//      }).catchError((error) {
//        OverAlert.saveErr();
//        setState(() {
//          isLoadingShare = false;
//        });
//      });
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return SafeArea(
//      child:   SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            SizedBox(
//              height: 8,
//            ),
//            Text(
//               'timetableprocesslist'),
//              style: TextStyle(color:  Fav.design.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Expanded(
//                      child: Text(
//                     'cleartimetablehint'),
//                    style: TextStyle(color:  Fav.design.primaryText.withAlpha(180), fontSize: 10),
//                  )),
//                  MyMiniRaisedButton(onPressed: clear, text:  'cleartimetable')),
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Expanded(
//                      child: Text(
//                     'savetimetablehint'),
//                    style: TextStyle(color:  Fav.design.primaryText.withAlpha(180), fontSize: 10),
//                  )),
//                  MyProgressButton(
//                    mini: true,
//                    onPressed: save,
//                    label:  'save'),
//                    isLoading: isLoadingSave,
//                  ),
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Expanded(
//                      child: Text(
//                     'sharetimetablehint'),
//                    style: TextStyle(color:  Fav.design.primaryText.withAlpha(180), fontSize: 10),
//                  )),
//                  MyProgressButton(
//                    mini: true,
//                    onPressed: share,
//                    label:  'share'),
//                    isLoading: isLoadingShare,
//                  ),
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 8.0),
//              child: Divider(),
//            ),
//            Text(
//               'settings'),
//              style: TextStyle(color:  Fav.design.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
//            ),
//            MyDropDown(
//                isExpanded: true,
//                iconData: FontAwesomeIcons.behanceSquare,
//                canvasColor:  Fav.design.dropdown.canvas,
//                textColor:  Fav.design.primaryText,
//                value: widget.timeTableSettings.size,
//                name:  'cellsize'),
//                items: [
//                  DropdownMenuItem(
//                    child: Text(
//                       'small'),
//                      style: TextStyle(color:  Fav.design.primaryText),
//                    ),
//                    value: 1,
//                  ),
//                  DropdownMenuItem(
//                    child: Text( 'medium'), style: TextStyle(color:  Fav.design.primaryText)),
//                    value: 2,
//                  ),
//                  DropdownMenuItem(
//                    child: Text( 'large'), style: TextStyle(color:  Fav.design.primaryText)),
//                    value: 3,
//                  )
//                ],
//                onChanged: (value) {
//                  widget.timeTableSettings.changeCellSize(value);
//                  widget.timeTableRefreshSink();
//                  setState(() {});
//                }),
//            SizedBox(
//              height: 8,
//            ),
//            MyDropDown(
//                isExpanded: true,
//                iconData: FontAwesomeIcons.tabletAlt,
//                iconColor: Colors.greenAccent,
//                canvasColor:  Fav.design.dropdown.canvas,
//                textColor:  Fav.design.primaryText,
//                value: widget.timeTableSettings.boxColorIsTeacher,
//                name:  'boxcolor'),
//                items: [
//                  DropdownMenuItem(
//                    child: Text(
//                       'teacherboxcolor'),
//                      style: TextStyle(color:  Fav.design.primaryText),
//                    ),
//                    value: true,
//                  ),
//                  DropdownMenuItem(
//                    child: Text( 'lessonboxcolor'), style: TextStyle(color:  Fav.design.primaryText)),
//                    value: false,
//                  ),
//                ],
//                onChanged: (value) {
//                  widget.timeTableSettings.boxColorIsTeacher = value;
//                  widget.timeTableRefreshSink();
//                  setState(() {});
//                }),
//            SizedBox(
//              height: 8,
//            ),
//            MyMultiSelect(
//              name:  'visibledays'),
//              initialValue: List<String>.from(widget.timeTableSettings.visibleDays),
//              context: context,
//              items: (List<String>.from(AppVar.appBloc.schoolTimesService.singleData.activeDays)..sort((a, b) => a.compareTo(b))).map((day) => MyMultiSelectItem(day, DateFormat('EEEE').format(DateTime(2019, 7, int.tryParse(day))))).toList(),
//              title:  'visibledays'),
//              iconData: FontAwesomeIcons.angular,
//              onChanged: (List value) {
//                widget.timeTableSettings.visibleDays = value..sort((a, b) => a.compareTo(b));
//                widget.timeTableRefreshSink();
//              },
//            ),
//            SizedBox(
//              height: 8,
//            ),
//            MyMultiSelect(
//              name:  'visibleclass0'),
//              initialValue: List<String>.from(widget.timeTableSettings.visibleClass),
//              context: context,
//              items: AppVar.appBloc.classService.dataList.map((sinif) => MyMultiSelectItem(sinif.key, sinif.name + '${sinif.classType == 1 ? ('(' +  'classtype1').substring(0, 1)) + ')' : ''}')).toList(),
//              title:  'visibleclass0'),
//              iconData: FontAwesomeIcons.ban,
//              color: Colors.redAccent,
//              onChanged: (value) {
//                widget.timeTableSettings.visibleClass = value;
//                widget.timeTableRefreshSink();
//              },
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
