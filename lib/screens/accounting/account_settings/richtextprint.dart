//? bunu muhtemelen html dosyalarini widget haline getirip yazdirabilirmiyim diye koymusum daha iyi yollar buldugunda sil
// // ignore_for_file: unnecessary_string_escapes

// import 'package:flutter/services.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:pdf/src/pdf/color.dart';
// import 'package:pdf/src/pdf/colors.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class RichTextPrint {
//   RichTextPrint(String _initialText) {
//     _sendPrint(_initialText);
//   }

//   final _regExp = RegExp("<u>|<\/u>|<ov>[^\>]+<\/ov>|<i>|<\/i>|<b>|<\/b>|<sup>[^\>]+<\/sup>|<sub>[^\>]+<\/sub>");
//   final _regExp2 = RegExp("<u>|<\/u>|<ov>[^\>]+<\/ov>|<i>|<\/i>|<b>|<\/b>|<sup>[^\>]+<\/sup>|<sub>[^\>]+<\/sub>|<img [^\>]+>");
//   final _fontSize = 12;
//   bool _underline = false;
//   bool _bold = false;
//   bool _italic = false;

//   Future<void> _sendPrint(String _initialText) async {
//     if (_initialText.startsWith('<p></p>')) {
//       _initialText = _initialText.replaceFirst('<p></p>', '');
//     }
//     if (_initialText.startsWith('<p><br></p>')) {
//       _initialText = _initialText.replaceFirst('<p><br></p>', '');
//     }
//     _initialText = _initialText.replaceAll(RegExp("&lt;"), "<").replaceAll(RegExp("&gt;"), ">").replaceAll(RegExp("&amp;"), "&").replaceAll(RegExp("&nbsp;"), " ");

//     final _tableRegExp = RegExp("<table.+\/table>");

//     var _allTableMatch = _tableRegExp.allMatches(_initialText);

//     while (_initialText.contains(_tableRegExp)) {
//       _initialText = _initialText.replaceFirst(_tableRegExp, 'tableplaceholder');
//     }

//     List<pw.Widget> _tableWidgets = [];
//     _allTableMatch.forEach((element) {
//       _tableWidgets.add(_tableWidget(element.group(0)));
//     });

//     _initialText = _initialText.replaceAll('</p>', '<br><br>').replaceAll('</div>', '<br>').replaceAll('</br>', '<br>');

//     final _splittedTextList = _initialText.split('tableplaceholder');

//     final List<pw.Widget> _result = _splittedTextList.fold<List<pw.Widget>>(<pw.Widget>[], (p, e) {
//       final _textIndex = _splittedTextList.indexOf(e);
//       if (_textIndex > 0) p.add(_tableWidgets[_textIndex - 1]);
//       final _splittedText2 = e.split('<br>');
//       p.addAll(_splittedText2.map((e) => _myRichText(text: e + '\n')).toList());
//       return p;
//     });

//     pw.Document doc = pw.Document();
//     doc.addPage(
//       pw.MultiPage(
//         // pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return _result
//             ..insert(0, pw.Text('Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ', style: _style()))
//             ..insert(1, pw.RichText(text: pw.TextSpan(children: [pw.TextSpan(text: 'Çağrı GÖKTAŞMİLLÎ EĞİTİM BAKANLIĞI  Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ', style: _style())])))
//             ..insert(2, pw.RichText(text: pw.TextSpan(children: _onlyText('Çağrı GÖKTAŞ MİLLÎ EĞİTİM BAKANLIĞI <b>Çağrı</b> GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ Çağrı GÖKTAŞ')))); // Center
//         },
//         pageTheme: pw.PageTheme(
//           orientation: pw.PageOrientation.portrait,
//           margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 48),
//           theme: pw.ThemeData.withFont(
//             base: pw.Font.ttf(await rootBundle.load('fonts/opensans.ttf')),
//             bold: pw.Font.ttf(await rootBundle.load('fonts/opensansbold.ttf')),
//             italic: pw.Font.ttf(await rootBundle.load('fonts/opensansitalic.ttf')),
//           ),
//         ),
//       ),
//     );

//     await Printing.layoutPdf(onLayout: (format) async => doc.save());
//   }

