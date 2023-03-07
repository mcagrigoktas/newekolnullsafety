import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../assets.dart';
import '../../flavors/themelist/helper.dart';
import 'login/signin.dart';
import 'login/signup.dart';
import 'other/editprofile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> settingListView = [];

    settingListView.add(TemaDegistir());
    settingListView.add(const SizedBox(
      height: 6,
    ));
    settingListView.add(YaziBoyutu());
    if (AppVar.qbankBloc.hesapBilgileri.girisYapildi == false) {
      settingListView.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: LoginButton(),
      ));
    }
    if (AppVar.qbankBloc.hesapBilgileri.girisYapildi == false) {
      settingListView.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SignUpButton(),
      ));
    }
    // if(AppVar.qbankBloc.hesapBilgileri.girisYapildi==true){settingListView.add(Padding(padding: EdgeInsets.only(top: 8),child: ReviewInfo(),));}
    if (AppVar.qbankBloc.hesapBilgileri.girisYapildi!) {
      settingListView.add(LogOutButton());
    }

    return MyQBankScaffold(
      hasScaffold: false,
      appBar: MyQBankAppBar(
        title: 'settings'.translate,
      ),
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? Column(
              children: [
                AppVar.qbankBloc.hesapBilgileri.girisYapildi! ? ProfileWidget() : Container(),
                16.heightBox,
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: settingListView,
                    padding: const EdgeInsets.all(0.0),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppVar.qbankBloc.hesapBilgileri.girisYapildi!
                          ? Expanded(
                              flex: 1,
                              child: ProfileWidget(),
                            )
                          : Container(),
                      Expanded(
                        flex: 1,
                        child: ListView(
                          children: settingListView,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? name = 'editname'.translate;
    if (AppVar.qbankBloc.hesapBilgileri.name!.length > 1) {
      name = AppVar.qbankBloc.hesapBilgileri.name;
    }

    return GestureDetector(
      onTap: () {
        if (Fav.noConnection()) return;

        Fav.to(QbankEditProfilePage());
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            AppVar.qbankBloc.hesapBilgileri.imgUrl!.startsWith("http")
                ? CircularProfileAvatar(
                    imageUrl: AppVar.qbankBloc.hesapBilgileri.imgUrl, radius: 70,
                    backgroundColor: Colors.transparent, borderWidth: 4,
                    //  initialsText: Text("AD", style: TextStyle(fontSize: 40, color: Colors.white),),
                    borderColor: Fav.secondaryDesign.accent,
                    elevation: 4.0,
                    foregroundColor: Colors.brown.withOpacity(0.5),
                    // onTap: () {print('adil');}, // sets on tap
                    showInitialTextAbovePicture: true,
                  )
                : Hero(
                    tag: "profileImage",
                    child: Image.asset(
                      Assets.images.emptyprofilephotoPNG,
                      width: 125.0,
                      height: 125.0,
                      fit: BoxFit.cover,
                    )),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    name!,
                    style: TextStyle(fontSize: 24.0, color: Fav.secondaryDesign.primaryText, fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class TemaDegistir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        final theme = Fav.preferences.getString('qbankThemeV2', ThemeListModel.qbankDarkKey);
        if (theme == ThemeListModel.qbankDarkKey) {
          Fav.preferences.setString('qbankThemeV2', ThemeListModel.qbankLightKey);
        } else {
          Fav.preferences.setString('qbankThemeV2', ThemeListModel.qbankDarkKey);
        }
        AppVar.qbankBloc.appConfig.qbankRestartApp!(true);
      },
      subtitle: Text(
        'changethemehint'.translate,
        style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(170), fontSize: 12),
      ),
      title: Text('changetheme'.translate,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
          )),
      leading: const Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            Icons.favorite,
            color: Color(0xffFF3669),
          ),
        ),
      ),
    );
  }
}

class YaziBoyutu extends StatefulWidget {
  @override
  _YaziBoyutuState createState() => _YaziBoyutuState();
}

class _YaziBoyutuState extends State<YaziBoyutu> {
  double? yaziBoyutu;
  bool sliderOn = false;

  @override
  void initState() {
    super.initState();
    yaziBoyutu = Fav.preferences.getDouble("yaziBoyutu") ?? 15.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            setState(() {
              sliderOn = !sliderOn;
            });
          },
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 333),
            child: sliderOn
                ? Slider(
                    value: yaziBoyutu!,
                    min: 12.0,
                    max: 30.0,
                    activeColor: Fav.secondaryDesign.primaryText,
                    onChanged: (value) {
                      yaziBoyutu = value.ceil().toDouble();
                      Fav.preferences.setDouble("yaziBoyutu", yaziBoyutu!);
                      setState(() {});
                    },
                  )
                : Align(
                    alignment: Alignment.topLeft,
                    child: Text('fontsize'.translate,
                        style: TextStyle(
                          color: Fav.secondaryDesign.primaryText,
                        ))),
          ),
          subtitle: Text(
            'fontsizehint'.translate,
            style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(170), fontSize: 12),
          ),
          leading: const Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.text_fields,
                color: Colors.amber,
              ),
            ),
          ),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "${yaziBoyutu!.ceil()}",
              style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: yaziBoyutu),
            ),
          ),
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Fav.to(SignInPage());
      },
      //subtitle: Text(  'pleasesignin'),style: TextStyle(  color: Fav.secondaryDesign.primaryText.withAlpha(170), ),),
      title: Text('signin'.translate,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
          )),
      leading: const Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            MdiIcons.login,
            color: Color(0xff59D654),
          ),
        ),
      ),
    );
  }
}

class ReviewInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {},
      subtitle: Text(
        'reviewinfohint'.translate,
        style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(170), fontSize: 12),
      ),
      title: Text('reviewinfo'.translate,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
          )),
      leading: const Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            MdiIcons.accountCircle,
            color: Color(0xff59D654),
          ),
        ),
      ),
    );
  }
}

class LogOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        var sure = await Over.sure(message: 'quitalert'.translate);

        if (sure == true) {
          AppVar.qbankBloc.signOut();
          Get.back();
        }
      },
      subtitle: Text(
        'signouthint'.translate,
        style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(170), fontSize: 12),
      ),
      title: Text('signout'.translate,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
          )),
      leading: const Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            MdiIcons.logout,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Fav.to(SignUpPage());
      },
      subtitle: Text(
        'signuphint'.translate,
        style: TextStyle(color: Fav.secondaryDesign.primaryText.withAlpha(170), fontSize: 12),
      ),
      title: Text('signup'.translate,
          style: TextStyle(
            color: Fav.secondaryDesign.primaryText,
          )),
      leading: const Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            MdiIcons.accountPlus,
            color: Color(0xff59D654),
          ),
        ),
      ),
    );
  }
}
