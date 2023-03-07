import 'dart:typed_data';
import 'deferred.dart' deferred as eager;

class SpreadSheetHelper {
  SpreadSheetHelper._();
  static Future<List<List<String>>?> convertToList(Uint8List byteData) async {
    await eager.loadLibrary();
    return eager.DeferredSpreadSheetHelper.convertToList(byteData);
  }
}
