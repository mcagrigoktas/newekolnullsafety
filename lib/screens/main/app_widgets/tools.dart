// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../../../helpers/glassicons.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class ToolsWidget extends MainWidget {
//   ToolsWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return WidgetContainer(
//       closedWidget: _WidgetBody(),
//       openWidget: null,
//     );
//   }
// }

// //668EE8
// class _WidgetBody extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final _controller = Get.find<MainController>();
//     Widget current = Container(
//       constraints: const BoxConstraints(maxHeight: 170),
//       decoration: BoxDecoration(color: Fav.design.others['widget.primaryBackground'], borderRadius: BorderRadius.circular(24), boxShadow: [
//         BoxShadow(
//           color: const Color(0xff2C2E60).withOpacity(0.01),
//           blurRadius: 2,
//           spreadRadius: 2,
//           offset: const Offset(0, 0),
//         ),
//       ]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(GlassIcons.tag.imgUrl, width: 32),
//                 8.widthBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       'tools'.translate.text.color(GlassIcons.tag.color).fontSize(18).bold.make(),
//                       'toolshint'.translate.text.color(Fav.design.widgetSecondaryText).maxLines(1).make(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           10.heightBox,
//           Expanded(
//               child: Center(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 //    children: [..._controller.toolsWidget.map((e) => e.px8).toList()],
//               ),
//             ),
//           ).px16),
//           16.heightBox,
//         ],
//       ),
//     );

//     // if (isWeb) {
//     //   current = MouseRegion(
//     //     child: current,
//     //     cursor: SystemMouseCursors.click,
//     //   );
//     // }

//     return current.p2;
//   }
// }
