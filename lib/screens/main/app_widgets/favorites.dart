// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../../../helpers/glassicons.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class FavoritesWidget extends MainWidget {
//   FavoritesWidget() : super(Fav.preferences.getInt('favoriteswidgettype', 2) == 1 ? [12, 6, 4] : [12, 12, 12], [0, 0, 0]);
//   @override
//   Widget build(BuildContext context) {
//     if (Fav.preferences.getInt('favoriteswidgettype', 1) == 0) return const SizedBox();
//     final controller = Get.find<MainController>();
//     if (controller.favoriteList.isEmpty) return const SizedBox();
//     return Container(
//       // margin: EdgeInsets.only(top: context.screenTopPadding + 24, left: 16),
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
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   GlassIcons.favorite.imgUrl,
//                   width: 32,
//                 ),
//                 8.widthBox,
//                 Expanded(
//                   child: 'favorites'.translate.text.color(GlassIcons.favorite.color).fontSize(18).bold.make(),
//                 ),
//               ],
//             ),
//             8.heightBox,
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children: controller.favoriteList
//                   .take(5)
//                   .map((e) => TextButton(
//                         style: TextButton.styleFrom(elevation: 0, backgroundColor: const Color(0xffF8D8CA).withAlpha(3), visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
//                         onPressed: () {
//                           e.node.onTap();
//                         },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(padding: const EdgeInsets.only(right: 4, bottom: 4), child: e.node.icon.icon.color(Fav.design.primaryText).padding(0).size(16).make()),
//                             e.name.text.bold.make(),
//                           ],
//                         ),
//                       ))
//                   .toList(),
//             ),
//             8.heightBox,
//           ],
//         ),
//       ),
//     );
//   }
// }
