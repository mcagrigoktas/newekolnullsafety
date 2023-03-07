// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../../appbloc/appvar.dart';
import '../../models/models.dart';
import '../secenekname.dart';

class QuestionNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: AppVar.questionPageController.theme!.backgroundColor,
      child: StreamBuilder(
          initialData: true,
          stream: AppVar.questionPageController.isaretlenenCevaplar,
          builder: (context, snapshot) {
            return OpticalForm();
          }),
    );
  }
}

class OpticalForm extends StatelessWidget {
  List<QuestionButton> questionButtons = [];

  @override
  Widget build(BuildContext context) {
    List<String?> isaretlenenCevaplar = AppVar.questionPageController.isaretlenenCevaplarList;
    for (int i = 0; i < isaretlenenCevaplar.length; i++) {
      questionButtons.add(QuestionButton(no: i, isaretliCevap: isaretlenenCevaplar[i]));
    }
    return Container(
      alignment: Alignment.center,
      height: 40,
      margin: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0, top: 4.0),
      decoration: BoxDecoration(color: AppVar.questionPageController.theme!.bottomNavigationBarColor, borderRadius: BorderRadius.circular(8.0), boxShadow: [BoxShadow(color: /*Color(0xffFAFAFA)*/ Colors.grey.withAlpha(75))]),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: questionButtons,
        scrollDirection: Axis.horizontal,
        controller: AppVar.questionPageController.scrollController,
      ),
    );
//       Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: const EdgeInsets.only(left: 4.0, ),
//             width: 36.0,height: 36.0,
//             decoration: BoxDecoration(color: AppVar.questionPageController.theme.bookColor,shape: BoxShape.circle),
//             child: IconButton(
//
//               padding: EdgeInsets.all(0.0),
//               alignment: Alignment.center,
//               iconSize: 24.0,
//               onPressed: (){AppVar.questionPageController.isExpended=true;AppVar.questionPageController.isaretlenenCevaplarSink(true);},
//               icon: Icon(Icons.menu, color: Colors.white,),
//             ),
//           ),
//           Expanded(
//             child: Container(
//             alignment: Alignment.center,
//      height: 40,
//      margin: const EdgeInsets.only(left: 4.0, right: 4.0,bottom: 4.0,top: 4.0),
//      decoration: BoxDecoration(
//      color: AppVar.questionPageController.theme.bottomNavigationBarColor,
//      borderRadius: BorderRadius.circular(8.0),
//      boxShadow: [
//      BoxShadow(color: /*Color(0xffFAFAFA)*/ Colors.grey.withAlpha(75))
//      ]),
//      child: ListView(
//
//             physics: ClampingScrollPhysics(),
//             children: questionButtons,
//             scrollDirection: Axis.horizontal,
//             controller: AppVar.questionPageController.scrollController,),
//
//      ),
//           ),
//         ],
//       );
  }
}

