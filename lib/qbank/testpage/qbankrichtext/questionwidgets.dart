import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/youtube_player/youtube_player_shared.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../models/models.dart';
import '../questionpage/fulllayouthelper/pdf/crop_pdf_view/pdfquestionview.dart';
import '../widgets/savedimage.dart';
import 'myrichtext.dart';

class QuestionWidget {
  dynamic questionWidget({required QuestionRow data, widgetSpan = false, alignment = PlaceholderAlignment.middle, textColor, double? fontSize}) {
    alignment = PlaceholderAlignment.middle;
    TextBaseline? baseLine;
    fontSize ??= Fav.preferences.getDouble("yaziBoyutu") ?? 14.0;

    Widget? current;
    if (data.type == 100) {
      current = Type100(data: data, textColor: textColor);
    } else if (data.type == 101) {
      current = Type101(data: data);
    } else if (data.type == 102) {
      current = Type102(data: data, textColor: textColor);
    } else if (data.type == 103) {
      current = Type103(data: data, textColor: textColor);
    } else if (data.type == 104) {
      current = Type104(data: data);
    } else if (data.type == 220) {
      current = Type220(data: data, textColor: textColor);
      alignment = PlaceholderAlignment.baseline;
      baseLine = TextBaseline.alphabetic;
    } else if (data.type == 230) {
      current = Type230(data: data, textColor: textColor);
    } else if (data.type == 231) {
      current = Type231(data: data, textColor: textColor);
    } else if (data.type == 250) {
      current = Type250(
        data: data,
        textColor: textColor,
        key: Key('Type250${AppVar.questionPageController.secilenSoruIndex}'),
      );
    } else if (data.type == 255) {
      current = Type255(data: data, textColor: textColor);
    } else if (data.type == 500) {
      current = Type500(data: data, textColor: textColor, tur: 1);
    } else if (data.type == 501) {
      current = Type500(data: data, textColor: textColor, tur: 2);
    } else if (data.type == 502) {
      current = Type500(data: data, textColor: textColor, tur: 3);
    } else if (data.type == 503) {
      current = Type500(data: data, textColor: textColor, tur: 4);
    } else if (data.type == 504) {
      current = Type500(data: data, textColor: textColor, tur: 5);
    } else if (data.type == 505) {
      current = Type505(data: data, textColor: textColor);
    } else if (data.type == 510) {
      current = Type510(data: data, textColor: textColor, fontSize: fontSize);
    } else if (data.type == 530) {
      current = Type530(data: data, textColor: textColor, tur: 1);
      alignment = PlaceholderAlignment.baseline;
      baseLine = TextBaseline.alphabetic;
    } else if (data.type == 531) {
      current = Type530(data: data, textColor: textColor, tur: 2);
      alignment = PlaceholderAlignment.baseline;
      baseLine = TextBaseline.alphabetic;
    } else if (data.type == 532) {
      current = Type530(data: data, textColor: textColor, tur: 3);
      alignment = PlaceholderAlignment.baseline;
      baseLine = TextBaseline.alphabetic;
    } else if (data.type == 533) {
      current = Type530(data: data, textColor: textColor, tur: 4);
      alignment = PlaceholderAlignment.baseline;
      baseLine = TextBaseline.alphabetic;
    } else if (data.type == 550) {
      current = Type550(data: data, textColor: textColor);
      alignment = PlaceholderAlignment.middle;
      /*baseLine= TextBaseline.alphabetic;*/
    } else if (data.type == 551) {
      current = Type551(data: data, textColor: textColor);
      alignment = PlaceholderAlignment.baseline;
      baseLine = TextBaseline.alphabetic;
    } else if (data.type == 552) {
      current = Type552(data: data, textColor: textColor, tur: 1);
      alignment = PlaceholderAlignment.middle;
      /*baseLine= TextBaseline.alphabetic;*/
    } else if (data.type == 553) {
      current = Type552(data: data, textColor: textColor, tur: 2);
      alignment = PlaceholderAlignment.middle;
      /*baseLine= TextBaseline.alphabetic;*/
    } else if (data.type == 554) {
      current = Type554(data: data, textColor: textColor);
      alignment = PlaceholderAlignment.middle;
      /*baseLine= TextBaseline.alphabetic;*/
    } else if (data.type == 25) {
      current = Type25(data: data);
    }

    if (widgetSpan == false) {
      return current;
    }
    return WidgetSpan(child: current!, baseline: baseLine, alignment: alignment);
  }
}

