import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../model.dart';

class Virman {
  bool? aktif;
  double? enteringAmount;
  int? date;
  int? enteringCase;
  double? sendingAmount;
  int? sendingCase;
  VirmanType? virmanType;
  String? key;
  String? exp;
  String? userKey;

  Virman.create() {
    key = 10.makeKey;
    aktif = true;
    enteringAmount = 0.0;
    enteringCase = 0;
    sendingAmount = 0.0;
    sendingCase = 0;
    virmanType = VirmanType.onlyEnter;
    exp = '';
    date = DateTime.now().millisecondsSinceEpoch;
    userKey = AppVar.appBloc.hesapBilgileri.uid;
  }

  Virman.fromJson(Map snapshot, this.key) {
    aktif = snapshot['aktif'] ?? true;
    enteringAmount = J.jDouble(snapshot['eA'], 0.0);
    date = snapshot['d'];
    enteringCase = snapshot['eC'];
    sendingAmount = J.jDouble(snapshot['sA'], 0.0);
    sendingCase = snapshot['sC'];
    exp = snapshot['exp'];
    userKey = snapshot['userKey'];
    virmanType = J.jEnum(snapshot['t'], VirmanType.values);
  }

  Map<String, dynamic> toJson() {
    return {
      'aktif': aktif,
      'eA': enteringAmount,
      'd': date,
      'eC': enteringCase,
      'sA': sendingAmount,
      'sC': sendingCase,
      'exp': exp,
      'userKey': userKey,
      't': virmanType!.name,
    };
  }

  List<AccountFullLog> getAccountFullLog() {
    return [
      if (sendingAmount != null && sendingAmount != 0) AccountFullLog(accountLogType: AccountLogType.V, date: date, amount: sendingAmount, caseNo: sendingCase, exp: exp, name: 'vmoneyin'.translate, tahsilEdilecek: false),
      if (enteringAmount != null && enteringAmount != 0) AccountFullLog(accountLogType: AccountLogType.V, date: date, amount: enteringAmount, caseNo: enteringCase, exp: exp, name: 'vmoneyout'.translate, tahsilEdilecek: false),
    ];
  }

  List<AccountLog> _getAccountLog() {
    return [
      if (sendingAmount != null && sendingAmount != 0) AccountLog(accountLogType: AccountLogType.V, amount: sendingAmount, caseNo: sendingCase, exp: exp),
      if (enteringAmount != null && enteringAmount != 0) AccountLog(accountLogType: AccountLogType.V, amount: enteringAmount, caseNo: enteringCase, exp: exp),
    ];
  }

  List toLog() {
    return _getAccountLog().map((e) => e.toJson()).toList();
  }
}

enum VirmanType { onlyEnter, change }
