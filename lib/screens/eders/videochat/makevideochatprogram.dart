import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../../widgets/targetlistwidget.dart';

class MakeVideoChatProgram extends StatefulWidget {
  @override
  _MakeVideoChatProgramState createState() => _MakeVideoChatProgramState();
}

class _MakeVideoChatProgramState extends State<MakeVideoChatProgram> {
  final VideoLessonProgramModel _data = VideoLessonProgramModel();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _data.teacherKey = AppVar.appBloc.hesapBilgileri.uid;
    }

    super.initState();
  }

  Future<void> _submit1(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (Fav.noConnection()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_formKey.currentState!.checkAndSave()) {
      final int? baslangicZamani = _data.startTime;
      final int dersSayisi = _data.lessonCount!;
      final int? dersSuresi = _data.lessonDuration;
      final int? dersArasi = _data.pauseDuration;
      final int? molaDersSayisi = _data.lessonCountForBreak;
      final int? molaSuresi = _data.breakDuration;

      _data.lessons = [];
      for (var i = 0; i < dersSayisi; i++) {
        VideoLessonModel lessonModel = VideoLessonModel();
        lessonModel.startTime = baslangicZamani! + (i * dersSuresi! + i * dersArasi! + (molaDersSayisi! > 1 ? (i ~/ molaDersSayisi) * (molaSuresi! - dersArasi) : 0)) * 60000;
        lessonModel.state = 0;
        lessonModel.aktif = true;
        lessonModel.endTime = lessonModel.startTime! + dersSuresi * 60000;
        _data.lessons.add(lessonModel);
      }
      _data.timeStamp = databaseTime;
      _data.endTime = _data.lessons.last.endTime;
      _data.aktif = true;

      final result = await OverPage.openChoosebleListViewFromMap(
          extraWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              12.heightBox,
              _data.startTime!.dateFormat("d-MMM-yyyy").text.fontSize(20).bold.make(),
            ],
          ),
          data: _data.lessons.fold<Map>({}, (previousValue, lesson) => previousValue..[10.makeKey] = lesson.startTime!.dateFormat("HH:mm") + ' - ' + lesson.endTime!.dateFormat("HH:mm")),
          title: _data.lessonName!,
          listNotChooseble: true,
          bottomBar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child: 'videoprogramresult'.translate.text.fontSize(20).make()),
              8.widthBox,
              MyRaisedButton(
                  onPressed: () {
                    OverPage.select(true);
                  },
                  text: Words.save)
            ],
          ));

      Fav.preferences.setString('videolessonnamepref', _data.lessonName!).unawaited;
      Fav.preferences.setString('videolessoncontentpref', _data.explanation!).unawaited;

      if (result == true) {
        _submit2();
      } else {
        OverAlert.saveErr();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submit2() {
    setState(() {
      _isLoading = true;
    });
    VideoChatService.saveVideoLesson(_data).then((a) async {
      Navigator.pop(context, true);
      OverAlert.saveSuc();
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  @override
  Widget build(BuildContext mainContext) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: "videolesson".translate),
      topActions: TopActionsTitle(title: "makevideocallprogram".translate),
      body: Body.singleChildScrollView(
        maxWidth: 720,
        child: MyForm(
          formKey: _formKey,
          child: Column(
            children: <Widget>[
              if (AppVar.appBloc.hesapBilgileri.gtM && AppVar.appBloc.teacherService!.dataList.isNotEmpty)
                AdvanceDropdown(
                  searchbarEnableLength: 25,
                  name: "teacher".translate,
                  iconData: MdiIcons.humanMaleBoard,
                  items: AppVar.appBloc.teacherService!.dataList.map((teacher) {
                    return DropdownItem(value: teacher.key, name: teacher.name);
                  }).toList(),
                  onSaved: (dynamic value) {
                    _data.teacherKey = value;
                  },
                ),
              TargetListWidget(
                  onSaved: (value) {
                    _data.targetList = value;
                  },
                  onlyteachers: false,
                  alluser: true),
              AnimatedGroupWidget(
                children: <Widget>[
                  MyTextFormField(
                    labelText: "lessonname".translate,
                    iconData: MdiIcons.pen,
                    validatorRules: ValidatorRules(req: true, minLength: 3),
                    onSaved: (value) {
                      _data.lessonName = value;
                    },
                    initialValue: Fav.preferences.getString('videolessonnamepref') ?? '',
                  ),
                  MyTextFormField(
                    labelText: "content".translate,
                    iconData: MdiIcons.commentTextMultipleOutline,
                    validatorRules: ValidatorRules(req: true, minLength: 5),
                    onSaved: (value) {
                      _data.explanation = value;
                    },
                    maxLines: null,
                    initialValue: Fav.preferences.getString('videolessoncontentpref') ?? '',
                  ),
                  MyDateTimePicker(
                    initialValue: DateTime.now().millisecondsSinceEpoch,
                    title: "starttime".translate,
                    firstYear: 2019,
                    lastYear: 2025,
                    onSaved: (value) {
                      _data.startTime = value;
                    },
                  ),
                  MyTextFormField(
                    keyboardType: TextInputType.number,
                    labelText: "videocalllessoncount".translate,
                    iconData: MdiIcons.calculator,
                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true, minValue: 1),
                    onSaved: (value) {
                      _data.lessonCount = int.parse(value!);
                    },
                  ),
                  MyTextFormField(
                    keyboardType: TextInputType.number,
                    labelText: "videocalllessonduration".translate,
                    iconData: MdiIcons.clock,
                    hintText: 'minutehint'.translate,
                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true, minValue: 4),
                    onSaved: (value) {
                      _data.lessonDuration = int.parse(value!);
                    },
                  ),
                  MyTextFormField(
                    hintText: 'minutehint'.translate,
                    labelText: "videocalllessonpauseduration".translate,
                    iconData: MdiIcons.clock,
                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true),
                    onSaved: (value) {
                      _data.pauseDuration = int.parse(value!);
                    },
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                  ),
                  MyTextFormField(
                    labelText: "videocalllessoncountforbreak".translate,
                    iconData: MdiIcons.coffee,
                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true),
                    onSaved: (value) {
                      _data.lessonCountForBreak = int.parse(value!);
                    },
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                  ),
                  MyTextFormField(
                    hintText: 'minutehint'.translate,
                    labelText: "videocalllessonbreakduration".translate,
                    iconData: MdiIcons.clock,
                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true),
                    onSaved: (value) {
                      _data.breakDuration = int.parse(value!);
                    },
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                  ),
                  Column(
                    children: <Widget>[
                      MyTextFormField(
                        hintText: 'dayhint'.translate,
                        labelText: "videolessonblock".translate,
                        iconData: MdiIcons.calendar,
                        validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true),
                        onSaved: (value) {
                          _data.blockDay = int.parse(value!);
                        },
                        initialValue: '10',
                        keyboardType: TextInputType.number,
                      ),
                      Text(
                        'videolessonblockhint'.translate,
                        style: TextStyle(color: Fav.design.primaryText, fontSize: 12),
                        textAlign: TextAlign.start,
                      )
                    ],
                  )
                ],
              ),
              16.heightBox,
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: MyProgressButton(
                    label: Words.save,
                    onPressed: () {
                      _submit1(context);
                    },
                    isLoading: _isLoading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
