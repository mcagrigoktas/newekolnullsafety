import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../assets.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../services/dataservice.dart';
import 'seteatlist.dart';

class EatList extends StatefulWidget {
  EatList();

  @override
  EatListState createState() {
    return EatListState();
  }
}

class EatListState extends State<EatList> {
  int dateMillis = DateTime.now().millisecondsSinceEpoch;
  bool isLoading = false;
  List<String> dayEatList = [];
  Random rnd = Random();

  bool phoneAndLandscape = false;
  void getDayEatList() {
    setState(() {
      isLoading = true;
    });
    EatService.dbDayEatList(dateMillis.dateFormat("dd-MM-yyyy")).once().then((snapshot) {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        dayEatList.clear();
        if (snapshot?.value != null) {
          dayEatList = List<String>.from(snapshot!.value);
          dayEatList.sort((a, b) => a.substring(1).compareTo(b.substring(1)));
        } else {
          OverAlert.show(type: AlertType.danger, message: 'nofooddata'.translate);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDayEatList();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.shortestSide < 600 && MediaQuery.of(context).orientation == Orientation.landscape) {
      phoneAndLandscape = true;
    } else {
      phoneAndLandscape = false;
    }

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'menu1'.translate,
        trailingActions: AppVar.appBloc.hesapBilgileri.gtM
            ? <Widget>[
                IconButton(
                    icon: Icon(Icons.edit, color: Fav.design.appBar.text),
                    onPressed: () {
                      if (AuthorityHelper.hasYetki5(warning: true) == false) return;

                      Fav.to(SetEatList(), preventDuplicates: false)!.then((_) {
                        getDayEatList();
                      });
                    })
              ]
            : null,
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: "eatlist".translate, imgUrl: GlassIcons.mealIcon.imgUrl, color: GlassIcons.mealIcon.color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const SizedBox(width: 20, height: 20),
            MyDateChangeWidget(
              initialValue: dateMillis,
              onChanged: (value) {
                setState(() {
                  dateMillis = value;
                });
                getDayEatList();
              },
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Fav.design.primary),
                    )
                  : null,
            ),
          ],
        ),
      ),
      body: Body(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6.0),
              child: Text(
                "morningbreakfast".translate,
                style: TextStyle(color: Fav.design.customDesign4.primary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(Assets.images.sabahPNG),
                    fit: BoxFit.cover,
                  )),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: dayEatList.where((eat) => eat.startsWith("0")).map((eat) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: phoneAndLandscape ? 0 : 16),
                          padding: const EdgeInsets.all(8.0),
                          width: phoneAndLandscape ? null : 90,
                          height: phoneAndLandscape ? null : 90,
                          alignment: Alignment.center,
                          decoration: phoneAndLandscape ? ShapeDecoration(shape: const StadiumBorder(), color: Colors.white.withAlpha(150)) : BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(170)),
                          child: Text(
                            eat.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Color.fromRGBO(rnd.nextInt(160), rnd.nextInt(160), rnd.nextInt(160), 1)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6.0),
              child: Text(
                "lunch".translate,
                style: TextStyle(color: Fav.design.customDesign4.primary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(Assets.images.oglePNG),
                    fit: BoxFit.cover,
                  )),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: dayEatList.where((eat) => eat.startsWith("1")).map((eat) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: phoneAndLandscape ? 0 : 16),
                          padding: const EdgeInsets.all(8.0),
                          width: phoneAndLandscape ? null : 90,
                          height: phoneAndLandscape ? null : 90,
                          alignment: Alignment.center,
                          decoration: phoneAndLandscape ? ShapeDecoration(shape: const StadiumBorder(), color: Colors.white.withAlpha(150)) : BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(170)),
                          child: Text(
                            eat.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Color.fromRGBO(rnd.nextInt(160), rnd.nextInt(160), rnd.nextInt(160), 1)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6.0),
              child: Text(
                "afternoonbreakfast".translate,
                style: TextStyle(color: Fav.design.customDesign4.primary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(Assets.images.ikindiPNG),
                    fit: BoxFit.cover,
                  )),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: dayEatList.where((eat) => eat.startsWith("2")).map((eat) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: phoneAndLandscape ? 0 : 16),
                          padding: const EdgeInsets.all(8.0),
                          width: phoneAndLandscape ? null : 90,
                          height: phoneAndLandscape ? null : 90,
                          alignment: Alignment.center,
                          decoration: phoneAndLandscape ? ShapeDecoration(shape: const StadiumBorder(), color: Colors.white.withAlpha(150)) : BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(170)),
                          child: Text(
                            eat.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Color.fromRGBO(rnd.nextInt(160), rnd.nextInt(160), rnd.nextInt(160), 1)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
