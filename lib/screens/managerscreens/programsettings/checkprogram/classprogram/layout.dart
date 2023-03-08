import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../models/class.dart';
import 'controller.dart';

class CheckClassProgram extends StatelessWidget {
  final Class? initialItem;
  CheckClassProgram({this.initialItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckClassProgramController>(
        init: CheckClassProgramController(initialItem: initialItem),
        builder: (controller) {
          final Widget _middle = (controller.selectedItem != null ? controller.selectedItem!.name : 'classprogrammenuname'.translate).text.bold.color(Fav.design.primary).maxLines(1).fontSize(18).autoSize.make();

          final _topBar = RTopBar(
            mainLeadingTitle: 'menu1'.translate,
            leadingTitleMainEqualBoth: true,
            detailLeadingTitle: 'classprogrammenuname'.translate,
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
              pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'checkClassProgram',
              listviewFirstWidget: Column(
                children: [
                  if (AppVar.appBloc.hesapBilgileri.gtM)
                    MySearchBar(
                      initialText: controller.filteredText,
                      onChanged: (text) {
                        controller.makeFilter(text);
                        controller.update();
                      },
                      resultCount: controller.filteredItemList.length,
                    ).p4,
                  if (AppVar.appBloc.hesapBilgileri.gtM)
                    AdvanceDropdown(
                      padding: Inset(4),
                      items: [
                        DropdownItem(name: 'all'.translate, value: -1),
                        DropdownItem(name: 'classtype0'.translate, value: 0),
                        DropdownItem(name: 'classtype1'.translate, value: 1),
                        ...AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!.entries
                            .map((item) => DropdownItem(
                                  name: item.value,
                                  value: int.parse(item.key.toString().replaceAll('t', '')),
                                ))
                            .toList()
                      ],
                      onChanged: (dynamic value) {
                        controller.filteredClassType = value;
                        controller.makeFilter(controller.filteredText);
                        controller.update();
                      },
                      initialValue: controller.filteredClassType,
                    ),
                ],
              ),
              itemCount: controller.filteredItemList.length,
              itemBuilder: (context, index) => MyCupertinoListTile(
                title: controller.filteredItemList[index].name,
                onTap: () {
                  controller.selectClass(controller.filteredItemList[index]);
                },
                isSelected: controller.filteredItemList[index].key == controller.selectedItem?.key,
                imgUrl: controller.filteredItemList[index].imgUrl,
              ),
            );

            _rightBody = controller.selectedItem == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.child(child: Builder(builder: (context) {
                    if (controller.data == null || controller.data == {}) return EmptyState(imgWidth: 50);
                    controller.sinifSaatSayisi.clear();
                    return Form(
                      key: controller.formKey,
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: [
                                controller.getTeacherProgram(),
                                16.heightBox,
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 600),
                                  child: controller.getDetailWidget(),
                                ),
                                16.heightBox,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
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
