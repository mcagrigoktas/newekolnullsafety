part of '../dataservice.dart';

class AccountingService {
  AccountingService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static dynamic get _realTime => databaseTime;
  static String get _uid => AppVar.appBloc.hesapBilgileri.uid!;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseAccountingg => AppVar.appBloc.databaseAccounting;

//! GETDATASERVICE
//Muhasebe fatura no ceker
  static Reference dbInvoiceNumber() => Reference(_databaseAccountingg, 'Okullar/$_kurumId/$_termKey/Kayitlar/faturaNo');

  //Ogrenci Muhasebe bilgilerini ceker
  static Reference dbStudentAccountingData(String studentKey) => Reference(_databaseAccountingg, 'Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey');

  //veli Muhasebe bilgilerini kontrol eder
  static Reference dbStudentAccountingReviewData() => Reference(_databaseAccountingg, 'Okullar/$_kurumId/$_termKey/StudentAccounting/$_uid/PaymentPlans');

  //Istatistikler icin tum muhasebe bilgilerini ceker
  static Reference dbAllStudentAccountingData() => Reference(_databaseAccountingg, 'Okullar/$_kurumId/$_termKey/StudentAccounting');

  //Butun makbuzlarin listesini ceker
  static Reference dbAllReceipt() => Reference(_databaseAccountingg, 'Okullar/$_kurumId/$_termKey/Logs/Faturalar');

  static Reference dbAccountingNote(String studentKey) => Reference(_databaseAccountingg, 'Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/Notes');

//! SETDATASERVICE

// Okul bilgilerine muhaseve kasa bilgilerini ekler
  static Future<void> saveAccountingCaseNames(data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/limits/cN'] = data;
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  // Okul bilgilerine odeme isim bilgilerini ekler
  static Future<void> saveAccountingPaymentNames(data) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/SchoolData/Info/limits/pN'] = data;
    updates['/Okullar/$_kurumId/SchoolData/Versions/SchoolInfo'] = _realTime;
    return _database11.update(updates);
  }

  ///Muhasebeci notu kaydeder
  static Future<void> addAccountingNot(String studentKey, List<String> noteData) async {
    return _databaseAccountingg.set('Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/Notes', noteData);
  }

  //Tekli odeme kaydeder
  static Future<void> addSinglePayment(String paymentTypeKey, Map accountingData, String studentKey) async {
    return _databaseAccountingg.push('Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey', accountingData).then((_) {
      _sentNotificationToStudent(AppVar.appBloc.hesapBilgileri.name!, 'addaccountingcontractnotify'.translate, studentKey);
    });
  }

  // Eger odeme sekli custompayment ise selectedKey odeme islemine ait itemin keyidir.
  // Eger odeme sekli custompayment degil ise selectedKey pesinat mi pesin ucretmi  yada taksit mi oldugunu ifade eder
  static Future<void> payAccounting(String paymentTypeKey, payData, faturaData, String studentKey, String? selecTedKey /*pesinat taksitler*/, String? taksitName, int faturaNo) async {
    Map<String, dynamic> updates = {};
    if (paymentTypeKey == 'custompayment') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/$selecTedKey/odemeler'] = payData;
    } else if (selecTedKey == 'pesinat') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/pesinat/odemeler'] = payData;
    } else if (selecTedKey == 'pesinUcret') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/pesinUcret/odemeler'] = payData;
    } else if (selecTedKey == 'taksitler') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/taksitler/$taksitName/odemeler'] = payData;
    }
    updates['/Okullar/$_kurumId/$_termKey/Kayitlar/faturaNo'] = faturaNo + 1;
    updates['/Okullar/$_kurumId/$_termKey/Logs/Faturalar/fatura$faturaNo'] = faturaData;

    return _databaseAccountingg.update(updates).then((_) {
      _sentNotificationToStudent(AppVar.appBloc.hesapBilgileri.name!, 'payaccountingnotify'.translate, studentKey);
    });
  }

  // Eger odeme sekli custompayment ise selectedKey odeme islemine ait itemin keyidir.
  // Eger odeme sekli custompayment degil ise selectedKey pesinat mi pesin ucretmi  yada taksit mi oldugunu ifade eder
  static Future<void> birTaksidiDegistir(String paymentTypeKey, String studentKey, String selecTedKey, String? taksitName, double eskiTutuar, double yeniTutar) async {
    Map<String, dynamic> updates = {};
    if (selecTedKey == 'pesinat') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/pesinat/tutar'] = yeniTutar;
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/notes/${4.makeKey}'] = 'amountchange'.argsTranslate({'name': 'cash'.translate, 'value1': eskiTutuar, 'value2': yeniTutar});
    } else if (selecTedKey == 'pesinUcret') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/pesinUcret/tutar'] = yeniTutar;
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/notes/${4.makeKey}'] = 'amountchange'.argsTranslate({'name': 'advancepayment'.translate, 'value1': eskiTutuar, 'value2': yeniTutar});
    } else if (selecTedKey == 'taksitler') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/taksitler/$taksitName/tutar'] = yeniTutar;
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/notes/${4.makeKey}'] =
          'amountchange'.argsTranslate({'name': 'taksitno'.translate + ': ${int.tryParse(taksitName!) == null ? taksitName : (int.tryParse(taksitName)! + 1)}', 'value1': eskiTutuar, 'value2': yeniTutar});
    }

    return _databaseAccountingg.update(updates).then((_) {
      _sentNotificationToStudent(AppVar.appBloc.hesapBilgileri.name!, 'payaccountingchangenotify'.translate, studentKey);
    });
  }

  /// Odemi plani olusmus bir ogrenci icin yeni taksit eklemesi yapar
  /// [taksitKey] taksitmodel naminin bir ekisigi olmali
  static Future<void> addNewInstalament(String paymentTypeKey, String studentKey, String taksitKey, TaksitModel taksit) async {
    Map<String, dynamic> updates = {};

    updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/taksitler/$taksitKey'] = taksit.mapForSave();
    updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/notes/${4.makeKey}'] = 'installamentadd'.argsTranslate({'key': taksit.name, 'date': DateTime.now().dateFormat()});

    return _databaseAccountingg.update(updates).then((_) {
      _sentNotificationToStudent(AppVar.appBloc.hesapBilgileri.name!, 'payaccountingchangenotify'.translate, studentKey);
    });
  }

  /// Odemi plani olusmus bir ogrenci icin son taksitte odeme alinmamissa son taksiti siler
  /// [taksitKey] taksitmodel naminin bir ekisigi olmali
  static Future<void> deleteLastInstallament(String paymentTypeKey, String studentKey, String taksitKey) async {
    Map<String, dynamic> updates = {};

    updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/taksitler/$taksitKey'] = null;
    updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/notes/${4.makeKey}'] = 'installamentdelete'.argsTranslate({'key': int.tryParse(taksitKey)! + 1, 'date': DateTime.now().dateFormat()});

    return _databaseAccountingg.update(updates).then((_) {
      _sentNotificationToStudent(AppVar.appBloc.hesapBilgileri.name!, 'payaccountingchangenotify'.translate, studentKey);
    });
  }

