import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'supermanagerdetail.dart';
import 'supermanagerlist.dart';

class SuperManagerMainPage extends StatefulWidget {
  SuperManagerMainPage();

  @override
  SuperManagerMainPageState createState() {
    return SuperManagerMainPageState();
  }
}

class SuperManagerMainPageState extends State<SuperManagerMainPage> {
  var _isLargeScreen = false;
  int sayfaTuru = 0; // 10 yeni kayıt.
  String? islemYapilacakKey;
  var uniqueKey = GlobalKey();
  var formKey = GlobalKey<FormState>();
  int pageState = 0; // dik ekran için listemi yada detaymı gözükmeli

  void selectItem(String itemKey) {
    setState(() {
      resetPage();
      islemYapilacakKey = itemKey;
      pageState = 1;
    });
  }

  void resetPage() {
    setState(() {
      sayfaTuru = 0;
      uniqueKey = GlobalKey();
      formKey = GlobalKey<FormState>();
      islemYapilacakKey = null;
      pageState = 0;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isLargeScreen = context.screenWidth > 600;

    Widget _detailWidget = SuperManagerDetail(
      key: uniqueKey,
      resetPage: resetPage,
      formKey: formKey,
      sayfaTuru: sayfaTuru,
      islemYapilacakKey: islemYapilacakKey,
    );

    Widget _listWidget = Container(color: Fav.design.scaffold.background, child: SuperManagerList(islemYapilacakKey: islemYapilacakKey, sayfaTuru: sayfaTuru, onTap: selectItem));

    return MyScaffold(
      appBar: MyAppBar(
        visibleBackButton: true,
        backButtonPressed: () {
          if (_isLargeScreen || pageState == 0) {
            Get.back();
          } else {
            setState(() {
              pageState = 0;
              resetPage();
            });
          }
        },
        title: "Super Manager Settings",
        trailingWidgets: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.plus, color: Fav.design.appBar.text),
            onPressed: () {
              setState(() {
                resetPage();
                sayfaTuru = 10;
                pageState = 1;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: !_isLargeScreen
            ? Container(
                child: pageState == 0 ? _listWidget : _detailWidget,
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: _listWidget,
                  ),
                  Expanded(
                    flex: 4,
                    child: _detailWidget,
                  ),
                ],
              ),
      ),
    );
  }
}
