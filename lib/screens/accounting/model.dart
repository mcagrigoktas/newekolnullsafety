import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:mcg_extension/mcg_extension.dart';

class AccountLog {
  String? name;
  int? installamentNo;
  double? amount;
  AccountLogType? accountLogType;
  String? label;
  int? caseNo;

  String? key;
  String? exp;

  String getName() => name! + ' ' + (installamentNo == null ? '' : ('taksitno'.translate + ':' + installamentNo.toString()));

  AccountLog({this.name, this.amount, this.accountLogType, this.label, this.installamentNo, this.caseNo, this.exp});

  AccountLog.fromJson(Map snapshot, this.key) {
    name = snapshot['n'];
    caseNo = snapshot['c'];
    installamentNo = snapshot['i'];
    label = snapshot['l'];
    exp = snapshot['e'];
    amount = J.jDouble(snapshot['a'], 0.0);
    accountLogType = J.jEnum(snapshot['t'], AccountLogType.values);
  }

  Map<String, dynamic> toJson() {
    return {'t': accountLogType!.name, 'a': amount, 'n': name, 'l': label, 'i': installamentNo, 'c': caseNo, 'e': exp};
  }
}

class AccountFullLog {
  String? name;
  int? installamentNo;
  double? amount;
  AccountLogType? accountLogType;
  String? label;
  int? caseNo;
  int? date;

  String? key;
  String? exp;

  bool? tahsilEdilecek;

  String getName() => name.toString() + ' ' + (installamentNo == null ? '' : ('taksitno'.translate + ':' + installamentNo.toString()));

  AccountFullLog({
    this.name,
    this.amount,
    this.accountLogType,
    this.label,
    this.installamentNo,
    this.caseNo,
    this.exp,
    this.tahsilEdilecek,
    this.date,
    this.key,
  });
}

enum AccountLogType {
  //C Contract
  //E Expense
  //S Sales Contract
  //V Virman
  //ST Student
  C,
  E,
  S,
  V,
  ST,
}

class ExpansesLabelNode extends ListenableNode<ExpansesLabelNode> {
  String? name;
  int? colorNo;
  String? fullparentKey;
  ExpansesLabelNode.create() : super(key: 6.makeKey) {
    name = '';
    colorNo = 34.random;
  }
  ExpansesLabelNode({String? nodeKey, this.name, this.colorNo}) : super(key: nodeKey);

  Map toJson() {
    return {'n': name, 'c': colorNo, 'key': super.key, 'i': children.map((key, value) => MapEntry(key, (value as ExpansesLabelNode).toJson()))};
  }

  ExpansesLabelNode.fromJson(Map snapshot) : super(key: snapshot['key']) {
    name = snapshot['n'];
    colorNo = snapshot['c'];
    addAll(((snapshot['i'] ?? {}) as Map).map((key, value) => MapEntry(key, ExpansesLabelNode.fromJson(value))).values);
  }

  List<ExpansesLabelNode> getAllChildren() {
    final _list = <ExpansesLabelNode>[];

    for (final child in children.values) {
      _list.add((child as ExpansesLabelNode));

      if (child.children.values.isNotEmpty) {
        _list.addAll(child.getAllChildren());
      }
    }
    return _list;
  }

  //? Istatistiklerde deterjani temizlik giderindede gostermek icin deterjana temizlik giderininde keyini ekler
  // List<LabelNode> getAllStructuredChildren([String parentNameKey]) {
  //   final _list = <LabelNode>[];

  //   for (final child in children.values) {
  //     _list.add((child as LabelNode)..name = (parentNameKey ?? '') + (child as LabelNode).key);

  //     if (child.children.values.isNotEmpty) {
  //       _list.addAll((child as LabelNode).getAllStructuredChildren((child as LabelNode).key));
  //     }
  //   }
  //   return _list;
  // }
}