class Type100 extends StatelessWidget {
// Sadece Text olan data
  final QuestionRow? data;
  final Color? textColor;
  Type100({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    return MyRichText(
      text: data!.text,
      textColor: textColor,
    );
  }
}

class Type101 extends StatelessWidget {
  final QuestionRow? data;
  Type101({this.data});

  @override
  Widget build(BuildContext context) {
    var align = (data!.widgetData ?? {})['align'] ?? 'center';

    return Align(
      alignment: align == 'left' ? Alignment.centerLeft : (align == 'right' ? Alignment.centerRight : Alignment.center),
      child: data!.imageRate == null
          ? SizedBox(
              child: QuestionImage(
                imgCode: data!.image,
                temaRengi: data!.imageSingleColor == true || (data!.widgetData ?? {})['imageSingleColor'] == true ? AppVar.questionPageController.theme!.questionTextColor : null,
              ),
              width: data!.widgetData['imageSize'].toDouble(),
            )
          : FractionallySizedBox(
              child: QuestionImage(
                imgCode: data!.image,
                temaRengi: data!.imageSingleColor == true || (data!.widgetData ?? {})['imageSingleColor'] == true ? AppVar.questionPageController.theme!.questionTextColor : null,
              ),
              alignment: Alignment.center,
              widthFactor: data!.imageRate! / 5 * (AppVar.questionPageController.tablet ? 0.6 : 1),
            ),
    );
  }
}

class Type103 extends StatelessWidget with QuestionWidget {
  // Solda resim sagda yazu
  final QuestionRow? data;
  final Color? textColor;
  Type103({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: data!.widget == null
              ? MyRichText(
                  text: data!.text,
                  textColor: textColor,
                )
              : questionWidget(data: QuestionRow.fromJson(data!.widget!)),
          flex: AppVar.questionPageController.tablet ? (8 - data!.imageRate!) : (5 - data!.imageRate!),
        ),
        if (data!.image != null)
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: data!.type == 102 ? 0.0 : 4.0, right: data!.type == 102 ? 4.0 : 0.0),
                child: QuestionImage(
                  imgCode: data!.image,
                  temaRengi: data!.imageSingleColor == true ? AppVar.questionPageController.theme!.questionTextColor : null,
                )),
            flex: data!.imageRate!,
          )
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }
}

class Type104 extends StatelessWidget with QuestionWidget {
  // Solda resim sagda yazu
  final QuestionRow? data;
  Type104({this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: data!.youtubeVideo.safeLength > 6
            ? SizedBox(width: 300, height: 168, child: MyYoutubeWidget(data!.youtubeVideo!))
            : SizedBox(
                width: context.screenWidth.clamp(100.0, 400.0),
                height: context.screenWidth.clamp(100.0, 400.0) / 16 * 9,
                child: MyVideoPlay(
                  isActiveDownloadButton: false,
                  url: data!.widgetData['Video'],
                  cacheVideo: false,
                  isFullScreen: false,
                  key: Key(data!.widgetData['Video']),
                  //  thumb: '',
                )));
  }
}

class Type102 extends StatelessWidget with QuestionWidget {
  // sagda resim solda yazu
  final QuestionRow? data;
  final Color? textColor;
  Type102({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (data!.image != null)
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: data!.type == 102 ? 0.0 : 4.0, right: data!.type == 102 ? 4.0 : 0.0),
                child: QuestionImage(
                  imgCode: data!.image,
                  temaRengi: data!.imageSingleColor == true ? AppVar.questionPageController.theme!.questionTextColor : null,
                )),
            flex: data!.imageRate!,
          ),
        Expanded(
          child: data!.widget == null
              ? MyRichText(
                  text: data!.text,
                  textColor: textColor,
                )
              : questionWidget(data: QuestionRow.fromJson(data!.widget!)),
          flex: AppVar.questionPageController.tablet ? (8 - data!.imageRate!) : (5 - data!.imageRate!),
        ),
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }
}

