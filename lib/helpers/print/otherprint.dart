import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../appbloc/appvar.dart';
import 'printhelper.dart';

class OtherPrint {
  OtherPrint._();

  static void printFirstLoginList(Map? loginData) {
    final doc = pw.Document();

    PrintHelper.printMultiplePagePdf(
      [
        PrintWidgetHelper.myTextContainer(text: 'firstloginlist'.translate),
        PrintWidgetHelper.makeTable(['name'.translate, 'state'.translate], AppVar.appBloc.studentService!.dataList.map((e) => [e.name, loginData![e.key] == true ? 'yes'.translate : 'no'.translate]).toList())
      ],
      doc: doc,
    );
  }

  // static void printUsageInfo(List<List<String>> data) {
  //   final doc = pw.Document();
  //   PrintHelper.printMultiplePagePdf(
  //     [PrintWidgetHelper.myTextContainer(text: 'usageinfo'.translate), PrintWidgetHelper.makeTable(data.first, data.sublist(1), headerFontSize: 8)],
  //     orientation: pw.PageOrientation.landscape,
  //     doc: doc,
  //   );
  // }

  static void printQbankTestStatistics(List<List<String?>> data) {
    final doc = pw.Document();
    PrintHelper.printMultiplePagePdf(
      [
        PrintWidgetHelper.myTextContainer(text: 'studentstatistics'.translate),
        PrintWidgetHelper.makeTable(
          data.first,
          data.sublist(1),
        )
      ],
      doc: doc,
    );
  }

  static void printBirthdayList() {
    final doc = pw.Document();
    PrintHelper.printMultiplePagePdf([
      PrintWidgetHelper.myTextContainer(text: 'birthdaylist'.translate),
      PrintWidgetHelper.makeTable(['name'.translate, 'birthday'.translate], AppVar.appBloc.studentService!.dataList.map((e) => [e.name, e.birthday is int ? e.birthday!.dateFormat("d-MMM-yyyy") : '?']).toList())
    ], doc: doc);
  }

  static Future<void> printSurveyResult(List<List<String?>> data) async {
    data.forEach((element) {
      element.forEach((el) {
        if (el.startsWithHttp) element[element.indexOf(el)] = 'picture'.translate;
      });
    });

    try {
      final doc = pw.Document();
      await PrintHelper.printMultiplePagePdf(
        [PrintWidgetHelper.myTextContainer(text: 'survey'.translate), PrintWidgetHelper.makeTable(data.first, data.sublist(1), headerFontSize: 8)],
        orientation: pw.PageOrientation.landscape,
        doc: doc,
      );
    } catch (e) {
      //todo bursi yazdiriliacak widget bir sayfaya  sigmadiginda hhata verdigin icin kondu daha iyi hale getirilebilir
      final doc = pw.Document();
      await PrintHelper.printMultiplePagePdf([PrintWidgetHelper.myTextContainer(text: 'survey'.translate), PrintWidgetHelper.makeTable(data.first, data.sublist(1).map((e) => e.map((item) => item.firstXcharacter(500)!.replaceAll('\n', ' ')).toList()).toList(), headerFontSize: 8)],
          orientation: pw.PageOrientation.landscape, doc: doc);
    }
  }
}
