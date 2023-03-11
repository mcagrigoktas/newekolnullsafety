import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../models/allmodel.dart';
import '../../services/remote_control.dart';
import '../../widgets/announcement_social_list_sticky.dart';
import 'helper.dart';
import 'share_social/sharesocial.dart';
import 'socialitem.dart';

class SocialPage extends StatefulWidget {
  final bool forMiniScreen;
  SocialPage({this.forMiniScreen = false});
  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  StreamSubscription? _refresher;
  List<SocialItem> _calculatedList = [];
  final List<SocialItem> _otherItems = [];
  final List<SocialItem> _unPublishedItems = [];
  final List<SocialItem> _newItems = [];

  SocialType? segment = SocialType.photoAndVideo;
  List<int>? _searchDate;
  var _isSearchMenuOpen = false;
  String _searchText = '';
  String _searchClassKey = 'all';

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

    _refresher = StreamGroup.merge([
      if (Get.find<RemoteControlValues>().useFirestoreForSocial == false) AppVar.appBloc.socialService!.stream,
      if (Get.find<RemoteControlValues>().useFirestoreForSocial == false) AppVar.appBloc.videoService!.stream,
      if (Get.find<RemoteControlValues>().useFirestoreForSocial == true) AppVar.appBloc.newSocialService!.stream,
    ]).listen((event) {
      if (mounted) {
        calculateAllData();
      }
    });
  }

  void calculateAllData() {
    setState(() {
      _calculatedList = SocialHelper.getAllFilteredSocialList(segment);
      _makeFilter();
    });
  }

  void _makeFilter() {
    List<SocialItem> _itemList = [];

    if (_searchText.isEmpty && _searchClassKey == 'all' && _searchDate == null) {
      _itemList = _calculatedList;
    } else {
      _itemList = _calculatedList.where((element) {
        return (element.content!.toLowerCase().contains(_searchText)) && (_searchClassKey == "all" || element.targetList!.contains(_searchClassKey) || element.targetList!.contains("alluser")) && (_searchDate == null || (element.time >= _searchDate!.first && element.time <= _searchDate!.last));
      }).toList();
    }

    //? Yeni yada yayinlanmamislarin gosterilmesi uzerine filtreleme yapar
    _unPublishedItems.clear();
    _newItems.clear();
    _otherItems.clear();
    _itemList.forEach((element) {
      if (element.isPublish != true) {
        _unPublishedItems.add(element);
      } else if ((element.time) > Fav.preferences.getInt(SocialHelper.lastSocialPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch)!) {
        _newItems.add(element);
      } else {
        _otherItems.add(element);
      }
    });
  }

  @override
  void dispose() {
    _refresher?.cancel();
    if (DateTime.now().difference(pageLoginTime) > Duration(milliseconds: 2000)) SocialHelper.saveLastLoginTime();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Body _body;

    if (_otherItems.isEmpty && _newItems.isEmpty && _unPublishedItems.isEmpty) {
      _body = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS).center);
    } else if (_unPublishedItems.isEmpty && _newItems.isEmpty) {
      _body = Body.staggeredGridViewBuilder(
          padding: Inset.b(context.screenBottomPadding),
          maxWidth: 1000,
          crossAxisCount: context.screenWidth > 600 ? 2 : 1,
          itemCount: _otherItems.length,
          itemBuilder: (BuildContext context, int index) => SocialItemWidget(
                key: ObjectKey(_otherItems[index]),
                item: _otherItems[index],
                pageStorageKey: "73849" + _otherItems.length.toString() + index.toString(),
              ));
    } else if (context.screenWidth <= 600) {
      final _lastItemList = [
        if (_unPublishedItems.isNotEmpty) AnnouncementAndSocialListSticky(AnnouncementSocialIconDataType.socialUnpunlished),
        ..._unPublishedItems,
        if (_newItems.isNotEmpty) AnnouncementAndSocialListSticky(AnnouncementSocialIconDataType.socialNew).paddingOnly(top: _unPublishedItems.isNotEmpty ? 32 : 0),
        ..._newItems,
        if (_otherItems.isNotEmpty) AnnouncementAndSocialListSticky(AnnouncementSocialIconDataType.socialOld).paddingOnly(top: _unPublishedItems.isNotEmpty || _newItems.isNotEmpty ? 32 : 0),
        ..._otherItems,
      ];
      _body = Body.listviewBuilder(
        padding: Inset.ltrb(0, 16, 0, context.screenBottomPadding),
        maxWidth: 1000,
        itemCount: _lastItemList.length,
        itemBuilder: (context, index) {
          final _item = _lastItemList[index];
          if (_item is! SocialItem) return _item as Widget;
          return SocialItemWidget(
            key: ObjectKey(_lastItemList[index]),
            item: _lastItemList[index] as SocialItem?,
            pageStorageKey: "73849" + _lastItemList.length.toString() + index.toString(),
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
                child: SocialListLargeScreenColumn(
                  socialItemList: _unPublishedItems,
                  type: AnnouncementSocialIconDataType.socialUnpunlished,
                ),
              ),
            if (_newItems.isNotEmpty)
              Expanded(
                child: SocialListLargeScreenColumn(
                  socialItemList: _newItems,
                  type: AnnouncementSocialIconDataType.socialNew,
                ),
              ),
            if (_otherItems.isNotEmpty)
              Expanded(
                child: SocialListLargeScreenColumn(
                  socialItemList: _otherItems,
                  type: AnnouncementSocialIconDataType.socialOld,
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
        trailingActions: <Widget>[
          if (AppVar.appBloc.hesapBilgileri.gtMT && _calculatedList.isNotEmpty)
            FilterSearchIcon(
              toolTip: true,
              onPressed: () async {
                setState(() {
                  _isSearchMenuOpen = !_isSearchMenuOpen;
                });
              },
            ),
          if (AppVar.appBloc.hesapBilgileri.gtT || AuthorityHelper.hasYetki4())
            AddIcon(
              onPressed: () {
                Fav.to(ShareSocial(previousPageTitle: 'social'.translate), preventDuplicates: false);
              },
              color: GlassIcons.social.color,
            ),
        ],
      ),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(
            title: 'social'.translate,
            color: GlassIcons.social.color,
            imgUrl: GlassIcons.social.imgUrl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (DateTime.now().millisecondsSinceEpoch - Fav.preferences.getInt('SocialInfoVisibleTime', 0)! > Duration(days: 15).inMilliseconds)
                          IconButton(
                            icon: Icon(Icons.info_outline, color: Fav.design.primaryText.withAlpha(200)),
                            onPressed: () async {
                              await OverDialog.show(DialogPanel.defaultPanel(
                                title: 'warning'.translate,
                                subTitle: 'socialnetworkwarning'.translate,
                              ));
                              await Fav.preferences.setInt('SocialInfoVisibleTime', DateTime.now().millisecondsSinceEpoch);
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                  CupertinoSlidingSegmentedControl<SocialType>(
                    groupValue: segment,
                    children: {
                      SocialType.photoAndVideo: 'all'.translate.text.make(),
                      SocialType.photo: 'photo'.translate.text.make(),
                      SocialType.video: 'video'.translate.text.make(),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        segment = value;
                        _calculatedList = SocialHelper.getAllFilteredSocialList(value);
                        _makeFilter();
                      });
                    },
                  ),
                  Spacer(),
                ],
              ),
              (AppVar.appBloc.hesapBilgileri.gtMT && _isSearchMenuOpen)
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: context.screenWidth < 1008 ? 0 : (context.screenWidth - 1008) / 2 + 2),
                      child: Row(
                        children: [
                          Expanded(
                              child: CupertinoSearchTextField(
                            style: TextStyle(color: Fav.design.primaryText),
                            onChanged: (value) {
                              setState(() {
                                _searchText = value.toLowerCase();
                                _makeFilter();
                              });
                            },
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
                            firstDate: (_calculatedList.isNotEmpty) ? DateTime.fromMillisecondsSinceEpoch(_calculatedList.last.time) : DateTime.now().subtract(const Duration(days: 365)),
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
