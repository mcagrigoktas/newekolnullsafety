import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:mcg_database/fetcherboxes/multiple_data_fetcher.dart';
import 'package:mcg_database/firestore/firestore.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:ntp/ntp.dart';

import '../flavors/appconfig.dart';
import '../flavors/mainhelper.dart';
import '../flavors/themelist/helper.dart';
import '../helpers/firebase_helper.dart';
import '../models/accountdata.dart';
import '../models/allmodel.dart';
import '../models/enums.dart';
import '../models/notification.dart';
import '../qbank/models/models.dart';
import '../screens/generallyscreens/birthdaypage/layout.dart';
import '../screens/main/macos_dock/macos_dock.dart';
import '../screens/main/widgets/user_profile_widget/user_image_helper.dart';
import '../screens/managerscreens/programsettings/programlistmodels.dart';
import '../screens/p2p/simple/edit_p2p_draft/model.dart';
import '../screens/portfolio/model.dart';
import '../screens/timetable/modelshw.dart';
import '../services/dataservice.dart';
import '../services/pushnotificationservice.dart';
import 'appbloc.auth_helper.dart';
import 'appbloc.define_helper.dart';
import 'appbloc.remote_config_helper.dart';
import 'databaseconfig.dart';
import 'minifetchers.dart';

class AppBloc {
  FirestoreDatabase get firestore => Get.findOrPut(createFunction: () => FirestoreDatabase());

