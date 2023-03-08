import 'package:mcg_database/fetcherboxes/multiple_data_fetcher.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:turkish/turkish.dart';

import '../constant_settings.dart';
import '../models/accountdata.dart';
import '../models/allmodel.dart';
import '../models/notification.dart';
import '../qbank/models/models.dart';
import '../screens/announcements/helper.dart';
import '../screens/dailyreport/helper.dart';
import '../screens/eders/livebroadcast/helper.dart';
import '../screens/eders/videochat/helper.dart';
import '../screens/educations/model.dart';
import '../screens/loginscreen/loginscreen.giris_turu_helper.dart';
import '../screens/main/menu_list_helper.dart';
import '../screens/managerscreens/othersettings/user_permission/user_permission.dart';
import '../screens/managerscreens/programsettings/programlistmodels.dart';
import '../screens/mesagging/helper.dart';
import '../screens/p2p/simple/edit_p2p_draft/model.dart';
import '../screens/portfolio/helper.dart';
import '../screens/portfolio/model.dart';
import '../screens/rollcall/ekidrollcallstudent.dart';
import '../screens/rollcall/ekolrollcallstudentpage.dart';
import '../screens/rollcall/helper.dart';
import '../screens/social/helper.dart';
import '../screens/timetable/helper.dart';
import '../screens/timetable/homework_helper.dart';
import '../screens/timetable/modelshw.dart';
import '../services/dataservice.dart';
import '../services/pushnotificationservice.dart';
import '../services/reference_service.dart';
import '../services/remote_control.dart';
import 'appbloc.dart';
import 'appvar.dart';
import 'databaseconfig.dart';

class AppblocDefineServiceHelper {
  AppblocDefineServiceHelper._();

  static AppBloc get _appBloc => AppVar.appBloc;
  static HesapBilgileri get _hesapBilgileri => AppVar.appBloc.hesapBilgileri;
  static BundleConfig get bundleConfig => BundleConfig(fileLocation: _hesapBilgileri.kurumID, firebaseStorageUrlPrefix: DatabaseStarter.databaseConfig.firebaseStorageUrlPrefix);

  static Future<void> defineEducationService() async {
    if (!MenuList.hasQBank()) return;

    _appBloc.educationService = PkgFireBox(
        boxKeyWithoutVersionNo: "${_hesapBilgileri.genelMudurlukEducationList.join('')}EducationList",
        collectionPath: ReferenceService.publicEducationListRef(),
        fetchType: FetchType.NONE,
        parsePkg: (key, value) => Education.fromJson(value, key),
        targetList: _hesapBilgileri.genelMudurlukEducationList,
        sortFunction: (Education a, Education b) {
          return a.lastUpdate! - b.lastUpdate!;
        },
        removeIfHasntThis: ['name']);
    await _appBloc.educationService!.init();
  }

