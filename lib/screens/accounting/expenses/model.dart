import 'package:mcg_extension/mcg_extension.dart';

import '../model.dart';

class Expense {
  String? key;
  String? no;
  String? supplier;
  int? date;
  ExpenseType? type;
  String? personKey;
  String? exp;
  List<ExpenseItem>? items;
  bool? aktif;
  List<String>? invoiceUrl;

  Expense({this.no, this.supplier, this.date, this.type, this.personKey, this.exp, this.items, this.aktif, this.invoiceUrl});

  Expense.create() {
    no = '';
    key = 10.makeKey;
    date = DateTime.now().millisecondsSinceEpoch;
    type = ExpenseType.ENFORCED;
    exp = '';
    items = [ExpenseItem.create(this)];
    aktif = true;
  }

  Expense.fromJson(Map snapshot, this.key) {
    no = snapshot['no'];
    supplier = snapshot['s'];
    date = snapshot['d'];
    type = J.jEnum(snapshot['t'], ExpenseType.values, ExpenseType.ENFORCED);
    personKey = snapshot['p'];
    exp = snapshot['exp'];
    items = J.jClassList(snapshot['items'], (p0) => ExpenseItem.fromJson(p0));
    aktif = snapshot['aktif'] ?? true;
    invoiceUrl = List<String>.from(snapshot['iurl'] ?? []);
  }

  double totalValue() {
    return items?.fold<double>(0.0, ((p, e) => p + (double.tryParse(e.total.value) ?? 0.0))) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'aktif': aktif,
      'iurl': invoiceUrl,
      'no': no,
      's': supplier,
      'd': date,
      't': type!.name,
      'p': personKey,
      'exp': exp,
      'items': items!.map((e) => e.toJson()).toList(),
    };
  }

  List<AccountFullLog>? getAccountFullLog() {
    if (aktif == false) return [];
    return items?.fold<List<AccountFullLog>>(
      [],
      (p, item) => (p..add(AccountFullLog(amount: item.unitPrice! * item.count!, date: date, name: no, caseNo: item.kasaNo, exp: item.product, label: item.label, accountLogType: AccountLogType.E, tahsilEdilecek: false))),
    );
  }

  List<AccountLog>? _getAccountLog() {
    if (aktif == false) return [];
    return items?.fold<List<AccountLog>>(
      [],
      (p, item) => (p..add(AccountLog(amount: item.unitPrice! * item.count!, name: no, caseNo: item.kasaNo, exp: item.product, label: item.label, accountLogType: AccountLogType.E))),
    );
  }

  List toLog() {
    return _getAccountLog()!.map((e) => e.toJson()).toList();
  }

  String get getSearchText => no! + exp!;
}

enum ExpenseType { ENFORCED, OTHER }

class ExpenseItem {
  String? product;
  int? count;
  double? unitPrice;
  String? label;
  int? kasaNo;

  var total = ''.obs;
  double _totalValue() {
    if (count == null || unitPrice == null) {
      return 0.0;
    } else {
      return (count! * unitPrice!);
    }
  }

  void countTotalValue() {
    total.value = _totalValue().toStringAsFixed(2);
  }

  ExpenseItem({this.product, this.unitPrice, this.count, this.label, this.kasaNo}) {
    countTotalValue();
  }

  ExpenseItem.create(Expense item) {
    kasaNo = Fav.readSeasonCache('${item.key}LastCaseNo', 0);
    count = 0;
    unitPrice = 0.0;
    product = '';
  }
  ExpenseItem.fromJson(Map snapshot) {
    product = snapshot['e'];
    count = snapshot['c'];
    unitPrice = J.jDouble(snapshot['p'], 0.0);
    label = snapshot['l'];
    kasaNo = snapshot['case'];
    countTotalValue();
  }

  Map<String, dynamic> toJson() {
    return {
      'e': product,
      'c': count,
      'p': unitPrice,
      'l': label,
      'case': kasaNo,
    };
  }
}
