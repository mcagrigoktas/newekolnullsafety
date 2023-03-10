import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../assets.dart';
import '../../../../flavors/themelist/helper.dart';
import '../../../../helpers/parent_state_helper.dart';
import '../../../../models/accountdata.dart';
import '../../../generallyscreens/edit_profile/editprofilepage.dart';
import '../../../loginscreen/loginscreen.dart';
import '../../../loginscreen/qr_code_web_login.dart';
import '../../controller.dart';
import 'user_image_helper.dart';

class UserProfileImage extends StatelessWidget {
  UserProfileImage();

  String studentClassName() {
    String resultText = '';
    AppVar.appBloc.classService!.dataList.forEach((sinif) {
      if (AppVar.appBloc.hesapBilgileri.classKeyList.contains(sinif.key)) {
        resultText += sinif.name + ' ';
      }
    });
    if (resultText.length < 2) {
      resultText = 'classmissing'.translate;
    }

    if (!AppVar.appBloc.hesapBilgileri.isEkid) {
      final _student = AppVar.appBloc.hesapBilgileri.castStudentData();
      if (_student?.no != null && _student!.no.safeLength > 0) {
        resultText = _student.no! + ' - ' + resultText;
      }
    }

    return resultText;
  }

  String get girisTuruIsmi => AppVar.appBloc.hesapBilgileri.gtM
      ? "manager".translate
      : AppVar.appBloc.hesapBilgileri.gtT
          ? "teacher".translate
          : "student".translate;

  MainController get controller => Get.find<MainController>();

  List<QudsPopupMenuBase> itemBuilder(BuildContext context) {
    final List<QudsPopupMenuBase> _menuItems = [
      QudsPopupMenuWidget(builder: (c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            16.heightBox,
            UserImageWidget(radius: 48),
            8.heightBox,
            AppVar.appBloc.hesapBilgileri.name!.toUpperCase().text.center.bold.fontSize(24).color(Fav.design.primaryText).make(),
            if (!AppVar.appBloc.hesapBilgileri.gtTransporter)
              MyMiniRaisedButton(
                  //  color: Fa,
                  onPressed: () {
                    Get.back();
                    Fav.to(EditProfilePage());
                  },
                  text: 'editprofile'.translate),
            16.heightBox,
          ],
        );
      }),
      QudsPopupMenuDivider(),
      QudsPopupMenuItem(title: 'changethemeekol'.translate.text.make(), leading: Icon(MdiIcons.palette, color: Fav.design.primaryText), onPressed: ThemeHelper.openThemeSelector),
      QudsPopupMenuItem(title: 'fonttypes'.translate.text.make(), leading: Icon(MdiIcons.fontAwesome, color: Fav.design.primaryText), onPressed: ThemeHelper.openFontSelector),
      QudsPopupMenuDivider(),
      QudsPopupMenuItem(
          title: 'newaccount'.translate.text.make(),
          leading: Icon(IconsaxOutline.user_add, color: Fav.design.primaryText),
          onPressed: () {
            Fav.to(EkolSignInPage());
          }),
      if (!isWeb && AppVar.appBloc.hesapBilgileri.gtMT)
        QudsPopupMenuItem(
            title: 'webqrcodelogin'.translate.text.make(),
            leading: Icon(Icons.qr_code_rounded, color: Fav.design.primaryText),
            onPressed: () {
              Fav.to(QRCodeWebLogin());
            }),
      QudsPopupMenuItem(
          title: 'signout'.translate.text.color(Colors.red).make(),
          leading: Icon(IconsaxOutline.logout, color: Colors.red),
          onPressed: () async {
            var sure = await Over.sure(message: 'quitalert'.translate);
            if (sure == true) {
              AppVar.appBloc.signOut();
            }
          }),
      QudsPopupMenuDivider(),
    ];
    final List<QudsPopupMenuItem> _menuUserItems = [];
    try {
      UserImageHelper.getAllUserForMenuType(SelectUserMenuType.ProfileImage).forEach((hesap) {
        _menuUserItems.add(QudsPopupMenuItem(
          leading: CircularProfileAvatar(imageUrl: UserImageHelper.getUserImageUrl(hesap), radius: 18, elevation: 4, borderColor: Colors.white, borderWidth: 0.3),
          title: Text(
            hesap.name!,
            maxLines: 1,
            style: TextStyle(color: Fav.design.primaryText),
          ),
          subTitle: Text(
            hesap.kurumID,
            maxLines: 1,
            style: TextStyle(color: Fav.design.primaryText, fontSize: 10),
          ),
          onPressed: () {
            UserImageHelper.selectAccount(hesap, SelectUserMenuType.ProfileImage);
          },
        ));
      });
    } catch (_) {
      // _menuItems = [];
    }

    if (_menuUserItems.length < 4) {
      _menuItems.addAll(_menuUserItems);
    } else {
      _menuItems.add(QudsPopupMenuSection(titleText: 'chooseuser'.translate, leading: MdiIcons.accountConvert.icon.color(Fav.design.primaryText).make(), subItems: [..._menuUserItems]));
    }

    return _menuItems;
  }

  @override
  Widget build(BuildContext context) {
    var _accountName = 'hi'.translate + ", " + AppVar.appBloc.hesapBilgileri.name.toString();
    _accountName += ParentStateHelper.userTopBarNamePrefix();

    return QudsPopupButton(
        backgroundColor: Fav.design.scaffold.background,
        itemBuilder: itemBuilder,
        child: Row(
          children: [
            // _menuUserItems.isEmpty
            //     ?
            UserImageWidget(),
            // : Stack(
            //     children: [
            //       Opacity(opacity: 0.4, child: _menuUserItems.first.leading),
            //       UserImageWidget().pl8,
            //     ],
            //   ),
            8.widthBox,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(child: _accountName.text.bold.fontSize(14).autoSize.maxLines(1).make()),
                      Icons.keyboard_arrow_down_rounded.icon.color(Fav.design.primaryText).size(16).padding(0).make(),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Flexible(child: _accountName.text.bold.fontSize(14).autoSize.maxLines(1).make()),
                  //     Icons.change_circle_outlined.icon.size(14).color(Fav.design.primaryText).padding(0).make().pl2,
                  //   ],
                  // ),
                  if (!AppVar.appBloc.hesapBilgileri.gtTransporter) (AppVar.appBloc.hesapBilgileri.gtS ? studentClassName() : girisTuruIsmi).text.fontSize(12).color(Fav.design.primaryText.withAlpha(180)).make(),
                ],
              ),
            ),
          ],
        ));
  }
}

