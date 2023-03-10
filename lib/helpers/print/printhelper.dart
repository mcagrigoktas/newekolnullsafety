import 'dart:math';

import 'package:flutter/services.dart';
import 'package:mcg_database/downloadmanager/downloadmanaer_shared.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../appbloc/appvar.dart';
import '../../assets.dart';
import '../../library_helper/printing/eager.dart';
import '../../models/allmodel.dart';
import '../../screens/mesagging/messagehelper.dart';

class PrintHelper {
  PrintHelper._();

  static Future<void> printPdf(pw.Widget widget, {bool pageLandscape = false, pw.Document? doc, pw.EdgeInsets? margin}) async {
    doc ??= pw.Document();
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);
    final font2 = await rootBundle.load(Assets.fonts.sfuiTextBoldTTF);

    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            orientation: pageLandscape ? pw.PageOrientation.landscape : pw.PageOrientation.portrait,
            theme: pw.ThemeData.withFont(
              base: pw.Font.ttf(font1),
              bold: pw.Font.ttf(font2),
              italic: pw.Font.ttf(font1),
            ),
            margin: margin ?? const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20)),
        build: (pw.Context context) => widget,
      ),
    );
    await PrintLibraryHelper.printPdfDoc(doc);
  }

  static Future<void> printMultiplePagePdf(List<pw.Widget> pages, {pw.PageOrientation orientation = pw.PageOrientation.portrait, pw.Document? doc}) async {
    doc ??= pw.Document();
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);
    final font2 = await rootBundle.load(Assets.fonts.sfuiTextBoldTTF);

    void setupPages(List<pw.Widget> pageList) {
      doc!.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            orientation: orientation,
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            theme: pw.ThemeData.withFont(
              base: pw.Font.ttf(font1),
              bold: pw.Font.ttf(font2),
              italic: pw.Font.ttf(font1),
            ),
          ),
          build: ((context) => pageList),
          maxPages: 1000,
        ),
      );
    }

    setupPages(pages);
    await PrintLibraryHelper.printPdfDoc(doc);
  }
}

class PrintWidgetHelper {
  PrintWidgetHelper._();

