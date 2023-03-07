import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../appbloc/appvar.dart';

class QuestionImage extends StatelessWidget {
  final String? imgCode;
  final double? height;
  final Color? temaRengi;

  QuestionImage({required this.imgCode, this.height, this.temaRengi});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        AppVar.questionPageController.drawImg = base64.decode(imgCode!.split(',').last);
        AppVar.questionPageController.drawImgColor = temaRengi;
        AppVar.questionPageController.setOpenDrawPanel.add(true);
        //todo Gerekirse geri ac AppVar.questionPageController.setDrawPanelTuru(3);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: Image.memory(
          base64.decode(imgCode!.split(',').last),
          height: height,
          color: temaRengi,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
