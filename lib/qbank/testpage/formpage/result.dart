// Alt Panel

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../controller/questionpagecontroller.dart';
import '../questionpage/themeservice.dart';
import 'chartwidget.dart';

class ResultTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionPageController questionPageController = AppVar.questionPageController;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ChartWidget(
            ds: questionPageController.dogruSayisi,
            ys: questionPageController.yanlisSayisi,
            bs: questionPageController.bosSayisi,
            mini: true,
          ),
          Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                        text: "%" + ((questionPageController.dogruSayisi / (questionPageController.yanlisSayisi + questionPageController.bosSayisi + questionPageController.dogruSayisi)) * 100).floor().toString(),
                        style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.normal, fontSize: 15.0),
                        children: [TextSpan(text: " ${'sucrate'.translate}", style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.normal, fontSize: 13.0))]),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LinearProgressIndicator(
                        value: (questionPageController.dogruSayisi / (questionPageController.yanlisSayisi + questionPageController.bosSayisi + questionPageController.dogruSayisi)),
                        backgroundColor: const Color(0xffeeeeee),
                        valueColor: const AlwaysStoppedAnimation(Color(0xffEF7463)),
                      ))
                ],
              )),
          Expanded(
              flex: 1,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "${'ds'.translate} ",
                    style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.normal, fontSize: 14.0),
                    children: [TextSpan(text: questionPageController.dogruSayisi.toString(), style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.bold, fontSize: 16.0))]),
              )),
          Expanded(
              flex: 1,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "${'ys'.translate} ",
                    style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.normal, fontSize: 14.0),
                    children: [TextSpan(text: questionPageController.yanlisSayisi.toString(), style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.bold, fontSize: 16.0))]),
              )),
          Expanded(
              flex: 1,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "${'bs'.translate} ",
                    style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.normal, fontSize: 14.0),
                    children: [TextSpan(text: questionPageController.bosSayisi.toString(), style: const TextStyle(color: Color(0xffEF7463), fontWeight: FontWeight.bold, fontSize: 16.0))]),
              )),
        ],
      ),
    );
  }
}

class ResultWidget extends StatelessWidget {
  final int? dogruSayisi, yanlisSayisi, bosSayisi;
  final TestPageThemeModel? theme;
  ResultWidget({this.dogruSayisi, this.yanlisSayisi, this.bosSayisi, this.theme});

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
                                style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 14.0),
                                children: [TextSpan(text: dogruSayisi.toString(), style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                          ),
                          4.heightBox,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "${'ys2'.translate} ",
                                style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 14.0),
                                children: [TextSpan(text: yanlisSayisi.toString(), style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                          ),
                          4.heightBox,
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "${'bs2'.translate} ",
                                style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 14.0),
                                children: [TextSpan(text: bosSayisi.toString(), style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 16.0))]),
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
                          style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 15.0),
                          children: [TextSpan(text: " ${'sucrate'.translate}", style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 13.0))]),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: (dogruSayisi! / (yanlisSayisi! + bosSayisi! + dogruSayisi!)),
                          backgroundColor: AppVar.questionPageController.theme!.primaryTextColor,
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
                            style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 15.0),
                            children: [TextSpan(text: " ${'sucrate'.translate}", style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 13.0))]),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LinearProgressIndicator(
                            value: (dogruSayisi! / (yanlisSayisi! + bosSayisi! + dogruSayisi!)),
                            backgroundColor: AppVar.questionPageController.theme!.primaryTextColor,
                            valueColor: AlwaysStoppedAnimation(AppVar.questionPageController.theme!.bookColor),
                          ))
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "${'ds'.translate} ",
                          style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 14.0),
                          children: [TextSpan(text: dogruSayisi.toString(), style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                    )),
                Expanded(
                    flex: 1,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "${'ys'.translate} ",
                          style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 14.0),
                          children: [TextSpan(text: yanlisSayisi.toString(), style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                    )),
                Expanded(
                    flex: 1,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "${'bs'.translate} ",
                          style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.normal, fontSize: 14.0),
                          children: [TextSpan(text: bosSayisi.toString(), style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 16.0))]),
                    )),
              ],
            ),
    );
  }
}

