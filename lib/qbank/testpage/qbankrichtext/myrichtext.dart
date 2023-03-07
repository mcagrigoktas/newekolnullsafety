// ignore_for_file: unnecessary_string_escapes, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../appbloc/appvar.dart';
import '../../../library_helper/flutter_math/math_widget.dart';
import '../../models/models.dart';
import '../controller/questionpagecontroller.dart';
import '../widgets/savedimage.dart';
import 'questionwidgets.dart';

class MyRichText extends StatelessWidget with QuestionWidget {
  String? text;
  final RegExp regExp = RegExp("<u>|<\/u>|<ov>[^\>]+<\/ov>|<i>|<\/i>|<b>|<\/b>|<sup>[^\>]+<\/sup>|<sub>[^\>]+<\/sub>|<vurgu[^\>]+>|</vurgu>");
  final RegExp regExp2 = RegExp("<u>|<\/u>|<ov>[^\>]+<\/ov>|<i>|<\/i>|<b>|<\/b>|<sup>[^\>]+<\/sup>|<sub>[^\>]+<\/sub>|<vurgu[^\>]+>|</vurgu>|<img [^\>]+>|#w [^#]+w#|#p[^#]+p#");

  bool underline = false;
  // bool overline = false;
  bool bold = false;
  bool italic = false;

  List<Shadow>? vurguShadows;
  Color? color; // değişen text color
  Color? textColor; // başlangıç text color
  Color? bookColor;
  double? fontSize;
  QuestionPageController get questionPageController => AppVar.questionPageController;
  bool questionText; //or optionText

