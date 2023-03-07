import 'dart:typed_data';
import 'package:mcg_database/downloadmanager/downloadmanaer_shared.dart';

import 'deferred.dart' deferred as eager;

class ExcelLibraryHelper {
  ExcelLibraryHelper._();
  static Future<List<List<String>>?> convertToList(Uint8List byteData) async {
    await eager.loadLibrary();
    return eager.DeferredExcelLibraryHelper.convertToList(byteData);
  }

  static Future<void> export(List<List> data, String name) async {
    await eager.loadLibrary();
    final _resultFile = await (eager.DeferredExcelLibraryHelper.export(data));
    await DownloadManager.saveFileToDisk(data: Uint8List.fromList(_resultFile!), fileName: name + '.xlsx');
  }
}
