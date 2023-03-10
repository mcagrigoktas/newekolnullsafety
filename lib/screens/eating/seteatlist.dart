import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../localization/usefully_words.dart';
import '../../services/dataservice.dart';

class SetEatList extends StatefulWidget {
  @override
  SetEatListState createState() {
    return SetEatListState();
  }
}

class SetEatListState extends State<SetEatList> {
  TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;
  bool isLoading2 = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int? segmentValue = 0;
  int dateMillis = DateTime.now().millisecondsSinceEpoch;
  late StreamSubscription subscription;
  List<String> eatList = [];
  List<String> dayEatList = [];

  Future<void> addEat(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (Fav.noConnection()) return;

      setState(() {
        isLoading = true;
      });

      EatService.dbAddEat(segmentValue.toString() + textEditingController.text).then((_) {
        setState(() {
          textEditingController.text = "";
          isLoading = false;
        });
      }).unawaited;
    }
  }

  Future<void> deleteEat(BuildContext context, String eatName) async {
    bool sure = await Over.sure(title: 'uyari'.translate, message: "sureeatdelete".translate);
    if (sure == true) {
      if (Fav.noConnection()) return;

      setState(() {
        isLoading2 = true;
      });
      EatService.dbDeleteEat(eatName).then((_) {
        setState(() {
          isLoading2 = false;
        });
      }).unawaited;
    }
  }

  void getDayEatList() {
    setState(() {
      isLoading2 = true;
    });
    EatService.dbDayEatList(dateMillis.dateFormat("dd-MM-yyyy")).once().then((snapshot) {
      setState(() {
        isLoading2 = false;
        dayEatList.clear();
        if (snapshot?.value != null) {
          dayEatList = List<String>.from(snapshot!.value);
        }
      });
    });
  }

  void saveDayEat() {
    setState(() {
      isLoading2 = true;
    });
    EatService.dbSetDayEats(dateMillis.dateFormat("dd-MM-yyyy"), dayEatList.where((eat) => eatList.contains(eat)).toList()).then((_) {
      setState(() {
        OverAlert.saveSuc();
        isLoading2 = false;
      });
    }).catchError((_) {
      setState(() {
        isLoading2 = false;
        OverAlert.saveErr();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    subscription = EatService.dbEatList().onValue().listen((event) {
      eatList.clear();
      if (event?.value != null) {
        (event!.value as Map).forEach((k, v) {
          if (v) {
            eatList.add(k);
          }
        });
        setState(() {
          eatList.sort((a, b) => a.substring(1).compareTo(b.substring(1)));
        });
      }
    });
    getDayEatList();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'eatlist'.translate),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: "seteatlist".translate),
          child: Column(
            children: [
              MyDateChangeWidget(
                initialValue: dateMillis,
                onChanged: (value) {
                  setState(() {
                    dateMillis = value;
                  });
                  getDayEatList();
                },
              ),
              CupertinoSlidingSegmentedControl<int>(
                children: {0: Text(" " + "shortmorningbreakfast".translate + " "), 1: Text(" " + "shortlunch".translate + " "), 2: Text(" " + "shortafternoonbreakfast".translate + " ")},
                onValueChanged: (value) {
                  setState(() {
                    segmentValue = value;
                  });
                },
                groupValue: segmentValue,
              ),
            ],
          )),
      body: Body(
        withKeyboardCloserGesture: true,
        singleChildScroll: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 12.0,
          spacing: 12.0,
          children: eatList
              .where((eat) => eat.startsWith(segmentValue.toString()))
              .map((eat) => GestureDetector(
                  onTap: () {
                    setState(() {
                      dayEatList.contains(eat) ? dayEatList.remove(eat) : dayEatList.add(eat);
                    });
                  },
                  onLongPress: () {
                    deleteEat(context, eat);
                  },
                  child: Opacity(
                    opacity: dayEatList.contains(eat) ? 1.0 : 0.3,
                    child: Container(
                      decoration: ShapeDecoration(color: Fav.design.primary, shape: const StadiumBorder()),
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                      child: Text(
                        eat.substring(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )))
              .toList(),
        ),
      ),
      bottomBar: BottomBar(
          child: Column(
        children: [
          MyProgressButton(
            label: Words.save,
            isLoading: isLoading2,
            onPressed: saveDayEat,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'eatdeleteeat'.translate,
              textAlign: TextAlign.center,
              style: TextStyle(color: Fav.design.primaryText, fontSize: 13),
            ),
          ),
          Container(color: Fav.design.primary, height: 3.0),
          Container(
            color: Fav.design.scaffold.background,
            child: Form(
              key: formKey,
              child: Row(
                children: <Widget>[
                  16.widthBox,
                  Expanded(
                      flex: 1,
                      child: MyTextFormField(
                        controller: textEditingController,
                        maxLines: null,
                        labelText: "addeat".translate,
                        validatorRules: ValidatorRules(
                          req: false,
                          minLength: 2,
                          firebaseSafe: true,
                        ),
                      )),
                  SizedBox(
                      width: 80.0,
                      height: 40.0,
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Fav.design.primary),
                                  )))
                          : MyFlatButton(
                              textColor: Fav.design.primaryText,
                              boldText: true,
                              text: "add".translate,
                              onPressed: () {
                                addEat(context);
                              })),
                  16.widthBox
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
