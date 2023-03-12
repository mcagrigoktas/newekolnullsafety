import 'dart:convert';

import 'package:elseifekol/library_helper/printing/eager.dart';
import 'package:flutter/services.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:turkish/turkish.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../assets.dart';
import '../../helper.dart';

class TimeTablePrintHelper {
  TimeTablePrintHelper._();
  static const nameWidgetWidth = 60.0;
  static const _borderWidth = 0.3;
  static const _boldBorderWidth = 0.6;
  static const _cellHeight = 16.0;
  static Future<void> printFullProgram() async {
    final _times = AppVar.appBloc.schoolTimesService!.dataList.last;
    var _programData = ProgramHelper.getLastSturdyProgram();

    final _pdf = Document();
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);

    List<Widget> _list = [];

    // final _gunlerdeToplamAcikDersSayisi = Iterable.generate(7).fold<int>(0, (p, e) => p+_times.getDayLessonCount(e+1));

    _list.add(Center(child: Text(AppVar.appBloc.schoolInfoService!.singleData!.name + ' ' + 'teacherprogrammenuname'.translate, style: TextStyle(fontSize: 4))));
    _list.add(_borderContainer(
        Row(children: [
          _borderContainer(SizedBox(width: nameWidgetWidth), 'R', cellHeight: 10),
          for (var i = 1; i < 8; i++)
            Expanded(
              flex: _times.getDayLessonCount('$i')!,
              child: _times.getDayLessonCount('$i')! > 1 ? _borderContainer(Text(McgFunctions.getDayNameFromDayOfWeek(i), style: TextStyle(fontSize: 4)), 'R', cellHeight: 10) : SizedBox(),
            )
        ]),
        'LRTb',
        cellHeight: 10));
    _list.add(_borderContainer(
        Row(children: [
          _borderContainer(SizedBox(width: nameWidgetWidth), 'R', cellHeight: 10),
          for (var i = 1; i < 8; i++)
            Expanded(
              flex: _times.getDayLessonCount('$i')!,
              child: _times.getDayLessonCount('$i')! > 1 ? _borderContainer(Row(children: [for (var j = 0; j < _times.getDayLessonCount('$i')!; j++) Expanded(child: _borderContainer(Text((j + 1).toString(), style: TextStyle(fontSize: 4)), 'r'))]), 'R', cellHeight: 10) : SizedBox(),
            )
        ]),
        'LRtB',
        cellHeight: 10));
    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      final _teacherProgramList = ProgramHelper.getTeacherAllLessonFromTimeTable(teacher.key, _programData);
      if (_teacherProgramList.isNotEmpty) {
        _list.add(_borderContainer(
            Row(children: [
              _borderContainer(
                  SizedBox(
                    width: nameWidgetWidth,
                    child: Padding(
                        padding: EdgeInsets.all(1),
                        child: Row(children: [
                          Expanded(child: Text(teacher.name, maxLines: 1, style: TextStyle(fontSize: 6))),
                          Text(_teacherProgramList.length.toString(), style: TextStyle(fontSize: 6)),
                        ])),
                  ),
                  'R'),
              for (var i = 1; i < 8; i++)
                Expanded(
                  flex: _times.getDayLessonCount('$i')!,
                  child: _times.getDayLessonCount('$i')! > 1
                      ? _borderContainer(
                          Row(children: [
                            for (var j = 0; j < _times.getDayLessonCount('$i')!; j++)
                              Expanded(
                                child: Builder(builder: (ctx) {
                                  final _item = _teacherProgramList.singleWhereOrNull((element) => element.lessonNo == j + 1 && element.day == i);
                                  return _borderContainer(
                                    _item == null
                                        ? Text('-', style: TextStyle(fontSize: 4))
                                        : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                            Text(_item.lesson!.name, style: TextStyle(fontSize: 4)),
                                            Text(AppVar.appBloc.classService!.dataListItem(_item.lesson!.classKey!)?.name ?? '', style: TextStyle(fontSize: 4)),
                                          ]),
                                    'r',
                                  );
                                }),
                              )
                          ]),
                          'R')
                      : SizedBox(),
                )
            ]),
            'LRtB'));
      }
    });

    _pdf.addPage(MultiPage(
      pageTheme: PageTheme(orientation: PageOrientation.landscape, pageFormat: PdfPageFormat.a4, margin: EdgeInsets.all(Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble()), theme: ThemeData.withFont(fontFallback: [Font.ttf(font1)])),
      build: (context) => _list,
      maxPages: 1000,
    ));
    await PrintLibraryHelper.printPdfDoc(_pdf);
  }

  static Future<void> printTeacherProgram(List<String>? teacherList) async {
    final _pdf = Document();
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);
    final _times = AppVar.appBloc.schoolTimesService!.dataList.last;
    final _timesMaxLessonCountADay = _times.maxLessonCountADay;

    var _programData = ProgramHelper.getLastSturdyProgram();

    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      if (teacherList!.contains(teacher.key)) {
        final _teacherProgramList = ProgramHelper.getTeacherAllLessonFromTimeTable(teacher.key, _programData);
        if (_teacherProgramList.isNotEmpty) {
          final _widget = Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            ...Fav.preferences.getString('t_p_h1', 'header'.translate)!.split('\n').map((e) => Text(e, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))).toList(),
            SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Column(children: [
                Row(children: [
                  SizedBox(width: 75, child: Text('t_p_o'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Text(': '.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(Fav.preferences.getInt('t_p_o', 1).toString().translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
                Row(children: [
                  SizedBox(width: 75, child: Text('t_p_o2'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Text(': '.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('weeklytimetable'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ])),
              Expanded(child: Center(child: Text(DateTime.now().millisecondsSinceEpoch.dateFormat('d-MM-yyyy'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
            ]),
            SizedBox(height: 4),
            Center(child: Text('dear'.translate + ' : ' + turkish.toUpperCase(teacher.name), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Text(
                't_p_content'.argsTranslate({
                  'term': Fav.preferences.getString('t_p_h3', AppVar.appBloc.hesapBilgileri.termKey),
                  'date': DateTime.now().dateFormat('d-MM-yyyy'),
                }),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Align(
                alignment: Alignment.topRight,
                child: Column(children: [
                  Text(Fav.preferences.getString('t_p_h2', AppVar.appBloc.hesapBilgileri.name)!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('t_p_h2'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ])),
            SizedBox(height: 4),
            Column(children: [
              Row(
                children: [
                  SizedBox(width: 85, child: _borderContainer(SizedBox(), 'LRTB', cellHeight: 30)),
                  ...Iterable.generate(_timesMaxLessonCountADay.clamp(9, 30)).map((e) {
                    final time = _times.getDayLessonNoTimes('1', e);
                    return Expanded(
                        child: _borderContainer(
                            Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('${e + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                              if (time.isNotEmpty && time.first != 0) Text(time.first!.timeToString, textAlign: TextAlign.center, style: TextStyle(fontSize: 8)),
                            ]),
                            'LRTB',
                            cellHeight: 30));
                  }).toList(),
                ],
              ),
              for (var i = 1; i < (Fav.preferences.getBool('onlyweekdayforprogram', true)! ? 6 : 8); i++)
                _borderContainer(
                    Row(children: [
                      SizedBox(width: 85, child: _borderContainer(Text(McgFunctions.getDayNameFromDayOfWeek(i), style: TextStyle(fontWeight: FontWeight.bold)), 'LRTB', cellHeight: 30)),
                      for (var j = 0; j < _timesMaxLessonCountADay.clamp(9, 30); j++)
                        Expanded(
                          child: Builder(builder: (ctx) {
                            final _item = _teacherProgramList.singleWhereOrNull((element) => element.lessonNo == j + 1 && element.day == i);
                            return _borderContainer(
                              _item == null
                                  ? Text('-', style: TextStyle(fontSize: 4))
                                  : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      Text(_item.lesson!.name, style: TextStyle(fontSize: 10)),
                                      Text(AppVar.appBloc.classService!.dataListItem(_item.lesson!.classKey!)?.name ?? '', style: TextStyle(fontSize: 10)),
                                    ]),
                              'rb',
                              cellHeight: 30,
                            );
                          }),
                        )
                    ]),
                    'R',
                    cellHeight: 30)
            ]),
            SizedBox(height: 4),
            Row(children: [
              Expanded(
                  flex: 3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('total'.translate + ': ' + _teacherProgramList.length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('classteacher'.translate + ': ' + (AppVar.appBloc.classService!.dataList.firstWhereOrNull((sinif) => sinif.classTeacher == teacher.key)?.name ?? ''), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ])),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('igotoriginal'.translate, style: TextStyle(fontSize: 12)),
                Text('date'.translate, style: TextStyle(fontSize: 12)),
                Text('../../....'.translate, style: TextStyle(fontSize: 12)),
              ])),
            ]),
          ]);
          _pdf.addPage(Page(
            pageTheme: PageTheme(
                orientation: PageOrientation.portrait,
                pageFormat: PdfPageFormat.a4,
                margin: EdgeInsets.symmetric(horizontal: Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble() + 16, vertical: Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble()),
                theme: ThemeData.withFont(fontFallback: [Font.ttf(font1)])),
            build: (context) => Column(children: [
              Expanded(child: _widget),
              Expanded(child: _widget),
            ]),
          ));
        }
      }
    });
    await PrintLibraryHelper.printPdfDoc(_pdf);
  }

  static Future<void> printClassProgram(List<String> classList) async {
    final _pdf = Document();
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);
    final _times = AppVar.appBloc.schoolTimesService!.dataList.last;
    final _timesMaxLessonCountADay = _times.maxLessonCountADay;

    var _programData = json.decode(json.encode(ProgramHelper.getLastSturdyProgram(timesModel: _times)));

    AppVar.appBloc.classService!.dataList.forEach((sinif) {
      if (classList.contains(sinif.key)) {
        Map<String?, int> _lessonTotalCountCacher = {};
        final _classProgramList = ProgramHelper.getClassAllLessonFromTimeTable(sinif.key, _programData);

        if (_classProgramList.isNotEmpty) {
          final _programWidget = Column(children: [
            Row(
              children: [
                SizedBox(width: 85, child: _borderContainer(SizedBox(), 'LRTB', cellHeight: 30)),
                ...Iterable.generate(_timesMaxLessonCountADay.clamp(9, 30)).map((e) {
                  final time = _times.getDayLessonNoTimes('1', e);
                  return Expanded(
                      child: _borderContainer(
                          Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${e + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                            if (time.isNotEmpty && time.first != 0) Text(time.first!.timeToString, textAlign: TextAlign.center, style: TextStyle(fontSize: 8)),
                          ]),
                          'LRTB',
                          cellHeight: 30));
                }).toList(),
              ],
            ),
            for (var i = 1; i < (Fav.preferences.getBool('onlyweekdayforprogram', true)! ? 6 : 8); i++)
              _borderContainer(
                  Row(children: [
                    SizedBox(width: 85, child: _borderContainer(Text(McgFunctions.getDayNameFromDayOfWeek(i), style: TextStyle(fontWeight: FontWeight.bold)), 'LRTB', cellHeight: 30)),
                    for (var j = 0; j < _timesMaxLessonCountADay.clamp(9, 30); j++)
                      Expanded(
                        child: Builder(builder: (ctx) {
                          final _item = _classProgramList.singleWhereOrNull((element) => element.lessonNo == j + 1 && element.day == i);

                          if (_item == null) {
                          } else if (_item.lesson != null) {
                            _lessonTotalCountCacher[_item.lesson!.key] ??= 0;
                            _lessonTotalCountCacher[_item.lesson!.key] = (_lessonTotalCountCacher[_item.lesson!.key] as int) + 1;
                          } else if (_item.classTypeName != null) {
                            _lessonTotalCountCacher['classType:' + _item.classTypeName!] ??= 0;
                            _lessonTotalCountCacher['classType:' + _item.classTypeName!] = (_lessonTotalCountCacher['classType:' + _item.classTypeName!] as int) + 1;
                          }

                          return _borderContainer(
                            _item == null
                                ? Text('-', style: TextStyle(fontSize: 4))
                                : _item.lesson != null
                                    ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                        Text(_item.lesson!.name, style: TextStyle(fontSize: 10)),
                                        Text(AppVar.appBloc.classService!.dataListItem(_item.lesson!.classKey!)?.name ?? '', style: TextStyle(fontSize: 10)),
                                      ])
                                    : Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                        Text(_item.classTypeName!, style: TextStyle(fontSize: 10)),
                                        Text(_item.classTypeName!, style: TextStyle(fontSize: 10)),
                                      ]),
                            'rb',
                            cellHeight: 30,
                          );
                        }),
                      )
                  ]),
                  'R',
                  cellHeight: 30)
          ]);

          final _widget = Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ...Fav.preferences.getString('t_p_h1', 'header'.translate)!.split('\n').map((e) => Text(e, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))).toList(),
            SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Column(children: [
                Row(children: [
                  SizedBox(width: 120, child: Text('class'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Text(': '.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(sinif.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
                Row(children: [
                  SizedBox(width: 120, child: Text('classteacher'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Text(': '.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(AppVar.appBloc.teacherService!.dataListItem(sinif.classTeacher ?? '?')?.name ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ])),
              Expanded(child: Center(child: Text(DateTime.now().millisecondsSinceEpoch.dateFormat('d-MM-yyyy'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
            ]),
            SizedBox(height: 4),
            Text(
                't_p_content_s'.argsTranslate({
                  'term': Fav.preferences.getString('t_p_h3', AppVar.appBloc.hesapBilgileri.termKey),
                  'date': DateTime.now().dateFormat('d-MM-yyyy'),
                }),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Align(
                alignment: Alignment.topRight,
                child: Column(children: [
                  Text(Fav.preferences.getString('t_p_h2', AppVar.appBloc.hesapBilgileri.name)!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('t_p_h2'.translate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ])),
            SizedBox(height: 4),
            _programWidget,
            SizedBox(height: 16),
            Column(children: [
              Row(children: [
                Expanded(child: Text('lessonname'.translate, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('totallessoncount'.translate.toUpperCase().onlyCapitalLetters!, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('teacher'.translate, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text(''.translate, style: TextStyle(fontWeight: FontWeight.bold))),
              ]),
              //! Builderden cikartirsan _lessonTotalCountCacher bos geliyor
              Builder(
                  builder: (_) => Column(children: [
                        ..._lessonTotalCountCacher.entries.map((e) {
                          if (e.key!.startsWith('classType:')) {
                            final _name = e.key!.replaceAll('classType:', '');
                            return Row(children: [
                              Expanded(child: Text(_name, style: TextStyle(fontWeight: FontWeight.normal))),
                              Expanded(child: Text(e.value.toString(), style: TextStyle(fontWeight: FontWeight.normal))),
                              Expanded(flex: 2, child: Text('', style: TextStyle(fontWeight: FontWeight.normal))),
                              Expanded(child: Text(''.translate, style: TextStyle(fontWeight: FontWeight.normal))),
                            ]);
                          } else {
                            final _lesson = AppVar.appBloc.lessonService!.dataListItem(e.key!);
                            final _teacher = AppVar.appBloc.teacherService!.dataListItem(_lesson?.teacher ?? '-');
                            return Row(children: [
                              Expanded(child: Text(_lesson?.name ?? '', style: TextStyle(fontWeight: FontWeight.normal))),
                              Expanded(child: Text(e.value.toString(), style: TextStyle(fontWeight: FontWeight.normal))),
                              Expanded(flex: 2, child: Text(_teacher?.name ?? '', style: TextStyle(fontWeight: FontWeight.normal))),
                              Expanded(child: Text(''.translate, style: TextStyle(fontWeight: FontWeight.normal))),
                            ]);
                          }
                        }).toList()
                      ]))
            ]),
            SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('total'.translate, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(_classProgramList.length.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text(''.translate, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(''.translate, style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
          ]);
          _pdf.addPage(Page(
            pageTheme: PageTheme(
                orientation: PageOrientation.portrait,
                pageFormat: PdfPageFormat.a4,
                margin: EdgeInsets.symmetric(horizontal: Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble() + 16, vertical: Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble()),
                theme: ThemeData.withFont(fontFallback: [Font.ttf(font1)])),
            build: (context) => _widget,
          ));
        }
      }
    });
    await PrintLibraryHelper.printPdfDoc(_pdf);
  }

  static Widget _borderContainer(Widget child, String _directions, {double? cellHeight}) {
    return Container(
        child: child,
        height: cellHeight ?? _cellHeight,
        decoration: BoxDecoration(
            border: Border(
          top: _directions.toLowerCase().contains('t') ? BorderSide(width: _directions.contains('t') ? _borderWidth : _boldBorderWidth) : BorderSide.none,
          left: _directions.toLowerCase().contains('l') ? BorderSide(width: _directions.contains('l') ? _borderWidth : _boldBorderWidth) : BorderSide.none,
          right: _directions.toLowerCase().contains('r') ? BorderSide(width: _directions.contains('r') ? _borderWidth : _boldBorderWidth) : BorderSide.none,
          bottom: _directions.toLowerCase().contains('b') ? BorderSide(width: _directions.contains('b') ? _borderWidth : _boldBorderWidth) : BorderSide.none,
        )),
        alignment: Alignment.center);
  }
}
