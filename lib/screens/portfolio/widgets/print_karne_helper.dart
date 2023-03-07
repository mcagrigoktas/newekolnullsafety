import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../helpers/print/pdf_widgets.dart';
import '../../../helpers/print/printhelper.dart';
import '../model.dart';
import 'exam_karne_helper.dart';

class PrintKarneHelper {
  PrintKarneHelper._();
  static pw.Widget _prepareSingleKarne(PortfolioExamReport data, {double earnintItemFontSize = 10}) {
    const _scale = 0.5;
    final isWritebleQuestionEnable = data.examType.lessons!.any((element) => element.wQuestionCount! > 0);

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      PRow<pw.Widget>(children: [
        pw.Expanded(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          PText(data.result.rSName!, pdfTextColor: Fav.design.primary.toPdfColor, style: TextStyle(fontWeight: FontWeight.bold))(1),
          PText(data.result.rSClass!, pdfTextColor: PdfColors.black, style: TextStyle(fontSize: 8))(1),
        ])),
        pw.Expanded(
          child: pw.Column(children: [
            PText(data.exam.name!, maxLines: 1)(1),
            PText(data.exam.date!.dateFormat('d-MMM-yyyy'), style: TextStyle(fontSize: 8))(1),
          ]),
        ),
        pw.Expanded(child: ExamKarneHelper.pBookLetType(data)),
      ])(1),
      PSizedBox(height: 1)(1),
      PRow<pw.Widget>(children: [
        ...ExamKarneHelper.lessonResultHeader<pw.Widget>(isWritebleQuestionEnable, 1, scale: _scale),
        ExamKarneHelper.pBasariGrafigiHeaderWidget(),
        pw.Expanded(child: ExamKarneHelper.studentAnswersHeader(1, 0.5)),
      ])(1),
      //? ders sonucleri ekleniyor
      for (var l = 0; l < data.examType.lessons!.length; l++)
        pw.Builder(builder: (context) {
          final item = data.examType.lessons![l];
          final result = data.result.testResults![item.key]!;
          return pw.Row(children: [
            ...ExamKarneHelper.lessonResultStudent<pw.Widget>(isWritebleQuestionEnable, item, result, 1, _scale),
            pw.SizedBox(
              width: 50,
              height: 16,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  [result.n! / item.questionCount!, Colors.grey.shade900],
                  [result.classAwerage! / item.questionCount!, Colors.grey.shade700],
                  [result.schoolAwerage! / item.questionCount!, Colors.grey.shade500],
                  [result.generalAwerage! / item.questionCount!, Colors.grey.shade300],
                ]
                    .map((e) => pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 0.3),
                        height: 3,
                        child: pw.ClipRRect(
                          verticalRadius: 1,
                          horizontalRadius: 1,
                          child: pw.LinearProgressIndicator(
                            backgroundColor: (Colors.black).withAlpha(10).toPdfColor.flatten(),
                            value: e[0] as double,
                            valueColor: (e[1] as Color).toPdfColor,
                          ),
                        )))
                    .toList(),
              ),
            ),
            pw.Expanded(
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Row(children: [
                ...Iterable.generate([result.studentAnswers!.length, result.realAnswers!.length].min)
                    .fold<String>('', (p, e) => p + (e + 1).toString().lastXcharacter(1)!)
                    .characters
                    .map<pw.Widget>(
                      (e) => PContainer<pw.Widget>(alignment: Alignment.center, width: 2.8, child: PText(e, style: TextStyle(fontSize: 4))(1))(1),
                    )
                    .toList()
                  ..insert(0, PSizedBox<pw.Widget>(width: 18)(1))
              ]),
              pw.Row(children: [
                ...Iterable.generate([result.studentAnswers!.length, result.realAnswers!.length].min)
                    .fold<String>('', (p, e) => p + result.studentAnswers![e].toUpperCase())
                    .characters
                    .map<pw.Widget>(
                      (e) => PContainer<pw.Widget>(alignment: Alignment.center, width: 2.8, child: PText(e, style: TextStyle(fontSize: 4))(1))(1),
                    )
                    .toList()
                  ..insert(0, PContainer<pw.Widget>(alignment: Alignment.center, margin: EdgeInsets.only(left: 1, right: 1), pdfBackgroundColor: PdfColor(0.7, 0.2, 0.5, 0.02).flatten(), borderRadius: 2, width: 16, child: PText('student'.translate, style: TextStyle(fontSize: 3))(1))(1))
              ]),
              pw.Row(children: [
                ...Iterable.generate([result.studentAnswers!.length, result.realAnswers!.length].min)
                    .fold<String>('', (p, e) => p + result.realAnswers![e].toUpperCase())
                    .characters
                    .map<pw.Widget>(
                      (e) => PContainer<pw.Widget>(alignment: Alignment.center, width: 2.8, child: PText(e, style: TextStyle(fontSize: 4))(1))(1),
                    )
                    .toList()
                  ..insert(0, PContainer<pw.Widget>(alignment: Alignment.center, margin: EdgeInsets.only(left: 1, right: 1), pdfBackgroundColor: PdfColor(0.7, 0.2, 0.5, 0.02).flatten(), borderRadius: 2, width: 16, child: PText('answer'.translate, style: TextStyle(fontSize: 3))(1))(1))
              ]),
            ]))
          ]);
        }),
      PSizedBox(height: 1)(1),
      pw.Row(children: [
        ...ExamKarneHelper.orderHeader<pw.Widget>(1),
        ExamKarneHelper.pBasariGrafigiHeaderWidget(),
      ]),
      ...ExamKarneHelper.orderStudentResult(1, data),
      PSizedBox(height: 2)(1),
      if (data.earningResultKeyMap != null)
        LessonResultCell<pw.Widget>(
          height: 30,
          background: Color(0x10000000),
          scale: 0.5,
          text: 'earningstatisticshead'.translate,
          fontSize: 12,
          bold: true,
        )(1),
      if (data.earningResultKeyMap != null)
        pw.Expanded(
            child: PWrap<pw.Widget>(crossAxisAlignment: WrapCrossAlignment.start, alignment: WrapAlignment.start, runAlignment: WrapAlignment.start, runSpacing: 4, spacing: 0, direction: Axis.vertical, children: [
          ...ExamKarneHelper.pKazanimList<pw.Widget>(data, 1, isWritebleQuestionEnable, earnintItemFontSize).map((e) => pw.SizedBox(width: 175, child: e)).toList(),
        ])(1)),
    ]);
  }

  static void print(PortfolioExamReport data) {
    PrintHelper.printPdf(_prepareSingleKarne(data));
  }

  static void printFullKarne(List<PortfolioExamReport> allStudentResultModel, {double earnintItemFontSize = 10}) {
    PrintHelper.printMultiplePagePdf(allStudentResultModel.map((item) => PSizedBox(height: 25.7 * 72 / 2.54, child: _prepareSingleKarne(item, earnintItemFontSize: earnintItemFontSize))(1)).toList());
  }
}
