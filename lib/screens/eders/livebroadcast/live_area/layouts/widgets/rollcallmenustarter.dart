import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../controller.dart';
import '../themes.dart';

class RollCallMenuStarter extends StatelessWidget {
  RollCallMenuStarter();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
                    child: Icons.close.icon.color(Colors.white).size(16).padding(2).make(),
                  )),
              6.widthBox,
              'makerollcall'.translate.text.make(),
            ],
          ).p12,
        ),
        1.heightBox,
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            color: Fav.design.card.background,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12))),
            child: Column(
              children: [
                const SizedBox(width: double.infinity),
                controller.videoChatSettings.isRollCallEnable
                    ? MyProgressButton(
                        label: controller.lesson == null ? 'stoprollcall1'.translate : 'stoprollcall2'.translate,
                        isLoading: controller.isRollCallLoading,
                        color: Colors.blue,
                        onPressed: () {
                          controller.stopRollCall();
                        },
                        mini: true,
                      ).p8
                    : MyProgressButton(
                        label: 'startrollcall'.translate,
                        isLoading: controller.isRollCallLoading,
                        color: Colors.green,
                        onPressed: controller.startRollCall,
                        mini: true,
                      ).p8,
                if (controller.videoChatSettings.isRollCallEnable)
                  MyProgressButton(
                    label: 'cancelrollcall'.translate,
                    isLoading: controller.isRollCallLoading,
                    color: Colors.redAccent,
                    onPressed: () {
                      controller.stopRollCall(cancel: true);
                    },
                    mini: true,
                  ).p8,
                if (controller.videoChatSettings.isRollCallEnable)
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final isUserOnLine = controller.rollCallStudentresult[controller.targetList[index].key] == true;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(controller.targetList[index].name, style: TextStyle(color: Fav.design.accentText)),
                              ),
                              'here'.translate.text.color(Colors.white).bold.make().stadium(background: isUserOnLine ? Colors.green : Colors.grey),
                            ],
                          ),
                        );
                      },
                      itemCount: controller.targetList.length,
                    ).pt8,
                  ),
              ],
            ),
          ).pb8,
        )
      ],
    ).p8;
  }
}
