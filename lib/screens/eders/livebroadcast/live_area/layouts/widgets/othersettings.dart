import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../apps/jitsimeetnew/jitsihelper.dart';
import '../controller.dart';
import '../themes.dart';

class OtherSettings extends StatelessWidget {
  OtherSettings();

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
              'other'.translate.text.make(),
            ],
          ).p12,
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              if (controller.isYoutubeShareEnable) YoutubeShareWidget().py8,
              if (controller.inputDevices.isNotEmpty) DeviceSelectionMenu(),
            ],
          ),
        )),
        16.heightBox,
      ],
    );
  }
}

class DeviceSelectionMenu extends StatelessWidget {
  DeviceSelectionMenu();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return Card(
        color: Fav.design.card.background,
        child: Column(
          children: [
            'inputdevices'.translate.text.bold.make().pt8,
            if (controller.inputDevices.containsKey('videoInput') && controller.inputDevices['videoInput']!.isNotEmpty)
              DropDownMenu<DeviceModel>(
                placeHolderText: 'camdevices'.translate,
                onChanged: (value) {
                  controller.setCameraInputDevice(value);
                },
                items: controller.inputDevices['videoInput']!.map((e) => DropdownItem<DeviceModel>(name: e.edittedName('cam'), value: e)).toList(),
                iconData: Icons.camera,
              ),
            if (controller.inputDevices.containsKey('audioInput') && controller.inputDevices['audioInput']!.isNotEmpty)
              DropDownMenu<DeviceModel>(
                placeHolderText: 'micdevices'.translate,
                onChanged: (value) {
                  controller.setAudioInputDevice(value);
                },
                items: controller.inputDevices['audioInput']!.map((e) => DropdownItem<DeviceModel>(name: e.edittedName('mic'), value: e)).toList(),
                iconData: Icons.mic,
              ),
            if (controller.inputDevices.containsKey('audioOutput') && controller.inputDevices['audioOutput']!.isNotEmpty)
              DropDownMenu<DeviceModel>(
                placeHolderText: 'speakerdevices'.translate,
                onChanged: (value) {
                  controller.setAudioOutputDevice(value);
                },
                items: controller.inputDevices['audioOutput']!.map((e) => DropdownItem<DeviceModel>(name: e.edittedName('speaker'), value: e)).toList(),
                iconData: Icons.speaker,
              ),
          ],
        ));
  }
}

class YoutubeShareWidget extends StatelessWidget {
  YoutubeShareWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return Card(
      color: Fav.design.card.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: controller.youtubeStreamKey.safeLength > 1
            ? MyMiniRaisedButton(
                color: Colors.redAccent,
                onPressed: () {
                  controller.extraMenuType = ExtraMenuType.closed;
                  controller.stopYoutubeStream();
                },
                text: 'shareyoutubestop'.translate)
            : Column(
                children: [
                  'shareyoutube'.translate.text.make(),
                  TextField(
                    decoration: InputDecoration(fillColor: Colors.transparent, hintText: 'youtubeStreamKey'.translate, hintStyle: TextStyle(color: const Color(0x88BBC7DE).withAlpha(180), fontSize: 12)),
                    onChanged: (value) {
                      controller.youtubeStreamKey = value;
                    },
                  ).py8,
                  MyMiniRaisedButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        controller.extraMenuType = ExtraMenuType.closed;
                        controller.startYoutubeStream();
                      },
                      text: 'start'.translate),
                ],
              ),
      ),
    );
  }
}
