import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';

class TeacherImportHelper {
  TeacherImportHelper._();

  ///donus degeri List<Ogretmen>
  ///yada Sadec hata yazisi String
  ///
  ///
  /// 1 Isim
  /// 2 Soyisim
  /// 3 username
  /// 4 password
  /// 5 tc
  /// 6 phone
  /// 7 mail
  /// 20 adres
  /// 21 aciklama
  static Tuple2<List<Teacher>?, String?> parseTeachers(List<List<String>> tableRows, bool sifreTcdenOlussun) {
    var studentList = AppVar.appBloc.studentService!.dataListWithDeleted;
    var teacherList = AppVar.appBloc.teacherService!.dataListWithDeleted;
    var managerList = AppVar.appBloc.managerService!.dataListWithDeleted;

    final rows = tableRows;

    final List<String> names = rows[0];

    if (!names.any((element) => element.split('-').last == '1')) return Tuple2(null, 'studentimportrequire'.translate);

    List<String> hataRaporu = [];

    List<Teacher> liste = [];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      var key = 5.makeKey;

      do {
        key = 5.makeKey;
      } while (liste.any((item) => item.key == key));

      final item = Teacher();
      item.aktif = true;
      item.key = key;
      item.lastUpdate = databaseTime;
      item.color = 'ff0000';
      item.seeAllClass = false;

      String teacherName = '';
      String teacherSurName = '';

      for (var j = 0; j < names.length; j++) {
        final String columnName = names[j].trim();
        final String data = (row[j]).toString().trim();
        final String nameNo = columnName.split('-').last.trim();

        // Ogretmen Ismi
        if (nameNo == '1') {
          teacherName = data;
        }

        // Ogretmen Soyismi
        if (nameNo == '2') teacherSurName = data;

        // Ogretmen Username
        if (nameNo == '3') {
          if (data.length > 5) {
            item.username = data;
          }
        }
        // Ogretmen Password
        if (nameNo == '4') {
          if (data.length > 5) {
            item.password = data;
          }
        }

        // Ogretmen Id
        if (nameNo == '5') item.tc = data;

        //Ogretmen teli
        if (nameNo == '6') {
          item.phone = data.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '');
        }

        //Ogretmen mail
        if (nameNo == '7') item.mail = data.trim();

        //Adres
        if (nameNo == '20') item.adress = data;

        //Aciklama
        if (nameNo == '21') item.explanation = data.safeLength < 1 ? '-' : data;
      }

      if ((teacherName + teacherSurName).length < 5) {
        hataRaporu.add('importerr3'.translate + ':${i + 1}');
      }
      item.name = teacherName + ' ' + teacherSurName;

      if (item.username.safeLength > 5 && item.username.hasFirebaseForbiddenCharacter) {
        hataRaporu.add('importerr6'.translate + ':${i + 1}');
      }
      if (item.password.safeLength > 5 && item.password.hasFirebaseForbiddenCharacter) {
        hataRaporu.add('importerr6'.translate + ':${i + 1}');
      }

      if (item.username.safeLength < 6 || item.password.safeLength < 6) {
        if (sifreTcdenOlussun && item.tc.safeLength > 5) {
          item.username = item.tc!.substring(item.tc!.length - 6);
          item.password = item.tc!.substring(item.tc!.length - 6);
        } else {
          String text;
          do {
            text = 6.makeKeyFromNumber;
          } while (liste.any((item) => item.username == text));

          item.username = text;
          item.password = text;
        }
      }
      if (liste.any((element) => element.username == item.username) || studentList.any((element) => element.username == item.username) || teacherList.any((element) => element.username == item.username) || managerList.any((element) => element.username == item.username)) {
        hataRaporu.add('importerr4'.translate + ':${i + 1}');
      }

      liste.add(item);
    }
    if (hataRaporu.isNotEmpty) return Tuple2(null, 'rowerror'.translate + ' ' + hataRaporu.fold('', (previousValue, element) => previousValue + '\n' + (element).toString()));
    return Tuple2(liste, null);
  }

  static Widget makeTable(BuildContext context, List<Teacher> itemList) {
    return Column(
      children: <Widget>[
        8.heightBox,
        Row(
          children: <Widget>[
            Expanded(child: Text('senddatabasehint'.translate, style: TextStyle(color: Fav.design.primaryText))),
            MyRaisedButton(
              text: 'senddatabase'.translate,
              onPressed: () async {
                var sure = await Over.sure();
                if (sure == true) {
                  return TeacherService.saveMultipleTeacher(itemList).then((value) {
                    Get.back();
                    OverAlert.saveSuc();
                  }).catchError((err) {
                    OverAlert.saveErr();
                  });
                }
              },
            ),
          ],
        ).paddingOnly(top: 4, right: 8, bottom: 8, left: 4),
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: MyDataTable(
                textColor: Fav.design.primaryText,
                maxWidth: 200,
                data: itemList
                    .map((e) => [
                          (itemList.indexOf(e) + 1).toString(),
                          e.name,
                          e.username,
                          e.password,
                          e.tc ?? '',
                          e.phone ?? '',
                          e.mail ?? '',
                          e.adress ?? '',
                          e.explanation ?? '--',
                        ])
                    .toList() as List<List<String>>
                  ..insert(
                    0,
                    [
                      ''.translate,
                      'namesurname'.translate,
                      'username'.translate,
                      'password'.translate,
                      'tc'.translate,
                      'phone'.translate,
                      'mailadress'.translate,
                      'adress'.translate,
                      'aciklama'.translate,
                    ],
                  ),
              )),
        ),
      ],
    );
  }
}
