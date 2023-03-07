//import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:elseifekol/appbloc/appvar.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../screens/main/widgets/bottom_navigation_bar.dart';
import 'bookpreview/booklibrary.dart';
import 'mybooks/mybooks.dart';
import 'settingspage.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Future.delayed(1.seconds).then((value) {
      if (AppVar.qbankBloc.hesapBilgileri.girisTuru == 100 || AppVar.qbankBloc.hesapBilgileri.girisTuru == 101) {
        if (DateTime.now().millisecondsSinceEpoch - (Fav.preferences.getInt('lastqbankeditorlogintime') ?? DateTime.now().millisecondsSinceEpoch) > 172800000) {
          AppVar.qbankBloc.signOut();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      key: ValueKey('DefaultQbankTabController'),
      length: 3,
      child: Scaffold(
          backgroundColor: Fav.secondaryDesign.scaffold.background,
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [MyBooks(), BookLibrary(), SettingsPage()],
          ),
          extendBody: true,
          bottomNavigationBar: QBankBottomNavBarCurved()),
    );
  }
}
