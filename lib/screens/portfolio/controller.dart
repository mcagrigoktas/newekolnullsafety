import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../models/accountdata.dart';
import '../../services/dataservice.dart';
import '../main/menu_list_helper.dart';
import '../managerscreens/registrymenu/studentscreen/student.dart';
import 'helper.dart';
import 'model.dart';
import 'print/portfolio_print_main_helper.dart';
import 'widgets/portfolio_items/examreportwidget.dart';

class PortfolioController extends GetxController {
  Student? selectedStudent;
  List<Portfolio>? _dataList;
  MiniFetcher<Portfolio>? _miniFetcher;

  PortfolioType? portfolioIndex;
  Map<PortfolioType, String> portfolioMap = {
    PortfolioType.examreport: 'portfolios1'.translate,
    PortfolioType.p2p: 'p2p'.translate,
    PortfolioType.rollcall: 'rollcall'.translate,
    if (MenuList.hasTimeTable()) PortfolioType.homeworkCheck: 'homeworkresult'.translate,
    if (MenuList.hasTimeTable()) PortfolioType.examCheck: 'examresult'.translate,
  };

  PortfolioController({this.portfolioIndex = PortfolioType.examreport});

  @override
  void onInit() {
    super.onInit();
    PortfolioHelper.saveLoginTime(portfolioIndex);
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      _dataList = AppVar.appBloc.portfolioService!.dataList;
      AppVar.appBloc.portfolioService!.stream.listen((event) {
        _dataList = AppVar.appBloc.portfolioService!.dataList;
        update();
      });
    }
  }

  String? get studentName => AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.hesapBilgileri.name : selectedStudent!.name;

  List<Student>? get allStudentList => AppFunctions2.getStudentListForTeacherAndManager();
  String filteredStudentText = '';

  List<Student>? get filteredStudentList => filteredStudentText.safeLength < 1
      ? allStudentList
      : allStudentList!.where((student) {
          return student.getSearchText().contains(filteredStudentText);
        }).toList();

  @override
  void onClose() {
    super.onClose();
  }

  void indexChanged(PortfolioType? index) {
    portfolioIndex = index;
    update();

    PortfolioHelper.saveLoginTime(index);
  }

  List<Portfolio> get datalist => (_dataList ?? []).where((element) => portfolioIndex == element.portfolioType).toList();

  Future<void> unSelectStudent() async {
    selectedStudent = null;
    await _miniFetcher?.dispose();
    _miniFetcher = null;
    update();
  }

  Future<void> selectStudent(Student student) async {
    selectedStudent = student;

    await _miniFetcher?.dispose();
    _miniFetcher = null;
    _miniFetcher = MiniFetcher(
      '${AppVar.appBloc.hesapBilgileri.kurumID}${selectedStudent!.key}${AppVar.appBloc.hesapBilgileri.termKey}SPortfolio',
      FetchType.LISTEN,
      multipleData: true,
      removeFunction: (a) => a.portfolioType == null || a.lastUpdate == null,
      lastUpdateKey: 'lastUpdate',
      queryRef: PortfolioService.dbPortfolio(selectedStudent!.key),
      filterDeletedData: true,
      jsonParse: (key, value) => Portfolio.fromJson(value, key),
      sortFunction: (Portfolio a, Portfolio b) => b.lastUpdate - a.lastUpdate,
    );
    OverLoading.show(style: OverLoadingWidgetStyle(text: 'loading'.translate + '\n' + student.name!));

    _miniFetcher!.stream.listen((event) async {
      await (3.random * 500 + 1000).wait;
      await OverLoading.close();
      _dataList = _miniFetcher!.dataList;
      update();
    });
  }

  Widget itemWidget(Portfolio item) {
    if (item.portfolioType == PortfolioType.examreport) {
      return ExamReportMiniWidget(
        item.data(),
        otherExamsData: () {
          return getOtherExamsData(item.data());
        },
        studentName: studentName,
      );
    }
    // if (item.portfolioType == PortfolioType.p2p) {
    //   return P2PMiniWidget(item.data());
    // }
    // if (item.portfolioType == PortfolioType.rollcall) {
    //   return RollCallMiniWidget(item.data());
    // }
    //? Artik homework ve exam farkli yonetiliyor
    // if (item.portfolioType == PortfolioType.homeworkCheck) {
    //   return HomeWorkMiniWidget(item.data());
    // }
    // if (item.portfolioType == PortfolioType.examCheck) {
    //   return HomeWorkMiniWidget(item.data());
    // }
    return const SizedBox();
  }

  List<PortfolioExamReport>? getOtherExamsData(PortfolioExamReport? data) {
    if (_dataList == null) return null;
    final _allExamList = _dataList!.where((element) => element.portfolioType == PortfolioType.examreport);
    // final _sameTypeExamList = _allExamList.where((element) {
    //   final PortfolioExamReport _item = element.data();
    //   return _item.examType.key == data.examType.key;
    // });
    return List<PortfolioExamReport>.from(_allExamList.map((e) => e.data()).toList());
  }

  void printPortfolio() {
    PortfolioPrintHelper.print(_dataList ?? [], portfolioMap, AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.hesapBilgileri.castStudentData as Student? : selectedStudent);
  }
}
