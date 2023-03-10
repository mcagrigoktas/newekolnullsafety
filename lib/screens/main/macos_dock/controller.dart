part of 'macos_dock.dart';

//? Istersen bu ve maincontrolleri birlestirebilirsin
class MacOSDockController extends GetxController with GetSingleTickerProviderStateMixin, NotificationWidgetMixin, AgendaWidgetMixin {
  TabController? pageController;
  var selectedIndex = 0.obs;
  List<MacOSDockPageItem> itemList;
  List<MacOSDockPageItem> bigScreenItems = [];
  List<MacOSDockPageItem> miniScreenItems = [];
  MacOSDockTheme? theme;

//? Burasi ana menude gosterilecek ekstra widgetlari tutar
//? Dogum gunu icin {'birthday':{'name':'Ahmet'}} gelir;
  RxMap<String, Map<dynamic, dynamic>> extraMenuWidgets = <String, Map>{}.obs;

  bool isSmallLayoutEnable = true;

  final int initialIndex;
  MacOSDockController({
    this.initialIndex = 0,
    required this.itemList,
  });

  GlobalKey macOSDockKey = GlobalKey();

  @override
  void onInit() {
    selectedIndex.value = initialIndex;
    makeSturdyItems();
    definePageController();
    super.onInit();
  }

  void definePageController() {
    if (bigScreenItems.length > 1) pageController = TabController(initialIndex: initialIndex, length: bigScreenItems.where((element) => element.dockItemButtonType == DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget).length, vsync: this);
  }

  void makeSturdyItems() {
    bigScreenItems.clear();
    miniScreenItems.clear();
    itemList.sort((a, b) => a.dockItemButtonType == b.dockItemButtonType
        ? 0
        : a.dockItemButtonType == DockItemButtonType.buttonAndOpenNewTarget
            ? 1
            : -1);

    itemList.forEach((element) {
      if (element.dockItemVisibleScreen == DockItemVisibleScreen.big || element.dockItemVisibleScreen == DockItemVisibleScreen.both) {
        bigScreenItems.add(element);
      }
      if (element.dockItemVisibleScreen == DockItemVisibleScreen.mini || element.dockItemVisibleScreen == DockItemVisibleScreen.both) {
        miniScreenItems.add(element);
      }
    });
  }

  void bigScreenOnChanged(MacOSDockPageItem item) {
    if (item.dockItemButtonType == DockItemButtonType.buttonAndOpenNewTarget) {
      Fav.to(item.childBuilder(DockButtonLocation.dock));
    } else if (item.dockItemButtonType == DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget) {
      final index = bigScreenItems.where((element) => element.dockItemButtonType == DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget).toList().indexOf(item);
      selectedIndex.value = bigScreenItems.toList().indexOf(item);

      pageController!.animateTo(index, duration: 200.milliseconds, curve: Curves.ease);
    }
  }

  late Function(DockItemTag) smallScreenGoToPageFromTag;
  final Map<PageName, Object?> _goToPageArguments = {};
  Object? getPageArgs(PageName pageName) => _goToPageArguments[pageName];

  void setPageArgs(PageName pageName, Object arg) {
    _goToPageArguments[pageName] = arg;
    Future.delayed(2.seconds).then((value) {
      _goToPageArguments[pageName] = null;
    });
  }

