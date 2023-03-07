// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../appbloc/getdataservice.dart';
// import '../../../flavors/mainhelper.dart';
// import '../../../helpers/print_and_export_helper.dart';
// import '../../../models/allmodel.dart';

// class MonthlyStatistics extends StatefulWidget {
//   MonthlyStatistics();

//   @override
//   _MonthlyStatisticsState createState() => _MonthlyStatisticsState();
// }

// class MonthlyData {
//   final String studentName;
//   final String paymentName;
//   final int tarih;
//   final double tutar;
//   final double odenenTutar;
//   final String studentKey;

//   final int month;
//   String get tarihText => tarih == null ? '' : tarih.dateFormat("d-MMM-yyyy");

//   MonthlyData({this.studentName, this.paymentName, this.tutar, this.studentKey, this.tarih, this.odenenTutar, this.month});
// }

// class _MonthlyStatisticsState extends State<MonthlyStatistics> {
//   // int month = DateTime.now().month;
//   List<int> _months = [DateTime.now().month];

//   String _paymentTypeKey = 'all';
//   Map _data;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     if (DateTime.now().millisecondsSinceEpoch - Fav.readSeasonCache<int>('readaccountingstatisticstime', 0) < const Duration(minutes: 10).inMilliseconds && Fav.readSeasonCache<Map>('readlastaccountingstatistics', {}) != null) {
//       _data = Fav.readSeasonCache<Map>('readlastaccountingstatistics', {});
//       _statisticsCalc();
//       _isLoading = false;
//     } else {
//       GetDataService.dbAllStudentAccountingData().once().then((snap) {
//         setState(() {
//           _data = snap.value;
//           _statisticsCalc();
//           _isLoading = false;
//           Fav.writeSeasonCache('readaccountingstatisticstime', DateTime.now().millisecondsSinceEpoch);
//           Fav.writeSeasonCache('readlastaccountingstatistics', _data);
//         });
//       });
//     }

//     super.initState();
//   }

//   void _makeFilter() {
//     if (_paymentTypeKey == 'all') {
//       _filteredMonthlyData = _monthlyData;
//     } else {
//       _filteredMonthlyData = _monthlyData.where((element) => (element.paymentName == _paymentTypeKey)).toList();
//     }
//   }

//   final List<MonthlyData> _monthlyData = [];
//   List<MonthlyData> _filteredMonthlyData = [];
//   void _statisticsCalc() {
//     _monthlyData.clear();
//     _data.forEach((studentKey, allPaymentList) {
//       var _student = AppVar.appBloc.studentService.dataListItem(studentKey);

//       ///todo silinmis  ogrenciye ait faturalainda gozukmesini istyiorasn  burayi ac
//       //  if (student == null) student = Student()..name =  'erasedstudent');
//       if (allPaymentList['PaymentPlans'] != null && _student != null) {
//         (allPaymentList['PaymentPlans'] as Map).forEach((paymentName, paymentValues) {
//           if (paymentName == 'custompayment') {
//             (paymentValues as Map).forEach((paymentKey, paymentValue) {
//               TaksitModel payment = TaksitModel.fromJson(paymentValue);
//               final double odennenTutar = (payment.odemeler?.fold(0, (t, v) => t + v.miktar) ?? 0);

//               if (payment.aktif != false
// //                && odennenTutar < payment.tutar
//                   ) {
//                 _monthlyData.add(MonthlyData(
//                   studentName: _student.name,
//                   studentKey: studentKey,
//                   paymentName: payment.name,
//                   tutar: payment.tutar.toDouble(),
//                   tarih: payment.tarih,
//                   odenenTutar: odennenTutar,
//                   month: DateTime.fromMillisecondsSinceEpoch(payment.tarih).month,
//                 ));
//               }
//             });
//           } else {
//             var _realPaymentName = AppVar.appBloc.schoolInfoService.singleData.paymentName(paymentName);

//             PaymentModel _payments = PaymentModel.fromJson(paymentValues);

//             if (_payments.aktif != false) {
//               final List<TaksitModel> paymentList = [];
//               if (_payments.pesinUcret != null) {
//                 paymentList.add(_payments.pesinUcret);
//               }
//               if (_payments.pesinat != null) {
//                 paymentList.add(_payments.pesinat);
//               }
//               if (_payments.taksitler != null) {
//                 paymentList.addAll(_payments.taksitler);
//               }

//               paymentList.forEach((payment) {
//                 if ((payment.tutar ?? 0) != 0) {
//                   final double odennenTutar = (payment.odemeler?.fold(0, (t, v) => t + v.miktar) ?? 0);

//                   if (payment.aktif != false
//                       //   && odennenTutar < payment.tutar
//                       ) {
//                     _monthlyData.add(MonthlyData(
//                       studentName: _student.name,
//                       studentKey: studentKey,
//                       paymentName: _realPaymentName,
//                       tutar: payment.tutar.toDouble(),
//                       tarih: payment.tarih,
//                       odenenTutar: odennenTutar,
//                       month: DateTime.fromMillisecondsSinceEpoch(payment.tarih).month,
//                     ));
//                   }
//                 }
//               });
//             }
//           }
//         });
//       }
//     });
//     _monthlyData.removeWhere((item) {
//       if (_months.contains(0)) return false;
//       return !_months.contains(item.month);
//     });
//     _monthlyData.sort((a, b) {
//       if (a.studentName == b.studentName) return a.month - b.month;
//       return a.studentName.compareTo(b.studentName);
//     });
//     double _odenenTutar = _monthlyData.fold(0.0, (t, v) => t + v.odenenTutar);
//     double _tutar = _monthlyData.fold(0.0, (t, v) => t + v.tutar);