  MyRichText({
    this.text,
    this.questionText = true,
    this.fontSize,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    fontSize ??= questionPageController.fontSize;

    color = questionText ? questionPageController.theme!.questionTextColor : questionPageController.theme!.optionTextColor;
    textColor = questionText ? questionPageController.theme!.questionTextColor : questionPageController.theme!.optionTextColor;
    bookColor = questionPageController.theme!.primaryColor;

    text = text!.replaceAll(RegExp("&lt;"), "<").replaceAll(RegExp("&gt;"), ">").replaceAll(RegExp("&amp;"), "&");
    return myRichText(text: text!, context: context);
  }

  Widget myRichText({required String text, context}) {
    Widget current;
    if (text.contains("<table") == true) {
      current = tableWidget(text);
    } else if (text.contains(RegExp("#w|#p|<img|<sup|<sub|<ov"))) {
      current = inlineWidget(text);
    } else {
      current = RichText(text: TextSpan(children: onlyText(text) as List<InlineSpan>?));
    }
    return current;
  }

  TextStyle style() {
    TextDecoration decoration = TextDecoration.none;
    if (underline) {
      decoration = TextDecoration.underline;
    }
    //  if(overline){decoration = TextDecoration.overline;}

    return TextStyle(
      decoration: decoration,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color,
      fontSize: fontSize,
      shadows: vurguShadows,
      fontFamily: kIsWeb || Platform.isIOS ? "SFUI" : null,
    );
  }

  List<TextSpan?> onlyText(String text) {
    text = text.replaceAll("<br>", "\n");

    List<TextSpan?> listText = [];
    int endIndex = 0;

    var allMatch = regExp.allMatches(text);
    allMatch.forEach((match) {
      final TextSpan textSpan = TextSpan(text: text.substring(endIndex, match.start), style: style());
      listText.add(textSpan);

      stiliAyarla(match.group(0), listText);
      endIndex = match.end;
    });
    // Yazının son kısmını yazar.
    final TextSpan textSpan = TextSpan(text: text.substring(endIndex), style: style());
    listText.add(textSpan);
    return listText;
  }

  Widget inlineWidget(String text) {
    text = text.replaceAll("<br>", "\n");
    List<InlineSpan> spanWidgetList = [];

    int endIndex = 0;
    var allMatch = regExp2.allMatches(text);

    for (int i = 0; i < allMatch.length; i++) {
      final String spanText = text.substring(endIndex, allMatch.elementAt(i).start);
      spanWidgetList.add(TextSpan(
        text: spanText,
        style: style(),
      ));
      stiliAyarla(allMatch.elementAt(i).group(0), spanWidgetList);
      endIndex = allMatch.elementAt(i).end;
    }
    // Yazının son kısmını yazar.
    final String spanText = text.substring(endIndex);
    spanWidgetList.add(TextSpan(
      text: spanText,
      style: style(),
    ));

    return RichText(
      text: TextSpan(children: spanWidgetList),
    );
  }

  Widget tableWidget(String text) {
    Color? backGorundColor = questionText ? questionPageController.theme!.questionTextColor : questionPageController.theme!.optionTextColor;

    List<TableRow> rows = [];

    final RegExp regExp = RegExp("<table.+\/table>");
    String match = regExp.allMatches(text).first.group(0)!;
    Map<int, TableColumnWidth>? yerlesimKodu;
    int i = 0;
    RegExp("-[0-9]+-").allMatches(text).forEach((match) {
      List<String> yerlesim = match.group(0)!.replaceAll("-", "").split("");
      int toplamKod = 0;
      yerlesim.forEach((kod) {
        toplamKod += int.parse(kod);
      });

      yerlesim.forEach((kod) {
        if (i == 0) {
          yerlesimKodu = {};
        }
        yerlesimKodu![i] = FractionColumnWidth(double.parse(kod) / toplamKod);
        i++;
      });
    });

    String tablo = RegExp("<tr.+<\/tr>").allMatches(match).first.group(0)!;

    List<String> satirlar = tablo.split("</tr>");
    satirlar.removeLast();

    satirlar.forEach((satir) {
      satir = satir.replaceAll("<tr>", "");

      List<String> sutunlar = satir.split("</td>");
      sutunlar.removeLast();

      List<Widget> columns = [];

      sutunlar.forEach((sutun) {
        sutun = sutun.replaceAll("<td>", "");

        while (sutun.startsWith("<br>")) {
          sutun = sutun.substring(4);
        }
        while (sutun.endsWith("<br>")) {
          sutun = sutun.substring(0, sutun.length - 4);
        }

        columns.add(TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                alignment: Alignment.center,
                color: sutun == "**" ? Colors.white : null,
                child: sutun == "**"
                    ? const Text("")
                    : myRichText(
                        text: sutun,
                      ))));
      });
      Color rowColor;
      if (rows.isEmpty) {
        rowColor = backGorundColor!.withAlpha(60);
      } else if (rows.length.isEven) {
        rowColor = backGorundColor!.withAlpha(30);
      } else {
        rowColor = backGorundColor!.withAlpha(15);
      }

      TableRow row = TableRow(
          children: columns,
          decoration: BoxDecoration(
            color: rowColor,
          ));
      rows.add(row);
    });

