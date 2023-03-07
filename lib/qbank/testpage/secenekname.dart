// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../appbloc/appvar.dart';

class SecenekName extends StatelessWidget {
  final int? incomingMenu; //1 Soru içinden
  final String? name;
  final Color? emptyColor;
  Color? backgroundColor;
  final Color? textColor;

  SecenekName({this.incomingMenu, this.name, this.emptyColor, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (name == "A") {
      color = const Color(0xff519ECE);
    } else if (name == "B") {
      color = const Color(0xffDC5A2C);
    } else if (name == "C") {
      color = const Color(0xff93B63E);
    } else if (name == "D") {
      color = const Color(0xffE7B342);
    } else if (name == "E") {
      color = const Color(0xff8155F6);
    } else if (name == "G") {
      color = Colors.transparent;
    } else if (name == " ") {
      color = emptyColor;
    }

    backgroundColor ??= AppVar.questionPageController.theme!.bottomNavigationTextColor;

    if (incomingMenu != null) {
      // Seçenek Eleme Yapabiliyor
      return Container(
        width: 21,
        height: 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: name != "G"
            ? Text(
                name!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
              )
            : const SizedBox(),
      );
    } else {
      if (name == " ") {
        return Container(
          alignment: Alignment.center,
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            "-",
            style: TextStyle(color: color),
          ),
        );
      }
      return CircleAvatar(
        backgroundColor: color,
        child: Text(
          name!,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
        ),
        radius: 10.0,
      );
    }
  }
}

class SecenekKontrol extends StatelessWidget {
  final int? durum;
  final double? size;
  final bool? white; // Result bölümünde beyaz verebilmek için

  SecenekKontrol({this.durum, this.size, this.white});

  @override
  Widget build(BuildContext context) {
    if (durum == 0) {
      return Icon(
        Icons.remove_circle,
        color: white != null ? Colors.white : Colors.grey,
        size: size,
      );
    } else if (durum == 1) {
      return Icon(Icons.cancel, color: white != null ? Colors.white : const Color(0xffFF4B36), size: size);
    } else {
      return Icon(Icons.check_circle, color: white != null ? Colors.white : const Color(0xff59D654), size: size);
    }
  }
}
