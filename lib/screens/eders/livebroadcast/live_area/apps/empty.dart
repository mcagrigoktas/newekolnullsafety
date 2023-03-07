import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class EmptyLive extends StatelessWidget {
  EmptyLive();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: 'emptylivehint'.translate.text.center.make(),
    );
  }
}
