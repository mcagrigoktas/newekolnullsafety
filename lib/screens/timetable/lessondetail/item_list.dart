import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../hwwidget.dart';
import '../modelshw.dart';

class HomeworkPageItemList extends StatelessWidget {
  final List<HomeWork>? itemList;
  HomeworkPageItemList(this.itemList);
  @override
  Widget build(BuildContext context) {
    return CupertinoTabWidget(
      backgroundColor: Colors.transparent,
      padding: 0,
      initialPageValue: 0,
      tabs: [
        TabMenu(name: 'timeline'.translate, widget: _HomeWorkList(itemList), value: 0),
        TabMenu(name: 'homework'.translate, widget: _HomeWorkList(itemList!.where((element) => element.tur == 1).toList()), value: 1),
        TabMenu(name: 'exam'.translate, widget: _HomeWorkList(itemList!.where((element) => element.tur == 2).toList()), value: 2),
        TabMenu(name: 'hwnote'.translate, widget: _HomeWorkList(itemList!.where((element) => element.tur == 3).toList()), value: 3),
      ],
    );
  }
}

class _HomeWorkList extends StatelessWidget {
  final List<HomeWork>? itemList;
  _HomeWorkList(this.itemList);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: itemList!.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          return HomeWorkWidget(
            homeWork: itemList![index],
            dividerStyle: itemList!.length == 1 ? 3 : (index == 0 ? 0 : (index == itemList!.length - 1 ? 2 : 1)),
          );
        });
  }
}
