import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

abstract class MainWidget extends StatelessWidget {
  final List<int> xSize;
  final List<int> ySize;

  const MainWidget(this.xSize, this.ySize);
}

extension ThemeExtension on Design {
  Color? get widgetPrimaryText => others['widget.primaryText'];
  Color? get widgetSecondaryText => others['widget.secondaryText'];
  Color? get widgetPriamryBackground => others['widget.primaryBackground'];
  Color? get widgetPageBackground => others['widget.pageBackground'];
}

// class WidgetContainer extends StatelessWidget {
//   static const useOpenContainer = false;
//   final Widget closedWidget;
//   final Widget openWidget;
//   final double borderRadius;

//   WidgetContainer({required this.closedWidget, required this.openWidget, this.borderRadius = 24});
//   @override
//   Widget build(BuildContext context) {
//     if (!useOpenContainer || openWidget == null) {
//       return GestureDetector(
//         onTap: () {
//           if (openWidget != null) Fav.to(openWidget, transition: Transition.cupertino, duration: 444.milliseconds);
//         },
//         child: closedWidget,
//       );
//     }

//     return OpenContainer(
//       tappable: true,
//       transitionDuration: const Duration(milliseconds: 444),
//       transitionType: ContainerTransitionType.fadeThrough,
//       //closedColor: Fav.design.widgetPageBackground,
//       closedElevation: 0,
//       clipBehavior: Clip.antiAlias,
//       openElevation: 0,
//       closedColor: Colors.transparent,
//       middleColor: Fav.design.widgetPageBackground,
//       closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
//       closedBuilder: (context, openContainer) => closedWidget,
//       openBuilder: (context, _openContainer) => openWidget,
//       useRootNavigator: true,
//     );
//   }
// }
