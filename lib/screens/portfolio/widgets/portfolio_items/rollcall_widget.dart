import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../managerscreens/schoolsettings/pages/terms/helper.dart';
import '../../../rollcall/helper.dart';
import '../../../rollcall/model.dart';
import '../../model.dart';

class PortfolioRollCallMainWidget extends StatefulWidget {
  final List<Portfolio>? portfolioItems;
  PortfolioRollCallMainWidget({this.portfolioItems});

  @override
  State<PortfolioRollCallMainWidget> createState() => _PortfolioRollCallMainWidgetState();
}

class _PortfolioRollCallMainWidgetState extends State<PortfolioRollCallMainWidget> {
  //{'LessonKey':[List<HomeWorkCheck>]}
  var _cachedData = <Portfolio>[];
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
    _cachedData = widget.portfolioItems!.where((element) {
      if (_subTermModel == null) return true;
      var hwItem = element.data<RollCallStudentModel>()!;
      if (hwItem.date == null) return true;
      return hwItem.date! >= _subTermModel.startDate! && hwItem.date! <= _subTermModel.endDate!;
    }).toList();
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
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _cachedData.length,
              itemBuilder: (context, index) {
                final _examDataList = _cachedData[index].data<RollCallStudentModel>();
                return _RollCallMiniWidget(_examDataList);
              }),
        ),
      ],
    );
  }
}

class _RollCallMiniWidget extends StatelessWidget {
  final RollCallStudentModel? data;
  _RollCallMiniWidget(this.data);
  @override
  Widget build(BuildContext context) {
    if (data!.isEkid!) return _RollCallEkidWidget(data);
    return _RollCallEkolWidget(data);
  }
}

class _RollCallEkolWidget extends StatelessWidget {
  final RollCallStudentModel? data;
  _RollCallEkolWidget(this.data);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      color: Fav.design.card.background,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data!.date!.dateFormat('dd-MMM-yyyy'),
                  style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  data!.lessonName ?? 'lessonnameerr'.translate,
                  style: TextStyle(color: Fav.design.primaryText, fontSize: 16),
                ),
                Text(
                  'lesson'.translate + ' ${data!.lessonNo}',
                  style: TextStyle(color: Fav.design.primaryText),
                ),
              ],
            ),
          ),
          Container(
            width: 90,
            height: 28,
            alignment: Alignment.center,
            decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(data!.value)),
            child: Text(
              'rollcall${data!.value}'.translate,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ).p12,
    );
  }
}

class _RollCallEkidWidget extends StatelessWidget {
  final RollCallStudentModel? data;
  _RollCallEkidWidget(this.data);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      color: Fav.design.card.background,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              data!.date!.dateFormat('dd-MMM-yyyy'),
              style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Container(
            width: 90,
            height: 28,
            alignment: Alignment.center,
            decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallEkidStatusColor(data!.value)),
            child: Text(
              'rollcall${data!.value}'.translate,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ).p12,
    );
  }
}