//     _monthlyData.insert(0, MonthlyData(month: 0, odenenTutar: _odenenTutar, studentName: 'total'.translate, tarih: null, tutar: _tutar, paymentName: ''));

//     _makeFilter();
//   }

//   PrintAndExportModel _prepareExportData({bool forExcel}) {
//     return PrintAndExportModel(columnNames: [
//       'name'.translate,
//       'paymenttype'.translate,
//       'date'.translate,
//       'paid'.translate,
//       'quantity'.translate,
//     ], rows: _filteredMonthlyData.map<List<dynamic>>((e) => [e.studentName, e.paymentName, e.tarihText, forExcel ? e.odenenTutar : e.odenenTutar.toStringAsFixed(1), forExcel ? e.tutar : e.tutar.toStringAsFixed(1)]).toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _topBar = TopBar(leadingTitle: 'menu1'.translate);

//     if (_isLoading) {
//       return AppScaffold(topBar: _topBar, topActions: TopActionsTitle(title: 'accountingstatitictype1'.translate), body: Body.child(child: MyProgressIndicator(isCentered: true)));
//     }

//     final _body = Body.listviewBuilder(
//       maxWidth: 800,
//       itemCount: _filteredMonthlyData.length,
//       itemBuilder: (context, index) {
//         return Container(
//           decoration: BoxDecoration(
//               color: index.isOdd ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150), border: index != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
//           child: StatisticsTile(
//             pastData: _filteredMonthlyData[index],
//           ),
//         );
//       },
//     );

//     final _topActions = TopActionsTitleWithChild(
//         title: TopActionsTitle(title: 'accountingstatitictype1'.translate),
//         childIsPinned: true,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: MyDropDown(
//                     name: 'paymenttype'.translate,
//                     items: AppConst.accountingType.map((paymentType) {
//                       final _realPaymentName = AppVar.appBloc.schoolInfoService.singleData.paymentName(paymentType);
//                       return DropdownMenuItem(child: Text(_realPaymentName), value: _realPaymentName);
//                     }).toList()
//                       ..add(DropdownMenuItem(child: Text('all'.translate), value: 'all')),
//                     onChanged: (value) {
//                       setState(() {
//                         _paymentTypeKey = value;
//                         _makeFilter();
//                       });
//                     },
//                     value: _paymentTypeKey,
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     alignedDropdown: true,
//                     isExpanded: true,
//                     canvasColor: Fav.design.scaffold.background,
//                     textColor: Fav.design.primaryText,
//                   ),
//                 ),
//                 Expanded(
//                   child: MyMultiSelect(
//                     title: 'month'.translate,
//                     name: 'month'.translate,
//                     initialValue: _months.map((e) => e.toString()).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         if (value == null) _months = [];
//                         _months = List<int>.from(value.map((e) => int.parse(e)).toList());
//                         //    month = value;
//                         _statisticsCalc();
//                       });
//                     },
//                     context: context,
//                     items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((item) => MyMultiSelectItem(item.toString(), DateFormat("MMMM").format(DateTime(2019, item)))).toList()..insert(0, MyMultiSelectItem('0', 'all'.translate)),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: context.screenWidth < 800 ? 0 : (context.screenWidth - 800) / 2,
//               ),
//               child: Row(
//                 children: <Widget>[
//                   8.width,
//                   Expanded(child: 'name'.translate.text.bold.fontSize(18).make()),
//                   'paid'.translate.text.color(Fav.design.accentText).make(),
//                   ('/' + 'quantity'.translate).translate.text.color(Fav.design.accentText).bold.make(),
//                   8.width,
//                 ],
//               ).py4,
//             ),
//           ],
//         ));

//     final _bottomBar = BottomBar(
//         child: Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         MyMiniRaisedButton(
//           text: Words.print,
//           onPressed: () {
//             PrintAndExportHelper.printPdf(
//               data: _prepareExportData(forExcel: false),
//               pdfHeaderName: 'accountingstatitictype1'.translate,
//             );
//           },
//           iconData: Icons.print,
//         ),
//         16.width,
//         MyMiniRaisedButton(
//           text: 'exportexcell'.translate,
//           onPressed: () {
//             PrintAndExportHelper.exportToExcel(
//               excelName: 'accountingstatitictype1'.translate,
//               data: _prepareExportData(forExcel: true),
//             );
//             //  ExportHelper.export(_prepareExportData(forExcel: true), 'accountingstatistics'.translate);
//           },
//           iconData: Icons.print,
//         ),
//         16.width,
//       ],
//     ));

//     return AppScaffold(
//       topBar: _topBar,
//       body: _body,
//       bottomBar: _bottomBar,
//       topActions: _topActions,
//     );
//   }
// }

// class StatisticsTile extends StatelessWidget {
//   final MonthlyData pastData;

//   StatisticsTile({this.pastData});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//         title: Text(pastData.studentName, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
//         subtitle: Text(pastData.paymentName + ' ${pastData.tarihText}', style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Text(pastData.odenenTutar.toStringAsFixed(2), style: TextStyle(color: Fav.design.accentText)),
//             Text(
//               ' / ' + pastData.tutar.toStringAsFixed(2),
//               style: TextStyle(color: Fav.design.accentText, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ));
//   }
// }
