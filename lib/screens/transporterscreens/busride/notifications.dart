import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';

class TransporterNotifications extends StatelessWidget {
  final String? timeText;
  TransporterNotifications({this.timeText});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              Icons.arrow_back_ios.icon.onPressed(Get.back).color(Fav.design.primary).make(),
              16.widthBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  timeText.text.color(Fav.design.primary).fontSize(32).make(),
                  'notifications'.translate.text.color(Fav.design.primary).fontSize(25).make(),
                ],
              ),
              32.widthBox,
            ],
          ).p16,
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ...AppVar.appBloc.inAppNotificationService!.dataList
                      .where((element) {
                        return timeText == (element.lastUpdate as int?)!.dateFormat();
                      })
                      .map((e) => ListTile(
                            leading: '🚌'.text.fontSize(32).make(),
                            title: e.title.text.color(Colors.white).fontSize(24).bold.make(),
                            subtitle: e.content.text.color(Colors.white).fontSize(20).make(),
                          ))
                      .toList()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
