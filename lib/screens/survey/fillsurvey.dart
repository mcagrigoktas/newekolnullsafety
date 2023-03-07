import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import 'model.dart';

class SurveyFillPage extends StatefulWidget {
  final Announcement? announcement;
  SurveyFillPage({this.announcement});

  @override
  _SurveyFillPageState createState() => _SurveyFillPageState();
}

class _SurveyFillPageState extends State<SurveyFillPage> {
  bool isLoading = false;
  Survey? surveyData;
  Map filledSurveyData = {};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map sendingSurveyData = {};

  @override
  void initState() {
    super.initState();
    var future1 = SurveyService.dbSurvey(widget.announcement!.surveyKey).once();
    var future2 = SurveyService.dbFilledSurvey(widget.announcement!.surveyKey).once();

    Future.wait([future1, future2]).then((response) {
      setState(() {
        if (mounted) {
          surveyData = Survey.fromJson(response.first?.value ?? {});
          filledSurveyData = response.last?.value ?? {};
        }
      });
    });
  }

  void save() {
    if (Fav.isTimeGuardNotAllowed('surveysavebutton')) return;
    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      setState(() {
        isLoading = true;
      });
      SurveyService.dbSaveSurvey(widget.announcement!.surveyKey, sendingSurveyData).then((_) {
        Get.back();
        OverAlert.saveSuc();
        setState(() {
          isLoading = false;
        });
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    }
  }

  Widget getContentText(SurveyItem surveyItem) {
    return Row(
      children: [
        if (surveyItem.imgUrl.safeLength > 6)
          MyCachedImage(
            imgUrl: surveyItem.imgUrl!,
            height: 80,
            usePhotoView: true,
          ).pr16,
        Expanded(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(text: surveyItem.content ?? '', style: TextStyle(fontSize: 15, color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
            if (surveyItem.isRequired == true) TextSpan(text: ' *', style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold)),
          ])),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (surveyData == null) {
      return AppScaffold(
        topBar: TopBar(leadingTitle: 'menu1'.translate),
        topActions: TopActionsTitle(title: 'survey'.translate),
        body: Body.circularProgressIndicator(),
      );
    }

    // final title = surveyData['title'];
    // final content = surveyData['content'];
    // final image = surveyData['image'];

    // final List<SurveyItem> surveyitems = (surveyData['surveyitems'] as List).map((survey) => SurveyItem.fromJson(survey, survey['key'])).toList();

    List<Widget> surveyWidgets = [];

    surveyData!.surveyitems!.forEach((surveyItem) {
      surveyWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: surveyItem.type == SurveyTypes.line
            ? Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: Inset.v(4),
                color: Fav.design.primaryText.withAlpha(50),
                child: surveyItem.content.text.fontSize(22).bold.make(),
              )
            : surveyItem.type == SurveyTypes.multiplechoosable
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    getContentText(surveyItem),
                    4.heightBox,
                    AdvanceMultiSelectDropdown(
                      padding: const EdgeInsets.all(0),
                      initialValue: filledSurveyData[surveyItem.key] == null ? null : List<String>.from(filledSurveyData[surveyItem.key]),
                      iconData: Icons.list,
                      nullValueText: '...',
                      items: (List<String>.from(surveyItem.extraData))
                          .map((options) => DropdownItem(
                                name: options,
                                value: options,
                              ))
                          .toList(),
                      onSaved: (value) {
                        sendingSurveyData[surveyItem.key] = value;
                      },
                      validatorRules: surveyItem.isRequired == true ? ValidatorRules(minLength: 1, req: true) : ValidatorRules.none(),
                    )
                  ])
                : surveyItem.type == SurveyTypes.choosable
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        getContentText(surveyItem),
                        4.heightBox,
                        AdvanceDropdown(
                          padding: const EdgeInsets.all(0),
                          initialValue: filledSurveyData[surveyItem.key],
                          iconData: Icons.list,
                          nullValueText: '...',
                          items: (List<String>.from(surveyItem.extraData))
                              .map((options) => DropdownItem(
                                    name: options,
                                    value: options,
                                  ))
                              .toList(),
                          onSaved: (dynamic value) {
                            sendingSurveyData[surveyItem.key] = value;
                          },
                          validatorRules: surveyItem.isRequired == true ? ValidatorRules(minLength: 1, req: true) : ValidatorRules.none(),
                        )
                      ])
                    : surveyItem.type == SurveyTypes.text
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              getContentText(surveyItem),
                              4.heightBox,
                              MyTextFormField(
                                maxLines: null,
                                padding: const EdgeInsets.only(
                                  bottom: 16.0,
                                ),
                                initialValue: filledSurveyData[surveyItem.key],
                                onSaved: (value) {
                                  sendingSurveyData[surveyItem.key] = value;
                                },
                                validatorRules: surveyItem.isRequired == true ? ValidatorRules(minLength: 1, req: true) : ValidatorRules.none(),
                              ),
                            ],
                          )
                        : surveyItem.type == SurveyTypes.hasPicture
                            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                getContentText(surveyItem),
                                4.heightBox,
                                AdvanceDropdown(
                                  validatorRules: surveyItem.isRequired == true ? ValidatorRules(minLength: 1, req: true) : ValidatorRules.none(),
                                  padding: const EdgeInsets.all(0),
                                  initialValue: filledSurveyData[surveyItem.key],
                                  nullValueText: '...',
                                  items: (List<String>.from(surveyItem.extraData))
                                      .map((options) => DropdownItem(
                                            child: ConstrainedBox(
                                              key: ValueKey(options),
                                              constraints: const BoxConstraints(maxHeight: 150),
                                              child: MyCachedImage(
                                                imgUrl: options,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            value: options,
                                          ))
                                      .toList(),
                                  onSaved: (dynamic value) {
                                    sendingSurveyData[surveyItem.key] = value;
                                  },
                                )
                              ])
                            : Container(),
      ));
    });

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: 'survey'.translate),
          child: Column(
            children: [
              Text(surveyData!.title!, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (surveyData!.image != null)
                    MyCachedImage(
                      usePhotoView: true,
                      imgUrl: surveyData!.image!,
                      fit: BoxFit.contain,
                      height: context.screenHeight / 10,
                    ).px16,
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: context.height / 3),
                      child: SingleChildScrollView(
                          child: Text(
                        surveyData!.content!,
                        style: TextStyle(color: Fav.design.primaryText),
                      )),
                    ),
                  ),
                ],
              ),
            ],
          )),
      body: Body.singleChildScrollView(
        maxWidth: 960,
        withKeyboardCloserGesture: true,
        child: MyForm(
          formKey: formKey,
          child: Column(
            children: surveyWidgets,
          ),
        ),
      ),
      bottomBar: (AppVar.appBloc.hesapBilgileri.gtS || (AppVar.appBloc.hesapBilgileri.gtT && widget.announcement!.targetList!.contains('onlyteachers')))
          ? BottomBar.saveButton(
              onPressed: save,
              isLoading: isLoading,
            )
          : null,
    );
  }
}
