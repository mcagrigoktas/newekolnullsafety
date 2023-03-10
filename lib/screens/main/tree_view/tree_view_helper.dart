import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../adminpages/screens/appchanges/changelogs/changelog.dart';
import '../../../adminpages/screens/evaulationadmin/examtypes/controller.dart';
import '../../../adminpages/screens/evaulationadmin/examtypes/examtypedefine.dart';
import '../../../adminpages/screens/evaulationadmin/examtypes/model.dart';
import '../../../adminpages/screens/evaulationadmin/helper.dart';
import '../../../adminpages/screens/evaulationadmin/opticformtypes/controller.dart';
import '../../../adminpages/screens/evaulationadmin/opticformtypes/opticformdefine.dart';
import '../../../adminpages/screens/evaulationadmin/route_management.dart';
import '../../../appbloc/appvar.dart';
import '../../../constant_settings.dart';
import '../../../flavors/themelist/helper.dart';
import '../../../helpers/manager_authority_helper.dart';
import '../../../models/accountdata.dart';
import '../../../services/dataservice.dart';
import '../../../test_screen.dart';
import '../../accounting/route_management.dart';
import '../../accounting/studentaccounting/widgets/planreview_for_student.dart';
import '../../generallyscreens/birthdaypage/layout.dart';
import '../../guiding/caserecords/layout.dart';
import '../../healthcare/addmedicine.dart';
import '../../loginscreen/qr_code_web_login.dart';
import '../../managerscreens/othersettings/firstloginlist.dart';
import '../../managerscreens/othersettings/route_managament.dart';
import '../../managerscreens/othersettings/usegeinfo.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../../managerscreens/programsettings/route_managament.dart';
import '../../managerscreens/registrymenu/classscreen/layout.dart';
import '../../managerscreens/registrymenu/lessonsscreen/layout.dart';
import '../../managerscreens/registrymenu/managersscreen/layout.dart';
import '../../managerscreens/registrymenu/personslist/layout.dart';
import '../../managerscreens/registrymenu/preregistration/layout.dart';
import '../../managerscreens/registrymenu/studentscreen/layout.dart';
import '../../managerscreens/registrymenu/teacherscreen/layout.dart';
import '../../managerscreens/schoolsettings/route_managament.dart';
import '../../p2p/route_managament.dart';
import '../../p2p/simple/reserve_p2p/layout.dart';
import '../../portfolio/eager_portfolio_main.dart';
import '../../rollcall/ekidrollcallmanagerpage.dart';
import '../../rollcall/ekidrollcallstudent.dart';
import '../../rollcall/ekolrollcallmanagerpage.dart';
import '../../rollcall/ekolrollcallstudentpage.dart';
import '../../survey/route_management.dart';
import '../../technical_support_page/technicalsupport.dart';
import '../../timetable/homework/homeworkpublish.dart';
import '../../timetable/homework/homeworkstudenttaken.dart';
import '../../transporterscreens/existingbusrides/model.dart';
import '../../transporterscreens/route_management.dart';
import '../menu_list_helper.dart';
import 'custom_node.dart';