  final Database database1 = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdb1, defaultAppInstance: true);
  final Database database2 = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdb2);
  final Database database3 = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdb3);
  final Database databaseLogs = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbLogs);
  final Database databaseVersions = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbVersions);
  final Database databaseAccounting = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbAccounting);
  final Database databaseProgram = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbLessonProgram);
  final Database databaseSB = Database(databaseUrl: DatabaseStarter.databaseConfig.rtdbSB);

  final FirebaseAuth auth = FirebaseAuth.instance;

  final HesapBilgileri hesapBilgileri = HesapBilgileri();
  AppConfig get appConfig => Get.find<AppConfig>();

  final Map? restartExtraData;

  //? Idareci baska donemimi inceliyor
  bool reviewTerm = false;

  AppBloc({this.restartExtraData});

  Future<bool> initAccount() async {
    hesapBilgileri.setHesapBilgileri();
    ThemeHelper.setEkolTheme(hesapBilgileri);
    if (!hesapBilgileri.isGood) return false;

    final _isSignInSuccess = await AppblocAuthHelper.signInWithToken();
    if (_isSignInSuccess != true) AppblocAuthHelper.sendSignInError();

    return true;
  }

  Future<void> init() async {
    if (!hesapBilgileri.isGood) return;

    if (restartExtraData != null) {
      if (restartExtraData!['reviewterm'] != null) {
        hesapBilgileri.termKey = restartExtraData!['reviewterm'];
        reviewTerm = true;
      }
    }

    if (hesapBilgileri.databaseVersion != appConfig.databaseVersion) {
      signOut();
    }

    await _defineData();
    _startDataServices();

    AppblocRemoteConfigHelper.startRemoteConfigProcesses().unawaited;
    _checkDemoTime().unawaited;
    AppblocAuthHelper.afterUserLoginProcess();

    calculateBirthDayWidget();
    BirthDayHelper.addAgendaBirthdayItems();

    //todo gercek saat webe gelince burayayaz
    if (!isWeb) NTP.now().then((value) => _realTimeDifference = value.difference(DateTime.now())).unawaited;

//? Acilista yeni mesaj vermek istersen yenileyebilirsin
    // if (DateTime.now().millisecondsSinceEpoch < DateTime(2023, 01, 7).millisecondsSinceEpoch) {
    //   () async {
    //     if (hesapBilgileri.gtM && managerService.dataList.length > 1) {
    //       final _prefKey = hesapBilgileri.uid + 'axxk4';
    //       if (hesapBilgileri.uid.contains('anager') == false) {
    //         if (Fav.preferences.getBool(_prefKey, false) == false) {
    //           var result = await OverDialog.show(DialogPanel.defaultPanel(
    //             cancelText: 'remindlater'.translate,
    //             title: 'axxk31'.translate,
    //             subTitle: 'axxk32'.translate,
    //           ));
    //           if (result == true) Fav.preferences.setBool(_prefKey, true).unawaited;
    //         }
    //       } else {
    //         if (Fav.preferences.getBool(_prefKey, false) == false) {
    //           var result = await OverDialog.show(DialogPanel.defaultPanel(
    //             cancelText: 'remindlater'.translate,
    //             title: 'axxk31'.translate,
    //             subTitle: 'axxk33'.translate,
    //           ));
    //           if (result == true) Fav.preferences.setBool(_prefKey, true).unawaited;
    //         }
    //       }
    //     }
    //   }.delay(3000).unawaited;
    // }
  }

  Duration? _realTimeDifference;
  int get realTime => DateTime.now().add(_realTimeDifference ?? const Duration(milliseconds: 0)).millisecondsSinceEpoch;

  /// Saat kesin dogrulukla  lazimsa
  Future<int> get exactRealTime async => _realTimeDifference != null ? realTime : (await NTP.now()).millisecondsSinceEpoch;

  //////////////////////DATA SERVICE///////////////////

  // Okula ait ortak verilerin versiyonları ve bireysel data versiyonlarını çekmeye abone olur.
  bool _startedData = false;

  void _startDataServices() {
    if (hesapBilgileri.isGood == false || _startedData) return;
    _startedData = true;
    _subscribeSchoolVersions();
    _subscribePersonalVersions();
  }

  //// Okul bilgilerindeki değişimlere abone olur.
  StreamSubscription? _schoolVersionSubscription;
  Box? _schoolVersionsBox;
  Future<void> _subscribeSchoolVersions() async {
    _schoolVersionsBox ??= await Get.openSafeBox(hesapBilgileri.kurumID! + AppConst.versionListBoxVersion.toString());
    if (_schoolVersionSubscription == null) {
      await _schoolVersiondatalariCek(_schoolVersionsBox!.toMap());

      _schoolVersionSubscription = SchoolDataService.dbSchoolVersions().onValue().listen((event) async {
        final _result = event?.value ?? {};
        //todo burada ve asagida cift trigger var zamanla bak.
        await _schoolVersiondatalariCek(_result);
        if (_schoolVersionsBox != null && _schoolVersionsBox!.isOpen) _schoolVersionsBox!.putAll(_result).unawaited;
      });
    }
  }

  //// Bireysel bilgilerdeki değişimlere abone olur.
  StreamSubscription? _personalVersionSubscription;
  Box? _personalVersionsBox;
  Future<void> _subscribePersonalVersions() async {
    _personalVersionsBox ??= await Get.openSafeBox(hesapBilgileri.kurumID! + hesapBilgileri.uid! + hesapBilgileri.termKey! + AppConst.versionListBoxVersion.toString());
    if (_personalVersionSubscription == null) {
      await _personalVersiondatalariCek(_personalVersionsBox!.toMap());
      _personalVersionSubscription = UserInfoService.dbPersonalVersions().onValue().listen((event) async {
        final _result = event?.value ?? {};
        await _personalVersiondatalariCek(_result);
        if (_personalVersionsBox != null && _personalVersionsBox!.isOpen) _personalVersionsBox!.putAll(_result).unawaited;
      });
    }
  }

  // Okul versiyonları değişiminde aşağıdaki dataların verisyonları değişmişse değişen dataları çeker.(Modul eklenebilir)
  Future<void> _schoolVersiondatalariCek(Map versionLists) async {
    if (!versionLists.containsKey(hesapBilgileri.termKey)) versionLists[hesapBilgileri.termKey] = {};

    await Future.wait([
      if (announcementService != null) announcementService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.announcements] ?? -1),
      if (schoolInfoService != null) schoolInfoService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.schoolInfo] ?? -1),
      if (schoolInfoForManagerService != null) schoolInfoForManagerService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.schoolInfoForManager] ?? -1),
      if (teacherService != null) teacherService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.teachers] ?? -1),
      if (classService != null) classService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.classes] ?? -1),
      if (lessonService != null) lessonService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.lessons] ?? -1),
      if (studentService != null) studentService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.students] ?? -1),
      if (transporterService != null) transporterService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.transporters] ?? -1),
      if (managerService != null) managerService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.managers] ?? -1),
      if (bookService != null) bookService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.books] ?? -1),
      if (permissionService != null) permissionService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.permissions] ?? -1),
      if (dailyReportProfileService != null) dailyReportProfileService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.dailyReportProfiles] ?? -1),
      if (stickersProfileService != null) stickersProfileService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.stickerProfiles] ?? -1),
      if (medicineProfileService != null) medicineProfileService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.medicineProfiles] ?? -1),
      if (schoolTimesService != null) schoolTimesService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.times] ?? -1),
      if (teacherHoursService != null) teacherHoursService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.teacherClassHours] ?? -1),
      if (classHoursService != null) classHoursService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.teacherClassHours] ?? -1),
      if (tableProgramService != null) tableProgramService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.timeTable] ?? -1),
      if (liveBroadcastService != null) liveBroadcastService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.liveBroadCast] ?? -1),
      if (notificationTokenService != null) notificationTokenService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][hesapBilgileri.gtS ? VersionListEnum.tokenListForStudent : VersionListEnum.tokenListForManagerTeacher] ?? -1),
      if (educationService != null) educationService!.fetchData(newDatabaseVersion: versionLists[VersionListEnum.educationService] ?? -1, firestoreDelayTime: 2500),
      if (simpleP2PDraftService != null) simpleP2PDraftService!.fetchDataAndStream(newDatabaseVersion: versionLists[hesapBilgileri.termKey][VersionListEnum.simpleP2PSchoolDraft] ?? -1),
    ]);
  }

  // Bireysel versiyon değişiminde aşağıdaki dataların verisyonları değişmişse değişen dataları çeker.(Modul eklenebilir).
  Future<void> _personalVersiondatalariCek(Map versionLists) async {
    //? Eskiden yeni mesaj gelmesi versiyon listesinde [newMessage]= true yapilarak kontrol ediliyordu boylece mesaj listesine bakilmiyordu. Bu Kayitlar setDataServicede hala yapiliyor
    //? Widget seklindeki menuye gecilince bu sistem mesaj listesine bakilacak sekile cevrildi
    //? Eger mesaj listesine bakma islemi yerine bu sistemi kullanmak istersen burayi duzenleyebilirsin. Tabi anne baba ayri olayini ve veli ogrenci olayini detayli denedikten sonra
    // if (hesapBilgileri.gtS && hesapBilgileri.isParent) {
    //   if (versionLists['newMessageParent'] == true && hesapBilgileri.parentNo != 2) {
    //     final value = subjectBottomNavigationBarWarning.value;
    //     value['messages'] = true;
    //     subjectBottomNavigationBarWarning.sink.add(value);
    //   } else if (versionLists['newMessageParent2'] == true && hesapBilgileri.parentNo == 2) {
    //     final value = subjectBottomNavigationBarWarning.value;
    //     value['messages'] = true;
    //     subjectBottomNavigationBarWarning.sink.add(value);
    //   }
    // } else {
    //   if (versionLists['newMessage'] == true) {
    //     final value = subjectBottomNavigationBarWarning.value;
    //     value['messages'] = true;
    //     subjectBottomNavigationBarWarning.sink.add(value);
    //   }
    // }

    await Future.wait([
      if (socialService != null) socialService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.socialNetwork] ?? -1),
      if (videoService != null) videoService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.video] ?? -1),
      if (newSocialService != null) newSocialService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.newSocialService] ?? -1),
      if (messaggingPreviewService != null) messaggingPreviewService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.messagesPreview] ?? -1),
      if (dailyReportService != null) dailyReportService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.dailyReport] ?? -1),
      if (stickerService != null) stickerService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.studentStickersData] ?? -1),
      if (userInfoChangeService != null) userInfoChangeService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.userInfoChangeService] ?? -1),
      if (videoChatTeacherService != null) videoChatTeacherService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.videoLessonService] ?? -1),
      if (videoChatStudentService != null) videoChatStudentService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.videoLessonService] ?? -1),
      if (studentRollCallService != null) studentRollCallService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.rollCall] ?? -1),
      if (homeWorkService != null) homeWorkService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.homeWork] ?? -1),
      if (portfolioService != null) portfolioService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.portfolio] ?? -1),
      if (inAppNotificationService != null) inAppNotificationService!.fetchDataAndStream(newDatabaseVersion: versionLists[VersionListEnum.inAppNotification] ?? -1),
    ]);
  }

