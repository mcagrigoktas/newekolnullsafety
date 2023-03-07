import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:painter/painter.dart';

import '../../../appbloc/appvar.dart';

class QuestionMiniAppBar extends StatelessWidget {
  final Widget? title;
  final bool drawPanelIcon;
  QuestionMiniAppBar({this.title, this.drawPanelIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.0,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: AppVar.questionPageController.theme!.bookColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
        boxShadow: [BoxShadow(color: AppVar.questionPageController.theme!.bookColor!, blurRadius: 6.0)],
      ),
      child: Row(
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 26.0,
                child: IconButton(
                  iconSize: 16.0,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppVar.questionPageController.theme!.isLight! ? Colors.white : AppVar.questionPageController.theme!.primaryTextColor,
                  ),
                  onPressed: () {
                    AppVar.questionPageController.onBackPressed();
                  },
                  padding: const EdgeInsets.all(0.0),
                ),
              )),
          Expanded(flex: 1, child: title!),
          if (drawPanelIcon)
            IconButton(
              iconSize: 12.0,
              icon: Icon(
                MdiIcons.pen,
                color: AppVar.questionPageController.theme!.primaryTextColor,
              ),
              onPressed: () {
                AppVar.questionPageController.changeDrawPanelTuru();
              },
              padding: const EdgeInsets.all(0.0),
            ),
          IconButton(
            iconSize: 12.0,
            padding: const EdgeInsets.all(0.0),
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              AppVar.questionPageController.scaffoldKey.currentState!.openEndDrawer();
            },
          )
        ],
      ),
    );
  }
}

class QuestionAppBar extends StatefulWidget {
  final Widget? title;
  final double height;
  final bool hasntDrawerNeed;

  QuestionAppBar({this.title, this.height = 0.0, this.hasntDrawerNeed = false});

  @override
  QuestionAppBarState createState() {
    return QuestionAppBarState();
  }
}

class QuestionAppBarState extends State<QuestionAppBar> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  late List<Widget> actionsLeft;
  late List<Widget> actionsRight; // Kaymışken
  late List<Widget> actionsRight2;

  late PainterController _controller;
  int colorValue = 0;
  double? height;
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    height = widget.height;

    _controller = _newController();

    animationController = AnimationController(duration: const Duration(milliseconds: 333), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(animationController)
      ..addListener(() {
        if (animation.status == AnimationStatus.reverse) {
          setState(() {
            height = animation.value * (220.0);
          });
        } else {
          setState(() {
            height = animation.value * height!;
          });
        }
      });

    AppVar.questionPageController.setOpenDrawPanel.add(false);
    subscription = AppVar.questionPageController.openDrawPanel.listen((state) {
      setState(() {});
      if (state == true && height! < 10) {
        animationController.reverse(from: 1.0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    subscription.cancel();
  }

  PainterController _newController() {
    PainterController controller = PainterController();
    controller.thickness = 3.5;
    controller.backgroundColor = Colors.transparent;
    controller.drawColor = AppVar.questionPageController.theme!.primaryTextColor!;
    return controller;
  }

  void _changeColorValue(value) {
    setState(() {
      colorValue = value;
      if (colorValue == 0) {
        _controller.drawColor = AppVar.questionPageController.theme!.primaryTextColor!;
      } else if (colorValue == 1) {
        _controller.drawColor = Colors.amber;
      } else if (colorValue == 2) {
        _controller.drawColor = Colors.teal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    actionsLeft = <Widget>[
      IconButton(
          icon: const Icon(
            Icons.undo,
            color: Colors.white,
          ),
          tooltip: 'Undo',
          onPressed: _controller.undo),
      IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
          tooltip: 'Clear',
          onPressed: () {
            _controller.clear();
            AppVar.questionPageController.drawImg = null;
            setState(() {});
          }),
    ];

    actionsRight = <Widget>[
      if (AppVar.questionPageController.tablet)
        SizedBox(
            width: AppVar.questionPageController.tablet ? 200 : 60,
            child: Slider(
              divisions: 14,
              activeColor: AppVar.questionPageController.theme!.primaryTextColor,
              min: 1,
              max: AppVar.questionPageController.tablet ? 7 : 5,
              value: _controller.thickness,
              onChanged: (value) {
                setState(() {
                  _controller.thickness = value;
                });
              },
            )),
      IconButton(
          padding: const EdgeInsets.all(0.0),
          icon: Icon(
            Icons.brush,
            color: _controller.drawColor,
          ),
          onPressed: () {
            _changeColorValue((colorValue + 1) % 3);
          }),
      IconButton(
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            _controller.clear();
            AppVar.questionPageController.drawImg = null;
            animationController.reset();
            animationController.forward();
          }),
    ];

    actionsRight2 = [
      if (AppVar.questionPageController.tablet)
        SizedBox(
          height: 36.0,
          child: IconButton(
            iconSize: 22.0,
            icon: const Icon(
              MdiIcons.pen,
              color: Colors.white,
            ),
            onPressed: () {
              AppVar.questionPageController.changeDrawPanelTuru();
            },
            padding: const EdgeInsets.all(0.0),
          ),
        ),
      if (widget.hasntDrawerNeed == false)
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            AppVar.questionPageController.scaffoldKey.currentState!.openEndDrawer();
          },
        )
    ];

    List<Widget> stackWidgetChildren = [];

    stackWidgetChildren.add(Container(
      color: AppVar.questionPageController.theme!.backgroundColor,
    ));
    if (AppVar.questionPageController.drawImg != null) {
      stackWidgetChildren.add(Align(
          alignment: Alignment.center,
          child: Image.memory(
            AppVar.questionPageController.drawImg!,
            color: AppVar.questionPageController.drawImgColor,
          )));
    }
    stackWidgetChildren.add(Painter(_controller));

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: AppVar.questionPageController.theme!.bookColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
        boxShadow: [BoxShadow(color: AppVar.questionPageController.theme!.bookColor!, blurRadius: 6.0)],
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: height,
            child: Stack(
              children: stackWidgetChildren,
            ),
          ),
          GestureDetector(
            onPanUpdate: (dragUpdateDetails) {
              setState(() {
                height = (height! + dragUpdateDetails.delta.dy).clamp(0.0, 450.0);
              });
            },
            onPanEnd: (dragEndDetails) {
              if (height! < 100.0) {
                animationController.reset();
                animationController.forward();
              }
            },
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: height! > 5.0
                        ? Opacity(
                            opacity: (height! / 100).clamp(0.0, 1.0),
                            child: Row(
                              children: actionsLeft,
                            ))
                        : Container(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 36.0,
                              child: IconButton(
                                iconSize: 22.0,
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppVar.questionPageController.theme!.isLight! ? Colors.white : AppVar.questionPageController.theme!.primaryTextColor,
                                ),
                                onPressed: () {
                                  AppVar.questionPageController.onBackPressed();
                                },
                                padding: const EdgeInsets.all(0.0),
                              ),
                            ))),
                widget.title ?? const Text(""),
                Expanded(
                    flex: 2,
                    child: height! > 5.0
                        ? Opacity(
                            opacity: (height! / 100).clamp(0.0, 1.0),
                            child: Row(
                              children: actionsRight,
                              mainAxisAlignment: MainAxisAlignment.end,
                            ))
                        : Row(
                            children: actionsRight2,
                            mainAxisAlignment: MainAxisAlignment.end,
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
