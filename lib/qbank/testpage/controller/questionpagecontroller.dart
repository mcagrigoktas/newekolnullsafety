import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:ntp/ntp.dart';
import 'package:pdfx/pdfx.dart';
import 'package:rxdart/subjects.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.dart';
import '../../../flavors/mainhelper.dart';
import '../../../models/accountdata.dart';
import '../../models/models.dart';
import '../../qbankbloc/getdataservice.dart';
import '../../qbankbloc/qbankbloc.dart';
import '../../qbankbloc/setdataservice.dart';
import '../../screens/bookpreviewspage/bookpreviewspage.dart';
import '../questionpage/themeservice.dart';
import '../senddenemeresult.dart';
import 'controller2.dart';

class QuestionPageController extends Object with WidgetsBindingObserver, QuestionPageController2 {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PdfDocument? pdfDocument;
  TestPageThemeModel? theme;
  QbankAppBloc qbankBloc = AppVar.qbankBloc;
  bool? debug;

  final QBankHesapBilgileri? hesapBilgileri;
  final Kitap kitapBilgileri;
  final String testKey;
  final String? testVersion;
  final IcindekilerItem? icindekilerItem;
  ScrollController scrollController = ScrollController();
  double? fontSize;

  Timer? timer;
  bool saatturu = true;
  void changeSaatTuru() {
    saatturu = !saatturu;
    _sure.add(true);
  } // Kalan süre, Geçen süre ayarı

  Map<String?, double> secenekDurumu = {"A": 0, "B": 0, "C": 0, "D": 0, "E": 0}; //0 normal 1 elendi
  Map<int?, Map<String?, double>> secenekDurumuCache = {};

  int? gecenSure = 0;
  int testSuresi = 0;
  bool? testCozuldu = false;
  int dogruSayisi = 0;
  int yanlisSayisi = 0;
  int bosSayisi = 0;
  String doruYanlisBosText = '';
  bool databaseKaydedildi = false;
  bool? anlatim = false; // Bu ne ki

  int? secilenSoruIndex = 0;
  Stream<bool> get soruYenile => _soruYenile.stream;
  final BehaviorSubject<bool> _soruYenile = BehaviorSubject<bool>.seeded(true);
  Sink<bool> get setSoruYenile => _soruYenile.sink;

  Stream<bool> get secenekleriYenile => _secenekleriYenile.stream;
  final BehaviorSubject<bool> _secenekleriYenile = BehaviorSubject<bool>.seeded(true);
  Sink<bool> get setSecenekleriYenile => _secenekleriYenile.sink;

  // Test Yenile 10 test yüklendi 0 yükleme başladı 1 internet yok
  Stream<int> get test => _testYenile.stream;
  final BehaviorSubject<int> _testYenile = BehaviorSubject<int>.seeded(0);
  Sink get setTestYenile => _testYenile.sink;
  Test? get getTest => _test;
  Test? _test;

  Stream<bool> get isaretlenenCevaplar => _isaretlenenCevaplar.stream;
  final BehaviorSubject<bool> _isaretlenenCevaplar = BehaviorSubject<bool>.seeded(true);
  void isaretlenenCevaplarSink(e) {
    _isaretlenenCevaplar.add(e);
  }

  late List<String?> isaretlenenCevaplarList;

  // Sure Tututcu
  Stream<bool> get sure => _sure.stream;
  final BehaviorSubject<bool> _sure = BehaviorSubject<bool>.seeded(true);

  //Eger deneme ise sayfa durumlarini ayarlamasi icin
  // 0 Gercek zaman hesaplaniyor
  //1 Gercek zaman hesaplandi zaman icerisinde
  //2 Gercek zaman hesaplandi zaman gelmemis
  //3 Gercek zaman hesaplandi zaman bitmis. ama 1 saat olmamis sorulari inceleyebilmesi icin
  //4 Gercek zaman hesaplandi zaman bitmis. Sorularida inceleyebilir
  //5 deneme yi tam suresince cozmus suresi dolmus fakat denemenin genel suresi dolmamis
  Stream<int> get denemeState => _denemeState.stream;
  final BehaviorSubject<int> _denemeState = BehaviorSubject<int>.seeded(-1);