class UserImageWidget extends StatelessWidget {
  final double radius;
  UserImageWidget({this.radius = 18});
  @override
  Widget build(BuildContext context) {
    Widget _current;
    if (AppVar.appBloc.hesapBilgileri.imgUrl.safeLength > 6) {
      _current = CircularProfileAvatar(
        imageUrl: AppVar.appBloc.hesapBilgileri.imgUrl,
        elevation: 3,
        borderColor: Colors.white,
        borderWidth: 0.3,
        radius: radius,
      );
    } else if (AppVar.appBloc.hesapBilgileri.gtTransporter) {
      _current = Image.asset(
        Assets.images.driverPNG,
        width: radius * 2,
      );
    } else {
      _current = Icon(
        MdiIcons.accountCircle,
        color: Fav.design.primary,
        size: radius * 2,
      );
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: _current,
    );
  }
}


// class _UserImageWidget extends StatelessWidget {
//   final double radius;
//   _UserImageWidget({this.radius = 18});
//   @override
//   Widget build(BuildContext context) {
//     Widget _current;
//     if (AppVar.appBloc.hesapBilgileri.imgUrl.safeLength > 6) {
//       _current = MyCachedImage(
//         imgUrl: AppVar.appBloc.hesapBilgileri.imgUrl,
//         width: radius * 2,
//         height: radius * 2,
//         fit: BoxFit.cover,
//       );
//     } else if (AppVar.appBloc.hesapBilgileri.gtTransporter) {
//       _current = Image.asset(
//         'assets/images/driver.png',
//         width: radius * 2,
//         height: radius * 2,
//         fit: BoxFit.contain,
//       );
//     } else {
//       _current = Icon(
//         MdiIcons.accountCircle,
//         color: Fav.design.primary,
//         size: radius * 2,
//       );
//     }

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
