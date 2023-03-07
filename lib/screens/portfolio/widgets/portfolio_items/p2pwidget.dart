import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../managerscreens/schoolsettings/pages/terms/helper.dart';
import '../../../p2p/freestyle/model.dart';
import '../../../p2p/freestyle/otherscreens/p2pdetail/controller.dart';
import '../../../p2p/freestyle/otherscreens/p2pdetail/layout.dart';
import '../../model.dart';

class PortfolioP2PMainWidget extends StatefulWidget {
  final List<Portfolio>? portfolioItems;
  PortfolioP2PMainWidget({this.portfolioItems});

  @override
  State<PortfolioP2PMainWidget> createState() => _PortfolioP2PMainWidgetState();
}

class _PortfolioP2PMainWidgetState extends State<PortfolioP2PMainWidget> {
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
      var hwItem = element.data<P2PModel>()!;
      final _time = hwItem.startTimeMilliSecond;
      //  if (_time == null) return true;
      return _time >= _subTermModel.startDate! && _time <= _subTermModel.endDate!;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_subTermValue != null)
          AdvanceDropdown(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            initialValue: _subTermValue,
            name: 'subtermlist'.translate,
            items: _subTermData!.map((e) => DropdownItem(name: e.name, value: e.name)).toList(),
            onChanged: (dynamic value) {
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
                final _examDataList = _cachedData[index].data<P2PModel>();
                return _P2PMiniWidget(_examDataList);
              }),
        ),
      ],
    );
  }
}

class _P2PMiniWidget extends StatelessWidget {
  final P2PModel? data;
  _P2PMiniWidget(this.data);
  @override
  Widget build(BuildContext context) {
    //? Bu kisim [portfolioprintmainhelper] icerisindede var
    if (data!.aktif == false) return const SizedBox();
    final _teacher = AppVar.appBloc.teacherService!.dataListItem(data!.teacherKey!);

    if (_teacher == null) return const SizedBox();

    String? branchText;
    if (AppVar.appBloc.hesapBilgileri.gtMT && data!.studentRequestLessonKey != null) {
      final _lesson = AppVar.appBloc.lessonService!.dataListItem(data!.studentRequestLessonKey!);

      if (_lesson != null) {
        branchText = (_lesson.branch ?? _lesson.name);
      }
    }

    if (branchText == null && _teacher.branches != null && _teacher.branches!.isNotEmpty) {
      branchText = _teacher.branches!.first;
    }
//? Buraya kadar
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      color: Fav.design.card.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _teacher.name.text.bold.make()),
              if (branchText != null) branchText.text.color(Colors.white).bold.make().rounded(background: Colors.amberAccent).pr16,
              if (data!.rollCall == true) 'rollcall0'.translate.text.color(Colors.white).bold.make().rounded(background: Colors.green).pr16,
              if (data!.rollCall == false) 'rollcall1'.translate.text.color(Colors.white).bold.make().rounded(background: Colors.red).pr16,
              data!.startTimeFullText.text.fontSize(12).color(Fav.design.disablePrimary).make(),
            ],
          ),
          if (data!.note.safeLength > 0) data!.note.text.make().pt8,
          if (AppVar.appBloc.hesapBilgileri.gtS)
            Align(
                alignment: Alignment.bottomRight,
                child: MyMiniRaisedButton(
                    text: 'examine'.translate,
                    onPressed: () {
                      Fav.to(P2PDetail(), binding: BindingsBuilder(() => Get.put<P2PDetailController>(P2PDetailController(data))));
                    })).pt8
        ],
      ).p12,
    );
  }
}
