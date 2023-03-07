import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../assets.dart';
import '../helpers/glassicons.dart';
import '../models/socialitem.dart';
import '../screens/announcements/announcement.dart';
import '../screens/announcements/announcementitem.dart';
import '../screens/social/socialitem.dart';

class SocialListLargeScreenColumn extends StatelessWidget {
  final AnnouncementSocialIconDataType? type;
  final List<SocialItem>? socialItemList;

  SocialListLargeScreenColumn({this.type, this.socialItemList});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnnouncementAndSocialListSticky(type),
        Expanded(
          child: ListView.builder(
            itemCount: socialItemList!.length,
            itemBuilder: (BuildContext context, int index) => SocialItemWidget(
              key: ObjectKey(socialItemList![index]),
              item: socialItemList![index],
              pageStorageKey: "73849" + type!.name + socialItemList!.length.toString() + index.toString(),
            ),
          ),
        ),
      ],
    );
  }
}

class AnnouncementListLargeScreenColumn extends StatelessWidget {
  final AnnouncementSocialIconDataType? type;
  final List<Announcement>? announcementList;

  AnnouncementListLargeScreenColumn({this.type, this.announcementList});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnnouncementAndSocialListSticky(type),
        Expanded(
          child: ListView.builder(
            itemCount: announcementList!.length,
            itemBuilder: (BuildContext context, int index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Fav.design.primaryText.withAlpha(2)),
              child: AnnouncementItem(announcement: announcementList![index]),
            ),
          ),
        ),
      ],
    );
  }
}

enum AnnouncementSocialIconDataType {
  annnouncementUnpublished,
  socialUnpunlished,
  announcementNew,
  socialNew,
  announcementOld,
  socialOld,
}

class AnnouncementAndSocialListSticky extends StatelessWidget {
  final AnnouncementSocialIconDataType? type;

  final Map _values = {
    AnnouncementSocialIconDataType.annnouncementUnpublished: {
      't': 'unpublishedannouncementhint'.translate,
      'c': GlassIcons.announcementIcon.color,
      'art': 'SEND',
      'anim': 'play',
      'i': MdiIcons.messageTextLockOutline,
    },
    AnnouncementSocialIconDataType.announcementOld: {
      't': 'otherannouncement'.translate,
      'c': GlassIcons.announcementIcon.color,
      'art': 'LIST',
      'anim': 'play',
      'i': MdiIcons.listBoxOutline,
    },
    AnnouncementSocialIconDataType.announcementNew: {
      't': 'newannouncement'.translate,
      'c': GlassIcons.announcementIcon.color,
      'art': 'NEW',
      'anim': 'Badge',
      'i': MdiIcons.messageBadgeOutline,
    },
    AnnouncementSocialIconDataType.socialUnpunlished: {
      't': 'unpublishedsocialhint'.translate,
      'c': GlassIcons.social.color,
      'art': 'SEND',
      'anim': 'play',
      'i': MdiIcons.messageTextLockOutline,
    },
    AnnouncementSocialIconDataType.socialOld: {
      't': 'othersocial'.translate,
      'c': GlassIcons.social.color,
      'art': 'LIST2',
      'anim': 'play',
      'i': MdiIcons.listBoxOutline,
    },
    AnnouncementSocialIconDataType.socialNew: {
      't': 'newsocial'.translate,
      'c': GlassIcons.social.color,
      'art': 'NEW2',
      'anim': 'Badge',
      'i': MdiIcons.messageBadgeOutline,
    },
  };

  AnnouncementAndSocialListSticky(this.type);
  @override
  Widget build(BuildContext context) {
    final _val = _values[type];
    final color = _val['c'];
    final text = _val['t'] as String?;
    final artboard = _val['art'];
    final animation = _val['anim'];
    final IconData? icon = _val['i'];

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(color: color.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            icon != null
                ? icon.icon.color(color).make()
                : artboard != null
                    ? RiveSimpeLoopAnimation.asset(
                        url: Assets.rive.ekolRIV,
                        artboard: artboard,
                        animation: animation,
                        width: 32,
                        heigth: 32,
                        changeChildColorMap: {
                          'line': color,
                          'circle1': color,
                          'circle2': color,
                          'Rectangle Path 1': color,
                        },
                      )
                    : SizedBox(height: 32),
            8.widthBox,
            Flexible(child: text.text.color(color).bold.make()),
            8.widthBox,
          ],
        ),
      ),
    ).px12;
  }
}
