// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../models/models.dart';
import '../../testpage/controller/questionpagecontroller.dart';
import '../../testpage/senddenemeresult.dart';
import '../../testpage/testpage.dart';
import '../../testscreens/common/model.dart';
import '../../testscreens/pdfbook/controller.dart';
import '../../testscreens/pdfbook/layout.dart';
import '../../testscreens/pdfbookwithoptic/controller.dart';
import '../../testscreens/pdfbookwithoptic/layout.dart';
import 'statisticspage.dart';
import 'teststatistics.dart';

class BooksPreviewPage extends StatefulWidget {
  final IcindekilerModel? icindekilerModel;
  final Kitap? kitap;
  final bool debug;

  /// Qbankta deneme testlerini bedava acmak icin
  final bool isTry;
  BooksPreviewPage({this.icindekilerModel, this.kitap, this.debug = false, this.isTry = false});

  @override
  BooksPreviewPageState createState() {
    return BooksPreviewPageState();
  }
}

class BooksPreviewPageState extends State<BooksPreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _testeGec(IcindekilerItem item) async {
    if (item.isPdfKAPage) {
      await Fav.to(PdfBook(),
          binding: BindingsBuilder(() => Get.put<PdfBookController>(PdfBookController(
                startPageForPdf: item.startPageForPdf,
                endPageForPdf: item.endPageForPdf,
                pdfUrl: widget.icindekilerModel!.pdfUrl,
              ))));
    } else if (item.isPdfSBPage) {
      await Fav.to(PdfBookWithOptic(), binding: BindingsBuilder(() => Get.put<PdfBookWithOpticController>(PdfBookWithOpticController(book: widget.kitap, icindekilerItem: item, icindekilerModel: widget.icindekilerModel))));
    } else {
      if (Fav.noConnection()) return;

      final _controller = QuestionPageController(debug: widget.debug, testKey: item.testKey, testVersion: widget.icindekilerModel!.testVersions[item.testKey!], hesapBilgileri: AppVar.qbankBloc.hesapBilgileri, kitapBilgileri: widget.kitap!, anlatim: true, icindekilerItem: item);
      await Fav.to(TestPage(), binding: BindingsBuilder(() => Get.put<QuestionPageController>(_controller)));
      _controller.dispose();
      100.wait.then((_) {
        if (Get.isRegistered<QuestionPageController>()) Get.delete<QuestionPageController>();
      }).unawaited;
      setState(() {});
    }
  }

  void _goToStatisticsPage() {
    if (widget.debug) return;

//todo burda idarecinin ne yapacagini gir

    if (Fav.noConnection()) return;

    Fav.to(StatisticsPage(kitap: widget.kitap, icindekilerData: widget.icindekilerModel));
  }

  bool get isEkol => AppVar.qbankBloc.isEkol == true;

  @override
  Widget build(BuildContext context) {
    if (widget.icindekilerModel == null) return MyQBankScaffold(body: Container());

    final _textColor = isEkol ? Fav.design.primaryText : Fav.secondaryDesign.primaryText;

    Widget swipeWidget = TestListesi(
      isTry: widget.isTry,
      kitap: widget.kitap,
      onClick: _testeGec,
      testData: widget.icindekilerModel,
      textColor: _textColor,
    );

    final String toplamSoru = (widget.icindekilerModel!.questionCount['toplam'] ?? 0).toString();

    final _statisticsPageButton = (!widget.debug && !widget.isTry)
        ? IconButton(
            icon: Icon(MdiIcons.chartBarStacked, color: isEkol ? Fav.design.appBar.text : Colors.white),
            onPressed: _goToStatisticsPage,
          )
        : SizedBox();

    if (isEkol) {
      return AppScaffold(
        topBar: TopBar(trailingActions: [_statisticsPageButton]),
        topActions: TopActionsTitleWithChild(
            title: TopActionsTitle(
              title: widget.kitap!.name1!,
              color: widget.kitap!.primaryColor.parseColor,
            ),
            child: Text(
              'totalquestionhint'.argTranslate(toplamSoru.toString()),
              style: TextStyle(color: Fav.design.primaryText.withAlpha(100), fontSize: 10.0),
            )),
        body: Body.child(maxWidth: 840, child: swipeWidget),
      );
    } else {
      return MyQBankScaffold(
        hasScaffold: true,
        body: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 4, right: 4),
              decoration: BoxDecoration(
                color: widget.kitap!.primaryColor.parseColor,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                boxShadow: [BoxShadow(color: widget.kitap!.primaryColor.parseColor, blurRadius: 6.0)],
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Get.back();
                      }),
                  Expanded(
                    child: Text(
                      widget.kitap!.name1!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
                    ),
                  ),
                  _statisticsPageButton
                ],
              ),
            ),
            Expanded(flex: 1, child: swipeWidget),
            const Divider(height: 1.0),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'totalquestionhint'.argTranslate(toplamSoru.toString()),
                style: TextStyle(color: _textColor.withAlpha(100), fontSize: 10.0),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class TestListesi extends StatelessWidget {
  final IcindekilerModel? testData;
  final Function? onClick;
  final Kitap? kitap;
  final bool? isTry;
  final Color? textColor;
  TestListesi({this.testData, this.onClick, this.kitap, this.isTry, this.textColor});

  Widget _buildTiles(IcindekilerItem item, BuildContext context, {int? no}) {
    if (item.testKey == "menulevel" || item.testKey == "testseviyesi" || item.testKey == "denemeseviyesi") {
      List<Widget> children = item.children!.fold<List<Widget>>(<Widget>[], (p, e) => p..add(_buildTiles(e, context)));

      return Container(
        decoration: ShapeDecoration(
          color: kitap!.primaryColor.parseColor.withAlpha(20),
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(8.0)), side: BorderSide(color: kitap!.primaryColor.parseColor.withAlpha(125), width: 0.3)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: ExpansionTile(
          collapsedIconColor: textColor,
          iconColor: textColor,
          initiallyExpanded: item.testKey == "denemeseviyesi",
          title: item.testKey == "denemeseviyesi"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(no == null ? item.baslik! : "$no. " + item.baslik!, style: TextStyle(color: textColor, fontSize: 16.0, fontWeight: FontWeight.bold)),
                    4.heightBox,
                    Text(item.aciklama ?? '', style: TextStyle(color: textColor!.withAlpha(200), fontSize: 11.0)),
                    8.heightBox,
                    Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      spacing: 8,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: ShapeDecoration(color: kitap!.primaryColor.parseColor.withAlpha(50), shape: const StadiumBorder()),
                          child: Text('starttime'.translate + ': ' + item.denemeStartTime!.dateFormat("d-MMM-yyyy, HH:mm"), style: TextStyle(color: kitap!.primaryColor.parseColor, fontSize: 11.0)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: ShapeDecoration(color: kitap!.primaryColor.parseColor.withAlpha(50), shape: const StadiumBorder()),
                          child: Text('finishtime'.translate + ': ' + item.denemeEndTime!.dateFormat("d-MMM-yyyy, HH:mm"), style: TextStyle(color: kitap!.primaryColor.parseColor, fontSize: 11.0)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: ShapeDecoration(color: kitap!.primaryColor.parseColor.withAlpha(50), shape: const StadiumBorder()),
                          child: Text('duration'.translate + ': ' + item.denemeDurationMinute.toString() + ' ${'minute'.translate}', style: TextStyle(color: kitap!.primaryColor.parseColor, fontSize: 11.0)),
                        ),
                      ],
                    ),
                    8.heightBox,
                    !Fav.preferences.getBool(item.denemeKey + 'sonucgonderildi', false)!
                        ? Row(
                            children: <Widget>[
                              Expanded(child: Text('sendresulthint'.translate, style: TextStyle(color: textColor!.withAlpha(200), fontSize: 8.0))),
                              8.widthBox,
                              MyMiniRaisedButton(
                                text: 'sendresult'.translate,
                                onPressed: () async {
                                  if (Fav.noConnection()) return;
                                  bool? sendSuc = await SendResult.send(true, item, kitap!.bookKey);
                                  if (sendSuc == null) return;
                                  if (sendSuc) {
                                    Get.back();
                                    OverAlert.saveSuc();
                                  } else {
                                    OverAlert.saveErr();
                                  }
                                },
                                color: kitap!.primaryColor.parseColor,
                                textColor: Colors.white,
                              ),
                            ],
                          )
                        : MyMiniRaisedButton(
                            text: 'viewresult'.translate,
                            color: kitap!.primaryColor.parseColor,
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
                    8.heightBox,
                  ],
                )
              : Text(no == null ? item.baslik! : "$no. " + item.baslik!, style: TextStyle(color: textColor, fontSize: 16.0, fontWeight: FontWeight.bold)),
          children: children,
        ),
      );
    }
    tryCount++;

    Widget trailingWidget = const SizedBox();
    if (isTry! && tryCount < 3) {
      if (Fav.preferences.getBool("${item.testKey}_test_cozuldu") ?? false) {
        trailingWidget = const Icon(Icons.check_circle, color: Color(0xff59D654));
      }
    } else if (isTry!) {
      trailingWidget = const Icon(Icons.lock, color: Colors.amber);
    } else if (Fav.preferences.getBool("${item.testKey}_test_cozuldu") ?? false) {
      trailingWidget = const Icon(Icons.check_circle, color: Color(0xff59D654));
    }

    if (!AppVar.qbankBloc.hesapBilgileri.isQbank && AppVar.qbankBloc.hesapBilgileri.girisTuru! < 30) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          trailingWidget,
          8.widthBox,
          IconButton(
            icon: Icon(MdiIcons.chartAreaspline, color: textColor),
            onPressed: () {
              if (Fav.noConnection()) return;
              Fav.to(TestStatisticsPage(book: kitap, testKey: item.testKey));
            },
          )
        ],
      );
    }

    return Container(
      decoration: ShapeDecoration(
          color: kitap!.primaryColor.parseColor.withAlpha(20),
          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(1.0)), side: BorderSide(color: kitap!.primaryColor.parseColor.withAlpha(150), width: 0.1)),
          image: DecorationImage(image: AssetImage(Assets.images.confettioPNG), fit: BoxFit.cover)),
      child: ListTile(
        onTap: (isTry! && tryCount > 2)
            ? () {
                OverAlert.show(autoClose: false, type: AlertType.danger, message: 'notfreewarning'.translate);
              }
            : () {
                onClick!(item);
              },
        title: Text(item.baslik!, style: TextStyle(color: textColor, fontSize: 16.0)),
        subtitle: Text(
            item.isPdfKAPage
                ? ((item.endPageForPdf! - item.startPageForPdf! + 1).toString() + ' ' + 'page'.translate)
                : item.isPdfSBPage
                    ? ((item.pdfSBQuestionCount).toString() + ' ' + 'soruplural'.translate)
                    : (testData!.questionCount[item.testKey!].toString() + " " + 'soruplural'.translate),
            style: TextStyle(color: textColor!.withAlpha(125), fontSize: 12.0)),
        trailing: trailingWidget,
      ),
    );
  }

  int tryCount = -1;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          itemCount: testData!.data!.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildTiles(testData!.data![index], context, no: index + 1);
          }),
    );
  }
}

