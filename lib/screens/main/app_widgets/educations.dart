// import 'package:flutter/material.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../helpers/glassicons.dart';
// import '../../educations/education_content/layout.dart';
// import '../../educations/entrance/layout.dart';
// import '../../educations/model.dart';
// import '../controller.dart';
// import 'z_mainwidget.dart';

// class EducationsWidget extends MainWidget {
//   EducationsWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MainController>(
//         id: 'EducationsWidget',
//         builder: (controller) {
//           print('Update: EducationsWidget update oldu');
//           return WidgetContainer(
//             closedWidget: _WidgetBody(),
//             openWidget: EducationListEntrance(),
//           );
//         });
//   }
// }

// //668EE8
// class _WidgetBody extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     //if (!AppVar.appBloc.hesapBilgileri.kurumID.startsWith('demo')) return SizedBox();

//     final _favoritesEducationItems = Fav.preferences.getLimitedStringList(AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.uid + 'favoritesEducationItems', []);

//     final _educationList = AppVar.appBloc.educationService.dataList<Education>();

//     Widget current = Container(
//       constraints: BoxConstraints(maxHeight: 170),
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
//                 Image.asset(GlassIcons.education.imgUrl, width: 40),
//                 8.widthBox,
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       'educationlist'.translate.text.color(GlassIcons.education.color).fontSize(18).bold.make(),
//                       'educationlisthint'.translate.text.color(Fav.design.widgetSecondaryText).autoSize.maxLines(1).make(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//               child: _favoritesEducationItems.isNotEmpty
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: _favoritesEducationItems
//                           .map((e) {
//                             return _educationList.firstWhere((element) => element.key == e, orElse: () => null);
//                           })
//                           .map((e) => e == null
//                               ? SizedBox()
//                               : InkWell(
//                                   onTap: () {
//                                     if (e.type == EducationType.ekol) {
//                                       Fav.to(EducationContent(education: e));
//                                     }
//                                   },
//                                   child: Container(
//                                     margin: Inset(4),
//                                     width: 64,
//                                     height: 80,
//                                     child: Column(
//                                       children: [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(4),
//                                           child: MyCachedImage(fit: BoxFit.contain, height: 48, imgUrl: e.imgUrl),
//                                         ),
//                                         4.heightBox,
//                                         Flexible(child: e.name.text.maxLines(2).autoSize.center.fontSize(12).make()),
//                                       ],
//                                     ),
//                                   ),
//                                 ))
//                           .toList()
//                         ..add(Container(
//                           alignment: Alignment.center,
//                           child: Container(
//                             margin: Inset(4),
//                             height: 80,
//                             width: 64,
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                                 //   gradient: GlassIcons.education.color.hueGradient,
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Fav.design.primaryText.withAlpha(15))),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 MdiIcons.arrowRightBoldCircleOutline.icon.color(Fav.design.primaryText).padding(4).make(),
//                                 'seealleducationitems'.translate.text.center.fontSize(11).color(Fav.design.primaryText).make(),
//                               ],
//                             ),
//                           ),
//                         )),
//                     ).p8
//                   : Container(
//                       alignment: Alignment.center,
//                       child: Container(
//                         height: 40,
//                         width: double.infinity,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           gradient: GlassIcons.education.color.withLightness(0.93).hueGradient,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: 'seealleducationitems'.translate.text.color(Colors.black).bold.make(),
//                       ),
//                     ).px16),
//         ],
//       ),
//     );

//     if (isWeb) {
//       current = MouseRegion(
//         child: current,
//         cursor: SystemMouseCursors.click,
//       );
//     }
//     return current.p2;
//   }
// }
