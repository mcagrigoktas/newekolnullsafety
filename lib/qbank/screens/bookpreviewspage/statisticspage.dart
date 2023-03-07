// ignore_for_file: must_be_immutable

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../models/models.dart';
import '../../qbankbloc/getdataservice.dart';
import 'bookpreviewspage.dart';

class StatisticsPage extends StatefulWidget {
  final IcindekilerModel? icindekilerData;
  final Kitap? kitap;

  String? uid; // Belki başkasının istatistiğine bakılıyor. Kendi istatistiğine bakıyorsan boş gelenbilir.
  StatisticsPage({this.icindekilerData, this.kitap, this.uid});

  @override
  StatisticsPageState createState() {
    return StatisticsPageState();
  }
}

class StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  List<IcindekilerItem>? icindekilerList;
  int toplamSure = 0;
  int toplamDogru = 0;
  int toplamYanlis = 0;
  int toplamBos = 0;
  bool istatistikVerisiGeldimi = false;
  Map<dynamic, dynamic>? istatistikVerisi;

  @override
  void initState() {
    super.initState();

    icindekilerList = widget.icindekilerData!.data;
    widget.uid ??= AppVar.qbankBloc.hesapBilgileri.uid;
    QBGetDataService.getStudentBookStatistics(widget.kitap!.bookKey, widget.uid).then((snapshot) {
      if (snapshot!.value != null) {
        istatistikVerisi = snapshot.value;
      } else {
        istatistikVerisi = {};
      }

      setState(() {
        istatistikVerisiGeldimi = true;
      });
    }).catchError((error) {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    toplamSure = 0;
    toplamDogru = 0;
    toplamYanlis = 0;
    toplamBos = 0;
    List<StatisticsModel> statisticsList = [];

    if (istatistikVerisiGeldimi) {
      icindekilerList!.forEach((level1Data) {
        statisticsList.add(StatisticsModel(tur: 0, name: level1Data.baslik));

        if (level1Data.children != null) {
          level1Data.children!.forEach((level2Data) {
            if (level2Data.testKey == "testseviyesi" || level2Data.testKey == "menulevel" || level2Data.testKey == "denemeseviyesi") {
              statisticsList.add(StatisticsModel(tur: 1, name: level2Data.baslik));
              if (level2Data.children != null) {
                level2Data.children!.forEach((level3Data) {
                  if (istatistikVerisi!.containsKey(level3Data.testKey)) {
                    var allSatatisticsOneTest = (istatistikVerisi![level3Data.testKey] as Map).entries.toList();
                    allSatatisticsOneTest.sort((a, b) => a.key.toString().compareTo(b.key.toString()));
                    var testIstatistigi = allSatatisticsOneTest.first.value;

                    statisticsList.add(StatisticsModel(tur: 20, name: level3Data.baslik, ds: testIstatistigi["ds"], ys: testIstatistigi["ys"], bs: testIstatistigi["bs"], sure: testIstatistigi["sure"]));
                    toplamSure = toplamSure + testIstatistigi["sure"] as int;
                    toplamDogru = toplamDogru + testIstatistigi["ds"] as int;
                    toplamYanlis = toplamYanlis + testIstatistigi["ys"] as int;
                    toplamBos = toplamBos + testIstatistigi["bs"] as int;
                  } else {
                    statisticsList.add(StatisticsModel(tur: 10, name: level3Data.baslik));
                  }
                });
              }
            } else {
              if (istatistikVerisi!.containsKey(level2Data.testKey)) {
                var testIstatistigi = (istatistikVerisi![level2Data.testKey] as Map).entries.first.value;

                statisticsList.add(StatisticsModel(tur: 20, name: level2Data.baslik, ds: testIstatistigi["ds"], ys: testIstatistigi["ys"], bs: testIstatistigi["bs"], sure: testIstatistigi["sure"]));
                toplamSure = toplamSure + testIstatistigi["sure"] as int;
                toplamDogru = toplamDogru + testIstatistigi["ds"] as int;
                toplamYanlis = toplamYanlis + testIstatistigi["ys"] as int;
                toplamBos = toplamBos + testIstatistigi["bs"] as int;
              } else {
                statisticsList.add(StatisticsModel(tur: 10, name: level2Data.baslik));
              }
            }
          });
        }
      });

      statisticsList.insert(0, StatisticsModel(tur: 100));
    }

    return MyQBankScaffold(
      appBar: MyQBankAppBar(
        visibleBackButton: true,
        title: 'statistics'.translate,
      ),
      body: !istatistikVerisiGeldimi
          ? MyProgressIndicator(isCentered: true)
          : ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: statisticsList.length,
              itemBuilder: (context, index) {
                //Basliklar
                if (statisticsList[index].tur == 0) {
                  return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      decoration: BoxDecoration(color: Fav.secondaryDesign.accent
                          //     image: DecorationImage(image: AssetImage("assets/images/confetti.png"),fit: BoxFit.cover)
                          ),
                      alignment: Alignment.center,
                      child: Text(
                        statisticsList[index].name!,
                        style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 16.0, fontWeight: FontWeight.bold),
                      ));
                } else if (statisticsList[index].tur == 1) {
                  return Container(
                      decoration: BoxDecoration(color: Fav.secondaryDesign.accent
                          //      image: DecorationImage(image: AssetImage("assets/images/confetti.png"),fit: BoxFit.cover)
                          ),
                      alignment: Alignment.center,
                      child: Text(
                        statisticsList[index].name!,
                        style: TextStyle(color: Fav.secondaryDesign.primaryText, fontSize: 16.0, fontWeight: FontWeight.bold),
                      ));
                } else if (statisticsList[index].tur == 10) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            statisticsList[index].name!,
                            style: const TextStyle(color: Color(0xff1F314A), fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'noteststatistics'.translate,
                            style: const TextStyle(color: Color(0xff1F314A), fontSize: 13.0, fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                  );
                } else if (statisticsList[index].tur == 20) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            statisticsList[index].name!,
                            style: const TextStyle(color: Color(0xff1F314A), fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          8.heightBox,
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: 4.0,
                                  color: const Color(0xff04bfac).withAlpha(225),
                                ),
                                flex: (100 * statisticsList[index].ds! / ((statisticsList[index].ds! + statisticsList[index].ys! + statisticsList[index].bs!).clamp(1, 10000))).floor(),
                              ),
                              Expanded(
                                child: Container(height: 4.0, color: const Color(0xfffe5a65).withAlpha(225)),
                                flex: (100 * statisticsList[index].ys! / ((statisticsList[index].ds! + statisticsList[index].ys! + statisticsList[index].bs!).clamp(1, 10000))).floor(),
                              ),
                              Expanded(
                                child: Container(height: 4.0, color: const Color(0xffffca12).withAlpha(225)),
                                flex: (100 * statisticsList[index].bs! / ((statisticsList[index].ds! + statisticsList[index].ys! + statisticsList[index].bs!).clamp(1, 10000))).floor(),
                              ),
                            ],
                          ),
                          8.heightBox,
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Icon(
                                  Icons.check_circle,
                                  color: const Color(0xff04bfac).withAlpha(225),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: Icon(Icons.cancel, color: const Color(0xfffe5a65).withAlpha(225)),
                                flex: 1,
                              ),
                              Expanded(
                                child: Icon(Icons.remove_circle, color: const Color(0xffffca12).withAlpha(225)),
                                flex: 1,
                              ),
                              Expanded(
                                child: Icon(Icons.timer, color: const Color(0xff8953ff).withAlpha(225)),
                                flex: 1,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  statisticsList[index].ds.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A)),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text(statisticsList[index].ys.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A))),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text(statisticsList[index].bs.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A))),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text(millisecondToText(statisticsList[index].sure!), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A))),
                                flex: 1,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'ds2'.translate,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150)),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text('ys2'.translate, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150))),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text('bs2'.translate, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150))),
                                flex: 1,
                              ),
                              Expanded(
                                child: Text('totaltime'.translate, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150))),
                                flex: 1,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }

                // Bütün istatistikler
                else if (statisticsList[index].tur == 100) {
                  return Card(
                    color: Fav.secondaryDesign.brightness == Brightness.light ? const Color(0xffFFF1C1) : Colors.white,
                    margin: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.images.confettioPNG), fit: BoxFit.cover)),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'totaltime'.translate,
                            style: const TextStyle(color: Color(0xff1F314A), fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          8.heightBox,
                          SizedBox(
                            width: 300.0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    (toplamSure / 3600000).floor().toString().padLeft(2, "0"),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Text(((toplamSure / 60000).floor() % 60).toString().padLeft(2, "0"), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A))),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Text(((toplamSure / 1000 % 60).toStringAsFixed(0)).padLeft(2, '0'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xff1F314A))),
                                  flex: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          SizedBox(
                            width: 300.0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'hour'.translate,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Text('minute'.translate, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150))),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Text('second'.translate, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0, color: const Color(0xff1F314A).withAlpha(150))),
                                  flex: 1,
                                ),
                              ],
                            ),
                          ),
                          8.heightBox,
                          SizedBox(
                            width: 300.0,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  width: 140.0,
                                  height: 140.0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: ProgressPainter(
                                            ds: toplamDogru,
                                            ys: toplamYanlis,
                                            bs: toplamBos,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: toplamDogru + toplamYanlis + toplamBos > 0
                                            ? TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'sucrate'.translate,
                                                    style: const TextStyle(fontSize: 14.0, color: Color(0xff1F314A), fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: "\n % " + (toplamDogru / (toplamDogru + toplamYanlis + toplamBos) * 100).toStringAsFixed(0),
                                                    style: const TextStyle(fontSize: 16.0, color: Color(0xff1F314A), fontWeight: FontWeight.bold),
                                                  )
                                                ],
                                              )
                                            : const TextSpan(text: ""),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          const Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                              backgroundColor: Color(0xff04bfac),
                                              maxRadius: 5.0,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              'ds2'.translate,
                                              style: const TextStyle(color: Color(0xff1F314A)),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(toplamDogru.toString(), style: TextStyle(color: const Color(0xff1F314A).withAlpha(225), fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                              backgroundColor: Color(0xfffe5a65),
                                              maxRadius: 5.0,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              'ys2'.translate,
                                              style: const TextStyle(color: Color(0xff1F314A)),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(toplamYanlis.toString(), style: TextStyle(color: const Color(0xff1F314A).withAlpha(225), fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                              backgroundColor: Color(0xffffca12),
                                              maxRadius: 5.0,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              'bs2'.translate,
                                              style: const TextStyle(color: Color(0xff1F314A)),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(toplamBos.toString(), style: TextStyle(color: const Color(0xff1F314A).withAlpha(225), fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                              backgroundColor: Color(0xff8953ff),
                                              maxRadius: 5.0,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              'totalquestion'.translate,
                                              style: const TextStyle(color: Color(0xff1F314A)),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text((toplamDogru + toplamYanlis + toplamBos).toString(), style: TextStyle(color: const Color(0xff1F314A).withAlpha(225), fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return Text(statisticsList[index].name! + " " + statisticsList[index].ds.toString());
              }),
    );
  }
}

String millisecondToText(int milliseconds) {
  return '${(milliseconds / 60000).floor().toString().padLeft(2, "0")}'
      ':${((milliseconds / 1000 % 60).toStringAsFixed(0)).padLeft(2, '0')}';
}

class StatisticsModel {
  int? tur;
  String? name;
  int? ds;
  int? ys;
  int? bs;
  int? sure;

  StatisticsModel({this.tur, this.name, this.ds, this.ys, this.bs, this.sure});
}

class ProgressPainter extends CustomPainter {
  ProgressPainter({
    required this.ds,
    required this.ys,
    required this.bs,
  });

  final int ds;
  final int ys;
  final int bs;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xff8953ff)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);

    int toplamSoru = ds + ys + bs;
    if (toplamSoru == 0) {
      return;
    }

    paint.color = const Color(0xff04bfac);
    double dsAngle = 2 * math.pi * (ds / toplamSoru);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: size.width / 2.0 - 8), -math.pi / 2, dsAngle, false, paint);

    paint.color = const Color(0xfffe5a65);
    double ysAngle = 2 * math.pi * (ys / toplamSoru);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: size.width / 2.0 - 8), -math.pi / 2 + dsAngle, ysAngle, false, paint);

    paint.color = const Color(0xffffca12);
    double bsAngle = 2 * math.pi * (bs / toplamSoru);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: size.width / 2.0 - 8), -math.pi / 2 + dsAngle + ysAngle, bsAngle, false, paint);
  }

  @override
  bool shouldRepaint(ProgressPainter oldDelegate) {
    return false;
  }
}
