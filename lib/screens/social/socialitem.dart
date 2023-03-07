import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/photoview.dart';
import 'package:mypackage/srcpages/youtube_player/youtube_player_shared.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import 'socialfunctions.dart';

class SocialItemWidget extends StatelessWidget with SocialFunctions {
  final SocialItem? item;
  final String? pageStorageKey;
  final bool forWidgetMenu;
  SocialItemWidget({this.item, this.pageStorageKey, this.forWidgetMenu = false, ObjectKey? key}) : super(key: key);

  void _openPhoto(BuildContext context, List<String> urlList, int index) {
    Fav.to(PhotoView(
      urlList: urlList,
      index: index,
      actionButtonDisable: AppVar.appBloc.hesapBilgileri.kurumID == 'demoapple' || AppVar.appBloc.hesapBilgileri.kurumID == 'demoaccount',
    ));
  }

  Future<void> _publish(BuildContext context, SocialItem? item, String tur) async {
    if (AuthorityHelper.hasYetki4(warning: true) == false) return;
    OverLoading.show();
    var contactList = targetListToContactList(targetList: item!.targetList, senderKey: item.senderKey);
    await SocialService.publishSocialItem(item, tur, contactList).then((_) {
      OverAlert.saveSuc();
    }).catchError((_) {
      OverAlert.saveErr();
    });
    await OverLoading.close();
  }

  Future<void> _delete(SocialItem? item, String tur) async {
    if (AppVar.appBloc.hesapBilgileri.gtS) return;
    //Guvenlik
    if (AppVar.appBloc.hesapBilgileri.gtT && AppVar.appBloc.hesapBilgileri.uid != item!.senderKey) return;
    //Guvenlik
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki4(warning: true) == false) return;

