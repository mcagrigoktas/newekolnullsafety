import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';
import '../library_helper/excel/eager.dart';
import '../localization/usefully_words.dart';

class ExportHelper {
  ExportHelper._();

  static String formatDate(int? date) {
    if (date is! int) return '';
    return date.dateFormat("d-MMM-yyyy");
  }

  static List<List<dynamic>> setupStudentList({String? studentKey, String classKey = 'all'}) {
    List<List<dynamic>> data = AppVar.appBloc.studentService!.dataList
        .where((element) {
          if (studentKey != null) return element.key == studentKey;
          return true;
        })
        .where((element) {
          if (classKey == 'all') return true;
          return element.classKeyList.contains(classKey);
        })
        .map((e) => [
              e.no,
              e.name,
              AppVar.appBloc.classService?.dataListItem(e.class0!)?.name ?? '-',
              e.genre == true ? "genre2".translate : "genre1".translate,
              e.username,
              e.passwordChangedByUser == true ? '******' : e.password,
              //  AppHelpers.passwordToParentPassword(e.password),
              e.tc,
              formatDate(e.startTime),
              e.studentPhone,
              e.adress,
              e.allergy,
              formatDate(e.birthday),
              e.blood,
              e.explanation,
              e.fatherName,
              e.fatherPhone,
              e.fatherMail,
              e.fatherJob,
              formatDate(e.fatherBirthday),
              e.motherName,
              e.motherPhone,
              e.motherMail,
              e.motherJob,
              formatDate(e.motherBirthday),
              AppVar.appBloc.transporterService?.dataListItem(e.transporter!)?.employeeName ?? '-',
            ])
        .toList();

    data.insert(0, [
      "studentno".translate,
      'namesurname'.translate,
      'classtype0'.translate,
      'genre'.translate,
      'username'.translate,
      'password'.translate,
      // 'parentpassword'.translate,
      'tc'.translate,
      'starttime'.translate,
      "student".translate + " " + "phone".translate,
      'adress'.translate,
      'allergy'.translate,
      'birthday'.translate,
      'bloodgenre'.translate,
      'aciklama'.translate,
      "father".translate + " " + "name2".translate,
      "father".translate + " " + "phone".translate,
      "father".translate + " " + "mail".translate,
      "father".translate + " " + "job".translate,
      "father".translate + " " + "birthday".translate,
      "mother".translate + " " + "name2".translate,
      "mother".translate + " " + "phone".translate,
      "mother".translate + " " + "mail".translate,
      "mother".translate + " " + "job".translate,
      "mother".translate + " " + "birthday".translate,
      'transporter'.translate,
    ]);
    return data;
  }

  static void exportStudentList({required String classKey}) {
    ExcelLibraryHelper.export(setupStudentList(classKey: classKey), 'studentlist'.translate);
  }

  static void exportSampleStudentList() {
    ExcelLibraryHelper.export([
      [
        "studentno".translate + '-1',
        'name'.translate + '-2',
        'surname'.translate + '-3',
        'username'.translate + '-4',
        'password'.translate + '-5',
        'tc'.translate + '-6',
        'classtype0'.translate + '-7',
        "mother".translate + " " + "name2".translate + '-8',
        "father".translate + " " + "name2".translate + '-9',
        "student".translate + " " + "phone".translate + '-10',
        "mother".translate + " " + "phone".translate + '-11',
        "father".translate + " " + "phone".translate + '-12',
        "mother".translate + " " + "job".translate + '-13',
        "father".translate + " " + "job".translate + '-14',
        "father".translate + " " + "mail".translate + '-15',
        'adress'.translate + '-20',
        'aciklama'.translate + '-21',
      ]
    ], 'studentlist'.translate);
  }

  static void exportSampleTeacherList() {
    ExcelLibraryHelper.export([
      [
        'name'.translate + '-1',
        'surname'.translate + '-2',
        'username'.translate + '-3',
        'password'.translate + '-4',
        'tc'.translate + '-5',
        "phone".translate + '-6',
        "mailadress".translate + '-7',
        'adress'.translate + '-20',
        'aciklama'.translate + '-21',
      ]
    ], Words.teacherList);
  }

  static void exportTeacherList() {
    ExcelLibraryHelper.export(setupTeacherList(), Words.teacherList);
  }

  static List<List<dynamic>> setupTeacherList() {
    List<List<dynamic>> data = AppVar.appBloc.teacherService!.dataList
        .map((e) => [
              e.name,
              e.username,
              e.passwordChangedByUser == true ? '******' : e.password,
              e.tc,
              e.phone,
              e.adress,
              formatDate(e.birthday),
              e.explanation,
              e.mail,
            ])
        .toList();

    data.insert(0, [
      'namesurname'.translate,
      'username'.translate,
      'password'.translate,
      'tc'.translate,
      'phone'.translate,
      'adress'.translate,
      'birthday'.translate,
      'aciklama'.translate,
      'mailadress'.translate,
    ]);
    return data;
  }
}
