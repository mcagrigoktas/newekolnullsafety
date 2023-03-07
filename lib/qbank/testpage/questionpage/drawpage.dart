import 'package:flutter/material.dart';
import 'package:painter/painter.dart';

import '../../../appbloc/appvar.dart';

class PaintPage extends StatefulWidget {
  final Color? backGroundColor;
  PaintPage({this.backGroundColor});
  @override
  _PaintPageState createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage> {
  late PainterController _controller;
  int colorValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = _newController();
  }

  PainterController _newController() {
    PainterController controller = PainterController();
    controller.thickness = 3.5;
    controller.backgroundColor = Colors.transparent;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    _controller.backgroundColor = AppVar.questionPageController.theme!.backgroundColor!;
    if (colorValue == 0) {
      _controller.drawColor = AppVar.questionPageController.theme!.primaryTextColor!;
    } else if (colorValue == 1) {
      _controller.drawColor = Colors.amber;
    } else if (colorValue == 2) {
      _controller.drawColor = Colors.teal;
    }

    _controller.backgroundColor = Colors.transparent;

    List<Widget> actions = <Widget>[
      SizedBox(
          height: 20,
          width: 200,
          child: Slider(
            divisions: 14,
            activeColor: AppVar.questionPageController.theme!.primaryTextColor,
            min: 1,
            max: 7,
            value: _controller.thickness,
            onChanged: (value) {
              setState(() {
                _controller.thickness = value;
              });
            },
          )),
      FloatingActionButton(
        child: const Icon(Icons.undo, color: Colors.white),
        onPressed: _controller.undo,
        backgroundColor: AppVar.questionPageController.theme!.bookColor,
        mini: true,
      ),
      FloatingActionButton(
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        onPressed: () {
          AppVar.questionPageController.drawImg = null;
          _controller.clear();
          setState(() {});
        },
        backgroundColor: AppVar.questionPageController.theme!.bookColor,
        mini: true,
      ),
      IconButton(
        icon: Icon(
          Icons.brush,
          color: _controller.drawColor,
        ),
        onPressed: () {
          setState(() {
            colorValue = (colorValue + 1) % 3;
          });
        },
        color: Colors.transparent,
      ),
      FloatingActionButton(
        child: const Icon(
          Icons.clear,
          color: Colors.white,
        ),
        onPressed: AppVar.questionPageController.changeDrawPanelTuru,
        backgroundColor: AppVar.questionPageController.theme!.bookColor,
        mini: true,
      ),
    ];

    List<Widget> stackWidgetChildren = [];

    if (AppVar.questionPageController.drawImg != null) {
      stackWidgetChildren.add(Align(
          alignment: Alignment.center,
          child: Image.memory(
            AppVar.questionPageController.drawImg!,
            color: AppVar.questionPageController.drawImgColor,
          )));
    }

    stackWidgetChildren.add(Positioned(
      child: SizedBox(width: double.infinity, child: Painter(_controller)),
      top: 00.0,
      bottom: 0.0,
      right: 0.0,
      left: 0.0,
    ));
    stackWidgetChildren.add(Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        )));

    return Stack(
      children: stackWidgetChildren,
    );
  }
}