  void goToThisPageTag(DockItemTag tag) {
    if (tag == DockItemTag.announcement) {
      if (isSmallLayoutEnable) {
        smallScreenGoToPageFromTag(DockItemTag.announcement);
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.social) {
      if (isSmallLayoutEnable) {
        smallScreenGoToPageFromTag(DockItemTag.social);
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.messages) {
      if (isSmallLayoutEnable) {
        smallScreenGoToPageFromTag(DockItemTag.messages);
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.portfolio) {
      if (isSmallLayoutEnable) {
        Fav.to(PortfolioMain(forMiniScreen: true));
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.dailyreport) {
      if (isSmallLayoutEnable) {
        Fav.to(DailyReportPage());
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.liveBroadCast) {
      if (isSmallLayoutEnable) {
        Fav.to(LiveBroadcastMain(forMiniScreen: true));
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.videoLesson) {
      if (isSmallLayoutEnable) {
        Fav.to(VideoChatMain(forMiniScreen: true));
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    } else if (tag == DockItemTag.sticker) {
      if (isSmallLayoutEnable) {
        Fav.to(StickersPage());
      } else {
        final _macOSDockPageItem = bigScreenItems.firstWhereOrNull((element) => element.dockItem.tag == tag);
        if (_macOSDockPageItem != null) bigScreenOnChanged(_macOSDockPageItem);
      }
    }
  }

  void miniScreenOnTap(MacOSDockPageItem item) {
    Fav.to(item.childBuilder(DockButtonLocation.free));
  }

  void changeItemList(List<MacOSDockPageItem> items) {
    itemList = items;
    makeSturdyItems();
    definePageController();
    macOSDockKey = GlobalKey();
    update();
    hoveredIndex.value = -2;
  }

  void addItem(MacOSDockPageItem item) {
    if (item.dockItemButtonType == DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget || itemList.any((element) => element.dockItem.tag == item.dockItem.tag)) return;
    itemList.add(item);
    makeSturdyItems();
    update();
    Get.find<MainController>().update();
  }

  var hoveredIndex = (-1).obs;
}

mixin NotificationWidgetMixin {
  var notificationBadge = 0.obs;

//! Badge ve bildirim widgeti icin islemler
  ///Uygulamaya gelen butun bildirimler burada toplaniyor
  final RxMap<NotificationGroup, List<InAppNotification>> _allNotificationListData = <NotificationGroup, List<InAppNotification>>{}.obs;

  void replaceThisTagNotificationList(NotificationGroup tag, List<InAppNotification> value) {
    _allNotificationListData[tag] = value;
  }

  List<InAppNotification>? announcementNotificationList() {
    if (_allNotificationListData[NotificationGroup.announcement] == null || _allNotificationListData[NotificationGroup.announcement]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.announcement];
  }

  List<InAppNotification>? unPublishedAnnouncementNotificationList() {
    if (_allNotificationListData[NotificationGroup.announcementUnPublish] == null || _allNotificationListData[NotificationGroup.announcementUnPublish]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.announcementUnPublish];
  }

  List<InAppNotification>? socialNotificationList() {
    if (_allNotificationListData[NotificationGroup.social] == null || _allNotificationListData[NotificationGroup.social]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.social];
  }

  List<InAppNotification>? unPublishedSocialNotificationList() {
    if (_allNotificationListData[NotificationGroup.socialUnPublish] == null || _allNotificationListData[NotificationGroup.socialUnPublish]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.socialUnPublish];
  }

  InAppNotification? messageNotificationList() {
    if (_allNotificationListData[NotificationGroup.message] == null || _allNotificationListData[NotificationGroup.message]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.message]!.first;
  }

  InAppNotification? appLastUsableTimeNotificationList() {
    if (_allNotificationListData[NotificationGroup.appLastUsableTime] == null || _allNotificationListData[NotificationGroup.appLastUsableTime]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.appLastUsableTime]!.first;
  }

  InAppNotification? appDemoTimeTimeNotificationList() {
    if (_allNotificationListData[NotificationGroup.appDemoTime] == null || _allNotificationListData[NotificationGroup.appDemoTime]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.appDemoTime]!.first;
  }

  InAppNotification? studentDailyReprotNotification() {
    if (_allNotificationListData[NotificationGroup.dailyreport] == null || _allNotificationListData[NotificationGroup.dailyreport]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.dailyreport]!.first;
  }

  List<InAppNotification>? databaseNotificationList() {
    if (_allNotificationListData[NotificationGroup.database] == null || _allNotificationListData[NotificationGroup.database]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.database];
  }

  InAppNotification? portfolioExamReportNotificationList() {
    if (_allNotificationListData[NotificationGroup.portfolioExamReport] == null || _allNotificationListData[NotificationGroup.portfolioExamReport]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.portfolioExamReport]!.first;
  }

  InAppNotification? portfolioP2PNotificationList() {
    if (_allNotificationListData[NotificationGroup.portfolioP2P] == null || _allNotificationListData[NotificationGroup.portfolioP2P]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.portfolioP2P]!.first;
  }

  InAppNotification? liveBroadCastNotificationList() {
    if (_allNotificationListData[NotificationGroup.liveBroadCast] == null || _allNotificationListData[NotificationGroup.liveBroadCast]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.liveBroadCast]!.first;
  }

  InAppNotification? rollCallNotificationList() {
    if (_allNotificationListData[RollCallHelper.rollCallNotificationGroup] == null || _allNotificationListData[RollCallHelper.rollCallNotificationGroup]!.isEmpty) return null;
    return _allNotificationListData[RollCallHelper.rollCallNotificationGroup]!.first;
  }

  List<InAppNotification>? homeWorkNotificationList() {
    if (_allNotificationListData[NotificationGroup.homeWork] == null || _allNotificationListData[NotificationGroup.homeWork]!.isEmpty) return null;
    return _allNotificationListData[NotificationGroup.homeWork];
  }

//! Badge ve bildirim widgeti icin islemler bitis

}
mixin AgendaWidgetMixin {
  var agendaBadge = 0.obs;

  final RxMap<AgendaGroup, List<Appointment>?> _allAgendaItemsData = <AgendaGroup, List<Appointment>>{}.obs;

  void replaceThisTagAgendaItems(AgendaGroup tag, List<Appointment>? value) {
    _allAgendaItemsData[tag] = value;
  }

//? TimeTable simdilik askida timetablehelpera detay icin bakabilirsin
  // List<Appointment> timeTableAgendaList() {
  //   if (_allAgendaItemsData[AgendaGroup.timetable] == null || _allAgendaItemsData[AgendaGroup.timetable].isEmpty) return null;
  //   return _allAgendaItemsData[AgendaGroup.timetable];
  // }

  List<Appointment>? p2pAgendaList() => _allAgendaItemsData[AgendaGroup.portfolioP2P];

  List<Appointment>? homeWorkAgendaList() => _allAgendaItemsData[AgendaGroup.homework];

  List<Appointment>? lessonExamAgendaList() => _allAgendaItemsData[AgendaGroup.lessonExam];

  List<Appointment>? liveBroadCastAgendaList() => _allAgendaItemsData[AgendaGroup.liveBroadCast];

  List<Appointment>? videoChatAgendaList() => _allAgendaItemsData[AgendaGroup.videoLesson];

  List<Appointment>? examAgendaList() => _allAgendaItemsData[AgendaGroup.exam];

  List<Appointment>? birthDayAgendaList() => _allAgendaItemsData[AgendaGroup.birthDay];
}
