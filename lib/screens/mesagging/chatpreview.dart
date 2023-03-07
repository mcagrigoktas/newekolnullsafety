import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../main/macos_dock/macos_dock.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import 'batchmessage.dart';
import 'helper.dart';
import 'mesagging_preview_item.dart';

class ChatPreview extends StatefulWidget {
  final bool ghost;
  final String? ghostUid;
  final String? ghostName;
  final bool forMiniScreen;

  ChatPreview({this.ghost = false, this.ghostUid, this.ghostName, this.forMiniScreen = false});
  @override
  _ChatPreviewState createState() => _ChatPreviewState();
}

class _ChatPreviewState extends State<ChatPreview> with AppFunctions {
  String _searchText = '';
  Map? _ghostMessageData = {};
  bool _isLoading = false;
  StreamSubscription? _refresher;
  List<MesaggingPreview> _finalFilteredList = [];
  final List<MesaggingPreview> _filteredList = [];

  late DateTime pageLoginTime;

  @override
  void initState() {
    super.initState();

    pageLoginTime = DateTime.now();

    clearWarning();

    if (widget.ghost) {
      _isLoading = true;
      MessageService.dbMessagesPreviewRef(widget.ghostUid).once().then((snap) {
        if (snap?.value != null) {
          _ghostMessageData = snap!.value;
        }
        setState(() {
          _prepareMessaggingPreviewList();
          _makeFilter();
          _isLoading = false;
        });
      }).catchError((_) {});
    } else {
      _refresher = AppVar.appBloc.messaggingPreviewService!.stream.listen((event) {
        if (mounted) {
          setState(() {
            _prepareMessaggingPreviewList();
            _makeFilter();
          });
        }
      });
    }
  }

  void _makeFilter() {
    if (_searchText.isEmpty) {
      _finalFilteredList = _filteredList;
    } else {
      _finalFilteredList = _filteredList.where((element) {
        return (element.senderName.toSearchCase().contains(_searchText));
      }).toList();
    }
  }

  void _prepareMessaggingPreviewList() {
    _filteredList.clear();
    if (widget.ghost) {
      _ghostMessageData!.forEach((key, value) {
        _filteredList.add(MesaggingPreview.fromJson(value, key));
      });
    } else {
      _filteredList.addAll(MessagePreviewHelper.getAllFilteredMesaggingPreviewList(AppVar.appBloc.messaggingPreviewService!.data));
    }

    _filteredList.sort((item1, item2) {
      return (item2.timeStamp ?? 0) - (item1.timeStamp ?? 0);
    });
  }

  @override
  void dispose() {
    _refresher?.cancel();
    //  if (!widget.ghost) AppVar.appBloc.messaggingPreviewService.refresh();

    if (DateTime.now().difference(pageLoginTime) > Duration(milliseconds: 2000)) MessagePreviewHelper.saveLastLoginTime();

    super.dispose();
  }

  void clearWarning() {
    if (widget.ghost) return;

    final newMessage = Get.find<MacOSDockController>().messageNotificationList();

////todocheck bu asagidaki gerekli mi eski mi
    if (newMessage != null) {
      if (AppVar.appBloc.hesapBilgileri.gtS && AppVar.appBloc.hesapBilgileri.isParent) {
        MessageService.setFalseNewMessage(isParent: true, parentNo: AppVar.appBloc.hesapBilgileri.parentNo);
      } else {
        MessageService.setFalseNewMessage(isParent: false);
      }
    }
  }

  Widget _getGhostTeacherListWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: MyPopupMenuButton(
        child: Icon(Icons.remove_red_eye, color: Fav.design.appBar.text),
        itemBuilder: (context) {
          return AppVar.appBloc.teacherService!.dataList
              .map((teacher) => PopupMenuItem(
                    child: Text(teacher.name!, style: TextStyle(color: Fav.design.primaryText)),
                    value: teacher.key,
                  ))
              .toList();
        },
        onSelected: (value) {
          Fav.guardTo(
              ChatPreview(
                ghost: true,
                ghostUid: value,
                ghostName: AppVar.appBloc.teacherService!.dataList.singleWhere((t) => t.key == value).name,
              ),
              preventDuplicates: false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBloc = AppVar.appBloc;
    if (appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki8() == false) {
      return AppScaffold(
          topBar: TopBar(
            hideBackButton: true,
            leadingTitle: 'menu1'.translate,
          ),
          body: Body.child(child: EmptyState(text: 'hasntauthority'.translate + ' ' + 'yetki8'.translate)));
    }

    if (_isLoading) return MyProgressIndicator(isCentered: true).inScaffold;

    return AppScaffold(
      isFullScreenWidget: widget.ghost || widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: widget.ghost ? null : Colors.transparent,
      topBar: TopBar(
        hideBackButton: widget.forMiniScreen || !widget.ghost,
        leadingTitle: widget.ghost ? 'messages'.translate : 'menu1'.translate,
        trailingActions: appBloc.hesapBilgileri.gtM || (appBloc.hesapBilgileri.gtT && UserPermissionList.hasTeacherMessageParent() == true)
            ? <Widget>[
                if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki6(warning: false) && !widget.ghost) _getGhostTeacherListWidget(),
                if (!widget.ghost)
                  IconButton(
                    onPressed: () {
                      Fav.guardTo(BatchMessages(), preventDuplicates: false);
                    },
                    icon: Icon(MdiIcons.accountMultiple, color: Fav.design.appBar.text),
                  ),
              ]
            : [],
        middle: widget.ghostName?.text.color(Fav.design.appBar.text).make(),
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: 'messages'.translate, color: GlassIcons.messagesIcon.color, imgUrl: GlassIcons.messagesIcon.imgUrl),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: context.screenWidth < 1008 ? 0 : (context.screenWidth - 1008) / 2 + 2),
          child: MySearchBar(
            initialText: _searchText,
            key: ValueKey('SerachBarPerson'),
            placeholder: 'searchperson'.translate,
            //  style: TextStyle(color: Fav.design.primaryText),
            onChanged: (value) {
              setState(() {
                _searchText = value.toSearchCase();
                _makeFilter();
              });
            },
          ).p16,
        ),
      ),
      body: _finalFilteredList.isEmpty
          ? Body.child(child: EmptyState(text: 'norecords'.translate))
          : Body.listviewBuilder(
              withKeyboardCloserGesture: true,
              padding: Inset.b(context.screenBottomPadding),
              maxWidth: 1000,
              itemBuilder: (BuildContext context, int index) {
                return MessagePreviewItem(
                  item: _finalFilteredList[index],
                  ghost: widget.ghost,
                  ghostUid: widget.ghostUid,
                  forWidgetMenu: false,
                  afterBackChatDetail: () {
                    setState(() {});
                  },
                );
              },
              itemCount: _finalFilteredList.length,
            ),
    );
  }
}
