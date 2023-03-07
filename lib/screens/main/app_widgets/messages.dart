// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/srcwidgets/badgewidget.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/glassicons.dart';
// import '../../mesagging/chatpreview.dart';
// import '../../mesagging/mesagging_preview_item.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class MessagesWidget extends MainWidget {
//   MessagesWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MainController>(
//         id: 'MessageWidget',
//         builder: (controller) {
//           print('Update: MessageWidget update oldu');
//           return WidgetContainer(
//             closedWidget: _WidgetBody(),
//             openWidget: ChatPreview(),
//           );
//         });
//   }
// }

// //668EE8
// class _WidgetBody extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final _scrollController = ScrollController();
//     final controller = Get.find<MainController>();
//     final _itemLength = controller.filteredMessageList.length;
//     Widget current = Container(
//       constraints: BoxConstraints(
//           maxHeight: _itemLength == 0
//               ? 170
//               : _itemLength == 1
//                   ? 180
//                   : _itemLength == 2
//                       ? 250
//                       : 320),
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
//                   GlassIcons.messagesIcon.imgUrl,
//                   width: 32,
//                 ),
//                 8.widthBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       'messages'.translate.text.color(GlassIcons.messagesIcon.color).fontSize(18).bold.make(),
//                       'messageshint'.translate.text.color(Fav.design.widgetSecondaryText).maxLines(1).make(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Divider(color: Colors.white.withAlpha(150)).pl8.pr16,
//           // 8.height,
//           Expanded(
//               child: _itemLength > 0
//                   ? Scrollbar(
//                       controller: _scrollController,
//                       showTrackOnHover: false,
//                       isAlwaysShown: true,
//                       child: ListView.builder(
//                           shrinkWrap: true,
//                           padding: const EdgeInsets.only(top: 8, bottom: 8),
//                           controller: _scrollController,
//                           itemCount: _itemLength,
//                           //     separatorBuilder: (_, __) => Divider(color: Fav.design.primaryText.withAlpha(15), height: 1),
//                           itemBuilder: (_, index) {
//                             return Container(
//                               margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//                               decoration: BoxDecoration(gradient: const Color(0xffECFFED).hueGradient, borderRadius: BorderRadius.circular(8), boxShadow: [
//                                 BoxShadow(
//                                   spreadRadius: 2,
//                                   blurRadius: 2,
//                                   color: Colors.grey.withAlpha(25),
//                                 )
//                               ]),
//                               child: MessagePreviewItem(
//                                 item: controller.filteredMessageList[index],
//                                 forWidgetMenu: true,
//                                 ghost: false,
//                               ),
//                             );
//                           }),
//                     ).p8
//                   : Container(
//                       alignment: Alignment.center,
//                       child: Container(
//                         height: 40,
//                         width: double.infinity,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           gradient: const Color(0xffD0FFD2).hueGradient,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: 'nonewmessage'.translate.text.color(Colors.black).bold.make(),
//                       ),
//                     ).px16),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
//             child: Align(alignment: Alignment.topRight, child: ('gopage'.translate + ' >').text.bold.make()),
//           ),
//         ],
//       ),
//     );

//     if (AppVar.appBloc.messaggingPreviewService.isFetching) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badgeLoading: true,
//         child: current,
//         textColor: Colors.white,
//         badgeLocation: BadgeLocation.topRight,
//         backgroundColor: const Color(0xff4FB265),
//       );
//     } else if (_itemLength != 0) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badge: _itemLength.toString(),
//         child: current,
//         textColor: Colors.white,
//         badgeLocation: BadgeLocation.topRight,
//         backgroundColor: const Color(0xff4FB265),
//       );
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
