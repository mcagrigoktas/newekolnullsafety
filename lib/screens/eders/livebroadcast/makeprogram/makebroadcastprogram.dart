// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../../../../widgets/targetlistwidget.dart';
import '../livebroadcasthelper.dart';
import 'livebroadcastdatamodel.dart';
import 'zoomsettings.dart';

class MakeLiveBroadcastProgram extends StatefulWidget {
  final LiveBroadcastModel? existingItem;
  MakeLiveBroadcastProgram({this.existingItem});

  @override
  _MakeLiveBroadcastProgramState createState() => _MakeLiveBroadcastProgramState();
}

class _MakeLiveBroadcastProgramState extends State<MakeLiveBroadcastProgram> {
  LiveBroadcastModel _data = LiveBroadcastModel();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? _timeType = 1;
  int? _livebroadcasturltype;
  LiveBroadcastZoomModel? _newBroadcastData;
  bool _zoomLinkCreated = false;
  String? _teacherKey;

  final _linkController = TextEditingController();
  @override
  void initState() {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _teacherKey = AppVar.appBloc.hesapBilgileri.uid;
    } else if (AppVar.appBloc.hesapBilgileri.gtM) {
      _teacherKey = AppVar.appBloc.teacherService!.dataList.first.key;
    }

    if (widget.existingItem != null) {
      _data = LiveBroadcastModel.fromJson(widget.existingItem!.mapForSave(), widget.existingItem!.key);
      _timeType = _data.timeType ?? 1;
      _linkController.value = TextEditingValue(text: (_data.broadcastLink ?? '').contains('-*-') ? '' : (_data.broadcastLink ?? ''));
      _livebroadcasturltype = _data.livebroadcasturltype;
      if (_data.broadcastData != null) _newBroadcastData = LiveBroadcastZoomModel.fromJson(_data.broadcastData!);
    } else if (AppVar.appBloc.hesapBilgileri.gtT) {
      _data.teacherKey = AppVar.appBloc.hesapBilgileri.uid;
    }

    _linkController.addListener(() {
      final text = _linkController.value.text;
      if (text.startsWithHttp) return;
      final RegExp regExp = RegExp("http[A-z0-9:.\/?=]+");
      if (regExp.allMatches(text).isNotEmpty) {
        String? match = regExp.allMatches(text).first.group(0);
        if (match.safeLength > 6) {
          _linkController.value = TextEditingValue(text: match!);
        }
      }
    });