//
//
//class ExpendedOpticalForm extends StatelessWidget {
//
//  List<QuestionButton> questionButtons = [];
//
//  @override
//  Widget build(BuildContext context) {
////AppVar.questionPageController.isExpended=false;AppVar.questionPageController.isaretlenenCevaplarSink(true);
//
//    List<String> isaretlenenCevaplar =
//        AppVar.questionPageController.isaretlenenCevaplarList;
//    for (int i = 0; i < isaretlenenCevaplar.length; i++) {
//      questionButtons.add(new QuestionButton(no: i, isaretliCevap: isaretlenenCevaplar[i]));
//    }
//
//    return Container(
//
//      decoration: BoxDecoration(
//        borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12)),
//          boxShadow: [BoxShadow(color: AppVar.questionPageController.theme.bookColor.withAlpha(10),blurRadius: 1)],
//
//          color: AppVar.questionPageController.theme.bottomNavigationBarColor,
//          //gradient: LinearGradient(colors: [Colors.black.withAlpha(50),AppVar.questionPageController.theme.backgroundColor],begin: Alignment.topCenter,end: Alignment.bottomCenter),
//          image: DecorationImage(image:   AssetImage("assets/images/pattern1${MediaQuery.of(context).orientation == Orientation.portrait ? '':'l'}.png"), fit: BoxFit.cover,)),
//
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//      Container(width: double.infinity,height: 2,decoration: BoxDecoration(
//        border: Border(top: BorderSide(color: AppVar.questionPageController.theme.bookColor,width: 2,style: BorderStyle.solid)),
//      //  borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12))
//      ),),
//
//      Padding(
//        padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
//        child: Row(
//          children: <Widget>[
//            Container(
//              margin: const EdgeInsets.only(left: 4.0, ),
//              width: 36.0,height: 36.0,
//              decoration: BoxDecoration(color: AppVar.questionPageController.theme.bookColor,shape: BoxShape.circle),
//              child: IconButton(
//
//                padding: EdgeInsets.all(0.0),
//                alignment: Alignment.center,
//                iconSize: 24.0,
//                onPressed: (){AppVar.questionPageController.isExpended=false;AppVar.questionPageController.isaretlenenCevaplarSink(true);},
//                icon: Icon(Icons.menu, color: Colors.white,),
//              ),
//            ),
//            Expanded(child: StreamBuilder(initialData: true, stream: AppVar.questionPageController.sure, builder: (context,snapshot){ return ClockWidget();})),
//            RaisedButton(
//              onPressed: !AppVar.questionPageController.testCozuldu ?
//                  (){AppVar.questionPageController.alertTestiKontrolEtSifirla(context,0);}  :
//                  (){AppVar.questionPageController.alertTestiKontrolEtSifirla(context,1);},
//              color: Colors.white,
//              shape: StadiumBorder(),
//              child: Row(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>
//                [Icon(Icons.check_circle,color:  AppVar.questionPageController.theme.bookColor,),
//                  SizedBox(width: 4.0,),
//                  Text(AppVar.questionPageController.testCozuldu ?  'testreset'): 'testfinish'),style: TextStyle(color:  AppVar.questionPageController.theme.bookColor),)
//                ],),),
//          ],
//        ),
//      ),
//
//
//
//      ConstrainedBox(constraints: BoxConstraints(maxHeight: context.screenHeight/4),child: SingleChildScrollView(child: Wrap(children: questionButtons,),)),
//
//      SizedBox(height: 8,),
//          if (AppVar.questionPageController.testCozuldu) ResultWidget(dogruSayisi: AppVar.questionPageController.dogruSayisi,yanlisSayisi: AppVar.questionPageController.yanlisSayisi,bosSayisi: AppVar.questionPageController.bosSayisi,theme: AppVar.questionPageController.theme,),
//
//
//          SizedBox(height: 8,),
//    ],),);
//  }
//}
//
//

class QuestionButton extends StatelessWidget {
  final int? no;
  final String? isaretliCevap;
  Color? color;

  QuestionButton({this.no, this.isaretliCevap, this.color});

