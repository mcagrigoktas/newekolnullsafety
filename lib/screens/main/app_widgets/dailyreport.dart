// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/srcwidgets/badgewidget.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/glassicons.dart';
// import '../../dailyreport/dailyreport.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class DailyReportWidget extends MainWidget {
//   DailyReportWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MainController>(
//         id: 'DailyReportWidget',
//         builder: (controller) {
//           print('Update: DailyReportWidget  update oldu');
//           return WidgetContainer(
//             closedWidget: _WidgetBody(),
//             openWidget: DailyReportPage(),
//           );
//         });
//   }
// }

// //668EE8
// class _WidgetBody extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MainController>();
//     Widget current = Container(
//       constraints: const BoxConstraints(maxHeight: 170),
//       decoration: BoxDecoration(
//           color: Fav.design.others['widget.primaryBackground'],
//           // gradient: Colors.white.hueGradient,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xff2C2E60).withOpacity(0.01),
//               blurRadius: 2,
//               spreadRadius: 2,
//               offset: const Offset(0, 0),
//             ),
//           ]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   GlassIcons.dailyReport.imgUrl,
//                   width: 32,
//                 ),
//                 8.widthBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       'dailyreport'.translate.text.color(GlassIcons.dailyReport.color).fontSize(18).bold.make(),
//                       'dailyreporthint'.translate.text.color(Fav.design.widgetSecondaryText).maxLines(1).make(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Divider(color: Colors.white.withAlpha(150)).pl8.pr16,
//           // 8.height,
//           Expanded(
//               child: Container(
//             alignment: Alignment.center,
//             child: Container(
//               height: 40,
//               width: double.infinity,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(gradient: const Color(0xffB1CCF3).hueGradient, borderRadius: BorderRadius.circular(8)),
//               child: AppVar.appBloc.hesapBilgileri.gtMT
//                   ? 'makenewshares'.translate.text.color(Colors.black).bold.make()
//                   : controller.dailyReportDataReceived
//                       ? 'thereisnewsharing'.translate.text.color(Colors.black).bold.make()
//                       : 'nonewsharing'.translate.text.color(Colors.black).bold.make(),
//             ),
//           ).px16),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
//             child: Align(alignment: Alignment.topRight, child: ('gopage'.translate + ' >').text.bold.make()),
//           ),
//         ],
//       ),
//     );

//     if (AppVar.appBloc.hesapBilgileri.gtS) {
//       if (AppVar.appBloc.dailyReportService.isFetching) {
//         current = BadgeWidget(
//           size: BadgeSize.large,
//           badgeLoading: true,
//           child: current,
//           badgeLocation: BadgeLocation.topRight,
//         );
//       } else if (controller.dailyReportDataReceived) {
//         current = BadgeWidget(
//           size: BadgeSize.large,
//           badge: '1',
//           child: current,
//           badgeLocation: BadgeLocation.topRight,
//         );
//       }
//     }

//     if (isWeb) {
//       current = MouseRegion(
//         child: current,
//         cursor: SystemMouseCursors.click,
//       );
//     }

//     return current.p2;
//   }
// }
