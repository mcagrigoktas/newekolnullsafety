import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../model.dart';
import '../controller.dart';

class SummaryResult {
  final double? alinanlar;
  final double? alinacaklar;
  final double? verilenler;
  final double? verilecekler;

  double get suankiKasa => alinanlar! - verilenler!;
  double get sonKasa => alinanlar! - verilenler! + alinacaklar! - verilecekler!;

  SummaryResult({this.alinacaklar, this.alinanlar, this.verilecekler, this.verilenler});

  List<String> get toExcelRow {
    return [
      'totalcollection'.translate,
      alinanlar!.toStringAsFixed(2),
      'futuracollection'.translate,
      alinacaklar!.toStringAsFixed(2),
      'paidexpenses'.translate,
      verilenler!.toStringAsFixed(2),
      'unpaidexpenses'.translate,
      verilecekler!.toStringAsFixed(2),
      'availablesafe'.translate,
      suankiKasa.toStringAsFixed(2),
      'cashbalance'.translate,
      sonKasa.toStringAsFixed(2),
    ];
  }

  List<List<String>> get toPrintRows {
    return [
      [
        '',
        '',
        'totalcollection'.translate,
        alinanlar!.toStringAsFixed(2),
        '',
        '',
      ],
      [
        '',
        '',
        'futuracollection'.translate,
        alinacaklar!.toStringAsFixed(2),
        '',
        '',
      ],
      [
        '',
        '',
        'paidexpenses'.translate,
        verilenler!.toStringAsFixed(2),
        '',
        '',
      ],
      [
        '',
        '',
        'unpaidexpenses'.translate,
        verilecekler!.toStringAsFixed(2),
        '',
        '',
      ],
      [
        '',
        '',
        'availablesafe'.translate,
        suankiKasa.toStringAsFixed(2),
        '',
        '',
      ],
      [
        '',
        '',
        'cashbalance'.translate,
        sonKasa.toStringAsFixed(2),
        '',
        '',
      ],
    ];
  }
}

class SummaryHelper {
  SummaryHelper._();
  static SummaryResult calculate() {
    final _controller = Get.find<FinancialAnalysisController>();
    double _alinanlar = 0;
    double _alinacaklar = 0;
    double _verilenler = 0;
    double _verilecekler = 0;
    (!_controller.filterMenuIsOpen ? _controller.filteredAccountLogData : _controller.allAccountLogData).forEach((element) {
      if (element.accountLogType == AccountLogType.C) {
        if (element.tahsilEdilecek == true) {
          _verilecekler += element.amount!;
        } else {
          _verilenler += element.amount!;
        }
      } else if (element.accountLogType == AccountLogType.S) {
        if (element.tahsilEdilecek == true) {
          _alinacaklar += element.amount!;
        } else {
          _alinanlar += element.amount!;
        }
      } else if (element.accountLogType == AccountLogType.E) {
        //? Expenses tahsil edilecek olamaz ama yinede eklendi
        if (element.tahsilEdilecek == true) {
          _verilecekler += element.amount!;
        } else {
          _verilenler += element.amount!;
        }
      } else if (element.accountLogType == AccountLogType.ST) {
        if (element.tahsilEdilecek == true) {
          _alinacaklar += element.amount!;
        } else {
          _alinanlar += element.amount!;
        }
      } else if (element.accountLogType == AccountLogType.V) {
        //? Pozitiflik negatiflik herseyi cozdugu icin if kontrolu gereksiz ama yinede yazildi
        if (element.amount! > 0) {
          _alinanlar += element.amount!;
        } else {
          _alinanlar += element.amount!;
        }
      }
    });
    return SummaryResult(alinacaklar: _alinacaklar, alinanlar: _alinanlar, verilecekler: _verilecekler, verilenler: _verilenler);
  }
}

class Summary extends StatefulWidget {
  Summary({Key? key}) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final _controller = Get.find<FinancialAnalysisController>();

  late SummaryResult _result;
  @override
  void initState() {
    _result = SummaryHelper.calculate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _childrenList = [
      [_result.alinanlar, MyPalette.getBaseColor(0), 'totalcollection'],
      [_result.alinacaklar, MyPalette.getBaseColor(1), 'futuracollection'],
      if (_result.verilenler != 0) [_result.verilenler, MyPalette.getBaseColor(5), 'paidexpenses'],
      if (_result.verilecekler != 0) [_result.verilecekler, MyPalette.getBaseColor(6), 'unpaidexpenses'],
      [_result.suankiKasa, MyPalette.getBaseColor(9), 'availablesafe'],
      [_result.sonKasa, MyPalette.getBaseColor(10), 'cashbalance'],
    ]
        .map(
          (e) => _controller.filterMenuIsOpen
              ? Container(
                  padding: Inset.hv(16, 8),
                  alignment: Alignment.center,
                  width: 162,
                  height: 110,
                  decoration: BoxDecoration(gradient: (e[1] as Color?)!.hueGradient, borderRadius: BorderRadius.circular(16), boxShadow: [
                    BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 2,
                      color: Colors.grey.withAlpha(25),
                    )
                  ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (e[2] as String?).translate.toUpperCase().text.autoSize.maxLines(1).fontSize(16).center.color(Colors.black).bold.make(),
                      16.heightBox,
                      (e[0] as double).toStringAsFixed(2).text.autoSize.maxLines(1).color(Colors.white).fontSize(24).bold.make(),
                    ],
                  ),
                )
              : Container(
                  padding: Inset.hv(16, 8),
                  margin: Inset.h(16),
                  decoration: BoxDecoration(gradient: (e[1] as Color?)!.hueGradient, borderRadius: BorderRadius.circular(8), boxShadow: [
                    BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 2,
                      color: Colors.grey.withAlpha(25),
                    )
                  ]),
                  child: Column(
                    children: [
                      (e[2] as String?).translate.toUpperCase().text.autoSize.maxLines(1).color(Colors.black).bold.make(),
                      8.heightBox,
                      (e[0] as double).toStringAsFixed(2).text.autoSize.maxLines(1).color(Colors.white).fontSize(24).bold.make(),
                    ],
                  ),
                ),
        )
        .toList();

    if (_controller.filterMenuIsOpen) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          scrollDirection: Axis.vertical,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _childrenList,
          ),
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _childrenList,
        ),
      ),
    );
  }
}
