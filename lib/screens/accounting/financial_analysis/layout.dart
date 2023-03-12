import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../helpers/print_and_export_helper.dart';
import '../../../localization/usefully_words.dart';
import 'controller.dart';
import 'model.dart';
import 'widgets/filter.dart';
import 'widgets/itemlist.dart';
import 'widgets/summary.dart';
import 'widgets/virman.dart';

class FinancialAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FinancialAnalysisController>(
        init: FinancialAnalysisController(),
        builder: (controller) {
          if (controller.isAllDataLoading) {
            return AppScaffold(
              topBar: TopBar(leadingTitle: 'menu1'.translate),
              topActions: TopActionsTitle(title: 'financialanalysis'.translate),
              body: Body.child(child: Center(child: MyProgressIndicator())),
            );
          }
          return controller.virmanPageType == null ? StatisticsPage() : VirmanPage();
        });
  }
}

class StatisticsPage extends StatelessWidget {
  StatisticsPage();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<FinancialAnalysisController>();
    final _virmanButton = MyPopupMenuButton(
        child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
        onSelected: (value) async {
          if (value == VirmanType.onlyEnter || value == VirmanType.change) {
            _controller.virmanItemForSave = Virman.create();
            _controller.virmanPageType = value;
            _controller.update();
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(value: VirmanType.onlyEnter, child: Text('vmenu1'.translate, style: TextStyle(color: Fav.design.primaryText))),
            PopupMenuItem(value: VirmanType.change, child: Text('vmenu2'.translate, style: TextStyle(color: Fav.design.primaryText))),
          ];
        });

    // final _openFilterMenuButton = OutlinedButton.icon(
    //     onPressed: (() {
    //       _controller.filterMenuIsOpen = true;
    //       _controller.update();
    //     }),
    //     icon: Icons.filter_alt_rounded.icon.color(Fav.design.appBar.text).padding(0).make(),
    //     label: 'examine'.translate.text.color(Fav.design.appBar.text).make());

    return AppScaffold(
      topBar: TopBar(
          backButtonPressed: () {
            if (_controller.filterMenuIsOpen) {
              Get.back();
            } else {
              _controller.filterMenuIsOpen = true;
              _controller.update();
            }
          },
          leadingTitle: 'menu1'.translate,
          trailingActions: [
            //  if (!_controller.filterMenuIsOpen) _openFilterMenuButton,
            _virmanButton
          ]),
      topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: 'financialanalysis'.translate), child: SizedBox()),
      body: _controller.filterMenuIsOpen
          ? (Body.child(
              child: context.screenWidth > 720
                  ? Row(
                      children: [
                        Expanded(flex: 1, child: Summary(key: ObjectKey(_controller.rows))),
                        Expanded(flex: 2, child: FilterMenu()),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(flex: 1, child: Summary(key: ObjectKey(_controller.rows))),
                        Expanded(flex: 2, child: FilterMenu()),
                      ],
                    )))
          : _controller.rows.isEmpty
              ? Body.child(
                  child: EmptyState(
                    emptyStateWidget: EmptyStateWidget.NORECORDS,
                  ),
                )
              : Body.child(
                  maxWidth: 1300,
                  child: FinansalAnalsisItemList(),
                ),
      bottomBar: _controller.rows.isEmpty || _controller.filterMenuIsOpen
          ? null
          : BottomBar(
              child: Row(
              children: [
                MyPopupMenuButton(
                    child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
                    onSelected: (value) async {
                      final _name = 'financialanalysis'.translate;

                      if (value == 1) {
                        final PrintAndExportModel _model = PrintAndExportModel(columnNames: _controller.columnNames, rows: _controller.calculateRows(forExcel: true));
                        _model.rows.add(['']);
                        _model.rows.add(SummaryHelper.calculate().toExcelRow);
                        return PrintAndExportHelper.exportToExcel(excelName: _name, data: _model);
                      }
                      if (value == 2) {
                        final PrintAndExportModel _model = PrintAndExportModel(columnNames: _controller.columnNames, rows: _controller.rows);
                        _model.rows.addAll(SummaryHelper.calculate().toPrintRows);
                        return PrintAndExportHelper.printPdf(
                            pdfHeaderName: _name,
                            data: _model,
                            flexList: [4, 20, 12, 12, 6, 5, 5, 12],
                            cellFormat: (index, data) {
                              if (index == 1) return (data as String?).safeSubString(0, 50) ?? '';
                              if (index == 4) return (data as String?).onlyCapitalLetters ?? '';

                              if (index == 6) return data.toString().contains('done') ? '+' : '-';

                              return (data as String);
                            });
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(value: 1, child: Text('exportexcell'.translate, style: TextStyle(color: Fav.design.primaryText))),
                        PopupMenuItem(value: 2, child: Text(Words.print, style: TextStyle(color: Fav.design.primaryText))),
                      ];
                    }),
                Expanded(child: Summary(key: ObjectKey(_controller.rows))),
              ],
            )),
    );
  }
}