// Data servislerini tanımlar
  List<FetcherBox?> get allService => [
        announcementService,
        socialService,
        videoService,
        newSocialService,
        managerService,
        bookService,
        teacherService,
        classService,
        lessonService,
        studentService,
        transporterService,
        permissionService,
        schoolInfoService,
        schoolInfoForManagerService,
        messaggingPreviewService,
        dailyReportProfileService,
        dailyReportService,
        stickersProfileService,
        stickerService,
        medicineProfileService,
        userInfoChangeService,
        videoChatTeacherService,
        videoChatStudentService,
        schoolTimesService,
        teacherHoursService,
        classHoursService,
        tableProgramService,
        studentRollCallService,
        homeWorkService,
        liveBroadcastService,
        portfolioService,
        notificationTokenService,
        educationService,
        inAppNotificationService,
        simpleP2PDraftService,
      ];
  MultipleDataFCS<Announcement>? announcementService;
  MultipleDataFCS<SocialItem>? socialService;
  MultipleDataFCS<SocialItem>? videoService;
  MultipleDataFCS<SocialItem>? newSocialService;
  MultipleDataFCS<Manager>? managerService;
  MultipleDataFCS<Kitap>? bookService;
  MultipleDataFCS<Teacher>? teacherService;
  MultipleDataFCS<Class>? classService;
  MultipleDataFCS<Lesson>? lessonService;
  MultipleDataFCS<Student>? studentService;
  MultipleDataFCS<Transporter>? transporterService;
  SingleDataFCS? permissionService;
  SingleDataFCS<SchoolInfo>? schoolInfoService;
  SingleDataFCS<SchoolInfoForManager>? schoolInfoForManagerService;
  MultipleDataFCS<MesaggingPreview>? messaggingPreviewService;
  SingleDataFCS<DailyReport>? dailyReportProfileService;
  MultipleDataFCS? dailyReportService;
  MultipleDataFCS<Sticker>? stickersProfileService;
  SingleDataFCS? stickerService;
  MultipleDataFCS<MedicineProfile>? medicineProfileService;
  SingleDataFCS? userInfoChangeService;
  MultipleDataFCS<VideoLessonProgramModel>? videoChatTeacherService;
  MultipleDataFCS<VideoLessonStudentModel>? videoChatStudentService;
  MultipleDataFCS<LiveBroadcastModel>? liveBroadcastService;
  MultipleDataFCS<TimesModel>? schoolTimesService;
  SingleDataFCS? teacherHoursService;
  SingleDataFCS? classHoursService;
  MultipleDataFCS? tableProgramService;
  MultipleDataFCS? studentRollCallService;
  MultipleDataFCS<HomeWork>? homeWorkService;
  MultipleDataFCS<Portfolio>? portfolioService;
  MultipleDataFCS<TokenModel>? notificationTokenService;
  MultipleDataFCS<InAppNotification>? inAppNotificationService;
  SingleDataFCS<SimpleP2pDraft>? simpleP2PDraftService;

  PkgFireBox? educationService;

  Future<void> _defineData() async {
    if (hesapBilgileri.gtS || hesapBilgileri.gtM || hesapBilgileri.gtT) {
      await Future.wait([
        AppblocDefineServiceHelper.defineAnnnouncementService(),
        AppblocDefineServiceHelper.defineManagerService(),
        AppblocDefineServiceHelper.defineTeacherService(),
        AppblocDefineServiceHelper.defineClassService(),
        AppblocDefineServiceHelper.defineLessonService(),
        AppblocDefineServiceHelper.defineStudentService(),
        AppblocDefineServiceHelper.defineTransporterService(),
        AppblocDefineServiceHelper.definePermissionService(),
        AppblocDefineServiceHelper.defineSchoolInfoService(),
        AppblocDefineServiceHelper.defineSchoolInfoForManagerService(),
        AppblocDefineServiceHelper.defineMessagesService(),
        AppblocDefineServiceHelper.defineDailyReportProfileAndDailyReportService(),
        AppblocDefineServiceHelper.defineDailyStickerProfileAndStickerService(),
        AppblocDefineServiceHelper.defineMedicineProfileService(),
        AppblocDefineServiceHelper.defineUserInfoChangeService(),
        AppblocDefineServiceHelper.defineVideoChatStudentAndTeacherService(),
        AppblocDefineServiceHelper.defineLiveBroadcastService(),
        AppblocDefineServiceHelper.defineSchooltimeService(),
        AppblocDefineServiceHelper.defineTecherAndClassHourService(),
        AppblocDefineServiceHelper.defineTimeTableService(),
        AppblocDefineServiceHelper.defineStudentRollCallService(),
        AppblocDefineServiceHelper.defineHomeworkService(),
        AppblocDefineServiceHelper.definePortfolioService(),
        AppblocDefineServiceHelper.defineNotificationTokenService(),
        AppblocDefineServiceHelper.defineQbankService(),
        AppblocDefineServiceHelper.defineInAppNotificationService(),
        AppblocDefineServiceHelper.defineSimpleP2PDraftService(),
        AppblocDefineServiceHelper.defineEducationService(),
      ]);
      //? Social ag class listesi olustuktan sonra olusmasi lazim Ogretmende hata verir degilse
      await Future.wait([
        AppblocDefineServiceHelper.defineSocialAndVideoService(),
      ]);
    } else if (hesapBilgileri.gtTransporter) {
      await Future.wait([
        AppblocDefineServiceHelper.defineStudentService(),
        AppblocDefineServiceHelper.defineSchoolInfoService(),
        AppblocDefineServiceHelper.defineUserInfoChangeService(),
        AppblocDefineServiceHelper.defineNotificationTokenService(),
        AppblocDefineServiceHelper.defineInAppNotificationService(),
      ]);
    }
  }

  void calculateBirthDayWidget() {
    final _now = DateTime.now();
    final _macosDockController = Get.find<MacOSDockController>();
    if (hesapBilgileri.gtT) {
      final _teacher = hesapBilgileri.castTeacherData();
      final _birthdayTime = _teacher?.birthday?.dateTime;
      if (_birthdayTime == null) return;
      if (_birthdayTime.day == _now.day && _birthdayTime.month == _now.month) {
        _macosDockController.extraMenuWidgets['birthday'] = {'name': _teacher!.name};
      }
    } else if (hesapBilgileri.gtS) {
      final _student = hesapBilgileri.castStudentData();
      final _birthdayTime = _student?.birthday?.dateTime;
      if (_birthdayTime == null) return;
      if (_birthdayTime.day == _now.day && _birthdayTime.month == _now.month) {
        _macosDockController.extraMenuWidgets['birthday'] = {'name': _student!.name};
      }
    }
  }

  Future<void> _checkDemoTime() async {
    if (hesapBilgileri.demoTime == null) return;
    await 300.wait;
    //todo web icin gercek zaman gelince duzenle
    if (hesapBilgileri.demoTime! + const Duration(days: 7).inMilliseconds < (isWeb ? DateTime.now() : await NTP.now()).millisecondsSinceEpoch) return signOut();
  }

  void signOut() {
    final String _kurumID = hesapBilgileri.kurumID!;
    final String _termKey = hesapBilgileri.termKey!;
    final String _userKey = hesapBilgileri.uid!;
    Fav.securePreferences.deleteItemMap(UserImageHelper.ekolAllUserPrefKey, hesapBilgileri.kurumID! + hesapBilgileri.uid!);
    hesapBilgileri.reset();
    hesapBilgileri.removePreferences();

    FirebaseHelper.getToken().then((token) {
      if (token != null) {
        SignInOutService.dbDeleteToken2(_kurumID, _termKey, _userKey, token);
      }

      if (!isWeb) {
        FirebaseMessaging.instance.unsubscribeFromTopic(_kurumID + 'pushnotification');
        if (hesapBilgileri.gtMT) {
          FirebaseMessaging.instance.unsubscribeFromTopic(_kurumID + 'onlyteachers');
        }
      }
    });

    appConfig.ekolRestartApp!(true);
  }

  Future dispose() async {
    await MiniFetchers.unregisterAllFetcher();
    _personalVersionsBox = null;
    _schoolVersionsBox = null;

    await _personalVersionSubscription?.cancel();
    await _schoolVersionSubscription?.cancel();

    _personalVersionSubscription = null;
    _schoolVersionSubscription = null;
  }

  // Stream<bool> get stateStream => _stateSubject.stream;
  // final BehaviorSubject<bool> _stateSubject = BehaviorSubject<bool>.seeded(false);

}
