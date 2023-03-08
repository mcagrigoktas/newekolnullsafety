import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class PM<T> {
  Widget m();
  pw.Widget? p();

  T call(int type) => type == 1 ? p() as T : m() as T;
}

//* Base Widgets

class PCenter<T> extends PM<T> {
  final T child;

  PCenter({required this.child});
  @override
  Widget m() => Center(child: child as Widget);

  //? Center yapinca ve alignde print ederken dikeylemesine tum ekrani kaplayip ortaladigindan bu cozume gidilde
  @override
  pw.Widget p() => PRow<pw.Widget>(mainAxisAlignment: MainAxisAlignment.center, children: [
        PExpanded<pw.Widget>(child: child as pw.Widget)(1),
      ])(1);
}

class PSizedBox<T> extends PM<T> {
  final double? width;
  final double? height;
  final T? child;

  PSizedBox({this.width, this.height, this.child});
  @override
  Widget m() => SizedBox(width: width, height: height, child: child as Widget?);
  @override
  pw.Widget p() => pw.SizedBox(width: width, height: height, child: child as pw.Widget?);
}

class PSpacer<T> extends PM<T> {
  PSpacer();
  @override
  Widget m() => Spacer();
  @override
  pw.Widget p() => pw.Spacer();
}

class PExpanded<T> extends PM<T> {
  final T child;
  final int flex;
  PExpanded({required this.child, this.flex = 1});
  @override
  Widget m() => Expanded(
        child: child as Widget,
        flex: flex,
      );
  @override
  pw.Widget p() => pw.Expanded(
        child: child as pw.Widget,
        flex: flex,
      );
}

// class PBuilder<T> extends PM<T> {
//   final Function() builder;
//   PBuilder({this.builder});
//   @override
//   Widget m() => Builder(
//         builder: (_) {
//           return builder() as Widget;
//         },
//       );
//   @override
//   pw.Widget p() => pw.Builder(builder: (_) {
//         return builder() as pw.Widget;
//       });
// }

class PText<T> extends PM<T> {
  final String text;
  final TextStyle? style;
  final PdfColor pdfTextColor;
  final int? maxLines;
  final TextAlign? textAlign;
  PText(this.text, {this.style, this.pdfTextColor = PdfColors.black, this.maxLines, this.textAlign});

  @override
  Widget m() => Text(text, textAlign: textAlign, style: style);

  @override
  pw.Widget p() {
    return pw.Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign == null ? null : _PHelper.changeTextAlign(textAlign),
      style: pw.TextStyle(
        fontSize: style?.fontSize,
        fontWeight: style?.fontWeight == FontWeight.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: pdfTextColor,
      ),
    );
  }
}

class PContainer<T> extends PM<T> {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Alignment? alignment;
  final double? width;
  final double? height;
  final Color? color;
  final PdfColor? pdfBackgroundColor;
  final double borderRadius;
  final T? child;

  PContainer({this.margin = EdgeInsets.zero, this.padding = EdgeInsets.zero, this.alignment, this.width, this.height, this.color, this.pdfBackgroundColor, this.borderRadius = 0, this.child});

  @override
  Widget m() => Container(
        margin: margin,
        padding: padding,
        alignment: alignment,
        width: width,
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(borderRadius)),
        child: child as Widget,
      );

  @override
  pw.Widget p() => pw.Container(
        margin: pw.EdgeInsets.only(bottom: margin.bottom, left: margin.left, right: margin.right, top: margin.top),
        padding: pw.EdgeInsets.only(bottom: padding.bottom, left: padding.left, right: padding.right, top: padding.top),
        alignment: alignment == null ? null : pw.Alignment(alignment!.x, alignment!.y),
        width: width,
        height: height,
        decoration: pw.BoxDecoration(color: pdfBackgroundColor, borderRadius: pw.BorderRadius.circular(borderRadius)),
        child: child as pw.Widget,
      );
}

