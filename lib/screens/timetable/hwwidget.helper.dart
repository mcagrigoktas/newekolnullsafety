import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../helpers/print/pdf_widgets.dart';
import '../../models/lesson.dart';
import 'homework/homework_check_helper.dart';

class HomeWorkWidgetHelper {
  HomeWorkWidgetHelper._();
  static Widget getNote(String noteText) {
    String note;
    String? tur;
    if (noteText.split('-t:').last == '0') {
      note = noteText.split('-t:').first == '-1' ? '?'.translate : 'hwdone${noteText.split('-t:').first}'.translate;
    } else {
      note = noteText.split('-t:').first == '-1' ? '?'.translate : noteText.split('-t:').first;
      tur = noteText.split('-t:').last == '1' ? '100' : (noteText.split('-t:').last == '2' ? '10' : '5');
    }

    return SizedBox(
      width: 40,
      height: 20,
      child: tur != null
          ? FittedBox(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(text: note, style: TextStyle(color: Fav.design.primaryText, fontSize: noteText.split('-t:').last == '0' ? 11 : 15, fontWeight: FontWeight.bold)),
                  TextSpan(text: '/', style: TextStyle(color: Fav.design.primaryText.withAlpha(180), fontSize: 9, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic)),
                  TextSpan(text: tur, style: TextStyle(color: Fav.design.primaryText.withAlpha(100), fontSize: 10, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic)),
                ]),
              ),
            )
          : note.text.bold.autoSize.maxLines(2).center.make(),
    );
  }

  static Widget getExamNoteForPortfolio(HomeWorkCheck item, Lesson lesson) {
    String noteText = item.noteText!;
    String note;
    // String tur;
    if (noteText.split('-t:').last == '0') {
      note = noteText.split('-t:').first == '-1' ? '?'.translate : 'hwdone${noteText.split('-t:').first}'.translate;
    } else {
      note = noteText.split('-t:').first == '-1' ? '?'.translate : noteText.split('-t:').first;
      //   tur = noteText.split('-t:').last == '1' ? '100' : (noteText.split('-t:').last == '2' ? '10' : '5');
    }

    final _transparentColor = lesson.color.parseColor.withOpacity(0.1);
    final _color = lesson.color.parseColor;
    return GestureDetector(
      onTap: () {
        OverBottomSheet.show(BottomSheetPanel.child(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            lesson.name.text.color(_color).fontSize(24).make(),
            item.title.text.bold.make().p8,
            item.content.text.make(),
            Transform.scale(scale: 2.0, child: getNote(noteText)).py16,
            MyRaisedButton(
              onPressed: OverBottomSheet.closeBottomSheet,
              text: 'ok'.translate,
              color: _color,
            ),
          ],
        )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: _transparentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 100,
          height: 100,
          child: Column(
            children: [
              Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )),
                child: item.title!.toUpperCase().replaceAll(lesson.longName!.toUpperCase(), '').text.autoSize.height(1.05).color(Colors.white).maxLines(2).center.make().p2,
              ),
              Expanded(
                child: Center(child: note.text.bold.autoSize.color(_color).fontSize(40).maxLines(1).center.make()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static pw.Widget getNoteForPdf(String noteText) {
    String note;
    String? tur;
    if (noteText.split('-t:').last == '0') {
      note = noteText.split('-t:').first == '-1' ? '?'.translate : 'hwdone${noteText.split('-t:').first}'.translate;
    } else {
      note = noteText.split('-t:').first == '-1' ? '?'.translate : noteText.split('-t:').first;
      tur = noteText.split('-t:').last == '1' ? '100' : (noteText.split('-t:').last == '2' ? '10' : '5');
    }

    return pw.Container(
      height: 20,
      decoration: pw.BoxDecoration(
          border: pw.Border.all(
        width: 1.0,
      )),
      alignment: pw.Alignment.center,
      child: tur != null
          ? pw.RichText(
              textAlign: pw.TextAlign.center,
              text: pw.TextSpan(children: [
                pw.TextSpan(text: note, style: pw.TextStyle(color: Fav.design.primaryText.toPdfColor.flatten(), fontSize: noteText.split('-t:').last == '0' ? 9 : 10, fontWeight: pw.FontWeight.bold)),
                pw.TextSpan(text: '/', style: pw.TextStyle(color: Fav.design.primaryText.withAlpha(180).toPdfColor.flatten(), fontSize: 8, fontWeight: pw.FontWeight.normal, fontStyle: pw.FontStyle.italic)),
                pw.TextSpan(text: tur, style: pw.TextStyle(color: Fav.design.primaryText.withAlpha(100).toPdfColor.flatten(), fontSize: 9, fontWeight: pw.FontWeight.normal, fontStyle: pw.FontStyle.italic)),
              ]),
            )
          : pw.Text(note, maxLines: 2, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
    );
  }
}
