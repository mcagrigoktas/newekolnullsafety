import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdfx/pdfx.dart';

import '../../screens/bookpreviewspage/bookpreviewspage.dart';
import '../common/pdfcontroller/native_pdf_view.dart';

class PdfBookController extends GetxController {
  //? Url yada bytedata yollayabilirsin
  final String? pdfUrl;
  final Uint8List? byteData;

  IcindekilerItem? icindekilerItem;
  bool isPdfPreparing = true;
  PdfBookViewController? pdfController;

  final int? startPageForPdf;
  final int? endPageForPdf;

  PdfBookController({this.pdfUrl, this.byteData, this.startPageForPdf = 1, this.endPageForPdf = 1});
  @override
  void onInit() {
    assert(pdfUrl != null || byteData != null);
    if (byteData != null) {
      pdfController = PdfBookViewController(document: PdfDocument.openData(byteData!), initialPage: startPageForPdf!);
      isPdfPreparing = false;
    } else {
      _downloadPdf();
    }
    super.onInit();
  }

  MyFile? _bookLet;
  Future<void> _downloadPdf() async {
    _bookLet = await DownloadManager.downloadThenCache(url: pdfUrl!);

    pdfController = PdfBookViewController(document: PdfDocument.openData(_bookLet!.byteData), initialPage: startPageForPdf!);
    isPdfPreparing = false;
    update();
  }

  void documentLoaded(PdfDocument? doc) {
    111.wait.then((value) {
      pdfController!.jumpToPage(startPageForPdf!);
      update();
    });
  }

  void nextPage() {
    if (endPageForPdf != null && pdfController!.page + 1 > endPageForPdf!) {
      OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
    } else {
      pdfController!.nextPage(duration: 444.milliseconds, curve: Curves.ease).then((value) {
        update();
      });
    }
  }

  void previousPage() {
    if (startPageForPdf != null && pdfController!.page - 1 < startPageForPdf!) {
      OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
    } else {
      pdfController!.previousPage(duration: 444.milliseconds, curve: Curves.ease).then((value) {
        update();
      });
    }
  }

  void goPage(String pageNo) {
    final _pageNo = int.tryParse(pageNo);
    if (_pageNo == null) return;
    if (_pageNo < 1) return;
    log(_pageNo);
    if (endPageForPdf != null && _pageNo > endPageForPdf!) {
      OverAlert.show(message: 'morepageempty'.translate, type: AlertType.danger);
    } else {
      log(startPageForPdf! + _pageNo - 1);
      // pdfController.animateToPage((startPageForPdf + _pageNo - 1), duration: 444.milliseconds, curve: Curves.ease).then((value) {
      //   update();
      // });
      pdfController!.jumpToPage((startPageForPdf! + _pageNo - 1));
      update();
    }
  }

  String get pageNoText {
    if ((pdfController?.page == null)) return 'page'.translate;
    int pageNo = (pdfController!.page - (startPageForPdf! - 1));
    if (pageNo < 1) pageNo = 1;

    return 'page'.translate + ' ' + pageNo.toString() + '/' + (endPageForPdf! - startPageForPdf! + 1).toString();
  }

  // void changeScale() {
  //   final _scaleState = pdfController.scaleStateController.scaleState;
  //   if (pdfController.scaleStateController.scaleState == PhotoViewScaleState.initial) {
  //     pdfController.scaleStateController.scaleState = PhotoViewScaleState.covering;
  //   } else if (_scaleState == PhotoViewScaleState.covering) {
  //     pdfController.scaleStateController.scaleState = PhotoViewScaleState.originalSize;
  //   } else {
  //     pdfController.scaleStateController.scaleState = PhotoViewScaleState.initial;
  //   }
  // }

  double scaledValue = 1.0;
  void changeScaleValue(double value) {
    scaledValue = value;
    pdfController!.photoViewController.scale = scaledValue;
  }
}
