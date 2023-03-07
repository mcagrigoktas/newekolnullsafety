// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pdf/src/pdf/page_format.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../assets.dart';
import '../../../../library_helper/excel/eager.dart';
import '../../../../library_helper/printing/eager.dart';
import '../../../../screens/portfolio/model.dart';
import '../../../../screens/portfolio/widgets/print_karne_helper.dart';
import '../../../../services/smssender.dart';
import 'controller.dart';

class ExamResultReviewHelper {
  ExamResultReviewHelper._();

  static ExamResultViewController get _controller => Get.find<ExamResultViewController>();

  static Future<void> exportExcel() async {
    await ExcelLibraryHelper.export(_controller.getExcelFile(), _controller.exam!.name!);
    OverAlert.saveSuc();
  }

  static Future<void> printReportCards(List<String> filteredClassList, {double earnintItemFontSize = 10}) async {
    Map<String, String?> reversedEarninKeyMap = {};
    if (_controller.examResultBigData!.earningIsActive!) {
      reversedEarninKeyMap = _controller.examResultBigData!.earninKeyMap!.map((key, value) => MapEntry(value, key));
    }

    PrintKarneHelper.printFullKarne(
        (_controller.allKurumAllStudentResults![_controller.kurumId]!.entries.toList()..sort((i1, i2) => i1.value!.rSClass!.compareTo(i2.value!.rSClass!)))
            .where((item) => filteredClassList.contains('all') || filteredClassList.contains(item.value!.rSClass))
            .map((e) => PortfolioExamReport({
                  'examType': _controller.examType!.mapForStudent(),
                  'examData': e.value!.mapForSave(),
                  'exam': _controller.exam!.mapForStudent(),
                  'earningResultKeyMap': reversedEarninKeyMap,
                }))
            .toList(),
        earnintItemFontSize: earnintItemFontSize);
  }

  static Future<void> print() async {
    final doc = pw.Document();
    final font1 = await rootBundle.load(Assets.fonts.sfuiTextMediumTTF);
    final font2 = await rootBundle.load(Assets.fonts.sfuiTextBoldTTF);

    pw.Widget headerWidget = _controller.getPdfPrintHeader();
    List<pw.Widget> items = _controller.getPdfPrintBody();

    doc.addPage(
      pw.MultiPage(
        header: (context) => headerWidget,
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.symmetric(horizontal: Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble(), vertical: Fav.preferences.getInt('printfullprogrammargin', 8)!.toDouble()),
          theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(font1),
            bold: pw.Font.ttf(font2),
            italic: pw.Font.ttf(font1),
          ),
        ),
        build: (context) => items,
      ),
    );
    await PrintLibraryHelper.printPdfDoc(doc);
  }

  static void sendSms() {
    final _smsList = _controller.getSmsList();

    OverPage.openModelBottomWithListView(
        itemBuilder: (context, index) {
          final _item = _smsList[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _item.numbers!.join('-').text.make(),
              _item.message.text.make(),
            ],
          ).pb16;
        },
        itemCount: _smsList.length,
        title: 'SmsListesi',
        bottomBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MyMiniRaisedButton(
                onPressed: () async {
                  await SmsSender.sendSms(
                    _smsList,
                    sureAlertVisible: false,
                    dataIsUserAccountInfo: false,
                    mobilePhoneCanBeUsed: false,
                  );
                  OverPage.close();
                },
                text: 'send'.translate),
          ],
        ));
  }
}
