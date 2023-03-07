// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../../../helpers/glassicons.dart';
// import '../../../qbank/screens/qbankekolentry.dart';
// import 'z_mainwidget.dart';

// class QbankWidget extends MainWidget {
//   QbankWidget() : super([6, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
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
//               GlassIcons.books.imgUrl,
//               width: 32,
//             ),
//             8.widthBox,
//             // Stack(
//             //   alignment: Alignment.topLeft,
//             //   children: [
//             //     ShaderMask(
//             //       child: Image.asset(
//             //         'assets/images/pt.png',
//             //         width: 36,
//             //       ),
//             //       shaderCallback: (Rect bounds) {
//             //         return MyPalette.getGradient(23).createShader(bounds);
//             //       },
//             //       blendMode: BlendMode.srcATop,
//             //     ).pl2.pt2,
//             //     Icons.add_task_outlined.icon.size(32).color(Colors.black).padding(0).make()
//             //   ],
//             // ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   'mybooks'.translate.text.color(GlassIcons.books.color).fontSize(18).bold.make(),
//                 ],
//               ),
//             ),
//           ],
//         ).p16,
//       ),
//       openWidget: QBankPage(),
//       borderRadius: 16,
//     );
//   }
// }
