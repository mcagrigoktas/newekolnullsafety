import 'package:mcg_extension/mcg_extension.dart';

import '../helpers/calculate_helper.dart';
import '../model.dart';

class SalesContract {
  String? key;

  int? startDate;
  int? endDate;
  String? exp;
  String? name;

  String? label;
  bool? aktif;
  String? personKey;
  String? personName;
  bool? isCompleted;
  double? minusPrice;

  List<SalesInstallament> installaments = [];
  List<SalesProduct>? products = [];

  SalesContract();
  SalesContract.createNew() {
    key = 10.makeKey;

    startDate = DateTime.now().millisecondsSinceEpoch;
    endDate = DateTime.now().add(365.days).millisecondsSinceEpoch;
    exp = '';
    setupInstallaments();
    products!.add(SalesProduct.create());
    name = '';
    label = 'c0';
    aktif = true;
    isCompleted = false;
    minusPrice = 0.0;
  }

  SalesContract.fromJson(Map snapshot, this.key) {
    personKey = snapshot['personKey'];
    personName = snapshot['personName'];
    isCompleted = snapshot['isCompleted'] ?? false;
    minusPrice = J.jDouble(snapshot['minusPrice'], 0.0);
    aktif = snapshot['aktif'] ?? true;
    startDate = snapshot['startDate'];
    endDate = snapshot['endDate'];
    exp = snapshot['exp'];
    label = snapshot['label'] ?? 'c0';
    name = snapshot['name'] ?? '';
    installaments = snapshot['installaments'] == null ? [] : (snapshot['installaments'] as List).map((e) => SalesInstallament.fromJson(e)).toList();
    products = J.jClassList(snapshot['products'], (p0) => SalesProduct.fromJson(p0), []);
  }

  Map<String, dynamic> toJson() {
    return {
      'aktif': aktif,
      'minusPrice': minusPrice,
      'personName': personName,
      'isCompleted': isCompleted,
      'personKey': personKey,
      'startDate': startDate,
      'name': name,
      'endDate': endDate,
      'exp': exp,
      'label': label,
      'installaments': installaments.map((e) => e.toJson()).toList(),
      'products': products?.map((e) => e.toJson()).toList(),
    };
  }

  List<AccountFullLog> getAccountFullLog() {
    return (installaments).fold<List<AccountFullLog>>(
      [],
      (p, installament) {
        p.add(AccountFullLog(amount: installament.kalan, date: installament.date, name: (personName ?? '') + name!, caseNo: null, installamentNo: installaments.indexOf(installament) + 1, label: label, accountLogType: AccountLogType.S, tahsilEdilecek: true, exp: installament.exp));
        if (installament.odemeler != null) {
          p.addAll(installament.odemeler!
              .map((payoff) => AccountFullLog(amount: payoff!.miktar, date: payoff.date, name: (personName ?? '') + name!, caseNo: payoff.kasaNo, installamentNo: installaments.indexOf(installament) + 1, label: label, accountLogType: AccountLogType.S, exp: installament.exp, tahsilEdilecek: false)));
        }
        return p;
      },
    );
  }

  List<AccountLog> _getAccountLog() {
    return (installaments).fold<List<AccountLog>>(
      [],
      (p, installament) => installament.odemeler == null ? p : (p..addAll(installament.odemeler!.map((payoff) => AccountLog(amount: payoff!.miktar, name: name, caseNo: payoff.kasaNo, installamentNo: installaments.indexOf(installament) + 1, label: label, accountLogType: AccountLogType.S)))),
    );
  }

  List toLog() {
    return _getAccountLog().map((e) => e.toJson()).toList();
  }

  void setupInstallaments([int count = 2]) {
    while (installaments.length < count) {
      final _installament = SalesInstallament()
        ..no = installaments.length + 1
        ..amount = 0
        ..exp = '';
      installaments.add(_installament);
    }
    while (installaments.length > count) {
      installaments.removeLast();
    }
    setUpInstallamenDates();
  }

