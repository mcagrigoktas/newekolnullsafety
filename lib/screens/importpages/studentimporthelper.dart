import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';

class StudentImportHelper {
  StudentImportHelper._();

  ///donus degeri List<Ogrenci>
  ///yada Sadec hata yazisi String
  ///
  ///
  /// 1 Ogrenci no
  /// 2 Isim
  /// 3 Soyisim
  /// 4 username
  /// 5 password
  /// 6 tc
  /// 7 sinif
  /// 8 anne adi
  /// 9 baba adi
  /// 10 ogrenci tel
  /// 11 anne tel
  /// 12 baba tel
  /// 13 anne meslek
  /// 14 baba meslek
  /// 15 baba mail
  /// 20 adres
  /// 21 aciklama
  static Tuple2<List<Student>?, String?> parseStudents(List<List<String>> tableRows, bool sifreTcdenOlussun) {
    var _studentList = AppVar.appBloc.studentService!.dataListWithDeleted;
    var _teacherList = AppVar.appBloc.teacherService!.dataListWithDeleted;
    var _managerList = AppVar.appBloc.managerService!.dataListWithDeleted;
    final _rows = tableRows;

    final List<String> _names = _rows[0];

    //  if (!names.any((element) => element.split('-').last == '1')) return  'studentimportrequire');
    if (!_names.any((element) => element.split('-').last == '2')) return Tuple2(null, 'studentimportrequire'.translate);

    List<String> _hataRaporu = [];

    List<Student> _liste = [];
    for (var i = 1; i < _rows.length; i++) {
      final _row = _rows[i];
      var _key = 4.makeKey;

      do {
        _key = 4.makeKey;
      } while (_liste.any((item) => item.key == _key));

      final _item = Student();
      _item.aktif = true;
      _item.key = _key;
      _item.lastUpdate = databaseTime;

      String _studentName = '';
      String _studentSurName = '';

      for (var j = 0; j < _names.length; j++) {
        final String _name = _names[j].trim();
        final String _data = (_row[j]).toString().trim();
        final String _nameNo = _name.split('-').last.trim();

        // Ogrenci No
        if (_nameNo == '1') {
//          if (data.length < 1) {
//            //     hataRaporu.add( 'importerr1') + ':${i + 1}');
//          }
//          if (liste.any((item) {
//            if (item.no.trim() == data.trim()) {
//              print(item.name);
//            }
//            return item.no.trim() == data.trim();
//          })) {
//            hataRaporu.add( 'importerr2') + ':${i + 1}');
//          }
          _item.no = _data;
        }

        // Ogrenci Ismi
        if (_nameNo == '2') {
          _studentName = _data;
          //    debugPrint(data);
        }

        // Ogrenci Soyismi
        if (_nameNo == '3') _studentSurName = _data;

        // Ogrenci Username
        if (_nameNo == '4') {
          if (_data.length > 5) {
            _item.username = _data;
          }
        }

        // Ogrenci Password
        if (_nameNo == '5') {
          if (_data.length > 5) {
            _item.password = _data;
          }
        }

        // Ogrenci Id
        if (_nameNo == '6') _item.tc = _data;

        // Ogrenci Sinifi
        if (_nameNo == '7') {
          if (_data.length > 1) {
            _item.class0 = AppVar.appBloc.classService!.dataList.firstWhereOrNull((element) => element.name!.toLowerCase().trim() == _data.toLowerCase().trim() && element.classType == 0)?.key;
          }
        }

        //Anne adi
        if (_nameNo == '8') _item.motherName = _data;

        //Baba adi
        if (_nameNo == '9') _item.fatherName = _data;

        //Ogrenci teli
        if (_nameNo == '10') {
          _item.studentPhone = _data.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '');
        }
        //Anne teli
        if (_nameNo == '11') {
          _item.motherPhone = _data.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '');
        }
        //Baba teli
        if (_nameNo == '12') {
          _item.fatherPhone = _data.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '');
        }
        //Anne Meslegi
        if (_nameNo == '13') _item.motherJob = _data;

        //Baba Meslegi
        if (_nameNo == '14') _item.fatherJob = _data;

        //Baba Mail
        if (_nameNo == '15') _item.fatherMail = _data;

        //Adres
        if (_nameNo == '20') _item.adress = _data;

