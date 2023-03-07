import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:mcg_extension/mcg_extension.dart';

class DeferredExcelLibraryHelper {
  DeferredExcelLibraryHelper._();
  static Future<List<List<String>>?> convertToList(Uint8List byteData) async {
    xls.Excel _excel;
    try {
      _excel = xls.Excel.decodeBytes(byteData);
    } on FormatException catch (_) {
      OverAlert.show(type: AlertType.danger, message: 'filenosupport'.translate);
      return null;
    }

    if (_excel.tables.keys.isEmpty) {
      OverAlert.show(type: AlertType.danger, message: 'errorsheetname'.translate);
      return null;
    }

    xls.Sheet _dataTable = _excel.tables[_excel.tables.keys.first]!;

    return convertStringRows(_dataTable.rows);
  }

  static List<List<String>> convertStringRows(List<List<xls.Data?>> dataList) {
    List<List<String>> _stringRows = [];
    dataList.forEach((row) {
      List<String> _rowStrings = [];
      row.forEach((item) {
        _rowStrings.add((item?.value ?? '').toString());
      });
      _stringRows.add(_rowStrings);
    });
    return _stringRows;
  }

//**************** Export bolumu */

  static Future<List<int>?> export(List<List> data) async {
    var excel = xls.Excel.createExcel();
    var sheet = excel.getDefaultSheet();

    data.forEach((element) {
      excel.appendRow(sheet!, element);
    });

    var _alphabat = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    var _exList = [
      ..._alphabat,
      ..._alphabat.map((e) => 'A$e').toList(),
      ..._alphabat.map((e) => 'B$e').toList(),
      ..._alphabat.map((e) => 'C$e').toList(),
      ..._alphabat.map((e) => 'D$e').toList(),
      ..._alphabat.map((e) => 'E$e').toList(),
      ..._alphabat.map((e) => 'F$e').toList(),
      ..._alphabat.map((e) => 'G$e').toList(),
      ..._alphabat.map((e) => 'H$e').toList(),
      ..._alphabat.map((e) => 'I$e').toList(),
      ..._alphabat.map((e) => 'J$e').toList(),
      ..._alphabat.map((e) => 'K$e').toList(),
      ..._alphabat.map((e) => 'L$e').toList(),
      ..._alphabat.map((e) => 'M$e').toList(),
      ..._alphabat.map((e) => 'N$e').toList(),
      ..._alphabat.map((e) => 'O$e').toList(),
      ..._alphabat.map((e) => 'P$e').toList(),
      ..._alphabat.map((e) => 'Q$e').toList(),
      ..._alphabat.map((e) => 'R$e').toList(),
      ..._alphabat.map((e) => 'S$e').toList(),
      ..._alphabat.map((e) => 'T$e').toList(),
      ..._alphabat.map((e) => 'U$e').toList(),
      ..._alphabat.map((e) => 'V$e').toList(),
      ..._alphabat.map((e) => 'W$e').toList(),
      ..._alphabat.map((e) => 'X$e').toList(),
      ..._alphabat.map((e) => 'Y$e').toList(),
      ..._alphabat.map((e) => 'Z$e').toList(),
    ];
    for (var i = 0; i < data.first.length; i++) {
      excel.updateCell(sheet!, xls.CellIndex.indexByString("${_exList[i]}1"), data.first[i], cellStyle: xls.CellStyle(backgroundColorHex: "#ff0000", fontColorHex: "#ffffff", bold: true, horizontalAlign: xls.HorizontalAlign.Center));
    }

    return excel.encode();
  }
}
