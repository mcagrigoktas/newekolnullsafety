import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/hover_icons/base.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../models/allmodel.dart';
import '../../widgets/announcement_social_list_sticky.dart';
import 'announcementitem.dart';
import 'helper.dart';
import 'shareannouncements.dart';

class AnnouncementsPage extends StatefulWidget {
  final bool forMiniScreen;
  AnnouncementsPage({this.forMiniScreen = false});
  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final appBloc = AppVar.appBloc;
  List<Announcement> _calculatedList = [];
  final List<Announcement> _otherItems = [];
  final List<Announcement> _unPublishedItems = [];
  final List<Announcement> _newItems = [];
  List<int>? _searchDate;
  StreamSubscription? _refresher;
  var _isSearchMenuOpen = false;
  String _searchText = '';
  String _searchClassKey = 'all';

  final _searchTextFieldController = TextEditingController();

  late DateTime pageLoginTime;

  @override
  void initState() {
    super.initState();
    pageLoginTime = DateTime.now();

    () {
      if (_calculatedList.isEmpty && mounted) {
        calculateAllData();
      }
    }.delay(100);

    _refresher = appBloc.announcementService!.stream.listen((event) {
      if (mounted) {
        calculateAllData();
      }
    });

    _searchTextFieldController.addListener(_onTextChange);
  }

  void calculateAllData() {
    setState(() {
      _calculatedList = AnnouncementHelper.getAllFilteredAnnouncement();
      _makeFilter();
    });
  }

  void _onTextChange() {
    setState(() {
      _searchText = _searchTextFieldController.text.toSearchCase();
      _makeFilter();
    });
  }

  void _makeFilter() {
    List<Announcement> _itemList = [];
    //? Filter ekrani icin filtreleme yapar
    if (_searchText.isEmpty && _searchClassKey == 'all' && _searchDate == null) {
      _itemList = _calculatedList;
    } else {
      _itemList = _calculatedList.where((element) {
        return (element.title.toSearchCase().contains(_searchText) || element.content.toSearchCase().contains(_searchText)) &&
            (_searchClassKey == "all" || element.targetList!.contains(_searchClassKey) || element.targetList!.contains("alluser")) &&
            (_searchDate == null || (element.createTime >= _searchDate!.first && element.createTime <= _searchDate!.last));
      }).toList();
    }

//? Yeni yada yayinlanmamislarin gosterilmesi uzerine filtreleme yapar
    _unPublishedItems.clear();
    _newItems.clear();
    _otherItems.clear();
    _itemList.forEach((element) {
      if (element.isPublish != true) {
        _unPublishedItems.add(element);
      } else if ((element.createTime ?? 0) > Fav.preferences.getInt(AnnouncementHelper.lastAnnouncementPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch)) {
        _newItems.add(element);
      } else {
        _otherItems.add(element);
      }
    });
  }

