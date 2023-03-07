import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../helpers/exporthelper.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import 'excel_helper.dart';
import 'studentimporthelper.dart';
import 'teacherimporthelper.dart';

class ImportPageMain extends StatefulWidget {
  ///menu no
  ///10 Ogrenci listesi
  ///11 Ogretmen listesi
  final int menuNo;
  ImportPageMain({required this.menuNo});

  @override
  _ImportPageMainState createState() => _ImportPageMainState();
}

class _ImportPageMainState extends State<ImportPageMain> {
  //SpreadsheetTable dataTable;
  Widget? _tablo;
  String? _errorText;

  Future<void> _chooseFile() async {
    _errorText = null;
    _tablo = null;
    final _dataRowsFromExcel = await ExcelHelper.chooseFileThenConvertToList();
    if (_dataRowsFromExcel == null) return;

    ///===Ayrac===////

    if (widget.menuNo == 10) {
      Tuple2<List<Student>?, String?> _result;

      final _sifreTcdenOlussun = await Over.sure(
        title: 'usernametcwarning'.translate,
        yesText: 'yes'.translate,
        cancelText: 'no'.translate,
      );

      _result = StudentImportHelper.parseStudents(_dataRowsFromExcel, _sifreTcdenOlussun == true);

      if (_result.item2 != null) {
        setState(() {
          _errorText = _result.item2;
        });
        return;
      }
      setState(() {
        _tablo = StudentImportHelper.makeTable(context, _result.item1!);
      });
    } else if (widget.menuNo == 11) {
      Tuple2<List<Teacher>?, String?> _result;

      final _sifreTcdenOlussun = await Over.sure(
        title: 'usernametcwarning'.translate,
        yesText: 'yes'.translate,
        cancelText: 'no'.translate,
      );

      _result = TeacherImportHelper.parseTeachers(_dataRowsFromExcel, _sifreTcdenOlussun == true);

      if (_result.item2 != null) {
        setState(() {
          _errorText = _result.item2;
        });
        return;
      }
      setState(() {
        _tablo = TeacherImportHelper.makeTable(context, _result.item1!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: widget.menuNo == 10 ? 'studentlist'.translate : Words.teacherList),
      topActions: TopActionsTitle(title: 'fromexcell'.translate),
      body: Body.child(
          child: _tablo ??
              Column(
                children: <Widget>[
                  WarningWidget(menuNo: widget.menuNo, errorText: _errorText),
                  8.heightBox,
                  MyRaisedButton(onPressed: _chooseFile, text: 'addfile'.translate),
                  8.heightBox,
                ],
              )),
    );
  }
}

class WarningWidget extends StatelessWidget {
  final int menuNo;
  final String? errorText;
  WarningWidget({required this.menuNo, this.errorText});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          4.heightBox,
          Icon(
            Icons.warning,
            color: Fav.design.primaryText.withAlpha(200),
            size: 64,
          ),
          16.heightBox,
          Text(
            'importwarning'.translate,
            style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
          ),
          8.heightBox,
          MyRaisedButton(
            text: 'sampleexcel'.translate,
            onPressed: () {
              if (menuNo == 10) ExportHelper.exportSampleStudentList();
              if (menuNo == 11) ExportHelper.exportSampleTeacherList();
            },
          ),
          12.heightBox,
          Text(
            'importhint1'.translate,
            style: TextStyle(color: Fav.design.primaryText),
          ),
          8.heightBox,
          Text(
            menuNo == 10 ? 'importstudentclasshint1'.translate : '',
            style: TextStyle(color: Fav.design.primaryText),
          ),
          8.heightBox,
          Text(
            menuNo == 10 || menuNo == 11 ? 'importhint2'.translate : '',
            style: TextStyle(color: Fav.design.primaryText),
          ),
          8.heightBox,
          if (errorText != null)
            Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
