import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/photoview.dart';
import 'package:mypackage/srcpages/youtube_player/youtube_player_shared.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../localization/usefully_words.dart';
import '../../../../services/dataservice.dart';
import 'model.dart';

class PostItemWidget extends StatelessWidget {
  final ChangeLogPostItem item;
  final bool comingToDeveloperPage;
  final bool isFirst;
  final bool isLast;
  final int index;
  PostItemWidget({required this.item, Key? key, this.comingToDeveloperPage = false, required this.isFirst, required this.isLast, required this.index}) : super(key: key);

  void _openPhoto(BuildContext context, List<String> urlList, int index) {
    Fav.to(PhotoView(
      urlList: urlList,
      index: index,
      actionButtonDisable: true,
    ));
  }

  Future<void> _delete() async {
    OverLoading.show();
    await ChangeLogService.sendChangelogData(item, delete: true).then((_) {
      OverAlert.saveSuc();
    }).catchError((_) {
      OverAlert.saveErr();
    });
    await OverLoading.close(state: false);
  }

  @override
  Widget build(BuildContext context) {
    Widget _otherFunctions = comingToDeveloperPage
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              8.widthBox,
              SimplePopupButton(
                child: MoreIcon2(),
                itemList: [
                  PopupItem(value: "delete", title: Words.delete),
                ],
                onSelected: (value) {
                  if (Fav.noConnection()) return;
                  if (value == "delete") _delete();
                },
              ),
            ],
          )
        : SizedBox();

    Widget _itemWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.imgList != null && item.imgList!.isNotEmpty)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: AspectRatio(
                aspectRatio: 32 / 21,
                child: Swiper(
                  key: PageStorageKey('K${item.key}'),
                  itemBuilder: (BuildContext context, int index) {
                    return Hero(
                        tag: item.imgList![index],
                        child: MyCachedImage(
                          placeholder: true,
                          fit: BoxFit.cover,
                          imgUrl: item.imgList![index],
                          width: double.infinity,
                        ));
                  },
                  onTap: (index) {
                    _openPhoto(context, item.imgList!, index);
                  },
                  autoplayDelay: 7000,
                  duration: 1000,
                  autoplayDisableOnInteraction: true,
                  loop: false,
                  itemCount: item.imgList?.length ?? 0,
                  pagination: (item.imgList?.length ?? 0) > 1 ? SwiperPagination(builder: DotSwiperPaginationBuilder(activeColor: Fav.design.primary, size: 7.0, color: Fav.design.primary.withAlpha(80), space: 3.0, activeSize: 10.0)) : null,
                ),
              ),
            ),
          ),
        if (item.youtubeLink.safeLength > 6)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: AspectRatio(
                aspectRatio: 32 / 21,
                child: MyYoutubeWidget(item.youtubeLink!),
              ),
            ),
          ),
      ],
    );

    Widget _content = (item.content ?? "").isNotEmpty
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
            child: Text(
              item.content!,
              textAlign: TextAlign.start,
              style: TextStyle(color: Fav.design.primaryText, fontSize: 16),
            ),
          )
        : 2.heightBox;

    Widget _infoWidget = Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        if (item.title.safeLength > 1)
          Expanded(
            flex: 1,
            child: SizedBox(height: 32, child: item.title.text.fontSize(22).bold.maxLines(1).autoSize.make()),
          )
        else
          Spacer(),
        _otherFunctions,
      ],
    );

    final _current = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
      decoration: BoxDecoration(
        color: Fav.design.card.background,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 2.0)],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: Inset.hv(16, 8), child: _infoWidget),
          _content.pb8,
          _itemWidget,
        ],
      ),
    );

    final _timeText = RotatedBox(
      quarterTurns: 3,
      child: Center(
        child: Text(
          item.getDateText,
          style: TextStyle(color: Fav.design.scaffold.background, fontWeight: FontWeight.bold, fontSize: 16),
        ).rounded(background: Fav.design.primary, padding: Inset.hv(8, 4)),
      ),
    );

    final lineStyle = LineStyle(
      color: Fav.design.primary.withAlpha(150),
      thickness: 4,
    );

    // if (context.screenWidth > 600) {
    //   return TimelineTile(
    //     indicatorStyle: IndicatorStyle(indicator: _timeText, height: 128, width: 40),
    //     alignment: TimelineAlign.center,
    //     lineXY: 0.08,
    //     afterLineStyle: lineStyle,
    //     beforeLineStyle: lineStyle,
    //     isFirst: isFirst,
    //     isLast: isLast,
    //     endChild: index.isOdd ? _current : Container(),
    //     startChild: index.isEven ? _current : Container(),
    //   );
    // }
    return TimelineTile(
      indicatorStyle: IndicatorStyle(indicator: _timeText, height: 128, width: 40, indicatorXY: 0.01),
      alignment: TimelineAlign.start,
      lineXY: 0.08,
      afterLineStyle: lineStyle,
      beforeLineStyle: lineStyle,
      isFirst: isFirst,
      isLast: isLast,
      endChild: _current.pb32.pb32,
    );
  }
}
