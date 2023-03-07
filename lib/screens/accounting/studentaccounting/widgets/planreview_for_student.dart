import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../flavors/mainhelper.dart';
import '../../../../helpers/appfunctions.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';

//Veli bu sayfadan odeme planlarini goruntuler
class StudentPlanReview extends StatefulWidget {
  @override
  _StudentPlanReviewState createState() => _StudentPlanReviewState();
}

class _StudentPlanReviewState extends State<StudentPlanReview> with AppFunctions {
  Map? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    AccountingService.dbStudentAccountingReviewData().once().then((snapshot) {
      if (mounted) {
        setState(() {
          data = snapshot?.value;
          isLoading = false;
        });
      }
    });
  }

  List<DataCell> buildDataCell(TaksitModel taksit, String selecTedKey) {
    double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
    return [
      DataCell(Text(
        taksit.name!,
        style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
      )),
      DataCell(Text(taksit.tarih!.dateFormat("d-MMM-yy"))),
      DataCell(Text(taksit.tutar!.toStringAsFixed(2))),
      DataCell(Text(odenen.toStringAsFixed(2))),
      DataCell(Text((taksit.tutar! - odenen).toStringAsFixed(2)))
    ];
  }

  Widget buildDataTable(PaymentModel data) {
    List<DataRow> rows = [];
    rows.add(DataRow(cells: buildDataCell(data.pesinat!, 'pesinat')));

    if (data.odemeTuru == 0) {
      rows.add(DataRow(cells: buildDataCell(data.pesinUcret!, 'pesinUcret')));
    } else {
      data.taksitler!.forEach((taksit) {
        rows.add(DataRow(cells: buildDataCell(taksit, 'taksitler')));
      });
    }
    return Column(
      children: <Widget>[
        DataTable(
          columns: [
            'name'.translate,
            'date'.translate,
            'quantity'.translate,
            'paid'.translate,
            'unpaid'.translate,
          ].map((e) => DataColumn(label: Text(e, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)))).toList(),
          rows: rows,
        ),
      ],
    );
  }

  Widget _buildCustomPaymentPlanWidget(context, paymentData) {
    if (paymentData['aktif'] == false) {
      return Container();
    }
    List<DataRow> rows = [];

    paymentData.forEach((key, value) {
      final taksit = TaksitModel.fromJson(value);
      if (taksit.aktif == true) {
        rows.add(DataRow(cells: buildDataCell(taksit, key)));
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          'name'.translate,
          'date'.translate,
          'quantity'.translate,
          'paid'.translate,
          'unpaid'.translate,
        ].map((e) => DataColumn(label: Text(e, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)))).toList(),
        rows: rows,
      ),
    );
  }

  Widget _buildPaymentPlanWidget(context, paymentData) {
    PaymentModel data = PaymentModel.fromJson(paymentData);
    if (data.aktif == false) return Container();

    List<Widget> children = [];

    children.add(Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('dateofcontract'.translate + ': ', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(data.sozlesmeTarihi!.dateFormat("d-MMM-yy"), style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('startprice'.translate + ': ', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(data.baslangicTutari!.toStringAsFixed(2), style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
            ],
          ),
        ),
        if (data.ekBaslangicTutari != null)
          ...data.ekBaslangicTutari!
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(item.name! + ': ', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(item.value!.toStringAsFixed(2), style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
                    ],
                  ),
                ),
              )
              .toList(),
        (data.indirimler?.length ?? 0) > 0
            ? Column(
                children: data.indirimler!
                    .map(
                      (indirim) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(indirim.name! + ': ', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('-' + indirim.oran.toString() + (indirim.type == 0 ? '%' : ''), style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('contractamount'.translate + ': ', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(data.tutar!.toStringAsFixed(2), style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
            ],
          ),
        ),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: buildDataTable(data)),
      ],
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget current;

    if (isLoading == true) {
      current = const Center(child: CircularProgressIndicator());
    } else if (data == null) {
      current = Center(
        child: EmptyState(text: 'norecords'.translate),
      );
    } else {
      List<Widget> children = [
        const SizedBox(
          height: 12,
        )
      ];
      AppConst.accountingType.forEach((type) {
        if (type == 'custompayment' && data!.containsKey(type)) {
          children.add(_buildCustomPaymentPlanWidget(context, data![type]));
        } else if (data!.containsKey(type)) {
          children.add(Text(
            AppVar.appBloc.schoolInfoService!.singleData!.paymentName(type)!.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText, fontSize: 22),
          ).rounded(background: Fav.design.primaryText.withAlpha(10)));
          children.add(_buildPaymentPlanWidget(context, data![type]));
        }
      });

      current = SingleChildScrollView(
          child: Column(
        children: children,
      ));
    }
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitle(title: 'showpayments'.translate),
      body: Body.child(child: current),
    );
  }
}
