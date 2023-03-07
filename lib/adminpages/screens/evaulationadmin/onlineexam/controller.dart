import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/mybutton.dart';
import 'package:rxdart/subjects.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../exams/bookletdefine/model.dart';
import '../examtypes/model.dart';
import 'fullpdftestpage/controller.dart';
import 'fullpdftestpage/layout.dart';
import 'fullpdftestpage/model.dart';

class OnlineExamController extends GetxController {
  final PublishSubject<DenemeEvent> denemeSubject = PublishSubject<DenemeEvent>();

  final bool isBookletReviewing;
  final Map? _onlineExamData;

  ///notification  haricide yollasan examtype ve  onlineformdata gelmeli
  ExamType get examType => ExamType.fromJson(_onlineExamData!['examType'], null);
  BookLetModel get bookLetData => BookLetModel.fromJson(_onlineExamData!['onlineForms']['seison$seisonNo']);

  ///Sinav sirasinda yeni notificationGelirse
  BookLetModel? get newBookLetData => isBookletReviewing
      ? bookLetData
      : examAnnouncement == null
          ? null
          : examAnnouncement!.extraData == null
              ? null
              : examAnnouncement!.extraData!['onlineForms'] == null
                  ? null
                  : examAnnouncement!.extraData!['onlineForms']['seison$seisonNo'] == null
                      ? null
                      : BookLetModel.fromJson(examAnnouncement!.extraData!['onlineForms']['seison$seisonNo']);

  String examKey;
  int? seisonNo;
  OnlineExamController(this._onlineExamData, this.examKey, this.seisonNo, {this.isBookletReviewing = false});

  bool isBookletDownloading = true;
  bool saveLoading = false;

  Announcement? examAnnouncement;
  ExamTypeLesson? lessonData(String? lessonKey) => examType.lessons!.firstWhereOrNull((element) => element.key == lessonKey);
  int solvedQuestionCount(String? lessonKey) {
    final answers = answerKeyData[lessonKey];
    if (answers == null) return 0;
    return answers.replaceAll(' ', '').length;
  }

  String get preferencesSaveKey => isBookletReviewing ? 'reviewKey$examKey' : examKey + AppVar.appBloc.hesapBilgileri.girisTuru.toString() + AppVar.appBloc.hesapBilgileri.uid! + 'answerKeyDataSeison$seisonNo';

  Uint8List? activePdfData;
  String? activeLessonKey;

  Map<String?, String> answerKeyData = {};
  StreamSubscription? subscription;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();

    activeLessonKey = examType.lessons!.where((element) => bookLetData.lessonBookLetFiles!.keys.contains(element.key)).first.key;

    if (Fav.preferences.getString(preferencesSaveKey) != null) {
      answerKeyData = Map<String?, String>.from(json.decode(Fav.preferences.getString(preferencesSaveKey).unMix!));
    }

    if (!isBookletReviewing) {
      examAnnouncement = AppVar.appBloc.announcementService!.dataListItem(examKey);
      subscription = AppVar.appBloc.announcementService!.stream.listen((event) async {
        await 100.wait;
        examAnnouncement = AppVar.appBloc.announcementService!.dataListItem(examKey);
        await 100.wait;
        if (newBookLetData?.notificationRole?.isVisibleBooklet != true) {
          denemeSubject.add(DenemeEvent.closeBooklet);
        }
        if (newBookLetData?.notificationRole?.examStarting == true) {
          denemeSubject.add(DenemeEvent.opticFormEnable);
        } else {
          denemeSubject.add(DenemeEvent.opticFormDisable);
        }
        await 100.wait;
        update();
      });
    }
    downloadAllBookLets();

