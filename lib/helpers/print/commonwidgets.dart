import 'package:flutter/material.dart' as mat;
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

//? Bu kutuphane pdf ve material widget ayni anda lazim olacaksa kullanabilirsin gayet guzel calisiyor.
class MaterialAndPrintWidget {
  MaterialAndPrintWidget._();

  // ignore: non_constant_identifier_names
  static dynamic SizedBox({WidgetType widgetType = WidgetType.MATERIAL, double? width, double? height}) {
    if (widgetType == WidgetType.MATERIAL) {
      return mat.SizedBox(width: width, height: height);
    }
    return pw.SizedBox(width: width, height: height);
  }

  // ignore: non_constant_identifier_names
  static dynamic Container({
    WidgetType widgetType = WidgetType.MATERIAL,
    mat.Alignment? alignment,
    double? width,
    double? height,
    double verticalMargin = 0,
    double horizantalMargin = 0,
    double verticalPadding = 0,
    double horizantalPadding = 0,
    mat.Color? materialBackgroundColor,
    PdfColor printBackgroundColor = PdfColors.white,
    double borderRadius = 0,
    dynamic child,
  }) {
    if (widgetType == WidgetType.MATERIAL) {
      return mat.Container(
        child: child,
        margin: mat.EdgeInsets.symmetric(vertical: verticalMargin, horizontal: horizantalMargin),
        padding: mat.EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizantalPadding),
        alignment: mat.Alignment.center,
        width: width,
        height: height,
        decoration: materialBackgroundColor == null ? null : mat.BoxDecoration(color: materialBackgroundColor, borderRadius: mat.BorderRadius.circular(borderRadius), boxShadow: [mat.BoxShadow(color: materialBackgroundColor.withAlpha(180), blurRadius: 1)]),
      );
    }
    return pw.Container(
      child: child,
      margin: pw.EdgeInsets.symmetric(vertical: verticalMargin, horizontal: horizantalMargin),
      padding: pw.EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizantalPadding),
      alignment: _changeAlignment(widgetType, alignment),
      width: width,
      height: height,
      decoration: pw.BoxDecoration(color: printBackgroundColor, borderRadius: pw.BorderRadius.circular(borderRadius)),
    );
  }

  // ignore: non_constant_identifier_names
  static dynamic Text(
    String text, {
    WidgetType widgetType = WidgetType.MATERIAL,
    mat.Color materialTextColor = mat.Colors.black,
    PdfColor printTextColor = PdfColors.black,
    double fontSize = 14,
    bool bold = false,
  }) {
    if (widgetType == WidgetType.MATERIAL) {
      return text.text.color(materialTextColor).autoSize.center.fontSize(fontSize).fontWeight(bold ? mat.FontWeight.bold : mat.FontWeight.normal).make();
    }
    return pw.Text(text, style: pw.TextStyle(color: printTextColor, fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal));
  }

  // ignore: non_constant_identifier_names
  static dynamic Column({WidgetType widgetType = WidgetType.MATERIAL, List? children, mat.MainAxisAlignment mainAxisAlignment = mat.MainAxisAlignment.start, mat.CrossAxisAlignment crossAxisAlignment = mat.CrossAxisAlignment.center}) {
    if (widgetType == WidgetType.MATERIAL) {
      return mat.Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: List<mat.Widget>.from(children!),
      );
    }
    return pw.Column(
      mainAxisAlignment: _changeMainAxisAlignment(widgetType, mainAxisAlignment),
      crossAxisAlignment: _changeCrossAxisAlignment(widgetType, crossAxisAlignment),
      children: List<pw.Widget>.from(children!),
    );
  }

  // ignore: non_constant_identifier_names
  static dynamic Row({WidgetType widgetType = WidgetType.MATERIAL, List? children, mat.MainAxisAlignment mainAxisAlignment = mat.MainAxisAlignment.start, mat.CrossAxisAlignment crossAxisAlignment = mat.CrossAxisAlignment.center}) {
    if (widgetType == WidgetType.MATERIAL) {
      return mat.Row(
        mainAxisSize: mat.MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: List<mat.Widget>.from(children!),
      );
    }
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      mainAxisAlignment: _changeMainAxisAlignment(widgetType, mainAxisAlignment),
      crossAxisAlignment: _changeCrossAxisAlignment(widgetType, crossAxisAlignment),
      children: List<pw.Widget>.from(children!),
    );
  }

  // ignore: non_constant_identifier_names
  static dynamic Wrap({
    WidgetType widgetType = WidgetType.MATERIAL,
    List? children,
  }) {
    if (widgetType == WidgetType.MATERIAL) {
      return mat.Wrap(
        alignment: mat.WrapAlignment.center,
        runSpacing: 4,
        spacing: 16,
        children: List<mat.Widget>.from(children!),
      );
    }
    return pw.Wrap(
      alignment: pw.WrapAlignment.center,
      runSpacing: 4,
      spacing: 16,
      children: List<pw.Widget>.from(children!),
    );
  }

  static dynamic keyValueText({
    WidgetType widgetType = WidgetType.MATERIAL,
    String? key,
    String? value,
    double fontSize = 16,
    mat.Color materialTextColor = mat.Colors.black,
    PdfColor printTextColor = PdfColors.black,
  }) {
    if (widgetType == WidgetType.MATERIAL) {
      return mat.Row(
        mainAxisSize: mat.MainAxisSize.min,
        children: [
          mat.Text(key!, style: mat.TextStyle(color: materialTextColor, fontWeight: mat.FontWeight.bold, fontSize: fontSize)),
          mat.Text(': ', style: mat.TextStyle(color: materialTextColor, fontWeight: mat.FontWeight.bold, fontSize: fontSize)),
          mat.Flexible(child: mat.Text(value!, style: mat.TextStyle(color: materialTextColor, fontSize: fontSize))),
        ],
      );
    }

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(key!, style: pw.TextStyle(color: printTextColor, fontWeight: pw.FontWeight.bold, fontSize: fontSize)),
        pw.Text(': ', style: pw.TextStyle(color: printTextColor, fontWeight: pw.FontWeight.bold, fontSize: fontSize)),
        pw.Flexible(child: pw.Text(value!, style: pw.TextStyle(color: printTextColor, fontSize: fontSize))),
      ],
    );
  }

  static dynamic _changeAlignment(WidgetType widgetType, mat.Alignment? alignment) {
    if (alignment == null) return null;
    if (widgetType == WidgetType.MATERIAL) return alignment;
    if (alignment == mat.Alignment.center) return pw.Alignment.center;
    if (alignment == mat.Alignment.centerLeft) return pw.Alignment.centerLeft;
    if (alignment == mat.Alignment.centerRight) return pw.Alignment.centerRight;
    return pw.Alignment.center;
  }

  static dynamic _changeMainAxisAlignment(WidgetType widgetType, mat.MainAxisAlignment? alignment) {
    if (alignment == null) return null;
    if (widgetType == WidgetType.MATERIAL) return alignment;
    if (alignment == mat.MainAxisAlignment.center) return pw.MainAxisAlignment.center;
    if (alignment == mat.MainAxisAlignment.start) return pw.MainAxisAlignment.start;
    if (alignment == mat.MainAxisAlignment.end) return pw.MainAxisAlignment.end;
    if (alignment == mat.MainAxisAlignment.spaceEvenly) return pw.MainAxisAlignment.spaceEvenly;
    if (alignment == mat.MainAxisAlignment.spaceAround) return pw.MainAxisAlignment.spaceAround;
    if (alignment == mat.MainAxisAlignment.spaceBetween) return pw.MainAxisAlignment.spaceBetween;
    return pw.MainAxisAlignment.center;
  }

  static dynamic _changeCrossAxisAlignment(WidgetType widgetType, mat.CrossAxisAlignment? alignment) {
    if (alignment == null) return null;
    if (widgetType == WidgetType.MATERIAL) return alignment;
    if (alignment == mat.CrossAxisAlignment.center) return pw.CrossAxisAlignment.center;
    if (alignment == mat.CrossAxisAlignment.start) return pw.CrossAxisAlignment.start;
    if (alignment == mat.CrossAxisAlignment.end) return pw.CrossAxisAlignment.end;
    return pw.CrossAxisAlignment.center;
  }
}

enum WidgetType { MATERIAL, PRINT }
