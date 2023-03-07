import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import 'questionpage/fulllayout.dart';
import 'senddenemeresult.dart';

class TestPage extends StatefulWidget {
  @override
  TestPageState createState() {
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  @override
  void dispose() {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: true,
        stream: AppVar.questionPageController.test,
        builder: (context, snapshot) {
          if (snapshot.data == 1) {
            return Material(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppVar.questionPageController.theme!.backgroundColor!, AppVar.questionPageController.theme!.backgroundColor!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    image: DecorationImage(
                      image: AssetImage(AppVar.questionPageController.patternImageUrl),
                      fit: BoxFit.cover,
                    )),
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //todocheck kontrol edilmeli
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppVar.questionPageController.theme!.primaryColor,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'refresh'.translate,
                          style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor),
                        ),
                        onPressed: () {
                          AppVar.questionPageController.testiHazirla();
                        }),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                        child: Text(
                          'noconnection'.translate,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppVar.questionPageController.theme!.primaryColor),
                        ))
                  ],
                ),
              ),
            );
          }

          if (AppVar.questionPageController.getTest == null) {
            return EmptyScaffold(
              child: MyProgressIndicator(
                text: 'loading'.translate,
                color: AppVar.questionPageController.theme!.primaryTextColor,
                isCentered: true,
              ),
              patternImageUrl: AppVar.questionPageController.patternImageUrl,
            );
          }

          if (AppVar.questionPageController.kitapBilgileri.isDeneme) {
            if (AppVar.questionPageController.icindekilerItem!.denemeKey.safeLength < 6) return EmptyState(text: 'Deneme Bilgileri hatali'.translate);
            if (Fav.noConnection()) return EmptyState(text: 'noconnection'.translate);

            return StreamBuilder<int>(
              stream: AppVar.questionPageController.denemeState,
              builder: (context, snapshot) {
                final Widget current = snapshot.hasData == false || snapshot.data! < 1
                    ? TimeCounting(AppVar.questionPageController.patternImageUrl)
                    : snapshot.data == 2
                        ? TimeNotCome(AppVar.questionPageController.patternImageUrl)
                        : snapshot.data == 3 || snapshot.data == 5
                            ? TimeWaitingOneHour(AppVar.questionPageController.patternImageUrl)
                            : WillPopScope(
                                onWillPop: () async {
                                  await AppVar.questionPageController.onBackPressed();
                                  return false;
                                },
                                child: TestPageQuestion(),
                              );

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 333),
                  child: current,
                );
              },
            );
          }

          return WillPopScope(
            onWillPop: () async {
              await AppVar.questionPageController.onBackPressed();
              return false;
            },
            child: TestPageQuestion(),
          );
        });
  }
}

class DenemeTime extends StatelessWidget {
  DenemeTime();

  @override
  Widget build(BuildContext context) {
    final bloc = AppVar.questionPageController;
    int? userDenemeStartTime = Fav.preferences.getInt(bloc.icindekilerItem!.denemeKey + bloc.kitapBilgileri.bookKey + 'userStartTime', 0);
    int usedduration = userDenemeStartTime == 0 ? 0 : Duration(milliseconds: bloc.realTime() - userDenemeStartTime!).inMinutes;
    usedduration = usedduration.clamp(0, bloc.icindekilerItem!.denemeDurationMinute!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: ShapeDecoration(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))).withAlpha(50), shape: const StadiumBorder()),
          child: Text('starttime'.translate + ': ' + bloc.icindekilerItem!.denemeStartTime!.dateFormat("d-MMM-yyyy, HH:mm"), style: TextStyle(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))), fontSize: 14.0)),
        ),
        8.heightBox,
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: ShapeDecoration(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))).withAlpha(50), shape: const StadiumBorder()),
          child: Text('finishtime'.translate + ': ' + bloc.icindekilerItem!.denemeEndTime!.dateFormat("d-MMM-yyyy, HH:mm"), style: TextStyle(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))), fontSize: 14.0)),
        ),
        8.heightBox,
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: ShapeDecoration(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))).withAlpha(50), shape: const StadiumBorder()),
          child: Text('duration'.translate + ': ' + bloc.icindekilerItem!.denemeDurationMinute.toString() + ' ${'minute'.translate}', style: TextStyle(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))), fontSize: 14.0)),
        ),
        8.heightBox,
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: ShapeDecoration(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))).withAlpha(50), shape: const StadiumBorder()),
          child: Text('usedduration'.translate + ': ' + usedduration.toString() + ' ${'minute'.translate}', style: TextStyle(color: Color(int.parse("0xff" + bloc.kitapBilgileri.primaryColor!.substring(1))), fontSize: 14.0)),
        ),
      ],
    );
  }
}

class TimeCounting extends StatelessWidget {
  final String patternImageUrl;
  TimeCounting(this.patternImageUrl);

