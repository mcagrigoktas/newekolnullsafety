import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdfx/pdfx.dart' show PdfDocument;

import '../../../../../qbank/testscreens/pdfbook/controller.dart';
import '../controller.dart';
import 'model.dart';

class FullPdfTestPageController extends GetxController {
  final Uint8List? pdfData;
  final String? testKey;
  final int? questionCount;
  final int? wQuestionCount;
  final int? numberOfOptions;
  final int? pdfStartPageNo;
  final int? pdfEndPageNo;

  ///Pdf sayfa no ilk  sayffadan baslamazsa  baslamazsa
  final int? pdfExtraPageNo;
  final String? preferencesSaveKey;
  PdfBookController? pdfController;

  ///Kitapcikta bazi derslerin  ilk  soru numarai 15 falan olabilir o souryu  1 no gostermek icin
  final int? firstQuestionNo;
  final EntryType? entryType;

  final Map<String?, String> answerKeyData;
  final int? initialPdfPageNo;
  final String? testName;
  bool isOpticFormClickable;

  StreamSubscription? denemeStateSubscription;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  FullPdfTestPageController({
    this.pdfData,
    this.testKey,
    this.firstQuestionNo,
    this.entryType,
    this.questionCount,
    this.wQuestionCount,
    this.numberOfOptions,
    this.pdfStartPageNo,
    this.pdfEndPageNo,
    this.preferencesSaveKey,
    this.pdfExtraPageNo = 0,
    this.initialPdfPageNo,
    this.answerKeyData = const {},
    this.testName = '',
    this.isOpticFormClickable = true,
  });

  @override
  void onInit() {
    pdfController = PdfBookController(byteData: pdfData, startPageForPdf: pdfStartPageNo! + pdfExtraPageNo!, endPageForPdf: pdfEndPageNo! + pdfExtraPageNo!);
    if (Get.isRegistered<PdfBookController>()) Get.delete<PdfBookController>();
    Get.put<PdfBookController?>(pdfController);

    if (entryType == EntryType.deneme) {
      denemeStateSubscription = Get.find<OnlineExamController>().denemeSubject.listen((value) {
        if (value == DenemeEvent.durationChanged) {
          update();
        } else if (value == DenemeEvent.closeBooklet) {
          Get.back();
        } else if (value == DenemeEvent.opticFormEnable) {
          isOpticFormClickable = true;
          update();
        } else if (value == DenemeEvent.opticFormDisable) {
          isOpticFormClickable = false;
          update();
        }
      });
    }

    super.onInit();
  }

  @override
  void dispose() {
    denemeStateSubscription?.cancel();
    super.dispose();
  }

  // void nextPage() {
  //   if (pdfEndPageNo != null && pdfController.page + 1 > pdfEndPageNo + pdfExtraPageNo) {
  //     OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
  //   } else {
  //     pdfController.nextPage(duration: 444.milliseconds, curve: Curves.ease).then((value) => update());
  //   }
  // }

  // void previousPage() {
  //   if (pdfStartPageNo != null && pdfController.page - 1 < pdfStartPageNo + pdfExtraPageNo) {
  //     OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
  //   } else {
  //     pdfController.previousPage(duration: 444.milliseconds, curve: Curves.ease).then((value) => update());
  //   }
  // }

  // String get pageNoText {
  //   if (pdfStartPageNo != null && pdfEndPageNo != null) {
  //     if ((pdfController?.page == null)) return 'page'.translate;
  //     int pageNo = (pdfController.page - (pdfStartPageNo + pdfExtraPageNo - 1));
  //     if (pageNo < 1) pageNo = 1;

  //     return testKey == null ? '' : 'page'.translate + ' ' + pageNo.toString() + '/' + (pdfEndPageNo - pdfStartPageNo + 1).toString();
  //   } else {
  //     if ((pdfController?.pagesCount == null)) return 'page'.translate;
  //     return testKey == null ? '' : 'page'.translate + ' ' + pdfController.page.toString() + '/' + pdfController.pagesCount.toString();
  //   }
  // }

  void clickAnswer(int no, String answer) {
    if (answerKeyData[testKey]!.substring(no, no + 1) == answer) {
      answerKeyData[testKey] = answerKeyData[testKey].changeCharacter(no, ' ');
    } else {
      answerKeyData[testKey] = answerKeyData[testKey].changeCharacter(no, answer);
    }

    Fav.preferences.setString(preferencesSaveKey!, json.encode(answerKeyData).mix!);
    update();
  }

  void wQuestionOnChange(String lessonKey, int no, String value) {
    answerKeyData[lessonKey + '-w$no'] = value;
    Fav.preferences.setString(preferencesSaveKey!, json.encode(answerKeyData).mix!);
  }

  String getWQuestionAnswer(String lessonKey, int no) {
    return answerKeyData[lessonKey + '-w$no'] ?? '';
  }

  String durationText() {
    if (entryType == EntryType.deneme) {
      return Get.find<OnlineExamController>().durationText;
    } else {
      ///todo  buraya  deneme harici  girisllerde sure lazimsa koy
      return '';
    }
  }

  void documentLoaded(PdfDocument doc) {
    111.wait.then((value) {
      pdfController!.goPage(initialPdfPageNo.toString());
      update();
    });
  }
}