class IcindekilerModel {
  List<IcindekilerItem>? data;
  late Map<String, int> questionCount;
  late Map<String, String> testVersions;
  late Map<String, dynamic> otherData;
  IcindekilerModel.fromJson(Map jsonData) {
    data = jsonData['data'] is List ? (jsonData['data'] as List).map((e) => IcindekilerItem.fromJson(e, '')).toList() : [];
    testVersions = Map<String, String>.from(jsonData['versions'] ?? {});
    questionCount = Map<String, int>.from(jsonData['questionCount'] ?? {});
    otherData = Map<String, dynamic>.from(jsonData['otherData'] ?? {});
  }

  BookType get bookType => otherData['bookType'] == 'pdf'
      ? BookType.pdf
      : otherData['bookType'] == 'exam'
          ? BookType.exam
          : BookType.qbank;

  ///Tek kitaplik pdf varsa urlsini dondurur.
  ///Liste halinde olmasinin nedeni birden fazla kopyasini tutmak icin
  String? get pdfUrl => otherData['pdfUrl'];
}

enum BookType {
  pdf,
  exam,
  qbank,
}

// extension BookTypeExtension on BookType {
//   bool get isOpticFormEnabled => this == BookType.qbank || this == BookType.exam;
// }

class IcindekilerItem {
  String? aciklama;
  String? baslik;
  String? data;
  String? testKey;
  List<IcindekilerItem>? children;
  late String _pageNo;
  AnswerKeyModel? answerKey;

