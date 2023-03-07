// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';
// import 'package:widgetpackage/widgetpackage.dart';

// import '../../../../helpers/glassicons.dart';
// import '../../widgetsettingspage/model.dart';
// import 'main.dart';

// class LinkWidgets extends StatelessWidget {
//   final List<WidgetModel> modelList;
//   LinkWidgets(this.modelList);
//   @override
//   Widget build(BuildContext context) {
//     return WidgetBox(
//       maxHeight: 163,
//       imageAsset: GlassIcons.cursor.imgUrl,
//       titleColor: GlassIcons.cursor.color,
//       isGoPageButtonEnable: false,
//       title: 'shortcuts'.translate,
//       subTitle: 'shortcutshints'.translate,
//       child: Scroller(
//         scrollDirection: Axis.horizontal,
//         hoverThickness: 6,
//         scrollBarIsAlwaysShown: true,
//         child: Row(
//           children: modelList
//               .map((e) => InkWell(
//                     onTap: () {
//                       e.linkWidgetUrl.launch(LaunchType.url);
//                     },
//                     child: Container(
//                       margin: Inset(4),
//                       width: 64,
//                       height: 80,
//                       child: Column(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(4),
//                             child: MyCachedImage(fit: BoxFit.contain, height: 48, imgUrl: e.linkWidgetImageUrl),
//                           ),
//                           4.heightBox,
//                           Expanded(child: e.name.text.maxLines(2).autoSize.center.fontSize(12).make()),
//                         ],
//                       ),
//                     ),
//                   ))
//               .toList(),
//         ),
//       ),
//     );
//   }
// }