  /// hazir Widgetlar
  static pw.Widget keyValueWidget(key, value, {int valueFlex = 1, PdfColor? color}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(children: [
          pw.Expanded(
            child: pw.Container(width: double.infinity, alignment: pw.Alignment.center, color: color ?? PdfColors.grey, child: pw.Text(key.toString(), style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold))),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            flex: valueFlex,
            child: pw.Text(value.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.black)),
          ),
        ]));
  }

  static pw.Widget keyValueColumnWidget(key, value) {
    return pw.Padding(
        padding: const pw.EdgeInsets.all(2),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Container(width: double.infinity, alignment: pw.Alignment.center, color: PdfColors.deepPurple, child: pw.Text(key.toString(), style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 2),
          pw.Text(value.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.black)),
        ]));
  }

  static pw.Widget myTextContainer({required String text, PdfColor color = PdfColors.redAccent, bool bold = false, double padding = 8}) {
    return pw.Container(color: color, width: double.infinity, padding: pw.EdgeInsets.all(padding), alignment: pw.Alignment.center, child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)));
  }

  static pw.Widget myBorderedContainer({
    double? height,
    required String text,
    bool alignmentIsCenter = true,
    PdfColor color = PdfColors.black,
    bool bold = false,
    double padding = 8,
    double fontSize = 14,
    bool? useFittedBox,
    int? maxLines,
    pw.TextAlign? textAlign,
    int rotate = 0,
  }) {
    if (rotate != 0) {
      return pw.LayoutBuilder(builder: (context, constraints) {
        pw.Widget _current = pw.Text(
          text,
          maxLines: maxLines,
          textAlign: textAlign,
          style: pw.TextStyle(color: color, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize),
        );

        if (useFittedBox == true) {
          _current = pw.FittedBox(child: _current);
        }

        _current = pw.Center(child: _current);

        _current = pw.OverflowBox(
          maxHeight: constraints!.maxWidth,
          maxWidth: height,
          minHeight: constraints.maxWidth,
          minWidth: height,
          child: _current,
        );

        _current = pw.Transform.rotate(angle: pi * rotate / 2, child: _current);

        return pw.Container(height: height, decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0, color: color)), width: double.infinity, padding: pw.EdgeInsets.all(padding), alignment: alignmentIsCenter ? pw.Alignment.center : pw.Alignment.centerLeft, child: _current);
      });
    }

    pw.Widget _current = pw.Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      style: pw.TextStyle(color: color, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize),
    );
    if (useFittedBox == true) {
      _current = pw.FittedBox(child: _current);
    }

    return pw.Container(height: height, decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.0, color: color)), width: double.infinity, padding: pw.EdgeInsets.all(padding), alignment: alignmentIsCenter ? pw.Alignment.center : pw.Alignment.centerLeft, child: _current);
  }

  static pw.Widget makeTable(List<String> tableHeaders, List<List<dynamic>> data, {double headerFontSize = 10}) {
    var baseColor = PdfColors.blue;
    var _baseTextColor = PdfColors.white;
    var _darkColor = PdfColors.black;
    var accentColor = PdfColors.amber;
    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.center,
      headerAlignment: pw.Alignment.center,
      headerDecoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(2), color: baseColor),
      headerHeight: 20,
      cellHeight: 25,
      headerStyle: pw.TextStyle(color: _baseTextColor, fontSize: headerFontSize, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(color: _darkColor, fontSize: 10),
      rowDecoration: pw.BoxDecoration(
          border: pw.Border(
        bottom: pw.BorderSide(color: accentColor, width: .5),
      )),
      headers: List<String>.generate(tableHeaders.length, (col) => tableHeaders[col]),
      data: data,
    );
  }
}

class EkolPrintHelper {
  EkolPrintHelper._();

  ///Okul bilgileri
  static Future<pw.Widget> schoolLogo(doc) async {
    return pw.Image(pw.MemoryImage((await DownloadManager.downloadThenCache(url: AppVar.appBloc.schoolInfoService!.singleData!.logoUrl))!.byteData), width: 40);
  }

