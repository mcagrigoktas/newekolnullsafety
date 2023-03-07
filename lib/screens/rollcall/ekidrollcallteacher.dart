import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../services/dataservice.dart';
import '../../services/pushnotificationservice.dart';
import 'model.dart';

class EkidRollCallTeacher extends StatefulWidget {
  final String sinif;
  EkidRollCallTeacher({required this.sinif});

  @override
  _EkidRollCallTeacherState createState() => _EkidRollCallTeacherState();
}

class _EkidRollCallTeacherState extends State<EkidRollCallTeacher> {
  GlobalKey<FormState> formKey = GlobalKey();
  Map rollCallData = {};
  DateTime? time;
  String? dangerText;
  int? lessonNo;
  bool isLoading = true;

  void save() {
    if (Fav.noConnection()) return;

    time ??= DateTime.now();
    if (time!.dateFormat("d-MM-yyyy") != DateTime.now().dateFormat("d-MM-yyyy")) {
      OverAlert.show(message: "errtimedevice".translate, type: AlertType.danger);
      return;
    }

    rollCallData = {};
    formKey.currentState!.save();
    if (rollCallData.isEmpty) return;

    final String dateKey = time!.dateFormat("d-MM-yyyy");
    Map<String?, RollCallStudentModel> studentData = {};
    rollCallData.forEach((studentKey, value) {
      studentData[studentKey] = RollCallStudentModel(
        classKey: widget.sinif,
        value: value,
        date: DateTime.now().millisecondsSinceEpoch,
        isEkid: true,
      );
    });

    setState(() {
      isLoading = true;
    });

    RollCallService.addEkidRollCall(dateKey, widget.sinif, rollCallData, studentData).then((_) {
      OverAlert.saveSuc();
      setState(() {
        isLoading = false;
      });
      sendNotification();
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

    trueTimeCount();
    getExistingData();
  }

  void trueTimeCount() {
    time = DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime);
    setState(() {});
  }

  void sendNotification() {
    List<String?> rollcall1 = [];
    rollCallData.forEach((studentKey, value) {
      if (value == 1) {
        rollcall1.add(studentKey);
      }
    });

    if (rollcall1.isNotEmpty) {
      EkolPushNotificationService.sendMultipleNotification('rollcallnotify'.translate, 'rollcall1'.translate, rollcall1, NotificationArgs.generally());
    }
  }

  void getExistingData() {
    setState(() {
      isLoading = true;
    });
    rollCallData = {};
    final String dateKey = (time ?? DateTime.now()).dateFormat("d-MM-yyyy");
    RollCallService.dbGetEkidRollCall(dateKey, widget.sinif).once().then((snap) {
      rollCallData = snap?.value ?? {};
      formKey = GlobalKey();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'dailyreport'.translate,
        trailingActions: <Widget>[
          isLoading
              ? MyProgressIndicator(
                  color: Fav.design.appBar.text,
                  size: 18,
                  isCentered: true,
                  padding: const EdgeInsets.only(right: 12),
                )
              : IconButton(
                  onPressed: save,
                  icon: Icon(Icons.save, color: Fav.design.appBar.text),
                ),
        ],
      ),
      topActions: TopActionsTitleWithChild(
          child: (time ?? DateTime.now()).dateFormat("d-MMM-yyyy EEEE").text.make(),
          title: TopActionsTitle(
            title: 'makerollcall'.translate,
          )),
      body: isLoading
          ? Body.circularProgressIndicator()
          : Body.singleChildScrollView(
              maxWidth: 540,
              child: MyForm(
                formKey: formKey,
                child: Column(
                  children: <Widget>[
                    8.heightBox,
                    ...AppVar.appBloc.studentService!.dataList
                        .where((student) => student.class0 == widget.sinif)
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
                                if (student.imgUrl?.startsWith('http') ?? false) 8.widthBox,
                                Expanded(flex: 2, child: Text(student.name!, style: TextStyle(color: Fav.design.primaryText))),
                                8.widthBox,
                                MyDropDownFieldOld(
                                  onSaved: (value) {
                                    rollCallData[student.key] = value;
                                  },
                                  initialValue: rollCallData[student.key] ?? 0,
                                  canvasColor: Colors.white,
                                  padding: const EdgeInsets.all(0.0),
                                  arrowIcon: false,
                                  isExpanded: false,
                                  items: [
                                    DropdownMenuItem(
                                      child: Container(
                                        width: 90,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: const ShapeDecoration(shape: StadiumBorder(), color: Colors.green),
                                        child: Text(
                                          'rollcall0'.translate,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                      value: 0,
                                    ),
                                    DropdownMenuItem(
                                      child: Container(
                                        width: 90,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: const ShapeDecoration(shape: StadiumBorder(), color: Colors.red),
                                        child: Text(
                                          'rollcall1'.translate,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                      value: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
            ),
    );
  }
}
