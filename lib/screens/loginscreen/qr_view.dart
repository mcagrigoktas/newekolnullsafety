import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

class QrView extends StatelessWidget {
  final String data;
  final Color color;
  final double size;
  QrView({required this.data, this.color = Colors.white, this.size = 200});

  String buildBarcode() {
    return Barcode.qrCode().toSvg(
      data,
      width: size,
      height: size,
      color: color.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return svg.SvgPicture.string(buildBarcode());
  }
}