class TreeViewHelper {
  TreeViewHelper._();
  static void setupTreeViewNodes(SidebarNode? rootNode) {
    Fav.writeSeasonCache(SidebarNode.favoriteUsageSeasonCacheKey, <String, FavoriteUsage>{});

    final appBloc = AppVar.appBloc;

    ///Idareci icin nodes
    if (appBloc.hesapBilgileri.gtM) {
      rootNode!.addAll([
        SidebarNode(name: "registrymenu".translate, icon: MdiIcons.accountMultiplePlus)
          ..addAll([
            if (isDebugMode) SidebarNode(name: "Kod Deneme Ekrani".translate, onTap: () => Fav.guardTo(CodeTestScreen()), icon: MdiIcons.accountClock),
            if (MenuList.hasPreRegistration() && AuthorityHelper.hasYetki1()) SidebarNode(name: "preregister".translate, onTap: () => Fav.guardTo(PreRegistrationList()), icon: MdiIcons.accountClock),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "studentlist".translate, onTap: () => Fav.guardTo(StudentList()), icon: MdiIcons.accountGroup),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "teacherlist".translate, onTap: () => Fav.guardTo(TeacherList()), icon: MdiIcons.humanMaleBoardPoll),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "lessonlist".translate, onTap: _openLessonList, icon: MdiIcons.bookOpenVariant),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "classlist".translate, onTap: () => Fav.guardTo(ClassList()), icon: MdiIcons.googleClassroom),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "personlist".translate, onTap: () => Fav.guardTo(PersonsList()), icon: MdiIcons.humanQueue),
            if (AppVar.appBloc.hesapBilgileri.uid == 'Manager1') SidebarNode(name: "managerlist".translate, onTap: () => Fav.guardTo(ManagerList()), icon: MdiIcons.accountTie),
          ]),
        SidebarNode(name: "educationsettingsmain".translate, icon: MdiIcons.library)
          ..addAll([
            if (MenuList.hasTimeTable() && AuthorityHelper.hasYetki10()) SidebarNode(name: "rcmenuname".translate, onTap: () => Fav.guardTo(EkolRollCallManagerPage()), icon: MdiIcons.accountEyeOutline),
            if (AuthorityHelper.hasYetki10() && AppVar.appBloc.hesapBilgileri.isEkid && !MenuList.hasTimeTable()) SidebarNode(name: "rcmenuname".translate, onTap: () => Fav.guardTo(EkidRollCallManagerStudentReview()), icon: MdiIcons.accountEyeOutline),
            if (AuthorityHelper.hasYetki10() && MenuList.hasTimeTable())
              SidebarNode(name: "homeworklist".translate, icon: MdiIcons.notebookEdit)
                ..addAll([
                  if (UserPermissionList.hasTeacherHomeWorkSharing() == false) SidebarNode(name: "hwwaitpublish".translate, onTap: () => Fav.guardTo(HomeWorkPublish()), icon: MdiIcons.notebookCheckOutline),
                  SidebarNode(name: "hwstudenttaken".translate, onTap: () => Fav.guardTo(HomeWorkStudentTaken()), icon: MdiIcons.notebookPlusOutline),
                ]),
            if (AuthorityHelper.hasYetki4() && MenuList.hasSurvey()) SidebarNode(name: "makesurvey".translate, onTap: SurveyMainRoutes.goSurveyList, icon: MdiIcons.chartMultiple),
            if (AuthorityHelper.hasYetki10() && MenuList.hasTimeTable() && MenuList.hasSimpleP2P() == false) SidebarNode(name: "p2pmenuname".translate, onTap: P2PMainRoutes.goFreeStyleP2PScreen, icon: MdiIcons.accountMultiple),
            if (AuthorityHelper.hasYetki10() && MenuList.hasSimpleP2P()) SidebarNode(name: "p2pmenuname".translate, onTap: () => Fav.guardTo(ReserveP2PLayout()), icon: MdiIcons.accountMultiple),
            if (AuthorityHelper.hasYetki10() && MenuList.hasPortfolio()) SidebarNode(name: "portfolio".translate, onTap: () => Fav.guardTo(PortfolioMain()), icon: MdiIcons.clipboardListOutline),
            if (AuthorityHelper.hasYetki7()) SidebarNode(name: "caserecord".translate, onTap: _openCaseRecordPage, icon: MdiIcons.pencilBox),
            //   if (isDebugAccount) SidebarNode(name: "Psikolink".translate, onTap: () => Fav.guardTo(PsikolinkMain()), icon: MdiIcons.clippy),
          ]),
        if (MenuList.hasTimeTable())
          SidebarNode(name: "programsettingsmain".translate, icon: MdiIcons.tableEdit)
            ..addAll([
              if (AuthorityHelper.hasYetki10() || AuthorityHelper.hasYetki12()) SidebarNode(name: "classprogrammenuname".translate, onTap: TimeTablesMainRoutes.goClassProgram, icon: MdiIcons.calendar),
              if (AuthorityHelper.hasYetki10() || AuthorityHelper.hasYetki12()) SidebarNode(name: "teacherprogrammenuname".translate, onTap: TimeTablesMainRoutes.goTeacherProgram, icon: MdiIcons.tableAccount),
              if (AuthorityHelper.hasYetki12()) SidebarNode(name: "schooltimes".translate, onTap: TimeTablesMainRoutes.goSchoolTimes, icon: MdiIcons.timelineClock),
              //        SidebarNode(name: "teacherworkingtimes".translate, onTap: () => Fav.guardTo(TeacherHoursMainPage())),
              //        SidebarNode(name: "classactivetimes".translate, onTap: () => Fav.guardTo(ClassHoursMainPage())),
              if (AuthorityHelper.hasYetki12()) SidebarNode(name: "timetables".translate, onTap: TimeTablesMainRoutes.goEditTimeTables, icon: MdiIcons.tableLargePlus),
            ]),
        if (MenuList.hasEvaulation() && AuthorityHelper.hasYetki13())
          SidebarNode(name: "evaulationscreenname".translate, icon: Icons.stacked_bar_chart)
            ..addAll([
              SidebarNode(
                  name: "evaulationexams".translate,
                  onTap: () {
                    EvaulationMainRoutes.goExamDefinePage(EvaulationUserType.school);
                  },
                  icon: MdiIcons.clipboardTextClock),
              SidebarNode(name: "opticalforms".translate, onTap: _openOpticalFormPages, icon: MdiIcons.formatColumns),
              SidebarNode(name: "examtypes".translate, onTap: _openExamTypeListPage, icon: MdiIcons.airFilter),
            ]),
        if (MenuList.hasAccounting() && AuthorityHelper.hasYetki3())
          SidebarNode(name: "accounting".translate, icon: MdiIcons.cash)
            ..addAll([
              SidebarNode(name: "studentaccounting".translate, onTap: AccountingMainRoutes.goStudentAccounting, icon: MdiIcons.accountCashOutline),
              //  SidebarNode(name: "showpayments".translate, onTap: () => Fav.guardTo(ShowPaymentsPage()), icon: MdiIcons.cash100),
              //  SidebarNode(name: "accountingstatitictype0".translate, onTap: () => Fav.guardTo(PastStatistics()), icon: MdiIcons.chartLine),
              //  SidebarNode(name: "accountingstatitictype1".translate, onTap: () => Fav.guardTo(MonthlyStatistics()), icon: MdiIcons.chartLineStacked),
              SidebarNode(name: "contracts".translate, onTap: AccountingMainRoutes.goContracts, icon: MdiIcons.fileSign),
              SidebarNode(name: "salescontracts".translate, onTap: AccountingMainRoutes.goSalesContracts, icon: MdiIcons.fileDocumentEditOutline),

              SidebarNode(name: "expenses".translate, onTap: AccountingMainRoutes.goExpenses, icon: MdiIcons.storeEditOutline),
              SidebarNode(name: "financialanalysis".translate, onTap: AccountingMainRoutes.goFinancalAnalsis, icon: MdiIcons.chartHistogram),
              //   SidebarNode(name: "accountingstatistics".translate, onTap: () => Fav.guardTo(AccountingStatisticsMain()), icon: MdiIcons.chart_line),
              SidebarNode(name: "accountingsettings".translate, onTap: AccountingMainRoutes.goAccountingSettings, icon: MdiIcons.cogStop),
            ]),
        if (MenuList.hasHealthcare() && AuthorityHelper.hasYetki11())
          SidebarNode(name: "healthcare".translate, icon: MdiIcons.lotionPlusOutline)
            ..addAll([
              SidebarNode(name: "medicineprofilelist".translate, onTap: () => Fav.guardTo(AddedMedicineList()), icon: MdiIcons.pill),
            ]),
        if (MenuList.hasTransporter())
          SidebarNode(name: "transportersmenuname".translate, icon: MdiIcons.busSchool)
            ..addAll([
              if (AuthorityHelper.hasYetki1()) SidebarNode(name: "transportlist".translate, onTap: TransportingMainRoutes.goTransporterList, icon: MdiIcons.busMultiple),
              if (AuthorityHelper.hasYetki1() || AuthorityHelper.hasYetki10()) SidebarNode(name: "busriderollcalls".translate, onTap: _openServiceRollCallPageForManager, icon: MdiIcons.accountCheck),
              SidebarNode(name: "buslocations".translate, onTap: _openBusLocationsForManager, icon: MdiIcons.busMarker),
            ]),
        SidebarNode(name: "othersettingsmain".translate, icon: MdiIcons.dotsVerticalCircleOutline)
          ..addAll([
            if (AuthorityHelper.hasYetki2()) SidebarNode(name: "schoolsettings".translate, onTap: SchoolSettingsMainRoutes.goSchoolSettings, icon: MdiIcons.cogs),
            if (AuthorityHelper.hasYetki2()) SidebarNode(name: "permissionlist".translate, onTap: OtherSettingsMainRoutes.goUserPermissionPage, icon: MdiIcons.crowd),
            if (AuthorityHelper.hasYetki10() && MenuList.hasBirthdayList()) SidebarNode(name: "birthdaylist".translate, onTap: () => Fav.guardTo(BirthdayListPage()), icon: MdiIcons.cake),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "usageinfo".translate, onTap: () => Fav.guardTo(UsageInfo()), icon: MdiIcons.information),
            if (AuthorityHelper.hasYetki1()) SidebarNode(name: "firstloginlist".translate, onTap: () => Fav.guardTo(FirstLoginList()), icon: MdiIcons.login),
            SidebarNode(name: "callcenter".translate, onTap: () => Fav.guardTo(TechnicalSupportPage()), icon: MdiIcons.headset),
            SidebarNode(name: "changethemeekol".translate, onTap: ThemeHelper.openThemeSelector, icon: MdiIcons.palette),
            if ('lang'.translate == 'tr') SidebarNode(name: "changelog".translate, onTap: () => Fav.guardTo(ChangeLogPage()), icon: MdiIcons.newspaperVariantMultiple),
            if (!isWeb) SidebarNode(name: "webqrcodelogin".translate, onTap: () => Fav.guardTo(QRCodeWebLogin()), icon: Icons.qr_code_rounded),
          ]),
      ]);
      List<FavoriteUsage> favoriteList = ((Fav.readSeasonCache(SidebarNode.favoriteUsageSeasonCacheKey) as Map<String, FavoriteUsage>).entries.toList()..sort((a, b) => b.value.usageCount! - a.value.usageCount!)).fold([], (p, e) => p..add(e.value));
      if (favoriteList.isNotEmpty && Get.context != null && Get.context!.width > 600) {
        rootNode.insert(
          0,
          SidebarNode(name: "favorites".translate, icon: MdiIcons.star)..addAll(favoriteList.take(5).map((e) => SidebarNode(name: e.name, onTap: e.node!.onTap, icon: e.node!.icon)).toList()),
        );
      }
    } else
