import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/form_tab_stack/form_tab_stack.dart';
import 'package:widgetpackage/form_tab_stack/model.dart';

import '../../../helpers/glassicons.dart';

class PhotoVideoQualityBottomSheetController extends GetxController {}

class SocialQualityHelper {
  SocialQualityHelper._();

  static Future<void> openQualityScreen() async {
    PhotoVideoCompressSetting photoVideoCompressSettings = Get.find<PhotoVideoCompressSetting>();
    final controller = Get.findOrPut<PhotoVideoQualityBottomSheetController>(createFunction: () => PhotoVideoQualityBottomSheetController());

    await OverBottomSheet.show(BottomSheetPanel.child(
        child: GetBuilder<PhotoVideoQualityBottomSheetController>(
            init: PhotoVideoQualityBottomSheetController(),
            builder: (context) {
              return FormStack(
                children: [
                  FormStackItem(
                      name: 'photoquality'.translate,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...[
                              1, 2, 3
                              //, 4
                            ]
                                .map((e) => _QualityTile(
                                      onPressed: (value) async {
                                        await photoVideoCompressSettings.setPhotoQulityLevel(value);
                                        controller.update();
                                      },
                                      text: _getPhotoQualityText(e),
                                      value: e,
                                      groupValue: photoVideoCompressSettings.photoQualityLevel,
                                    ))
                                .toList(),
                            MyRaisedButton(
                                color: GlassIcons.social.color,
                                onPressed: () {
                                  OverBottomSheet.closeBottomSheet();
                                },
                                text: 'ok'.translate)
                          ],
                        ),
                      )),
                  FormStackItem(
                      name: 'videoquality'.translate,
                      child: Column(
                        children: [
                          if (isAndroid)
                            ...[1, 2, 3]
                                .map((e) => _QualityTile(
                                      onPressed: (value) async {
                                        await photoVideoCompressSettings.setVideoQulityLevel(value);
                                        controller.update();
                                      },
                                      text: _getVideoQualityText(e),
                                      value: e,
                                      groupValue: photoVideoCompressSettings.videoQualityLevel,
                                    ))
                                .toList()
                          else
                            _QualityTile(
                              onPressed: (value) async {},
                              text: isIOS ? 'iosvideoqualityhint'.translate : 'videoonlyemobile'.translate,
                              value: 2,
                              groupValue: 2,
                            ),
                          MyRaisedButton(
                              color: GlassIcons.social.color,
                              onPressed: () {
                                OverBottomSheet.closeBottomSheet();
                              },
                              text: 'ok'.translate)
                        ],
                      )),
                ],
              );
            })));

    await Get.delete<PhotoVideoQualityBottomSheetController>();
  }

  static String _getPhotoQualityText(int level) => 'photoqualitylvl$level'.translate;

  static String _getVideoQualityText(int level) => 'videoqualitylvl$level'.translate;
}

class _QualityTile extends StatelessWidget {
  final Function(int) onPressed;
  final String text;
  final int value;
  final int groupValue;
  _QualityTile({required this.onPressed, required this.text, required this.value, required this.groupValue});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        onPressed(value);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: GlassIcons.social.color!.withAlpha(value == groupValue ? 180 : 25), offset: Offset(2, 2)),
            ],
            color: Fav.design.scaffold.background),
        child: Row(
          children: [
            Radio<int?>(
              value: value,
              groupValue: groupValue,
              onChanged: (value) {
                onPressed(value!);
              },
              activeColor: GlassIcons.social.color,
            ),
            Expanded(child: text.text.make()),
          ],
        ),
      ),
    );
  }
}
