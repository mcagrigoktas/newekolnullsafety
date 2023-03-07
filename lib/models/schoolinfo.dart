import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';
import '../screens/accounting/model.dart';
import '../screens/main/widgetsettingspage/model.dart';
import '../screens/managerscreens/schoolsettings/models/mutlu_cell.dart';

class SchoolInfo {
  String? name;
  String? logoUrl;
  bool? aktif;
  String? activeTerm;
  String? slogan;
  //String storageBucket;
  // String agoraAppId;
  String? livedomainlist;
  String? schoolType;
  List<String>? menuList;
  Map<String, String?>? classTypes;
  int? eatMenuType; //0 menu 1 url 2 file
  String? eatMenuUrl;
  late Map _limits;
  String? appName;
  Map? _gmAccount;
  late Map _widgetList;
  late List<String> _branchList;

  String? _smsConfig;
  Map? _subTermList;

  //?{'education':{'grupkey':true}}
  Map? genelMudurlukGroupList;

  SchoolInfo.fromJson(Map snapshot) {
    name = snapshot["name"] ?? "";
    eatMenuType = snapshot["et"] ?? 0;
    eatMenuUrl = snapshot["em"] ?? "";
    logoUrl = snapshot["logoUrl"] ?? "";
    activeTerm = snapshot["activeTerm"] ?? "";
    slogan = snapshot["slogan"] ?? "";
    schoolType = snapshot["schoolType"] ?? "ekid";
    aktif = snapshot["aktif"] ?? true;
    //storageBucket = snapshot["storageBucket"] ?? "";
    //   agoraAppId = (snapshot["agoraAppId"] as String).safeLength > 6 ? snapshot["agoraAppId"] : AgoraHelper.makeAgoraId();
    livedomainlist = (snapshot["livedomainlist"] as String?).safeLength > 4 ? (snapshot["livedomainlist"] as String).replaceAll('common', 'meet.jit.si') : null;
    menuList = List<String>.from(snapshot["menuList"] ?? []);
    classTypes = Map<String, String?>.from(snapshot["classTypes"] ?? {'t0': 'classtype0'.translate, 't1': 'classtype1'.translate}); //Numaraini basina t harfi eklendi
    _limits = snapshot["limits"] ?? {};
    appName = snapshot["appName"] ?? "yoook";
    _gmAccount = snapshot["gm"];
    _widgetList = snapshot["widgetList"] ?? {};
    _branchList = List<String>.from(snapshot["branchList"] ?? []);
    genelMudurlukGroupList = snapshot["gmgl"] ?? {};
    _smsConfig = snapshot["smsConfig"];
    _subTermList = snapshot["sTL"];
  }

  Map<String, String?>? get filteredClassType => classTypes!
    ..remove('t0')
    ..remove('t1');
  // bool get isEkid => schoolType == 'ekid';
  // bool get isEkol => schoolType == 'ekol';
  // bool get isUni => schoolType == 'uni';

  int get getMaxStudentCount => _limits['sC'] ?? 10000;

  Duration? get getMaxVideoDuration => _limits['vD'] == null ? null : Duration(seconds: _limits['vD']);
  String? caseName(i) {
    if (_limits['cN'] is! List || i - 1 >= (_limits['cN'] as List).length || i <= 0) return '$i';
    return _limits['cN'][i - 1];
  }

  String? paymentName(String? key) {
    if (_limits['pN'] == null) return key.translate;
    if (_limits['pN'][key] == null) return key.translate;
    return _limits['pN'][key];
  }

  //*Expense Bitis

  String? get genelMudurlukServerId => _gmAccount == null ? null : _gmAccount!['si'];
  String? get genelMudurlukName => _gmAccount == null ? null : _gmAccount!['n'];

  List<WidgetModel> get widgetList => _widgetList.entries.map((e) => WidgetModel.fromJson(e.value, e.key)).toList();

  // List<String> getZoomAccountInfo() {
  //   if (limits['zAI'] == null) return null;
  //   var dataList = (limits['zAI'] as String).split('-#-');
  //   var data = dataList[Random().nextInt(dataList.length)];
  //   return [data.split('-*-').first, data.split('-*-').last];
  // }

  List<String> get branchList => (_branchList..addAll(defaultBranches)).map((e) => e.translate).toSet().toList()..sort();

  SmSConfig get smsConfig => SmSConfig.fromJson(_smsConfig);

  List<SubTermModel>? subTermList() => (_subTermList == null || _subTermList!.isEmpty || _subTermList![activeTerm] == null) ? null : (_subTermList![activeTerm] as List).map((e) => SubTermModel.fromJson(e)).toList();
}

class SubTermModel {
  String? name;
  int? startDate;
  int? endDate;
  SubTermModel({this.name, this.startDate, this.endDate});
  SubTermModel.fromJson(Map data) {
    name = data['n'];
    startDate = data['sD'];
    endDate = data['eD'];
  }
  Map toJson() {
    return {
      'n': name,
      'sD': startDate,
      'eD': endDate,
    };
  }
}

const defaultBranches = ['math', 'physical', 'chemical', 'history', 'geography', 'science'];

class SchoolInfoForManager {
  Map? _contractLabelList;
  Map? _studentContractLabelList;
  Map? _expenseLabelList;
  String? studentContractTemplate;
  int? _maxStudentCount;
  int? managerLastLoginTime;
  int? lastUsableTime;

  SchoolInfoForManager.fromJson(Map snapshot) {
    _contractLabelList = snapshot['ccl'];
    _studentContractLabelList = snapshot['scl'];
    _expenseLabelList = snapshot['exl'];
    studentContractTemplate = snapshot['sct'];
    lastUsableTime = snapshot['lUT'];
    //* todo Bu data eskiden okul bilgileri icindeydi simdi buraya alindi. ama mecburen eskisi duruyor 29 temmuz 2023 ten sonra diger taraftan kaldir
    _maxStudentCount = snapshot['sC'];
    managerLastLoginTime = snapshot['mLT'];
  }

  int get maxStudentCount => _maxStudentCount ?? AppVar.appBloc.schoolInfoService!.singleData!.getMaxStudentCount;

  List<MapEntry<String, String>> contractLabelInfoList() {
    final _data = Map<String, String>.from(_contractLabelList ?? {'c0': 'generally'.translate});
    return (_data..removeWhere((key, value) => value.safeLength < 1)).entries.toList()..sort((a, b) => int.tryParse(a.key.replaceAll('c', ''))! - int.tryParse(b.key.replaceAll('c', ''))!);
  }

  List<MapEntry<String, String>> salesContractLabelInfoList() {
    final _data = Map<String, String>.from(_studentContractLabelList ?? {'c0': 'generally'.translate});
    return (_data..removeWhere((key, value) => value.safeLength < 1)).entries.toList()..sort((a, b) => int.tryParse(a.key.replaceAll('c', ''))! - int.tryParse(b.key.replaceAll('c', ''))!);
  }

//* Expense
  Map<String, dynamic> expenseLabelInfoList() {
    final _data = Map<String, dynamic>.from(
      _expenseLabelList ??
          {
            'cleaningeq': ExpansesLabelNode(name: 'cleaningequipment'.translate, nodeKey: 'cleaningeq', colorNo: 1).toJson(),
            'electric': ExpansesLabelNode(name: 'electric'.translate, nodeKey: 'electric', colorNo: 2).toJson(),
          },
    );
    return _data;
  }

  ExpansesLabelNode get expenseLabelRootNode => ExpansesLabelNode.fromJson({'n': 'Root', 'key': 'root', 'c': 0, 'i': expenseLabelInfoList()});
}