class Type220 extends StatelessWidget {
  // Alti numaralandirilmis kelime
  final QuestionRow? data;
  final Color? textColor;
  Type220({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        children: <Widget>[
          // Text('Heyyy'),
          MyRichText(text: data!.widgetData['text'], textColor: textColor),
          Container(color: textColor, height: 2),
          //  Text('Heyyy'),
          MyRichText(text: data!.widgetData['subText'], textColor: textColor),
        ],
      ),
    );
  }
}

class Type230 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  Type230({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    (data!.widgetData as List).forEach((item) {
      if (item is String) {
        children.add(MyRichText(
          text: item,
          textColor: textColor,
        ));
      } else if (item is Map) {
        children.add(questionWidget(data: QuestionRow(type: item['type'], widgetData: item['data']), textColor: textColor)
            //   questionWidget(data: QuestionRow.fromJson(item),textColor: textColor)
            );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class Type231 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  Type231({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment alignment = data!.widgetData['align'] == 'top' ? CrossAxisAlignment.start : (data!.widgetData['align'] == 'bottom' ? CrossAxisAlignment.end : CrossAxisAlignment.center);
    final List<Widget> children = [];

    (data!.widgetData['widgets'] as List).forEach((item) {
      if (item is String) {
        children.add(MyRichText(
          text: item,
          textColor: textColor,
        ));
      } else if (item is Map) {
        children.add(questionWidget(data: QuestionRow(type: item['type'], widgetData: item['data']), textColor: textColor)
            //   questionWidget(data: QuestionRow.fromJson(item),textColor: textColor)
            );
      }
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: children,
    );
  }
}

class Type500 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  final int? tur;
  Type500({this.data, this.textColor, this.tur});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final fontScale = AppVar.questionPageController.fontSize! / 16;
    late String assetData;
    late double height;
    if (tur == 1) {
      assetData = Assets.latex.dotPNG;
      height = 4.0;
    } else if (tur == 2) {
      assetData = Assets.latex.existsPNG;
      height = 16.0;
    } else if (tur == 3) {
      assetData = Assets.latex.forallPNG;
      height = 16.0;
    } else if (tur == 4) {
      assetData = Assets.latex.veePNG;
      height = 16.0;
    } else if (tur == 5) {
      assetData = Assets.latex.wedgePNG;
      height = 16.0;
    }

    return Image.asset(
      assetData,
      height: height * data!.widgetData['size'],
      /*width:4.0*data.widgetData['size'],*/ color: textColor,
      fit: BoxFit.fill,
    );
  }
}

class Type505 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  Type505({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final rootText = data!.widgetData['root'];
    final number = data!.widgetData['number'];
    final widget = data!.widgetData['widget'];
    final fontScale = AppVar.questionPageController.fontSize! / 16;

    return Padding(
      padding: const EdgeInsets.only(),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (rootText == null)
              Container(
                margin: const EdgeInsets.only(left: 1.0),
                width: fontScale * 7,
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.latex.squarerootPNG), fit: BoxFit.fill, colorFilter: ColorFilter.mode(textColor!, BlendMode.srcIn))),
              ),
            if (rootText != null)
              Stack(
                children: <Widget>[
                  Text(
                    rootText,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: AppVar.questionPageController.fontSize! / 2),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: rootText.length < 2 ? 3.0 : AppVar.questionPageController.fontSize! * 0.45),
                    width: fontScale * 7,
                    decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.latex.squarerootPNG), fit: BoxFit.fill, colorFilter: ColorFilter.mode(textColor!, BlendMode.srcIn))),
                  ),
                ],
              ),
            Container(
              padding: const EdgeInsets.only(left: 2),
              child: number != null
                  ? MyRichText(
                      text: number,
                      textColor: textColor,
                    )
                  : questionWidget(data: QuestionRow(type: widget['type'], widgetData: widget['data']), textColor: textColor),
              decoration: ShapeDecoration(
                  shape: Border(
                top: BorderSide(color: textColor!, width: fontScale * 1.3),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class Type510 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  final double? fontSize;
  Type510({this.data, this.textColor, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final pay = data!.widgetData['top'];

    final payda = data!.widgetData['bottom'];
    final fontScale = AppVar.questionPageController.fontSize! / 16;

    return IntrinsicWidth(
      child: Padding(
        padding: EdgeInsets.only(top: 1.5 * fontScale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            pay is String
                ? MyRichText(text: pay, textColor: textColor, fontSize: fontSize)
                : questionWidget(
                    data: QuestionRow(
                      type: pay['type'],
                      widgetData: pay['data'],
                    ),
                    textColor: textColor,
                    fontSize: fontSize),
            Container(
              color: textColor,
              height: 1.3 * fontScale,
            ),
            payda is String ? MyRichText(text: payda, textColor: textColor, fontSize: fontSize) : questionWidget(data: QuestionRow(type: payda['type'], widgetData: payda['data']), textColor: textColor, fontSize: fontSize),
          ],
        ),
      ),
    );
  }
}

class Type530 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  final int tur;
  Type530({this.data, this.textColor, this.tur = 1});

  @override
  Widget build(BuildContext context) {
    final fontScale = AppVar.questionPageController.fontSize! / 16;
    late String assetData;
    if (tur == 1) {
      assetData = Assets.latex.widehatPNG;
    } else if (tur == 2) {
      assetData = Assets.latex.trianglePNG;
    } else if (tur == 3) {
      assetData = Assets.latex.overrightarrowPNG;
    } else if (tur == 4) {
      assetData = Assets.latex.overarcPNG;
    }

    return IntrinsicWidth(
      child: Column(
        children: <Widget>[
          Container(
            height: 6 * fontScale,
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(assetData), fit: BoxFit.fill, colorFilter: ColorFilter.mode(textColor!, BlendMode.srcIn))),
          ),
          Text(
            data!.widgetData['text'],
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: AppVar.questionPageController.fontSize,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Type550 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;

  Type550({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final fontScale = AppVar.questionPageController.fontSize! / 16;

    final top = data!.widgetData['top'];
    final bottom = data!.widgetData['bottom'];

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 5.0 * fontScale),
          child: Image.asset(
            Assets.latex.integralPNG,
            height: 40.0 * fontScale,
            width: 15.0 * fontScale,
            color: textColor,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 16.0 * fontScale),
            child: top is String ? MyRichText(text: top, textColor: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.65) : questionWidget(data: QuestionRow(type: top['type'], widgetData: top['data']), textColor: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.65)),
        Container(
          padding: EdgeInsets.only(top: 30.0 * fontScale, left: 9.0 * fontScale),
          child: bottom is String
              ? MyRichText(text: bottom, textColor: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.65)
              : questionWidget(data: QuestionRow(type: bottom['type'], widgetData: bottom['data']), textColor: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.65),
        ),
      ],
    );
  }
}

class Type551 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;

  Type551({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final fontScale = AppVar.questionPageController.fontSize! / 16;

    final left = data!.widgetData['left'];
    final right = data!.widgetData['right'];

    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Text(
          "lim",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: AppVar.questionPageController.fontSize),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0 * fontScale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                left,
                textAlign: TextAlign.start,
                style: TextStyle(color: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.85),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.0 * fontScale),
                child: Image.asset(
                  Assets.latex.overrightarrowPNG,
                  height: 7.0 * fontScale,
                  width: 12.0 * fontScale,
                  color: textColor,
                ),
              ),
              right is String ? MyRichText(text: right, textColor: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.65) : questionWidget(data: QuestionRow(type: right['type'], widgetData: right['data']), textColor: textColor, fontSize: AppVar.questionPageController.fontSize! * 0.65)
            ],
          ),
        ),
      ],
    );
  }
}

