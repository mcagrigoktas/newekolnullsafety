import 'package:flutter/material.dart';

class CodeTestScreen extends StatefulWidget {
  CodeTestScreen();
  @override
  _CodeTestScreenState createState() => _CodeTestScreenState();
}

class _CodeTestScreenState extends State<CodeTestScreen> {
  // final url = 'https://eu2.contabostorage.com/b16e777923364f3cb0dda8a3f3980619:ekol/aa_SF/2022-12/Img/111101/scaled_9M5.jpg';
  // final url2 = 'https://eu2.contabostorage.com/b16e777923364f3cb0dda8a3f3980619:ekol/aa_SF/2022-12/Vid/demoekid/DWKznGnSk.mp4';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          size: Size(300, 200),
          painter: LogoPainter(),
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 1;

    canvas.drawLine(Offset(50, 50), Offset(100, 50), paint);
    // canvas.drawArc();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
