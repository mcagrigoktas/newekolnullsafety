import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../assets.dart';
import '../library_helper/excel/eager.dart';
import '../library_helper/printing/eager.dart';

class PrintAndExportHelper {
  PrintAndExportHelper._();
  static Future<void> exportToExcel({required String excelName, required PrintAndExportModel data}) {
    return ExcelLibraryHelper.export([data.columnNames, ...data.rows], excelName);
  }

  static Future<void> printPdf({
    required PrintAndExportModel data,
    required String pdfHeaderName,
    bool isLandscape = false,
    List<int> flexList = const [],
    String Function(int, dynamic)? cellFormat,
  }) async {
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);
    final font2 = await rootBundle.load(Assets.fonts.sfuiTextBoldTTF);

    pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: isLandscape ? pw.PageOrientation.landscape : pw.PageOrientation.portrait,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(font1),
            bold: pw.Font.ttf(font2),
            italic: pw.Font.ttf(font1),
          ),
        ),
        header: (context) {
          return pw.Container(height: 30, width: double.infinity, color: PdfColor(0, 0, 0, 0.1).flatten(), alignment: pw.Alignment.center, child: pw.Text(pdfHeaderName, style: pw.TextStyle(color: PdfColors.black)));
        },
        maxPages: 1000,
        build: (pw.Context context) => [
          pw.SizedBox(),
          pw.Table.fromTextArray(
            border: null,
            headerDecoration: pw.BoxDecoration(borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)), color: PdfColors.teal),
            headerHeight: 15,
            cellHeight: 15,
            cellFormat: cellFormat,
            columnWidths: Iterable.generate(data.columnNames.length, (x) => x).map((e) => MapEntry(e, pw.FlexColumnWidth((flexList.length > e ? flexList[e] : 1).toDouble() - 0.1))).fold({}, ((p, e) => p!..[e.key] = e.value)),
            cellAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(color: PdfColors.white, fontSize: 6, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(color: PdfColors.black, fontSize: 7, fontWeight: pw.FontWeight.normal),
            rowDecoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.red, width: .5))),
            headers: data.columnNames,
            data: data.rows.toList(),
          )
        ],
      ),
    );

    await PrintLibraryHelper.printPdfDoc(doc, pdfPageFormat: PdfPageFormat.a4);
  }
}

class PrintAndExportModel {
  final List<dynamic> columnNames;
  final List<List<dynamic>> rows;

  PrintAndExportModel({required this.columnNames, required this.rows});

  List<String> get stringListColumnNames => columnNames.map((e) => e.toString()).toList();
  List<List<String>> get stringListRows => rows.map((e1) => e1.map((e2) => e2.toString()).toList()).toList();
}
