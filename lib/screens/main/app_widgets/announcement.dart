// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/srcwidgets/badgewidget.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/glassicons.dart';
// import '../../announcements/announcementitem.dart';
// import '../../announcements/announcementspage.dart';
// import '../../announcements/shareannouncements.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class AnnouncementWidget extends MainWidget {
//   AnnouncementWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MainController>(
//         id: 'AnnouncementWidget',
//         builder: (controller) {
//           print('Update: Announcement widget update oldu');
//           return WidgetContainer(
//             closedWidget: _WidgetBody(),
//             openWidget: AnnouncementsPage(),
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
//     final _itemLength = controller.filteredAnnouncementList.length;
//     Widget current = Container(
//       constraints: BoxConstraints(
//           maxHeight: _itemLength == 0
//               ? 170
//               : _itemLength == 1
//                   ? 240
//                   : _itemLength == 2
//                       ? 350
//                       : 460),
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
//                   GlassIcons.announcementIcon.imgUrl,
//                   width: 32,
//                 ),
//                 8.widthBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       'announcements'.translate.text.color(GlassIcons.announcementIcon.color).fontSize(18).bold.make(),
//                       'announcementshint'.translate.text.color(Fav.design.widgetSecondaryText).maxLines(1).make(),
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
//                               decoration: BoxDecoration(gradient: const Color(0xffFFEFDB).hueGradient, borderRadius: BorderRadius.circular(8), boxShadow: [
//                                 BoxShadow(
//                                   spreadRadius: 2,
//                                   blurRadius: 2,
//                                   color: Colors.grey.withAlpha(25),
//                                 )
//                               ]),
//                               child: AnnouncementItem(announcement: controller.filteredAnnouncementList[index], forWidgetMenu: true),
//                             );
//                           }),
//                     ).p8
//                   : Container(
//                       alignment: Alignment.center,
//                       child: Container(
//                         height: 40,
//                         width: double.infinity,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(gradient: const Color(0xffFFEFDB).hueGradient, borderRadius: BorderRadius.circular(8)),
//                         child: 'announcementempty'.translate.text.color(Colors.black).bold.make(),
//                       ),
//                     ).px16),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
//             child: Align(alignment: Alignment.topRight, child: ('gopage'.translate + ' >').text.bold.make()),
//           ),
//         ],
//       ),
//     );

//     if (AppVar.appBloc.announcementService.isFetching) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badgeLoading: true,
//         child: current,
//         badgeLocation: BadgeLocation.topRight,
//       );
//     } else if (_itemLength != 0) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badge: _itemLength.toString(),
//         child: current,
//         badgeLocation: BadgeLocation.topRight,
//       );
//     } else if (AppVar.appBloc.hesapBilgileri.gtMT) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badge: '+',
//         child: current,
//         badgeLocation: BadgeLocation.topRight,
//         borderColor: const Color(0xffDA9B52),
//         textColor: const Color(0xffDA9B52),
//         backgroundColor: Fav.design.others['widget.primaryBackground'],
//         onTap: () async {
//           var result = await Fav.to(ShareAnnouncements(previousPageTitle: 'menu1'.translate));
//           if (result == true) OverAlert.saveSuc();
//         },
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
