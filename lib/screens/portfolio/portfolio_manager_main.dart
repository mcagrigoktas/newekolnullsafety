import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import 'controller.dart';
import 'model.dart';
import 'widgets/portfolio_items/exam_result_main_widget.dart';
import 'widgets/portfolio_items/homework_result_main_widget.dart';
import 'widgets/portfolio_items/p2pwidget.dart';
import 'widgets/portfolio_items/rollcall_widget.dart';

class PortfolioTeachersMain extends StatelessWidget {
  final PortfolioType? initialIndex;
  PortfolioTeachersMain({
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioController>(
        init: PortfolioController(portfolioIndex: initialIndex),
        builder: (controller) {
          final _dataList = controller.datalist;
          final Widget _middle = (controller.selectedStudent != null ? controller.selectedStudent!.name : 'studentportfolio'.translate).text.bold.color(Fav.design.primary).maxLines(1).fontSize(18).autoSize.make();

          final _topBar = RTopBar(
            mainLeadingTitle: 'menu1'.translate,
            leadingTitleMainEqualBoth: true,
            detailLeadingTitle: 'studentlist'.translate,
            detailBackButtonPressed: controller.unSelectStudent,
            mainMiddle: _middle,
            detailMiddle: _middle,
            bothMiddle: _middle,
          );
          Body _leftBody;
          Body _rightBody;
          _leftBody = Body.listviewBuilder(
            pageStorageKey: 'studentlist',
            listviewFirstWidget: Column(
              children: [
                MySearchBar(
                  onChanged: (text) {
                    controller.filteredStudentText = text.toSearchCase();
                    controller.update();
                  },
                  resultCount: controller.filteredStudentList!.length,
                  initialText: controller.filteredStudentText,
                ).p4,
              ],
            ),
            itemCount: controller.filteredStudentList!.length,
            itemBuilder: (context, index) => MyCupertinoListTile(
              title: controller.filteredStudentList![index].name,
              onTap: () {
                controller.selectStudent(controller.filteredStudentList![index]);
              },
              isSelected: controller.filteredStudentList![index].key == controller.selectedStudent?.key,
              imgUrl: controller.filteredStudentList![index].imgUrl,
            ),
          );

          _rightBody = Body.child(
              maxWidth: 720,
              child: controller.selectedStudent == null
                  ? EmptyState(text: 'choosestudent'.translate)
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: CupertinoSlidingSegmentedControl(
                                groupValue: controller.portfolioIndex,
                                onValueChanged: controller.indexChanged,
                                children: controller.portfolioMap.map((key, name) => MapEntry(key, name.text.center.make())),
                              ).pl4,
                            ),
                            4.widthBox,
                            Icons.print.icon
                                .color(Fav.design.primaryText)
                                .onPressed(() {
                                  controller.printPortfolio();
                                })
                                .padding(4)
                                .make(),
                          ],
                        ),
                        Expanded(
                            child: _dataList.isEmpty
                                ? Center(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
                                : controller.portfolioIndex == PortfolioType.examCheck
                                    ? PortfolioLessonExamResultMainWidget(portfolioItems: _dataList)
                                    : controller.portfolioIndex == PortfolioType.homeworkCheck
                                        ? PortfolioLessonHomeWorkResultMainWidget(portfolioItems: _dataList)
                                        : controller.portfolioIndex == PortfolioType.rollcall
                                            ? PortfolioRollCallMainWidget(portfolioItems: _dataList)
                                            : controller.portfolioIndex == PortfolioType.p2p
                                                ? PortfolioP2PMainWidget(portfolioItems: _dataList)
                                                : ListView.builder(
                                                    itemCount: _dataList.length,
                                                    itemBuilder: (context, index) {
                                                      return controller.itemWidget(_dataList[index]);
                                                    },
                                                  ))
                      ],
                    ));

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.selectedStudent == null ? VisibleScreen.main : VisibleScreen.detail,
          );
        });
  }
}
