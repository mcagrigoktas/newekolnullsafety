import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../library_helper/excel/eager.dart';
import '../../library_helper/spreadsheet_decoder/eager.dart';
import '../../services/remote_control.dart';

class ExcelHelper {
  ExcelHelper._();

  static Future<List<List<String>>?> chooseFileThenConvertToList() async {
    MyFile? _file = await FilePicker.pickFile(fileType: FileType.ANY);
    if (_file == null) return null;
    String _fileName = _file.fileName;

    if (!_fileName.contains("xls")) {
      OverAlert.show(type: AlertType.danger, message: 'filenosupport'.translate);
      return null;
    }

    if (Get.find<RemoteControlValues>().excelIsSpreadSheet == true) {
      return SpreadSheetHelper.convertToList(_file.byteData);
    } else {
      return ExcelLibraryHelper.convertToList(_file.byteData);
    }
  }
}
