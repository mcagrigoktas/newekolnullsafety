import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/allmodel.dart';
import 'controller.dart';

class P2PTeacherList extends StatelessWidget {
  final controller = Get.find<P2PController>();

  void onFilterChanged(String text) {
    controller.teacherFilterText = text.toLowerCase();
    controller.update();
  }

  void teacherBranchDropdownChanged(text) {
    controller.teacherBranchDropdownValue = text;
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    // final _studentRequestLesson = controller.selectedRequest == null ? null : AppVar.appBloc.lessonService.dataListItem(controller.selectedRequest.lessonKey);
    List<Teacher> _filteredList = AppVar.appBloc.teacherService!.dataList
        .where((item) {
          if (controller.teacherBranchDropdownValue.safeLength < 1) return true;
          if (item.branches == null || item.branches!.isEmpty) return true;
          return item.branches!.contains(controller.teacherBranchDropdownValue);
        })
        // .where((item) {
        //   if (controller.selectedRequest == null) return true;
        //   if (item.branches == null || item.branches.isEmpty || _studentRequestLesson == null || _studentRequestLesson.branch == null) return true;

        //   return item.branches.contains(_studentRequestLesson.branch);
        // })
        .where((item) => (item.getSearchText.contains(controller.teacherFilterText ?? "")))
        .toList();

    return Column(children: [
      12.heightBox,
      MySearchBar(
        onChanged: onFilterChanged,
        resultCount: _filteredList.length,
      ).px4,
      6.heightBox,
      AdvanceDropdown(
        name: 'branch'.translate,
        padding: EdgeInsets.all(2),
        items: controller.teacherBranchListItem,
        onChanged: teacherBranchDropdownChanged,
        initialValue: controller.teacherBranchDropdownValue,
      ),
      _filteredList.isNotEmpty
          ? Expanded(
              flex: 1,
              child: ListView.builder(
                key: const PageStorageKey('teacherListp2p'),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  var item = _filteredList[index];
                  return MyCupertinoListTile(
                      //  islargeScreen: true,
                      onTap: () {
                        controller.selectTeacher(item.key);
                      },
                      title: item.name,
                      imgUrl: item.imgUrl,
                      isSelected: controller.selectedTeacher == item.key);
                },
              ),
            )
          : EmptyState(imgWidth: 50),
    ]);
  }
}