  void setUpInstallamenDates({bool forceFirstInstallaments = false}) {
    final _firstDate = DateTime.fromMillisecondsSinceEpoch(forceFirstInstallaments ? (installaments.first.date ?? startDate!) : startDate!);

    for (var _i = 0; _i < installaments.length; _i++) {
      if (installaments[_i].date == null || forceFirstInstallaments) {
        installaments[_i].date = DateTime(_firstDate.year, _firstDate.month + _i, _firstDate.day, _firstDate.hour).millisecondsSinceEpoch;
      }
    }
  }

  double get contractAmount => products!.fold(0.0, (p, e) => p + e.net);
  double get totalPaid => installaments.fold<double>(0, (p, e) => p + e.amount!);
  double get totalKalan => contractAmount - totalPaid;

  void calculateInstallaments() {
    final _installamentList = AccountingCalculateHelper.amountToInstallament(contractAmount, installaments.length);
    for (var _i = 0; _i < installaments.length; _i++) installaments[_i].amount = _installamentList[_i];
  }

  bool _isContractAmountEqualSubInstallamentsAmount() {
    return contractAmount <= totalPaid + 0.01 && contractAmount >= totalPaid - 0.01;
  }

  bool saveValidate({bool completed = false}) {
    if (!completed && !_isContractAmountEqualSubInstallamentsAmount()) {
      OverAlert.show(message: 'insttotalerr'.translate, type: AlertType.danger);
      return false;
    }
    return true;
  }

  String get getSearchText => (name! + exp!).toLowerCase();
}

class SalesProduct {
  int? startDate;
  int? endDate;
  String? name;
  String? exp;
  double? amount;
  double? discount;
  double? tax;

  SalesProduct();

  SalesProduct.create() {
    amount = 0.0;
    discount = 0;
    tax = 0;
  }

  SalesProduct.fromJson(Map snapshot) {
    amount = J.jDouble(snapshot['amount'], 0.0);
    discount = J.jDouble(snapshot['d'], 0.0);
    tax = J.jDouble(snapshot['t'], 0.0);

    name = snapshot['n'];
    exp = snapshot['exp'];
    startDate = snapshot['sd'];
    endDate = snapshot['ed'];
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'n': name,
      'exp': exp,
      't': tax,
      'sd': startDate,
      'ed': endDate,
      'd': discount,
    };
  }

  double get net => (amount! * ((100 - discount!) / 100)) * ((100 + tax!) / 100);
}

class SalesInstallament {
  int? no;
  double? amount;
  int? date;
  String? exp;

  List<SalesPayOff?>? odemeler;
  SalesInstallament();

  SalesInstallament.fromJson(Map snapshot) {
    no = snapshot['no'];
    amount = (snapshot['amount'] ?? 0.0).toDouble();
    date = snapshot['date'];
    exp = snapshot['exp'];
    odemeler = J.jClassList(snapshot['odemeler'], (p0) => SalesPayOff.fromJson(p0));
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'amount': amount,
      'date': date,
      'exp': exp,
      "odemeler": odemeler?.map((odeme) => odeme!.toJson()).toList(),
    };
  }

  double get paid {
    return odemeler?.fold<double>(0.0, (p, e) => p + e!.miktar!) ?? 0.0;
  }

  double get kalan => (amount! - paid);
}

class SalesPayOff {
  int? date;
  double? miktar;
  String? otherNo;
  int? kasaNo;

  SalesPayOff.fromJson(Map snapshot) {
    kasaNo = snapshot['kasaNo'];
    date = snapshot['date'];
    otherNo = snapshot['otherNo'];
    kasaNo = J.jInt(snapshot['kasaNo'], 0);
    miktar = J.jDouble(snapshot['miktar']);
  }
  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "miktar": miktar,
      "otherNo": otherNo,
      "kasaNo": kasaNo,
    };
  }

  SalesPayOff.create() {
    date = DateTime.now().millisecondsSinceEpoch;
    kasaNo = 0;
    otherNo = '';
    miktar = 0.0;
  }
}