//?
//
//
// Ogretmen icin nodes
    if (appBloc.hesapBilgileri.gtT) {
      rootNode!.addAll([
        SidebarNode(name: "studentlist".translate, onTap: () => Fav.guardTo(StudentList()), icon: MdiIcons.accountGroupOutline),
        if (MenuList.hasSimpleP2P()) SidebarNode(name: "p2pmenuname".translate, onTap: () => Fav.guardTo(ReserveP2PLayout()), icon: MdiIcons.accountMultiple),
        if (appBloc.hesapBilgileri.isEkolOrUni) SidebarNode(name: "hwstudenttaken".translate, onTap: () => Fav.guardTo(HomeWorkStudentTaken()), icon: MdiIcons.notebookPlusOutline),
        if (MenuList.hasPortfolio()) SidebarNode(name: "portfolio".translate, onTap: () => Fav.guardTo(PortfolioMain()), icon: MdiIcons.clipboardListOutline),
        if (MenuList.hasSurvey()) SidebarNode(name: "makesurvey".translate, onTap: SurveyMainRoutes.goSurveyList, icon: MdiIcons.chartMultiple),
        SidebarNode(name: "caserecord".translate, onTap: _openCaseRecordPage, icon: MdiIcons.pencilBox),
        if (MenuList.hasHealthcare())
          SidebarNode(name: "healthcare".translate, icon: MdiIcons.lotionPlusOutline)
            ..addAll([
              SidebarNode(name: "medicineprofilelist".translate, onTap: () => Fav.guardTo(AddedMedicineList()), icon: MdiIcons.pill),
            ]),
        if (MenuList.hasBirthdayList()) SidebarNode(name: "birthdaylist".translate, onTap: () => Fav.guardTo(BirthdayListPage()), icon: MdiIcons.cake),
        SidebarNode(name: "callcenter".translate, onTap: () => Fav.guardTo(TechnicalSupportPage()), icon: MdiIcons.headset),
        if (isDebugAccount && 'lang'.translate == 'tr') SidebarNode(name: "changelog".translate, onTap: () => Fav.guardTo(ChangeLogPage()), icon: MdiIcons.newspaperVariantMultiple),
        SidebarNode(name: "changethemeekol".translate, onTap: ThemeHelper.openThemeSelector, icon: MdiIcons.palette),
      ]);
    } else
