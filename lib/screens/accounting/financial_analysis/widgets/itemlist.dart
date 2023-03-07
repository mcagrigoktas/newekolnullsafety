import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../controller.dart';

class FinansalAnalsisItemList extends StatelessWidget {
  FinansalAnalsisItemList();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<FinancialAnalysisController>();
    return Scroller(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1300,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(color: Fav.design.scaffold.background.withAlpha(150)),
              child: Row(
                children: [
                  for (var _i = 0; _i < _controller.columnNames.length; _i++) Expanded(flex: _controller.flexList[_i], child: _controller.columnNames[_i].translate.text.color(Fav.design.primary).bold.make().center),
                ],
              ),
            ),
            Container(height: 1, color: Fav.design.primaryText.withAlpha(15), width: double.infinity),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final _item = _controller.rows[index];
                  return Container(
                    constraints: BoxConstraints(maxHeight: 30),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: index.isEven ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150),
                        border: index != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
                    child: Row(
                      children: [
                        Expanded(flex: _controller.flexList[0], child: _item[0].toString().text.bold.color(Fav.design.primary).make().center),
                        Expanded(flex: _controller.flexList[1], child: _item[1].toString().text.make().center),
                        Expanded(flex: _controller.flexList[2], child: _item[2].toString().text.make().center),
                        Expanded(flex: _controller.flexList[3], child: _item[3].toString().text.make().center),
                        Expanded(flex: _controller.flexList[4], child: _item[4].toString().translate.text.make().center),
                        Expanded(flex: _controller.flexList[5], child: _item[5].toString().text.make().center),
                        Expanded(flex: _controller.flexList[6], child: (_item[6] == 'done' ? Icons.done : Icons.clear).icon.padding(0).color(_item[6] == 'done' ? Colors.green : Colors.red).size(16).make().center),
                        Expanded(flex: _controller.flexList[7], child: _item[7].toString().text.make().center),
                      ],
                    ),
                  );
                },
                itemCount: _controller.rows.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