  @override
  void dispose() {
    _refresher?.cancel();
    _searchTextFieldController.removeListener(_onTextChange);
    if (DateTime.now().difference(pageLoginTime) > Duration(milliseconds: 2000)) AnnouncementHelper.saveLastLoginTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Body _body;

    if (((_calculatedList.isEmpty && appBloc.announcementService!.state == FetchDataState.fetchingNewData))) {
      _body = Body.circularProgressIndicator();
    } else if (_otherItems.isEmpty && _newItems.isEmpty && _unPublishedItems.isEmpty) {
      _body = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS).center);
    } else if (_unPublishedItems.isEmpty && _newItems.isEmpty) {
      _body = Body.staggeredGridViewBuilder(
        withSelectionArea: true,
        padding: Inset.ltrb(0, 16, 0, context.screenBottomPadding),
        maxWidth: 1000,
        crossAxisCount: context.screenWidth > 600 ? 2 : 1,
        itemCount: _otherItems.length,
        itemBuilder: (BuildContext context, int index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Fav.design.primaryText.withAlpha(2)),
          child: AnnouncementItem(announcement: _otherItems[index]),
        ),
      );
    } else if (context.screenWidth <= 600) {
      final _lastItemList = [
        if (_unPublishedItems.isNotEmpty) AnnouncementAndSocialListSticky(AnnouncementSocialIconDataType.annnouncementUnpublished),
        ..._unPublishedItems,
        if (_newItems.isNotEmpty) AnnouncementAndSocialListSticky(AnnouncementSocialIconDataType.announcementNew).paddingOnly(top: _unPublishedItems.isNotEmpty ? 32 : 0),
        ..._newItems,
        if (_otherItems.isNotEmpty) AnnouncementAndSocialListSticky(AnnouncementSocialIconDataType.announcementOld).paddingOnly(top: _unPublishedItems.isNotEmpty || _newItems.isNotEmpty ? 32 : 0),
        ..._otherItems,
      ];
      _body = Body.listviewBuilder(
        withSelectionArea: true,
        padding: Inset.ltrb(0, 16, 0, context.screenBottomPadding),
        maxWidth: 1000,
        itemCount: _lastItemList.length,
        itemBuilder: (context, index) {
          final _item = _lastItemList[index];
          if (_item is! Announcement) return _item as Widget;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Fav.design.primaryText.withAlpha(2)),
            child: AnnouncementItem(announcement: _lastItemList[index] as Announcement?),
          );
        },
      );
    } else {
      _body = Body.child(
        withSelectionArea: true,
        padding: Inset.ltrb(0, 16, 0, context.screenBottomPadding),
        maxWidth: _unPublishedItems.isNotEmpty && _newItems.isNotEmpty ? 1280 : 1000,
        child: Row(
          children: [
            if (_unPublishedItems.isNotEmpty)
              Expanded(
                child: AnnouncementListLargeScreenColumn(
                  announcementList: _unPublishedItems,
                  type: AnnouncementSocialIconDataType.annnouncementUnpublished,
                ),
              ),
            if (_newItems.isNotEmpty)
              Expanded(
                child: AnnouncementListLargeScreenColumn(
                  announcementList: _newItems,
                  type: AnnouncementSocialIconDataType.announcementNew,
                ),
              ),
            if (_otherItems.isNotEmpty)
              Expanded(
                child: AnnouncementListLargeScreenColumn(
                  announcementList: _otherItems,
                  type: AnnouncementSocialIconDataType.announcementOld,
                ),
              ),
          ],
        ),
      );
    }

    return AppScaffold(
      isFullScreenWidget: widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: Colors.transparent,
      topBar: TopBar(
        hideBackButton: true,
        leadingTitle: 'menu1'.translate,
        trailingActions: [
          if (AppVar.appBloc.hesapBilgileri.gtMT)
            FilterSearchIcon(
              toolTip: true,
              // tooltip: 'filter'.translate,
              // icon: Icon(Icons.filter_list_sharp, color: Fav.design.primaryText),
              onPressed: () async {
                setState(() {
                  _isSearchMenuOpen = !_isSearchMenuOpen;
                });
              },
            ).px4,
          if (AppVar.appBloc.hesapBilgileri.gtT || AuthorityHelper.hasYetki4(warning: false))
            AddIcon(
              reversedIcon: true,
              toolTip: true,
              color: GlassIcons.announcementIcon.color,
              // icon: Icon(Icons.add, color: Fav.design.primaryText),
              onPressed: () async {
                var result = await Fav.to(ShareAnnouncements(previousPageTitle: 'announcements'.translate), preventDuplicates: false);
                if (result == true) OverAlert.saveSuc();
              },
            ).px4,
        ],
      ),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(
            title: 'announcements'.translate,
            color: GlassIcons.announcementIcon.color,
            imgUrl: GlassIcons.announcementIcon.imgUrl,
          ),
          child: Column(
            children: [
              AppVar.appBloc.hesapBilgileri.gtMT && _isSearchMenuOpen
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: context.screenWidth < 1008 ? 0 : (context.screenWidth - 1008) / 2 + 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: CupertinoSearchTextField(
                            style: TextStyle(color: Fav.design.primaryText),
                            controller: _searchTextFieldController,
                          )),
                          8.widthBox,
                          Expanded(
                              child: DropDownMenu<String>(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            value: _searchClassKey,
                            placeHolderText: 'classlist'.translate,
                            onChanged: (value) {
                              setState(() {
                                _searchClassKey = value;
                                _makeFilter();
                              });
                            },
                            items: AppVar.appBloc.classService!.dataList.map((e) => DropdownItem(name: e.name, value: e.key)).toList()..insert(0, DropdownItem(name: 'all'.translate, value: 'all')),
                          )),
                          Expanded(
                              child: MyDateRangePicker(
                            onChanged: (value) {
                              setState(() {
                                _searchDate = value;
                                _makeFilter();
                              });
                            },
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 31)),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          )),
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          )),
      body: _body,
    );
  }
}
