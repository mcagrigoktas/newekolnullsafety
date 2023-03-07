// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/glassicons.dart';
// import '../../eating/eatfile.dart';
// import '../../eating/eating.dart';
// import '../../eating/eaturl.dart';
// import 'z_mainwidget.dart';

// class FoodListWidget extends MainWidget {
//   FoodListWidget() : super([6, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     Widget _current;

//     if (AppVar.appBloc.schoolInfoService!.singleData!.eatMenuType == 1) {
//       _current = EatUrl();
//     } else if (AppVar.appBloc.schoolInfoService!.singleData!.eatMenuType == 2) {
//       _current = EatFile();
//     } else {
//       _current = EatList();
//     }

//     return WidgetContainer(
//       closedWidget: Container(
//         decoration: BoxDecoration(
//             color: Fav.design.others['widget.primaryBackground'],
//             // gradient: Colors.white.hueGradient,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xff2C2E60).withOpacity(0.01),
//                 blurRadius: 2,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 0),
//               ),
//             ]),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               GlassIcons.mealIcon.imgUrl!,
//               width: 32,
//             ),
//             8.widthBox,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   'eatlist'.translate.text.color(GlassIcons.mealIcon.color!).fontSize(18).bold.make(),
//                 ],
//               ),
//             ),
//           ],
//         ).p16,
//       ),
//       openWidget: _current,
//       borderRadius: 16,
//     );
//   }
// }
