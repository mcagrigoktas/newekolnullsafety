import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/mainhelper.dart';
import '../../../helpers/print_and_export_helper.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';

class StudentFinancalAnalysis extends StatefulWidget {
  @override
  _StudentFinancalAnalysisState createState() => _StudentFinancalAnalysisState();
}

class _StudentFinansalAnalysisData {
  final String? studentName;
  final String? paymentName;
  final double? tutar;
  final double? odenen;
  final String? studentKey;

  double get kalan => tutar! - odenen!;
  _StudentFinansalAnalysisData({this.studentName, this.paymentName, this.tutar, this.studentKey, this.odenen});
}

class _StudentFinancalAnalysisState extends State<StudentFinancalAnalysis> {
  String? _paymentTypeKey = AppVar.appBloc.schoolInfoService!.singleData!.paymentName('paymenttype1');
  Map? _data;
  bool _isLoading = true;
  final List<_StudentFinansalAnalysisData> _pastData = [];
  List<_StudentFinansalAnalysisData> _filteredPastData = [];
  @override
  void initState() {
    if (DateTime.now().millisecondsSinceEpoch - Fav.readSeasonCache<int>('readaccountingstatisticstime', 0)! < const Duration(minutes: 10).inMilliseconds && Fav.readSeasonCache<Map>('readlastaccountingstatistics', {}) != null) {
      _data = Fav.readSeasonCache<Map>('readlastaccountingstatistics', {});
      _getPastData();
      _isLoading = false;
    } else {
      AccountingService.dbAllStudentAccountingData().once().then((snap) {
        setState(() {
          _data = snap!.value;
          _getPastData();
          _isLoading = false;
          Fav.writeSeasonCache('readaccountingstatisticstime', DateTime.now().millisecondsSinceEpoch);
          Fav.writeSeasonCache('readlastaccountingstatistics', _data);
        });
      });
    }
    super.initState();
  }

  void _makeFilter() {
    if (_paymentTypeKey == 'all') {
      _filteredPastData = _pastData;
    } else {
      _filteredPastData = _pastData.where((element) => (element.paymentName == _paymentTypeKey)).toList();
    }

    _filteredPastData.sort((a, b) => (b.kalan - a.kalan) > 0
        ? 1
        : (b.kalan - a.kalan) == 0
            ? 0
            : -1);
  }

