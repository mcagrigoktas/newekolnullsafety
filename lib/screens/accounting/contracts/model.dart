import 'package:mcg_extension/mcg_extension.dart';

import '../../managerscreens/registrymenu/managersscreen/manager.dart';
import '../../managerscreens/registrymenu/personslist/model.dart';
import '../../managerscreens/registrymenu/teacherscreen/teacher.dart';
import '../helpers/calculate_helper.dart';
import '../model.dart';

class Contract {
  String? key;

  Contract();
  int? startDate;
  double? contractAmount;
  int? endDate;
  String? duration;
  String? exp;
  String? name;

  String? label;
  bool? aktif;
  bool? isCompleted;
  String? personKey;
  String? personName;

  List<Installament> installaments = [];

  Contract.createNew(this.personKey, this.personName) {
    key = 10.makeKey;
    startDate = DateTime.now().millisecondsSinceEpoch;
    endDate = DateTime.now().add(365.days).millisecondsSinceEpoch;
    duration = '';
    contractAmount = 0;
    exp = '';
    setupInstallaments();
    name = '';
    label = 'c0';
    aktif = true;
    isCompleted = false;
  }

  Contract.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    personKey = snapshot['personKey'];
    personName = snapshot['personName'];
    isCompleted = snapshot['isCompleted'] ?? false;
    startDate = snapshot['startDate'];
    endDate = snapshot['endDate'];
    duration = (snapshot['duration'] ?? '').toString();
    exp = snapshot['exp'];
    label = snapshot['label'] ?? 'c0';
    name = snapshot['name'] ?? '';
    contractAmount = J.jDouble(snapshot['contractAmount'], 0.0);
    installaments = snapshot['installaments'] == null ? [] : (snapshot['installaments'] as List).map((e) => Installament.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'aktif': aktif,
      'personKey': personKey,
      'personName': personName,
      'isCompleted': isCompleted,
      'startDate': startDate,
      'name': name,
      'endDate': endDate,
      'duration': duration,
      'exp': exp,
      'label': label,
      'contractAmount': (contractAmount ?? 0).toDouble(),
      'installaments': installaments.map((e) => e.toJson()).toList(),
    };
  }

  List<AccountFullLog> getAccountFullLog() {
    return (installaments).fold<List<AccountFullLog>>(
      [],
      (p, installament) {
        p.add(AccountFullLog(amount: installament.kalan, date: installament.date, name: (personName ?? '') + name!, caseNo: null, installamentNo: installaments.indexOf(installament) + 1, label: label, accountLogType: AccountLogType.C, tahsilEdilecek: true, exp: installament.exp));
        if (installament.odemeler != null) {
          p.addAll(installament.odemeler!
              .map((payoff) => AccountFullLog(amount: payoff!.miktar, date: payoff.date, name: (personName ?? '') + name!, caseNo: payoff.kasaNo, installamentNo: installaments.indexOf(installament) + 1, label: label, accountLogType: AccountLogType.C, exp: installament.exp, tahsilEdilecek: false)));
        }
        return p;
      },
    );
  }

  List<AccountLog> _getAccountLog() {
    return (installaments).fold<List<AccountLog>>(
      [],
      (p, installament) =>
          installament.odemeler == null ? p : (p..addAll(installament.odemeler!.map((payoff) => AccountLog(amount: payoff!.miktar, name: (personName ?? '') + name!, caseNo: payoff.kasaNo, installamentNo: installaments.indexOf(installament) + 1, label: label, accountLogType: AccountLogType.C)))),
    );
  }

  List toLog() {
    return _getAccountLog().map((e) => e.toJson()).toList();
  }

  void setupInstallaments([int count = 2]) {
    while (installaments.length < count) {
      final _installament = Installament()
        ..no = installaments.length + 1
        ..amount = 0
        ..exp = ''
        ..type = InstallamentType.MONTHLY;
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

  void calculateInstallaments() {
    final _installamentList = AccountingCalculateHelper.amountToInstallament(contractAmount, installaments.length);
    for (var _i = 0; _i < installaments.length; _i++) installaments[_i].amount = _installamentList[_i];
  }

  bool _isContractAmountEqualSubInstallamentsAmount() {
    return contractAmount! <= installaments.fold<double>(0, (p, e) => p + e.amount!) + 0.01 && contractAmount! >= installaments.fold<double>(0, (p, e) => p + e.amount!) - 0.01;
  }

  bool saveValidate() {
    if (!_isContractAmountEqualSubInstallamentsAmount()) {
      OverAlert.show(message: 'insttotalerr'.translate, type: AlertType.danger);
      return false;
    }
    return true;
  }
}

enum InstallamentType {
  MONTHLY,
}

class Installament {
  InstallamentType? type;
  int? no;
  double? amount;
  int? date;
  String? exp;

  List<PayOff?>? odemeler;
  Installament();

  Installament.fromJson(Map snapshot) {
    type = J.jEnum(snapshot['type'], InstallamentType.values, InstallamentType.MONTHLY);
    no = snapshot['no'];
    amount = (snapshot['amount'] ?? 0.0).toDouble();
    date = snapshot['date'];
    exp = snapshot['exp'];
    odemeler = J.jClassList(snapshot['odemeler'], (p0) => PayOff.fromJson(p0));
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type!.name,
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

class PayOff {
  int? date;
  double? miktar;
  String? otherNo;
  int? kasaNo;

  PayOff.fromJson(Map snapshot) {
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

  PayOff.create() {
    date = DateTime.now().millisecondsSinceEpoch;
    kasaNo = 0;
    otherNo = '';
    miktar = 0.0;
  }
}

class ContractPerson {
  Teacher? teacher;
  Person? person;
  Manager? manager;

  ContractPerson({this.teacher, this.person, this.manager});

  String? get key => teacher?.key ?? manager?.key ?? person?.key;

  bool get isManager {
    if (_isSturdy) {
      return manager != null;
    }
    return false;
  }

  bool get isTeacher {
    if (_isSturdy) {
      return teacher != null;
    }
    return false;
  }

  bool get isPerson {
    if (_isSturdy) {
      return person != null;
    }
    return false;
  }

  bool get _isSturdy {
    bool _sturdy = teacher != null || person != null || manager != null;
    if (!_sturdy) throw ('ContractPerson dogru tanimlanmamis');
    return _sturdy;
  }

  String? get getSearchText => isTeacher
      ? teacher!.getSearchText
      : isManager
          ? manager!.getSearchText
          : isPerson
              ? person!.getSearchText
              : null;

  String? get name => isTeacher
      ? teacher!.name
      : isManager
          ? manager!.name
          : isPerson
              ? person!.name
              : null;

  String? get imgUrl => isTeacher
      ? teacher!.imgUrl
      : isManager
          ? manager!.imgUrl
          : isPerson
              ? person!.imgUrl
              : null;
}
