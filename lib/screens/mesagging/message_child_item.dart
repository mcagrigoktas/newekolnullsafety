import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';
import 'package:mypackage/srcpages/photoview.dart';
import 'package:widgetpackage/link_widget/link_text.dart';

import '../../models/chatmodel.dart';

class MessageChildItem extends StatelessWidget {
  final ChatModel item;
  final bool owner;
  MessageChildItem(this.item, this.owner);

  @override
  Widget build(BuildContext context) {
    final Color _onPrimaryColor = Fav.design.primaryText;

    if (item.imgList != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 125),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Hero(
                    tag: item.imgList!,
                    child: MyCachedImage(
                      placeholder: true,
                      fit: BoxFit.cover,
                      imgUrl: item.imgList![index],
                      width: double.infinity,
                    ));
              },
              onTap: (index) {
                Fav.to(PhotoView(
                  urlList: item.imgList!,
                  index: index,
                ));
              },
              autoplayDelay: 3000,
              duration: 1000,
              autoplay: true,
              autoplayDisableOnInteraction: true,
              loop: false,
              itemCount: item.imgList!.length,
              pagination: null,
            ),
          ),
        ),
      );
    } else if (item.imageUrl != null) {
      return GestureDetector(
          key: ValueKey(item.imageUrl),
          onTap: () {
            Fav.to(PhotoView(urlList: [item.imageUrl!]));
          },
          child: MyCachedImage(imgUrl: item.imageUrl!, width: 125, placeholder: true));
    } else if (item.videoUrl != null) {
      return GestureDetector(
          onTap: () {
            Fav.to(MyVideoPlay(url: item.videoUrl!, isActiveDownloadButton: true, cacheVideo: true));
          },
          child: Container(
              width: 150,
              height: 80,
              decoration: BoxDecoration(image: DecorationImage(image: CacheHelper.imageProvider(imgUrl: item.thumbnailUrl ?? ''), fit: BoxFit.cover), borderRadius: BorderRadius.circular(4)),
              child: Icon(Icons.play_circle_filled, size: 48, color: owner ? Colors.white : _onPrimaryColor)));
    } else if (item.audioUrl != null) {
      return MyAudioPlayers(
        url: item.audioUrl!,
        textColor: owner ? Colors.white : _onPrimaryColor,
      );
    } else if (item.fileUrl != null) {
      return GestureDetector(
        onTap: () {
          DocumentView.openTypeList(item.fileUrl!);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.attach_file, color: owner ? Colors.white : _onPrimaryColor),
            Flexible(
              child: owner ? Text(item.message!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.right) : Text(item.message!, style: TextStyle(color: _onPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.left),
            ),
          ],
        ),
      );
    } else {
      if (item.message!.contains(RegExp('http|www'))) {
        return owner
            ? LinkText(
                item.message!,
                textStyle: TextStyle(color: Colors.blue),
                linkStyle: TextStyle(decoration: TextDecoration.underline, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.right,
              )
            : LinkText(
                item.message!,
                textAlign: TextAlign.left,
                textStyle: TextStyle(color: Colors.blue),
                linkStyle: TextStyle(decoration: TextDecoration.underline, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: _onPrimaryColor),
              );
      }
      return owner
          ? SelectableText(
              item.message!,
              style: TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.right,
            )
          : SelectableText(
              item.message!,
              style: TextStyle(color: _onPrimaryColor, fontSize: 15),
              textAlign: TextAlign.left,
            );
    }
  }
}
