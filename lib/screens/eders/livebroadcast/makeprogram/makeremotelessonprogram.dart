// ignore_for_file: unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../livebroadcasthelper.dart';
import 'livebroadcastdatamodel.dart';
import 'zoomsettings.dart';

class MakeRemoteLessonProgram extends StatefulWidget {
  final Lesson? lesson;
  MakeRemoteLessonProgram({this.lesson});

  @override
  _MakeRemoteLessonProgramState createState() => _MakeRemoteLessonProgramState();
}

class _MakeRemoteLessonProgramState extends State<MakeRemoteLessonProgram> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool? _remoteLessonActive;

  int? _livebroadcasturltype;
  String? _broadcastLink;

  LiveBroadcastZoomModel? _newBroadcastData;
  final _linkController = TextEditingController();

  bool _zoomLinkCreated = false;

  @override
  void initState() {
    _remoteLessonActive = widget.lesson!.remoteLessonActive ?? false;
    _livebroadcasturltype = widget.lesson!.livebroadcasturltype;

    _linkController.value = TextEditingValue(text: (widget.lesson!.broadcastLink ?? '').contains('-*-') ? '' : (widget.lesson!.broadcastLink ?? ''));

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

    if (widget.lesson!.broadcastData != null) _newBroadcastData = LiveBroadcastZoomModel.fromJson(widget.lesson!.broadcastData!);
    super.initState();
  }

  Future<void> _submit1() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (Fav.noConnection()) return;

    if (_formKey.currentState!.checkAndSave()) {
      _broadcastLink = _linkController.value.text.trim();
      //  if (livebroadcasturltype == 1) broadcastLink = 15.makeKey;
      if (_livebroadcasturltype == 5) {
        _broadcastLink = LiveBroadCastHelper.getJitsiDomain()! + '-*-' + 15.makeKey;
      }
      if (_livebroadcasturltype == 9) {
        if (_newBroadcastData == null) await _makeZoomLink(widget.lesson);

        _broadcastLink = _newBroadcastData!.joinUrl;
      }

      _submit2();
    }
  }

  void _submit2() {
    setState(() {
      _isLoading = true;
    });

    LessonService.saveLessonBroadcastProgram(widget.lesson!.key, _remoteLessonActive, _livebroadcasturltype, _broadcastLink, _newBroadcastData?.mapForSave()).then((a) async {
      Navigator.pop(context, true);

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
      topBar: TopBar(leadingTitle: '     '.translate),
      topActions: TopActionsTitle(title: "makevideocallprogram".translate),
      body: Body.singleChildScrollView(
        maxWidth: 720,
        child: MyForm(
          formKey: _formKey,
          child: Column(
            children: <Widget>[
              AnimatedGroupWidget(
                children: <Widget>[
                  CheckboxListTile(
                    activeColor: Fav.design.primary,
                    title: Text('active'.translate, style: TextStyle(color: Fav.design.primaryText)),
                    onChanged: (value) {
                      setState(() {
                        _remoteLessonActive = value;
                      });
                    },
                    value: _remoteLessonActive,
                  ),
                  LiveBroadCastHelper.broadcastTypeWidget((value) {
                    _livebroadcasturltype = value;
                  }, (value) {
                    setState(() {
                      _livebroadcasturltype = value;
                    });
                  }, _livebroadcasturltype),
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
                                  _makeZoomLink(widget.lesson);
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
                          )
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
              16.heightBox,
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: MyProgressButton(
                    label: Words.save,
                    onPressed: _submit1,
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

  Future<void> _makeZoomLink(Lesson? lesson) async {
    String? hostUid;
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      hostUid = AppVar.appBloc.hesapBilgileri.uid;
    } else {
      hostUid = AppVar.appBloc.teacherService!.dataListItem(lesson!.teacher!)?.key;
    }

    final zakAndZas = LiveBroadCastHelper.getZakAndZas(hostUid);
    if (zakAndZas == null) return;
    setState(() {
      _newBroadcastData = null;
      _isLoading = true;
    });

    _newBroadcastData = await LiveBroadCastHelper.createZoomMeeting(
      zakAndZas.first,
      zakAndZas.last!,
      topic: widget.lesson!.name! + ' ' + (AppVar.appBloc.teacherService!.dataListItem(widget.lesson!.teacher!)?.name).toString(),
    );
    setState(() {
      _zoomLinkCreated = true;
      _isLoading = false;
    });
    if (_newBroadcastData == null) OverAlert.saveErr();
  }
}