  @override
  Widget build(BuildContext context) {
    return EmptyScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MyFlareIndicator(child: const Icon(Icons.access_time, size: 28)),
          16.heightBox,
          'checkdenemetime'.translate.text.center.color(Fav.secondaryDesign.primaryText).make(),
          16.heightBox,
          FloatingActionButton(heroTag: 'jflks', mini: true, backgroundColor: Color(int.parse("0xff" + AppVar.questionPageController.kitapBilgileri.primaryColor!.substring(1))), child: const Icon(Icons.chevron_left, color: Colors.white), onPressed: Get.back)
        ],
      ),
      patternImageUrl: patternImageUrl,
    );
  }
}

class TimeNotCome extends StatelessWidget {
  final String patternImageUrl;

  TimeNotCome(this.patternImageUrl);

  @override
  Widget build(BuildContext context) {
    return EmptyScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(AppVar.questionPageController.getTest!.name!, style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 32)),
          16.heightBox,
          MyFlareIndicator(child: const Icon(Icons.hourglass_empty, size: 28)),
          8.heightBox,
          StopWatch(),
          8.heightBox,
          Text('denemenotstarted'.translate, style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor)),
          16.heightBox,
          DenemeTime(),
          64.heightBox,
          FloatingActionButton(heroTag: 'jflks', mini: true, backgroundColor: Color(int.parse("0xff" + AppVar.questionPageController.kitapBilgileri.primaryColor!.substring(1))), child: const Icon(Icons.chevron_left, color: Colors.white), onPressed: Get.back)
        ],
      ),
      patternImageUrl: patternImageUrl,
    );
  }
}

class TimeWaitingOneHour extends StatelessWidget {
  final String patternImageUrl;
  TimeWaitingOneHour(this.patternImageUrl);

  @override
  Widget build(BuildContext context) {
    return EmptyScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(AppVar.questionPageController.getTest!.name!, style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 32)),
          16.heightBox,
          MyFlareIndicator(child: const Icon(Icons.timer_off, size: 28)),
          8.heightBox,
          Text('onehourwaiting'.translate, textAlign: TextAlign.center, style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor)),
          16.heightBox,
          DenemeTime(),
          64.heightBox,
          Fav.preferences.getBool(AppVar.questionPageController.icindekilerItem!.denemeKey + 'sonucgonderildi', false)!
              ? MyRaisedButton(
                  text: 'viewresult'.translate,
                  onPressed: () {},
                )
              : MyRaisedButton(
                  text: 'sendresult'.translate,
                  onPressed: () async {
                    if (Fav.noConnection()) return;
                    bool? sendSuc = await SendResult.send(true, AppVar.questionPageController.icindekilerItem!, AppVar.questionPageController.kitapBilgileri.bookKey);
                    if (sendSuc == null) return;
                    if (sendSuc) {
                      Get.back();
                      OverAlert.saveSuc();
                    } else {
                      OverAlert.saveErr();
                    }
                  },
                ),
          16.heightBox,
          FloatingActionButton(heroTag: 'jflks', mini: true, backgroundColor: Color(int.parse("0xff" + AppVar.questionPageController.kitapBilgileri.primaryColor!.substring(1))), child: const Icon(Icons.chevron_left, color: Colors.white), onPressed: Get.back)
        ],
      ),
      patternImageUrl: patternImageUrl,
    );
  }
}

class StopWatch extends StatefulWidget {
  StopWatch();

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  String text = '';
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        var time = AppVar.questionPageController.realTime();
        var denemeStartTime = AppVar.questionPageController.icindekilerItem!.denemeStartTime!;
        var remaininng = (denemeStartTime - time).remainingTime;
        text = '';
        text += remaininng.day == 0 ? '' : ((remaininng.day.toString() + ' ' + 'dayhint'.translate) + ' ');
        text += remaininng.hour == 0 ? '' : (remaininng.hour.toString() + ' ' + 'hour'.translate) + ' ';
        text += '${remaininng.minute} ${'minute'.translate} ${remaininng.second} ${'second'.translate} ';
        if (denemeStartTime - time < 0) {
          timer.cancel();
          // ignore: unused_local_variable
          var net = Fav.hasConnection();
          AppVar.questionPageController.sureyiCalistir();
        }
      });
    });
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Color(int.parse("0xff" + AppVar.questionPageController.kitapBilgileri.primaryColor!.substring(1))), fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class EmptyScaffold extends StatelessWidget {
  final Widget? child;
  final String? patternImageUrl;
  EmptyScaffold({this.child, this.patternImageUrl});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppVar.questionPageController.theme!.backgroundColor!, AppVar.questionPageController.theme!.backgroundColor!], begin: Alignment.topCenter, end: Alignment.bottomCenter), image: DecorationImage(image: AssetImage(patternImageUrl!), fit: BoxFit.cover)),
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
