import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../formpage/clock.dart';
import '../formpage/result.dart';
import 'questionnavigationbar.dart';

class QBankDrawer extends StatelessWidget {
  QBankDrawer();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        initialData: true,
        stream: AppVar.questionPageController.isaretlenenCevaplar,
        builder: (context, snapshot) {
          List<QuestionButton> questionButtons = [];
          List<String?> isaretlenenCevaplar = AppVar.questionPageController.isaretlenenCevaplarList;
          for (int i = 0; i < isaretlenenCevaplar.length; i++) {
            questionButtons.add(QuestionButton(no: i, isaretliCevap: isaretlenenCevaplar[i]));
          }

          return Container(
            color: AppVar.questionPageController.theme!.backgroundColor,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height: context.screenHeight > 600 ? 8 : 4),
                  Text(
                    AppVar.questionPageController.getTest!.name!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppVar.questionPageController.theme!.bookColor, fontSize: 18),
                  ),
                  SizedBox(height: context.screenHeight > 600 ? 8 : 4),
                  if (context.screenHeight > 600 && (AppVar.questionPageController.getTest!.aciklama ?? '').isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppVar.questionPageController.getTest!.aciklama!,
                          style: TextStyle(color: AppVar.questionPageController.theme!.bookColor!.withAlpha(200), fontSize: 14),
                        )),
                  if (context.screenHeight > 600 && (AppVar.questionPageController.getTest!.aciklama ?? '').isNotEmpty) 8.heightBox,
                  //todo Asagidaki mutlaka kaldirilmali widget span web te  calismadigi ici  kondu
                  if (!kIsWeb) StreamBuilder(initialData: true, stream: AppVar.questionPageController.sure, builder: (context, snapshot) => ClockWidget()),
                  if (AppVar.questionPageController.testCozuldu!)
                    ResultWidget(
                      dogruSayisi: AppVar.questionPageController.dogruSayisi,
                      yanlisSayisi: AppVar.questionPageController.yanlisSayisi,
                      bosSayisi: AppVar.questionPageController.bosSayisi,
                      theme: AppVar.questionPageController.theme,
                    ),
                  if (AppVar.questionPageController.testCozuldu!) 8.heightBox,
                  Text(
                    'clearanswerhint'.translate,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor!.withAlpha(150), fontSize: 12),
                  ),
                  8.heightBox,
                  Expanded(child: SingleChildScrollView(child: Wrap(children: questionButtons))),
                  SizedBox(height: context.screenHeight > 600 ? 8 : 4),
                  if (!AppVar.questionPageController.kitapBilgileri.isDeneme)
                    MyRaisedButton(
                      onPressed: !AppVar.questionPageController.testCozuldu!
                          ? () {
                              AppVar.questionPageController.alertTestiKontrolEtSifirla(context, 0);
                            }
                          : () {
                              AppVar.questionPageController.alertTestiKontrolEtSifirla(context, 1);
                            },
                      iconData: Icons.check_circle,
                      text: AppVar.questionPageController.testCozuldu! ? 'testreset'.translate : 'testfinish'.translate,
                    ),
                  SizedBox(height: context.screenHeight > 600 ? 16 : 4),
                ],
              ),
            ),
          );
        });
  }
}
