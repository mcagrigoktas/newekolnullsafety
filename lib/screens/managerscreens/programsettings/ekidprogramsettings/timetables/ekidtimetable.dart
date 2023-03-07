//import 'package:elseifekol/appbloc/appvar.dart';
//import 'package:elseifekol/models/allmodel.dart';
//import 'package:elseifekol/screens/managerscreens/programsettings/programlistmodels.dart';
//import 'package:flutter/material.dart';
//
//
//import 'package:intl/intl.dart';
//
//class EkidTimeTable extends StatelessWidget {
//  final AppBloc appBloc;
//  final data;
//  final Function timeTableRefreshSink;
//  final TimeTableSettings timeTableSettings;
//  final Map caches;
//  EkidTimeTable({this.appBloc, this.timeTableSettings, this.data, this.timeTableRefreshSink, this.caches});
//
//  @override
//  Widget build(BuildContext context) {
//    return SingleChildScrollView(
//      child: Center(
//        child: SingleChildScrollView(
//          scrollDirection: Axis.horizontal,
//          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
//          child: Column(
//            children: <Widget>[
//              DayNames(
//                appBloc: appBloc,
//                timeTableSettings: timeTableSettings,
//              ),
//              LessonHours(
//                appBloc: appBloc,
//                timeTableSettings: timeTableSettings,
//              ),
//              LessonNumbers(
//                appBloc: appBloc,
//                timeTableSettings: timeTableSettings,
//              ),
//              ...appBloc.classService.dataList.where((sinif) => timeTableSettings.visibleClass.contains(sinif.key)).map((sinif) => ClassProgram(appBloc: appBloc, timeTableSettings: timeTableSettings, sinif: sinif, data: data, timeTableRefreshSink: timeTableRefreshSink, caches: caches)).toList(),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}
//
//class DayNames extends StatelessWidget {
//  final AppBloc appBloc;
//  final TimeTableSettings timeTableSettings;
//  DayNames({this.appBloc, this.timeTableSettings});
//
//  @override
//  Widget build(BuildContext context) {
//    return Row(
//      children: <Widget>[
//        Container(
//          margin: EdgeInsets.all(1),
//          width: timeTableSettings.classNameWidth,
//          height: timeTableSettings.cellHeight,
//          alignment: Alignment.center,
//        ),
//        ...timeTableSettings.visibleDays.map((day) => Container(
//              alignment: Alignment.center,
//              decoration: BoxDecoration(color:  Fav.design.bottomNavigationBar.background, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
//              width: (timeTableSettings.cellWidth + 2) * (int.tryParse(day) > 5 ? appBloc.schoolTimesService.singleData.weekendLessonCount : appBloc.schoolTimesService.singleData.weekdaysLessonCount) - 2.0,
//              height: timeTableSettings.cellHeight,
//              margin: EdgeInsets.all(1),
//              child: Text(
//                DateFormat('EEEE').format(DateTime(2019, 7, int.tryParse(day))),
//                style: TextStyle(color: Fav.design.primaryText),
//              ),
//            ))
//      ],
//    );
//  }
//}
//
//class LessonNumbers extends StatelessWidget {
//  final AppBloc appBloc;
//  final TimeTableSettings timeTableSettings;
//  LessonNumbers({this.appBloc, this.timeTableSettings});
//
//  @override
//  Widget build(BuildContext context) {
//    return Row(
//      children: <Widget>[
//        Container(
//          alignment: Alignment.center,
//          width: timeTableSettings.classNameWidth,
//          height: timeTableSettings.lessonNumberHeight,
//          margin: EdgeInsets.all(1),
//        ),
//        ...(timeTableSettings.visibleDays).map((day) => Row(
//              children: Iterable.generate(int.tryParse(day) > 5 ? appBloc.schoolTimesService.singleData.weekendLessonCount : appBloc.schoolTimesService.singleData.weekdaysLessonCount)
//                  .map((lessonNo) => Container(
//                        alignment: Alignment.center,
//                        decoration: BoxDecoration(color:  Fav.design.bottomNavigationBar.background, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
//                        width: timeTableSettings.cellWidth,
//                        height: timeTableSettings.lessonNumberHeight,
//                        margin: EdgeInsets.all(1),
//                        child: Text(
//                          '${lessonNo + 1}',
//                          style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
//                        ),
//                      ))
//                  .toList(),
//            ))
//      ],
//    );
//  }
//}
//
//class LessonHours extends StatelessWidget {
//  final AppBloc appBloc;
//  final TimeTableSettings timeTableSettings;
//  LessonHours({this.appBloc, this.timeTableSettings});
//
//  String timeToString(value) => '${(value ?? 0) ~/ 60}'.padLeft(2, '0') + ':' + '${(value ?? 0) % 60}'.padLeft(2, '0');
//
//  @override
//  Widget build(BuildContext context) {
//    return Row(
//      children: <Widget>[
//        Container(
//          alignment: Alignment.center,
//          width: timeTableSettings.classNameWidth,
//          height: timeTableSettings.lessonNumberHeight,
//          margin: EdgeInsets.all(1),
//        ),
//        ...(timeTableSettings.visibleDays).map((day) => Row(
//              children: Iterable.generate(int.tryParse(day) > 5 ? appBloc.schoolTimesService.singleData.weekendLessonCount : appBloc.schoolTimesService.singleData.weekdaysLessonCount)
//                  .map((lessonNo) => Container(
//                        alignment: Alignment.center,
//                        decoration: BoxDecoration(color:  Fav.design.bottomNavigationBar.background, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
//                        width: timeTableSettings.cellWidth,
//                        height: timeTableSettings.lessonNumberHeight,
//                        margin: EdgeInsets.all(1),
//                        child: Text(
//                          '${timeToString((int.tryParse(day) > 5 ? appBloc.schoolTimesService.singleData.weekendsLessonTimes : appBloc.schoolTimesService.singleData.weekdaysLessonTimes)[lessonNo].first ?? 0)}',
//                          style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
//                        ),
//                      ))
//                  .toList(),
//            ))
//      ],
//    );
//  }
//}
//
//class ClassProgram extends StatelessWidget  {
//  final AppBloc appBloc;
//  final TimeTableSettings timeTableSettings;
//  final Class sinif;
//  final Map data;
//  final Function timeTableRefreshSink;
//  final Map caches;
//  ClassProgram({this.appBloc, this.timeTableSettings, this.sinif, this.data, this.timeTableRefreshSink, this.caches});
//
//  bool ayniSaatteOgretmenDolumu(String lessonKey, int day, int lessonNo) {
//    bool teacherFull = false;
//    data.forEach((classKey, value) {
//      if (classKey != sinif.key && !teacherFull) {
//        final Map sinifProgarmi = value;
//        sinifProgarmi.forEach((time, lessonKey2) {
//          if (time == '$day-$lessonNo' && !teacherFull) {
//            if (caches.containsKey(lessonKey2) &&
//                caches.containsKey(lessonKey) && // todo gelen hatadan sonra eklendi silinen sinif uada ders ile ilgili bir osrun var
//                caches[lessonKey2]['teacherKey'] == caches[lessonKey]['teacherKey']) {
//              teacherFull = true;
//            }
//          }
//        });
//      }
//    });
//    return teacherFull;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Row(
//      children: <Widget>[
//        Container(
//          alignment: Alignment.center,
//          decoration: BoxDecoration(color:  Fav.design.bottomNavigationBar.background, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
//          width: timeTableSettings.classNameWidth,
//          height: timeTableSettings.cellHeight,
//          margin: EdgeInsets.all(1),
//          child: Text(
//            sinif.name.length > 5 ? sinif.name.substring(0, 5) : sinif.name,
//            style: TextStyle(color: Fav.design.primaryText),
//          ),
//        ),
//        ...(timeTableSettings.visibleDays).map((day) => Row(
//              children: Iterable.generate(int.tryParse(day) > 5 ? appBloc.schoolTimesService.singleData.weekendLessonCount : appBloc.schoolTimesService.singleData.weekdaysLessonCount)
//                  .map(
//                    (lessonNo) => PopupMenuButton(
//                      onSelected: (lessonKey) {
//                        if (data[sinif.key] == null) {
//                          data[sinif.key] = {};
//                        }
//                        if (lessonKey == 'sil') {
//                          (data[sinif.key] as Map).remove('$day-${lessonNo + 1}');
//                        } else {
//                          if (ayniSaatteOgretmenDolumu(lessonKey, int.tryParse(day), lessonNo + 1) == true) {
//                            Alert.alert( type: AlertType.danger, message:  'teacherlessonfull'));
//                            return;
//                          }
//                          data[sinif.key]['$day-${lessonNo + 1}'] = lessonKey;
//                        }
//                        timeTableRefreshSink();
//                      },
//                      child: Container(
//                        alignment: Alignment.center,
//                        decoration: BoxDecoration(
//                            color: timeTableSettings.boxColorIsTeacher
//                                ? (((caches[(data[sinif.key] ?? {})['$day-${lessonNo + 1}']]) ?? {})['teacherColor'] ?? (appBloc.hesapBilgileri.isEkid ? Color(0xfff3f3f3) : Color(0xff24262A)))
//                                : (((caches[(data[sinif.key] ?? {})['$day-${lessonNo + 1}']]) ?? {})['lessonColor'] ?? (appBloc.hesapBilgileri.isEkid ? Color(0xfff3f3f3) : Color(0xff24262A))),
//                            borderRadius: BorderRadius.circular(4.0),
//                            boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
//                        width: timeTableSettings.cellWidth,
//                        height: timeTableSettings.cellHeight,
//                        margin: EdgeInsets.all(1),
//                        child: Text(
//                          (((caches[(data[sinif.key] ?? {})['$day-${lessonNo + 1}']]) ?? {})['lessonName'] ?? ''),
//                          style: TextStyle(color: appBloc.hesapBilgileri.isEkid ? Colors.white : Fav.design.primaryText),
//                        ),
//                      ),
//                      itemBuilder: (context) {
//                        return appBloc.lessonService.dataList
//                            .where((lesson) => lesson.classKey == sinif.key)
//                            .where((lesson) => lesson.count > (((data[sinif.key] ?? {}) as Map).values.fold(0, (t, e) => e == lesson.key ? t + 1 : t)))
//                            .map((lesson) => PopupMenuItem(
//                                value: lesson.key,
//                                height: timeTableSettings.cellHeight + 8,
//                                child: Container(
//                                    alignment: Alignment.center,
//                                    decoration: BoxDecoration(
//                                        color: timeTableSettings.boxColorIsTeacher ? (((caches[lesson.key]) ?? {})['teacherColor'] ?? Color(0xff24262A)) : (((caches[lesson.key]) ?? {})['lessonColor'] ?? Color(0xff24262A)),
//                                        borderRadius: BorderRadius.circular(4.0),
//                                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 1)]),
//                                    height: timeTableSettings.cellHeight,
//                                    margin: EdgeInsets.all(1),
//                                    child: RichText(
//                                        text: TextSpan(children: [
//                                      TextSpan(text: lesson.name + ' - ', style: TextStyle(color: Colors.white)),
//                                      TextSpan(text: '${lesson.count - (((data[sinif.key] ?? {}) as Map).values.fold(0, (t, e) => e == lesson.key ? t + 1 : t))}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//                                    ])))))
//                            .toList()
//                              ..insert(
//                                  0,
//                                  PopupMenuItem(
//                                      value: 'sil',
//                                      height: timeTableSettings.cellHeight + 8,
//                                      child: Container(
//                                        alignment: Alignment.center,
//                                        decoration: BoxDecoration(color:  Fav.design.bottomNavigationBar.background, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
//                                        height: timeTableSettings.cellHeight,
//                                        margin: EdgeInsets.all(1),
//                                        child: Text('-'),
//                                      )));
//                      },
//                    ),
//                  )
//                  .toList(),
//            ))
//      ],
//    );
//  }
//}