  static pw.Widget schoolInfo() {
    return pw.Text(AppVar.appBloc.schoolInfoService!.singleData!.name, style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold));
  }

  // static Future<void> printUsername(Student student) async {
  //   if (Get.find<RemoteControlValues>().userCanChangePassword == true) {
  //     return printUsernameNew(student);
  //   }
  //   final doc = pw.Document();

  //   pw.Widget makbuz = pw.Column(children: [
  //     pw.SizedBox(height: 16),
  //     pw.Container(
  //       decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 1)),
  //       child: pw.Row(children: [
  //         pw.Expanded(
  //             flex: 2,
  //             child: pw.Container(
  //               padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //               decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))),
  //               child: pw.Text(AppVar.appBloc.schoolInfoService.singleData.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             )),
  //         pw.Expanded(
  //             flex: 1,
  //             child: pw.Container(
  //               padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //               child: pw.Text('${'date'.translate}: ${DateFormat("d-MMM-yyyy").format(DateTime.now())}'),
  //             )),
  //       ]),
  //     ),
  //     pw.SizedBox(height: 8),
  //     pw.Container(
  //       padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //       width: double.infinity,
  //       decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 1)),
  //       child: pw.Text('student'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //     ),
  //     pw.Container(
  //       padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //       decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
  //       child: pw.Row(children: [
  //         pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('name'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
  //         pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.name))),
  //       ]),
  //     ),
  //     pw.Container(
  //       padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //       decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
  //       child: pw.Row(children: [
  //         pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('username'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
  //         pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.username))),
  //       ]),
  //     ),
  //     pw.SizedBox(height: 8),
  //     pw.Container(
  //       padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //       decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 1)),
  //       child: pw.Row(children: [
  //         pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('password'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
  //         pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.passwordChangedByUser == true ? '******' : student.password))),
  //       ]),
  //     ),
  //     if (MessageHelper.isParentMessageActive())
  //       pw.Container(
  //         padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //         decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
  //         child: pw.Row(children: [
  //           pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('parentpassword'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
  //           pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(McgFunctions.mcgStringNumberKey(student.password) + '-' + student.password))),
  //         ]),
  //       ),
  //     if (MessageHelper.isParentMessageActive()) pw.Text('parentmessagehint'.translate, textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.black, fontSize: 8)),
  //     pw.SizedBox(height: 8),
  //     pw.Container(
  //       padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  //       decoration: pw.BoxDecoration(
  //           border: pw.Border.all(
  //         color: PdfColors.blue,
  //         width: 1,
  //       )),
  //       child: pw.Row(children: [
  //         pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('kurumid'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
  //         pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(AppVar.appBloc.hesapBilgileri.kurumID))),
  //       ]),
  //     ),
  //     pw.SizedBox(height: 8),
  //   ]);

  //   await PrintHelper.printPdf(pw.Column(children: [pw.Expanded(child: makbuz), pw.Expanded(child: makbuz)]), doc: doc);
  // }

  static Future<void> printUsername(Student student) async {
    final doc = pw.Document();

    pw.Widget getTable({parentType}) {
      return pw.Column(children: [
        pw.SizedBox(height: 16),
        pw.Container(
          color: PdfColor(0, 0, 0, 0.04).flatten(),
          child: pw.Row(children: [
            pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: pw.Text(AppVar.appBloc.schoolInfoService!.singleData!.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                )),
            pw.Expanded(
                flex: 1,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: pw.Text('${'date'.translate}: ${DateTime.now().dateFormat("d-MMM-yyyy")}'),
                )),
          ]),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          width: double.infinity,
          color: PdfColor(0, 0, 0, 0.05).flatten(),
          child: pw.Text('student'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: PdfColor(0, 0, 0, 0.02).flatten(),
          child: pw.Row(children: [
            pw.Expanded(flex: 1, child: pw.Text('name'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.name))),
          ]),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: PdfColor(0, 0, 0, 0.02).flatten(),
          child: pw.Row(children: [
            pw.Expanded(flex: 1, child: pw.Text('username'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.username!))),
          ]),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: PdfColor(0, 0, 0, 0.02).flatten(),
          child: pw.Row(children: [
            pw.Expanded(flex: 1, child: pw.Text('password'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.passwordChangedByUser == true ? '******' : student.password!))),
          ]),
        ),
        if (MessageHelper.isParentMessageActive())
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            color: PdfColor(0, 0, 0, 0.02).flatten(),
            child: pw.Row(children: [
              pw.Expanded(flex: 1, child: pw.Text('parentpassword'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 1,
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: pw.Text(student.passwordChangedByUser == true
                          ? '******'
                          : parentType == 2
                              ? student.parentPassword2!
                              : student.parentPassword1!))),
            ]),
          ),
        if (MessageHelper.isParentMessageActive()) pw.Text('parentmessagehint'.translate, textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.black, fontSize: 8)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          color: PdfColor(0, 0, 0, 0.02).flatten(),
          child: pw.Row(children: [
            pw.Expanded(flex: 1, child: pw.Text('kurumid'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(AppVar.appBloc.hesapBilgileri.kurumID))),
          ]),
        ),
        pw.SizedBox(height: 8),
      ]);
    }

    if (student.parentState == 2) {
      await PrintHelper.printPdf(pw.Column(children: [pw.Expanded(child: getTable(parentType: 1)), pw.Expanded(child: getTable(parentType: 2))]), doc: doc);
      return;
    }

    await PrintHelper.printPdf(pw.Column(children: [pw.Expanded(child: getTable()), pw.Expanded(child: getTable())]), doc: doc);
  }
}
