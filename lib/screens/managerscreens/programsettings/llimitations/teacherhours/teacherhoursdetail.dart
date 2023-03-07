// import 'package:elseifekol/appbloc/appvar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';
// import 'package:elseifekol/appbloc/getdataservice.dart';
// import 'package:elseifekol/appbloc/setdataservice.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class TeacherHoursDetail extends StatefulWidget {
//   final int sayfaTuru;
//   final String islemYapilacakKey;
//   final GlobalKey<FormState> formKey;
//   final Function resetPage;
//   TeacherHoursDetail({this.islemYapilacakKey, this.sayfaTuru, this.formKey, this.resetPage});
//
//   @override
//   TeacherHoursDetailState createState() {
//     return TeacherHoursDetailState();
//   }
// }
//
// // TeacherType 1: Sınıf 2. Branş
// class TeacherHoursDetailState extends State<TeacherHoursDetail> with SingleTickerProviderStateMixin {
//   Map _data;
//   bool isLoading = false;
//   bool isloadingFetchData = true;
//
//   String timeToString(value) => '${(value ?? 0) ~/ 60}'.padLeft(2, '0') + ':' + '${(value ?? 0) % 60}'.padLeft(2, '0');
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.islemYapilacakKey != null) {
//       GetDataService.dbGetTeacherWorkTimes(widget.islemYapilacakKey).once().then((snap) {
//         setState(() {
//           _data = snap.value;
//           isloadingFetchData = false;
//           _data ??= {};
//         });
//       });
//     }
//   }
//
//   void submit() {
//     if (Fav.noConnection()) return;
//
//     setState(() {
//       isLoading = true;
//     });
//     SetDataService.saveTeacherWorkTimes(_data, widget.islemYapilacakKey).then((a) {
//       widget.resetPage();
//       OverAlert.saveSuc();
//     }).catchError((error) {
//       setState(() {
//         isLoading = false;
//       });
//       OverAlert.show(message: "saveerruser".translate, type: AlertType.danger);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.islemYapilacakKey == null) {
//       return EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST);
//     }
//     if (isloadingFetchData) {
//       return MyProgressIndicator(
//         isCentered: true,
//       );
//     }
//     return Form(
//       key: widget.formKey,
//       child: Center(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 children: <Widget>[
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Row(children: <Widget>[
//                         Container(
//                           width: 50,
//                           height: 35,
//                           //   decoration: BoxDecoration(border: Border.all(color:  Fav.design.primaryText.withAlpha(20),width: 0.5)),
//                           alignment: Alignment.center,
//                           //      child: Text(  'weekdays'),style: TextStyle(color:  Fav.design.accentText,fontWeight: FontWeight.bold),),
//                         ),
//                         for (var i = 1; i < AppVar.appBloc.schoolTimesService.dataList.last.weekdaysLessonCount + 1; i++)
//                           Container(
//                             width: 40,
//                             height: 35,
//                             decoration: BoxDecoration(border: Border.all(color: Fav.design.primaryText.withAlpha(20), width: 0.5)),
//                             alignment: Alignment.center,
//                             child: Column(
//                               children: <Widget>[
//                                 Text(
//                                   '$i',
//                                   style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   '${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekdaysLessonTimes[i - 1].first ?? 0)}',
//                                   style: TextStyle(color: Fav.design.primaryText, fontSize: 5.5),
//                                 ),
//                                 Text(
//                                   '${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekdaysLessonTimes[i - 1].last ?? 0)}',
//                                   style: TextStyle(color: Fav.design.primaryText, fontSize: 5.5),
//                                 ),
//                               ],
//                             ),
//                           )
//                       ]),
//                       ...[1, 2, 3, 4, 5].map((day) {
//                         final dayName = DateFormat('EEE').format(DateTime(2019, 7, day));
//                         return Row(
//                           children: <Widget>[
//                             Container(
//                               width: 50,
//                               height: 30,
//                               decoration: BoxDecoration(border: Border.all(color: Fav.design.primaryText.withAlpha(20), width: 0.5)),
//                               alignment: Alignment.center,
//                               child: Text(
//                                 dayName,
//                                 style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             for (var i = 1; i < AppVar.appBloc.schoolTimesService.dataList.last.weekdaysLessonCount + 1; i++)
//                               GestureDetector(
//                                   onTap: () {
//                                     if (AppVar.appBloc.schoolTimesService.dataList.last.activeDays.contains(day.toString()) == false) {
//                                       return;
//                                     }
//                                     setState(() {
//                                       _data['id$day-$i'] = !(_data['id$day-$i'] ?? false);
//                                     });
//                                   },
//                                   child: Container(
//                                     width: 40,
//                                     height: 30,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(color: Fav.design.primaryText.withAlpha(120), width: 0.5), color: AppVar.appBloc.schoolTimesService.dataList.last.activeDays.contains(day.toString()) ? (_data['id$day-$i'] == true ? Colors.greenAccent : Colors.redAccent) : Colors.grey),
//                                     alignment: Alignment.center,
//                                   ))
//                           ],
//                         );
//                       }).toList(),
//                       8.height,
//                       Row(children: <Widget>[
//                         Container(
//                           width: 50,
//                           height: 35,
//                           //    decoration: BoxDecoration(border: Border.all(color:  Fav.design.primaryText.withAlpha(20),width: 0.5)),
//                           alignment: Alignment.center,
//                           //  child: Text(  'weekends'),style: TextStyle(color:  Fav.design.accentText,fontSize:8,fontWeight: FontWeight.bold),),
//                         ),
//                         for (var i = 1; i < AppVar.appBloc.schoolTimesService.dataList.last.weekendLessonCount + 1; i++)
//                           Container(
//                             width: 40,
//                             height: 35,
//                             decoration: BoxDecoration(border: Border.all(color: Fav.design.primaryText.withAlpha(20), width: 0.5)),
//                             alignment: Alignment.center,
//                             child: Column(
//                               children: <Widget>[
//                                 Text(
//                                   '$i',
//                                   style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   '${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekendsLessonTimes[i - 1].first ?? 0)}',
//                                   style: TextStyle(color: Fav.design.primaryText, fontSize: 5.5),
//                                 ),
//                                 Text(
//                                   '${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekendsLessonTimes[i - 1].last ?? 0)}',
//                                   style: TextStyle(color: Fav.design.primaryText, fontSize: 5.5),
//                                 ),
//                               ],
//                             ),
//                           )
//                       ]),
//                       ...[6, 7].map((day) {
//                         final dayName = DateFormat('EEE').format(DateTime(2019, 7, day));
//                         return Row(
//                           children: <Widget>[
//                             Container(
//                               width: 50,
//                               height: 30,
//                               decoration: BoxDecoration(border: Border.all(color: Fav.design.primaryText.withAlpha(20), width: 0.5)),
//                               alignment: Alignment.center,
//                               child: Text(
//                                 dayName,
//                                 style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             for (var i = 1; i < AppVar.appBloc.schoolTimesService.dataList.last.weekendLessonCount + 1; i++)
//                               GestureDetector(
//                                   onTap: () {
//                                     if (AppVar.appBloc.schoolTimesService.dataList.last.activeDays.contains(day.toString()) == false) {
//                                       return;
//                                     }
//                                     setState(() {
//                                       _data['id$day-$i'] = !(_data['id$day-$i'] ?? false);
//                                     });
//                                   },
//                                   child: Container(
//                                     width: 40,
//                                     height: 30,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(color: Fav.design.primaryText.withAlpha(120), width: 0.5), color: AppVar.appBloc.schoolTimesService.dataList.last.activeDays.contains(day.toString()) ? (_data['id$day-$i'] == true ? Colors.greenAccent : Colors.redAccent) : Colors.grey),
//                                     alignment: Alignment.center,
//                                   ))
//                           ],
//                         );
//                       }).toList()
//                     ],
//                   ),
//                   16.height,
//                   Padding(
//                     padding: const EdgeInsets.only(right: 16.0),
//                     child: MyProgressButton(
//                       onPressed: submit,
//                       label: Words.save,
//                       isLoading: isLoading,
//                     ),
//                   ),
//                 ],
//               )),
//         ),
//       ),
//     );
//   }
// }
