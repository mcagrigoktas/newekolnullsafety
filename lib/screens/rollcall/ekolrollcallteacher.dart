import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../services/pushnotificationservice.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import 'model.dart';

class EkolRollCallTeacher extends StatefulWidget {
  final Class sinif;
  final Lesson? lesson;
  final bool forOnlineLesson;
  final List onlineLessonOnlinePeopleData;
  EkolRollCallTeacher({required this.sinif, this.lesson, this.forOnlineLesson = false, this.onlineLessonOnlinePeopleData = const []});

  @override
  _EkolRollCallTeacherState createState() => _EkolRollCallTeacherState();
}

class _EkolRollCallTeacherState extends State<EkolRollCallTeacher> {
  GlobalKey<FormState> formKey = GlobalKey();
  Map rollCallDataForTeacherExistingData = {};
  Map rollCallDataForTeacher = {};
  Map rollCallDataForStudentPortfolio = {};
  DateTime? time;
  List<int?> lessonNumbers = [];
  String? dangerText;
  bool schoolHasTimetable = true;
  int? lessonNo;
  bool isLoading = true;

  void save() {
    if (Fav.noConnection()) return;

    time ??= DateTime.now();

    if (time!.dateFormat("d-MM-yyyy") != DateTime.now().dateFormat("d-MM-yyyy")) {
      OverAlert.show(message: "errtimedevice".translate, type: AlertType.danger);
      return;
    }

    rollCallDataForTeacher = {};
    rollCallDataForStudentPortfolio = {};
    formKey.currentState!.save();
    if (rollCallDataForTeacher.keys.isEmpty) return;

    Map<String, RollCallStudentModel> studentData = {};
    rollCallDataForStudentPortfolio.forEach((studentKey, value) {
      studentData[studentKey] = RollCallStudentModel(
        date: DateTime.now().millisecondsSinceEpoch,
        lessonKey: widget.lesson!.key,
        lessonName: widget.lesson!.longName,
        classKey: widget.sinif.key,
        isEkid: false,
        value: value,
        lessonNo: lessonNo,
      );
    });

    if (rollCallDataForStudentPortfolio.keys.isEmpty) {
      rollCallDataForStudentPortfolio = {'full': true};
    }
    setState(() {
      isLoading = true;
    });

    final String dateKey = time!.dateFormat("d-MM-yyyy");

    RollCallService.addEkolRollCall(dateKey, widget.sinif.key!, lessonNo, widget.lesson!.key! + 'LN:' + lessonNo.toString(), rollCallDataForTeacher, studentData).then((_) {
      OverAlert.show(message: 'rollcallsavehint'.argsTranslate({'className': widget.sinif.name, 'no': lessonNo, 'lessonName': widget.lesson!.longName}));
      setState(() {
        isLoading = false;
      });
      if (UserPermissionList.hasRollcallAutoNotification()) {
        sendNotification();
      }
      Get.back();
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  @override
  void initState() {
    super.initState();

    time = DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime);
    calcLessonNumber();
    getExistingData();
  }

  void sendNotification() {
    List<String?> rollcall1 = [];
    List<String?> rollcall2 = [];
    List<String?> rollcall3 = [];
    List<String?> rollcall4 = [];
    List<String?> rollcall5 = [];
    rollCallDataForTeacher.forEach((studentKey, value) {
      if (value == 1) {
        rollcall1.add(studentKey);
      } else if (value == 2) {
        rollcall2.add(studentKey);
      } else if (value == 3) {
        rollcall3.add(studentKey);
      } else if (value == 4) {
        rollcall4.add(studentKey);
      } else if (value == 5) {
        rollcall5.add(studentKey);
      }
    });

    if (rollcall1.isNotEmpty) {
      EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallsnotify'.argsTranslate({'lessonName': widget.lesson!.longName}) + ' ' + 'rollcall1'.translate, rollcall1, NotificationArgs.generally());
    }
    if (rollcall2.isNotEmpty) {
      EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallsnotify'.argsTranslate({'lessonName': widget.lesson!.longName}) + ' ' + 'rollcall2'.translate, rollcall2, NotificationArgs.generally());
    }
    if (rollcall3.isNotEmpty) {
      EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallsnotify'.argsTranslate({'lessonName': widget.lesson!.longName}) + ' ' + 'rollcall3'.translate, rollcall3, NotificationArgs.generally());
    }
    if (rollcall4.isNotEmpty) {
      EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallsnotify'.argsTranslate({'lessonName': widget.lesson!.longName}) + ' ' + 'rollcall4'.translate, rollcall4, NotificationArgs.generally());
    }
    if (rollcall5.isNotEmpty) {
      EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcallsnotify'.argsTranslate({'lessonName': widget.lesson!.longName}) + ' ' + 'rollcall5'.translate, rollcall5, NotificationArgs.generally());
    }
  }

  void calcLessonNumber() {
    var now = DateTime.now();

    int programdakiDersSayisi = 0;
    if (AppVar.appBloc.tableProgramService!.takeData(1).entries.length == 1) {
      AppVar.appBloc.tableProgramService!.takeData(1).entries.first.value['classProgram'][widget.sinif.key]?.forEach((dayhour, lessonKey) {
        programdakiDersSayisi++;
        if (lessonKey == widget.lesson!.key) {
          final String day = dayhour.split('-').first;
          final String? hour = dayhour.split('-').last;
          if (DateTime(2019, 7, int.tryParse(day)!).dateFormat('EEE') == now.dateFormat("EEE")) {
            lessonNumbers.add(int.tryParse(hour!));
          }
        }
      });
    }
    if (programdakiDersSayisi < 3) {
      schoolHasTimetable = false;
      lessonNumbers = List<int?>.from(Iterable.generate(15).map((number) => number + 1));
    }
    if (lessonNumbers.isNotEmpty) {
      lessonNo = lessonNumbers.first;
    }
  }

  void getExistingData() {
    if (lessonNo != null) {
      setState(() {
        isLoading = true;
      });
      rollCallDataForTeacher = {};
      final String dateKey = (time ?? DateTime.now()).dateFormat("d-MM-yyyy");
      RollCallService.dbGetEkolRollCall(dateKey, widget.sinif.key!, widget.lesson!.key! + 'LN:' + lessonNo.toString()).once().then((snap) {
        rollCallDataForTeacher = snap?.value ?? {};
        rollCallDataForTeacherExistingData = Map.from(snap?.value ?? {});
        formKey = GlobalKey();
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
        hideBackButton: widget.forOnlineLesson,
        leadingTitle: widget.lesson!.name,
        trailingActions: (!(schoolHasTimetable && lessonNumbers.isEmpty))
            ? <Widget>[
                isLoading
                    ? MyProgressIndicator(
                        color: Fav.design.appBar.text,
                        size: 18,
                        isCentered: true,
                        padding: const EdgeInsets.only(right: 12),
                      )
                    : IconButton(
                        onPressed: save,
                        icon: Icon(
                          Icons.save,
                          color: Fav.design.appBar.text,
                        ),
                      ),
              ]
            : null,
      ),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: 'makerollcall'.translate),
          child: Column(
            children: [
              (time ?? DateTime.now()).dateFormat("d-MMM-yyyy EEEE").text.make(),
            ],
          )),
      body: schoolHasTimetable && lessonNumbers.isEmpty
          ? Body.child(
              child: EmptyState(text: 'nolessonthisday'.translate),
            )
          : Body.singleChildScrollView(
              maxWidth: 540,
              child: MyForm(
                formKey: formKey,
                child: Column(
                  children: <Widget>[
                    8.heightBox,
                    MyDropDownField(
                      onChanged: (value) {
                        lessonNo = value;
                        getExistingData();
                      },
                      initialValue: lessonNo,
                      onSaved: (value) {
                        lessonNo = value;
                      },
                      name: 'rcchooselessonno'.translate,
                      iconData: Icons.art_track,
                      color: Colors.deepPurpleAccent,
                      items: lessonNumbers
                          .map((no) => DropdownMenuItem(
                                child: Text(
                                  '${'lesson'.translate} $no',
                                  style: TextStyle(color: Fav.design.primaryText),
                                ),
                                value: no,
                              ))
                          .toList(),
                    ),
                    if (!schoolHasTimetable)
                      Text(
                        'rcnoprogram'.translate,
                        style: TextStyle(color: Fav.design.primaryText, fontSize: 10),
                      ),
                    8.heightBox,
                    ...AppVar.appBloc.studentService!.dataList
                        .where((student) {
                          return student.classKeyList.contains(widget.sinif.key);
                          //todo burasi asiri supheli
                          // if(widget.sinif.classType==0&&student.class0==widget.sinif.key){return true;}if(widget.sinif.classType==1&&student.class1==widget.sinif.key){return true;}return false;
                        })
                        .map(
                          (student) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                            child: Row(
                              children: <Widget>[
                                if (student.imgUrl?.startsWithHttp ?? false)
                                  CircularProfileAvatar(
                                    imageUrl: student.imgUrl,
                                    radius: 18,
                                  ),
                                if (student.imgUrl?.startsWithHttp ?? false) 8.widthBox,
                                Expanded(flex: 2, child: Text(student.name, style: TextStyle(color: Fav.design.primaryText))),
                                8.widthBox,
                                MyDropDownFieldOld(
                                  onSaved: (value) {
                                    rollCallDataForTeacher[student.key] = value;
                                    if (value != 0 || (rollCallDataForTeacherExistingData[student.key] != null && rollCallDataForTeacherExistingData[student.key] != 0)) {
                                      rollCallDataForStudentPortfolio[student.key] = value;
                                    }
                                  },
                                  initialValue: widget.forOnlineLesson
                                      ? (widget.onlineLessonOnlinePeopleData.contains(student.key)
                                          ? 0
                                          : (rollCallDataForTeacher[student.key] ?? 1) > 2
                                              ? 1
                                              : (rollCallDataForTeacher[student.key] ?? 1))
                                      : (rollCallDataForTeacher[student.key] ?? 0),
                                  canvasColor: Colors.white,
                                  padding: const EdgeInsets.all(0.0),
                                  arrowIcon: false,
                                  isExpanded: false,
                                  items: <List>[
                                    [0, Colors.green, 'rollcall0'],
                                    [1, Colors.red, 'rollcall1'],
                                    [2, Colors.deepOrangeAccent, 'rollcall2'],
                                    if (!widget.forOnlineLesson) [3, Colors.amber, 'rollcall3'],
                                    if (!widget.forOnlineLesson) [4, Colors.indigoAccent, 'rollcall4'],
                                    if (!widget.forOnlineLesson) [5, Colors.deepPurpleAccent, 'rollcall5'],
                                  ]
                                      .map((e) => DropdownMenuItem(
                                            child: Container(
                                              width: 90,
                                              height: 28,
                                              alignment: Alignment.center,
                                              decoration: ShapeDecoration(shape: const StadiumBorder(), color: e[1]),
                                              child: Text(
                                                (e[2] as String).translate,
                                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                            ),
                                            value: e[0],
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
