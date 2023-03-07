import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../controller.dart';
import '../themes.dart';

class StudentList extends StatelessWidget {
  StudentList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return Column(
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
                (controller.extraMenuType == ExtraMenuType.onlineStudentList ? 'online'.translate : 'offline'.translate).translate.text.make(),
                4.widthBox,
                CircleAvatar(
                  radius: 4,
                  backgroundColor: controller.extraMenuType == ExtraMenuType.onlineStudentList ? Colors.green : Colors.red,
                ),
              ],
            ).p12),
        1.heightBox,
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            color: Fav.design.card.background,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12))),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final onlineItems = controller.onlineUsers.firstWhereOrNull((element) => element.uid == controller.targetList[index].key);
                final isUserOnLine = onlineItems != null;
                if (isUserOnLine && controller.extraMenuType != ExtraMenuType.onlineStudentList) return const SizedBox();
                if (!isUserOnLine && controller.extraMenuType != ExtraMenuType.offlineStudentList) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isUserOnLine ? MdiIcons.account : MdiIcons.accountOff,
                        color: isUserOnLine ? Colors.green : Fav.design.accentText,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(controller.targetList[index].name!, style: TextStyle(color: Fav.design.accentText)),
                            //   if (onlineItems != null) Text(onlineItems.getDevice, style: TextStyle(color: Fav.design.accentText, fontSize: 8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: controller.targetList.length,
            ),
          ),
        ),
      ],
    ).p8;
  }
}
