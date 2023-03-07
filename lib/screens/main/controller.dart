import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../appbloc/appvar.dart';
import '../../flavors/appentry/ekolsplashscreen.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../models/chatmodel.dart';
import '../../models/socialitem.dart';
import '../../qbank/screens/eager_deferred_qbank_ekol_entry.dart';
import '../announcements/announcement.dart';
import '../announcements/announcementspage.dart';
import '../announcements/helper.dart';
import '../dailyreport/dailyreport.dart';
import '../dailyreport/helper.dart';
import '../eating/eatfile.dart';
import '../eating/eating.dart';
import '../eating/eaturl.dart';
import '../eders/livebroadcast/livebroadcastmain.dart';
import '../eders/videochat/videochatmain.dart';
import '../educations/entrance/layout.dart';
import '../healthcare/addmedicine.dart';
import '../mesagging/chatpreview.dart';
import '../mesagging/helper.dart';
import '../notification_and_agenda/layout.dart';
import '../notification_and_agenda/notification/notification_helper.dart';
import '../portfolio/eager_portfolio_main.dart';
import '../school_tools/layout.dart';
import '../social/helper.dart';
import '../social/share_social/sharesocial.dart';
import '../social/socialpage.dart';
import '../stickers/stickerspage.dart';
import '../timetable/timetablehome.dart';
import 'macos_dock/macos_dock.dart';
import 'menu_list_helper.dart';
import 'tree_view/custom_node.dart';
import 'tree_view/tree_view_helper.dart';

class MainController extends GetxController {
  int? navigationIndex;

  MacOSDockController get macOSDockController => Get.find<MacOSDockController>();
  List<MacOSDockPageItem> widgetList = [];

  StreamSubscription? _schoolInfoServiceSubscription;
  bool isMenuReady = false;

  @override
  void onInit() {
    super.onInit();

    _schoolInfoServiceSubscription = AppVar.appBloc.schoolInfoService!.stream.listen((event) {
      if (!isMenuReady) {
        isMenuReady = true;
        _schoolInfoServiceSubscription!.cancel();
        _setupSplashScreen();
        _setupNotificationSubscription();

        _setupMenuList();
        _setupTreeViewNodesAndFavoritesWidget();
        macOSDockController.changeItemList(widgetList);
        update();
      }
    });

    if (AppVar.appBloc.hesapBilgileri.gtMT && !kIsWeb) _setUpIntent();
  }

  @override
  void onClose() {
    _medicineSubscription?.cancel();
    _intentDataStreamSubscriptionUrl?.cancel();
    _schoolInfoServiceSubscription?.cancel();
    _announcementSubscription?.cancel();
    _timeTableSubscription?.cancel();
    _socialSubscription?.cancel();
    _messageSubscription?.cancel();
    _dailyReportSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.onClose();
  }

//?Treeview Setup Baslangic

  SidebarNode? treeViewNodes;
  void _setupTreeViewNodesAndFavoritesWidget() {
    treeViewNodes = SidebarNode(name: 'root');
    TreeViewHelper.setupTreeViewNodes(treeViewNodes);
  }

//? TreeView Setup Bitis

//? MenuList Ayarlama baslangic
  List<String> _menuList = [];
  void _setupMenuList() {
    final newMenuList = MenuList.fullMenuList()!;
    if ((newMenuList..sort()).join('') == (_menuList..sort()).join('')) return;
    _menuList = newMenuList;

    _setupNotificationAndAgendaWidget();
    _setupAnnouncementWidget();
    _setupSocialWidget();

    _setupMessageWidget();
    _setupDailyReport();

    _setupTimeTableWidget();
    _setupEducationWidget();
    _setupQBankWidget();
    _setupStickers();
    _setupPortfolio();
    // _setupVideoLesson();
    _setupLiveBroadcast();
    _setupVideoLesson();

    _setupFoodWidget();
    _setupToolsWidget();
    _setupMedicineButtonWidget();
    //  _setupStudentWidget();
    // _NsetupSchoolInfoWidgets();

    // _setupSettingsWidget();
  }

