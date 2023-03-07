import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../app_widgets/z_mainwidget.dart';

class StudentCountWidget extends MainWidget {
  StudentCountWidget() : super([6, 4, 4], [0, 0, 0]);
  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      shadowColor: Colors.grey.withAlpha(20),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
        child: Row(
          children: [
            Icons.ac_unit.icon.color(Colors.pink).make(),
            8.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'studentlist'.translate.text.color(Colors.grey).overflow(TextOverflow.fade).maxLines(1).make(),
                  '78'.translate.text.color(Colors.black).bold.fontSize(18).make(),
                ],
              ),
            )
          ],
        ),
      ).p4,
    ).p8;
  }
}
