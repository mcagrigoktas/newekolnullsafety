// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../../../helpers/glassicons.dart';
// import '../../timetable/timetablehome.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class TimeTableWidget extends MainWidget {
//   TimeTableWidget() : super([6, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MainController>(
//         id: 'TimeTableWidget',
//         builder: (controller) {
//           print('Update: TimeTableWidget update oldu');
//           return WidgetContainer(
//             closedWidget: Container(
//               decoration: BoxDecoration(
//                   color: Fav.design.others['widget.primaryBackground'],
//                   // gradient: Colors.white.hueGradient,
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xff2C2E60).withOpacity(0.01),
//                       blurRadius: 2,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 0),
//                     ),
//                   ]),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     GlassIcons.timetable.imgUrl,
//                     width: 32,
//                   ),
//                   8.widthBox,
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         'mylessons'.translate.text.color(GlassIcons.timetable.color).fontSize(18).bold.make(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ).p16,
//             ),
//             openWidget: TimeTableHome(),
//             borderRadius: 16,
//           );
//         });
//   }
// }
