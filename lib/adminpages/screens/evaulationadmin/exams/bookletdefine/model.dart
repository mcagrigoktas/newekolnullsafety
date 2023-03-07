import 'package:mcg_extension/mcg_extension.dart';

class BookLetModel {
  int? lastUpdate;
  Exambookletlocation? exambookletlocation;

  int? examBookLetVisibleTime;
  int? examFormClosedTime;
  int? examFormEkstraTime;

  int? examBookLetExtraPage;

  bool? bookletIsDownladable;

  /// true Butun dersller icin tek kitapcik false her  ders icin ayri kitapcik
  bool? isOnlyMainBooklet;

  BookLetFile? mainBookLetFile;
  NotificationRole? notificationRole;

  ///lessonkey=>bookletfiles
  Map<String?, BookLetFile>? lessonBookLetFiles;
  BookLetModel({this.lastUpdate});

  BookLetModel.fromJson(Map snapshot) {
    lastUpdate = snapshot['lastUpdate'];
    exambookletlocation = snapshot['eBL'] == null ? Exambookletlocation.pdf : Exambookletlocation.values.singleWhereOrNull((element) => element.toString() == snapshot['eBL']);
    bookletIsDownladable = snapshot['bID'] ?? false;
    isOnlyMainBooklet = snapshot['pOM'] ?? true;
    notificationRole = snapshot['nR'] == null ? NotificationRole.invisibleBookLet : NotificationRole.values.singleWhere((element) => element.toString() == snapshot['nR'], orElse: () => NotificationRole.invisibleBookLet);
    examFormEkstraTime = snapshot['eET'] ?? 0;
    examBookLetVisibleTime = snapshot['eVT'];
    examFormClosedTime = snapshot['eCT'];
    examBookLetExtraPage = snapshot['eBP'] ?? 0;
    mainBookLetFile = snapshot['mBL'] == null ? null : BookLetFile.fromJson(snapshot['mBL']);
    lessonBookLetFiles = snapshot['lBF'] == null ? null : (snapshot['lBF'] as Map).map((lessonKey, value) => MapEntry(lessonKey, BookLetFile.fromJson(value)));
  }

  Map<String, dynamic> mapForSave() {
    return {
      "lastUpdate": lastUpdate,
      "eBL": (exambookletlocation ?? Exambookletlocation.pdf).toString(),
      "bID": bookletIsDownladable,
      "pOM": isOnlyMainBooklet,
      "nR": notificationRole?.toString(),
      "eET": examFormEkstraTime,
      "eVT": examBookLetVisibleTime,
      "eCT": examFormClosedTime,
      "eBP": examBookLetExtraPage ?? 0,
      "mBL": mainBookLetFile?.mapForSave(),
      "lBF": lessonBookLetFiles?.map((lessonKey, value) => MapEntry(lessonKey, value.mapForSave())),
    };
  }

  Map<String, dynamic> mapForStudent() {
    return {
      "eBL": exambookletlocation?.toString(),
      "bID": bookletIsDownladable,
      "pOM": isOnlyMainBooklet,
      "nR": notificationRole?.toString(),
      "eET": examFormEkstraTime,
      "eVT": examBookLetVisibleTime,
      "eCT": examFormClosedTime,
      "eBP": examBookLetExtraPage ?? 0,
      "mBL": mainBookLetFile?.mapForSave(),
      "lBF": lessonBookLetFiles?.map((lessonKey, value) => MapEntry(lessonKey, value.mapForSave())),
    };
  }
}

enum Exambookletlocation {
  pdf,
  //qbank,
}

class BookLetFile {
  List<String>? pdfUrlList;
  String? fileName;
  String? sK;
  int? startPageNo;
  int? endPageNo;
  int? firstQuestionNo;

  BookLetFile({this.pdfUrlList, this.sK, this.startPageNo, this.endPageNo, this.fileName, this.firstQuestionNo});

  BookLetFile.fromJson(Map snapshot) {
    pdfUrlList = snapshot['pUL'] == null ? null : List<String>.from(snapshot['pUL']);
    fileName = snapshot['fileName'];
    sK = ((snapshot['sK'] as String?) ?? '').unMix;
    startPageNo = snapshot['sPN'];
    endPageNo = snapshot['ePN'];
    firstQuestionNo = snapshot['fQN'] ?? 1;
  }

  Map<String, dynamic> mapForSave() {
    return {
      "pUL": pdfUrlList,
      "fileName": fileName,
      "sK": sK?.mix,
      "sPN": startPageNo,
      "ePN": endPageNo,
      "fQN": firstQuestionNo,
    };
  }
}

enum NotificationRole {
  invisibleBookLet,
  downloadBookletNotVisible,

  visibleBookLetAndOpticForm, // Sinavi baslat
  onlySendResultButton,
  visibleBookLetAndInvisibleOpticForm, //Sinavi bitir
  invisibleBookLetAndInvisibleOpticForm, //Sinavi bitir kitapcigida kaldir
}

extension NotificationRoleExtension on NotificationRole? {
  bool get bookletMustAdded => this == NotificationRole.downloadBookletNotVisible || this == NotificationRole.onlySendResultButton || isVisibleBooklet;
  bool get isVisibleBooklet => this == NotificationRole.visibleBookLetAndOpticForm || this == NotificationRole.visibleBookLetAndInvisibleOpticForm;
  bool get examStarting => this == NotificationRole.visibleBookLetAndOpticForm;
  bool get examEnding => this == NotificationRole.visibleBookLetAndInvisibleOpticForm || this == NotificationRole.invisibleBookLetAndInvisibleOpticForm;
}
