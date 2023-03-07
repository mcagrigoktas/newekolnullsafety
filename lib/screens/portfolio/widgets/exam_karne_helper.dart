import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:random_color/random_color.dart';

import '../../../adminpages/screens/evaulationadmin/exams/model.dart';
import '../../../adminpages/screens/evaulationadmin/examtypes/model.dart';
import '../../../helpers/print/pdf_widgets.dart';
import '../model.dart';

class ExamKarneHelper {
  ExamKarneHelper._();
  static Widget mBookLetType(PortfolioExamReport data) => ('booklettype'.translate + ': ${data.result.bookletTypes?.fold('', (dynamic p, e) => p + e) ?? ''}').text.color(Colors.white).make().stadium();
  static pw.Widget pBookLetType(PortfolioExamReport data) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
          decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(4), color: Fav.design.primary.toPdfColor),
          padding: pw.EdgeInsets.all(2),
          child: pw.Text(('booklettype'.translate + ': ${data.result.bookletTypes?.fold('', (dynamic p, e) => p + e) ?? ''}'), style: pw.TextStyle(color: PdfColors.white, fontSize: 8))));

  static const List<double> widthListLessons = [100, 50, 250, 250, 100];
  static const List<double> heightListLessons = [50, 30];
  static List<Color> colorListLessons = Iterable.generate(120)
      .map(
        (_) => RandomColor().randomColor(colorBrightness: Fav.design.brightness == Brightness.dark ? ColorBrightness.dark : ColorBrightness.light),
      )
      .toList();
  //? Burasi karnede Ders Sonuclari ileGenel basari orani arasindaki sadece basliklar
  static List<T> lessonResultHeader<T>(bool isWritebleQuestionEnable, int type, {double scale = 1}) {
    return [
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[0],
        height: heightListLessons[0],
        background: colorListLessons[30].withAlpha(50),
        bold: true,
        fontSize: 16,
        scale: scale,
        text: 'testresults'.translate,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[1].withAlpha(50),
        text: 'questioncount'.translate,
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[2].withAlpha(50),
        text: 'ds2'.translate,
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[3].withAlpha(50),
        text: 'ys2'.translate,
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[4].withAlpha(50),
        text: 'bs2'.translate,
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[5].withAlpha(50),
        text: 'ns2'.translate,
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      if (isWritebleQuestionEnable) ...[
        LessonResultCell<T>(
          width: widthListLessons[1],
          height: heightListLessons[0],
          background: colorListLessons[10].withAlpha(50),
          text: 'wquestioncount'.translate,
          fontSize: 10,
          scale: scale,
          bold: true,
        )(type),
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[0],
          background: colorListLessons[11].withAlpha(50),
          text: 'wds2'.translate,
          fontSize: 10,
          scale: scale,
          bold: true,
        )(type),
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[0],
          background: colorListLessons[12].withAlpha(50),
          text: 'wys2'.translate,
          fontSize: 10,
          scale: scale,
          bold: true,
        )(type),
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[0],
          background: colorListLessons[13].withAlpha(50),
          text: 'wbs2'.translate,
          fontSize: 10,
          scale: scale,
          bold: true,
        )(type),
      ],
      if (type == 0) PSizedBox<T>(width: 16 * scale)(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[20].withAlpha(50),
        text: 'ep'.translate + ' (%)',
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[21].withAlpha(50),
        text: 'class'.translate + ' ' + 'ep'.translate + ' (%)',
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[22].withAlpha(50),
        text: 'school'.translate + ' ' + 'ep'.translate + ' (%)',
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[23].withAlpha(50),
        text: 'general'.translate + ' ' + 'ep'.translate + ' (%)',
        fontSize: 10,
        scale: scale,
        bold: true,
      )(type),
    ];
  }

  //? Burasi karnede her dersin Ders Sonuclari ileGenel basari orani arasindaki sonuclari
  static List<T> lessonResultStudent<T>(bool isWritebleQuestionEnable, ExamTypeLesson item, TestResultModel result, int type, double scale) {
    return [
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[0],
        height: heightListLessons[1],
        text: item.name,
        background: colorListLessons[0].withAlpha(50),
        scale: scale,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[1].withAlpha(50),
        text: item.questionCount.toString(),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[2].withAlpha(50),
        text: result.d.toString(),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[3].withAlpha(50),
        text: result.y.toString(),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[4].withAlpha(50),
        text: result.b.toString(),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[5].withAlpha(50),
        text: result.n!.toStringAsFixed(2),
        scale: scale,
        fontSize: 12,
      )(type),
      if (isWritebleQuestionEnable) ...[
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[1],
          background: colorListLessons[10].withAlpha(50),
          text: item.wQuestionCount.toString(),
          scale: scale,
          fontSize: 12,
        )(type),
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[1],
          background: colorListLessons[11].withAlpha(50),
          text: result.wd.toString(),
          scale: scale,
          fontSize: 12,
        )(type),
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[1],
          background: colorListLessons[12].withAlpha(50),
          text: result.wy.toString(),
          scale: scale,
          fontSize: 12,
        )(type),
        LessonResultCell<T>(
          padding: Inset(0),
          width: widthListLessons[1],
          height: heightListLessons[1],
          background: colorListLessons[13].withAlpha(50),
          text: result.wb.toString(),
          scale: scale,
          fontSize: 12,
        )(type),
      ],
      if (type == 0) PSizedBox<T>(width: 16 * scale)(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[20].withAlpha(50),
        text: (100 * result.n! / item.questionCount!).toStringAsFixed(2),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[21].withAlpha(50),
        text: (100 * result.classAwerage! / item.questionCount!).toStringAsFixed(2),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[22].withAlpha(50),
        text: (100 * result.schoolAwerage! / item.questionCount!).toStringAsFixed(2),
        scale: scale,
        fontSize: 12,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[1],
        background: colorListLessons[23].withAlpha(50),
        text: (100 * result.generalAwerage! / item.questionCount!).toStringAsFixed(2),
        scale: scale,
        fontSize: 12,
      )(type),
    ];
  }

  static Widget mBasariGrafigiHeaderWidget() {
    return Container(
      width: widthListLessons[2],
      height: heightListLessons[0],
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: colorListLessons[31].withAlpha(50), borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Expanded(child: 'eg'.translate.text.bold.make()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ['student'.translate, Colors.greenAccent],
              ['class'.translate, Colors.deepPurpleAccent],
              ['school'.translate, Colors.pinkAccent],
              ['general'.translate, Colors.blueAccent],
            ]
                .map(
                  (e) => Row(
                    children: [
                      CircleAvatar(radius: 2, backgroundColor: e[1] as Color?).pr2,
                      (e[0] as String).text.fontSize(8).make().pr4,
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget pBasariGrafigiHeaderWidget() {
    const _scale = 0.5;
    return pw.Container(
      width: 50,
      height: heightListLessons[0] * _scale,
      padding: pw.EdgeInsets.symmetric(horizontal: 10 * _scale),
      decoration: pw.BoxDecoration(color: PdfColor(0, 0, 0, 0.01).flatten(), borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text('eg'.translate, style: pw.TextStyle(color: PdfColors.black, fontSize: 10 * _scale, fontWeight: pw.FontWeight.bold))),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              ['student'.translate, Colors.grey.shade900],
              ['class'.translate, Colors.grey.shade700],
              ['school'.translate, Colors.grey.shade500],
              ['general'.translate, Colors.grey.shade300],
            ]
                .map(
                  (e) => pw.Row(
                    children: [
                      pw.Container(width: 4 * _scale, height: 4 * _scale, decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(2 * _scale), color: (e[1] as Color).toPdfColor.flatten())),
                      pw.SizedBox(width: 2),
                      pw.Text((e[0] as String), style: pw.TextStyle(color: PdfColors.black, fontSize: 6 * _scale, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static T studentAnswersHeader<T>(int type, double scale) {
    return LessonResultCell<T>(
      width: widthListLessons[3],
      height: heightListLessons[0],
      background: colorListLessons[30].withAlpha(50),
      text: 'esa'.translate,
      fontSize: 10,
      scale: scale,
      bold: true,
    )(type);
  }

  //? Burasi genel derece headeri
  static List<T> orderHeader<T>(int type) {
    return [
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[0],
        height: heightListLessons[0],
        background: colorListLessons[30].withAlpha(50),
        bold: true,
        fontSize: 16,
        scale: type == 1 ? 0.5 : 1,
        text: 'scoreresults'.translate,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[1].withAlpha(50),
        text: 'score'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
      if (type == 0) PSizedBox(width: 16)(0),
      //else PSpacer()(1),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[2].withAlpha(50),
        text: 'esca'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[3].withAlpha(50),
        text: 'essa'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[1],
        height: heightListLessons[0],
        background: colorListLessons[4].withAlpha(50),
        text: 'esga'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
      if (type == 0) PSizedBox(width: 16)(0),
      //else PSpacer()(1),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[4],
        height: heightListLessons[0],
        background: colorListLessons[40].withAlpha(50),
        text: 'esco'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[4],
        height: heightListLessons[0],
        background: colorListLessons[41].withAlpha(50),
        text: 'esso'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
      LessonResultCell<T>(
        padding: Inset(0),
        width: widthListLessons[4],
        height: heightListLessons[0],
        background: colorListLessons[2].withAlpha(50),
        text: 'esgo'.translate,
        fontSize: 10,
        scale: type == 1 ? 0.5 : 1,
        bold: true,
      )(type),
    ];
  }

  static List<T> orderStudentResult<T>(int type, PortfolioExamReport data) {
    return data.examType.scoring!.fold<List<T>>(<T>[], (p, e) {
      final item = e;
      final result = data.result.scoreResults![e.key]!;
      return p
        ..add(PRow<T>(
          children: [
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[0],
              height: heightListLessons[1],
              text: item.name,
              background: colorListLessons[0].withAlpha(50),
              scale: type == 0 ? 1 : 0.5,
              bold: true,
            )(type),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[1],
              height: heightListLessons[1],
              background: colorListLessons[1].withAlpha(50),
              text: result.score.toString(),
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            if (type == 0) PSizedBox(width: 16)(0),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[1],
              height: heightListLessons[1],
              background: colorListLessons[2].withAlpha(50),
              text: result.classAwerage.toString(),
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[1],
              height: heightListLessons[1],
              background: colorListLessons[3].withAlpha(50),
              text: result.schoolAwerage.toString(),
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[1],
              height: heightListLessons[1],
              background: colorListLessons[4].withAlpha(50),
              text: result.generalAwerage.toString(),
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            if (type == 0) PSizedBox(width: 16)(0),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[4],
              height: heightListLessons[1],
              background: colorListLessons[40].withAlpha(50),
              text: '${result.classOrder} / ${result.classStudentCount}',
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[4],
              height: heightListLessons[1],
              background: colorListLessons[41].withAlpha(50),
              text: '${result.schoolOrder} / ${result.schoolStudentCount}',
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            LessonResultCell<T>(
              padding: Inset(0),
              width: widthListLessons[4],
              height: heightListLessons[1],
              background: colorListLessons[42].withAlpha(50),
              text: '${result.generalOrder} / ${result.generalStudentCount}',
              scale: type == 0 ? 1 : 0.5,
              fontSize: 12,
            )(type),
            if (type == 0) PSizedBox(width: 16)(0),
            PSizedBox<T>(
              width: type == 0 ? widthListLessons[2] : 50,
              height: type == 0 ? heightListLessons[1] : 16,
              child: PColumn<T>(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  [result.score / item.maxValue!, Colors.greenAccent, Colors.grey.shade900],
                  [result.classAwerage! / item.maxValue!, Colors.deepPurpleAccent, Colors.grey.shade700],
                  [result.schoolAwerage! / item.maxValue!, Colors.pinkAccent, Colors.grey.shade500],
                  [result.generalAwerage! / item.maxValue!, Colors.blueAccent, Colors.grey.shade300],
                ]
                    .map((e) => type == 0
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              backgroundColor: (e[1] as Color).withAlpha(50),
                              value: e[0] as double?,
                              valueColor: AlwaysStoppedAnimation<Color>(e[1] as Color),
                            ),
                          ) as T
                        : pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 0.3),
                            height: 3,
                            child: pw.ClipRRect(
                              verticalRadius: 1,
                              horizontalRadius: 1,
                              child: pw.LinearProgressIndicator(
                                backgroundColor: (Colors.black).withAlpha(10).toPdfColor.flatten(),
                                value: e[0] as double,
                                valueColor: (e[2] as Color).toPdfColor.flatten(),
                              ),
                            )) as T)
                    .toList(),
              )(type),
            )(type),
          ],
        )(type));
    });
  }

  //? Kazanim listesini widget icin yazdirir
  static List<T> mKazanimList<T>(PortfolioExamReport data, int type, bool isWritebleQuestionEnable) {
    int l = 0;
    return data.examType.lessons!.fold<List<T>>([], (p, e) {
      l++;
      final item = e;
      final result = data.result.testResults![item.key]!;
      final earningResultsEntries = result.earningResults?.entries.toList();
      final wEarningResultsEntries = result.wEarningResults?.entries.toList();
      final double scale = type == 1 ? 0.7 : 1.0;

      return p
        ..add(PColumn<T>(
          children: [
            PSizedBox(height: 16 * scale)(type),
            PRow(
              children: [
                PExpanded<T>(
                  child: LessonResultCell<T>(
                    height: heightListLessons[1],
                    background: colorListLessons[50 + l].withAlpha(50),
                    text: item.name,
                    fontSize: 12,
                    scale: scale,
                    bold: true,
                  )(type),
                )(type),
                LessonResultCell<T>(
                  width: widthListLessons[1],
                  height: heightListLessons[1],
                  background: colorListLessons[2].withAlpha(50),
                  text: 'ds2'.translate,
                  fontSize: 10,
                  scale: scale,
                  bold: true,
                )(type),
                LessonResultCell<T>(
                  width: widthListLessons[1],
                  height: heightListLessons[1],
                  background: colorListLessons[3].withAlpha(50),
                  text: 'ys2'.translate,
                  fontSize: 10,
                  scale: scale,
                  bold: true,
                )(type),
                LessonResultCell<T>(
                  width: widthListLessons[1],
                  height: heightListLessons[1],
                  background: colorListLessons[4].withAlpha(50),
                  text: 'bs2'.translate,
                  fontSize: 10,
                  scale: scale,
                  bold: true,
                )(type),
              ],
            )(type),
            if (earningResultsEntries != null)
              for (var e = 0; e < earningResultsEntries.length; e++)
                PRow(
                  children: [
                    PExpanded<T>(
                        child: LessonResultCell<T>(
                      // width: widthListLessons[4],
                      height: heightListLessons[1],
                      background: colorListLessons[50 + l].withAlpha(50),
                      text: data.earningResultKeyMap![earningResultsEntries[e].key!] ?? '-',
                      fontSize: 12,
                      scale: scale,
                      alignment: Alignment.topLeft,
                    )(type))(type),
                    LessonResultCell<T>(
                      width: widthListLessons[1],
                      height: heightListLessons[1],
                      background: colorListLessons[2].withAlpha(50),
                      text: (earningResultsEntries[e].value['d'] ?? 0).toString(),
                      fontSize: 10,
                      scale: scale,
                      bold: true,
                    )(type),
                    LessonResultCell<T>(
                      width: widthListLessons[1],
                      height: heightListLessons[1],
                      background: colorListLessons[3].withAlpha(50),
                      text: (earningResultsEntries[e].value['y'] ?? 0).toString(),
                      fontSize: 10,
                      scale: scale,
                      bold: true,
                    )(type),
                    LessonResultCell<T>(
                      width: widthListLessons[1],
                      height: heightListLessons[1],
                      background: colorListLessons[4].withAlpha(50),
                      text: (earningResultsEntries[e].value['b'] ?? 0).toString(),
                      fontSize: 10,
                      scale: scale,
                      bold: true,
                    )(type),
                  ],
                )(type),
            if (wEarningResultsEntries != null && isWritebleQuestionEnable)
              for (var e = 0; e < wEarningResultsEntries.length; e++)
                PRow(
                  children: [
                    PExpanded(
                        child: LessonResultCell<T>(
                      // width: widthListLessons[4],
                      height: heightListLessons[1],
                      background: colorListLessons[50 + l].withAlpha(50),
                      text: data.earningResultKeyMap![wEarningResultsEntries[e].key] ?? '-',
                      fontSize: 12,
                      alignment: Alignment.topLeft,
                      scale: scale,
                    )(type))(type),
                    LessonResultCell<T>(
                      width: widthListLessons[1],
                      height: heightListLessons[1],
                      background: colorListLessons[2].withAlpha(50),
                      text: (wEarningResultsEntries[e].value['d'] ?? 0).toString(),
                      fontSize: 10,
                      bold: true,
                      scale: scale,
                    )(type),
                    LessonResultCell<T>(
                      width: widthListLessons[1],
                      height: heightListLessons[1],
                      background: colorListLessons[3].withAlpha(50),
                      text: (wEarningResultsEntries[e].value['y'] ?? 0).toString(),
                      fontSize: 10,
                      bold: true,
                      scale: scale,
                    )(type),
                    LessonResultCell<T>(
                      width: widthListLessons[1],
                      height: heightListLessons[1],
                      background: colorListLessons[4].withAlpha(50),
                      text: (wEarningResultsEntries[e].value['b'] ?? 0).toString(),
                      fontSize: 10,
                      bold: true,
                      scale: scale,
                    )(type),
                  ],
                )(type)
          ],
        )(type));
    });

    // return [
    //   for (var l = 0; l < data.examType.lessons.length; l++)
    //     Builder(builder: (context) {

    //       return ;
    //     })
    // ];
  }

  //? Kazanim listesini widget icin yazdirir
  static List<T> pKazanimList<T>(PortfolioExamReport data, int type, bool isWritebleQuestionEnable, double itemFontSize) {
    int l = 0;
    return data.examType.lessons!.fold<List<T>>([], (p, e) {
      l++;
      final _item = e;
      final _result = data.result.testResults![_item.key]!;
      final _earningResultsEntries = _result.earningResults?.entries.toList();
      final _wEarningResultsEntries = _result.wEarningResults?.entries.toList();
      final double _scale = type == 1 ? 0.3 : 1.0;
      final _margin = EdgeInsets.all(0.2);
      final _padding = EdgeInsets.all(0.3);

      p.add(PRow(
        children: [
          PExpanded<T>(
            flex: 9,
            child: EarningItenCell<T>(
              background: colorListLessons[50 + l].withAlpha(50),
              text: _item.name,
              fontSize: 1.2 * itemFontSize,
              scale: _scale,
              bold: true,
              textAlign: TextAlign.center,
            )(type),
          )(type),
          PExpanded<T>(
            child: EarningItenCell<T>(
              background: colorListLessons[2].withAlpha(50),
              text: 'ds'.translate,
              fontSize: itemFontSize,
              scale: _scale,
              bold: true,
              textAlign: TextAlign.center,
            )(type),
          )(type),
          PExpanded<T>(
            child: EarningItenCell<T>(
              background: colorListLessons[3].withAlpha(50),
              text: 'ys'.translate,
              fontSize: itemFontSize,
              scale: _scale,
              bold: true,
              textAlign: TextAlign.center,
            )(type),
          )(type),
          PExpanded<T>(
            child: EarningItenCell<T>(
              background: colorListLessons[4].withAlpha(50),
              text: 'bs'.translate,
              fontSize: itemFontSize,
              scale: _scale,
              bold: true,
              textAlign: TextAlign.center,
            )(type),
          )(type),
        ],
      )(type));

      if (_earningResultsEntries != null)
        for (var e = 0; e < _earningResultsEntries.length; e++)
          p.add(PRow(
            children: [
              PExpanded<T>(
                  flex: 9,
                  child: EarningItenCell<T>(
                    margin: _margin,
                    padding: _padding,

                    // width: widthListLessons[4],
                    background: colorListLessons[50 + l].withAlpha(50),
                    text: data.earningResultKeyMap![_earningResultsEntries[e].key!] ?? '-',
                    fontSize: 1.2 * itemFontSize,
                    scale: _scale,
                    bold: false,
                  )(type))(type),
              PExpanded<T>(
                child: EarningItenCell<T>(
                  margin: _margin,
                  padding: _padding,
                  background: colorListLessons[2].withAlpha(50),
                  text: (_earningResultsEntries[e].value['d'] ?? 0).toString(),
                  fontSize: itemFontSize,
                  scale: _scale,
                  bold: true,
                  textAlign: TextAlign.center,
                )(type),
              )(type),
              PExpanded<T>(
                child: EarningItenCell<T>(
                  margin: _margin,
                  padding: _padding,
                  background: colorListLessons[3].withAlpha(50),
                  text: (_earningResultsEntries[e].value['y'] ?? 0).toString(),
                  fontSize: itemFontSize,
                  scale: _scale,
                  bold: true,
                  textAlign: TextAlign.center,
                )(type),
              )(type),
              PExpanded<T>(
                child: EarningItenCell<T>(
                  margin: _margin,
                  padding: _padding,
                  background: colorListLessons[4].withAlpha(50),
                  text: (_earningResultsEntries[e].value['b'] ?? 0).toString(),
                  fontSize: itemFontSize,
                  scale: _scale,
                  bold: true,
                  textAlign: TextAlign.center,
                )(type),
              )(type),
            ],
          )(type));
      if (_wEarningResultsEntries != null && isWritebleQuestionEnable)
        for (var e = 0; e < _wEarningResultsEntries.length; e++)
          p.add(PRow(
            children: [
              PExpanded(
                  flex: 9,
                  child: EarningItenCell<T>(
                    margin: _margin,
                    padding: _padding,
                    // width: widthListLessons[4],
                    background: colorListLessons[50 + l].withAlpha(50),
                    text: data.earningResultKeyMap![_wEarningResultsEntries[e].key] ?? '-',
                    fontSize: 1.2 * itemFontSize,
                    scale: _scale,
                    bold: false,
                    textAlign: TextAlign.center,
                  )(type))(type),
              PExpanded<T>(
                child: EarningItenCell<T>(
                  margin: _margin,
                  padding: _padding,
                  background: colorListLessons[2].withAlpha(50),
                  text: (_wEarningResultsEntries[e].value['d'] ?? 0).toString(),
                  fontSize: itemFontSize,
                  bold: true,
                  scale: _scale,
                  textAlign: TextAlign.center,
                )(type),
              )(type),
              PExpanded<T>(
                child: EarningItenCell<T>(
                  margin: _margin,
                  padding: _padding,
                  background: colorListLessons[3].withAlpha(50),
                  text: (_wEarningResultsEntries[e].value['y'] ?? 0).toString(),
                  fontSize: itemFontSize,
                  bold: true,
                  scale: _scale,
                  textAlign: TextAlign.center,
                )(type),
              )(type),
              PExpanded<T>(
                child: EarningItenCell<T>(
                  margin: _margin,
                  padding: _padding,
                  background: colorListLessons[4].withAlpha(50),
                  text: (_wEarningResultsEntries[e].value['b'] ?? 0).toString(),
                  fontSize: itemFontSize,
                  bold: true,
                  scale: _scale,
                  textAlign: TextAlign.center,
                )(type),
              )(type),
            ],
          )(type));
      p.add(PSizedBox(height: 8 * _scale)(type));
      return p;
    });
  }
}

//? Kazanim listesindeki itemler  icin widget. Sadece yazdirma kismina eklendi goruntuleme kisminada eklenince bu notu sil
//? [LessonResultCell] den tek farki alignment konusu..
class EarningItenCell<T> {
  final double? width;
  final double? height;
  final Color? background;
  final PdfColors? pdfTextColor;
  final String? text;
  final double fontSize;
  final bool bold;
  final double scale;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final TextAlign? textAlign;

  T call(int type) => PContainer<T>(
      margin: margin ?? EdgeInsets.all(1 * scale),
      padding: padding ?? EdgeInsets.all(8 * scale),
      width: width == null ? null : width! * scale,
      height: height == null ? null : height! * scale,
      borderRadius: 4 * scale,
      color: background,
      pdfBackgroundColor: PdfColor(0, 0, 0, 0.02).flatten(), //background == null ? null : background.toPdfColor.flatten(),
      child: text == null
          ? null
          : PCenter<T>(child: PText<T>(text!, textAlign: textAlign, style: TextStyle(fontSize: fontSize * scale, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: Fav.design.primaryText), pdfTextColor: pdfTextColor as PdfColor? ?? PdfColors.black)(type))(type))(type);

  EarningItenCell({this.width, this.height, this.text, this.background, this.textAlign, this.fontSize = 14, this.bold = false, this.pdfTextColor, this.scale = 1, this.margin, this.padding});
}

class LessonResultCell<T> {
  final double? width;
  final double? height;
  final Color? background;
  final PdfColors? pdfTextColor;
  final String? text;
  final double fontSize;
  final bool bold;
  final Alignment? alignment;
  final double scale;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  T call(int type) => PContainer<T>(
      margin: margin ?? EdgeInsets.all(1 * scale),
      padding: padding ?? EdgeInsets.all(8 * scale),
      width: width == null ? null : width! * scale,
      height: height == null ? null : height! * scale,
      alignment: alignment ?? Alignment.center,
      borderRadius: 4 * scale,
      color: background,
      pdfBackgroundColor: PdfColor(0, 0, 0, 0.02).flatten(), //background == null ? null : background.toPdfColor.flatten(),
      child: text == null ? null : PText(text!, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize * scale, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: Fav.design.primaryText), pdfTextColor: pdfTextColor as PdfColor? ?? PdfColors.black)(type))(type);

  LessonResultCell({this.width, this.height, this.text, this.background, this.fontSize = 14, this.bold = false, this.pdfTextColor, this.scale = 1, this.alignment, this.margin, this.padding});
}
