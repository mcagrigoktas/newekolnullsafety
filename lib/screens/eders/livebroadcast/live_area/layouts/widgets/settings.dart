import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../../appbloc/appvar.dart';
import '../controller.dart';
import '../themes.dart';

class Settings extends StatelessWidget {
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
                      child: (Icons.close).icon.color(Colors.white).size(16).padding(2).make(),
                    )),
                6.widthBox,
                ('settings'.translate).translate.text.make(),
              ],
            ).p12),
        1.heightBox,
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            color: Fav.design.card.background,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (AppVar.appBloc.hesapBilgileri.gtMT)
                    MyDropDownField(
                      canvasColor: Fav.design.dropdown.canvas,
                      name: "chats".translate,
                      iconData: Icons.mark_chat_read,
                      color: Fav.design.primaryText,
                      initialValue: controller.videoChatSettings.chatEnableType,
                      items: [0, 1, 2].map((e) => DropdownMenuItem(child: 'chatsenable$e'.translate.text.fontSize(12).make(), value: e)).toList(),
                      onChanged: (value) {
                        controller.videoChatSettings.chatEnableType = value;
                        controller.saveSettings();
                      },
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    ).p8;
  }
}