  StreamSubscription? _notificationSubscription;
  Future<void> _setupNotificationSubscription() async {
    await 100.wait;
    _notificationSubscription ??= AppVar.appBloc.inAppNotificationService!.stream.listen((event) {
      //  if (event == null) return;
      NotificationWidgetHelper.checkNotification();
    });
  }

  Future<void> _setupNotificationAndAgendaWidget() async {
    widgetList.add(MacOSDockPageItem(
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      dockItemVisibleScreen: DockItemVisibleScreen.big,
      dockItemButtonType: DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget,
      childBuilder: (buttonLocation) {
        return NotificationAndAgendaBigScreenPage();
      },
      dockItem: DockItem(
        child: Image.asset(GlassIcons.notifcation.imgUrl!, height: 50),
        name: 'notifications'.translate,
        primaryColor: GlassIcons.notifcation.color,
        tag: DockItemTag.nullTag,
      ),
    ));
  }

  StreamSubscription? _announcementSubscription;
  List<Announcement> filteredAnnouncementList = [];
  Future<void> _setupAnnouncementWidget() async {
    widgetList.add(MacOSDockPageItem(
      dockItemVisibleScreen: DockItemVisibleScreen.big,
      childBuilder: (buttonLocation) => AnnouncementsPage(
        forMiniScreen: buttonLocation == DockButtonLocation.free,
      ),
      dockItem: DockItem(
        child: Image.asset(GlassIcons.announcementIcon.imgUrl!, height: 50),
        name: 'announcements'.translate,
        primaryColor: GlassIcons.announcementIcon.color,
        tag: AnnouncementHelper.announcementIconTag,
      ),
    ));
  }

