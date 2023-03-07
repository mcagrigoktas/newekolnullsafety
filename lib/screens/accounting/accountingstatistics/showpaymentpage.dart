// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../appbloc/getdataservice.dart';
// import '../../../flavors/mainhelper.dart';
// import '../../../helpers/appfunctions.dart';
// import '../../../helpers/print_and_export_helper.dart';
// import '../../../models/allmodel.dart';

// class ShowPaymentsPage extends StatefulWidget {
//   final bool showdeletedpersonorder;

//   const ShowPaymentsPage({this.showdeletedpersonorder = false});

//   @override
//   _ShowPaymentsPageState createState() => _ShowPaymentsPageState();
// }

// class _ShowPaymentsPageState extends State<ShowPaymentsPage> with AppFunctions {
//   Map _data;
//   bool _isLoading = true;
//   String _paymentTypeKey = 'all';
//   int _kasaNo = 0;
//   String _studentFilter;
//   List<int> _filterDate;

//   List<String> _studentFilterList;
//   @override
//   void initState() {
//     super.initState();

//     GetDataService.dbAllReceipt().once().then((snapshot) {
//       setState(() {
//         _isLoading = false;
//         _data = snapshot.value;
//       });
//     });
//   }

//   void _makeFilter(String filterText) {
//     if (filterText.isEmpty) {
//       _studentFilterList = null;
//       return;
//     }
//     _studentFilterList = [];
//     setState(() {
//       if (filterText.isNotEmpty) {
//         AppVar.appBloc.studentService.dataList.forEach((student) {
//           if (student.name.toLowerCase().contains(filterText)) _studentFilterList.add(student.key);
//         });
//       }
//     });
//   }

//   void _dataCellOnTap(FaturaModel fatura, String key) {}

//   List<dynamic> _buildDataCell(FaturaModel fatura, String key, {bool forExcel = false}) {
//     return [
//       key.replaceAll('fatura', ''),
//       AppFunctions2.whatIsThisName(fatura.personKey, onlyStudent: true) ?? whatIsThisErasedItem(fatura.personKey, additionalItem: '*') ?? 'erasedstudent'.translate,
//       AppVar.appBloc.schoolInfoService.singleData.paymentName(fatura.paymentTypeKey),
//       fatura.paymentName,
//       forExcel ? fatura.tutar : fatura.tutar.toStringAsFixed(2),
//       DateFormat("d-MMM-yy").format(DateTime.fromMillisecondsSinceEpoch(fatura.tarih)),
//       AppVar.appBloc.schoolInfoService.singleData.caseName(fatura.kasaNo),
//       fatura.aktif == false ? 'canceled'.translate : '',
//     ];
//   }

//   PrintAndExportModel _buildData({bool forExcel = false}) {
//     List<List<dynamic>> rows = [];
//     var total = 0.0;
//     _data.forEach((key, value) {
//       final fatura = FaturaModel.fromJson(value, key);
//       final studentName = AppFunctions2.whatIsThisName(fatura.personKey, onlyStudent: true);

//       if ((widget.showdeletedpersonorder == false && studentName != null) || (widget.showdeletedpersonorder == true && studentName == null)) {
//         if ((_kasaNo == 0 || fatura.kasaNo == _kasaNo) && (_paymentTypeKey == 'all' || _paymentTypeKey == fatura.paymentTypeKey)) {
//           if (_studentFilterList == null || _studentFilterList.contains(fatura.personKey)) {
//             if (_filterDate == null || (fatura.tarih >= _filterDate.first && fatura.tarih <= _filterDate.last)) {
//               if (fatura.aktif != false) total += fatura.tutar ?? 0.0;
//               rows.add(_buildDataCell(fatura, key, forExcel: forExcel));
//             }
//           }
//           // if (_studentFilter.safeLength < 1 || _studentFilter == fatura.personKey) {
//           //   if (fatura.aktif != false) total += fatura.tutar ?? 0.0;
//           //   rows.add(_buildDataCell(fatura, key));
//           // }
//         }
//       }
//     });

//     rows.sort((i1, i2) {
//       int i1data = int.tryParse(i1.first) ?? 0;
//       int i2data = int.tryParse(i2.first) ?? 0;
//       return i1data.compareTo(i2data);
//     });
//     rows.add(['', "total".translate, '', '', forExcel ? total : total.toStringAsFixed(2), '', '', '']);
//     return PrintAndExportModel(columnNames: [
//       'orderno'.translate,
//       'name'.translate,
//       'paymenttype'.translate,
//       'paymentname'.translate,
//       'paid'.translate,
//       'date'.translate,
//       'casenumber'.translate,
//       'state'.translate,
//     ], rows: rows);
//   }

