import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'deferred.dart' deferred as eager;

class PrintLibraryHelper {
  PrintLibraryHelper._();
  static Future<void> printPdfDoc(pw.Document doc, {PdfPageFormat pdfPageFormat = PdfPageFormat.standard}) async {
    await eager.loadLibrary();
    await eager.DeferredPrintLibraryHelper.printPdfDoc(doc, pdfPageFormat: pdfPageFormat);
  }

  static Future<void> printAssetFilePdf(String path, {PdfPageFormat pdfPageFormat = PdfPageFormat.standard}) async {
    await eager.loadLibrary();
    await eager.DeferredPrintLibraryHelper.printAssetFilePdf(path, pdfPageFormat: pdfPageFormat);
  }
}