//   pw.Widget _myRichText({String text}) {
//     int _align = 0;
//     if (text.contains('text-align: center')) {
//       _align = 1;
//     } else if (text.contains('text-align: left')) {
//       _align = 0;
//     } else if (text.contains('text-align: right')) {
//       _align = 2;
//     }

//     text = text.replaceAll('<div style="text-align: center;">', '');
//     text = text.replaceAll('<div style="text-align: left;">', '');
//     text = text.replaceAll('<div style="text-align: right;">', '');
//     text = text.replaceAll('<p style="text-align: center;">', '\n');
//     text = text.replaceAll('<p style="text-align: left;">', '\n');
//     text = text.replaceAll('<p style="text-align: right;">', '\n');
//     text = text.replaceAll('<div style="text-align: center; ">', '');
//     text = text.replaceAll('<div style="text-align: left;" >', '');
//     text = text.replaceAll('<div style="text-align: right; ">', '');
//     text = text.replaceAll('<p style="text-align: center; ">', '\n');
//     text = text.replaceAll('<p style="text-align: left; ">', '\n');
//     text = text.replaceAll('<p style="text-align: right; ">', '\n');
//     text = text.replaceAll('<p>', '');
//     text = text.replaceAll('<div>', '');

//     pw.Widget current;
//     if (text.contains(RegExp("<img|<sup|<sub|<ov"))) {
//       current = _inlineWidget(text);
//     } else {
//       current = pw.RichText(text: pw.TextSpan(children: _onlyText(text)));
//     }
//     if (_align == 1) {
//       current = pw.Center(child: current);
//     } else if (_align == 2) {
//       current = pw.Align(alignment: pw.Alignment.topRight, child: current);
//     }
//     return current;
//   }

//   List<pw.TextSpan> _onlyText(String text) {
//     text = text.replaceAll("<br>", "\n");

//     List<pw.TextSpan> listText = [];
//     int endIndex = 0;

//     var allMatch = _regExp.allMatches(text);
//     allMatch.forEach((match) {
//       final pw.TextSpan textSpan = pw.TextSpan(text: text.substring(endIndex, match.start), style: _style());
//       listText.add(textSpan);

//       _stiliAyarla(match.group(0), listText);
//       endIndex = match.end;
//     });
//     // Yazının son kısmını yazar.
//     final pw.TextSpan textSpan = pw.TextSpan(text: text.substring(endIndex), style: _style());
//     listText.add(textSpan);
//     return listText;
//   }

//   pw.TextStyle _style() {
//     pw.TextDecoration decoration = pw.TextDecoration.none;
//     if (_underline) {
//       decoration = pw.TextDecoration.underline;
//     }
//     //  if(overline){decoration = TextDecoration.overline;}

//     return pw.TextStyle(
//       decoration: decoration,
//       fontWeight: _bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//       fontStyle: _italic ? pw.FontStyle.italic : pw.FontStyle.normal,
//       color: PdfColors.black,
//       // fontSize: fontSize,
//       // fontFamily: kIsWeb || Platform.isIOS ? "SFUI" : null,
//     );
//   }

//   void _stiliAyarla(String match, List<pw.InlineSpan> list) {
//     if (match == "<u>") {
//       _underline = true; //overline = false;
//     } else if (match == "</u>") {
//       _underline = false;
//     } else if (match == "<i>") {
//       _italic = true;
//     } else if (match == "</i>") {
//       _italic = false;
//     } else if (match == "<b>") {
//       _bold = true;
//     } else if (match == "</b>") {
//       _bold = false;
//     } else if (match.contains("<sup>")) {
//       list.add(pw.WidgetSpan(

//           //  alignment: PlaceholderAlignment.middle,
//           child: pw.Padding(
//         padding: pw.EdgeInsets.only(bottom: _fontSize * 0.4),
//         child: _myRichText(
//           text: match.replaceAll("<sup>", "").replaceAll("<\/sup>", ""),
//           // fontSize: fontSize * 0.67,
//           // questionText: questionText,
//         ),
//       )));
//     } else if (match.contains("<sub>")) {
//       list.add(pw.WidgetSpan(
//           //   alignment: PlaceholderAlignment.middle,
//           child: pw.Padding(
//         padding: pw.EdgeInsets.only(top: _fontSize * 0.4),
//         child: _myRichText(
//           text: match.replaceAll("<sub>", "").replaceAll("<\/sub>", ""),
//           //fontSize: fontSize * 0.65,
//         ),
//       )));
//     }

