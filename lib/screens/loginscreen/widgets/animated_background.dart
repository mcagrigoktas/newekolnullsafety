import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../assets.dart';

class SignInBackground2 extends StatefulWidget {
  final Widget child;
  SignInBackground2(this.child);

  @override
  State<SignInBackground2> createState() => _SignInBackground2State();
}

class _SignInBackground2State extends State<SignInBackground2> {
  final Duration _animationDuration = Duration(milliseconds: 5500);

  @override
  void initState() {
    _setupValue();
    super.initState();
  }

  GlobalKey? restartKey;
  Offset? offset1begin;
  Offset? offset1end;
  Offset? offset2begin;
  Offset? offset2end;
  Offset? offset3begin;
  Offset? offset3end;

  void _setupValue() {
    restartKey = GlobalKey();
    offset1begin = Offset(_randomWidth(), _randomHeight());
    offset1end = Offset(_randomWidth(), _randomHeight());
    offset2begin = Offset(_randomWidth(), _randomHeight());
    offset2end = Offset(_randomWidth(), _randomHeight());
    offset3begin = Offset(_randomWidth(), _randomHeight());
    offset3end = Offset(_randomWidth(), _randomHeight());
  }

  double _randomWidth() => (Get.context!.screenWidth * 1.5).toInt().random.toDouble() - (Get.context!.screenWidth * 1.5) / 2;
  double _randomHeight() => (Get.context!.screenHeight * 1.5).toInt().random.toDouble() - (Get.context!.screenHeight * 1.5) / 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        key: restartKey,
        children: [
          ...[
            [Assets.images.sShape3PNG, offset1begin, offset1end, '*'],
            [Assets.images.sShape2PNG, offset2begin, offset2end],
            [Assets.images.sShape1PNG, offset3begin, offset3end]
          ]
              .map(
                (e) => Positioned.fill(
                  child: Image.asset(e.first as String, height: 200).animate(delay: 250.ms).rotate(duration: _animationDuration).move(begin: e[1] as Offset?, end: e[2] as Offset?).custom(builder: (context, value, child) {
                    return Opacity(opacity: (value < 0.5 ? value * 1.3 : (1 - value) * 1.3).clamp(0.0, 1.0), child: child);
                  }).callback(callback: (value) async {
                    if (value == false && e.length == 4) {
                      await 1250.wait;
                      if (mounted) {
                        setState(() {
                          _setupValue();
                        });
                      }
                    }
                  }),
                ),
              )
              .toList(),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: SizedBox(),
          )),
          Positioned.fill(
            child: widget.child,
          )
        ],
      ),
    );
  }
}
