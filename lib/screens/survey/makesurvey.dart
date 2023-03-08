import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../widgets/mycard.dart';
import '../../widgets/targetlistwidget.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import 'model.dart';

class SurveyEdit extends StatefulWidget {
  final Map? existingSurveyData;
  SurveyEdit([this.existingSurveyData]);
  @override
  _SurveyEditState createState() => _SurveyEditState();
}

class _SurveyEditState extends State<SurveyEdit> {
  // final Map _data = {};
  late Survey survey;
  final Announcement _dataAnnouncement = Announcement();
  var formKey = GlobalKey<FormState>();
  List<SurveyItem>? surveyList = [];
  bool isLoading = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    survey = Survey.create();
    if (widget.existingSurveyData != null && widget.existingSurveyData!['surveyitems'] != null) {
      final _existingItems = widget.existingSurveyData!['surveyitems'] as List;
      surveyList = _existingItems.map((e) {
        final _item = e as Map;
        return SurveyItem.fromJson(_item, _item['key']);
      }).toList();

      survey.title = widget.existingSurveyData!['title'];
      survey.content = widget.existingSurveyData!['content'];
      survey.image = widget.existingSurveyData!['image'];
    } else {
      readPreferences();
    }

    super.initState();
  }

  void sendAnnouncement(String key) {
    if (AppVar.appBloc.hesapBilgileri.gtM) {
      _dataAnnouncement.isPublish = true;
    }
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _dataAnnouncement.isPublish = UserPermissionList.hasTeacherAnnouncementsSharing();
    }
    _dataAnnouncement.timeStamp = databaseTime;
    _dataAnnouncement.createTime = databaseTime;
    _dataAnnouncement.surveyKey = key;
    _dataAnnouncement.senderKey = AppVar.appBloc.hesapBilgileri.uid;
    _dataAnnouncement.senderName = AppVar.appBloc.hesapBilgileri.name;

    AnnouncementService.saveAnnouncement(_dataAnnouncement, null).then((a) {
      setState(() {
        isLoading = false;
      });
      Get.back();
      OverAlert.saveSuc();
    }).catchError((error) {
      OverAlert.saveErr();
      setState(() {
        isLoading = false;
      });
    });
  }

  final prefKey = 'SurveyDraft';
  Future<void> save() async {
    formKey.currentState!.save();
    survey.surveyitems = surveyList;
    await Fav.securePreferences.setMap(prefKey, survey.toJson());
    Get.back();
  }

  Future<void> readPreferences() async {
    final data = Fav.securePreferences.getMap(prefKey);

    if (data.isEmpty) return;
    survey = Survey.fromJson(data);
    surveyList = survey.surveyitems;
    setState(() {});
  }

  Future<void> clear() async {
    setState(() {
      survey = Survey.create();
      surveyList!.clear();
      Fav.preferences.remove(prefKey);
      formKey = GlobalKey();
    });
  }

  Future<void> submit() async {
    if (Fav.noConnection()) return;

    if (formKey.currentState!.validate() && surveyList!.isNotEmpty) {
      final _sure = await Over.sure();
      if (_sure != true) return;

      formKey.currentState!.save();

      var key = DateTime.now().millisecondsSinceEpoch.toString() + 2.makeKey;
      survey.surveyitems = surveyList;
      survey.prepared = AppVar.appBloc.hesapBilgileri.uid;
      survey.preparedtype = AppVar.appBloc.hesapBilgileri.girisTuru;

      setState(() {
        isLoading = true;
      });

      await SurveyService.dbAddSurvey(survey.toJson(), key).then((_) {
        sendAnnouncement(key);
      }).catchError((_) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    } else {
      OverAlert.show(type: AlertType.danger, message: "errvalidation".translate);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> surveyWidgetList = [];

    for (int i = 0; i < surveyList!.length; i++) {
      final survey = surveyList![i];
      surveyWidgetList.add(MyListedCard(
        number: i + 1,
        closePressed: () {
          setState(() {
            surveyList!.remove(survey);
          });
        },
        tapPressed: i == 0
            ? null
            : () {
                setState(() {
                  formKey.currentState!.save();
                  surveyList!.remove(survey);
                  surveyList!.insert(i - 1, survey);
                });
              },
        downPressed: i + 1 == surveyList!.length
            ? null
            : () {
                setState(() {
                  formKey.currentState!.save();
                  surveyList!.remove(survey);
                  surveyList!.insert(i + 1, survey);
                });
              },
        child: FormField(
          key: ObjectKey(survey),
          initialValue: survey,
          builder: (FormFieldState<SurveyItem> state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              4.heightBox,
              Row(
                children: [
                  Expanded(
                    child: AdvanceDropdown<SurveyTypes>(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      initialValue: state.value!.type,
                      name: "",
                      items: [
                        DropdownItem<SurveyTypes>(name: 'choosable'.translate, value: SurveyTypes.choosable),
                        DropdownItem<SurveyTypes>(name: 'writable'.translate, value: SurveyTypes.text),
                        DropdownItem<SurveyTypes>(name: 'haspicture'.translate, value: SurveyTypes.hasPicture),
                        DropdownItem<SurveyTypes>(name: 'multiplechoosable'.translate, value: SurveyTypes.multiplechoosable),
                        DropdownItem<SurveyTypes>(name: 'lineforgroup'.translate, value: SurveyTypes.line),
                      ],
                      onSaved: (value) {
                        surveyList![i].type = value;
                      },
                      onChanged: (value) {
                        var sticker = state.value!;
                        sticker.type = value;
                        state.didChange(sticker);
                      },
                    ),
                  ),
                  if (state.value!.type != SurveyTypes.line)
                    MySwitch(
                        color: Fav.design.primaryText,
                        isTextPositonOnTop: true,
                        padding: EdgeInsets.zero,
                        name: 'req'.translate,
                        initialValue: surveyList![i].isRequired ?? true,
                        onSaved: (value) {
                          surveyList![i].isRequired = value;
                        }),
                  if (state.value!.type != SurveyTypes.line)
                    Tooltip(
                        message: 'duplicate'.translate,
                        child: Icons.control_point_duplicate.icon
                            .color(Fav.design.primaryText)
                            .onPressed(() {
                              setState(() {
                                formKey.currentState!.save();
                                final _surveyMap = survey.mapForSave();
                                final _newKey = DateTime.now().millisecondsSinceEpoch.toString() + 2.makeKey;
                                final _newSurvey = SurveyItem.fromJson(_surveyMap, _newKey);
                                surveyList!.add(_newSurvey);
                              });
                            })
                            .make()
                            .px8),
                  4.widthBox
                ],
              ),
              if (state.value!.type == SurveyTypes.line) 'lineforgrouphint'.translate.text.fontSize(10).make(),
              6.heightBox,
              Row(
                children: [
                  if (state.value!.type != SurveyTypes.line)
                    MyPhotoUploadWidget(
                      onSaved: (value) {
                        surveyList![i].imgUrl = value;
                      },
                      saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "GenerallyFiles",
                      initialValue: surveyList![i].imgUrl,
                      validatorRules: ValidatorRules(),
                    ),
                  Expanded(
                    child: MyTextFormField(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      labelText: "aciklama".translate,
                      validatorRules: ValidatorRules(req: true, minLength: 4),
                      initialValue: survey.content,
                      onSaved: (value) {
                        surveyList![i].content = value;
                      },
                      onChanged: (value) {
                        surveyList![i].content = value;
                      },
                    ),
                  ),
                ],
              ),
              if (state.value!.type == SurveyTypes.choosable || state.value!.type == SurveyTypes.multiplechoosable)
                MyMakeChipList(
                  validatorRules: ValidatorRules(req: true, minLength: 2),
                  initialValue: List<String>.from(survey.extraData ?? []),
                  iconData: MdiIcons.databasePlus,
                  color: Fav.design.primaryText,
                  labelText: "option".translate,
                  onSaved: (value) {
                    surveyList![i].extraData = value;
                  },
                ),
              if (state.value!.type == SurveyTypes.hasPicture)
                Row(
                  children: [
                    16.widthBox,
                    "option".translate.text.make(),
                    MyMultiplePhotoUploadWidget(
                      validatorRules: ValidatorRules(req: true, minLength: 2),
                      initialValue: List<String>.from(survey.extraData ?? []),
                      saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + 'SurveyPicture',
                      onSaved: (value) {
                        surveyList![i].extraData = value;
                      },
                    ),
                  ],
                ),
              8.heightBox,
            ],
          ),
        ),
      ));
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'surveylist'.translate, trailingActions: [
        MyPopupMenuButton(
          child: Icons.menu.icon.color(Fav.design.appBar.text).make(),
          itemBuilder: (context) {
            return <PopupMenuEntry>[
              PopupMenuItem(value: 0, child: Text("saveentryinfo".translate)),
              PopupMenuDivider(),
              PopupMenuItem(value: 1, child: Text("clear".translate)),
            ];
          },
          onSelected: (value) {
            if (value == 0) {
              save();
            } else if (value == 1) {
              clear();
            }
          },
        ),
      ]),
      topActions: TopActionsTitle(
        title: 'surveyadd'.translate,
      ),
      body: Body.singleChildScrollView(
        maxWidth: 960,
        scrollController: _scrollController,
        child: MyForm(
            formKey: formKey,
            child: Column(
              children: <Widget>[
                TargetListWidget(
                  initialValue: survey.targetList,
                  onlyteachers: AppVar.appBloc.hesapBilgileri.gtM,
                  onSaved: (value) {
                    _dataAnnouncement.targetList = value;
                    survey.targetList = value;
                  },
                ),
                MyTextFormField(
                  labelText: "header".translate,
                  iconData: MdiIcons.pen,
                  validatorRules: ValidatorRules(
                    req: true,
                    minLength: 4,
                  ),
                  initialValue: survey.title,
                  onSaved: (value) {
                    _dataAnnouncement.title = value;
                    survey.title = value;
                  },
                ),
                Row(
                  children: [
                    MyPhotoUploadWidget(
                      onSaved: (value) {
                        survey.image = value;
                      },
                      saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "GenerallyFiles",
                      initialValue: survey.image,
                      validatorRules: ValidatorRules(),
                    ),
                    Expanded(
                      child: MyTextFormField(
                        labelText: "content".translate,
                        iconData: MdiIcons.commentTextMultipleOutline,
                        validatorRules: ValidatorRules(req: true, minLength: 5),
                        initialValue: survey.content,
                        onSaved: (value) {
                          _dataAnnouncement.content = value;
                          survey.content = value;
                        },
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
                'questions'.translate.toUpperCase().text.bold.underline.fontSize(22).color(Fav.design.primaryText).make(),
                Column(children: surveyWidgetList),
              ],
            )),
      ),
      bottomBar: BottomBar.row(children: [
        MyRaisedButton(
          iconData: Icons.add,
          text: 'addquestion'.translate,
          onPressed: () async {
            setState(() {
              surveyList!.add(SurveyItem(type: SurveyTypes.text, content: '', key: DateTime.now().millisecondsSinceEpoch.toString() + 2.makeKey));
            });
            await 100.wait;
            await _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: 333.milliseconds, curve: Curves.ease);
          },
        ),
        Spacer(),
        MyProgressButton(
          isLoading: isLoading,
          label: "startsurvey".translate,
          onPressed: submit,
        ),
      ]),
    );
  }
}
