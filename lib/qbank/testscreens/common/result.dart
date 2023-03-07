import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../models/models.dart';
import '../../testpage/formpage/chartwidget.dart';

class ResultWidget extends StatelessWidget {
  final int? dogruSayisi, yanlisSayisi, bosSayisi;
  final Kitap? book;
  ResultWidget({this.dogruSayisi, this.yanlisSayisi, this.bosSayisi, this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Fav.secondaryDesign.accent,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8.0, spreadRadius: 3.0)],
        //    image: DecorationImage(image: AssetImage("assets/images/tileleadingkisa.png"),fit: BoxFit.cover)
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12.0),
      child: context.screenHeight > 600
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ChartWidget(
                      ds: dogruSayisi,
                      ys: yanlisSayisi,
                      bs: bosSayisi,
                      mini: false,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "${'ds2'.translate} ",
                                style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0),
                                children: [TextSpan(text: dogruSayisi.toString(), style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                          ),
                          4.heightBox,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "${'ys2'.translate} ",
                                style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0),
                                children: [TextSpan(text: yanlisSayisi.toString(), style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                          ),
                          4.heightBox,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "${'bs2'.translate} ",
                                style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0),
                                children: [TextSpan(text: bosSayisi.toString(), style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                8.heightBox,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          text: "%" + ((dogruSayisi! / (yanlisSayisi! + bosSayisi! + dogruSayisi!)) * 100).floor().toString(),
                          style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 15.0),
                          children: [TextSpan(text: " ${'sucrate'.translate}", style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 13.0))]),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: (dogruSayisi! / (yanlisSayisi! + bosSayisi! + dogruSayisi!)),
                          backgroundColor: Fav.design.primaryText,
                          valueColor: const AlwaysStoppedAnimation(Colors.green /*AppVar.questionPageController.theme.bookColor*/),
                        ))
                  ],
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ChartWidget(
                  ds: dogruSayisi,
                  ys: yanlisSayisi,
                  bs: bosSayisi,
                  mini: true,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            text: "%" + ((dogruSayisi! / (yanlisSayisi! + bosSayisi! + dogruSayisi!)) * 100).floor().toString(),
                            style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 15.0),
                            children: [TextSpan(text: " ${'sucrate'.translate}", style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 13.0))]),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LinearProgressIndicator(
                            value: (dogruSayisi! / (yanlisSayisi! + bosSayisi! + dogruSayisi!)),
                            backgroundColor: Fav.design.primaryText,
                            valueColor: AlwaysStoppedAnimation(book!.primaryColor.parseColor),
                          ))
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "${'ds'.translate} ", style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0), children: [TextSpan(text: dogruSayisi.toString(), style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                    )),
                Expanded(
                    flex: 1,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "${'ys'.translate} ", style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0), children: [TextSpan(text: yanlisSayisi.toString(), style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                    )),
                Expanded(
                    flex: 1,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "${'bs'.translate} ", style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0), children: [TextSpan(text: bosSayisi.toString(), style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                    )),
              ],
            ),
    );
  }
}