    timer = Timer.periodic(60.seconds, (timer) {
      calcDurationText();
    });
  }

  String durationText = '';
  void calcDurationText() {
    if (newBookLetData!.notificationRole.examStarting) {
      final time = (newBookLetData!.examFormClosedTime ?? 0) + (newBookLetData!.examFormEkstraTime ?? 0) - DateTime.now().millisecondsSinceEpoch;
      if (time < 0) {
        durationText = '';
      } else {
        durationText = Duration(milliseconds: time).inMinutes.toString() + ' ' + 'minute'.translate;
      }
    } else {
      durationText = '';
    }
    denemeSubject.add(DenemeEvent.durationChanged);
  }

  @override
  void onClose() {
    subscription?.cancel();
    timer?.cancel();
    super.onClose();
  }

  Map<String?, Uint8List> bookletPdfFiles = {};
  Future<void> downloadAllBookLets() async {
    if (bookLetData.isOnlyMainBooklet!) {
      final mainFile = await downloadBooklet(bookLetData.mainBookLetFile!.pdfUrlList);
      if (mainFile == null) {
        Get.back();
        'filedownloaderr'.translate.showAlert();
        return;
      }

      try {
        await 222.wait;
        activePdfData = mainFile.byteData.decryptToUint8List(Get.appController.commonEncryptKey);
      } catch (err) {
        Get.back();
        'filecorrupted'.translate.showAlert();
      }
    } else {
      final entries = bookLetData.lessonBookLetFiles!.entries.toList();
      for (var e = 0; e < entries.length; e++) {
        final bookLetFile = entries[e].value;
        final file = await (downloadBooklet(bookLetFile.pdfUrlList));
        if (file == null) {
          Get.back();
          'filedownloaderr'.translate.showAlert();
        }
        try {
          await 222.wait;
          bookletPdfFiles[entries[e].key] = file!.byteData.decryptToUint8List(Get.appController.commonEncryptKey);
        } catch (err) {
          Get.back();
          'filecorrupted'.translate.showAlert();
          break;
        }
      }
      activePdfData = bookletPdfFiles[activeLessonKey];
    }
    isBookletDownloading = false;
    update();
  }

  Future<MyFile?> downloadBooklet(List<String>? list) async {
    if (list == null || list.isEmpty) return null;
    List<String> urlList = List<String>.from(list);
    for (var i = 0; i < urlList.length; i++) {
      String url = urlList[i];
      if (url.contains('digitaloceanspaces') && !url.contains('cdn')) {
        urlList.add(url.replaceAll('digitaloceanspaces', 'cdn.digitaloceanspaces'));
        urlList.add(url.replaceAll('digitaloceanspaces', 'cdn.digitaloceanspaces'));
      }
    }

    for (String url in urlList) {
      final existingBookLet = await DownloadManager.getCacheData(url: url);
      if (existingBookLet != null) {
        return existingBookLet;
      } else {}
    }
    urlList.shuffle();
    for (String url in urlList) {
      final downloaded = await DownloadManager.downloadThenCache(url: url);
      if (downloaded != null) {
        return downloaded;
      } else {}
    }
    return null;
  }

  void initLessonAnswerKeyData() {
    if (answerKeyData[activeLessonKey] == null) {
      final activeLessonData = examType.lessons!.singleWhereOrNull((element) => element.key == activeLessonKey)!;
      answerKeyData[activeLessonKey] = Iterable.generate(activeLessonData.questionCount!).fold<String>('', (p, _) => p + ' ');
    }
  }

  int get getFirstQuestionNo => bookLetData.lessonBookLetFiles![activeLessonKey]!.firstQuestionNo ?? 1;

  Future<void> clickLesson(String? lessonKey) async {
    activeLessonKey = lessonKey;
    initLessonAnswerKeyData();
    final int initialPageNo = bookLetData.isOnlyMainBooklet! ? bookLetData.lessonBookLetFiles![lessonKey]!.startPageNo! + bookLetData.examBookLetExtraPage! : 1;
    if (!bookLetData.isOnlyMainBooklet!) {
      activePdfData = bookletPdfFiles[lessonKey];
    }

    await Fav.to(FullPdfTestPage(),
        binding: BindingsBuilder(() => Get.put<FullPdfTestPageController>(FullPdfTestPageController(
              pdfData: activePdfData,
              entryType: EntryType.deneme,
              answerKeyData: answerKeyData,
              testKey: activeLessonKey,
              preferencesSaveKey: preferencesSaveKey,
              initialPdfPageNo: initialPageNo,
              firstQuestionNo: getFirstQuestionNo,
              numberOfOptions: lessonData(activeLessonKey)!.numberOfOptions,
              questionCount: answerKeyData[activeLessonKey]!.length,
              wQuestionCount: lessonData(activeLessonKey)!.wQuestionCount ?? 0,
              pdfStartPageNo: bookLetData.lessonBookLetFiles![lessonKey]!.startPageNo,
              pdfEndPageNo: bookLetData.lessonBookLetFiles![lessonKey]!.endPageNo,
              pdfExtraPageNo: bookLetData.examBookLetExtraPage,
              testName: lessonData(activeLessonKey)!.name,
              isOpticFormClickable: !dataSended! && newBookLetData!.notificationRole.examStarting,
            ))));
    update();
  }

  String get examStartTime {
    return 'examstarttime'.translate + ': ' + newBookLetData!.examBookLetVisibleTime!.dateFormat('d-MMM, HH:mm');
  }

  String get examEndTime {
    return 'examfinishtime'.translate + ': ' + newBookLetData!.examFormClosedTime!.dateFormat('d-MMM, HH:mm');
  }

  Widget get sendExamDataForReviewWidget {
    if (!AppVar.appBloc.hesapBilgileri.gtS) return const SizedBox();
    if (newBookLetData == null) return const SizedBox();
    if (dataSended!) return 'sendedexamdataforreview'.translate.text.color(Colors.white).make().stadium();

    if (newBookLetData!.notificationRole == NotificationRole.invisibleBookLet) return const SizedBox();
    if (newBookLetData!.notificationRole.examStarting) {
      return MyRaisedButton(
        text: 'sendexamdataforreview'.translate,
        onPressed: () async {
          var sure = await Over.sure(message: 'sendexamdataforreviewhint'.translate);
          if (sure == true) await sendExamDataForReview();
        },
      );
    }

    if (newBookLetData!.notificationRole.examEnding) return 'finishexamtime'.translate.text.color(Colors.white).make().stadium(background: Colors.blueAccent);
    return const SizedBox();
  }

  String get sendDataPreferencesKey => AppVar.appBloc.hesapBilgileri.kurumID! + AppVar.appBloc.hesapBilgileri.uid! + examKey + 'seison$seisonNo' + 'sendedStudentExamData';
  bool? get dataSended => Fav.preferences.getBool(sendDataPreferencesKey, false);

  Future<void> sendExamDataForReview() async {
    if (Fav.noConnection()) return;
    if (!AppVar.appBloc.hesapBilgileri.gtS) return;
    if (dataSended == true) {
      'sendedexamreviewerr'.translate.showAlert();
      return;
    }
    OverLoading.show();
    await ExamService.saveOnlineExamStudentsAnswer(examKey, answerKeyData, 'seison$seisonNo').then((_) {
      Fav.preferences.setBool(sendDataPreferencesKey, true);
      OverAlert.saveSuc();
    }).catchError((err) {
      if (err.toString().contains('ermission')) {
        'sendedexamreviewerr'.translate.showAlert();
      } else {
        OverAlert.saveErr();
      }
    });
    await OverLoading.close();
  }
}

enum DenemeEvent {
  durationChanged,
  closeBooklet,
  opticFormEnable,
  opticFormDisable,
}
