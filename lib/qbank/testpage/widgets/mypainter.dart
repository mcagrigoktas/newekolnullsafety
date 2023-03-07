import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;

class Painter extends StatefulWidget {
  final PainterController painterController;

  Painter(this.painterController) : super(key: ValueKey<PainterController>(painterController));

  @override
  _PainterState createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  late bool _finished;

  @override
  void initState() {
    super.initState();
    _finished = false;
    widget.painterController._widgetFinish = _finish;
  }

  Size? _finish() {
    setState(() {
      _finished = true;
    });
    return context.size;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      willChange: true,
      painter: _PainterPainter(widget.painterController._pathHistory, repaint: widget.painterController),
    );
    child = ClipRect(child: child);
    if (!_finished) {
      child = GestureDetector(
        child: child,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
      );
    }
    return SizedBox(
      child: child,
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _onPanStart(DragStartDetails start) {
    Offset pos = (context.findRenderObject() as RenderBox).globalToLocal(start.globalPosition);
    widget.painterController._pathHistory!.add(pos);
    widget.painterController._notifyListeners();
  }

  void _onPanUpdate(DragUpdateDetails update) {
    Offset pos = (context.findRenderObject() as RenderBox).globalToLocal(update.globalPosition);
    widget.painterController._pathHistory!.updateCurrent(pos);
    widget.painterController._notifyListeners();
  }

  void _onPanEnd(DragEndDetails end) {
    widget.painterController._pathHistory!.endCurrent();
    widget.painterController._notifyListeners();
  }
}

class _PainterPainter extends CustomPainter {
  final _Path? _path;

  _PainterPainter(this._path, {Listenable? repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _path!.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_PainterPainter oldDelegate) {
    return true;
  }
}

class _Path {
  late Path _path;
  late Paint currentPaint;
  late Paint _backgroundPaint;
  late bool _inDrag;

  _Path() {
    _path = Path();
    _inDrag = false;
    _backgroundPaint = Paint();
  }

  void setBackgroundColor(Color backgroundColor) {
    _backgroundPaint.color = backgroundColor;
  }

  void clear() {
    _path = Path();
  }

  void add(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      _path.moveTo(startPoint.dx, startPoint.dy);
    }
  }

  void updateCurrent(Offset nextPoint) {
    if (_inDrag) {
      _path.lineTo(nextPoint.dx, nextPoint.dy);
    }
  }

  void endCurrent() {
    _inDrag = false;
  }

  void draw(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);

    canvas.drawPath(_path, currentPaint);
  }
}

typedef PictureDetails PictureCallback();

class PictureDetails {
  final Picture picture;
  final int width;
  final int height;

  const PictureDetails(this.picture, this.width, this.height);

  Future<Image> toImage() {
    return picture.toImage(width, height);
  }

  Future<Uint8List> toPNG() async {
    return (await (await toImage()).toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}

class PainterController extends ChangeNotifier {
  Color _drawColor = const Color.fromARGB(255, 0, 0, 0);
  Color _backgroundColor = const Color.fromARGB(255, 255, 255, 255);

  double _thickness = 1.0;
  PictureDetails? _cached;
  _Path? _pathHistory;
  late ValueGetter<Size?> _widgetFinish;

  PainterController() {
    _pathHistory = _Path();
  }

  Color get drawColor => _drawColor;
  set drawColor(Color color) {
    _drawColor = color;
    _updatePaint();
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color) {
    _backgroundColor = color;
    _updatePaint();
  }

  double get thickness => _thickness;
  set thickness(double t) {
    _thickness = t;
    _updatePaint();
  }

  void _updatePaint() {
    Paint paint = Paint();
    paint.color = drawColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = thickness;
    _pathHistory!.currentPaint = paint;
    _pathHistory!.setBackgroundColor(backgroundColor);
    notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void clear() {
    if (!isFinished()) {
      _pathHistory!.clear();
      notifyListeners();
    }
  }

  PictureDetails? finish() {
    if (!isFinished()) {
      _cached = _render(_widgetFinish()!);
    }
    return _cached;
  }

  PictureDetails _render(Size size) {
    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);
    _pathHistory!.draw(canvas, size);
    return PictureDetails(recorder.endRecording(), size.width.floor(), size.height.floor());
  }

  bool isFinished() {
    return _cached != null;
  }
}