    return Table(
      defaultColumnWidth: FractionColumnWidth(1 / (rows.first.children!.length)),
      border: TableBorder.all(color: questionPageController.theme!.questionTextColor!),
      columnWidths: yerlesimKodu,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  void stiliAyarla(String? match, List<InlineSpan?> list) {
    if (match == "<u>") {
      underline = true; //overline = false;
    } else if (match == "</u>") {
      underline = false;
    } else if (match == "<i>") {
      italic = true;
    } else if (match == "</i>") {
      italic = false;
    } else if (match == "<b>") {
      bold = true;
    } else if (match == "</b>") {
      bold = false;
    } else if (match!.contains("#w")) {
      final data = json.decode(match.replaceAll("#w", "").replaceAll("w#", "").trim());
      list.add(questionWidget(data: QuestionRow(type: data['type'], widgetData: data['data']), textColor: color, widgetSpan: true));
    } else if (match.contains("#p")) {
      final String data = match.replaceAll("#p", "").replaceAll("p#", "").trim();
      final List textData = getAlignmentFoMath(data);
      list.add(WidgetSpan(
        baseline: TextBaseline.alphabetic,
        alignment: textData[1],
        child: MathWidget(
          color: color,
          data: textData[0],
          textStyle: style(),
          fontSize: fontSize,
          bold: bold,
        ),
      ));
    } else if (match.contains("<sup>")) {
      list.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(bottom: fontSize! * 0.4),
            child: MyRichText(
              text: match.replaceAll("<sup>", "").replaceAll("<\/sup>", ""),
              fontSize: fontSize! * 0.67,
              questionText: questionText,
            ),
          )));
//      list.add(WidgetSpan(
//          alignment: PlaceholderAlignment.bottom,
//          child: Padding(
//            padding: EdgeInsets.only(bottom: fontSize * 0.4),
//            child: MyRichText(
//              text: match.replaceAll("<sup>", "").replaceAll("<\/sup>", ""),
//              fontSize: fontSize * 0.67,
//              questionText: questionText,
//            ),
//          )));
    } else if (match.contains("<sub>")) {
      list.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(top: fontSize! * 0.4),
            child: MyRichText(
              text: match.replaceAll("<sub>", "").replaceAll("<\/sub>", ""),
              fontSize: fontSize! * 0.65,
              questionText: questionText,
            ),
          )));
//      list.add(WidgetSpan(
//          alignment: PlaceholderAlignment.top,
//          child: Padding(
//            padding: EdgeInsets.only(top: fontSize * 0.3),
//            child: MyRichText(
//              text: match.replaceAll("<sub>", "").replaceAll("<\/sub>", ""),
//              fontSize: fontSize * 0.65,
//              questionText: questionText,
//            ),
//          )));
    } else if (match.contains("<ov>")) {
      list.add(WidgetSpan(
          alignment: PlaceholderAlignment.bottom,
          //  baseline: TextBaseline.alphabetic,
          child: IntrinsicWidth(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 2.0),
                  color: textColor,
                  height: 2,
                ),
                MyRichText(
                  text: match.replaceAll("<ov>", "").replaceAll("<\/ov>", ""),
                  questionText: questionText,
                )
              ],
            ),
          )));
    } else if (match.contains("<vurgu")) {
      vurguShadows = [Shadow(color: textColor!.withAlpha(100), blurRadius: 1.0, offset: const Offset(-1.5, 1.5))];
    } else if (match.contains("vurgu>")) {
      vurguShadows = null;
    } else if (match.contains("<img")) {
      var match2 = RegExp("data:[A-z0-9/+=,;]+").allMatches(match);
      var match3 = RegExp("height=[\"'0-9px]+\"").allMatches(match);

      list.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: QuestionImage(
            temaRengi: match.contains("temarengi") ? color : null,
            imgCode: match2.first.group(0),
            height: double.parse(match3.first.group(0)!.replaceAll("height=", "").replaceAll("px", "").replaceAll("\"", "")),
          )));
    }
  }

  List getAlignmentFoMath(String text) {
    if (text.startsWith('a')) {
      if (text.startsWith('a1 ')) {
        return [text.substring(2).trim(), PlaceholderAlignment.top];
      } else if (text.startsWith('a2 ')) {
        return [text.substring(2).trim(), PlaceholderAlignment.aboveBaseline];
      } else if (text.startsWith('a3 ')) {
        return [text.substring(2).trim(), PlaceholderAlignment.middle];
      } else if (text.startsWith('a4 ')) {
        return [text.substring(2).trim(), PlaceholderAlignment.belowBaseline];
      } else if (text.startsWith('a5 ')) {
        return [text.substring(2).trim(), PlaceholderAlignment.bottom];
      }
    }
    if (text.startsWith('\\sqrt') || text.startsWith('\\overline') || text.startsWith('\\widehat') || text.startsWith('\\overrightarrow')) {
      return [text, PlaceholderAlignment.aboveBaseline];
    }

    return [text, PlaceholderAlignment.middle];
  }
}