  // Çizim Paneli Tututcu
  Uint8List? drawImg;
  Color? drawImgColor;
  bool ekranUstuYazma = false;
  void changeDrawPanelTuru([bool? islem]) {
    if (islem != null) {
      ekranUstuYazma = islem;
    } else {
      ekranUstuYazma = !ekranUstuYazma;
    }
    setSoruYenile.add(true); // Soru sayfasını yeniler
    if (ekranUstuYazma == false) {
      drawImg = null;
    }
  }

// Resme uzun bastığında appbarın genişleyip sorunun çözüm ksımının açılması için
  Stream<bool> get openDrawPanel => _openDrawPanel.stream;
  final BehaviorSubject<bool> _openDrawPanel = BehaviorSubject<bool>.seeded(false);
  Sink<bool> get setOpenDrawPanel => _openDrawPanel.sink;

  bool testPaused = false;

  QuestionPageController({required this.testKey, this.testVersion, this.hesapBilgileri, required this.kitapBilgileri, this.anlatim, this.debug, this.icindekilerItem}) {
    theme = temayiAyarla();

    theme!.bookColor = Color(int.parse('0xff${kitapBilgileri.primaryColor!.substring(1)}'));

    fontSize = Fav.preferences.getDouble("yaziBoyutu") ?? 14.0;

    WidgetsBinding.instance.addObserver(this);

    testiHazirla();
  }

  Future<bool> calculateRealTime() async {
    if (_realTimeDifference is Duration) return true;
    var time = await NTP.now();
    OverAlert.show(message: time.dateFormat("d-MMM, HH:mm"));
    _realTimeDifference = time.difference(DateTime.now());
    return true;
  }

  int realTime() {
    if (_realTimeDifference == null) return 0;
    return DateTime.now().add(_realTimeDifference!).millisecondsSinceEpoch;
  }

  Duration? _realTimeDifference;

  Future<void> testiHazirla() async {
    _testYenile.add(0);

    if (debug!) {
      if (Fav.noConnection()) {
        _testYenile.add(1);
        return;
      }
      QBGetDataService.streamTest(kitapBilgileri.bookKey, testKey).listen((snapShot) {
        _testiYazdir(snapShot!.value);
      });
    } else {
      final oncedenKayitliTest = await Fav.securePreferences.getHiveMap('qbankTest_' + testKey + AppConst.preferenecesBoxVersion.toString());
      final bool sonVersiyonKayitlimi = (Fav.preferences.getString("${testKey}_version") ?? "") == testVersion;
      if (oncedenKayitliTest.isNotEmpty && sonVersiyonKayitlimi) {
        await _testiYazdir(oncedenKayitliTest);
      } else {
        if (Fav.noConnection()) {
          _testYenile.add(1);
          return;
        }

        var byteData = await (DownloadManager.downloadWithHttp('${DatabaseStarter.databaseConfig.questionBankUrlPrefix}/Books%2F${kitapBilgileri.bookKey}%2F$testKey?alt=media'));
        var data = json.decode(DownloadManager.convertText(byteData!));
        await Fav.securePreferences.setHiveMap('qbankTest_' + testKey + AppConst.preferenecesBoxVersion.toString(), data, clearExistingData: true);
        Fav.preferences.setString("${testKey}_version", data["testInfo"]["version"]).unawaited;
        await _testiYazdir(data);
      }
    }
  }

  Future<void> _testiYazdir(data) async {
    Test test = Test.fromJson(data, testKey);
    await test.prepareNecceceryData();

    isaretlenenCevaplarList = List.filled(test.count, " ");

    _test = test;
    _getState(test);

    _testYenile.add(10);
    await sureyiCalistir();
  }

