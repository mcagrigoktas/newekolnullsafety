// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/print/otherprint.dart';
import '../../library_helper/excel/eager.dart';
import '../../library_helper/syncfusion_flutter_charts/eager.dart';
import '../../library_helper/syncfusion_flutter_charts/models.dart';
import '../../localization/usefully_words.dart';
import '../../services/dataservice.dart';
import 'makesurvey.dart';
import 'model.dart';

class SurveyDataList extends StatefulWidget {
  final String? surveyKey;
  SurveyDataList({this.surveyKey});

  @override
  _SurveyDataListState createState() => _SurveyDataListState();
}

class _SurveyDataListState extends State<SurveyDataList> {
  bool isLoading = false;
  Survey? surveyData;
  Map? filledSurveyData;

  List<_SurveyResultModel> resultDataForChart = [];
  @override
  void initState() {
    super.initState();

    var future1 = SurveyService.dbSurvey(widget.surveyKey).once();
    var future2 = SurveyService.dbSurveyDataList(widget.surveyKey).once();

    Future.wait([future1, future2]).then((response) {
      setState(() {
        surveyData = Survey.fromJson(response.first?.value ?? {});
        filledSurveyData = response.last?.value ?? {};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (surveyData == null || filledSurveyData == null) {
      return AppScaffold(
        topBar: TopBar(leadingTitle: 'surveylist'.translate),
        body: Body.circularProgressIndicator(),
      );
    }

    List<List<String>> myDataTable = [];
    resultDataForChart.clear();
    filledSurveyData!.forEach((personKey, suerveyValue) {
      String? personName;
      var student = AppVar.appBloc.studentService!.dataListItem(personKey);
      if (student != null) {
        personName = student.name;
      } else {
        var teacher = AppVar.appBloc.teacherService!.dataListItem(personKey);
        if (teacher != null) personName = teacher.name;
      }

      if (personName != null) {
        List<String> listCell = [personName];

        surveyData!.surveyitems!.forEach((item) {
          if (item.type != SurveyTypes.line) {
            final String? questionKey = item.key;
            final result = filledSurveyData![personKey][questionKey] ?? '...';

            if (item.type == SurveyTypes.choosable || item.type == SurveyTypes.hasPicture || item.type == SurveyTypes.multiplechoosable) {
              _SurveyResultModel? surveyResultModel = resultDataForChart.singleWhereOrNull((element) => element.questionKey == questionKey);
              if (surveyResultModel == null) {
                surveyResultModel = _SurveyResultModel(options: List<String>.from(item.extraData), questionKey: questionKey, questionType: item.type, content: item.content, imgUrl: item.imgUrl);
                resultDataForChart.add(surveyResultModel);
              }
              if (item.type == SurveyTypes.multiplechoosable) {
                if (result is List) {
                  result.forEach((element) {
                    surveyResultModel!.optionResult[element] = (surveyResultModel.optionResult[element] ?? 0) + 1;
                  });
                }
              } else {
                surveyResultModel.optionResult[result] = (surveyResultModel.optionResult[result] ?? 0) + 1;
              }
            }

            if (result is String) {
              listCell.add(result);
            } else if (result is List) {
              listCell.add((result..sort()).map((e) => e.toString()).join('-'));
            }
          }
        });

        myDataTable.add(listCell);
      }
    });

    myDataTable.sort((List a, List b) => (a.first ?? '').compareTo(b.first ?? ''));

    myDataTable.insert(0, ((surveyData!.surveyitems!)..removeWhere((element) => element.type == SurveyTypes.line)).map((itemhead) => (itemhead.content ?? '')).toList()..insert(0, 'name'.translate));

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'surveylist'.translate, trailingActions: <Widget>[
        MyPopupMenuButton(
            child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
            onSelected: (value) async {
              if (value == 1) {
                var sure = await Over.sure();
                if (sure == true) {
                  await SurveyService.dbdeleteSurvey(widget.surveyKey).then((value) {
                    Get.back();
                    OverAlert.deleteSuc();
                  }).catchError((err) {
                    OverAlert.deleteErr();
                  });
                }
              } else if (value == 2) {
                await OtherPrint.printSurveyResult(myDataTable);
              } else if (value == 3) {
                await ExcelLibraryHelper.export(myDataTable, surveyData!.title!);
                OverAlert.saveSuc();
              } else if (value == 4) {
                Get.back();
                await Fav.to(SurveyEdit(surveyData!.toJson()));
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 1, child: Text(Words.delete, style: TextStyle(color: Fav.design.primaryText))),
                PopupMenuItem(value: 2, child: Text(Words.print, style: TextStyle(color: Fav.design.primaryText))),
                PopupMenuItem(value: 3, child: Text('exportexcell'.translate, style: TextStyle(color: Fav.design.primaryText))),
                PopupMenuItem(value: 4, child: Text('editandresend'.translate, style: TextStyle(color: Fav.design.primaryText))),
              ];
            }),
      ]),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: surveyData!.title!),
          child: Column(
            children: [
              Row(
                children: [
                  if (surveyData!.image != null)
                    MyCachedImage(
                      imgUrl: surveyData!.image!,
                      fit: BoxFit.contain,
                      height: context.screenHeight / 10,
                    ).px16,
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: context.height / 5),
                      child: SingleChildScrollView(
                        child: surveyData!.content.text.center.color(Fav.design.primaryText).make(),
                      ),
                    ),
                  ),
                ],
              ),
              ResultChart(resultDataForChart),
            ],
          )),
      body: Body.child(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: MyDataTable(
              data: myDataTable,
              maxWidth: 200,
            ),
          ),
        ),
      ),
    );
  }
}

