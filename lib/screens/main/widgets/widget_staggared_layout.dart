// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:widgetpackage/widgetpackage.dart';

// import '../app_widgets/z_mainwidget.dart';
// import '../controller.dart';

// class StaggeredWidgetContainer extends StatelessWidget {
//   final double extraTopPadding;
//   final List<MainWidget> widgetList;

//   StaggeredWidgetContainer({
//     this.widgetList,
//     this.extraTopPadding = 44,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MainController>();
//     return LayoutBuilder(builder: (context, constraints) {
//       const _maxWidth = 1080.0;

//       final int _xSizeType = controller.xSizeType([constraints.maxWidth, _maxWidth].min);
//       final double _horizontalPadding = constraints.maxWidth < _maxWidth ? controller.paddingHorizontal(constraints.maxWidth) : (constraints.maxWidth - _maxWidth) / 2;

//       return Center(
//         child: StaggeredGridView.countBuilder(
//           shrinkWrap: true,
//           crossAxisCount: 12,
//           physics: const BouncingScrollPhysics(),
//           itemCount: widgetList.length,
//           itemBuilder: (BuildContext context, int index) {
//             final height = widgetList[index].ySize[controller.sizeType(_maxWidth)].toDouble();
//             return Container(height: height <= 0 ? null : height, padding: EdgeInsets.symmetric(horizontal: controller.widgetPadding(_maxWidth)), child: widgetList[index]);
//           },
//           staggeredTileBuilder: (int index) {
//             return StaggeredTile.fit(widgetList[index].xSize[_xSizeType]);
//             //  return StaggeredTile.count(widgetList[index].xSize[xSizeType], widgetList[index].ySize.toDouble());
//           },
//           padding: EdgeInsets.only(
//             top: context.screenTopPadding + 16 + extraTopPadding,
//             bottom: context.screenBottomPadding + 8,
//             left: _horizontalPadding,
//             right: _horizontalPadding,
//           ),
//           mainAxisSpacing: controller.mainAxisSpacing(_maxWidth),
//           crossAxisSpacing: 0,
//         ),
//       );
//     });
//   }
// }