  static Future<void> defineNotificationTokenService() async {
    _appBloc.notificationTokenService = MultipleDataFCS<TokenModel>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.girisTuru}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}NotificationTokenList",
      queryRefForRealtimeDB: (_hesapBilgileri.gtMT || _hesapBilgileri.gtTransporter) ? SignInOutService.dbTokenList2TSM() : SignInOutService.dbTokenList2TM(),
      jsonParse: (key, value) => TokenModel.fromJson(value, key),
      lastUpdateKey: 'lastUpdate',
      removeFunction: (p0) => p0.tokenData == null || p0.tokenData!.isEmpty,
    );
    await _appBloc.notificationTokenService!.init();
  }

  static Future<void> definePortfolioService() async {
////todowrong birebir ajandaya portfolio acik olmayinca yerlesmiyor
    if (!MenuList.hasPortfolio()) return;

    if (_hesapBilgileri.gtS || _hesapBilgileri.gtT) {
      _appBloc.portfolioService = MultipleDataFCS<Portfolio>(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}Portfolio",
        queryRefForRealtimeDB: PortfolioService.dbPortfolio(_hesapBilgileri.uid),
        jsonParse: (key, value) => Portfolio.fromJson(value, key),
        lastUpdateKey: 'lastUpdate',
        sortFunction: (Portfolio a, Portfolio b) => b.lastUpdate - a.lastUpdate,
        afterGetValue: () {
          PortfolioHelper.afterPortfolioGetData();
        },
        removeFunction: (p0) => p0.portfolioType == null,
      );
      await _appBloc.portfolioService!.init();
    }
  }

  static Future<void> defineHomeworkService() async {
    if (!MenuList.hasTimeTable()) return;
    if ((_hesapBilgileri.gtS || _hesapBilgileri.gtT) == false) return;

    _appBloc.homeWorkService = MultipleDataFCS<HomeWork>("${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}HomeWork",
        queryRefForRealtimeDB: HomeWorkService.dbUserHomeWorkRef(),
        jsonParse: (key, value) => HomeWork.fromJson(value, key),
        maxCount: 2000,
        removeFunction: (p0) => p0.teacherKey == null,
        lastUpdateKey: 'timeStamp',
        afterGetValue: () {
          HomeWorkHelper.afterHomeWorkNewData();
        });
    await _appBloc.homeWorkService!.init();
  }

  static Future<void> defineStudentRollCallService() async {
    if (_appBloc.hesapBilgileri.gtS == false) return;

    _appBloc.studentRollCallService = MultipleDataFCS("${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}RollCall",
        queryRefForRealtimeDB: MenuList.hasTimeTable() ? RollCallService.dbEkolStudentGetRollCall() : RollCallService.dbEkidStudentGetRollCall(),
        jsonParse: (key, value) {
          return MenuList.hasTimeTable() ? EkolRolCallStudentModel.fromJson(value, key) : EkidRolCallStudentModel.fromJson(value, key);
        },
        lastUpdateKey: 'lastUpdate',
        afterGetValue: () {
          RollCallHelper.afterRollCallsNewData();
        });
    await _appBloc.studentRollCallService!.init();
  }

  static Future<void> defineTimeTableService() async {
    if (!MenuList.hasTimeTable()) return;

    _appBloc.tableProgramService = MultipleDataFCS(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}TimeTable",
      queryRefForRealtimeDB: ProgramService.dbGetActiveTimeTable(),
      lastUpdateKey: 'timeStamp',
      maxCount: _hesapBilgileri.gtM ? 25 : 1,
      afterGetValue: () {
        TimeTableHelper.afterTimeTableNewData();
      },
    );
    await _appBloc.tableProgramService!.init();
  }

  static Future<void> defineTecherAndClassHourService() async {
    if (_hesapBilgileri.gtM == false) return;
    if (_hesapBilgileri.isEkolOrUni == false) return;

    _appBloc.teacherHoursService = SingleDataFCS(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}TeacherHours",
      queryRef: ProgramService.dbGetAllTeacherWorkTimes(),
    );
    await _appBloc.teacherHoursService!.init();

    _appBloc.classHoursService = SingleDataFCS(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}ClassHours",
      queryRef: ProgramService.dbGetAllClassActiveTimes(),
    );
    await _appBloc.classHoursService!.init();
  }

  static Future<void> defineSchooltimeService() async {
    if (!MenuList.hasTimeTable()) return;

    _appBloc.schoolTimesService = MultipleDataFCS<TimesModel>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}SchoolTimes",
      queryRefForRealtimeDB: ProgramService.dbGetTimes(),
      jsonParse: (key, value) => TimesModel.fromJson(value),
      sortFunction: (TimesModel a, TimesModel b) {
        return a.timeStamp - b.timeStamp;
      },
      maxCount: 1,
      lastUpdateKey: 'timeStamp',
      removeFunction: (p0) => p0.activeDays == null,
    );
    await _appBloc.schoolTimesService!.init();
  }

  static Future<void> defineLiveBroadcastService() async {
    if (!MenuList.hasLivebroadcast()) return;

    _appBloc.liveBroadcastService = MultipleDataFCS<LiveBroadcastModel>("${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}LiveBroadcastModel",
        queryRefForRealtimeDB: LiveBroadCastService.dbGetLiveBroadcastLessons(),
        jsonParse: (key, value) => LiveBroadcastModel.fromJson(value, key),
        sortFunction: (LiveBroadcastModel a, LiveBroadcastModel b) {
          if (b.timeType == 1) return 1;
          if (a.timeType == 1) return -1;
          return a.startTime! - b.startTime!;
        },
        lastUpdateKey: 'lastUpdate',
        removeFunction: (p0) => p0.startTime == null,
        afterGetValue: () {
          LiveBroadcastMainHalper.afterLiveBroadCastNewData();
        });
    await _appBloc.liveBroadcastService!.init();
  }

  static Future<void> defineVideoChatStudentAndTeacherService() async {
    if (!MenuList.hasVideoLesson()) return;

    if (_hesapBilgileri.gtT) {
      _appBloc.videoChatTeacherService = MultipleDataFCS<VideoLessonProgramModel>("${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}VideoLessonProgramModel",
          queryRefForRealtimeDB: VideoChatService.dbGetTeacherVideoLessons(_hesapBilgileri.uid),
          jsonParse: (key, value) => VideoLessonProgramModel.fromJson(value, key),
          sortFunction: (VideoLessonProgramModel a, VideoLessonProgramModel b) {
            return b.startTime! - a.startTime!;
          },
          lastUpdateKey: 'timeStamp',
          removeFunction: (p0) => p0.startTime == null,
          afterGetValue: () {
            VideoChatHelper.afterVideoChatNewData();
          });
      await _appBloc.videoChatTeacherService!.init();
    } else if (_hesapBilgileri.gtS) {
      _appBloc.videoChatStudentService = MultipleDataFCS<VideoLessonStudentModel>("${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}VideoLessonProgramModel",
          queryRefForRealtimeDB: VideoChatService.dbGetStudentVideoLessons(),
          jsonParse: (key, value) => VideoLessonStudentModel.fromJson(value, key),
          sortFunction: (VideoLessonStudentModel a, VideoLessonStudentModel b) {
            return b.startTime! - a.startTime!;
          },
          lastUpdateKey: 'timeStamp',
          removeFunction: (p0) => p0.startTime == null,
          afterGetValue: () {
            VideoChatHelper.afterVideoChatNewData();
          });
      await _appBloc.videoChatStudentService!.init();
    }
  }

  static Future<void> defineUserInfoChangeService() async {
    final _girisTuruKey = LoginScreenGirisTuruHelper.girisTuruKey(_hesapBilgileri.girisTuru);
    _appBloc.userInfoChangeService = SingleDataFCS(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}UserInfoChangeService",
      queryRef: UserInfoService.dbGetUserInfo(_hesapBilgileri.kurumID, _girisTuruKey, _hesapBilgileri.uid, _hesapBilgileri.termKey),
      getValueAfterOnlyDatabaseQuery: _parseUserInfo,
    );
    await _appBloc.userInfoChangeService!.init();
  }

  static void _parseUserInfo(Map data) {
    // if (data == null) return;
    _hesapBilgileri.userData = data;
    if (_hesapBilgileri.gtM) {
      final model = Manager.fromJson(data, _hesapBilgileri.uid);
      //if (model.aktif != true || model.username != hesapBilgileri.username || model.password != hesapBilgileri.password) return signOut();
      if (model.aktif != true) return _appBloc.signOut();
      if (model.username != _hesapBilgileri.username) return _appBloc.signOut();

      final Map userOtherData = model.otherData ?? {};
      _hesapBilgileri.otherData['zoomApiKey'] = userOtherData['zak'] != null ? (userOtherData['zak'] as String).unMix : userOtherData['zoomApiKey'];
      _hesapBilgileri.otherData['zoomApiSecret'] = userOtherData['zas'] != null ? (userOtherData['zas'] as String).unMix : userOtherData['zoomApiSecret'];

      _hesapBilgileri.imgUrl = model.imgUrl;
      _hesapBilgileri.name = model.name;
      _hesapBilgileri.girisYapildi = true;

      _hesapBilgileri.authorityList = List<String>.from(model.authorityList ?? []);
    } else if (_hesapBilgileri.gtT) {
      final model = Teacher.fromJson(data, _hesapBilgileri.uid);
      //    if (model.aktif != true || model.username != hesapBilgileri.username || model.password != hesapBilgileri.password) return signOut();
      if (model.aktif != true) return _appBloc.signOut();
      if (model.username != _hesapBilgileri.username) return _appBloc.signOut();
      //    if (model.aktif != true || model.username != hesapBilgileri.username || model.password != hesapBilgileri.password) return signOut();

      final Map userOtherData = model.otherData ?? {};
      _hesapBilgileri.otherData['zoomApiKey'] = userOtherData['zak'] != null ? (userOtherData['zak'] as String).unMix : userOtherData['zoomApiKey'];
      _hesapBilgileri.otherData['zoomApiSecret'] = userOtherData['zas'] != null ? (userOtherData['zas'] as String).unMix : userOtherData['zoomApiSecret'];

      _hesapBilgileri.imgUrl = model.imgUrl;
      _hesapBilgileri.name = model.name;
      _hesapBilgileri.girisYapildi = true;

      _hesapBilgileri.teacherSeeAllClass = model.seeAllClass ?? false;
    } else if (_hesapBilgileri.gtS) {
      final model = Student.fromJson(data, _hesapBilgileri.uid);
      if (model.aktif != true) return _appBloc.signOut();
      if (model.username != _hesapBilgileri.username) return _appBloc.signOut();

      //if (model.password != hesapBilgileri.password) return signOut();

      _hesapBilgileri.imgUrl = model.imgUrl;
      _hesapBilgileri.name = model.name;
      _hesapBilgileri.girisYapildi = true;
      _hesapBilgileri.parentState = model.parentState;

      _hesapBilgileri.class0 = model.class0 ?? "";
      _hesapBilgileri.groupList = Map<String, String>.from(model.groupList);
    } else if (_hesapBilgileri.gtTransporter) {
      final model = Transporter.fromJson(data, _hesapBilgileri.uid);
      if (model.aktif != true) return _appBloc.signOut();
      if (model.username != _hesapBilgileri.username) return _appBloc.signOut();
      _hesapBilgileri.name = model.driverName;
      _hesapBilgileri.girisYapildi = true;
    }

    _hesapBilgileri.savePreferences();
  }

  static Future<void> defineMedicineProfileService() async {
    if (!MenuList.hasHealthcare()) return;

    _appBloc.medicineProfileService = MultipleDataFCS<MedicineProfile>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}MedicineProfiles",
      queryRefForRealtimeDB: MedicineService.dbMedicineProfilessRef(),
      jsonParse: (key, value) => MedicineProfile.fromJson(value, key),
      lastUpdateKey: 'timeStamp',
    );
    await _appBloc.medicineProfileService!.init();
  }

  static Future<void> defineDailyStickerProfileAndStickerService() async {
    if (!MenuList.hasStickers()) return;

    _appBloc.stickersProfileService = MultipleDataFCS<Sticker>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}StickerProfiles",
      queryRefForRealtimeDB: StickerService.dbStickersProfilesRef(),
      jsonParse: (key, value) => Sticker.fromJson(value, key),
      lastUpdateKey: 'lastUpdate',
      removeFunction: (p0) => p0.title.safeLength < 1,
    );
    await _appBloc.stickersProfileService!.init();
    if (_hesapBilgileri.gtS) {
      _appBloc.stickerService = SingleDataFCS(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}Stickers",
        queryRef: StickerService.dbStudentStickersRef(_hesapBilgileri.uid),
        // getValueAfterOnlyDatabaseQuery: (value) {
        //   StickerHelper.afterStickerNewData();
        // },
      );
      await _appBloc.stickerService!.init();
    }
  }

  // static void _gettingStickerNewData(Map data) {
  //   if (data.isNotEmpty) {
  //     final value = _appBloc.subjectBottomNavigationBarWarning.value;
  //     value['stickers'] = true;
  //     _appBloc.subjectBottomNavigationBarWarning.sink.add(value);
  //   }
  // }

  static Future<void> defineDailyReportProfileAndDailyReportService() async {
    if (!MenuList.hasDailyReport()) return;

    if (_hesapBilgileri.gtMT) {
      _appBloc.dailyReportProfileService = SingleDataFCS<DailyReport>(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}DailyReportProfiles",
        queryRef: DailyReportService.dbDailyReportProfilesRef(),
      );
      await _appBloc.dailyReportProfileService!.init();
    }
    if (_hesapBilgileri.gtS) {
      _appBloc.dailyReportService = MultipleDataFCS(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}DailyReports",
        queryRefForRealtimeDB: DailyReportService.dbStudent5DailyReports(),
        maxCount: 5,
        lastUpdateKey: 'timeStamp',
        afterGetValue: () {
          DailyReportHelper.afterDailyReportNewData();
        },
      );
      await _appBloc.dailyReportService!.init();
    }
  }

  static Future<void> defineMessagesService() async {
    if (!MenuList.hasMessages()) return;

    _appBloc.messaggingPreviewService = MultipleDataFCS<MesaggingPreview>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}MessagesPreview",
      queryRefForRealtimeDB: MessageService.dbMessagesPreviewRef(),
      jsonParse: (key, value) => MesaggingPreview.fromJson(value, key),
      lastUpdateKey: 'timeStamp',
      removeFunction: (p0) => p0.lastMessage.safeLength < 1,
      afterGetValue: () {
        MessagePreviewHelper.afterMessagePreviewNewData();
      },
    );
    await _appBloc.messaggingPreviewService!.init();
  }

  static Future<void> defineSchoolInfoForManagerService() async {
    if (_hesapBilgileri.gtM == false) return;

    _appBloc.schoolInfoForManagerService = SingleDataFCS<SchoolInfoForManager>(
      "${_hesapBilgileri.kurumID}SchoolInfoForManager",
      queryRef: SchoolDataService.dbSchoolInfoForManagerRef(),
      jsonParse: (snapshot) => SchoolInfoForManager.fromJson(snapshot),
    );
    await _appBloc.schoolInfoForManagerService!.init();
  }

  static Future<void> defineSchoolInfoService() async {
    _appBloc.schoolInfoService = SingleDataFCS<SchoolInfo>(
      "${_hesapBilgileri.kurumID}SchoolInfo",
      queryRef: SchoolDataService.dbSchoolInfoRef(),
      jsonParse: (snapshot) => SchoolInfo.fromJson(snapshot),
      getValueAfter: _parseSchoolInfoChange,
    );
    await _appBloc.schoolInfoService!.init();
  }

  static void _parseSchoolInfoChange(_) {
    if (
        // _appBloc.schoolInfoService!.data == null ||
        _appBloc.schoolInfoService!.data.isEmpty) return;

    final _schoolInfoServiceData = _appBloc.schoolInfoService!.singleData;
    if (_schoolInfoServiceData == null) return;

    MenuList.savePreferences(kurumId: _hesapBilgileri.kurumID, menuList: _schoolInfoServiceData.menuList ?? [], refreshMenuList: true);
    _hesapBilgileri.genelMudurlukId = _schoolInfoServiceData.genelMudurlukServerId;
    _hesapBilgileri.genelMudurlukGroupList = _schoolInfoServiceData.genelMudurlukGroupList;

    if (_schoolInfoServiceData.activeTerm != _hesapBilgileri.termKey) {
      if (_hesapBilgileri.gtM) {
        if (_appBloc.reviewTerm) return;
        _appBloc.appConfig.ekolRestartApp!(true);
        _hesapBilgileri.termKey = _schoolInfoServiceData.activeTerm!;

        //      Fav.preferences.setString("hessapBilgileri", hesapBilgileri.toString());
      } else {
        _appBloc.signOut();
        return;
      }
    }
    _hesapBilgileri.savePreferences();
  }

  static Future<void> definePermissionService() async {
    _appBloc.permissionService = SingleDataFCS(
      "${_hesapBilgileri.kurumID}Permissions",
      queryRef: SchoolDataService.dbPermissionRef(),
      getValueAfterOnlyDatabaseQuery: (data) {
        UserPermissionList.refresh();
      },
    );
    await _appBloc.permissionService!.init();
  }

  static Future<void> defineTransporterService() async {
    if (!MenuList.hasTransporter()) return;

    _appBloc.transporterService = MultipleDataFCS<Transporter>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}Transporters",
      queryRefForRealtimeDB: TransportService.dbTransportListRef(),
      jsonParse: (key, value) => Transporter.fromJson(value, key),
      sortFunction: (Transporter a, Transporter b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.profileName!.toLowerCase(), b.profileName!.toLowerCase()) : (a.profileName!.toLowerCase()).compareTo(b.profileName!.toLowerCase());
      },
      removeFunction: (a) => a.driverName == null,
      lastUpdateKey: 'lastUpdate',
      bundleConfig: bundleConfig,
    );
    await _appBloc.transporterService!.init();
  }

  static Future<void> defineStudentService() async {
    if (_hesapBilgileri.gtS) return;

    _appBloc.studentService = MultipleDataFCS<Student>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}Students",
      queryRefForRealtimeDB: StudentService.dbStudentListRef(),
      jsonParse: (key, value) => Student.fromJson(value, key),
      removeFunction: (a) => !a.isReliable,
      sortFunction: (Student a, Student b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.name.toLowerCase(), b.name.toLowerCase()) : (a.name.toLowerCase()).compareTo(b.name.toLowerCase());
      },
      lastUpdateKey: 'lastUpdate',
      bundleConfig: bundleConfig,
    );
    await _appBloc.studentService!.init();
  }

  static Future<void> defineLessonService() async {
    _appBloc.lessonService = MultipleDataFCS<Lesson>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}Lessons",
      queryRefForRealtimeDB: LessonService.dbLessonListRef(),
      jsonParse: (key, value) => Lesson.fromJson(value, key),
      removeFunction: (a) => a.name == null,
      sortFunction: (Lesson a, Lesson b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase()) : (a.name!.toLowerCase()).compareTo(b.name!.toLowerCase());
      },
      lastUpdateKey: 'lastUpdate',
      bundleConfig: bundleConfig,
    );
    await _appBloc.lessonService!.init();
  }

  static Future<void> defineClassService() async {
    _appBloc.classService = MultipleDataFCS<Class>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}Classes",
      queryRefForRealtimeDB: ClassService.dbClassListRef(),
      jsonParse: (key, value) => Class.fromJson(value, key),
      removeFunction: (a) => a.name == null,
      sortFunction: (Class a, Class b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase()) : (a.name!.toLowerCase()).compareTo(b.name!.toLowerCase());
      },
      lastUpdateKey: 'lastUpdate',
      bundleConfig: bundleConfig,
      afterGetValue: _hesapBilgileri.gtT ? _parseTecherClass : null,
    );
    await _appBloc.classService!.init();
  }

  static void _parseTecherClass() {
//    // bunu kaldirdim
//    Class sinif = classService.dataList.singleWhere((sinif)=>sinif.classTeacher==hesapBilgileri.uid,orElse: ()=>null);
//    hesapBilgileri.teacherClassList = sinif!= null ? [sinif.key] : [];
//    classService.refresh.add(true);//Bundan emin degilim
//    prefs.setString("hessapBilgileri", hesapBilgileri.toString());
  }

  static Future<void> defineTeacherService() async {
    _appBloc.teacherService = MultipleDataFCS<Teacher>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}Teachers",
      queryRefForRealtimeDB: TeacherService.dbTeacherListRef(),
      jsonParse: (key, value) => Teacher.fromJson(value, key),
      removeFunction: (a) => !a.isReliable,
      sortFunction: (Teacher a, Teacher b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.name.toLowerCase(), b.name.toLowerCase()) : (a.name.toLowerCase()).compareTo(b.name.toLowerCase());
      },
      lastUpdateKey: 'lastUpdate',
      bundleConfig: bundleConfig,
    );
    await _appBloc.teacherService!.init();
  }

  static Future<void> defineManagerService() async {
    _appBloc.managerService = MultipleDataFCS<Manager>(
      "${_hesapBilgileri.kurumID}Managers",
      queryRefForRealtimeDB: ManagerService.dbManagerListRef(),
      jsonParse: (key, value) => Manager.fromJson(value, key),
      removeFunction: (a) => a.name == null,
      sortFunction: (Manager a, Manager b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase()) : (a.name!.toLowerCase()).compareTo(b.name!.toLowerCase());
      },
      lastUpdateKey: 'lastUpdate',
      bundleConfig: bundleConfig,
    );
    await _appBloc.managerService!.init();
  }

  static Future<void> defineSocialAndVideoService() async {
    if (!MenuList.hasSocialNetwork()) return;

    if (Get.find<RemoteControlValues>().useFirestoreForSocial) {
      final _targetList = AppVar.appBloc.hesapBilgileri.gtM
          ? null
          : AppVar.appBloc.hesapBilgileri.gtT
              ? <String>[
                  'alluser',
                  AppVar.appBloc.hesapBilgileri.uid,
                  ...AppVar.appBloc.classService!.dataList.fold<List<String>>([], (p, e) => e.classTeacher == AppVar.appBloc.hesapBilgileri.uid || e.classTeacher2 == AppVar.appBloc.hesapBilgileri.uid ? (p..add(e.key!)) : p),
                ]
              : <String>[
                  'alluser',
                  AppVar.appBloc.hesapBilgileri.uid,
                  ...AppVar.appBloc.hesapBilgileri.classKeyList,
                ];

      final _keySuffix = AppVar.appBloc.hesapBilgileri.gtM ? '' : (_targetList!..sort()).join('').removeNonEnglishCharacter;
      _appBloc.newSocialService = MultipleDataFCS<SocialItem>(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}FSocialNetwork$_keySuffix",
        firestorePath: ReferenceService.socialReference(),
        minLastUpdateTime: DateTime.now().subtract(Duration(days: AppVar.appBloc.hesapBilgileri.gtMT ? socialNetworkMaxDay : 90)).millisecondsSinceEpoch,
        jsonParse: (key, value) => SocialItem.fromJsonForFirestoreData(value, key),
        sortFunction: (SocialItem a, SocialItem b) => b.time - a.time,
        maxCount: _hesapBilgileri.gtM ? 2500 : 1500,
        removeFunction: (a) => a.senderName == null,
        targetList: _targetList,
        afterGetValue: () {
          SocialHelper.afterSocialNewData();
        },
      );
      await _appBloc.newSocialService!.init();
    } else {
      _appBloc.socialService = MultipleDataFCS<SocialItem>(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}SocialNetwork",
        queryRefForRealtimeDB: SocialService.dbSocialNetworkRef(),
        jsonParse: (key, value) => SocialItem.fromJson(value, key),
        sortFunction: (SocialItem a, SocialItem b) => b.time - a.time,
        maxCount: 500,
        removeFunction: (a) => a.senderName == null,
        lastUpdateKey: 'timeStamp',
        afterGetValue: () {
          SocialHelper.afterSocialNewData();
        },
      );
      await _appBloc.socialService!.init();

      _appBloc.videoService = MultipleDataFCS<SocialItem>(
        "${_hesapBilgileri.kurumID}${_hesapBilgileri.uid}${_hesapBilgileri.termKey}Video",
        queryRefForRealtimeDB: SocialService.dbVideoRef(),
        jsonParse: (key, value) => SocialItem.fromJson(value, key),
        sortFunction: (SocialItem a, SocialItem b) => b.time - a.time,
        lastUpdateKey: 'timeStamp',
        maxCount: 500,
        removeFunction: (a) => a.senderName == null,
        afterGetValue: () {
          SocialHelper.afterSocialNewData();
        },
      );
      await _appBloc.videoService!.init();
    }
  }

  static Future<void> defineAnnnouncementService() async {
    _appBloc.announcementService = MultipleDataFCS<Announcement>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}Announcements",
      queryRefForRealtimeDB: AnnouncementService.dbAnnouncementsRef(),
      jsonParse: (key, value) => Announcement.fromJson(value, key),
      sortFunction: (Announcement a, Announcement b) {
        if ((a.isPinned ?? false) == (b.isPinned ?? false)) return b.createTime - a.createTime;
        if ((a.isPinned ?? false)) return -1;
        return 1;
      },
      afterGetValue: () {
        AnnouncementHelper.afterAnnouncementsNewData();
      },
      maxCount: _hesapBilgileri.gtM ? 2500 : 500,
      lastUpdateKey: 'timeStamp',
      removeFunction: (i) => i.title.safeLength < 1,
    );
    await _appBloc.announcementService!.init();
  }

  static Future<void> defineInAppNotificationService() async {
    _appBloc.inAppNotificationService = MultipleDataFCS<InAppNotification>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}${_hesapBilgileri.uid}InAppNotifications",
      queryRefForRealtimeDB: InAppNotificationService.dbInAppNotificationsRef(),
      jsonParse: (key, value) {
        return InAppNotification.fromJson(value, key);
      },
      removeFunction: (p0) => p0.lastUpdate == null,
      sortFunction: (InAppNotification a, InAppNotification b) => b.lastUpdate - a.lastUpdate,
      lastUpdateKey: 'u',
      maxCount: _hesapBilgileri.gtTransporter ? 30 : 30,
    );
    await _appBloc.inAppNotificationService!.init();
  }

  static Future<void> defineQbankService() async {
    if (!MenuList.hasQBank()) return;

    _appBloc.bookService = MultipleDataFCS<Kitap>(
      "${_hesapBilgileri.kurumID}Books",
      queryRefForRealtimeDB: Reference(_appBloc.databaseSB, 'Books'),
      jsonParse: (key, value) => Kitap.fromJson(value, key),
      removeFunction: (p0) => p0.name1 == null,
      sortFunction: (Kitap a, Kitap b) {
        return 'lang'.translate == 'tr' ? turkish.comparator(a.name1!.toLowerCase(), b.name1!.toLowerCase()) : (a.name1!.toLowerCase()).compareTo(b.name1!.toLowerCase());
      },
      lastUpdateKey: 'lastUpdate',
    );
    await _appBloc.bookService!.init();
  }

  static Future<void> defineSimpleP2PDraftService() async {
    if (!MenuList.hasSimpleP2P()) return;

    _appBloc.simpleP2PDraftService = SingleDataFCS<SimpleP2pDraft>(
      "${_hesapBilgileri.kurumID}${_hesapBilgileri.termKey}SimpleP2pDraft",
      queryRef: P2PService.dgGetSimpleP2PSchoolDraft(),
      jsonParse: (snapshot) => SimpleP2pDraft.fromJson(snapshot),
    );
    await _appBloc.simpleP2PDraftService!.init();
  }
}