//// Test biter bitmez ortada
//class ResultWidgetBig extends StatefulWidget {
//
//
//  final OverlayEntry overlayEntry;final int dogruSayisi,yanlisSayisi,bosSayisi;final ThemeModel theme;
//  ResultWidgetBig({this.overlayEntry,this.dogruSayisi,this.yanlisSayisi,this.bosSayisi,this.theme});
//
//  @override
//  ResultWidgetBigState createState() {
//    return   ResultWidgetBigState();
//  }
//}
//
//class ResultWidgetBigState extends State<ResultWidgetBig> with SingleTickerProviderStateMixin{
//
//  AnimationController animationController;
//  Animation animation;
//
//
//  @override
//  void initState() {
//    super.initState();
//    animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 222));
//    animation= Tween(begin: 0.0,end: 1.0).animate(animationController);
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//    animationController.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    animationController.forward();
//
//    return GestureDetector(
//      onTap: () => widget.overlayEntry.remove(),
//      child: Container(
//        alignment: Alignment.center,
//        color: Colors.black12.withAlpha(50),
//        child: AnimatedBuilder(
//          animation: animation,
//          child: Material(
//            color: Colors.transparent,
//            child:   Container(
//              width: 320.0,
//              decoration: BoxDecoration(
//                  color: Colors.white,
//                  borderRadius: BorderRadius.circular(12.0),
//                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10),blurRadius: 8.0,spreadRadius: 3.0)],
//                  image: DecorationImage(image: AssetImage("assets/images/tileleadingkisa.png"),fit: BoxFit.cover)
//              ),
//              padding: EdgeInsets.all(12.0),
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  ChartWidget(ds: widget.dogruSayisi,ys: widget.yanlisSayisi,bs: widget.bosSayisi,mini: false,),
//                  Column(
//                    mainAxisSize: MainAxisSize.min,
//                    children: <Widget>[
//                      RichText(text: TextSpan(text: "%"+((widget.dogruSayisi/(widget.yanlisSayisi+widget.bosSayisi+widget.dogruSayisi))*100).floor().toString(),style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.normal,fontSize: 15.0)
//                          ,children: [TextSpan(text: " başarı",style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.normal,fontSize: 13.0))]),),
//                      Padding(padding:EdgeInsets.symmetric(horizontal: 16.0),child: LinearProgressIndicator(value: (widget.dogruSayisi/(widget.yanlisSayisi+widget.bosSayisi+widget.dogruSayisi)),backgroundColor: Color(0xffeeeeee),valueColor: AlwaysStoppedAnimation(Color(0xffEF7463)),))
//
//                    ],),
//
//                  RichText(textAlign: TextAlign.center,text: TextSpan(text: "DS: ",style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.normal,fontSize: 14.0)
//                      ,children: [TextSpan(text: widget.dogruSayisi.toString(),style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.bold,fontSize: 16.0))]),),
//                  RichText(textAlign: TextAlign.center,text: TextSpan(text: "YS: ",style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.normal,fontSize: 14.0)
//                      ,children: [TextSpan(text: widget.yanlisSayisi.toString(),style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.bold,fontSize: 16.0))]),),
//                  RichText(textAlign: TextAlign.center,text: TextSpan(text: "BS: ",style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.normal,fontSize: 14.0)
//                      ,children: [TextSpan(text: widget.bosSayisi.toString(),style: TextStyle(color: Color(0xffEF7463),fontWeight: FontWeight.bold,fontSize: 16.0))]),),
//
//
//                ],),
//            ),
//          ),
//          builder: (context,child){
//
//            return Opacity(
//              opacity: animation.value,
//              child: Transform.scale(scale: animation.value,child: child),
//            );
//          },
//
//        ),
//      ),
//    );
//  }
//}
