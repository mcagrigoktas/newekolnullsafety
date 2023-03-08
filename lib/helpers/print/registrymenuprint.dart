import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../appbloc/appvar.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../screens/managerscreens/registrymenu/preregistration/model.dart';
import '../apphelpers.dart';
import 'printhelper.dart';

class RegistryMenuPrint {
  RegistryMenuPrint._();
  static String formatDate(int? date) {
    if (date is! int) return '';
    return date.dateFormat("d-MMM-yyyy");
  }

  static Map<String, List> studentDataHelper = {
    '1': ["studentno".translate, (Student student) => student.no],
    '2': ['classtype0'.translate, (Student student) => AppVar.appBloc.classService?.dataListItem(student.class0!)?.name ?? '-'],
    '3': ['genre'.translate, (Student student) => student.genre == true ? "genre2".translate : "genre1".translate],
    '4': ['username'.translate, (Student student) => student.username],
    '5': ['password'.translate, (Student student) => student.passwordChangedByUser == true ? '******' : student.password],
    '14': ['parentpassword'.translate, (Student student) => AppHelpers.passwordToParentPassword(student.password!)],
    '6': ['tc'.translate, (Student student) => student.tc],
    '7': ["student".translate + " " + "phone".translate, (Student student) => student.studentPhone],
    '8': ['adress'.translate, (Student student) => student.adress],
    '9': ['birthday'.translate, (Student student) => formatDate(student.birthday)],
    '10': ["father".translate + " " + "name2".translate, (Student student) => student.fatherName],
    '11': ["father".translate + " " + "phone".translate, (Student student) => student.fatherPhone],
    '12': ["mother".translate + " " + "name2".translate, (Student student) => student.motherName],
    '13': ["mother".translate + " " + "phone".translate, (Student student) => student.motherPhone],
  };
  static Map<String, List> teacherDataHelper = {
    '1': ['tc'.translate, (Teacher teacher) => teacher.tc],
    '2': ['username'.translate, (Teacher teacher) => teacher.username],
    '3': ['password'.translate, (Teacher teacher) => teacher.passwordChangedByUser == true ? '******' : teacher.password],
    '4': ['birthday'.translate, (Teacher teacher) => formatDate(teacher.birthday)],
    '5': ["phone".translate, (Teacher teacher) => teacher.phone],
    '6': ["mail".translate, (Teacher teacher) => teacher.mail],
    '7': ['adress'.translate, (Teacher teacher) => teacher.adress],
  };
  static Map<String, List> preRegisterDataHelper = {
    '1': ['tc'.translate, (PreRegisterModel student) => student.tc],
    '2': ['birthday'.translate, (PreRegisterModel student) => formatDate(student.birthday)],
    '3': ['genre'.translate, (PreRegisterModel student) => student.gender == true ? "genre2".translate : "genre1".translate],
    '4': ["father".translate + " " + "name2".translate, (PreRegisterModel student) => student.fatherName],
    '5': ["father".translate + " " + "phone".translate, (PreRegisterModel student) => student.fatherPhone],
    '6': ["mother".translate + " " + "name2".translate, (PreRegisterModel student) => student.motherName],
    '7': ["mother".translate + " " + "phone".translate, (PreRegisterModel student) => student.motherPhone],
    '8': ["aciklama".translate, (PreRegisterModel student) => student.explanation],
    '9': ["note".translate + '1', (PreRegisterModel student) => student.not1],
    '10': ["note".translate + '2', (PreRegisterModel student) => student.not2],
    '11': ["note".translate + '3', (PreRegisterModel student) => student.not3],
  };
  static Future<void> printStudentList(BuildContext context) async {
    Map printData = {};
    GlobalKey<FormState> formKey = GlobalKey();
    bool cancel = false;
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Material(
              color: Colors.transparent,
              child: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                      decoration: BoxDecoration(color: Fav.design.scaffold.background, borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          MyDropDownField(
                            iconData: Icons.class_,
                            name: 'classlist'.translate,
                            canvasColor: Fav.design.dropdown.canvas,
                            items: AppVar.appBloc.classService!.dataList.map((sinif) => DropdownMenuItem(child: Text(sinif.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Fav.design.primaryText)), value: sinif.key)).toList()
                              ..insert(0, DropdownMenuItem(child: Text('all'.translate, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Fav.design.primaryText.withAlpha(150))), value: 'all'))
                            //  ..add(DropdownMenuItem(child: Text( 'noclassstudent'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color:  Fav.design.primaryText)), value: 'noclass'))
                            ,
                            onSaved: (value) {
                              printData['class'] = value;
                            },
                            initialValue: 'all',
                          ),
                          MyMultiSelect(
                            iconData: Icons.playlist_add_check,
                            title: 'printtext1'.translate,
                            initialValue: [],
                            validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 5),
                            onSaved: (value) {
                              printData['printlist'] = value;
                            },
                            items: studentDataHelper.entries
                                .map(
                                  (e) => MyMultiSelectItem(e.key, e.value.first),
                                )
                                .toList(),
                            name: 'printtext1'.translate,
                            context: context,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyRaisedButton(
                                text: 'cancel'.translate,
                                onPressed: () {
                                  cancel = true;
                                  Get.back();
                                },
                              ),
                              MyRaisedButton(
                                text: 'next'.translate,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    printData.clear();
                                    formKey.currentState!.save();

                                    final doc = pw.Document();
                                    PrintHelper.printMultiplePagePdf([
                                      PrintWidgetHelper.myTextContainer(text: 'studentlist'.translate),
                                      PrintWidgetHelper.makeTable(
                                          List<String>.from((printData['printlist'] as List).map((e) => studentDataHelper[e]!.first).toList()..insert(0, 'name'.translate)),
                                          AppVar.appBloc.studentService!.dataList
                                              .where((student) {
                                                return printData['class'] == 'all' || student.classKeyList.any((classname) => classname == printData['class']);
                                              })
                                              .map((student) => List<String>.from((printData['printlist'] as List).map((e) {
                                                    return studentDataHelper[e]!.last(student);
                                                  }).toList())
                                                    ..insert(0, student.name))
                                              .toList())
                                    ], doc: doc);

                                    Get.back();
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (cancel) return;
  }

  static Future<void> printTeacherList(BuildContext context) async {
    Map printData = {};
    GlobalKey<FormState> formKey = GlobalKey();
    bool cancel = false;
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Material(
              color: Colors.transparent,
              child: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                      decoration: BoxDecoration(color: Fav.design.scaffold.background, borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          MyMultiSelect(
                            iconData: Icons.playlist_add_check,
                            title: 'printtext1'.translate,
                            initialValue: [],
                            validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 5),
                            onSaved: (value) {
                              printData['printlist'] = value;
                            },
                            items: teacherDataHelper.entries
                                .map(
                                  (e) => MyMultiSelectItem(e.key, e.value.first),
                                )
                                .toList(),
                            name: 'printtext1'.translate,
                            context: context,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyRaisedButton(
                                text: 'cancel'.translate,
                                onPressed: () {
                                  cancel = true;
                                  Get.back();
                                },
                              ),
                              MyRaisedButton(
                                text: 'next'.translate,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    printData.clear();
                                    formKey.currentState!.save();

                                    final doc = pw.Document();
                                    PrintHelper.printMultiplePagePdf(
                                      [
                                        PrintWidgetHelper.myTextContainer(text: Words.teacherList),
                                        PrintWidgetHelper.makeTable(
                                            List<String>.from((printData['printlist'] as List).map((e) => teacherDataHelper[e]!.first).toList()..insert(0, 'name'.translate)),
                                            AppVar.appBloc.teacherService!.dataList
                                                .map((teacher) => List<String>.from((printData['printlist'] as List).map((e) {
                                                      return teacherDataHelper[e]!.last(teacher);
                                                    }).toList())
                                                      ..insert(0, teacher.name))
                                                .toList())
                                      ],
                                      doc: doc,
                                    );

                                    Get.back();
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (cancel) return;
  }

  static Future<void> printPreRegisterList(BuildContext context, List<PreRegisterModel> preRegisterList) async {
    Map printData = {};
    GlobalKey<FormState> formKey = GlobalKey();
    bool cancel = false;
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Material(
              color: Colors.transparent,
              child: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                      decoration: BoxDecoration(color: Fav.design.scaffold.background, borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          MyDropDownField(
                            iconData: Icons.class_,
                            name: 'status'.translate,
                            canvasColor: Fav.design.dropdown.canvas,
                            items: [
                              DropdownMenuItem(child: Text('preregisterstatus1'.translate), value: PreRegisterStatus.aktif),
                              DropdownMenuItem(child: Text('preregisterstatus2'.translate), value: PreRegisterStatus.saved),
                              DropdownMenuItem(child: Text('preregisterstatus3'.translate), value: PreRegisterStatus.cancelled),
                            ],
                            onSaved: (value) {
                              printData['state'] = value;
                            },
                            initialValue: PreRegisterStatus.aktif,
                          ),
                          MyMultiSelect(
                            iconData: Icons.playlist_add_check,
                            title: 'printtext1'.translate,
                            initialValue: [],
                            validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 5),
                            onSaved: (value) {
                              printData['printlist'] = value;
                            },
                            items: preRegisterDataHelper.entries
                                .map(
                                  (e) => MyMultiSelectItem(e.key, e.value.first),
                                )
                                .toList(),
                            name: 'printtext1'.translate,
                            context: context,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyRaisedButton(
                                text: 'cancel'.translate,
                                onPressed: () {
                                  cancel = true;
                                  Get.back();
                                },
                              ),
                              MyRaisedButton(
                                text: 'next'.translate,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    printData.clear();
                                    formKey.currentState!.save();

                                    final doc = pw.Document();
                                    PrintHelper.printMultiplePagePdf([
                                      PrintWidgetHelper.myTextContainer(text: 'preregister'.translate),
                                      PrintWidgetHelper.makeTable(
                                          List<String>.from((printData['printlist'] as List).map((e) => preRegisterDataHelper[e]!.first).toList()..insert(0, 'name'.translate)),
                                          preRegisterList
                                              .where((student) => student.status == printData['state'])
                                              .map((student) => List<String>.from((printData['printlist'] as List).map((e) {
                                                    return preRegisterDataHelper[e]!.last(student);
                                                  }).toList())
                                                    ..insert(0, student.name!))
                                              .toList())
                                    ], orientation: pw.PageOrientation.landscape, doc: doc);

                                    Get.back();
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (cancel) return;
  }
}