class Type552 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;
  final int? tur;

  Type552({this.data, this.textColor, this.tur});

  @override
  Widget build(BuildContext context) {
    late String assetData;
    if (tur == 1) {
      assetData = Assets.latex.toplamPNG;
    } else if (tur == 2) {
      assetData = Assets.latex.carpimPNG;
    }

    final fontScale = AppVar.questionPageController.fontSize! / 16;

    final top = data!.widgetData['top'];
    final bottom = data!.widgetData['bottom'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          top,
          textAlign: TextAlign.start,
          style: TextStyle(color: textColor, fontSize: 11.0 * fontScale),
        ),
        Image.asset(
          assetData,
          height: 40.0 * fontScale,
          width: 30.0 * fontScale,
          color: textColor,
        ),
        Text(
          bottom,
          textAlign: TextAlign.start,
          style: TextStyle(color: textColor, fontSize: 11.0 * fontScale),
        ),
      ],
    );
  }
}

class Type554 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;

  Type554({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final fontScale = AppVar.questionPageController.fontSize! / 16;

    final top = data!.widgetData['top'];
    final bottom = data!.widgetData['bottom'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          Assets.latex.leftpPNG,
          height: 40.0 * fontScale,
          width: 8.0 * fontScale,
          color: textColor,
        ),
        Column(
          children: <Widget>[
            Text(
              top,
              textAlign: TextAlign.start,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15.0 * fontScale),
            ),
            SizedBox(
              height: 6.0 * fontScale,
            ),
            Text(
              bottom,
              textAlign: TextAlign.start,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15.0 * fontScale),
            ),
          ],
        ),
        Image.asset(
          Assets.latex.rightpPNG,
          height: 40.0 * fontScale,
          width: 8.0 * fontScale,
          color: textColor,
        ),
      ],
    );
  }
}

