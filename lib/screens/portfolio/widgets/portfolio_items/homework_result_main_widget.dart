import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../managerscreens/schoolsettings/pages/terms/helper.dart';
import '../../../timetable/homework/homework_check_helper.dart';
import '../../model.dart';
import '../homework_mini_widget.dart';

class PortfolioLessonHomeWorkResultMainWidget extends StatefulWidget {
  final List<Portfolio>? portfolioItems;
  PortfolioLessonHomeWorkResultMainWidget({this.portfolioItems});

  @override
  State<PortfolioLessonHomeWorkResultMainWidget> createState() => _PortfolioLessonHomeWorkResultMainWidgetState();
}

class _PortfolioLessonHomeWorkResultMainWidgetState extends State<PortfolioLessonHomeWorkResultMainWidget> {
  //{'LessonKey':[List<HomeWorkCheck>]}
  final _cachedData = <String?, List<HomeWorkCheck>>{};
  final _subTermData = AppVar.appBloc.schoolInfoService!.singleData!.subTermList();
  String? _subTermValue;
  String lessonKey = 'all';

  @override
  void initState() {
    _calculateSubTermData();
    _calculaterCachedData();
    super.initState();
  }

  void _calculateSubTermData() {
    _subTermValue = TermsHelper.calculateSubTermDropdownValue();
  }

  void _calculaterCachedData() {
    _cachedData.clear();
    final _subTermModel = _subTermValue == null ? null : _subTermData!.firstWhereOrNull((element) => element.name == _subTermValue);
    final _portfolioItems = widget.portfolioItems!.where((element) {
      if (_subTermModel == null) return true;
      var hwItem = element.data<HomeWorkCheck>()!;
      if (hwItem.date == null) return true;
      return hwItem.date! >= _subTermModel.startDate! && hwItem.date! <= _subTermModel.endDate!;
    });
    //? Dersler gruplaniyor
    _portfolioItems.forEach((portfolioItem) {
      var hwItem = portfolioItem.data<HomeWorkCheck>()!;
      _cachedData[hwItem.lessonKey] ??= [];
      _cachedData['all'] ??= [];
      _cachedData[hwItem.lessonKey]!.add(hwItem);
      _cachedData['all']!.add(hwItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_subTermValue != null)
          AdvanceDropdown<String>(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            initialValue: _subTermValue,
            name: 'subtermlist'.translate,
            items: _subTermData!.map((e) => DropdownItem(name: e.name, value: e.name)).toList(),
            onChanged: (value) {
              setState(() {
                _subTermValue = value;
                _calculaterCachedData();
                Fav.preferences.setString(TermsHelper.termDropdownPrefKey, value);
              });
            },
          ),
        AdvanceDropdown<String>(
          padding: EdgeInsets.symmetric(horizontal: 12),
          initialValue: lessonKey,
          name: 'lessonlist'.translate,
          items: _cachedData.keys.where((element) => element != 'all').map((e) => DropdownItem(name: (AppVar.appBloc.lessonService!.dataListItem(e!)?.name ?? e), value: e)).toList()..insert(0, DropdownItem(name: 'all'.translate, value: 'all')),
          onChanged: (value) {
            setState(() {
              lessonKey = value;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _cachedData[lessonKey]!.length,
              itemBuilder: (context, index) {
                final _examDataList = _cachedData[lessonKey]![index];
                return HomeWorkMiniWidget(_examDataList);
              }),
        ),
      ],
    );
  }
}
