import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/models.dart';
import '../../../services/dataservice.dart';
import '../../../services/reference_service.dart';
import '../contracts/model.dart';
import '../expenses/model.dart';
import '../model.dart';
import '../sales_contracts/model.dart';
import 'model.dart';

class FinancialAnalysisController extends GetxController {
  final int _delay = 2000;
  bool isAllDataLoading = true;

  //MiniFetcher _personFetcher;
  VirmanType? virmanPageType;
  PkgFireBox? _virmanDataPackage;
  StreamSubscription? _virmanListFetcherListener;
  List<Virman> _virmanList = [];
  int statisticsTabValue = 0;

  final List<AccountFullLog> _allAccountLogData = [];
  List<AccountFullLog> get allAccountLogData => [..._allAccountLogData, ..._virmanList.fold<List<AccountFullLog>>([], (p, e) => p..addAll(e.getAccountFullLog()))]..sort((a, b) => b.date! - a.date!);
  List<AccountFullLog> filteredAccountLogData = [];
  Map cachedFullData = {};

  final columnNames = [''.translate, 'name'.translate, 'date'.translate, 'amount'.translate, 'type'.translate, 'effect'.translate, 'state'.translate, 'casenumber'.translate];
  final flexList = [1, 15, 6, 6, 6, 3, 3, 6];

  List<List<dynamic>> rows = [];

  List<List<dynamic>> calculateRows({bool forExcel = false}) {
    var _rows = <List<dynamic>>[];

    for (var _i = 0; _i < filteredAccountLogData.length; _i++) {
      final _item = filteredAccountLogData[_i];
      _rows.add([
        (_i + 1).toString(),
        _item.getName(),
        _item.date!.dateFormat(),
        forExcel ? _item.amount : _item.amount!.toStringAsFixed(2),
        (_item.accountLogType == AccountLogType.C
                ? 'contracts'
                : _item.accountLogType == AccountLogType.S
                    ? 'salescontracts'
                    : _item.accountLogType == AccountLogType.ST
                        ? 'studentaccounting'
                        : _item.accountLogType == AccountLogType.E
                            ? 'expenses'
                            : _item.accountLogType == AccountLogType.V
                                ? 'virman'
                                : '')
            .translate,
        (_item.tahsilEdilecek == true
            ? ''
            : _item.accountLogType == AccountLogType.C || _item.accountLogType == AccountLogType.E
                ? '-'
                : _item.accountLogType == AccountLogType.S || _item.accountLogType == AccountLogType.ST
                    ? '+'
                    : _item.accountLogType == AccountLogType.V && _item.amount! > 0
                        ? '+'
                        : _item.accountLogType == AccountLogType.V && _item.amount! < 0
                            ? '-'
                            : ''),
        (_item.tahsilEdilecek == false ? (forExcel ? '+' : 'done') : (forExcel ? 'x' : 'clear')),
        (_item.caseNo == null ? '' : AppVar.appBloc.schoolInfoService!.singleData!.caseName(_item.caseNo))
      ]);
    }
    return _rows;
  }

  late List<ExpansesLabelNode> allExpensesLabelNodes;
  Map<String, String> expensesLabelNodePathCache = {};

  @override
  void onInit() {
    allExpensesLabelNodes = AppVar.appBloc.schoolInfoForManagerService!.singleData!.expenseLabelRootNode.getAllChildren();
    allExpensesLabelNodes.forEach((_item) {
      expensesLabelNodePathCache[_item.key] = _item.path;
    });

    _fetchAllData();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    _virmanListFetcherListener?.cancel();
    _virmanDataPackage?.dispose();
  }