  IcindekilerItem.fromJson(Map jsonData, String? data) {
    aciklama = jsonData['aciklama'] ?? '';
    baslik = jsonData['baslik'] ?? '';
    _pageNo = jsonData['pn'] ?? '';
    answerKey = jsonData['answerkey'] == null ? null : AnswerKeyModel.fromJson(jsonData['answerkey']);

    /// Deneme de en uste yazilan datalarin asagi menulere ulastirilmasini saglar
    this.data = data.safeLength > 6 ? data : (jsonData['data'] ?? '');
    testKey = jsonData['testKey'] ?? '';

    children = jsonData['children'] is List ? (jsonData['children'] as List).map((e) => IcindekilerItem.fromJson(e, this.data)).toList() : null;
  }

  int? get denemeStartTime => int.tryParse(data!.split('-')[1]);
  int? get denemeEndTime => int.tryParse(data!.split('-')[2]);
  int get denemeDurationMillisecond => int.tryParse(data!.split('-')[3])! * 60000;
  int? get denemeDurationMinute => int.tryParse(data!.split('-')[3]);
  String get denemeKey => data!.split('-')[0];

  int? get startPageForPdf => int.tryParse(_pageNo.split('-').first.trim());
  int? get endPageForPdf => int.tryParse(_pageNo.split('-').last.trim());

  int get pdfSBQuestionCount => answerKey!.answerKeyItems!.length;

  bool get isPdfKAPage => testKey == 'pdfkapage';
  bool get isPdfSBPage => testKey == 'pdftestpage';
}
