// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/src/pdf/color.dart';
import 'package:pdf/src/pdf/colors.dart';
import 'package:pdf/widgets.dart' as pw;

class CellWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final String? text;
  final IconData? icon;
  final bool? iconDataActive;
  final Color? background;
  final Function()? onTap;
  final double fontSize;
  final double padding;
  final double margin;
  CellWidget({this.width, this.height, this.text, this.background, this.icon, this.iconDataActive, this.onTap, this.fontSize = 14, this.padding = 8, this.margin = 2});

  @override
  Widget build(BuildContext context) {
    Widget current;

    if (text != null && icon == null) {
      current = text.text.fontSize(fontSize).bold.center.make();
    } else if (text == null && icon != null) {
      current = Icon(icon, color: iconDataActive! ? Fav.design.primary : Fav.design.primaryText, size: 18);
    } else {
      current = Row(
        children: [
          Icon(icon, color: iconDataActive! ? Fav.design.primary : Fav.design.primaryText, size: 18),
          8.widthBox,
          Flexible(child: text.text.fontSize(fontSize).bold.make()),
        ],
      );
    }

    current = Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.only(left: margin, right: margin, bottom: margin),
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: background),
      child: current,
    );

    if (onTap != null) {
      current = GestureDetector(onTap: onTap, child: current);
    }

    return width == null ? Expanded(child: current) : SizedBox(width: width, child: current);
  }
}

class PdfCellWidget {
  PdfCellWidget._();
  static pw.Widget make({double? width, int? flex, double? height, required String text, required PdfColor background, double fontSize = 6, double padding = 2, double margin = 0.5}) {
    pw.Widget current;

    current = pw.Text(text, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, color: PdfColors.black));

    current = pw.Container(
      padding: pw.EdgeInsets.all(padding),
      margin: pw.EdgeInsets.only(left: margin, right: margin, bottom: margin),
      height: height,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(4), color: background.flatten()),
      child: current,
    );

    return flex != null
        ? pw.Expanded(flex: flex, child: current)
        : width != null
            ? pw.SizedBox(width: width, child: current)
            : pw.Center(child: current);
  }

  static pw.Widget borderedContainer({
    double? width,
    int? flex,
    double? height,
    required String text,
    required PdfColor background,
    double fontSize = 6,
    String directions = 'ltrb',
  }) {
    pw.Widget current;

    current = pw.Text(text, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, color: PdfColors.black));

    current = pw.Container(
      height: height,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
          color: background.flatten(),
          border: pw.Border(
            top: directions.toLowerCase().contains('t') ? pw.BorderSide(width: directions.contains('t') ? 0.3 : 0.6) : pw.BorderSide.none,
            left: directions.toLowerCase().contains('l') ? pw.BorderSide(width: directions.contains('l') ? 0.3 : 0.6) : pw.BorderSide.none,
            right: directions.toLowerCase().contains('r') ? pw.BorderSide(width: directions.contains('r') ? 0.3 : 0.6) : pw.BorderSide.none,
            bottom: directions.toLowerCase().contains('b') ? pw.BorderSide(width: directions.contains('b') ? 0.3 : 0.6) : pw.BorderSide.none,
          )),
      child: current,
    );

    return flex != null
        ? pw.Expanded(flex: flex, child: current)
        : width != null
            ? pw.SizedBox(width: width, child: current)
            : pw.Center(child: current);
  }
}

class MiniCellWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final String? text;

  final Color? background;

  MiniCellWidget({this.width, this.height, this.text, this.background});

  @override
  Widget build(BuildContext context) {
    Widget current = text.text.fontSize(10).maxLines(1).make();

    current = Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1, top: 1),
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: background),
      child: current,
    );

    return width == null ? Expanded(child: current) : SizedBox(width: width, child: current);
  }
}