  Map? filterOption = {
    'searchText': '',
    'startDate': null,
    'endDate': null,
    'amountRange': '',
    'caseList': ['all'],
    'contractsEnable': true,
    'contractsTahsilEdilecek': true,
    'contractsTahsilEdildi': true,
    'contractsLabelList': ['all'],
    'salesContractsEnable': true,
    'salesContractsTahsilEdilecek': true,
    'salesContractsTahsilEdildi': true,
    'salesContractsLabelList': ['all'],
    'expenseEnable': true,
    'expensesLabelList': ['all'],
    'virmanEnable': true,
    'studentAccountingEnable': true,
    'studentsTahsilEdilecek': true,
    'studentsTahsilEdildi': true,
    'studentsAccountingLabelList': ['all'],
  };
  bool filterMenuIsOpen = true;
  void makeFilter() {
    //* Burada range araligi yazilan texte gore duzenleniyor
    double? _maxAmount;
    double? _minAmount;
    final String? _amountRangeText = filterOption!['amountRange'];

    if (_amountRangeText.safeLength > 0 && _amountRangeText!.contains('-')) {
      _minAmount = double.tryParse(_amountRangeText.split('-').first);
      _maxAmount = double.tryParse(_amountRangeText.split('-').last);
    }
    //*******************/
    filteredAccountLogData = allAccountLogData.where((item) {
//? Yazilan texte gore filtreleniyor
      if ((filterOption!['searchText'] as String?).safeLength > 0 && !item.getName().toLowerCase().contains(filterOption!['searchText'])) return false;

//? Tarih araligina gore filtreleniyor
      if (filterOption!['startDate'] != null && item.date! < filterOption!['startDate']) return false;
      if (filterOption!['endDate'] != null && item.date! > filterOption!['endDate']) return false;
//? Tutar araligina gore filtreleniyor
      if (_minAmount != null && item.amount!.abs() < _minAmount) return false;
      if (_maxAmount != null && item.amount!.abs() > _maxAmount) return false;

      //? Kasaya gore filtreleniyor
      if (!List<String>.from(filterOption!['caseList']).any((element) => element == 'all' || element == item.caseNo.toString())) return false;

//? Personel sozlesmelerine gore filtreleniyor
      if (filterOption!['contractsEnable'] != true && item.accountLogType == AccountLogType.C) return false;
      if (item.accountLogType == AccountLogType.C && !List<String>.from(filterOption!['contractsLabelList']).any((element) => element == 'all' || element == item.label)) return false;

      if (item.accountLogType == AccountLogType.C) {
        if ((filterOption!['contractsTahsilEdilecek'] != true && filterOption!['contractsTahsilEdildi'] != true)) return false;
        if (!(filterOption!['contractsTahsilEdilecek'] && filterOption!['contractsTahsilEdildi'])) {
          if (filterOption!['contractsTahsilEdilecek'] && item.tahsilEdilecek == false) return false;
          if (filterOption!['contractsTahsilEdildi'] && item.tahsilEdilecek != false) return false;
        }
      }

      //? Satis sozlesmelerine gore filtreleniyor
      if (filterOption!['salesContractsEnable'] != true && item.accountLogType == AccountLogType.S) return false;
      if (item.accountLogType == AccountLogType.S && !List<String>.from(filterOption!['salesContractsLabelList']).any((element) => element == 'all' || element == item.label)) return false;

      if (item.accountLogType == AccountLogType.S) {
        if ((filterOption!['salesContractsTahsilEdilecek'] != true && filterOption!['salesContractsTahsilEdildi'] != true)) return false;
        if (!(filterOption!['salesContractsTahsilEdilecek'] && filterOption!['salesContractsTahsilEdildi'])) {
          if (filterOption!['salesContractsTahsilEdilecek'] && item.tahsilEdilecek == false) return false;
          if (filterOption!['salesContractsTahsilEdildi'] && item.tahsilEdilecek != false) return false;
        }
      }

      //? Gider islemlerinie gore filtreleniyor
      if (filterOption!['expenseEnable'] != true && item.accountLogType == AccountLogType.E) return false;
      if (item.accountLogType == AccountLogType.E &&
          !List<String>.from(filterOption!['expensesLabelList']).any((element) {
            if (element == 'all') return true;
            final _itemLabelPath = expensesLabelNodePathCache[item.label!];
            if (_itemLabelPath == null) return false;

            return _itemLabelPath.contains(element);
          })) return false;

      //? Kasaya para ekleme cikarmaya gore filtreleniyor
      if (filterOption!['virmanEnable'] != true && item.accountLogType == AccountLogType.V) return false;

      //? Ogrenci muhasebesine gore filtreleniyor gore filtreleniyor
      if (filterOption!['studentAccountingEnable'] != true && item.accountLogType == AccountLogType.ST) return false;
      if (item.accountLogType == AccountLogType.ST && !List<String>.from(filterOption!['studentsAccountingLabelList']).any((element) => element == 'all' || element == item.label)) return false;

      if (item.accountLogType == AccountLogType.ST) {
        if ((filterOption!['studentsTahsilEdilecek'] != true && filterOption!['studentsTahsilEdildi'] != true)) return false;
        if (!(filterOption!['studentsTahsilEdilecek'] && filterOption!['studentsTahsilEdildi'])) {
          if (filterOption!['studentsTahsilEdilecek'] && item.tahsilEdilecek == false) return false;
          if (filterOption!['studentsTahsilEdildi'] && item.tahsilEdilecek != false) return false;
        }
      }

      return true;
    }).toList();
    rows = calculateRows(forExcel: false);
    update();
  }

