import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'controller.dart';
import 'model.dart';
import 'widgets/portfolio_items/exam_result_main_widget.dart';
import 'widgets/portfolio_items/homework_result_main_widget.dart';
import 'widgets/portfolio_items/p2pwidget.dart';
import 'widgets/portfolio_items/rollcall_widget.dart';

class PortfolioStudentsMain extends StatelessWidget {
  final PortfolioType? initialIndex;
  final bool forMiniScreen;
  PortfolioStudentsMain({
    this.forMiniScreen = true,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioController>(
        init: PortfolioController(portfolioIndex: initialIndex),
        builder: (controller) {
          final _dataList = controller.datalist;
          return AppScaffold(
              isFullScreenWidget: forMiniScreen ? true : false,
              scaffoldBackgroundColor: forMiniScreen ? null : Colors.transparent,
              topBar: TopBar(
                hideBackButton: !forMiniScreen,
                leadingTitle: 'menu1'.translate,
              ),
              topActions: TopActionsTitleWithChild(
                  childIsPinned: true,
                  title: TopActionsTitle(title: 'studentportfolio'.translate),
                  child: Row(
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
                  )),
              body: _dataList.isEmpty
                  ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
                  : controller.portfolioIndex == PortfolioType.examCheck
                      ? Body.child(child: PortfolioLessonExamResultMainWidget(portfolioItems: _dataList))
                      : controller.portfolioIndex == PortfolioType.homeworkCheck
                          ? Body.child(child: PortfolioLessonHomeWorkResultMainWidget(portfolioItems: _dataList))
                          : controller.portfolioIndex == PortfolioType.rollcall
                              ? Body.child(child: PortfolioRollCallMainWidget(portfolioItems: _dataList))
                              : controller.portfolioIndex == PortfolioType.p2p
                                  ? Body.child(child: PortfolioP2PMainWidget(portfolioItems: _dataList))
                                  : Body.listviewBuilder(
                                      maxWidth: 720,
                                      itemCount: _dataList.length,
                                      itemBuilder: (context, index) {
                                        return controller.itemWidget(_dataList[index]);
                                      },
                                    ));
        });
  }
}