  void _getPastData() {
    _data!.forEach((studentKey, allPaymentList) {
      var student = AppVar.appBloc.studentService!.dataList.singleWhereOrNull((student) => student.key == studentKey);

      ///todo silinmis  ogrenciye ait faturalainda gozukmesini istyiorasn  burayi ac
      //  if (student == null) student = Student()..name =  'erasedstudent');
      if (allPaymentList['PaymentPlans'] != null && student != null) {
        (allPaymentList['PaymentPlans'] as Map).forEach((paymentName, paymentValues) {
          if (paymentName == 'custompayment') {
            (paymentValues as Map).forEach((paymentKey, paymentValue) {
              final _payment = TaksitModel.fromJson(paymentValue);
              final double _odennenTutar = (_payment.odemeler?.fold<double>(0, ((t, v) => t + v.miktar!)) ?? 0);
              if (_payment.aktif != false) {
                _pastData.add(_StudentFinansalAnalysisData(
                  studentName: student.name,
                  studentKey: studentKey,
                  paymentName: _payment.name,
                  tutar: _payment.tutar,
                  odenen: _odennenTutar,
                ));
              }
            });
          } else {
            var _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentName);

            PaymentModel _payments = PaymentModel.fromJson(paymentValues);

            if (_payments.aktif != false) {
              final List<TaksitModel?> paymentList = [];
              if (_payments.pesinUcret != null) {
                paymentList.add(_payments.pesinUcret);
              }
              if (_payments.pesinat != null) {
                paymentList.add(_payments.pesinat);
              }
              if (_payments.taksitler != null) {
                paymentList.addAll(_payments.taksitler!);
              }

              double _totalTutar = 0.0;
              double _odenenToplamTutar = 0.0;

              paymentList.forEach((payment) {
                if ((payment!.tutar ?? 0) != 0) {
                  if (payment.aktif != false) {
                    final double _odennenTutar = (payment.odemeler?.fold<double>(0, ((t, v) => t + v.miktar!)) ?? 0);
                    _odenenToplamTutar += _odennenTutar;
                    _totalTutar += payment.tutar!;
                  }
                }
              });

              _pastData.add(_StudentFinansalAnalysisData(
                studentName: student.name,
                studentKey: studentKey,
                paymentName: _realPaymentName,
                tutar: _totalTutar,
                odenen: _odenenToplamTutar,
              ));
            }
          }
        });
      }
    });
    _makeFilter();
  }

  PrintAndExportModel _prepareExportData({bool forExcel = false}) {
    return PrintAndExportModel(columnNames: [
      'name'.translate,
      'quantity'.translate,
      'paid'.translate,
      'unpaid'.translate,
    ], rows: _filteredPastData.map<List<dynamic>>((e) => [e.studentName, forExcel ? e.tutar : e.tutar.toString(), forExcel ? e.odenen : e.odenen.toString(), forExcel ? e.kalan : e.kalan.toString()]).toList());
  }

  @override
  Widget build(BuildContext context) {
    final _topBar = TopBar(leadingTitle: 'menu1'.translate);

    if (_isLoading) {
      return AppScaffold(topBar: _topBar, topActions: TopActionsTitle(title: 'accountingstatitictype2'.translate), body: Body.child(child: MyProgressIndicator(isCentered: true)));
    }

    final _topActions = TopActionsTitleWithChild(
        title: TopActionsTitle(title: 'accountingstatitictype2'.translate),
        child: AdvanceDropdown(
          name: 'paymenttype'.translate,
          items: AppConst.accountingType.map((paymentType) {
            final _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentType);
            return DropdownItem(name: _realPaymentName, value: _realPaymentName);
          }).toList()
            ..add(DropdownItem(name: 'all'.translate, value: 'all')),
          onChanged: (dynamic value) {
            setState(() {
              _paymentTypeKey = value;
              log(_paymentTypeKey);
              _makeFilter();
            });
          },
          initialValue: _paymentTypeKey,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));

    final _body = Body.listviewBuilder(
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            children: [
              SizedBox(width: 30),
              Expanded(flex: 1, child: 'name'.translate.text.bold.color(Fav.design.primary).make().center),
              Expanded(flex: 1, child: 'quantity'.translate.text.bold.color(Fav.design.primary).make().center),
              Expanded(flex: 1, child: 'paid'.translate.text.bold.color(Fav.design.primary).make().center),
              Expanded(flex: 1, child: 'unpaid'.translate.text.bold.color(Fav.design.primary).make().center),
            ],
          );
        }
        return Container(
            decoration: BoxDecoration(
                color: index.isOdd ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150), border: index != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
            child: StatisticsTile(
              item: _filteredPastData[index - 1],
              index: index - 1,
            ));
      },
      itemCount: _filteredPastData.length + 1,
      maxWidth: 800,
    );
    final _bottomBar = BottomBar(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MyMiniRaisedButton(
          text: Words.print,
          onPressed: () {
            PrintAndExportHelper.printPdf(data: _prepareExportData(forExcel: false), pdfHeaderName: 'accountingstatitictype0'.translate);
          },
          iconData: Icons.print,
        ),
        16.widthBox,
        MyMiniRaisedButton(
          text: 'exportexcell'.translate,
          onPressed: () {
            PrintAndExportHelper.exportToExcel(data: _prepareExportData(forExcel: true), excelName: 'accountingstatitictype0'.translate);
          },
          iconData: Icons.print,
        ),
        16.widthBox,
      ],
    ));

    return AppScaffold(
      topBar: _topBar,
      topActions: _topActions,
      body: _body,
      bottomBar: _bottomBar,
    );
  }
}

class StatisticsTile extends StatelessWidget {
  final _StudentFinansalAnalysisData? item;
  final int? index;

  StatisticsTile({this.item, this.index});

  @override
  Widget build(BuildContext context) {
    final _textColor = item!.kalan == 0 ? Colors.green : Fav.design.primaryText;
    return Container(
      constraints: BoxConstraints(maxHeight: 30),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
          color: index!.isEven ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150), border: index != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
      child: Row(
        children: [
          SizedBox(width: 30, child: (index! + 1).toString().text.bold.color(_textColor).make().center),
          Expanded(flex: 1, child: item!.studentName.text.bold.color(_textColor).make().center),
          Expanded(flex: 1, child: item!.tutar!.toStringAsFixed(2).text.bold.color(_textColor).make().center),
          Expanded(flex: 1, child: item!.odenen!.toStringAsFixed(2).text.bold.color(_textColor).make().center),
          Expanded(flex: 1, child: item!.kalan.toStringAsFixed(2).text.bold.color(_textColor).make().center),
        ],
      ),
    );
  }
}
