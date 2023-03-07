import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DeferredPrintLibraryHelper {
  DeferredPrintLibraryHelper._();
  static Future<void> printPdfDoc(pw.Document doc, {PdfPageFormat pdfPageFormat = PdfPageFormat.standard}) async {
    await Printing.layoutPdf(format: pdfPageFormat, onLayout: (format) async => doc.save());
  }

  static Future<void> printAssetFilePdf(String path, {PdfPageFormat pdfPageFormat = PdfPageFormat.standard}) async {
    final pdf = await rootBundle.load(path);
    await Printing.layoutPdf(format: pdfPageFormat, onLayout: (_) => pdf.buffer.asUint8List());
  }
}