  Future<void> sureyiCalistir() async {
    if (debug!) return;
    if (timer != null) timer!.cancel();
    if (kitapBilgileri.isDeneme) {
      final isCalculateTrue = await calculateRealTime();
      if (isCalculateTrue == false) return;

      if (realTime() < icindekilerItem!.denemeStartTime!) return _denemeState.add(2);
      if (realTime() > (icindekilerItem!.denemeEndTime! + 3600000)) return _denemeState.add(4);
      if (realTime() > icindekilerItem!.denemeEndTime!) return _denemeState.add(3);

      int? userDenemeStartTime = Fav.preferences.getInt(icindekilerItem!.denemeKey + kitapBilgileri.bookKey + 'userStartTime');

      userDenemeStartTime ??= (await QBGetDataService.getUserDenemeStartTime(kitapBilgileri.bookKey, icindekilerItem!.denemeKey, qbankBloc.hesapBilgileri.uid!))!.value;

      if (userDenemeStartTime == null) {
        await QBSetDataService.sendUserDenemeStartTime(realTime(), kitapBilgileri.bookKey, icindekilerItem!.denemeKey, qbankBloc.hesapBilgileri.uid!).then((value) => Fav.preferences.setInt(icindekilerItem!.denemeKey + kitapBilgileri.bookKey + 'userStartTime', realTime()));
        userDenemeStartTime = realTime();
      } else {
        await Fav.preferences.setInt(icindekilerItem!.denemeKey + kitapBilgileri.bookKey + 'userStartTime', userDenemeStartTime);
      }
      gecenSure = realTime() - userDenemeStartTime;

      if (icindekilerItem!.denemeDurationMillisecond - gecenSure! < 3000) return _denemeState.add(5);

      _denemeState.add(1);

      testSuresi = icindekilerItem!.denemeDurationMillisecond;

      timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        gecenSure = realTime() - userDenemeStartTime!;
        cevaplariHesapla();

        if (gecenSure! > testSuresi || realTime() > icindekilerItem!.denemeEndTime!) {
          SendResult.send(false, icindekilerItem!, kitapBilgileri.bookKey).then((value) => _denemeState.add(3)).unawaited;
          timer.cancel();
          await 5000.wait;
          _denemeState.add(3);
        }
        _sure.add(true);
      });
    } else {
      testSuresi = getTest!.sure! * 60000;

      timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
        if (!testCozuldu! && !testPaused) {
          gecenSure = gecenSure! + 1000;
          if (gecenSure! >= testSuresi) {
            timer.cancel();
          }
          _sure.add(true);
        }
      });
    }
  }

  Future<void> deleteSecenek(int? questionNo) async {
    if (testCozuldu!) return;
    if (questionNo == secilenSoruIndex) {
      secenekDurumu = {"A": 0, "B": 0, "C": 0, "D": 0, "E": 0};
    } else {
      secenekDurumuCache[questionNo] = {"A": 0, "B": 0, "C": 0, "D": 0, "E": 0};
    }

    setSoruYenile.add(true);
    await Future.delayed(const Duration(milliseconds: 222));

    isaretlenenCevaplarList[questionNo!] = ' ';
    _isaretlenenCevaplar.add(true);

    if (kitapBilgileri.isDeneme) cevaplariHesapla();
  }

  Future<void> clickSecenek(String? secenek, BuildContext context) async {
    if (testCozuldu!) return;

    ekranUstuYazma = false;
    drawImg = null;

    for (var i = 0; i < 5; i++) {
      if (secenek != "ABCDE"[i]) {
        secenekDurumu["ABCDE"[i]] = 1;
      }
    }
    setSoruYenile.add(true);
    await Future.delayed(const Duration(milliseconds: 222));

    isaretlenenCevaplarList[secilenSoruIndex!] = secenek;
    _isaretlenenCevaplar.add(true);

    if (kitapBilgileri.isDeneme) cevaplariHesapla();

    for (int i = secilenSoruIndex! + 1; i < isaretlenenCevaplarList.length; i++) {
      if (isaretlenenCevaplarList[i] == " ") {
        clickQuestion(i);
        return;
      }
    }
    for (int i = 0; i < secilenSoruIndex! + 1; i++) {
      if (isaretlenenCevaplarList[i] == " ") {
        clickQuestion(i);
        return;
      }
    }

    OverAlert.show(message: 'noemptyquestion'.translate);

    // clickQuestion(0,context);
  }

  void clickQuestion(int? questionNo) {
    if (questionNo == secilenSoruIndex) {
      return;
    }

    //todo asagisi sadece klasik sorulara gore ayarlanabilir
    secenekDurumuCache[secilenSoruIndex] = secenekDurumu;
    secenekDurumu = secenekDurumuCache[questionNo] ?? {"A": 0, "B": 0, "C": 0, "D": 0, "E": 0};
    if (isaretlenenCevaplarList[questionNo!] != " ") {
      secenekDurumu["A"] = isaretlenenCevaplarList[questionNo] == "A" ? 0 : 1;
      secenekDurumu["B"] = isaretlenenCevaplarList[questionNo] == "B" ? 0 : 1;
      secenekDurumu["C"] = isaretlenenCevaplarList[questionNo] == "C" ? 0 : 1;
      secenekDurumu["D"] = isaretlenenCevaplarList[questionNo] == "D" ? 0 : 1;
      secenekDurumu["E"] = isaretlenenCevaplarList[questionNo] == "E" ? 0 : 1;
    }
    if (testCozuldu!) {
      secenekDurumu[getTest!.questions[questionNo].answer.option] = 0;
    }

    secilenSoruIndex = questionNo;
    setSoruYenile.add(true);

    if (scaffoldKey.currentState!.isEndDrawerOpen) {
      Get.back();
    }
    scrollController.animateTo(70.0 * (secilenSoruIndex! - 1), duration: const Duration(milliseconds: 250), curve: Curves.linear);
  }

  void alertTestiKontrolEtSifirla(BuildContext mainContext, int tur) {
    String testBitirmeMesaji = 'testfinishsure'.translate;
    if (tur == 0) {
      int count = 0;
      for (var i = 0; i < isaretlenenCevaplarList.length; i++) {
        if (isaretlenenCevaplarList[i] == " ") {
          count++;
        }
      }
      if (count > 0) {
        testBitirmeMesaji = "$count ${'testfinishwarning'.translate}\n" + testBitirmeMesaji;
      }
    }

    Over.sure(
      primaryColor: theme!.bookColor,
      message: tur == 0 ? testBitirmeMesaji : 'testresetsure'.translate,
      cancelText: 'no'.translate,
      yesText: 'yes'.translate,
    ).then((sure) {
      if (sure) {
        tur == 0 ? testiKontrolEt(sendStatistics: true) : testiSifirla();
      }
    });
  }

  void cevaplariHesapla() {
    dogruSayisi = 0;
    yanlisSayisi = 0;
    bosSayisi = 0;
    doruYanlisBosText = ''; //Hangi sorularin dogru yanlis oldugunu databae e yollamak icin kaydeder

    for (var i = 0; i < isaretlenenCevaplarList.length; i++) {
      if (isaretlenenCevaplarList[i] == " ") {
        bosSayisi++;
        doruYanlisBosText += 'B';
      } else if (getTest!.questions[i].questionType != QuestionType.SECENEKLI) {
        bosSayisi++;
        doruYanlisBosText += 'B';
      } else if (isaretlenenCevaplarList[i] == getTest!.questions[i].answer.option) {
        dogruSayisi++;
        doruYanlisBosText += 'D';
      } else {
        yanlisSayisi++;
        doruYanlisBosText += 'Y';
      }
    }
    if (kitapBilgileri.isDeneme) {
      Get.openSafeBox('${kitapBilgileri.bookKey}${icindekilerItem!.denemeKey}answerresult').then((box) => box.put(testKey, {'data1': doruYanlisBosText}));
    }
  }

  void testiKontrolEt({bool sendStatistics = false}) {
    cevaplariHesapla();

    testCozuldu = true;
    _testYenile.add(10); // Testi yenilemek için

    saveState();

    Fav.preferences.setBool("${testKey}_test_cozuldu", true);

    if (sendStatistics && hesapBilgileri!.uid != null) {
      Map<String, dynamic> statisticsData = {"ds": dogruSayisi, "ys": yanlisSayisi, "bs": bosSayisi, "sure": gecenSure};

      QBSetDataService.sendStudentStatistics(statisticsData, kitapBilgileri.bookKey, testKey, hesapBilgileri!.uid!);

      if (!qbankBloc.hesapBilgileri.isQbank && qbankBloc.hesapBilgileri.ekolUid.safeLength > 2) {
        QBSetDataService.sendSchoolTestStatistics(statisticsData..['results'] = doruYanlisBosText, kitapBilgileri.bookKey, testKey, hesapBilgileri!.kurumID!, hesapBilgileri!.ekolUid!);
      }
    }
  }

  void testiSifirla() {
    Fav.preferences.setBool("${testKey}_test_cozuldu", false);

    Fav.preferences.setString(hesapBilgileri!.uid! + "_" + testKey, "");
    gecenSure = 0;
    testCozuldu = false;
    dogruSayisi = 0;
    yanlisSayisi = 0;
    bosSayisi = 0;
    for (int i = 0; i < isaretlenenCevaplarList.length; i++) {
      isaretlenenCevaplarList[i] = " ";
    }
    secenekDurumuCache = {};
    clickQuestion(0);

    _testYenile.add(10); // Testi yenilemek için
    sureyiCalistir();
  }

  void dispose() {
    saveState();
    _testYenile.close();
    _denemeState.close();
    _isaretlenenCevaplar.close();
    _soruYenile.close();
    _sure.close();
    //  _testPreview.close();
    _openDrawPanel.close();
    _secenekleriYenile.close();
    WidgetsBinding.instance.removeObserver(this);
  }

  void saveState() {
    Map<String, String?> isaretlemeListesi = {};
    Map<String, dynamic> state = {};

    for (var i = 0; i < getTest!.count; i++) {
      final Question question = getTest!.questions[i];
      isaretlemeListesi[question.key] = isaretlenenCevaplarList[i];
    }

    state["isaretlemeListesi"] = isaretlemeListesi;
    state["sure"] = gecenSure;
    state["testCozuldu"] = testCozuldu;

    if (kitapBilgileri.isDeneme) cevaplariHesapla();

    Fav.preferences.setString(hesapBilgileri!.uid.toString() + "_" + getTest!.testKey.toString(), jsonEncode(state));
  }

  void _getState(Test test) {
    String stateText = Fav.preferences.getString(hesapBilgileri!.uid.toString() + "_" + test.testKey!) ?? "";

    if (stateText.length < 6) return;

    Map<String, dynamic> state = json.decode(stateText);

    for (var i = 0; i < test.count; i++) {
      final Question question = test.questions[i];
      if (state["isaretlemeListesi"].containsKey(question.key)) {
        isaretlenenCevaplarList[i] = state["isaretlemeListesi"][question.key];
      }
    }

    gecenSure = state["sure"];
    testCozuldu = state["testCozuldu"];

    if (testCozuldu!) {
      testiKontrolEt(sendStatistics: false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // Uygulama sanırsam gözüküyor ama tıklanamıyor. Görev yöneticisindeki gibi
      testiDurdur();
    } else if (state == AppLifecycleState.paused) {
      testiDurdur();

      // Uygulama gözükmüyor. Arkapland
    } else if (state == AppLifecycleState.resumed) {
      //  setTestPreview.add(false);
      //Uygulama çalışıyor
    }
  }

  Future<void> onBackPressed() async {
    final _sure = await Over.sure(title: 'generallyquitsure'.translate, cancelText: 'no'.translate);
    if (_sure == true) {
      saveState();
      timer?.cancel();
      Get.back();
    }
  }

  void testiDurdur() {
    saveState();
    if (testPaused) return;

    testPaused = true;

    Get.dialog(
      WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                  onTap: () {
                    testPaused = false;
                    Get.back();
                  },
                  child: MyFlareIndicator(child: const Icon(Icons.play_arrow, color: Colors.white))))),
    );
  }
}
