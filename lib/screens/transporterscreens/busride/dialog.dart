import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../models/allmodel.dart';
import 'controller.dart';

class TransporterStudentDialog extends StatelessWidget {
  final Student? student;
  TransporterStudentDialog({
    this.student,
  });
  BusRideController get controller => Get.find<BusRideController>();

  @override
  Widget build(BuildContext context) {
    final _buttonWidth = ((context.screenWidth - 64) / 2).clamp(0.0, 200.0);
    return GestureDetector(
      onTap: Get.back,
      child: Material(
        color: Colors.transparent,
        child: FadeInUpColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 2,
            ),
            if (student!.imgUrl != null && student!.imgUrl.startsWithHttp)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MyCachedImage(
                  imgUrl: student!.imgUrl!,
                  width: 200,
                ),
              ).pt16,
            16.heightBox,
            student!.name.text.color(Colors.white).center.fontSize(40).bold.make(),
            4.heightBox,
            student!.adress.text.color(Colors.white).center.make(),
            16.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.makeStudentHere(student!.key);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, fixedSize: Size(_buttonWidth, 96)),
                  child: FittedBox(child: 'rollcall0'.translate.text.fontSize(90).color(Colors.white).make().p8),
                ),
                32.widthBox,
                ElevatedButton(
                  onPressed: () {
                    controller.makeStudentAbsent(student!.key);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, fixedSize: Size(_buttonWidth, 96)),
                  child: FittedBox(child: 'rollcall1'.translate.text.fontSize(90).color(Colors.white).make().p8),
                ),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            GetBuilder<BusRideController>(builder: (controller) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: controller.getSendWeAreComingNotStatus(student!.key) == true ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: controller.getSendWeAreComingNotStatus(student!.key) == true,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.sendWeAreComingNot(student);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 255, 255, 255), fixedSize: Size(416, 54)),
                        child: FittedBox(child: (controller.getSendWeAreComingNotStatus(student!.key) == true ? 'sendnotificationsuc' : 'sendwearecomingnot').translate.text.center.fontSize(90).color(Colors.black).make().p8),
                      ),
                    ),
                  ),
                  32.heightBox,
                  Opacity(
                    opacity: controller.getSendWeAreCameNotStatus(student!.key) == true ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: controller.getSendWeAreCameNotStatus(student!.key) == true,
                      child: ElevatedButton.icon(
                        icon: Icons.thumb_up_alt_rounded.icon.color(Colors.green).make(),
                        onPressed: () {
                          controller.sendWeAreCameNot(student);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 255, 255, 255), fixedSize: Size(416, 54)),
                        label: FittedBox(child: (controller.getSendWeAreCameNotStatus(student!.key) == true ? 'sendnotificationsuc' : 'sendwecamenot').translate.text.center.fontSize(90).color(Colors.black).make().p8),
                      ),
                    ),
                  ),
                ],
              );
            }).px16,
            Spacer(
              flex: 2,
            ),
            MyFlatButton(
              text: 'savestudentlocation'.translate,
              onPressed: () {
                controller.saveStudentLocation(student!.key);
              },
              textColor: Colors.white,
            ),
            if (student!.getLatitude != null) 'oldstudentlocation'.argTranslate(student!.getLatitude.toString() + ',' + student!.getLongitude.toString()).text.color(Colors.white).make(),
            16.heightBox,
          ],
        ),
      ),
    );
  }
}