        //Aciklama
        if (_nameNo == '21') _item.explanation = _data.safeLength < 1 ? '-' : _data;
      }
      if ((_studentName + _studentSurName).length < 5) {
        _hataRaporu.add('importerr3'.translate + ':${i + 1}');
      }
      _item.name = _studentName + ' ' + _studentSurName;

      if (_item.username.safeLength > 5 && _item.username.hasFirebaseForbiddenCharacter) {
        _hataRaporu.add('importerr6'.translate + ':${i + 1}');
      }
      if (_item.password.safeLength > 5 && _item.password.hasFirebaseForbiddenCharacter) {
        _hataRaporu.add('importerr6'.translate + ':${i + 1}');
      }

      if (_item.username.safeLength < 6 || _item.password.safeLength < 6) {
        if (sifreTcdenOlussun && _item.tc.safeLength > 5) {
          _item.username = _item.tc!.substring(_item.tc!.length - 6);
          _item.password = _item.tc!.substring(_item.tc!.length - 6);
        } else {
          String text;
          do {
            text = 6.makeKeyFromNumber;
          } while (_liste.any((item) => item.username == text));

          _item.username = text;
          _item.password = text;
        }
      }
      if (_liste.any((element) => element.username == _item.username) || _studentList.any((element) => element.username == _item.username) || _teacherList.any((element) => element.username == _item.username) || _managerList.any((element) => element.username == _item.username)) {
        _hataRaporu.add('importerr4'.translate + ':${i + 1}');
      }

      _item.no ??= '';
      //  if (liste.any((element) => element.no == item.no) || AppVar.appBloc.studentService.dataList.any((element) => element.no == item.no)) hataRaporu.add( 'importerr5') + ':${i + 1}');

      _liste.add(_item);
    }
    if (_hataRaporu.isNotEmpty) return Tuple2(null, 'rowerror'.translate + ' ' + _hataRaporu.fold('', (previousValue, element) => previousValue + '\n' + (element).toString()));
    return Tuple2(_liste, null);
  }

  static Widget makeTable(BuildContext context, List<Student> itemList) {
    AppFunctions appFunctions = AppFunctions();
    return Column(
      children: <Widget>[
        8.heightBox,
        Row(
          children: <Widget>[
            Expanded(
                child: Text(
              'senddatabasehint'.translate,
              style: TextStyle(color: Fav.design.primaryText),
            )),
            MyRaisedButton(
              text: 'senddatabase'.translate,
              onPressed: () async {
                var sure = await Over.sure();
                if (sure == true) {
                  return StudentService.saveMultipleStudent(itemList).then((value) {
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
                          e.no,
                          e.username,
                          e.password,
                          e.class0 != null ? appFunctions.classKeyToName(e.class0!) : '',
                          e.tc ?? '',
                          e.fatherName ?? '',
                          e.motherName ?? '',
                          e.studentPhone ?? '',
                          e.fatherPhone ?? '',
                          e.motherPhone ?? '',
                          e.motherJob ?? '',
                          e.fatherJob ?? '',
                          e.fatherMail ?? '',
                          e.adress ?? '',
                          e.explanation ?? '--'
                        ])
                    .toList() as List<List<String>>
                  ..insert(
                    0,
                    [
                      ''.translate,
                      'namesurname'.translate,
                      'studentno'.translate,
                      'username'.translate,
                      'password'.translate,
                      'classtype0'.translate,
                      'tc'.translate,
                      'father'.translate + ' ' + 'name'.translate,
                      'mother'.translate + ' ' + 'name'.translate,
                      'student'.translate + ' ' + 'phone'.translate,
                      'father'.translate + ' ' + 'phone'.translate,
                      'mother'.translate + ' ' + 'phone'.translate,
                      'mother'.translate + ' ' + 'job'.translate,
                      'father'.translate + ' ' + 'job'.translate,
                      'father'.translate + ' ' + 'mail'.translate,
                      'adress'.translate,
                      'aciklama'.translate,
                    ],
                  ),
              )),
        ),
      ],
    );
  }

//  static List<String> _dataRowToStringRow(List<xls.Data> row) {}
}

// //* Excelin yeni surumunde rowlar data list olarak geliyor onu string liste cevirir simdilik asagidaki kod gostermelik

// extension on List<List<dynamic>> {
//   List<List<String>> get convertStringRows {
//     List<List<String>> _stringRows = [];
//     forEach((row) {
//       List<String> _rowStrings = [];
//       row.forEach((item) {
//         _rowStrings.add(item?.toString() ?? '');
//       });
//       _stringRows.add(_rowStrings);
//     });
//     return _stringRows;
//   }
// }
