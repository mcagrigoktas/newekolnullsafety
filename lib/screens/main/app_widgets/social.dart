// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/srcwidgets/badgewidget.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/glassicons.dart';
// import '../../social/share_social/sharesocial.dart';
// import '../../social/socialitem.dart';
// import '../../social/socialpage.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class SocialWidget extends MainWidget {
//   SocialWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MainController>(
//         id: 'SocialWidget',
//         builder: (controller) {
//           print('Update: SocialWidget update oldu');
//           return WidgetContainer(
//             closedWidget: _WidgetBody(),
//             openWidget: SocialPage(),
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
//     final _itemLength = controller.filteredSocialList.length;
//     Widget current = Container(
//       constraints: BoxConstraints(
//           maxHeight: _itemLength == 0
//               ? 170
//               : _itemLength == 1
//                   ? 200
//                   : 320),
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
//                   GlassIcons.social.imgUrl,
//                   width: 32,
//                 ),
//                 8.widthBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       'social'.translate.text.color(GlassIcons.social.color).fontSize(18).bold.make(),
//                       'socialhint'.translate.text.color(Fav.design.widgetSecondaryText).maxLines(1).make(),
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
//                               decoration: BoxDecoration(
//                                 gradient: const Color(0xffFFECEC).hueGradient,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: SocialItemWidget(
//                                 forWidgetMenu: true,
//                                 item: controller.filteredSocialList[index],
//                                 pageStorageKey: "812218" + _itemLength.toString() + index.toString(),
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
//                         decoration: BoxDecoration(gradient: const Color(0xffffdede).hueGradient, borderRadius: BorderRadius.circular(8), boxShadow: [
//                           BoxShadow(
//                             spreadRadius: 2,
//                             blurRadius: 2,
//                             color: Colors.grey.withAlpha(25),
//                           )
//                         ]),
//                         child: 'sociallistempty'.translate.text.color(Colors.black).bold.make(),
//                       ),
//                     ).px16),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
//             child: Align(alignment: Alignment.topRight, child: ('gopage'.translate + ' >').text.bold.make()),
//           ),
//         ],
//       ),
//     );
// //todo firesotrea gecince newsocial service yapavilirsin
//     if (AppVar.appBloc.socialService?.isFetching == true) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badgeLoading: true,
//         child: current,
//         textColor: Colors.white,
//         badgeLocation: BadgeLocation.topRight,
//         backgroundColor: const Color(0xffEC6767),
//       );
//     } else if (_itemLength != 0) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badge: _itemLength.toString(),
//         child: current,
//         textColor: Colors.white,
//         badgeLocation: BadgeLocation.topRight,
//         backgroundColor: const Color(0xffEC6767),
//       );
//     } else if (AppVar.appBloc.hesapBilgileri.gtMT) {
//       current = BadgeWidget(
//         size: BadgeSize.large,
//         badge: '+',
//         child: current,
//         textColor: const Color(0xffEC6767),
//         badgeLocation: BadgeLocation.topRight,
//         borderColor: const Color(0xffEC6767),
//         backgroundColor: Fav.design.others['widget.primaryBackground'],
//         onTap: () {
//           Fav.to(ShareSocial(
//             previousPageTitle: 'menu1'.translate,
//           ));
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
