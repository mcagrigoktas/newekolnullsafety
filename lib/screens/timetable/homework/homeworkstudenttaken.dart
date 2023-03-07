import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../hwwidget.dart';
import '../modelshw.dart';

const _kShowLessonNotesPrefsKey = 'showLessonNotesP';

class HomeWorkStudentTaken extends StatefulWidget {
  HomeWorkStudentTaken();

  @override
  _HomeWorkStudentTakenState createState() => _HomeWorkStudentTakenState();
}

class _HomeWorkStudentTakenState extends State<HomeWorkStudentTaken> {
  String? studentKey;
  List<HomeWork>? hwList;
  bool loading = false;

  String classListDropDownValue = '-';
  String? filteredLesson;

  List<Student>? _studentList;
  @override
  void initState() {
    _studentList = AppFunctions2.getStudentListForTeacherAndManager();
    super.initState();
  }

  void onChangeStudent(key) {
    setState(() {
      filteredLesson = null;
      studentKey = key;
      hwList = null;
      if (studentKey != null) {
        getData();
        loading = true;
      }
    });
  }

  void onChangeLesson(key) {
    setState(() {
      filteredLesson = key;
    });
  }

  void getData() {
    HomeWorkService.dbUserHomeWorkRef(studentKey).once().then((snap) {
      hwList = [];
      if (snap?.value == null) {
      } else {
        (snap!.value as Map).forEach((key, value) {
          ///Guvenlik
          if ((value as Map).containsKey('senderKey')) {
            hwList!.add(HomeWork.fromJson(value, key));
          }
        });
        hwList!.removeWhere((item) => item.aktif == false);
        hwList!.sort((a, b) => b.timeStamp - a.timeStamp);
      }
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Student? student = AppVar.appBloc.studentService!.dataList.singleWhereOrNull((student) => student.key == studentKey);

    late List<DropdownItem<String>> lessonDropDownList;

    if (student != null) {
      lessonDropDownList = AppVar.appBloc.lessonService!.dataList.where((lesson) => student.classKeyList.contains(lesson.classKey)).map((lesson) {
        return DropdownItem<String>(value: lesson.key, name: lesson.name);
      }).toList();
      lessonDropDownList.insert(0, DropdownItem<String>(value: null, name: "all".translate));
    }

    List<HomeWork>? filteredList;
    if (hwList != null) {
      filteredList = hwList!.where((hw) => filteredLesson == null || hw.lessonKey == filteredLesson).toList();
      if (Fav.preferences.getBool(_kShowLessonNotesPrefsKey, true) == false) filteredList = filteredList.where((element) => element.tur != 3).toList();
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate, trailingActions: [
        MyPopupMenuButton(
          child: Icons.more_vert.icon.color(Fav.design.appBar.text).make(),
          onSelected: (value) {
            if (value == '0') {
              setState(() {
                final _existingValue = Fav.preferences.getBool(_kShowLessonNotesPrefsKey, true)!;
                Fav.preferences.setBool(_kShowLessonNotesPrefsKey, !_existingValue);
              });
            }
          },
          itemBuilder: (context) {
            return <PopupMenuEntry>[
              PopupMenuItem(value: '0', child: Text('tooglenotes'.translate)),
            ];
          },
        ),
      ]),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(
            title: AppVar.appBloc.hesapBilgileri.gtT ? 'hwstudenttaken'.translate : 'hwstudenttaken'.translate,
          ),
          child: Column(
            children: [
              Row(
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
                      initialValue: studentKey,
                      name: "choosestudent".translate,
                      iconData: MdiIcons.accountMultiple,
                      items: _studentList!.where((student) => classListDropDownValue == '-' || student.classKeyList.contains(classListDropDownValue)).map((student) {
                        return DropdownItem<String>(value: student.key, name: student.name);
                      }).toList()
                        ..insert(0, DropdownItem<String>(value: null, name: "choosestudent".translate)),
                      onChanged: onChangeStudent,
                    ),
                  ),
                ],
              ),
              if (student != null)
                AdvanceDropdown(
                  initialValue: filteredLesson,
                  name: "chooselesson".translate,
                  iconData: MdiIcons.viewList,
                  items: lessonDropDownList,
                  onChanged: onChangeLesson,
                ),
            ],
          )),
      body: loading
          ? Body.circularProgressIndicator()
          : (filteredList == null || filteredList.isEmpty)
              ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
              : Body.listviewBuilder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => HomeWorkWidget(
                        showLessonName: true,
                        publishButton: false,
                        checkButton: false,
                        deleteButton: false,
                        homeWork: filteredList![index],
                        dividerStyle: filteredList.length == 1 ? 3 : (index == 0 ? 0 : (index == filteredList.length - 1 ? 2 : 1)),
                      )),
    );
  }
}
