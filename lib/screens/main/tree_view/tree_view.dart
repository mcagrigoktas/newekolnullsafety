import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../assets.dart';
import '../../../helpers/glassicons.dart';
import '../controller.dart';

class AppTreeView extends StatelessWidget {
  final bool fromBigDashboard;
  AppTreeView({this.fromBigDashboard = true});

  MainController get _controller => Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (fromBigDashboard || Fav.design.brightness == Brightness.dark) {
      backgroundColor = Fav.design.others['widget.primaryBackground'];
    } else {
      backgroundColor = Color(0xccffffff);
    }

    Widget _current = Center(
      child: ExpandableSideBar(
        root: _controller.treeViewNodes!,
        backgroundColor: backgroundColor,
        collapsedBackgroundColor: backgroundColor,
        groupPadding: 1.0,
        tilePadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
        childrenPadding: EdgeInsets.only(left: 16),
        textColor: fromBigDashboard ? Fav.design.primary : GlassIcons.bag.color,
        collapsedTextColor: Fav.design.primaryText.withAlpha(210),
        padding: EdgeInsets.only(
          top: fromBigDashboard ? 48 : 16,
          bottom: fromBigDashboard ? 48 : (context.screenBottomPadding + 16),
          right: fromBigDashboard ? 8 : 32,
          left: fromBigDashboard ? 8 : 32,
        ),
      ),
    );

    if (!fromBigDashboard) {
      _current = AppScaffold(
        scaffoldBackgroundColor: Colors.transparent,
        blurVisiblePercentage: -2,
        backgroundDecoration: Opacity(
          opacity: 0.33,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.pattern.ekolschoolpatternPNG),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        topBar: TopBar(leadingTitle: '', hideBackButton: true),
        topActions: TopActionsTitle(title: 'options'.translate, color: GlassIcons.bag.color, imgUrl: GlassIcons.bag.imgUrl),
        body: Body.child(child: _current),
      );
    }

    return _current;
  }
}

// class FavoritesWidget extends StatelessWidget {
//   FavoritesWidget();
//   MainController get _controller => Get.find<MainController>();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: _controller.favoriteList
//           .take(5)
//           .map((e) => TextButton(
//                 style: TextButton.styleFrom(elevation: 0, backgroundColor: const Color(0xffF8D8CA).withAlpha(3), visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
//                 onPressed: () {
//                   e.node.onTap();
//                 },
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Padding(padding: const EdgeInsets.only(right: 4, bottom: 4), child: e.node.icon.icon.color(Fav.design.primaryText).padding(0).size(16).make()),
//                     e.name.text.bold.make(),
//                   ],
//                 ),
//               ))
//           .toList(),
//     );
//   }
// }