class PColumn<T> extends PM<T> {
  final List<T> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  PColumn({required this.children, this.mainAxisAlignment = MainAxisAlignment.start, this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget m() => Column(children: children as List<Widget>, mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: crossAxisAlignment);

  @override
  pw.Widget p() => pw.Column(children: children as List<pw.Widget>, mainAxisAlignment: _PHelper.changeMainAxisAlignment(mainAxisAlignment), crossAxisAlignment: _PHelper.changeCrossAxisAlignment(crossAxisAlignment));
}

class PRow<T> extends PM<T> {
  final List<T> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  PRow({required this.children, this.mainAxisAlignment = MainAxisAlignment.start, this.crossAxisAlignment = CrossAxisAlignment.center, this.mainAxisSize = MainAxisSize.max});

  @override
  Widget m() => Row(children: children as List<Widget>, mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: crossAxisAlignment, mainAxisSize: mainAxisSize);

  @override
  pw.Widget p() => pw.Row(children: children as List<pw.Widget>, mainAxisAlignment: _PHelper.changeMainAxisAlignment(mainAxisAlignment), crossAxisAlignment: _PHelper.changeCrossAxisAlignment(crossAxisAlignment), mainAxisSize: _PHelper.changeMainAxisSize(mainAxisSize));
}

class PWrap<T> extends PM<T> {
  final List<T> children;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;

  final double spacing;
  final double runSpacing;
  final Axis direction;

  PWrap({required this.children, this.direction = Axis.horizontal, this.alignment = WrapAlignment.start, this.crossAxisAlignment = WrapCrossAlignment.start, this.runAlignment = WrapAlignment.start, this.spacing = 0, this.runSpacing = 0});

  @override
  Widget m() => Wrap(
        direction: Axis.horizontal,
        children: children as List<Widget>,
        alignment: alignment,
        runAlignment: runAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        runSpacing: runSpacing,
      );

  @override
  pw.Widget p() => pw.Wrap(
        direction: _PHelper.changeAxis(direction),
        children: children as List<pw.Widget>,
        alignment: _PHelper.changeWrapAlignment(alignment),
        runAlignment: _PHelper.changeWrapAlignment(runAlignment),
        crossAxisAlignment: _PHelper.changeWrapCrossAlignment(crossAxisAlignment),
        spacing: spacing,
        runSpacing: runSpacing,
      );
}

//* Extension
extension pWidgetExtension on PM {
  T stadium<T>({int type = 0, Color? background, EdgeInsets? padding}) {
    return PContainer(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      color: background ?? Colors.purpleAccent,
      pdfBackgroundColor: background == null ? PdfColors.purple : PdfColor(background.red / 255, background.green / 255, background.blue / 255, background.alpha / 255).flatten(),
      borderRadius: 24,
      child: this(type),
    )(type) as T;
  }
}

extension pColorExtension on Color {
  PdfColor get toPdfColor => PdfColor(red / 255, green / 255, blue / 255, opacity);
}

//* Helpers
class _PHelper {
  _PHelper._();

  static pw.MainAxisAlignment changeMainAxisAlignment(MainAxisAlignment alignment) {
    if (alignment == MainAxisAlignment.center) return pw.MainAxisAlignment.center;
    if (alignment == MainAxisAlignment.start) return pw.MainAxisAlignment.start;
    if (alignment == MainAxisAlignment.end) return pw.MainAxisAlignment.end;
    if (alignment == MainAxisAlignment.spaceEvenly) return pw.MainAxisAlignment.spaceEvenly;
    if (alignment == MainAxisAlignment.spaceAround) return pw.MainAxisAlignment.spaceAround;
    if (alignment == MainAxisAlignment.spaceBetween) return pw.MainAxisAlignment.spaceBetween;
    return pw.MainAxisAlignment.start;
  }

  static pw.CrossAxisAlignment changeCrossAxisAlignment(CrossAxisAlignment alignment) {
    if (alignment == CrossAxisAlignment.center) return pw.CrossAxisAlignment.center;
    if (alignment == CrossAxisAlignment.start) return pw.CrossAxisAlignment.start;
    if (alignment == CrossAxisAlignment.end) return pw.CrossAxisAlignment.end;
    return pw.CrossAxisAlignment.center;
  }

  static pw.TextAlign changeTextAlign(TextAlign? textAlign) {
    if (textAlign == TextAlign.center) return pw.TextAlign.center;
    if (textAlign == TextAlign.start) return pw.TextAlign.left;
    if (textAlign == TextAlign.end) return pw.TextAlign.right;

    return pw.TextAlign.center;
  }

  static pw.MainAxisSize changeMainAxisSize(MainAxisSize mainAxisSize) {
    if (mainAxisSize == MainAxisSize.max) return pw.MainAxisSize.max;
    return pw.MainAxisSize.min;
  }

  static pw.WrapAlignment changeWrapAlignment(WrapAlignment wrapAlignment) {
    if (wrapAlignment == WrapAlignment.start) return pw.WrapAlignment.start;
    if (wrapAlignment == WrapAlignment.center) return pw.WrapAlignment.center;
    if (wrapAlignment == WrapAlignment.end) return pw.WrapAlignment.end;
    if (wrapAlignment == WrapAlignment.spaceAround) return pw.WrapAlignment.spaceAround;
    if (wrapAlignment == WrapAlignment.spaceBetween) return pw.WrapAlignment.spaceBetween;
    if (wrapAlignment == WrapAlignment.spaceEvenly) return pw.WrapAlignment.spaceEvenly;

    return pw.WrapAlignment.start;
  }

  static pw.WrapCrossAlignment changeWrapCrossAlignment(WrapCrossAlignment wrapCrossAlignment) {
    if (wrapCrossAlignment == WrapCrossAlignment.start) return pw.WrapCrossAlignment.start;
    if (wrapCrossAlignment == WrapCrossAlignment.center) return pw.WrapCrossAlignment.center;
    if (wrapCrossAlignment == WrapCrossAlignment.end) return pw.WrapCrossAlignment.end;

    return pw.WrapCrossAlignment.start;
  }

  static pw.Axis changeAxis(Axis axis) {
    if (axis == Axis.horizontal) return pw.Axis.horizontal;

    return pw.Axis.vertical;
  }
}