//?
//
//
//Ogrenci icin nodes
    if (appBloc.hesapBilgileri.gtS) {
      rootNode!.addAll([
        if (MenuList.hasTimeTable()) SidebarNode(name: "rollcallinfo".translate, onTap: () => Fav.guardTo(EkolRollCallStudentPage()), icon: MdiIcons.accountEyeOutline),
        if (!MenuList.hasTimeTable() && AppVar.appBloc.hesapBilgileri.isEkid) SidebarNode(name: "rollcallinfo".translate, onTap: () => Fav.guardTo(EkidRollCallStudentPage()), icon: MdiIcons.accountEyeOutline),
        if (MenuList.hasAccounting() && (AppVar.appBloc.hesapBilgileri.isEkid || appBloc.hesapBilgileri.isParent == true)) SidebarNode(name: "mypaymentplan".translate, onTap: () => Fav.guardTo(StudentPlanReview()), icon: MdiIcons.cash),
        if (MenuList.hasHealthcare())
          SidebarNode(name: "healthcare".translate, icon: MdiIcons.lotionPlusOutline)
            ..addAll([
              SidebarNode(name: "medicineprofilelist".translate, onTap: () => Fav.guardTo(AddedMedicineList()), icon: MdiIcons.pill),
            ]),
        if (MenuList.hasTransporter())
          SidebarNode(name: "transportersmenuname".translate, icon: MdiIcons.busSchool)
            ..addAll([
              SidebarNode(name: "buslocation".translate, onTap: _openBusLocationsForStudent, icon: MdiIcons.busMarker),
              SidebarNode(name: "transporterinfo".translate, onTap: TransportingMainRoutes.goStudentScreenTransporterInfo, icon: MdiIcons.cardAccountPhoneOutline),
            ]),
        SidebarNode(name: "callcenter".translate, onTap: () => Fav.guardTo(TechnicalSupportPage()), icon: MdiIcons.headset),
        SidebarNode(name: "changethemeekol".translate, onTap: ThemeHelper.openThemeSelector, icon: MdiIcons.palette),
      ]);
    }
  }

  static Future<void> _openServiceRollCallPageForManager() async {
    OverLoading.show();
    MiniFetcher<BusRideModel> existingBusRides = MiniFetcher<BusRideModel>(
      AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.termKey + 'ServiceRollCallListAllVehicle',
      FetchType.ONCE,
      multipleData: true,
      lastUpdateKey: 'lastUpdate',
      queryRef: RollCallService.dbAllServiceRollCallData(),
      jsonParse: (key, value) => BusRideModel(transporterUid: value['uid'], name: value['time'] + '/' + (AppVar.appBloc.transporterService!.dataListItem(value['uid'])?.profileName ?? 'erasedtransporter'.translate), key: key, data: value),
    );
    await 2000.wait;
    await OverLoading.close();

    if (existingBusRides.dataList.isNotEmpty) {
      await TransportingMainRoutes.goExistingBusridesScreen(existingBusRides.dataList);
    } else {
      'norecords'.translate.showAlert(AlertType.danger);
    }
  }

  static Future<void> _openLessonList() async {
    if ((AppVar.appBloc.teacherService!.dataList.isNotEmpty) && (AppVar.appBloc.classService!.dataList.isNotEmpty)) {
      await Fav.guardTo(LessonList());
    } else {
      OverAlert.show(type: AlertType.danger, message: 'notactiveyet'.translate);
    }
  }

  static Future<void> _openOpticalFormPages() async {
    OverLoading.show();
    if (Get.isRegistered<ExamTypeController>()) await Get.delete<ExamTypeController>();
    Get.put(ExamTypeController(EvaulationUserType.school));
    await 2000.wait;
    await OverLoading.close();
    ExamTypeController controller = Get.find<ExamTypeController>();
    final _value = await OverPage.openChoosebleListViewFromMap(data: controller.allExamType.fold<Map>({}, (p, e) => p..[e] = e.name), title: 'examtype'.translate, extraWidget: 'opticformexamtypehint'.translate.text.bold.make());

    //  final value = await controller.allExamType.fold<Map>({}, (p, e) => p..[e] = e.name).makeSheet(title: 'examtype'.translate);
    if (_value is ExamType) {
      await Fav.guardTo(OpticFormDefine(), binding: BindingsBuilder(() => Get.put<OpticFormDefineController>(OpticFormDefineController(_value, EvaulationUserType.school))));
    }
  }

  static Future<void> _openBusLocationsForStudent() async {
    final _transporter = AppVar.appBloc.hesapBilgileri.studentTransporter;
    if (_transporter == null) {
      OverAlert.show(message: 'notransporter'.translate, type: AlertType.danger);
    } else {
      await TransportingMainRoutes.goServiceLocationScreen(transporterList: [_transporter]);
    }
  }

  static Future<void> _openBusLocationsForManager() async {
    if (AppVar.appBloc.transporterService!.dataList.isEmpty) {
      OverAlert.show(message: 'notransporter'.translate, type: AlertType.danger);
    } else {
      await TransportingMainRoutes.goServiceLocationScreen(transporterList: AppVar.appBloc.transporterService!.dataList);
    }
  }

  static Future<void>? _openExamTypeListPage() async {
    if (Get.isRegistered<ExamTypeController>()) await Get.delete<ExamTypeController>();
    return Fav.guardTo(ExamTypeDefine(), binding: BindingsBuilder(() async {
      Get.put<ExamTypeController>(ExamTypeController(EvaulationUserType.school));
    }));
  }

  static void _openCaseRecordPage() {
    if (AppVar.appBloc.hesapBilgileri.gtT) Fav.to(CaseRecordPage());
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki7(warning: true)) Fav.to(CaseRecordPage());
  }
}
