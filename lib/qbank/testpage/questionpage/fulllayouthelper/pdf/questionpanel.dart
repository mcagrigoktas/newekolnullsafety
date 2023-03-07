import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../models/models.dart';
import '../../../qbankrichtext/questionwidgets.dart';
import 'crop_pdf_view/pdfquestionview.dart';

class PdfSoruPaneli extends StatefulWidget {
  @override
  PdfSoruPaneliState createState() {
    return PdfSoruPaneliState();
  }
}

class PdfSoruPaneliState extends State<PdfSoruPaneli> with TickerProviderStateMixin, QuestionWidget {
  @override
  Widget build(BuildContext context) {
    if (AppVar.questionPageController.pdfDocument == null) return Container();

    Question question = AppVar.questionPageController.getTest!.questions[AppVar.questionPageController.secilenSoruIndex!];

    if (question.soru == null || question.soru!.isEmpty) return Container();

    final RegExp regExp2 = RegExp("#w [^#]+w#");
    var allMatch = regExp2.allMatches(question.soru!.first.text!);
    final data = json.decode(allMatch.elementAt(0).group(0)!.replaceAll("#w", "").replaceAll("w#", "").trim());

    //question.coordinate
    // todo burada sorunun koordinatlarini cekmellisin
    final int? pageno = data['data']['page'];
    final int? topLeftX = data['data']['left'];
    final int? topLeftY = data['data']['top'];
    final int? bottomRightX = data['data']['right'];
    final int? bottomRightY = data['data']['bottom'];

    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        gradient: AppVar.questionPageController.theme!.questionBgGradient,
        boxShadow: [BoxShadow(blurRadius: 4.0, color: AppVar.questionPageController.theme!.questionBgShadowColor!)],
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      margin: const EdgeInsets.all(8.0),
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 222),
        reverseDuration: const Duration(milliseconds: 222),
        child: PdfQuestionView(
          key: Key('MainBookLet${AppVar.questionPageController.secilenSoruIndex}'),
          initialPage: pageno,
          leftTopX: topLeftX,
          leftTopY: topLeftY,
          rightBottomX: bottomRightX,
          rightBottomY: bottomRightY,
          document: AppVar.questionPageController.pdfDocument,
          viewPort: 3,
        ),
      ),
    );
  }
}