  StreamSubscription? _timeTableSubscription;
  Future<void> _setupTimeTableWidget() async {
    //todo Idareci icin tum ogretmen ve siniflarin ders programini iceren sayfa yap
    if (MenuList.hasTimeTable() && (AppVar.appBloc.hesapBilgileri.gtT || AppVar.appBloc.hesapBilgileri.gtS)) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => TimeTableHome(
          forMiniScreen: buttonLocation == DockButtonLocation.free,
        ),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.timetable2.imgUrl!, height: 50),
          name: 'mylessons'.translate,
          primaryColor: GlassIcons.timetable2.color,
          tag: DockItemTag.nullTag,
        ),
      ));
    }
  }

  void _setupQBankWidget() {
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki10() == false) return;

    if (MenuList.hasQBank()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => EkolQBankPage(
          forMiniScreen: buttonLocation == DockButtonLocation.free,
        ),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.books2.imgUrl!, height: 50),
          name: 'mybooks'.translate,
          primaryColor: GlassIcons.books2.color,
          tag: DockItemTag.nullTag,
        ),
      ));
    }
  }

  StreamSubscription? _socialSubscription;
  List<SocialItem> filteredSocialList = [];
  Future<void> _setupSocialWidget() async {
    if (MenuList.hasSocialNetwork()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.big,
        childBuilder: (buttonLocation) => SocialPage(
          forMiniScreen: buttonLocation == DockButtonLocation.free,
        ),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.social.imgUrl!, height: 50),
          name: 'social'.translate,
          primaryColor: GlassIcons.social.color,
          tag: SocialHelper.socialIconTag,
        ),
      ));
    }
  }

  Future<void> _setupEducationWidget() async {
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki10() == false) return;

    if (AppVar.appBloc.educationService != null) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => EducationListEntrance(
          forMiniScreen: buttonLocation == DockButtonLocation.free,
        ),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.education.imgUrl!, height: 50),
          name: 'educationlist'.translate,
          primaryColor: GlassIcons.education.color,
          tag: DockItemTag.nullTag,
        ),
      ));
    }
  }

  StreamSubscription? _messageSubscription;
  List<MesaggingPreview> filteredMessageList = [];
  Future<void> _setupMessageWidget() async {
    if (MenuList.hasMessages()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.big,
        childBuilder: (buttonLocation) => ChatPreview(
          forMiniScreen: buttonLocation == DockButtonLocation.free,
        ),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.messagesIcon.imgUrl!, height: 50),
          name: 'messages'.translate,
          primaryColor: GlassIcons.messagesIcon.color,
          tag: MessagePreviewHelper.messageIconTag,
        ),
      ));
    }
  }

  StreamSubscription? _dailyReportSubscription;
  bool dailyReportDataReceived = false;
  Future<void> _setupDailyReport() async {
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki10() == false) return;

    if (MenuList.hasDailyReport()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => DailyReportPage(forMiniScreen: buttonLocation == DockButtonLocation.free),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.dailyReport.imgUrl!, height: 50),
          name: 'dailyreport'.translate,
          primaryColor: GlassIcons.dailyReport.color,
          tag: DailyReportHelper.dailyReportIconTag,
        ),
      ));
    }
  }

  void _setupStickers() {
    if (MenuList.hasStickers()) {
      if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki10() == false) return;

      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => StickersPage(forMiniScreen: buttonLocation == DockButtonLocation.free),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.stickers.imgUrl!, height: 50),
          name: 'stickersmenuname'.translate,
          primaryColor: GlassIcons.stickers.color,
          tag: DockItemTag.sticker,
        ),
      ));
    }
  }

  void _setupPortfolio() {
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki10() == false) return;

    if (MenuList.hasPortfolio() && AppVar.appBloc.hesapBilgileri.gtS) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => PortfolioMain(forMiniScreen: buttonLocation == DockButtonLocation.free),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.portfolio.imgUrl!, height: 50),
          name: 'studentportfolio'.translate,
          primaryColor: GlassIcons.portfolio.color,
          tag: DockItemTag.portfolio,
        ),
      ));
    }
  }

  // void _setupVideoLesson() {
  //   if (_menuList.contains('videolesson')) {
  //     widgetList.add(VideoLessonWidget());
  //   }
  // }

  void _setupLiveBroadcast() {
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki9() == false) return;

    if (MenuList.hasLivebroadcast()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => LiveBroadcastMain(forMiniScreen: buttonLocation == DockButtonLocation.free),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.liveBroadcastIcon.imgUrl!, height: 50),
          name: 'elesson'.translate,
          primaryColor: GlassIcons.liveBroadcastIcon.color,
          tag: DockItemTag.liveBroadCast,
        ),
      ));
    }
  }

  void _setupVideoLesson() {
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki9() == false) return;

    if (MenuList.hasVideoLesson()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        childBuilder: (buttonLocation) => VideoChatMain(forMiniScreen: buttonLocation == DockButtonLocation.free),
        dockItem: DockItem(
          child: Image.asset(GlassIcons.videoLesson.imgUrl!, height: 50),
          name: 'p2pappointmentlesson'.translate,
          primaryColor: GlassIcons.videoLesson.color,
          tag: DockItemTag.videoLesson,
        ),
      ));
    }
  }

  void _setupFoodWidget() {
    if (MenuList.hasFoodMenu()) {
      widgetList.add(MacOSDockPageItem(
        dockItemVisibleScreen: DockItemVisibleScreen.both,
        dockItemButtonType: DockItemButtonType.buttonAndOpenNewTarget,
        childBuilder: (buttonLocation) {
          if (AppVar.appBloc.schoolInfoService!.singleData!.eatMenuType == 1) {
            return EatUrl();
          } else if (AppVar.appBloc.schoolInfoService!.singleData!.eatMenuType == 2) {
            return EatFile();
          } else {
            return EatList();
          }
        },
        dockItem: DockItem(
          child: Image.asset(GlassIcons.mealIcon.imgUrl!, height: 50),
          name: 'eatlist'.translate,
          primaryColor: GlassIcons.mealIcon.color,
          tag: DockItemTag.nullTag,
        ),
      ));
    }
  }

  // void _setupStudentWidget() {
  //   if (AppVar.appBloc.hesapBilgileri.gtM) {
  //     //   widgetList.add(StudentCountWidget());
  //   }
  // }

  // void _NsetupSchoolInfoWidgets() {
  //   SchoolWidgetHelper.addSchoolWidgets(FilterHelper.getAllFilteredWidgets(), widgetList);
  // }

  // void _setupSettingsWidget() {
  //   if (AppVar.appBloc.hesapBilgileri.gtM) {
  //     widgetList.add(SettingsWidget());
  //   }
  // }

  // void _setupFernusWidget() {
  //   //! Fernus lazim olursa acabilirsin
  //   // if (AppVar.appBloc.hesapBilgileri.kurumID.startsWith('demo') && isWeb) {
  //   //   widgetList.add(FernusWidget());
  //   // }
  // }

  Future<void> _setupToolsWidget() async {
    widgetList.add(MacOSDockPageItem(
      dockItemVisibleScreen: DockItemVisibleScreen.both,
      dockItemButtonType: DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget,
      childBuilder: (buttonLocation) {
        return SchoolToolsPage(forMiniScreen: buttonLocation == DockButtonLocation.free);
      },
      dockItem: DockItem(
        child: Image.asset(GlassIcons.tag.imgUrl!, height: 50),
        name: 'tools'.translate,
        primaryColor: GlassIcons.tag.color,
        tag: DockItemTag.nullTag,
      ),
    ));
  }

  StreamSubscription? _medicineSubscription;
  bool _medicineButtonAdded = false;
  Future<void> _setupMedicineButtonWidget() async {
    if (AppVar.appBloc.hesapBilgileri.gtS) return;
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki11() == false) return;

    await 4000.wait;
    _medicineSubscription ??= AppVar.appBloc.medicineProfileService?.stream.listen((event) {
      // if (event == null) return null;

      final _now = DateTime.now().millisecondsSinceEpoch;

      final _medicineIsActive = AppVar.appBloc.medicineProfileService?.dataList.where((medicine) => medicine.aktif != false).any((med) {
        return _now < med.endDate! + const Duration(days: 1).inMilliseconds && _now > med.startDate! - const Duration(days: 1).inMilliseconds;
      });
      const medicinaBadgeTag = DockItemTag.medicinebutton;
      // const medicinaNotificationType = NotificationGroup.medicine;
      if (_medicineIsActive == true && !_medicineButtonAdded) {
        macOSDockController.addItem(MacOSDockPageItem(
          dockItemButtonType: DockItemButtonType.buttonAndOpenNewTarget,
          dockItemVisibleScreen: DockItemVisibleScreen.both,
          childBuilder: (buttonLocation) => AddedMedicineList(),
          dockItem: DockItem(
            child: Image.asset(GlassIcons.medicine.imgUrl!, height: 50),
            name: 'medicineprofilelist'.translate,
            primaryColor: GlassIcons.medicine.color,
            tag: medicinaBadgeTag,
          ),
        ));

        ////todocheck burasina istersen itemleri digerleri gibi koyup ister bildirim widgetinda goster istersen agendaya ekle
        ///todocheck tabi bunlardan once ogretmen hagni ogrencilerin saglik bilgierini gorup gormedigini kontrol et
        ///tododanger bunu kontrol et
        // macOSDockController.replaceThisTagBadgeData(medicinaNotificationType, [1]);
        _medicineSubscription!.cancel();
        _medicineButtonAdded = true;
      }
    });
  }

  //? MenuList Ayarlama bitis

//? Splash Screen Baslangic
  bool logoGosterilecek = true;
  Future<void> _setupSplashScreen() async {
    if (!logoGosterilecek) return;

    const int duration = 2666;

    final current = SplashScreen(duration: duration);

    await 10.wait;

    Get.dialog(current, useSafeArea: false, barrierColor: Colors.transparent, barrierDismissible: false).unawaited;
    await 1000.wait;
    logoGosterilecek = false;
    update();
    await (duration - 1000).wait;
    if (Get.isDialogOpen!) Get.back();
  }
//? Splash Screen Bitis

//? Intent Baslangic
  StreamSubscription? _intentDataStreamSubscriptionUrl;
  void _setUpIntent() {
    _intentDataStreamSubscriptionUrl = ReceiveSharingIntent.getTextStream().listen((value) {
      if (!value.contains('you')) return;

      Fav.to(ShareSocial(youtubeUrl: value));
    }, onError: (err) {});

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value == null || !value.contains('you')) return;
      Fav.to(ShareSocial(youtubeUrl: value));
    });
  }
//? Intent Bitis

}
