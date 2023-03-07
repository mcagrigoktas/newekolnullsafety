import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'changeschoolinfodetail.dart';
import 'changeschoolinfolist.dart';

class ChangeSchoolInfoMainPage extends StatefulWidget {
  ChangeSchoolInfoMainPage();

  @override
  ChangeSchoolInfoMainPageState createState() {
    return ChangeSchoolInfoMainPageState();
  }
}

class ChangeSchoolInfoMainPageState extends State<ChangeSchoolInfoMainPage> {
  var isLargeScreen = false;
  String? islemYapilacakKey;
  var uniqueKey = GlobalKey();
  var formKey = GlobalKey<FormState>();
  var form2Key = GlobalKey<FormState>();
  var form3Key = GlobalKey<FormState>();
  int pageState = 0; // dik ekran için listemi yada detaymı gözükmeli
  String? saver;
  void selectItem(String itemKey, String saver) {
    setState(() {
      resetPage();
      islemYapilacakKey = itemKey;
      this.saver = saver;
      pageState = 1;
    });
  }

  void resetPage() {
    setState(() {
      uniqueKey = GlobalKey();
      formKey = GlobalKey<FormState>();
      form2Key = GlobalKey<FormState>();
      form3Key = GlobalKey<FormState>();
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
    isLargeScreen = context.screenWidth > 600;

    Widget detailWidget = ChangeSchoolInfoDetail(
      key: uniqueKey,
      resetPage: resetPage,
      formKey: formKey,
      form2Key: form2Key,
      form3Key: form3Key,
      islemYapilacakKey: islemYapilacakKey,
      saver: saver,
    );

    Widget listWidget = Container(color: Fav.design.scaffold.background, child: ChangeSchoolInfoList(islemYapilacakKey: islemYapilacakKey, onTap: selectItem));

    return MyScaffold(
      appBar: MyAppBar(
        visibleBackButton: true,
        backButtonPressed: () {
          if (isLargeScreen || pageState == 0) {
            Get.back();
          } else {
            resetPage();
          }
        },
        title: "Change School Info",
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: !isLargeScreen
            ? Container(child: pageState == 0 ? listWidget : detailWidget)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 1, child: listWidget),
                  Expanded(flex: 4, child: detailWidget),
                ],
              ),
      ),
    );
  }
}
