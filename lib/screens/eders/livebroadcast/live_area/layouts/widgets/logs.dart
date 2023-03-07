import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../../library_helper/excel/eager.dart';
import '../controller.dart';
import '../themes.dart';

class Logs extends StatelessWidget {
  Logs();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
            margin: EdgeInsets.zero,
            color: Fav.design.card.background,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
            child: Row(
              children: [
                GestureDetector(
                    onTap: controller.closeOpenedPanel,
                    child: Container(
                      decoration: BoxDecoration(gradient: MeetTheme.gradient, borderRadius: BorderRadius.circular(6)),
                      child: (Icons.close).icon.color(Colors.white).size(16).padding(2).make(),
                    )),
                6.widthBox,
                ('logs'.translate).translate.text.make(),
              ],
            ).p12),
        1.heightBox,
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            color: Fav.design.card.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
            child: SizedBox(
              width: double.infinity,
              child: controller.logData.isEmpty
                  ? const SizedBox()
                  : MyDataTable(
                      data: controller.logData,
                      textColor: Fav.design.accentText,
                    ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          color: Fav.design.card.background,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12))),
          child: SizedBox(
            width: double.infinity,
            child: MyMiniRaisedButton(
              onPressed: () {
                ExcelLibraryHelper.export(controller.logData, DateTime.now().dateFormat("d-MMM, HH:mm") + 'LogData');
              },
              text: 'exportexcell'.translate,
            ).p8,
          ),
        ),
      ],
    ).p8;
  }
}
