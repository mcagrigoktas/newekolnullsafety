import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../models/allmodel.dart';
import '../../helper.dart';
import 'controller.dart';

class CheckTeacherProgram extends StatelessWidget {
  final Teacher? initialItem;
  CheckTeacherProgram({this.initialItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckTeacherProgramController>(
        init: CheckTeacherProgramController(initialItem: initialItem),
        builder: (controller) {
          final Widget _middle = (controller.selectedItem != null ? controller.selectedItem!.name : 'teacherprogrammenuname'.translate).text.bold.color(Fav.design.primary).maxLines(1).fontSize(18).autoSize.make();

          final _showEmptyStateTacherButton = Icons.person_search_rounded.icon.color(Fav.design.appBar.text).onPressed(ProgramHelper.showEmptyStateTeacher).make();
          final _topBar = RTopBar(
            mainLeadingTitle: 'menu1'.translate,
            leadingTitleMainEqualBoth: true,
            detailLeadingTitle: 'teacherprogrammenuname'.translate,
            detailBackButtonPressed: controller.detailBackButtonPressed,
            mainMiddle: _middle,
            detailMiddle: _middle,
            bothMiddle: _middle,
            bothTrailingActions: [_showEmptyStateTacherButton],
            mainTrailingActions: [_showEmptyStateTacherButton],
          );
          Body _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = Body.listviewBuilder(
              pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID! + 'teacherCheckProgram',
              listviewFirstWidget: MySearchBar(
                onChanged: (text) {
                  controller.makeFilter(text);
                  controller.update();
                },
                initialText: controller.filteredText,
                resultCount: controller.filteredItemList.length,
              ).p4,
              itemCount: controller.filteredItemList.length,
              itemBuilder: (context, index) => MyCupertinoListTile(
                title: controller.filteredItemList[index].name,
                onTap: () {
                  controller.selectTeacher(controller.filteredItemList[index]);
                },
                isSelected: controller.filteredItemList[index].key == controller.selectedItem?.key,
                imgUrl: controller.filteredItemList[index].imgUrl,
              ),
            );

            _rightBody = controller.selectedItem == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.child(child: Builder(builder: (context) {
                    if (controller.data.isEmpty) return EmptyState(imgWidth: 50);
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
                                  controller.getDetailWidget2(),
                                  8.heightBox,
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 600),
                                    child: controller.getDetailWidget(),
                                  ),
                                  8.heightBox,
                                ],
                              )),
                        ),
                      ),
                    );
                  }));
          }

          // RBottomBar _bottomBar;
          // if (controller.selectedItem != null && (controller.visibleScreen == VisibleScreen.detail) && controller.data != null && controller.data.isNotEmpty) {
          //   Widget _bottomChild = Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       MyRaisedButton(
          //         text: Words.print,
          //         onPressed: () {
          //           controller.sinifSaatSayisi.clear();
          //           final widget = pw.Column(children: [
          //             controller.getTeacherProgram(widgetType: WidgetType.PRINT),
          //             pw.SizedBox(height: 16),
          //             controller.getDetailWidget2(widgetType: WidgetType.PRINT),
          //             pw.SizedBox(height: 16),
          //             controller.getDetailWidget(widgetType: WidgetType.PRINT),
          //           ]);

          //           PrintHelper.printPdf(pw.Transform.scale(scale: 0.7, child: widget, alignment: pw.Alignment.topLeft), pageLandscape: true);
          //         },
          //         iconData: Icons.print,
          //       ),
          //     ],
          //   );
          //   _bottomBar = RBottomBar(
          //     bothChild: _bottomChild,
          //     detailChild: _bottomChild,
          //   );
          // }

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            //   bottomBar: _bottomBar,
          );
        });
  }
}
