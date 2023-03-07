import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import 'controller.dart';
import 'model.dart';

class ExistingBusRides extends StatelessWidget {
  final List<BusRideModel> itemList;
  ExistingBusRides(this.itemList);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExistingBusRideController>(
        init: ExistingBusRideController(itemList),
        builder: (controller) {
          final Widget _middle = (controller.selectedItem != null ? controller.selectedItem!.name : controller.menuName.translate).text.bold.color(Fav.design.primary).maxLines(1).fontSize(18).autoSize.make();

          final _topBar = RTopBar(
            mainLeadingTitle: 'back'.translate,
            leadingTitleMainEqualBoth: true,
            detailLeadingTitle: controller.menuName.translate,
            detailBackButtonPressed: controller.detailBackButtonPressed,
            mainMiddle: _middle,
            detailMiddle: _middle,
            bothMiddle: _middle,
          );
          Body _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = Body.listviewBuilder(
              pageStorageKey: controller.listViewPageStorageKey,
              listviewFirstWidget: MySearchBar(
                onChanged: (text) {
                  controller.makeFilter(text.toSearchCase());
                  controller.update();
                },
                resultCount: controller.filteredItemList.length,
                initialText: controller.filteredText,
              ).p4,
              itemCount: controller.filteredItemList.length,
              itemBuilder: (context, index) => MyCupertinoListTile(
                title: controller.filteredItemList[index].name! + '/' + controller.filteredItemList[index].seferNoText.translate,
                onTap: () {
                  controller.selectItem(controller.filteredItemList[index]);
                },
                isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                //imgurl koyabilirsin
              ),
            );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: <Widget>[
                          ...controller.itemData!.studentKeyValue!.entries
                              .map((e) => Card(
                                    margin: EdgeInsets.all(2),
                                    color: e.value == 0
                                        ? Fav.design.scaffold.background
                                        : e.value == 1
                                            ? Colors.green
                                            : Colors.red,
                                    child: ListTile(
                                        title: (AppVar.appBloc.studentService!.dataListItem(e.key)?.name ?? 'erasedstudent'.translate)
                                            .text
                                            .color(
                                              e.value == 0 ? Fav.design.primaryText : Colors.white,
                                            )
                                            .make()),
                                  ))
                              .toList()
                        ],
                      ),
                    ));
          }

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
          );
        });
  }
}