  @override
  Widget build(BuildContext context) {
    color = AppVar.questionPageController.secilenSoruIndex == no ? AppVar.questionPageController.theme!.bottomNavigationTextColor : Colors.transparent;

    Widget secenekName;

    if (AppVar.questionPageController.secilenSoruIndex == no) {
      secenekName = SecenekName(
        name: isaretliCevap,
        emptyColor: color,
        textColor: AppVar.questionPageController.theme!.bottomNavigationTextColor,
        backgroundColor: AppVar.questionPageController.theme!.bottomNavigationBarColor,
      );
    } else {
      secenekName = SecenekName(
        name: isaretliCevap,
        emptyColor: color,
        textColor: AppVar.questionPageController.theme!.bottomNavigationTextColor,
        backgroundColor: AppVar.questionPageController.theme!.bottomNavigationBarColor,
      );
    }

    Widget current = Container(
      height: 28,
      width: 58.0, // questionpagebloc autoscroll aşağıdaki marginin 2 katı kadar fazlası olmalı
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppVar.questionPageController.secilenSoruIndex == no ? AppVar.questionPageController.theme!.bookColor! : Colors.transparent),
        color: AppVar.questionPageController.theme!.passiveQuestionBgColor,
        borderRadius: BorderRadius.circular(10.8),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4.0, spreadRadius: 2.0)],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "${(no! + 1)}- ",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppVar.questionPageController.secilenSoruIndex == no ? AppVar.questionPageController.theme!.bottomNavigationTextColor : AppVar.questionPageController.theme!.bottomNavigationTextColor, fontSize: 14.4),
          ),
          secenekName,
        ],
      ),
    );

    if (AppVar.questionPageController.testCozuldu!) {
      IconData iconData;
      Color iconColor;
      if (isaretliCevap == " ") {
        iconData = Icons.remove;
        iconColor = Colors.white.withAlpha(0);
      }
      //todo ilerde navigation bbarda soru  tiplerine gore butonun nasil gozukecegini tekrar yaz
      else if (AppVar.questionPageController.getTest!.questions[no!].questionType != QuestionType.SECENEKLI) {
        iconData = Icons.remove;
        iconColor = Colors.white.withAlpha(0);
      } else if (isaretliCevap == AppVar.questionPageController.getTest!.questions[no!].answer.option) {
        iconData = Icons.check;
        iconColor = Colors.greenAccent;
      } else {
        iconData = Icons.clear;
        iconColor = Colors.redAccent;
      }

      current = Stack(
        children: <Widget>[
          current,
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppVar.questionPageController.secilenSoruIndex == no ? AppVar.questionPageController.theme!.bookColor! : Colors.transparent),
                color: iconColor.withAlpha(50),
                borderRadius: BorderRadius.circular(10.8),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4.0, spreadRadius: 2.0)],
              ),
              alignment: Alignment.center,
              width: 58,
              height: 28,
              child: Icon(
                iconData,
                color: iconColor,
              )),
        ],
      );
    }

    return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        splashColor: AppVar.questionPageController.theme!.primaryTextColor!.withAlpha(150),
        onTap: () => AppVar.questionPageController.clickQuestion(no),
        onLongPress: () {
          //  if (AppVar.questionPageController.secilenSoruIndex == no) {
          AppVar.questionPageController.deleteSecenek(no);
          //   }
        },
        child: current);
  }
}
// class QuestionButton extends StatelessWidget {
//  final int no;
//  final String isaretliCevap;
//  Color color;
//
//  QuestionButton({this.no, this.isaretliCevap, this.color});
//
//  @override
//  Widget build(BuildContext context) {
//
//
//
//    QuestionPageBloc questionPageBloc = AppVar.questionPageController;
//
//    color = questionPageBloc.secilenSoruIndex ==no ? questionPageBloc.theme.bottomNavigationTextColor : Colors.transparent;
//
//
//    Widget secenekName;
//
//
//    if(questionPageBloc.secilenSoruIndex == no){
//      secenekName = SecenekName(name: isaretliCevap, emptyColor: color,textColor: AppVar.questionPageController.theme.bottomNavigationTextColor,backgroundColor: AppVar.questionPageController.theme.bottomNavigationBarColor,);
//    }else{
//      secenekName = SecenekName(name: isaretliCevap, emptyColor: color,textColor: AppVar.questionPageController.theme.bottomNavigationTextColor,backgroundColor: AppVar.questionPageController.theme.bottomNavigationBarColor,  );
//    }
//
//    Icon resultIcon;
//    if(questionPageBloc.testCozuldu ){
//      if(isaretliCevap == " "){
//        resultIcon = Icon(Icons.blur_circular,color: questionPageBloc.secilenSoruIndex == no ?questionPageBloc.theme.primaryTextColor :questionPageBloc.theme.bottomNavigationTextColor,size: 16.0,);
//      }else if(isaretliCevap == questionPageBloc.getTest.questions[no].answer.option){
//        resultIcon = Icon(Icons.check_circle,color: questionPageBloc.secilenSoruIndex == no ?questionPageBloc.theme.primaryTextColor :questionPageBloc.theme.bottomNavigationTextColor,size: 16.0,);
//      }else {
//        resultIcon =  Icon(Icons.cancel,color: questionPageBloc.secilenSoruIndex == no ?questionPageBloc.theme.primaryTextColor :questionPageBloc.theme.bottomNavigationTextColor,size: 16.0,);
//      }
//    }
//
//
//
//
//    return Container(
//      height: 28,
//      width: questionPageBloc.testCozuldu ? 78.0 : 58.0, // questionpagebloc autoscroll aşağıdaki marginin 2 katı kadar fazlası olmalı
//      margin: EdgeInsets.symmetric(horizontal: 6.0,vertical: 6.0),
//      padding: EdgeInsets.symmetric(horizontal: 4.0,vertical: 0.0),
//      decoration: BoxDecoration(
//        border: Border.all(color: questionPageBloc.secilenSoruIndex ==no ? questionPageBloc.theme.bookColor : Colors.transparent),
//        color:  questionPageBloc.theme.passiveQuestionBgColor ,
//        borderRadius: BorderRadius.circular(10.8),
//        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10),blurRadius: 4.0,spreadRadius: 2.0)],
//      ),
//
//      child: InkWell(
//        borderRadius: BorderRadius.all(Radius.circular(18.0)),
//        splashColor: questionPageBloc.theme.primaryTextColor.withAlpha(150),
//        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text("${(no+1)}- ",
//              style: TextStyle(
//                  fontWeight: FontWeight.bold,
//                  color: questionPageBloc.secilenSoruIndex == no ? questionPageBloc.theme.bottomNavigationTextColor :questionPageBloc.theme.bottomNavigationTextColor,
//                  fontSize: 14.4),),
//            secenekName,
//            questionPageBloc.testCozuldu ? Padding(padding: const EdgeInsets.only(left:4.0), child: resultIcon,) : Container()
//          ],
//        ),
//        onTap: () => AppVar.questionPageController.clickQuestion(no,context),
//        onLongPress:  (){if(questionPageBloc.secilenSoruIndex == no){AppVar.questionPageController.clickSecenek(" ",context);}
//
//        },
//      ) ,
//    );
//
//
//
//
//  }
//}