    super.initState();
  }

  Future<void> _submit1(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (Fav.noConnection()) return;

    if (_formKey.currentState!.checkAndSave()) {
      if (_data.timeType == 0) {
        if (_data.endTime! <= _data.startTime!) return OverAlert.show(type: AlertType.danger, message: 'checkdateerr2'.translate);
        if (_data.endTime! <= DateTime.now().millisecondsSinceEpoch) return OverAlert.show(type: AlertType.danger, message: 'checkdateerr'.translate);
      }

      _data.broadcastLink = _linkController.value.text.trim();

      if (_data.livebroadcasturltype == 5) {
        _data.broadcastLink = LiveBroadCastHelper.getJitsiDomain();
      }
      if (_livebroadcasturltype == 9) {
        if (_newBroadcastData == null) await _makeZoomLink(_teacherKey, lessonName: _data.lessonName);
        _data.broadcastLink = _newBroadcastData!.joinUrl;
        _data.broadcastData = _newBroadcastData!.mapForSave();
      }

      _data.aktif = true;
      _data.channelName = 15.makeKey;
      _data.startTime ??= DateTime.now().millisecondsSinceEpoch - const Duration(days: 3650).inMilliseconds;
      _data.endTime ??= DateTime.now().millisecondsSinceEpoch + const Duration(days: 3650).inMilliseconds;
      await Fav.preferences.setString('broadcastnamepref', _data.lessonName!);
      await Fav.preferences.setString('broadcastcontentpref', _data.explanation!);
      _data.lastUpdate = databaseTime;
      _submit2();
    }
  }

  void _submit2() {
    setState(() {
      _isLoading = true;
    });
    LiveBroadCastService.saveBroadcastProgram(_data, existingKey: widget.existingItem?.key).then((a) async {
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
      topBar: TopBar(leadingTitle: 'livebroadcast'.translate),
      topActions: TopActionsTitle(title: "makevideocallprogram".translate),
      body: Body.singleChildScrollView(
        maxWidth: 720,
        child: MyForm(
          formKey: _formKey,
          child: Column(
            children: <Widget>[
              if (AppVar.appBloc.hesapBilgileri.gtM && AppVar.appBloc.teacherService!.dataList.isNotEmpty && widget.existingItem == null)
                AdvanceDropdown(
                  searchbarEnableLength: 25,
                  name: "teacher".translate,
                  iconData: MdiIcons.humanMaleBoard,
                  onChanged: (dynamic value) {
                    _teacherKey = value;
                  },
                  items: AppVar.appBloc.teacherService!.dataList.map((teacher) {
                    return DropdownItem(value: teacher.key, name: teacher.name);
                  }).toList(),
                  onSaved: (dynamic value) {
                    _data.teacherKey = value;
                  },
                ),
              if (widget.existingItem == null)
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
                    initialValue: widget.existingItem != null ? widget.existingItem!.lessonName : Fav.preferences.getString('broadcastnamepref') ?? '',
                  ),
                  MyTextFormField(
                    labelText: "content".translate,
                    iconData: MdiIcons.commentTextMultipleOutline,
                    validatorRules: ValidatorRules(req: true, minLength: 5),
                    onSaved: (value) {
                      _data.explanation = value;
                    },
                    maxLines: null,
                    initialValue: widget.existingItem != null ? widget.existingItem!.explanation : Fav.preferences.getString('broadcastcontentpref') ?? '',
                  ),
                  LiveBroadCastHelper.broadcastTypeWidget((value) {
                    _data.livebroadcasturltype = value;
                  }, (value) {
                    setState(() {
                      _livebroadcasturltype = value;
                    });
                  }, widget.existingItem?.livebroadcasturltype),
                  if (_livebroadcasturltype == 9)
                    Column(
                      children: [
                        if (!_zoomLinkCreated)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              16.widthBox,
                              MyRaisedButton(
                                onPressed: () {
                                  _makeZoomLink(_teacherKey, lessonName: _data.lessonName);
                                },
                                text: 'makenewzoomlink'.translate,
                                color: Colors.blue,
                              ),
                              const Spacer(),
                              MyMiniRaisedButton(
                                onPressed: () async {
                                  await Fav.to(ZoomSettingsPage());
                                  setState(() {});
                                },
                                text: 'zoomsettings'.translate,
                                color: Colors.orange,
                              ),
                              16.widthBox,
                            ],
                          ),
                        8.heightBox,
                        if (_newBroadcastData != null)
                          Row(
                            children: [
                              Text('LINK:', style: TextStyle(color: Fav.design.primaryText, fontSize: 12, fontWeight: FontWeight.bold)),
                              8.widthBox,
                              SelectableText(
                                _newBroadcastData!.joinUrl!,
                                style: TextStyle(color: Fav.design.primaryText, fontSize: 12),
                              ),
                            ],
                          ),
                        8.heightBox,
                      ],
                    ),
                  if ((_livebroadcasturltype ?? 0) != 5 && (_livebroadcasturltype ?? 0) != 9)
                    Column(
                      children: [
                        MyTextFormField(
                          labelText: "broadcastLink".translate,
                          iconData: MdiIcons.link,
                          validatorRules: ValidatorRules(),
                          controller: _linkController,
                        ),
                        _livebroadcasturltype == 2
                            ? GestureDetector(
                                onTap: () async {
                                  await Fav.to(ZoomSettingsPage());
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: Fav.design.primaryText.withAlpha(25),
                                  child: Text(
                                    'zoomautolinkhint'.translate,
                                    style: TextStyle(color: Fav.design.primaryText),
                                  ),
                                ),
                              )
                            : Text(
                                'broadcastLinkHint'.translate,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Fav.design.primaryText.withAlpha(150), fontSize: 10),
                              ),
                      ],
                    ),
                ],
              ),
              MySegmentedControl(
                onChanged: (value) {
                  setState(() {
                    _timeType = value;
                  });
                },
                children: {
                  1: Text('broadcastTimeType2'.translate),
                  0: Text('broadcastTimeType1'.translate),
                },
                initialValue: _timeType,
                onSaved: (value) {
                  _data.timeType = value;
                },
              ),
              Text(
                (_timeType == 0 ? 'broadcastTimeType1hint' : 'broadcastTimeType2hint').translate,
                textAlign: TextAlign.center,
                style: TextStyle(color: Fav.design.primaryText.withAlpha(150), fontSize: 10),
              ),
              if (_timeType == 0)
                AnimatedGroupWidget(
                  children: [
                    MyDateTimePicker(
                      initialValue: widget.existingItem != null && widget.existingItem!.startTime != null ? widget.existingItem!.startTime : DateTime.now().millisecondsSinceEpoch,
                      title: "starttime".translate,
                      firstYear: 2019,
                      lastYear: 2025,
                      onSaved: (value) {
                        _data.startTime = value;
                      },
                    ),
                    MyDateTimePicker(
                      initialValue: widget.existingItem != null && widget.existingItem!.endTime != null ? widget.existingItem!.endTime : DateTime.now().millisecondsSinceEpoch,
                      title: "endtime".translate,
                      firstYear: 2019,
                      lastYear: 2025,
                      onSaved: (value) {
                        _data.endTime = value;
                      },
                    ),
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

  Future<void> _makeZoomLink(String? hostUid, {String? lessonName}) async {
    final zakAndZas = LiveBroadCastHelper.getZakAndZas(hostUid);
    if (zakAndZas == null) return;
    setState(() {
      _newBroadcastData = null;
      _isLoading = true;
    });

    _newBroadcastData = await LiveBroadCastHelper.createZoomMeeting(
      zakAndZas.first,
      zakAndZas.last!,
      topic: 'lesson'.translate + (lessonName ?? '') + ' ' + 1.makeKey,
    );
    setState(() {
      _zoomLinkCreated = true;
      _isLoading = false;
    });
    if (_newBroadcastData == null) OverAlert.saveErr();
  }
}