class _SurveyResultModel {
  //0 yazi 1 secenekli 2 resimli
  String? questionKey;
  String? content;
  String? imgUrl;
  SurveyTypes? questionType;
  List<String> options;
  Map<String, int> optionResult = {};

  _SurveyResultModel({this.questionKey, required this.options, this.questionType, this.content, this.imgUrl}) {
    options.forEach((element) {
      optionResult[element] = 0;
    });
  }
}

class ResultChart extends StatelessWidget {
  List<_SurveyResultModel> resultDataForChart = [];
  ResultChart(this.resultDataForChart);

  @override
  Widget build(BuildContext context) {
    List<Widget> chartWidget = [];
    resultDataForChart.forEach((element) {
      chartWidget.add(SizedBox(height: 248, width: 400, child: PieChartSample2(element)));
    });

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(children: chartWidget),
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  final _SurveyResultModel item;
  PieChartSample2(this.item);

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Fav.design.card.background,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.item.imgUrl.safeLength > 6)
                MyCachedImage(
                  imgUrl: widget.item.imgUrl!,
                  usePhotoView: true,
                  height: 40,
                ).pr8,
              Text(
                widget.item.content!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Fav.design.primaryText),
              ).stadium(background: Colors.teal.withAlpha(20)).py12,
            ],
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(data: getPieChartData(), showLegand: false),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    for (var i = 0; i < widget.item.optionResult.entries.length; i++)
                      Indicator(
                        text: widget.item.optionResult.entries.toList()[i].key + ' (' + widget.item.optionResult.entries.toList()[i].value.toString() + ')',
                        color: MyPalette.getChartColorFromCount(i),
                      )
                  ]),
                ),
              ],
            ),
          ),
        ],
      ).p8,
    );
  }

  List<PieChartSampleData> getPieChartData() {
    List<PieChartSampleData> resultData = [];

    for (var i = 0; i < widget.item.optionResult.entries.length; i++) {
      final entry = widget.item.optionResult.entries.toList()[i];
      final toplamKisi = widget.item.optionResult.entries.fold(0, (dynamic previousValue, element) => previousValue + element.value);
      resultData.add(PieChartSampleData(
        value: entry.value.toDouble(),
        text: (entry.key.startsWithHttp ? '' : entry.key) + '\n(${(entry.value * 100 / toplamKisi).toStringAsFixed(0)}%)',
        name: entry.key,
        //text: entry.value.toString() + '\n%' + (entry.value * 100 / toplamKisi).toStringAsFixed(0),
      ));
    }
    return resultData;
  }
}

class Indicator extends StatelessWidget {
  final Color? color;
  final String? text;
  final bool isSquare;
  final double size;

  const Indicator({
    Key? key,
    this.color,
    this.text,
    this.isSquare = true,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: isSquare ? BoxShape.rectangle : BoxShape.circle, color: color),
          ),
          4.widthBox,
          if (text!.startsWith('https'))
            Expanded(
              child: Row(
                children: [
                  MyCachedImage(
                    width: 40,
                    height: 40,
                    imgUrl: text!.split(' ').first.trim(),
                    usePhotoView: true,
                  ).pr4,
                  Expanded(child: Text(text!.split(' ').last.trim(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Fav.design.primaryText))),
                ],
              ),
            ),
          if (!text!.startsWith('https')) Expanded(child: Text(text!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Fav.design.primaryText)))
        ],
      ),
    );
  }
}