    OverLoading.show();
    var contactList = targetListToContactList(targetList: item!.targetList, senderKey: item.senderKey);
    await SocialService.deleteSocialItem(item.key, tur, contactList).then((_) {
      OverLoading.close(state: true);
      //   OverAlert.deleteSuc();
    }).catchError((_) {
      OverLoading.close(state: false);
      //   OverAlert.deleteErr();
    });
  }

  Future<void> _operTargetList(BuildContext context, SocialItem? item) async {
    int _allCount = 0;
    final List _listviewChildren = AppVar.appBloc.studentService!.dataList.where((ogrenci) {
      return item!.targetList!.any((itemm) => ["alluser", ...ogrenci.classKeyList, ogrenci.key].contains(itemm));
    }).map((ogrenci) {
      _allCount++;
      return Container(
        color: Fav.design.primaryText.withAlpha(_allCount.isEven ? 10 : 0),
        child: Text(ogrenci.name!, style: TextStyle(color: Fav.design.primaryText, fontSize: 14)).px12,
      );
    }).toList();

    OverPage.openModelBottomWithListView(
        itemBuilder: (context, index) {
          return _listviewChildren[index];
        },
        itemCount: _listviewChildren.length,
        title: 'sender'.translate + ': ' + (item!.senderName ?? ''),
        extraWidget: Row(
          children: [
            Expanded(
              child: item.targetList!.contains("alluser")
                  ? Text("allstudents".translate, style: TextStyle(color: Fav.design.primary))
                  : Wrap(
                      children: AppVar.appBloc.classService!.dataList.where((sinif) {
                        return item.targetList!.contains(sinif.key);
                      }).map((sinif) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: const ShapeDecoration(color: Colors.amber, shape: StadiumBorder()),
                          child: Text(sinif.name!, style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                    ),
            ),
            8.widthBox,
            "$_allCount".translate.text.bold.color(Fav.design.primary).make(),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool _isPhoto = true;
    if ((item!.youtubeLink ?? '').length > 10 || (item!.videoLink ?? '').length > 10) {
      _isPhoto = false;
    }

    List<Widget> _extralist = [];

    // Yayınlanmamışsa idareci için yayınla butonu öğretmen için onay bekliyor yazısı oluşturur.
    if (!(item!.isPublish ?? false)) {
      if (AppVar.appBloc.hesapBilgileri.gtT) {
        _extralist.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Text(
            "waitingpublish".translate,
            style: TextStyle(color: Fav.design.primary, fontSize: 12.0),
          ),
        ));
      } else if (AppVar.appBloc.hesapBilgileri.gtM) {
        _extralist.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: MyMiniRaisedButton(
            text: "publish".translate,
            onPressed: () {
              _publish(context, item, _isPhoto ? "SocialNetwork" : "Video");
            },
            color: Fav.design.customColors2[2],
          ),
        ));
      }
    }

    // Popup Menu Button ve içerisine silme ve hedef listesi oluşturur
    if (AppVar.appBloc.hesapBilgileri.gtT || AuthorityHelper.hasYetki4()) {
      _extralist.add(PopupMenuButton(
        child: SizedBox(
          width: 32.0,
          height: 32.0,
          child: Icon(
            Icons.more_vert,
            size: 20.0,
            color: Fav.design.disablePrimary,
          ),
        ),
        // child: MyMiniRaisedButton(text: ".",color: appBloc.appTheme.disablePink,),
        itemBuilder: (context) {
          return <PopupMenuEntry>[
            item!.targetList!.contains('onlyteachers') ? PopupMenuItem(value: "onlyteachers", child: Text("onlyteachersshared".translate)) : PopupMenuItem(value: "targetlist", child: Text("targetlist".translate)),
            const PopupMenuDivider(),
            if (AppVar.appBloc.hesapBilgileri.gtM || (AppVar.appBloc.hesapBilgileri.gtT && AppVar.appBloc.hesapBilgileri.uid == item!.senderKey)) PopupMenuItem(value: "delete", child: Text(Words.delete)),
          ];
        },
        onSelected: (dynamic value) {
          if (Fav.noConnection()) return;
          if (value == "delete") _delete(item, _isPhoto ? "SocialNetwork" : "Video");
          if (value == "targetlist") _operTargetList(context, item);
        },
      ));
    }

    Widget _itemWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: AspectRatio(
        aspectRatio: 32 / 21,
        child: _isPhoto
            ? Swiper(
                key: PageStorageKey(pageStorageKey),
                itemBuilder: (BuildContext context, int index) {
                  return Hero(
                      tag: item!.imgList![index],
                      child: MyCachedImage(
                        placeholder: true,
                        fit: BoxFit.cover,
                        imgUrl: item!.imgList![index],
                        width: double.infinity,
                      ));
                },
                onTap: (index) {
                  _openPhoto(context, item!.imgList!, index);
                },
                //  indicatorLayout: PageIndicatorLayout.WARM,
                //   autoplay: true,
                autoplayDelay: 7000,
                duration: 1000,
                autoplayDisableOnInteraction: true,
                loop: false,

                itemCount: item!.imgList?.length ?? 0,
                pagination:
                    (item!.imgList?.length ?? 0) > 1 ? SwiperPagination(builder: DotSwiperPaginationBuilder(activeColor: Fav.design.primary, size: forWidgetMenu ? 3.0 : 7.0, color: Fav.design.primary.withAlpha(80), space: forWidgetMenu ? 1.0 : 3.0, activeSize: forWidgetMenu ? 5.0 : 10.0)) : null,
              )
            : (item!.youtubeLink != null
                ? MyYoutubeWidget(item!.youtubeLink!)
                : MyVideoWidget(
                    url: item!.videoLink!,
                    thumbnail: item!.videoThumb!,
                    iconColor: GlassIcons.social.color,
                  )),
      ),
    );

    Widget _content = (item!.content ?? "").isNotEmpty
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: forWidgetMenu ? 4 : 8, horizontal: 16.0),
            child: Text(
              item!.content!,
              textAlign: TextAlign.start,
              style: TextStyle(color: forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.primaryText, fontSize: forWidgetMenu ? 14 : 16),
            ),
          )
        : 2.heightBox;

    Widget _infoWidget = Row(
      children: <Widget>[
        item!.senderImgUrl.safeLength > 6
            ? CircularProfileAvatar(
                imageUrl: item!.senderImgUrl,
                borderColor: GlassIcons.social.color!,
                borderWidth: 1,
                elevation: 3,
                radius: forWidgetMenu ? 18.0 : 24.0,
              )
            : Icon(
                MdiIcons.accountCircle,
                color: Fav.design.primary,
              ),
        8.widthBox,
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item!.senderName ?? "",
                style: TextStyle(color: forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.primaryText, fontSize: forWidgetMenu ? 14 : 18, fontWeight: FontWeight.bold),
              ),
              2.heightBox,
              Text(
                item!.getDateText,
                style: TextStyle(color: forWidgetMenu ? const Color(0xFF3B1736).withAlpha(150) : Fav.design.primaryText.withAlpha(150), fontSize: forWidgetMenu ? 10 : 12),
              ),
            ],
          ),
        ),
        Column(children: _extralist),
      ],
    );

    if (forWidgetMenu) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoWidget.p8,
                  _content.px8,
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8), child: SizedBox(width: 100, child: _itemWidget)),
            //  Container(height: 1.0,color: appBloc.appTheme.lightTeal,),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
      decoration: BoxDecoration(
        color: Fav.design.card.background,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 2.0)],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _infoWidget,
          ),
          _content,
          _itemWidget,
          //  Container(height: 1.0,color: appBloc.appTheme.lightTeal,),
        ],
      ),
    );
  }
}
