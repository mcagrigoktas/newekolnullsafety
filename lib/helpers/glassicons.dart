// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class GlassIcons {
  GlassIcons._();
  static const String _book = 'assets/images/gicons/book.png';
  static const String _bookmark = 'assets/images/gicons/Bookmark.png';
  static const String _chartpie = 'assets/images/gicons/Chart-pie.png';
  static const String _medicine = 'assets/images/gicons/medicine.png';
  static const String _chat = 'assets/images/gicons/Chat.png';
  static const String _folder = 'assets/images/gicons/Folder.png';
  static const String _heart = 'assets/images/gicons/Heart.png';
  static const String _profile = 'assets/images/gicons/Profile.png';
  static const String _star = 'assets/images/gicons/Star.png';
  static const String _user = 'assets/images/gicons/User.png';
  static const String _video = 'assets/images/gicons/Video.png';
  static const String _docks = 'assets/images/gicons/checklist.png';
  static const String _palette = 'assets/images/gicons/palet.png';
  static const String _person = 'assets/images/gicons/person.png';
  static const String _meal = 'assets/images/gicons/meal.png';
  // static const String _hat = 'assets/images/gicons/Bookmark.png';
  // static const String _timeTable = 'assets/images/gicons/Bookmark.png';
  static const String _videochat = 'assets/images/gicons/videochat.png';
  static const String _document = 'assets/images/gicons/Document.png';
  static const String _cursor = 'assets/images/gicons/cursor.png';
  static const String _timer = 'assets/images/gicons/timer.png';
  static const String _dart = 'assets/images/gicons/dart.png';
  static const String _bag = 'assets/images/gicons/bag.png';
  static const String _tag = 'assets/images/gicons/tag.png';
  static const String _agenda = 'assets/images/gicons/agenda.png';
  static const String _notification = 'assets/images/gicons/notification.png';
  static const String _trash = 'assets/images/gicons/trash.png';
  static const String _timeTable = 'assets/images/gicons/timetable.png';
  static const String _pencil = 'assets/images/gicons/pencil.png';
  static const String _books = 'assets/images/gicons/books.png';
  static const String _exam = 'assets/images/gicons/exam.png';
  static const String _birthday = 'assets/images/gicons/birthday.png';
  static const String _apps = 'assets/images/gicons/apps.png';

  static _GlassIconData get announcementIcon => _GlassIconData(imgUrl: _bookmark, color: const Color(0xffDA9B52));
  static _GlassIconData get messagesIcon => _GlassIconData(imgUrl: _chat, color: const Color(0xff4FB265));
  static _GlassIconData get mealIcon => _GlassIconData(imgUrl: _meal, color: const Color(0xffFD6D64));
  static _GlassIconData get profile => _GlassIconData(imgUrl: _profile, color: const Color(0xff825EEA));
  static _GlassIconData get videoLesson => _GlassIconData(imgUrl: _user, color: const Color(0xffFD6492));
  static _GlassIconData get portfolio => _GlassIconData(imgUrl: _folder, color: const Color(0xff75D7B8));
  static _GlassIconData get social => _GlassIconData(imgUrl: _video, color: const Color(0xffEC6767));
  static _GlassIconData get books => _GlassIconData(imgUrl: _book, color: const Color(0xff1BBBDE));
  static _GlassIconData get books2 => _GlassIconData(imgUrl: _books, color: const Color(0xff7FC0FB));
  static _GlassIconData get liveBroadcastIcon => _GlassIconData(imgUrl: _videochat, color: const Color(0xffFFAB2D));
  static _GlassIconData get stickers => _GlassIconData(imgUrl: _heart, color: const Color(0xffEC6767));
  static _GlassIconData get dailyReport => _GlassIconData(imgUrl: _document, color: const Color(0xff5A7FCF));
  static _GlassIconData get medicine => _GlassIconData(imgUrl: _medicine, color: const Color(0xff9D7CF0));
  static _GlassIconData get cursor => _GlassIconData(imgUrl: _cursor, color: const Color(0xff7879E9));
  static _GlassIconData get timer => _GlassIconData(imgUrl: _timer, color: const Color(0xffF99462));
  static _GlassIconData get education => _GlassIconData(imgUrl: _dart, color: const Color(0xffFE5196));
  static _GlassIconData get tag => _GlassIconData(imgUrl: _tag, color: const Color(0xffDF8A3C));
  static _GlassIconData get timetable2 => _GlassIconData(imgUrl: _timeTable, color: const Color(0xff6B44DB));
  static _GlassIconData get homework => _GlassIconData(imgUrl: _pencil, color: const Color(0xff6B44DB));
  static _GlassIconData get exam => _GlassIconData(imgUrl: _exam, color: const Color(0xff4088F4));

  ///treeview
  static _GlassIconData get favorite => _GlassIconData(imgUrl: _star, color: const Color(0xffF18D65));
  static _GlassIconData get theme => _GlassIconData(imgUrl: _palette);
  static _GlassIconData get account => _GlassIconData(imgUrl: _person);
  static _GlassIconData get users => _GlassIconData(imgUrl: _docks);

  static _GlassIconData get bag => _GlassIconData(imgUrl: _bag, color: Color(0xff61CFC6));

  //?
  static _GlassIconData get agenda => _GlassIconData(imgUrl: _agenda, color: Color(0xffFF6161));
  static _GlassIconData get notifcation => _GlassIconData(imgUrl: _notification, color: Color(0xff46AA6A));
  static _GlassIconData get trash => _GlassIconData(imgUrl: _trash, color: Color(0xffFF6161));
  static _GlassIconData get birthday => _GlassIconData(imgUrl: _birthday, color: Color(0xffF3CF98));
  static _GlassIconData get apps => _GlassIconData(imgUrl: _apps, color: Color(0xffF3CF98));
}

class _GlassIconData {
  final String? imgUrl;
  final Color? color;
  _GlassIconData({this.imgUrl, this.color});
}
