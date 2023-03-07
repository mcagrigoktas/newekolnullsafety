import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'reviewschoolinfodetail.dart';
import 'reviewschoolinfolist.dart';

class ReviewSchoolInfoMainPage extends StatefulWidget {
  ReviewSchoolInfoMainPage();

  @override
  ReviewSchoolInfoMainPageState createState() {
    return ReviewSchoolInfoMainPageState();
  }
}

class ReviewSchoolInfoMainPageState extends State<ReviewSchoolInfoMainPage> {
  var isLargeScreen = false;
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
    isLargeScreen = context.screenWidth > 600;
    Widget detailWidget = ReviewSchoolInfoDetail(
      key: uniqueKey,
      resetPage: resetPage,
      formKey: formKey,
      islemYapilacakKey: islemYapilacakKey,
    );

    Widget listWidget = Container(color: Fav.design.scaffold.background, child: ReviewSchoolInfoList(islemYapilacakKey: islemYapilacakKey, onTap: selectItem));

    return MyScaffold(
      appBar: MyAppBar(
        visibleBackButton: true,
        backButtonPressed: () {
          if (isLargeScreen || pageState == 0) {
            Get.back();
          } else {
            setState(() {
              pageState = 0;
              resetPage();
            });
          }
        },
        title: "Review School Info",
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: !isLargeScreen
            ? Container(
                child: pageState == 0 ? listWidget : detailWidget,
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: listWidget,
                  ),
                  Expanded(
                    flex: 4,
                    child: detailWidget,
                  ),
                ],
              ),
      ),
    );
  }
}
