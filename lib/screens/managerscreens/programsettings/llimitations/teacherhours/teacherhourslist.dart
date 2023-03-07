// import 'package:elseifekol/appbloc/appvar.dart';
// import 'package:elseifekol/models/allmodel.dart';
// import 'package:flutter/material.dart';
// import 'package:mypackage/mywidgets.dart';
// import 'package:mcg_extension/mcg_extension.dart';
//
// class TeacherHoursList extends StatefulWidget {
//   final int sayfaTuru;
//   final String islemYapilacakKey;
//   final Function onTap;
//
//   TeacherHoursList({this.sayfaTuru, this.islemYapilacakKey, this.onTap});
//
//   @override
//   TeacherHoursListState createState() {
//     return TeacherHoursListState();
//   }
// }
//
// class TeacherHoursListState extends State<TeacherHoursList> {
//   String filterText = "";
//
//   void onFilterChanged(String text) {
//     setState(() {
//       filterText = text.toLowerCase();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Teacher> filteredList = AppVar.appBloc.teacherService.dataList.where((teacher) => teacher.getSearchText.contains(filterText ?? "")).toList();
//
//     bool islargeScreen = context.screenWidth > 600;
//     return Column(children: [
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: islargeScreen ? 12.0 : 24.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(flex: 1, child: MySearchBar(onChanged: onFilterChanged)),
//             4.width,
//             Container(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                 decoration: ShapeDecoration(color: Fav.design.customDesign4.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
//                 child: Text(
//                   "${filteredList.length}",
//                   style: const TextStyle(color: Colors.white),
//                 )),
//           ],
//         ),
//       ),
//       filteredList.isNotEmpty
//           ? Expanded(
//               flex: 1,
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: islargeScreen ? 8.0 : 16.0),
//                 itemCount: filteredList.length,
//                 itemBuilder: (context, index) {
//                   var item = filteredList[index];
//                   return MyListTile(
//                     islargeScreen: islargeScreen,
//                     onTap: () {
//                       widget.onTap(item.key);
//                     },
//                     title: item.name,
//                     isSelected: widget.islemYapilacakKey == item.key,
//                     imgUrl: item.imgUrl,
//                   );
//                 },
//               ),
//             )
//           : EmptyState(
//               imgWidth: 50,
//             ),
//     ]);
//   }
// }
