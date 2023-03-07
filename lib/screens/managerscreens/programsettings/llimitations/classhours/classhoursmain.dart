// import 'package:elseifekol/appbloc/appvar.dart';
//
// import 'package:mcg_extension/mcg_extension.dart';
//
// import 'package:mypackage/mywidgets.dart';
// import 'package:flutter/material.dart';
//
// import 'classhoursdetail.dart';
// import 'classhourslist.dart';
//
// class ClassHoursMainPage extends StatefulWidget {
//   @override
//   ClassHoursMainPageState createState() {
//     return ClassHoursMainPageState();
//   }
// }
//
// class ClassHoursMainPageState extends State<ClassHoursMainPage> {
//   var isLargeScreen = false;
//   int sayfaTuru = 0; // 10 yeni kayıt.
//   String islemYapilacakKey;
//   var uniqueKey = UniqueKey();
//   var formKey = GlobalKey<FormState>();
//   int pageState = 0; // dik ekran için listemi yada detaymı gözükmeli
//
//   void selectItem(String itemKey) {
//     setState(() {
//       resetPage();
//       islemYapilacakKey = itemKey;
//       pageState = 1;
//     });
//   }
//
//   void resetPage() {
//     setState(() {
//       sayfaTuru = 0;
//       uniqueKey = UniqueKey();
//       formKey = GlobalKey<FormState>();
//       islemYapilacakKey = null;
//       pageState = 0;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 10)).then((_) {
//       if (AppVar.appBloc.schoolTimesService.dataList.isEmpty || AppVar.appBloc.schoolTimesService.dataList.last.activeDays == null) {
//         Get.back();
//         OverAlert.show(type: AlertType.danger, message: 'schooltimeswarning'.translate);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (context.screenWidth > 600) {
//       isLargeScreen = true;
//     } else {
//       isLargeScreen = false;
//     }
//
//     Widget detailWidget = Container(
//         key: uniqueKey,
//         child: ClassHoursDetail(
//           resetPage: resetPage,
//           formKey: formKey,
//           sayfaTuru: sayfaTuru,
//           islemYapilacakKey: islemYapilacakKey,
//         ));
//
//     Widget listWidget = StreamBuilder(
//         initialData: false,
//         stream: AppVar.appBloc.classService.stream,
//         builder: (context, snap) {
//           if (!snap.hasData || snap.data == false) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           return ClassHoursList(sayfaTuru: sayfaTuru, islemYapilacakKey: islemYapilacakKey, onTap: selectItem);
//         });
//
//     return MyScaffold(
//       appBar: MyAppBar(
//         visibleBackButton: true,
//         backButtonPressed: () {
//           if (isLargeScreen || pageState == 0) {
//             Get.back();
//           } else {
//             setState(() {
//               pageState = 0;
//               resetPage();
//             });
//           }
//         },
//         title: "classactivetimes".translate,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 12.0),
//         child: !isLargeScreen
//             ? Container(
//                 child: pageState == 0 ? listWidget : detailWidget,
//               )
//             : Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Expanded(
//                     flex: 1,
//                     child: listWidget,
//                   ),
//                   Expanded(
//                     flex: 4,
//                     child: detailWidget,
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
