import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/print/printhelper.dart';
import '../../library_helper/excel/eager.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../services/pushnotificationservice.dart';
import 'ekolrollcallstudentpage.dart';

class EkolRollCallManagerPage extends StatefulWidget {
  @override
  _EkolRollCallManagerPageState createState() => _EkolRollCallManagerPageState();
}

class _EkolRollCallManagerPageState extends State<EkolRollCallManagerPage> {
  bool isLoading = false;
  //Istersen bunu cacheleyip tekrarli veri istemeyi engelleyebilirsin
  Map<String, Map?> dateRollCallData = {};
  final List<Widget> listWidget = [];

  Map notificationKeyList = {};

  List<String> bildirimGonderilenlerListesi = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  int currentDate = DateTime.now().millisecondsSinceEpoch;
  String get currentDateText => currentDate.dateFormat("d-MM-yyyy");
  Map? selectedDayRollCallData() => dateRollCallData[currentDateText];
  Map? getDayRollCallData(String dayKey) => dateRollCallData[dayKey];

  void getData() {
    if (selectedDayRollCallData() != null) {
      setState(() {
        calcClassList();
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    RollCallService.dbGetRollCallDay(currentDateText).once().then((snap) {
      setState(() {
        dateRollCallData[currentDateText] = snap?.value;
        isLoading = false;
        notificationKeyList.clear();
        if (snap?.value != null) {
          calcClassList();
        }
      });
    }).catchError((err) {
      log(err);
    });
  }

  Future<List<String>> getRangeData(int firstDate, int endDate) async {
    int _controlDate = endDate;
    final List<Future> _futureList = [];
    final List<String> _dayTextList = [];
    do {
      _dayTextList.add(_controlDate.dateFormat('d-MM-yyyy'));
      _controlDate -= Duration(days: 1).inMilliseconds;
    } while (_controlDate >= firstDate);

    _dayTextList.forEach((_dayText) {
      if (getDayRollCallData(_dayText) == null) {
        _futureList.add(RollCallService.dbGetRollCallDay(_dayText).once().then((snap) {
          dateRollCallData[_dayText] = snap?.value;
        }));
      }
    });

    await Future.wait(_futureList);
    return _dayTextList;
  }

  void calcClassList() {
    listWidget.clear();
    final data = selectedDayRollCallData()!;
    final keyList = data.keys.toList()
      ..sort((sinifKey1, sinifKey2) {
        final sinifName1 = AppVar.appBloc.classService!.dataListItem(sinifKey1)?.name;
        final sinifName2 = AppVar.appBloc.classService!.dataListItem(sinifKey2)?.name;
        if (sinifName1 == null || sinifName2 == null) return 1;
        return sinifName1.compareTo(sinifName2);
      });
    for (var i = 0; i < keyList.length; i++) {
      final classKey = keyList[i];
      final value = data[classKey];

      final sinif = AppVar.appBloc.classService!.dataListItem(classKey);

      listWidget.add(ExpansionTile(
        title: Text(
          sinif != null ? sinif.name! : 'classnameerr'.translate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: calcLessonList(value, classKey),
      ));
    }
  }

  List<Widget> calcLessonList(Map value, String classKey) {
    final List<Widget> listWidget = [];
    final keyList = value.keys.toList()..sort();

    //Yoklamalarin ders sirasina gore olmasini saglar
    keyList.sort((a, b) {
      if (!a.contains('LN:') || !b.contains('LN:')) {
        return -1;
      }
      return a.split('LN:').last.compareTo(b.split('LN:').last);
    });

    for (var i = 0; i < keyList.length; i++) {
      final lessonkeyAndLessonNo = keyList[i];

      final rollCallValue = value[lessonkeyAndLessonNo];

      final String lessonKey = lessonkeyAndLessonNo.split('LN:').first;
      final String lessonNo = lessonkeyAndLessonNo.split('LN:').last;

      var ders = AppVar.appBloc.lessonService!.dataListItem(lessonKey);

      final String lessonName = ders != null ? ders.longName! : 'lessonnameerr'.translate;

      listWidget.add(Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ExpansionTile(
          title: Text(
            '${"lesson".translate} $lessonNo: ' + lessonName,
          ),
          children: calcStudentTile(rollCallValue, classKey, int.tryParse(lessonNo), lessonkeyAndLessonNo, lessonName),
        ),
      ));
    }

    return listWidget;
  }

  List<Widget> calcStudentTile(Map valueData, String classKey, int? lessonNo, String lessonNameNo, String lessonName) {
    final List<Widget> listWidget = [];

    valueData.forEach((studentKey, value) {
      var student = AppVar.appBloc.studentService!.dataListItem(studentKey);

      if (student != null) {
        if (value != 0) {
          notificationKeyList[studentKey] = student.name;
        }
        listWidget.add(Padding(
          key: Key(student.name!),
          padding: const EdgeInsets.only(left: 24, top: 12.0, bottom: 12),
          child: Row(
            children: <Widget>[
              if (student.imgUrl?.startsWithHttp ?? false)
                CircularProfileAvatar(
                  imageUrl: student.imgUrl,
                  radius: 18,
                ),
              if (student.imgUrl?.startsWithHttp ?? false) 8.widthBox,
              Expanded(flex: 2, child: Text(student.name ?? 'studentnameerr'.translate, style: TextStyle(color: Fav.design.primaryText))),
              8.widthBox,
              MyDropDownFieldOld(
                onChanged: (val) {
                  RollCallService.changeStudnetRollCall(currentDateText, classKey, lessonNo, lessonNameNo, studentKey, val);
                  setState(() {
                    valueData[studentKey] = val;
                    calcClassList();
                  });
                },
                initialValue: value ?? 0,
                canvasColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                arrowIcon: false,
                isExpanded: false,
                items: [
                  [0, 'rollcall0'.translate, Colors.green],
                  [1, 'rollcall1'.translate, Colors.red],
                  [2, 'rollcall2'.translate, Colors.deepOrangeAccent],
                  [3, 'rollcall3'.translate, Colors.amber],
                  [4, 'rollcall4'.translate, Colors.indigoAccent],
                  [5, 'rollcall5'.translate, Colors.deepPurpleAccent],
                ]
                    .map((e) => DropdownMenuItem(
                          child: Container(
                            width: 90,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(shape: const StadiumBorder(), color: e[2] as Color?),
                            child: Text(
                              e[1] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          value: e[0],
                        ))
                    .toList(),
              ),
              if (value != 0 && currentDateText == DateTime.now().dateFormat("d-MM-yyyy"))
                IconButton(
                  icon: Icon(
                    bildirimGonderilenlerListesi.contains(currentDateText + classKey + lessonNameNo + studentKey) ? Icons.done : Icons.send,
                    color: Fav.design.primaryText,
                  ),
                  onPressed: () {
                    if (bildirimGonderilenlerListesi.contains(currentDateText + classKey + lessonNameNo + studentKey)) {
                      return;
                    }
                    EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallsnotify'.argsTranslate({'lessonName': lessonName}) + ' ' + 'rollcall$value'.translate, [studentKey], NotificationArgs.generally());
                    bildirimGonderilenlerListesi.add(currentDateText + classKey + lessonNameNo + studentKey);
                    OverAlert.show(message: 'sendnotificationsuc'.translate);
                    setState(() {
                      calcClassList();
                    });
                  },
                ).pl8
            ],
          ),
        ));
      }
    });
    listWidget.sort((Widget a, Widget b) => a.key.toString().compareTo(b.key.toString()));
    return listWidget;
  }

  Future<void> sendBatchNotification() async {
    final List<String?> names = [];
    final List<String> keys = [];
    notificationKeyList.forEach((studentKey, studnetName) {
      names.add(studnetName);
      keys.add(studentKey);
    });

    final bool sure = await Over.sure(title: 'rcsendallstudent'.translate, message: names.join(' - '));
    if (!sure) {
      return;
    }
    EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallnotifygeneral'.translate, keys, NotificationArgs.generally()).unawaited;
    OverAlert.show(message: 'sendnotificationsuc'.translate);
  }

  List<int>? exportRangeValue;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'back'.translate,
        trailingActions: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.chartBar, color: Fav.design.appBar.text),
            onPressed: () {
              Fav.to(RollCallManagerStudentReview());
            },
          ),
          8.widthBox,
          QudsPopupButton(
            backgroundColor: Fav.design.scaffold.background,
            items: [
              QudsPopupMenuItem(
                  title: Words.print.text.make(),
                  onPressed: () {
                    if (selectedDayRollCallData() != null) RollcallExportHelper.printPDF(selectedDayRollCallData(), currentDateText);
                  }),
              QudsPopupMenuItem(
                  title: 'exportexcell'.translate.text.make(),
                  onPressed: () {
                    if (selectedDayRollCallData() != null) RollcallExportHelper.toExcel(selectedDayRollCallData(), currentDateText);
                  }),
              QudsPopupMenuSection(titleText: 'other'.translate, subItems: [
                QudsPopupMenuWidget(
                    builder: (ctx) => Column(
                          children: [
                            MyDateRangePicker(
                              firstDate: DateTime.now().subtract(Duration(days: 60)),
                              lastDate: DateTime.now(),
                              onChanged: (value) async {
                                if (value != null) exportRangeValue = value;
                              },
                              value: exportRangeValue,
                            ),
                            MyMiniRaisedButton(
                                onPressed: () async {
                                  if (exportRangeValue == null) return;
                                  if (exportRangeValue!.last - exportRangeValue!.first > Duration(days: 14).inMilliseconds) {
                                    OverAlert.show(message: 'rangetoomuch'.argsTranslate({'day': 14}));
                                    return;
                                  }
                                  if (exportRangeValue!.first >= exportRangeValue!.last) return;
                                  OverLoading.show();
                                  await 6000.wait;
                                  final _dateRangeTextList = await getRangeData(exportRangeValue!.first, exportRangeValue!.last);
                                  await 2000.wait;
                                  await OverLoading.close();
                                  await RollcallExportHelper.toRangeExcel(_dateRangeTextList, dateRollCallData);
                                },
                                text: 'exportspesificdaterange'.translate),
                            8.heightBox
                          ],
                        )),
              ])
            ],
            child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.appBar.text)),
          ),
        ],
      ),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: 'rcmenuname'.translate),
          child: Column(
            children: [
              MyDateChangeWidget(
                initialValue: DateTime.now().millisecondsSinceEpoch,
                onChanged: (value) {
                  currentDate = value;
                  getData();
                },
              ),
              if (currentDateText == DateTime.now().dateFormat("d-MM-yyyy")) 8.heightBox,
              if (!isLoading && selectedDayRollCallData() != null && notificationKeyList.keys.isNotEmpty && currentDateText == DateTime.now().dateFormat("d-MM-yyyy"))
                MyMiniRaisedButton(
                  color: Fav.design.primary,
                  onPressed: sendBatchNotification,
                  text: 'rcsendallstudent'.translate,
                ),
            ],
          )),
      body: Body.singleChildScrollView(
        child: Column(
          children: <Widget>[
            if (isLoading)
              Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: MyProgressIndicator(
                    color: Fav.design.primaryText,
                    text: 'longtimeloading'.translate,
                  )),
            if (!isLoading && selectedDayRollCallData() == null) EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS),
            if (!isLoading && selectedDayRollCallData() != null) ...listWidget
          ],
        ),
      ),
    );
  }
}