//   Widget _buildDataTable() {
//     final _data = _buildData(forExcel: false);
//     return MyDataTable(data: [_data.stringListColumnNames, ..._data.stringListRows], maxWidth: 250);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _topBar = TopBar(leadingTitle: 'menu1'.translate, trailingActions: [
//       MyPopupMenuButton(
//           child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
//           onSelected: (value) {
//             if (value == 1) {
//               ///Get  ayni isimlilleri acarken zorluk yasiyordu
//               Fav.to(SizedBox(key: GlobalKey(), child: const ShowPaymentsPage(showdeletedpersonorder: true)));
//             } else if (value == 2) {
//               PrintAndExportHelper.printPdf(data: _buildData(forExcel: false), pdfHeaderName: 'showpayments'.translate);

//               //   PrintAccounting.printShowPayments(_buildData());
//             } else if (value == 3) {
//               PrintAndExportHelper.exportToExcel(data: _buildData(forExcel: true), excelName: 'showpayments'.translate);
//               // ExportHelper.export(_buildData(), 'showpayments'.translate);
//             }
//           },
//           itemBuilder: (context) {
//             return [
//               if (widget.showdeletedpersonorder == false) PopupMenuItem(value: 1, child: Text('showdeletedpersonorder'.translate, style: TextStyle(color: Fav.design.primaryText))),
//               PopupMenuItem(value: 2, child: Text(Words.print, style: TextStyle(color: Fav.design.primaryText))),
//               PopupMenuItem(value: 3, child: Text('exportexcell'.translate, style: TextStyle(color: Fav.design.primaryText))),
//             ];
//           })
//     ]);
//     final _topActions = TopActionsTitleWithChild(
//         childIsPinned: true,
//         title: TopActionsTitle(title: 'showpayments'.translate),
//         child: _isLoading || _data == null
//             ? SizedBox()
//             : Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: MyDropDown(
//                           name: 'paymenttype'.translate,
//                           items: AppConst.accountingType.map((paymentType) => DropdownMenuItem(child: Text(AppVar.appBloc.schoolInfoService.singleData.paymentName(paymentType)), value: paymentType)).toList()..add(DropdownMenuItem(child: Text('all'.translate), value: 'all')),
//                           onChanged: (value) {
//                             setState(() {
//                               _paymentTypeKey = value;
//                             });
//                           },
//                           value: _paymentTypeKey,
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           alignedDropdown: true,
//                           isExpanded: true,
//                           canvasColor: Fav.design.scaffold.background,
//                           textColor: Fav.design.primaryText,
//                         ),
//                       ),
//                       Expanded(
//                         child: MyDropDown(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           isExpanded: true,
//                           name: 'casenumber'.translate,
//                           items: Iterable.generate(10)
//                               .map((i) => DropdownMenuItem(
//                                     value: i,
//                                     child: Text(i == 0 ? 'all'.translate : AppVar.appBloc.schoolInfoService.singleData.caseName(i)),
//                                   ))
//                               .toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _kasaNo = value;
//                             });
//                           },
//                           value: _kasaNo,
//                         ),
//                       ),
//                       Expanded(
//                         child: MyDateRangePicker(
//                           showResetButton: true,
//                           padding: const EdgeInsets.all(2),
//                           firstDate: DateTime.now().subtract(const Duration(days: 730)),
//                           lastDate: DateTime.now().add(const Duration(days: 730)),
//                           //    name: 'date'.translate,
//                           onChanged: (value) {
//                             setState(() {
//                               _filterDate = value;
//                             });
//                           },
//                         ),
//                       )
//                     ],
//                   ),
//                   if (widget.showdeletedpersonorder == false)
//                     CupertinoSearchTextField(
//                       style: TextStyle(color: Fav.design.primaryText),
//                       onChanged: (value) {
//                         _makeFilter(value.toLowerCase());
//                       },
//                     )
//                 ],
//               ));

//     final _body = _isLoading
//         ? Body.child(child: MyProgressIndicator(isCentered: true))
//         : _data == null
//             ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
//             : Body.child(child: Align(alignment: Alignment.topCenter, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildDataTable())));

//     return AppScaffold(
//       topBar: _topBar,
//       topActions: _topActions,
//       body: _body,
//     );
//   }
// }