//     // else if (match.contains("<img")) {
//     //   var match2 = RegExp("data:[A-z0-9/+=,;]+").allMatches(match);
//     //   var match3 = RegExp("height=[\"'0-9px]+\"").allMatches(match);

//     //   list.add(pw.WidgetSpan(
//     //       //  alignment: PlaceholderAlignment.middle,
//     //       child: pw.Image(
//     //     pw.MemoryImage(Downl),
//     //     temaRengi: match.contains("temarengi") ? color : null,
//     //     imgCode: match2.first.group(0),
//     //     height: double.parse(match3.first.group(0).replaceAll("height=", "").replaceAll("px", "").replaceAll("\"", "")),
//     //   )));
//     // }
//   }

//   pw.Widget _inlineWidget(String text) {
//     text = text.replaceAll("<br>", "\n");
//     List<pw.InlineSpan> spanWidgetList = [];

//     int endIndex = 0;
//     var allMatch = _regExp2.allMatches(text);

//     for (int i = 0; i < allMatch.length; i++) {
//       final String spanText = text.substring(endIndex, allMatch.elementAt(i).start);
//       spanWidgetList.add(pw.TextSpan(
//         text: spanText,
//         style: _style(),
//       ));
//       _stiliAyarla(allMatch.elementAt(i).group(0), spanWidgetList);
//       endIndex = allMatch.elementAt(i).end;
//     }
//     // Yazının son kısmını yazar.
//     final String spanText = text.substring(endIndex);
//     spanWidgetList.add(pw.TextSpan(
//       text: spanText,
//       style: _style(),
//     ));

//     return pw.RichText(
//       text: pw.TextSpan(children: spanWidgetList),
//     );
//   }

//   pw.Widget _tableWidget(String text) {
//     final List<pw.TableRow> rows = [];

//     final RegExp regExp = RegExp("<table.+\/table>");

//     String match = regExp.allMatches(text).first.group(0);
//     Map<int, pw.TableColumnWidth> yerlesimKodu = {};

//     String tablo = RegExp("<tr.+<\/tr>").allMatches(match).first.group(0);

//     List<String> satirlar = tablo.split("</tr>");
//     satirlar.removeLast();
//     for (var _s = 0; _s < satirlar.length; _s++) {
//       var satir = satirlar[_s];
//       satir = satir.replaceAll("<tr>", "");

//       List<String> sutunlar = satir.split("</td>");
//       sutunlar.removeLast();

//       List<pw.Widget> columns = [];

//       for (var _st = 0; _st < sutunlar.length; _st++) {
//         var sutun = sutunlar[_st];
//         sutun = sutun.replaceAll("<td>", "");
//         if (_s == 0) {
//           log(sutun);
//           yerlesimKodu[_st] = pw.FlexColumnWidth(sutun.replaceAll("<br>", "").safeLength < 1
//               ? 1
//               : sutun.replaceAll("<br>", "").safeLength < 5
//                   ? 2
//                   : 14);
//         }

//         sutun = sutun.replaceAll('</p>', '<br><br>').replaceAll('</div>', '<br>').replaceAll('</br>', '<br>');

//         final _splittedText2 = sutun.split('<br>');

//         columns.add(pw.Container(
//           padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
//           alignment: pw.Alignment.center,
//           // color: PdfColors.red,
//           child: pw.Column(children: [..._splittedText2.map((e) => _myRichText(text: e + '\n')).toList()]),
//         ));
//       }

//       pw.TableRow row = pw.TableRow(
//           children: columns,
//           decoration: pw.BoxDecoration(
//             color: PdfColor.fromInt(0x00ffebee).flatten(),
//           ));
//       rows.add(row);
//     }

//     log(yerlesimKodu);
//     return pw.Table(
//       defaultColumnWidth: pw.FractionColumnWidth(1 / (rows.first.children.length)),
//       border: pw.TableBorder.all(color: PdfColor.fromInt(0x00ffebee).flatten()),
//       columnWidths: yerlesimKodu,
//       defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
//       children: rows,
//     );
//   }
// }
