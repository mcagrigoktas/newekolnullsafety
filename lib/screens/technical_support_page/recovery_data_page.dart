import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import 'model.dart';

class RecoverPage extends StatefulWidget {
  final int? tur; //0 ogrenci geri getirme,1 Sinif, 2 ogretmen 3 ders
  RecoverPage({this.tur});

  @override
  _RecoverPageState createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  Map? dataMap;
  List<RecoverData> infoList = [];

  String getMenuname() {
    if (widget.tur == 0) return "recoverstudent".translate;
    if (widget.tur == 1) return "recoverclass".translate;
    if (widget.tur == 2) return "recoverteacher".translate;
    if (widget.tur == 3) return "recoverlesson".translate;
    return '';
  }

  @override
  void initState() {
    super.initState();
    if (widget.tur == 0) dataMap = Map.from(AppVar.appBloc.studentService!.data);
    if (widget.tur == 1) dataMap = Map.from(AppVar.appBloc.classService!.data);
    if (widget.tur == 2) dataMap = Map.from(AppVar.appBloc.teacherService!.data);
    if (widget.tur == 3) dataMap = Map.from(AppVar.appBloc.lessonService!.data);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? getClassName(classKey) {
    var sinif = AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => classKey == sinif.key);
    if (sinif != null) {
      return sinif.name;
    }
    return 'erasedclass'.translate;
  }

  Future<void> recover(String? key) async {
    if (Fav.noConnection()) return;

    var sure = await Over.sure(message: 'dangerrecover'.translate);
    if (sure == true) {
      if (widget.tur == 0) {
        await StudentService.deleteStudent(key!, recover: true).then((_) {
          Get.back();
          OverAlert.saveSuc();
        }).catchError((_) {
          OverAlert.saveErr();
        });
      } else if (widget.tur == 1) {
        await ClassService.deleteClass(key!, recover: true).then((_) {
          Get.back();
          OverAlert.saveSuc();
        }).catchError((_) {
          OverAlert.saveErr();
        });
      } else if (widget.tur == 2) {
        await TeacherService.deleteTeacher(key!, recover: true).then((_) {
          Get.back();
          OverAlert.saveSuc();
        }).catchError((_) {
          OverAlert.saveErr();
        });
      } else if (widget.tur == 3) {
        await LessonService.deleteLesson(key!, recover: true).then((_) {
          Get.back();
          OverAlert.saveSuc();
        }).catchError((_) {
          OverAlert.saveErr();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataMap != null) {
      infoList.clear();
      dataMap!.forEach((key, value) {
        if (widget.tur == 0) {
          Student student = Student.fromJson(value, key);
          if (!student.aktif) infoList.add(RecoverData(key: student.key, name: student.name, data2: student.tc));
        }
        if (widget.tur == 1) {
          Class sinif = Class.fromJson(value, key);
          if (!sinif.aktif!) infoList.add(RecoverData(key: sinif.key, name: sinif.name, data2: ''));
        }
        if (widget.tur == 2) {
          Teacher teacher = Teacher.fromJson(value, key);
          if (!teacher.aktif) infoList.add(RecoverData(key: teacher.key, name: teacher.name, data2: teacher.tc));
        }
        if (widget.tur == 3) {
          Lesson lesson = Lesson.fromJson(value, key);
          if (!lesson.aktif!) infoList.add(RecoverData(key: lesson.key, name: lesson.name, data2: getClassName(lesson.classKey)));
        }
      });
      infoList.sort((a, b) => a.name!.compareTo(b.name!));
    }

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'callcenter'.translate,
      ),
      topActions: TopActionsTitle(title: getMenuname()),
      body: dataMap == null
          ? Body.circularProgressIndicator()
          : Body.singleChildScrollView(
              child: Column(
                children: infoList
                    .map((item) => GestureDetector(
                          onTap: () {
                            recover(item.key);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              children: [
                                Text(item.name ?? '', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                                Text(item.data2 ?? '', style: TextStyle(color: Fav.design.primaryText)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
    );
  }
}