class RollCallManagerStudentReview extends StatefulWidget {
  RollCallManagerStudentReview();

  @override
  _RollCallManagerStudentReviewState createState() => _RollCallManagerStudentReviewState();
}

class _RollCallManagerStudentReviewState extends State<RollCallManagerStudentReview> {
  @override
  void initState() {
    super.initState();
  }

  Map? data;
  String studentListDropDownValue = '-';
  String classListDropDownValue = '-';
  bool isLoading = false;
  void getData(studentKey) {
    setState(() {
      studentListDropDownValue = studentKey;
      isLoading = true;
    });
    if (studentKey == null) {
      setState(() {
        data = null;
        isLoading = false;
      });
    } else {
      RollCallService.dbEkolStudentGetRollCall(studentKey).once().then((snap) {
        setState(() {
          data = snap?.value;
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        topBar: TopBar(
          leadingTitle: 'rcmenuname'.translate,
          trailingActions: [
            if (isWeb)
              MyPopupMenuButton(
                itemBuilder: (context) {
                  return <PopupMenuEntry>[
                    if (isWeb) PopupMenuItem(value: 1, child: Text('exportexcell'.translate)),
                  ];
                },
                child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(right: 8),
                onSelected: (value) {
                  if (value == 1) {
                    RollcallExportHelper.exportAllStudentsAllRollCall();
                  }
                },
              ),
          ],
        ),
        topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: 'rollcallstudentreview'.translate),
          child: Row(
            children: [
              if (AppVar.appBloc.hesapBilgileri.gtM)
                Expanded(
                  flex: 1,
                  child: AdvanceDropdown(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      initialValue: classListDropDownValue,
                      name: 'classlist'.translate,
                      iconData: Icons.class_,
                      searchbarEnableLength: 10,
                      items: AppVar.appBloc.classService!.dataList.map((sinif) => DropdownItem(name: sinif.name, value: sinif.key)).toList()..insert(0, DropdownItem(value: '-', name: 'all'.translate)),
                      onChanged: (dynamic value) {
                        setState(() {
                          classListDropDownValue = value;
                        });
                      }),
                ),
              Expanded(
                flex: 3,
                child: AdvanceDropdown(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    initialValue: studentListDropDownValue,
                    name: 'studentlist'.translate,
                    iconData: Icons.line_style,
                    searchbarEnableLength: 10,
                    items: AppVar.appBloc.studentService!.dataList.where((student) => classListDropDownValue == '-' || student.classKeyList.contains(classListDropDownValue)).map((student) => DropdownItem(name: student.name, value: student.key)).toList()
                      ..insert(0, DropdownItem(value: '-', name: 'choosestudent'.translate)),
                    onChanged: getData),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Body.circularProgressIndicator()
            : data == null
                ? Body.child(child: EmptyState(imgWidth: 50))
                : Body.child(
                    child: EkolRollCallStudentPage(
                    hasScaffold: false,
                    data: data,
                  )));
  }
}

class RollcallExportHelper {
  RollcallExportHelper._();

//? Yazdirilmak istenen gunler [dayText]->['22.01.2022','23.01.2022'] dayData {'22.01.2022'}
  ///Buraya gelen datatada once sinif bilgisi icinde dersler icindede hangi ogrenci geldi hangisi gelmedi var
  ///burada ise bu ogrenci adi ve gelmedigi derslere ceriliyor
  static List<List<String>> _prepareData(List<String> dayTextList, Map<String, Map?> dayData) {
    //{'studentKey':{'dayText':'data'}}
    Map<String, Map> studentDataDaysBayDay = {};

    dayTextList.forEach((dayText) {
      final data = dayData[dayText];
      if (data != null) {
        for (var lessonData in data.values) {
          lessonData.entries.forEach((element) {
            final splittedKey = element.key.split('LN:');
            final lessonKey = splittedKey[0];
            final lessonName = AppVar.appBloc.lessonService!.dataListItem(lessonKey)?.name ?? '?';
            final lessonNo = splittedKey[1];
            element.value.entries.forEach((studentRollCallData) {
              final rollcallValue = studentRollCallData.value;
              if (rollcallValue == 1) {
                final studentKey = studentRollCallData.key;
                studentDataDaysBayDay[studentKey] ??= {};
                final studentData = studentDataDaysBayDay[studentKey]!;
                final existingCachedStudentData = studentData[dayText] ?? '';
                studentData[dayText] = existingCachedStudentData + ' ' + '$lessonName-$lessonNo';
              }
            });
          });
        }
      }
    });
    return ([
      ...studentDataDaysBayDay.entries.map((e) {
        var student = AppVar.appBloc.studentService!.dataListItem(e.key);
        if (student == null) return ['', 'erasedstudent'.translate, '', '', '', ''];
        return [
          student.no!,
          student.name ?? '?',
          (AppVar.appBloc.classService!.dataListItem(student.class0!) ?? (Class()..name = '?')).name!,
          student.motherPhone ?? '?',
          student.fatherPhone ?? '?',
          ...dayTextList.map((dayText) {
            return e.value[dayText] == null ? '' : e.value[dayText].toString();
          }).toList(),
        ];
      }).toList()
    ]..insert(0, [
        "studentno".translate,
        'name'.translate,
        "classtype0".translate,
        'mother'.translate + ' ' + 'phone'.translate,
        'father'.translate + ' ' + 'phone'.translate,
        ...dayTextList,
      ]))
      ..sort((i1, i2) {
        /// Sinif adina gore sirali liste icin
        if (i1.length < 3 || i2.length < 3) return 1;
        if (i1[2] == "classtype0".translate) return -1;
        if (i2[2] == "classtype0".translate) return 1;

        return i1[2].compareTo(i2[2]);
      });
  }

  static Future<void> toExcel(Map? data, String dayText) async {
    final preparedData = _prepareData([dayText], {dayText: data});
    await ExcelLibraryHelper.export(preparedData, 'rollcallinfo'.translate);
    OverAlert.saveSuc();
  }

  static Future<void> toRangeExcel(List<String> _dayTextList, Map<String, Map?> data) async {
    final preparedData = _prepareData(_dayTextList, data);
    await ExcelLibraryHelper.export(preparedData, 'rollcallinfo'.translate);
    OverAlert.saveSuc();
  }

  static void printPDF(Map? data, String dayText) {
    final preparedData = _prepareData([dayText], {dayText: data});
    PrintHelper.printMultiplePagePdf(
      [
        PrintWidgetHelper.myTextContainer(text: 'rollcallinfo'.translate),
        PrintWidgetHelper.makeTable(preparedData[0], preparedData.sublist(1)),
      ],
    );
  }

  static Future<void> exportAllStudentsAllRollCall() async {
    OverLoading.show();
    var snap = await RollCallService.dbEkolAllStudentGetRollCall().once();
    await OverLoading.close();
    if (snap == null) {
      return;
    }

    ///studentKey
    ///  -> GelmedigiGunler(days) -> []
    ///  -> GelmedigiDersller-> {dersName:count}
    ///  -> Gelmedigi  topllam saat -> int
    ///  -> student -> Student()
    Map exportData = {};
    Map cacheData = {};

    Map allData = snap.value;

    allData.forEach((studentKey, studentValue) {
      final Student? student = AppVar.appBloc.studentService!.dataListItem(studentKey);
      if (student != null) {
        (studentValue as Map).forEach((dateLessonNo, data) {
          Map rollCallData = data;

          if (rollCallData['value'] == 1) {
            final lessonKey = rollCallData['lessonKey'];
            final splittedKey = dateLessonNo.split('LN:');
            final date = splittedKey[0];

            String? lessonName = cacheData["lesson$lessonKey"];
            if (lessonName == null) {
              final lesson = AppVar.appBloc.lessonService!.dataListItem(lessonKey);
              lessonName = lesson?.name ?? 'erasedlesson'.translate;
              cacheData["lesson$lessonKey"] = lessonName;
            }
            // ignore: unused_local_variable
            final lessonNo = splittedKey[1];
            //todo burda date fieldine bakarak istedigin  tarihe  gorede cikartma yaptirtabilirsin
            exportData[studentKey] ??= {};
            exportData[studentKey]['student'] ??= student;
            exportData[studentKey]['days'] ??= <dynamic>{};
            (exportData[studentKey]['days'] as Set).add(date);
            exportData[studentKey]['lessons'] ??= {};
            exportData[studentKey]['lessons'][lessonName] ??= 0;
            exportData[studentKey]['lessons'][lessonName] = (exportData[studentKey]['lessons'][lessonName] as int) + 1;
          }
        });
      }
    });

    final lastData = <List<String?>>[
      ...exportData.entries.map((e) {
        final Student student = e.value['student'];

        return <String?>[
          student.no,
          student.name ?? '?',
          (AppVar.appBloc.classService!.dataListItem(student.class0!) ?? (Class()..name = '?')).name,
          (e.value['days'] as Set).length.toString(),
          (e.value['lessons'] as Map).entries.fold(0, (dynamic p, e) => p + e.value).toString(),
          (e.value['days'] as Set).fold<String>('', ((p, e) => p + e + ' ')),
          (e.value['lessons'] as Map).entries.fold('', (dynamic p, e) => p + e.key + ': ' + e.value.toString() + ' / ').toString(),
        ];
      }).toList()
    ]..insert(0, [
        "studentno".translate,
        'name'.translate,
        "classtype0".translate,
        "rollcall1datecount".translate,
        "rollcall1hours".translate,
        "rollcall1datedays".translate,
        "lessons".translate,
      ]);
    await ExcelLibraryHelper.export(lastData, 'rollcallinfo'.translate);
  }
}
