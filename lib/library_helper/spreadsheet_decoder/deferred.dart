import 'dart:typed_data';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class DeferredSpreadSheetHelper {
  DeferredSpreadSheetHelper._();
  static Future<List<List<String>>?> convertToList(Uint8List byteData) async {
    SpreadsheetDecoder decoder;
    try {
      decoder = SpreadsheetDecoder.decodeBytes(byteData);
    } on FormatException catch (_) {
      OverAlert.show(type: AlertType.danger, message: 'filenosupport'.translate);
      return null;
    }

    final table = decoder.tables.values.first;
    List<List<String>> _stringRows = [];
    table.rows.forEach((row) {
      _stringRows.add(row.map((e) => e.toString() == 'null' ? '' : e.toString()).toList());
    });
    return _stringRows;
  }
}