class Type250 extends StatefulWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;

  Type250({this.data, this.textColor, key}) : super(key: key);

  @override
  _Type250State createState() => _Type250State();
}

class _Type250State extends State<Type250> with QuestionWidget {
  bool? isVisible;

  @override
  Widget build(BuildContext context) {
    final warning = widget.data!.widgetData['warning'];
    final text = widget.data!.widgetData['text'];
    final detailWidget = widget.data!.widgetData['widget'];

    isVisible ??= widget.data!.widgetData['isVisible'] ?? true;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 333),
      child: isVisible!
          ? Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Fav.secondaryDesign.accent.withAlpha(180), borderRadius: BorderRadius.circular(8.0), boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), spreadRadius: 1.0, blurRadius: 2)]),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.info,
                          color: widget.textColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible!;
                          });
                        },
                      ),
                      Expanded(
                          child: MyRichText(
                        textColor: widget.textColor,
                        text: warning,
                      )),
                      8.widthBox,
                    ],
                  ),
                ),
                8.heightBox,
                if (text != null)
                  Align(
                      alignment: Alignment.topLeft,
                      child: MyRichText(
                        textColor: widget.textColor,
                        text: text,
                      )),
                if (detailWidget != null) questionWidget(data: QuestionRow(type: detailWidget['type'], widgetData: detailWidget['data']), textColor: widget.textColor),
              ],
            )
          : Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.info,
                  color: widget.textColor,
                ),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible!;
                  });
                },
              )),
    );
  }
}

class Type255 extends StatelessWidget with QuestionWidget {
  // Column
  final QuestionRow? data;
  final Color? textColor;

  Type255({this.data, this.textColor});

  @override
  Widget build(BuildContext context) {
    final text = data!.widgetData['text'];
    final detailWidget = data!.widgetData['widget'];
    final bgColor = data!.widgetData['bgColor'];

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(color: bgColor == null ? Fav.secondaryDesign.accent.withAlpha(125) : Color(int.parse('0xff$bgColor')).withAlpha(125), borderRadius: BorderRadius.circular(8.0), boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), spreadRadius: 1.0, blurRadius: 2)]),
          child: Row(
            children: <Widget>[
              if (text != null)
                Expanded(
                    child: MyRichText(
                  textColor: textColor,
                  text: text,
                )),
              if (text != null && detailWidget != null) 8.widthBox,
              if (detailWidget != null) questionWidget(data: QuestionRow(type: detailWidget['type'], widgetData: detailWidget['data']), textColor: textColor),
            ],
          ),
        ),
      ],
    );
  }
}

///Pdf ten kesilen parca
class Type25 extends StatelessWidget {
  final QuestionRow? data;

  Type25({this.data});

  @override
  Widget build(BuildContext context) {
    //  p.info(data.widgetData);
    // return Container(color: Colors.red, height: 500, width: 500);
    return Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          gradient: AppVar.questionPageController.theme!.questionBgGradient,
          boxShadow: [BoxShadow(blurRadius: 4.0, color: AppVar.questionPageController.theme!.questionBgShadowColor!)],
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        ),
        margin: const EdgeInsets.all(8.0),
        child: PdfQuestionView(
          key: Key('MainBookLet${AppVar.questionPageController.secilenSoruIndex}'),
          initialPage: data!.widgetData['page'],
          leftTopX: data!.widgetData['left'],
          leftTopY: data!.widgetData['top'],
          rightBottomX: data!.widgetData['right'],
          rightBottomY: data!.widgetData['bottom'],
          document: AppVar.questionPageController.pdfDocument,
          viewPort: 3,
        ));
  }
}
