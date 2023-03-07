import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../models/class.dart';
import '../../../../models/lesson.dart';
import 'controller.dart';

class PopUpBuild {
  PopUpBuild._();

  static Future<dynamic> build({
    Iterable<Lesson>? lessonList,
    required Class sinif,
    required BuildContext context,
    required GlobalKey gestureKey,
    required String day,
    required int lessonNo,
  }) async {
    final RenderBox _referenceBox = gestureKey.currentContext!.findRenderObject() as RenderBox;
    final _globalPosition = _referenceBox.localToGlobal(Offset.zero);

    Widget _current = PopupBox(
      lessonList: lessonList,
      sinif: sinif,
      header: '${sinif.name} / ${McgFunctions.getDayNameFromDayOfWeek(int.tryParse(day)!)} / ${'lesson'.translate}:${lessonNo + 1}',
    );
    var _yon = 0;
    if (_globalPosition.dx > context.screenWidth / 2 && _globalPosition.dy < context.screenHeight / 2) {
      _yon = 1;
    } else if (_globalPosition.dx < context.screenWidth / 2 && _globalPosition.dy > context.screenHeight / 2) {
      _yon = 2;
    } else if (_globalPosition.dx > context.screenWidth / 2 && _globalPosition.dy > context.screenHeight / 2) {
      _yon = 3;
    }
    _current = TweenAnimationBuilder(
      child: _current,
      builder: (context, dynamic animation, child) {
        return Opacity(
          opacity: animation,
          child: Transform.scale(
              alignment: _yon == 0
                  ? Alignment.topLeft
                  : _yon == 1
                      ? Alignment.topRight
                      : _yon == 2
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
              scale: animation,
              child: child),
        );
      },
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0.0, end: 1.0),
    );

    var _lessonKey = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Stack(
              children: <Widget>[
                if (_yon == 0)
                  Positioned(
                    left: _globalPosition.dx,
                    top: _globalPosition.dy,
                    child: _current,
                  ),
                if (_yon == 1)
                  Positioned(
                    right: context.screenWidth - _globalPosition.dx,
                    top: _globalPosition.dy,
                    child: _current,
                  ),
                if (_yon == 2)
                  Positioned(
                    left: _globalPosition.dx,
                    bottom: context.screenHeight - _globalPosition.dy,
                    child: _current,
                  ),
                if (_yon == 3)
                  Positioned(
                    right: context.screenWidth - _globalPosition.dx,
                    bottom: context.screenHeight - _globalPosition.dy,
                    child: _current,
                  ),
              ],
            ));
    return _lessonKey;
  }
}

class PopupBox extends StatelessWidget {
  final double popupWidth;
  final String? header;
  final Iterable<Lesson>? lessonList;
  final Class? sinif;
  PopupBox({
    this.popupWidth = 250,
    this.header,
    this.lessonList,
    this.sinif,
  });
  final _controller = Get.find<TimaTableEditController>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: popupWidth,
      child: Card(
        margin: EdgeInsets.zero,
        color: Fav.design.scaffold.background,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(header!, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
              Container(margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), height: 1, color: Fav.design.disablePrimary),
              Wrap(
                runSpacing: 8,
                spacing: 8,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.center,
                children: <Widget>[
                  if (lessonList!.isEmpty)
                    Text(
                      'nosuggestedlesson'.translate,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Fav.design.primaryText),
                    ),
                  ...lessonList!
                      .map<Widget>(
                        (lesson) => GestureDetector(
                          onTap: () {
                            Navigator.pop(context, lesson.key);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: ShapeDecoration(
                                color: _controller.timeTableSettings.boxColorIsTeacher ? (((_controller.caches[lesson.key]) ?? {})['teacherColor'] ?? const Color(0xff24262A)) : (((_controller.caches[lesson.key]) ?? {})['lessonColor'] ?? const Color(0xff24262A)), shape: const StadiumBorder()),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                lesson.name.text.color(Colors.white).fontSize(12).make(),
                                6.widthBox,
                                CircleAvatar(
                                  radius: 9,
                                  backgroundColor: Colors.white,
                                  child: Center(
                                    child: Text('${lesson.count! - (((_controller.programData[sinif!.key] ?? {}) as Map).values.fold(0, (t, e) => e == lesson.key ? t + 1 : t))}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: _controller.timeTableSettings.boxColorIsTeacher ? (((_controller.caches[lesson.key]) ?? {})['teacherColor'] ?? const Color(0xff24262A)) : (((_controller.caches[lesson.key]) ?? {})['lessonColor'] ?? const Color(0xff24262A)))),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
              Container(margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), height: 1, color: Fav.design.disablePrimary),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, 'sil');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: const ShapeDecoration(color: Colors.red, shape: StadiumBorder()),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
