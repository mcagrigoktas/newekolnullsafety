import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../managerscreens/schoolsettings/pages/terms/helper.dart';
import '../../../timetable/homework/homework_check_helper.dart';
import '../../../timetable/hwwidget.helper.dart';
import '../../model.dart';

class PortfolioLessonExamResultMainWidget extends StatefulWidget {
  final List<Portfolio>? portfolioItems;
  PortfolioLessonExamResultMainWidget({this.portfolioItems});

  @override
  State<PortfolioLessonExamResultMainWidget> createState() => _PortfolioLessonExamResultMainWidgetState();
}

class _PortfolioLessonExamResultMainWidgetState extends State<PortfolioLessonExamResultMainWidget> {
  //{'LessonKey':[List<HomeWorkCheck>]}
  final _cachedData = <String?, List<HomeWorkCheck>>{};
  final _subTermData = AppVar.appBloc.schoolInfoService!.singleData!.subTermList();
  String? _subTermValue;

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
      _cachedData[hwItem.lessonKey]!.add(hwItem);
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
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ..._cachedData.entries.map((entry) {
                final _lessonKey = entry.key!;
                final _examDataList = entry.value;
                final _lesson = AppVar.appBloc.lessonService!.dataListItem(_lessonKey);
                if (_lesson == null) return SizedBox();
                return Card(
                  color: Fav.design.card.background,
                  child: SizedBox(
                    height: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _lesson.longName!.toUpperCase().text.bold.make(),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _examDataList.length,
                            itemBuilder: (context, index) {
                              final _item = _examDataList[index];
                              return HomeWorkWidgetHelper.getExamNoteForPortfolio(_item, _lesson).pr16;
                            },
                          ),
                        ),
                      ],
                    ).p16,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
