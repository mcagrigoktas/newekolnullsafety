import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import 'controller.dart';

class BusRide extends StatelessWidget {
  final int seferNo;
  BusRide(this.seferNo);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusRideController>(
      init: BusRideController(seferNo),
      builder: (controller) {
        return AppScaffold(
          scaffoldBackgroundColor: Fav.design.scaffold.accentBackground,
          topBar: TopBar(
            leadingTitle: 'back'.translate,
            trailingActions: [
              Icons.notifications.icon.onPressed(controller.showNotificationDialog).color(controller.newNotificationReceived ? Colors.red : Fav.design.appBar.text).make(),
            ],
          ),
          topActions: TopActionsTitleWithChild(
            title: TopActionsTitle(title: controller.time.millisecondsSinceEpoch.dateFormat() + ' / ' + 'busridetype${controller.seferNo}'.translate + ' / ' + controller.studentList.length.toString() + ' ' + 'student'.translate),
            child: SizedBox(),
          ),
          body: controller.isPageLoading
              ? Body.circularProgressIndicator()
              : Body.reorderableListviewBuilder(
                  pageStorageKey: controller.dataPreferencesKey,
                  itemBuilder: (context, index) {
                    final _student = controller.studentList[index];
                    return Container(key: ValueKey(_student.key), child: _ItemWidget(_student));
                  },
                  itemCount: controller.studentList.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final _item = controller.studentList.removeAt(oldIndex);
                    controller.studentList.insert(newIndex, _item);
                    controller.saveOrderList();
                  },
                ),
          bottomBar: BottomBar.row(children: [
            Expanded(
              child: 'studentreorderhint'.translate.text.fontSize(11).make(),
            ),
            if (Fav.preferences.getBool(controller.savePreferencesKey) != true)
              MyProgressButton(
                onPressed: controller.save,
                label: Words.save,
                isLoading: controller.isLoading,
              )
          ]),
        );
      },
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final Student student;
  _ItemWidget(this.student);
  final _itemHeight = 60.0;

  BusRideController get controller => Get.find<BusRideController>();
  @override
  Widget build(BuildContext context) {
    final hasPhoto = student.imgUrl?.startsWithHttp ?? false;

    final _textColor = controller.getStudentStatus(student.key) == 0 ? Fav.design.selectableListItem.unselectedText : Colors.white;
    Widget current = (student.name).text.fontSize(24).bold.color(_textColor).maxLines(1).autoSize.center.make().pl16;

    current = Container(
      alignment: Alignment.centerLeft,
      child: current,
      height: _itemHeight,
    );

    current = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (hasPhoto) 16.widthBox,
        if (hasPhoto)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: MyCachedImage(
              imgUrl: student.imgUrl!,
              height: _itemHeight,
            ),
          ),
        Flexible(child: current),
        16.widthBox,
      ],
    );

    current = ElevatedButton(
      onPressed: () {
        if (Fav.preferences.getBool(controller.savePreferencesKey) != true) controller.showOptionsDialog(student);
      },
      child: current.p8,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        foregroundColor: Fav.design.primary, //Fav.design.primaryText.withAlpha(5),
        backgroundColor: controller.getStudentStatus(student.key) == 1
            ? Colors.green
            : controller.getStudentStatus(student.key) == -1
                ? Colors.red
                : Fav.design.selectableListItem.unselected,

        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ).p4;

    return current;
  }
}