  Future<void> _fetchAllData() async {
    _virmanDataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.singleDocListCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.singleDocListCollectionRef(),
        fetchType: FetchType.LISTEN,
        filterDeletedData: true,
        parsePkg: (key, value) => Virman.fromJson(value, key),
        removeIfHasntThis: ['eA'],
        sortFunction: (a, b) => (a as Virman).date! - (b as Virman).date!);
    await _virmanDataPackage!.init();

    _virmanList = _virmanDataPackage!.dataListOfThisDocs('Virmans');
    _virmanListFetcherListener = _virmanDataPackage!.refresh.listen((value) {
      cachedFullData.clear();
      _virmanList = _virmanDataPackage!.dataListOfThisDocs('Virmans');
    });

    // _personFetcher = MiniFetchers.getFetcher(MiniFetcherKeys.schoolPersons);
    await Future.wait([
      _fetcStudentAccountingData(),
      _fetcSalesContractData(),
      _fetchExpensesData(),
      _fetchPersonalContractData(),
    ]);
    isAllDataLoading = false;
    makeFilter();
    update();
  }

  Future<bool> _fetchPersonalContractData() async {
    final _personalContractDataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.userContractCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.userContractCollectionRef(),
        fetchType: FetchType.ONCE,
        filterDeletedData: true,
        parsePkg: (key, value) => Contract.fromJson(value, key),
        removeIfHasntThis: ['startDate'],
        sortFunction: (a, b) => (a as Contract).startDate! - (b as Contract).startDate!);
    await _personalContractDataPackage.init();
    await _delay.wait;
    _allAccountLogData.addAll(_personalContractDataPackage.dataList<Contract>().fold<List<AccountFullLog>>([], (p, e) => p..addAll(e.getAccountFullLog())));
    return true;
  }

  Future<bool> _fetcSalesContractData() async {
    final _salesContractDataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.salesContractCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.salesContractCollectionRef(),
        fetchType: FetchType.ONCE,
        filterDeletedData: true,
        parsePkg: (key, value) => SalesContract.fromJson(value, key),
        removeIfHasntThis: ['startDate'],
        sortFunction: (a, b) => (a as SalesContract).startDate! - (b as SalesContract).startDate!);
    await _salesContractDataPackage.init();
    await _delay.wait;
    _allAccountLogData.addAll(_salesContractDataPackage.dataList<SalesContract>().fold<List<AccountFullLog>>([], (p, e) => p..addAll(e.getAccountFullLog())));

    return true;
  }

  Future<bool> _fetchExpensesData() async {
    final _expenseDataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.expensesCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.expensesCollectionRef(),
        fetchType: FetchType.ONCE,
        filterDeletedData: true,
        parsePkg: (key, value) => Expense.fromJson(value, key),
        removeIfHasntThis: ['d'],
        sortFunction: (a, b) => (a as Expense).date! - (b as Expense).date!);
    await _expenseDataPackage.init();
    await _delay.wait;
    _allAccountLogData.addAll(_expenseDataPackage.dataList<Expense>().fold<List<AccountFullLog>>([], (p, e) => p..addAll(e.getAccountFullLog()!)));

    return true;
  }

  Future<bool> _fetcStudentAccountingData() async {
    Map? _studentAccountingData;

    if (DateTime.now().millisecondsSinceEpoch - Fav.readSeasonCache<int>('readaccountingstatisticstime', 0)! < const Duration(minutes: 10).inMilliseconds && Fav.readSeasonCache<Map>('readlastaccountingstatistics', {}) != null) {
      _studentAccountingData = Fav.readSeasonCache<Map>('readlastaccountingstatistics', {});
    } else {
      await AccountingService.dbAllStudentAccountingData().once().then((snap) {
        _studentAccountingData = snap?.value;
        Fav.writeSeasonCache('readaccountingstatisticstime', DateTime.now().millisecondsSinceEpoch);
        Fav.writeSeasonCache('readlastaccountingstatistics', _studentAccountingData);
      });
    }
    await 100.wait;
    _studentAccountingDataToAccountLog(_studentAccountingData);
    return true;
  }

  ///Burasi realtimedatabasede bulunan ogrenci muhasebisinin datalarini accountloga cevirir
  void _studentAccountingDataToAccountLog(Map? _studentAccountingData) {
    final List<AccountFullLog> _studendAccountingDataList = [];
    _studentAccountingData?.forEach((studentKey, allPaymentList) {
      var _student = AppVar.appBloc.studentService!.dataListItem(studentKey);

      if (allPaymentList['PaymentPlans'] != null && _student != null) {
        (allPaymentList['PaymentPlans'] as Map).forEach((paymentName, paymentValues) {
          if (paymentName == 'custompayment') {
            (paymentValues as Map).forEach((paymentKey, paymentValue) {
              TaksitModel payment = TaksitModel.fromJson(paymentValue);

              if (payment.aktif != false) {
                final double _odennenTutar = payment.odemeler?.fold<double>(0, ((t, v) => t + v.miktar!)) ?? 0;
                final double _kalanTutar = payment.tutar! - _odennenTutar;
                if (_kalanTutar > 0) {
                  _studendAccountingDataList.add(AccountFullLog(
                    name: _student.name + ' ' + payment.name!,
                    accountLogType: AccountLogType.ST,
                    amount: _kalanTutar,
                    date: payment.tarih,
                    tahsilEdilecek: true,
                    label: 'custompayment',
                  ));
                }
                payment.odemeler?.forEach((element) {
                  _studendAccountingDataList.add(AccountFullLog(
                    name: _student.name + ' ' + payment.name!,
                    accountLogType: AccountLogType.ST,
                    amount: element.miktar,
                    date: element.tarih,
                    tahsilEdilecek: false,
                    caseNo: element.kasaNo,
                    label: 'custompayment',
                  ));
                });
              }
            });
          } else {
            var _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentName);

            PaymentModel _payments = PaymentModel.fromJson(paymentValues);

            if (_payments.aktif != false) {
              final List<TaksitModel?> _paymentList = [];
              if (_payments.pesinUcret != null) {
                _paymentList.add(_payments.pesinUcret);
              }
              if (_payments.pesinat != null) {
                _paymentList.add(_payments.pesinat);
              }
              if (_payments.taksitler != null) {
                _paymentList.addAll(_payments.taksitler!);
              }

              _paymentList.forEach((payment) {
                if ((payment!.tutar ?? 0) != 0) {
                  final double _odennenTutar = (payment.odemeler?.fold<double>(0.0, ((t, v) => t + v.miktar!)) ?? 0);
                  final double _kalanTutar = payment.tutar! - _odennenTutar;
                  if (payment.aktif != false) {
                    if (_kalanTutar > 0) {
                      _studendAccountingDataList.add(AccountFullLog(
                        name: _student.name + ' ' + _realPaymentName!,
                        accountLogType: AccountLogType.ST,
                        amount: _kalanTutar,
                        date: payment.tarih,
                        tahsilEdilecek: true,
                        label: paymentName,
                      ));
                    }
                    payment.odemeler?.forEach((element) {
                      _studendAccountingDataList.add(AccountFullLog(
                        name: _student.name + ' ' + _realPaymentName! + ' (${payment.tarih!.dateFormat("d-MMM-yyyy")})',
                        accountLogType: AccountLogType.ST,
                        amount: element.miktar,
                        date: element.tarih,
                        tahsilEdilecek: false,
                        caseNo: element.kasaNo,
                        label: paymentName,
                      ));
                    });
                  }
                }
              });
            }
          }
        });
      }
    });
    _allAccountLogData.addAll(_studendAccountingDataList);
  }

  Virman? virmanItemForSave;
  var virmanFormKey = GlobalKey<FormState>();
  bool isVirmanSaving = false;
  Future<bool> saveVirman({bool delete = false}) async {
    if (virmanFormKey.currentState!.checkAndSave() || delete) {
      if (Fav.noConnection()) return false;
      if (virmanItemForSave!.enteringAmount == 0) return false;

      virmanItemForSave!.virmanType = virmanPageType;
      if (virmanPageType == VirmanType.change) {
        virmanItemForSave!.sendingAmount = virmanItemForSave!.enteringAmount! * -1;
      }

      isVirmanSaving = true;
      update();

      final _completer = Completer<bool>();
      await AppVar.appBloc.firestore.setItemInPkg(ReferenceService.singleDocListCollectionRef() + '/Virmans', 'data', virmanItemForSave!.key!, virmanItemForSave!.toJson(), addParentDocName: false).then((value) async {
        AppVar.appBloc.firestore.setItemInPkg(ReferenceService.accountLogRef() + ReferenceService.getDocName(virmanItemForSave!.key!), 'data', virmanItemForSave!.key!, virmanItemForSave!.toLog(), addParentDocName: false).catchError(log).unawaited;
        virmanPageType = null;
        virmanItemForSave = null;
        OverAlert.saveSuc();
        isVirmanSaving = false;
        update();
        _completer.complete(true);
      }).catchError((err) {
        isVirmanSaving = false;
        update();
        OverAlert.saveErr();
        _completer.complete(false);
      });
      return _completer.future;
    }
    return false;
  }

  Future<void> deleteVirman(Virman item) async {
    virmanItemForSave = item;

    final sure = await Over.sure();
    if (sure) {
      virmanItemForSave!.aktif = false;
      final _result = await saveVirman(delete: true);
      if (_result == true) {
        update();
      } else {
        virmanItemForSave!.aktif = true;
      }
    }
  }
}
