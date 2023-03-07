import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../pageparts/schoolinfo.dart';
import 'smart_search.dart';
import 'user_profile_widget/user_profile_image.dart';

class MainScreenTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool _isLargeWidth = context.screenWidth > 600;

    final _userProfileImage = UserProfileImage();

    GlobalKey? _key = Fav.readSeasonCache('searchglobalkey');
    if (_key == null) {
      _key = GlobalKey();
      Fav.writeSeasonCache('searchglobalkey', _key);
    }

    final _searchWidget = _isLargeWidth && AppVar.appBloc.hesapBilgileri.gtMT
        ? Center(
            child: SizedBox(
              width: 360,
              child: SmartSearch(_key),
            ),
          )
        : null;

    final _schoolInfo = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Fav.guardTo(AdressBookPage());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isLargeWidth)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (AppVar.appBloc.schoolInfoService!.singleData?.name ?? '').text.fontSize(14).color(Fav.design.primaryText).bold.make(),
                  (AppVar.appBloc.schoolInfoService!.singleData?.slogan ?? '').text.fontSize(12).color(Fav.design.primaryText).make(),
                ],
              ).pr8,
            CircularProfileAvatar(backgroundColor: Colors.white, imageUrl: AppVar.appBloc.schoolInfoService!.singleData!.logoUrl, radius: 18, borderWidth: 1, elevation: 2),
          ],
        ),
      ),
    );
    Widget _current;
    if (_searchWidget != null) {
      _current = Row(
        children: [
          Expanded(child: _userProfileImage),
          Expanded(child: _searchWidget),
          Expanded(child: _schoolInfo),
        ],
      );
    } else {
      _current = Row(
        children: [
          Expanded(child: _userProfileImage),
          8.widthBox,
          _schoolInfo,
        ],
      );
    }

    _current = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Fav.design.others['appbar.background']!.withAlpha(25),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: context.screenTopPadding, left: context.screenLeftPadding, right: context.screenRightPadding),
            alignment: Alignment.center,
            height: 44,
            child: _current,
          ),
          Container(color: Colors.grey.withAlpha(10), height: 1),
        ],
      ),
    );

    return _current;
  }
}

// class _SchoolImageWidget extends StatelessWidget {
//   final double radius;
//   _SchoolImageWidget({this.radius = 18});
//   @override
//   Widget build(BuildContext context) {
//     Widget _current;
//     _current = MyCachedImage(
//       imgUrl: AppVar.appBloc.schoolInfoService.singleData.logoUrl,
//       width: radius * 2,
//       height: radius * 2,
//       fit: BoxFit.cover,
//     );

//     _current = ClipRRect(
//       borderRadius: BorderRadius.circular(5),
//       child: _current,
//     );

//     // final _backgroundColor = Fav.design.brightness == Brightness.dark ? Color(0xff444444) : Color(0xffffffff);
//     final _backgroundColor = Fav.design.card.background;
//     _current = Container(
//       width: radius * 2,
//       height: radius * 2,
//       decoration: BoxDecoration(
//         color: Fav.design.card.background,
//         borderRadius: BorderRadius.circular(8.0),
//         border: Border.all(
//           color: _backgroundColor,
//           width: 1.0,
//         ),
//       ),
//       child: _current,
//     );

//     return _current;
//   }
// }

// CircularProfileAvatar(
            //   backgroundColor: Colors.white,
            //   imageUrl: AppVar.appBloc.schoolInfoService.singleData.logoUrl,
            //   radius: 18,
            //   borderWidth: 1,
            //   elevation: 2,
            // ),