// Yapilmis odemeyi siler
  static Future<void> deletePayAccounting(String paymentTypeKey, payData, String studentKey, String? selecTedKey /*pesinat taksitler*/, String? taksitName, int? faturaNo) async {
    Map<String, dynamic> updates = {};
    if (paymentTypeKey == 'custompayment') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/$selecTedKey/odemeler'] = payData;
    } else if (selecTedKey == 'pesinat') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/pesinat/odemeler'] = payData;
    } else if (selecTedKey == 'pesinUcret') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/pesinUcret/odemeler'] = payData;
    } else if (selecTedKey == 'taksitler') {
      updates['/Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/taksitler/$taksitName/odemeler'] = payData;
    }
    updates['/Okullar/$_kurumId/$_termKey/Logs/Faturalar/fatura$faturaNo/aktif'] = false;
    return _databaseAccountingg.update(updates);
  }

// Odeme sozlesmesi Siler
  static Future<void> deleteAccountingContract(String paymentTypeKey, String studentKey) async {
    return _databaseAccountingg.set('Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey/aktif', false);
  }

// Custom odemeyi siler
  static Future<void> removeCustomPayment(String studentKey, String itemKey) async {
    return _databaseAccountingg.set('Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/custompayment/$itemKey/aktif', false);
  }

  // Odeme sozlesmesi kaydeder
  static Future<void> addAccountingContract(String paymentTypeKey, Map accountingData, String studentKey) async {
    return _databaseAccountingg.set('Okullar/$_kurumId/$_termKey/StudentAccounting/$studentKey/PaymentPlans/$paymentTypeKey', accountingData).then((_) {
      _sentNotificationToStudent(AppVar.appBloc.hesapBilgileri.name!, 'addaccountingcontractnotify'.translate, studentKey);
    });
  }

  // ContractList icin etiketleri kaydeder
  static Future<void> saveContractLabelSettings(Map info) => SchoolDataService.schoolInfoForManagerSaver('ccl', info);
  // SalesContractList icin etiketleri kaydeder
  static Future<void> saveSalesContractLabelSettings(Map info) => SchoolDataService.schoolInfoForManagerSaver('scl', info);
  // Gider islemleri etiketleri kaydeder
  static Future<void> saveExpensesLabelSettings(Map info) => SchoolDataService.schoolInfoForManagerSaver('exl', info);
  // Ogrenci Sozlesmesini kaydeder
  static Future<void> saveStudentContractTemplate(String info) => SchoolDataService.schoolInfoForManagerSaver('sct', info);

  static Future<void> _sentNotificationToStudent(String title, String message, String studentKey) async {
    await InAppNotificationService.sendInAppNotification(
      InAppNotification(
        title: title,
        content: message,
        key: 'AccNot',
        type: NotificationType.payment,
        pageName: PageName.sA,
      )..forParentOtherMenu = true,
      studentKey,
      notificationTag: 'accounting',
    );
  }
}
