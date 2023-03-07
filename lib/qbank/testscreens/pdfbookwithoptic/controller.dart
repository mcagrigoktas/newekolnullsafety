// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdfx/pdfx.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/accountdata.dart';
import '../../models/models.dart';
import '../../qbankbloc/setdataservice.dart';
import '../../screens/bookpreviewspage/bookpreviewspage.dart';
import '../common/model.dart';
import '../common/pdfcontroller/native_pdf_view.dart';

//!Testi kondrol et kisminda kaldim
class PdfBookWithOpticController extends GetxController {
  Kitap? book;
  IcindekilerModel? icindekilerModel;
  IcindekilerItem? icindekilerItem;
  bool isPdfPreparing = true;
  PdfBookViewController? pdfController;
  int get startPageForPdf => icindekilerItem!.startPageForPdf ?? 1;
  int get endPageForPdf => icindekilerItem!.endPageForPdf ?? 1;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  QBankHesapBilgileri get hesapBilgileri => AppVar.qbankBloc.hesapBilgileri;
  PdfBookWithOpticController({this.book, this.icindekilerModel, this.icindekilerItem});
  bool? get testCozuldu => Fav.preferences.getBool(testSaveKey + 'testCozuldu', false);
  bool testPaused = false;

  //! buraya test key  lazim
  String get testSaveKey => book!.bookKey + testResultSaveKey! + (hesapBilgileri.uid ?? '');
  String? get testResultSaveKey => icindekilerItem!.answerKey!.testKey;

  late List<MapEntry<String, AnswerKeyItem>> answerKeyItemsEntries;

  @override
  void onClose() {
    _saveState();
    super.onClose();
  }

  @override
  void onInit() {
    answerKeyItemsEntries = icindekilerItem!.answerKey!.answerKeyItems!.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    _downloadPdf();
    super.onInit();
  }

  Timer? timer;
  void _startClock() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      if (!testCozuldu! && !testPaused) {
        gecenSure = gecenSure + 1000;
      }
    });
  }

  MyFile? _bookLet;
  Future<void> _downloadPdf() async {
    _bookLet = await DownloadManager.downloadThenCache(url: icindekilerModel!.pdfUrl!);
    pdfController = PdfBookViewController(document: PdfDocument.openData(_bookLet!.byteData), initialPage: startPageForPdf);
    isPdfPreparing = false;
    _startClock();
    _getState();
    update();
  }

  void documentLoaded(PdfDocument? doc) {
    111.wait.then((value) {
      pdfController!.jumpToPage(startPageForPdf);
      update();
    });
  }

  void nextPage() {
    if (pdfController!.page + 1 > endPageForPdf) {
      OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
    } else {
      pdfController!.nextPage(duration: 444.milliseconds, curve: Curves.ease).then((value) => update());
    }
  }

  void previousPage() {
    if (pdfController!.page - 1 < startPageForPdf) {
      OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
    } else {
      pdfController!.previousPage(duration: 444.milliseconds, curve: Curves.ease).then((value) => update());
    }
  }

  String get pageNoText {
    if ((pdfController?.page == null)) return 'page'.translate;
    int pageNo = (pdfController!.page - (startPageForPdf - 1));
    if (pageNo < 1) pageNo = 1;

    return 'page'.translate + ' ' + pageNo.toString() + '/' + (endPageForPdf - startPageForPdf + 1).toString();
  }

  Future<void> alertTestiKontrolEtSifirla(int tur) async {
    final _value = await OverBottomSheet.show(BottomSheetPanel.simpleList(title: tur == 0 ? 'testfinishsure'.translate : 'testresetsure'.translate, items: [
      BottomSheetItem(name: 'yes'.translate, value: true),
      BottomSheetItem.cancel(),
    ]));

    if (_value == true) {
      tur == 0 ? _testiKontrolEt() : _testiSifirla();
    }
  }

  void _testiKontrolEt({bool sendStatistics = true}) {
    _cevaplariHesapla();

    Fav.preferences.setBool(testSaveKey + 'testCozuldu', true);

    if (sendStatistics && hesapBilgileri.uid.safeLength > 2) {
      Map<String, dynamic> statisticsData = {"ds": dogruSayisi, "ys": yanlisSayisi, "bs": bosSayisi, "sure": gecenSure.value};

      QBSetDataService.sendStudentStatistics(statisticsData, book!.bookKey, testResultSaveKey!, hesapBilgileri.uid!);

      if (!AppVar.qbankBloc.hesapBilgileri.isQbank && AppVar.qbankBloc.hesapBilgileri.ekolUid.safeLength > 2) {
        QBSetDataService.sendSchoolTestStatistics(
            statisticsData
              ..['answers'] = answerKeyData
              ..['realAnswers'] = icindekilerItem!.answerKey!.toJson(),
            book!.bookKey,
            testResultSaveKey!,
            hesapBilgileri.kurumID!,
            hesapBilgileri.ekolUid!);
      }
    }
    update();
  }

  void _testiSifirla() {
    Fav.preferences.setBool(testSaveKey + 'testCozuldu', false);

    Fav.preferences.setString(testSaveKey + 'State', ""); //State
    gecenSure.value = 0;

    dogruSayisi = 0;
    yanlisSayisi = 0;
    bosSayisi = 0;
    answerKeyData.clear();

    _startClock();
    if (scaffoldKey.currentState!.isEndDrawerOpen) Get.back();
    update();
  }

  RxInt gecenSure = 0.obs;
  int? dogruSayisi;
  int? yanlisSayisi;
  int? bosSayisi;
  void _cevaplariHesapla() {
    dogruSayisi = 0;
    yanlisSayisi = 0;
    bosSayisi = 0;

    final _realAnswersKeys = icindekilerItem!.answerKey!.answerKeyItems!.keys.toList();

    for (var i = 0; i < _realAnswersKeys.length; i++) {
      String _questionKey = _realAnswersKeys[i];
      final _answer = (answerKeyData[_questionKey] ?? '').toLowerCase().trim();
      final _realAnswer = icindekilerItem!.answerKey!.answerKeyItems![_questionKey]!.answer!.toLowerCase().trim();
      if (_answer.trim().isEmpty) {
        bosSayisi = bosSayisi! + 1;
      } else if (_answer == _realAnswer) {
        dogruSayisi = dogruSayisi! + 1;
      } else {
        yanlisSayisi = yanlisSayisi! + 1;
      }
    }
  }

  void _getState() {
    String? stateText = Fav.preferences.getString(testSaveKey + 'State');

    if (stateText.safeLength < 6) return;

    Map<String, dynamic> state = json.decode(stateText!);

    gecenSure.value = state["sure"];
    answerKeyData = Map<String, String>.from(state["answers"] ?? {});

    if (testCozuldu!) {
      _testiKontrolEt(sendStatistics: false);
    }
  }

  void _saveState() {
    Map<String, dynamic> state = {};

    state["answers"] = answerKeyData;
    state["sure"] = gecenSure.value;

    Fav.preferences.setString(testSaveKey + 'State', jsonEncode(state));
  }

  void _testiDurdur() {
    _saveState();
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

  int get questionCount => answerKeyItemsEntries.length;
  int? get numberOfOptions => icindekilerItem!.answerKey!.optionCount;
  Map<String, String> answerKeyData = {};
}
