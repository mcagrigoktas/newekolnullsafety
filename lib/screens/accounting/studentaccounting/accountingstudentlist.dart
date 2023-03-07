// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../models/allmodel.dart';

// // class AccountingStudentList extends StatefulWidget {
// //   final String islemYapilacakKey;
// //   final Function onTap;
// //   final String initialFilterText;
// //   final bool showErasedStudent;

// //   AccountingStudentList({this.islemYapilacakKey, this.onTap, this.initialFilterText, this.showErasedStudent = false});

// //   @override
// //   AccountingStudentListState createState() {
// //     return AccountingStudentListState();
// //   }
// // }

// class AccountingStudentListState extends State<AccountingStudentList> {
//   String filterText = "";

//   @override
//   void initState() {
//     filterText = widget.initialFilterText;
//     super.initState();
//   }

//   void onFilterChanged(String text) {
//     setState(() {
//       filterText = text.toLowerCase();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       filteredList.isNotEmpty
//           ? Expanded(
//               flex: 1,
//               child: ListView.builder(
//                 key: const PageStorageKey('accountingstudentlist'),
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
//                     imgUrl: item.imgUrl,
//                     isSelected: widget.islemYapilacakKey == item.key,
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
