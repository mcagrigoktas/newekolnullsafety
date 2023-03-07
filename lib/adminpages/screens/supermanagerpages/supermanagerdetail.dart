import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import '../../../helpers/stringhelper.dart';
import '../../../localization/usefully_words.dart';
import '../../../widgets/mycard.dart';
import 'models.dart';

class SuperManagerDetail extends StatefulWidget {
  final String? islemYapilacakKey;
  final GlobalKey<FormState>? formKey;
  final Function? resetPage;

  final int? sayfaTuru;
  SuperManagerDetail({this.islemYapilacakKey, this.formKey, this.resetPage, key, this.sayfaTuru}) : super(key: key);

  @override
  SuperManagerDetailState createState() {
    return SuperManagerDetailState();
  }
}

class SuperManagerDetailState extends State<SuperManagerDetail> {
  late SuperManagerModel _superManagerData;
  bool _isLoading = false;
  GlobalKey<FormState>? _formKey;

  String? _islemSifresi;
  List<SuperManagerSchoolInfoModel> _schoolList = [];
  final _scrollController = ScrollController();

  List<String?> _existingServerIdList = [];
  SuperUserInfo get _superUser => Get.find<SuperUserInfo>();
  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey;
    if (widget.islemYapilacakKey != null) {
      setState(() {
        _isLoading = true;
      });
      Future.wait([
        AppVar.appBloc.database1.once('SuperManagers/${widget.islemYapilacakKey}'),
      ]).then((results) {
        _superManagerData = SuperManagerModel.fromJson(results[0]!.value, widget.islemYapilacakKey);
        _schoolList = _superManagerData.schoolDataList ?? [];

        _existingServerIdList = _schoolList.map((e) => e.serverId).toList();
        // (_superManagerData.schoolDataList ?? []).forEach((item) {
        //   _schoolList.add(SuperManagerSchoolInfoModel.fromJson(item));
        // });

        setState(() {
          _isLoading = false;
        });
      });
    } else {
      _superManagerData = SuperManagerModel();
    }
  }

  Future<void> _submit() async {
    if (_formKey!.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      if (!_superManagerData.superManagerServerId!.startsWith('739')) {
        OverAlert.show(type: AlertType.danger, message: 'SuperManagerServerId isnt correct: 739 error');
        return;
      }

      _superManagerData.key ??= _superManagerData.superManagerServerId;

      _superManagerData.schoolDataList = _schoolList;
      _superManagerData.saver = _superUser.saver.name;

      OverLoading.show();
      var _sp = await AppVar.appBloc.database1.once('sp');
      if (_sp == null || _sp.value.toString() != _islemSifresi) {
        await OverLoading.close();
        OverAlert.show(type: AlertType.danger, message: 'Incorrect Save Password');
        return;
      }
      Map<String, dynamic> _updates = {};

      _existingServerIdList.forEach((serverId) {
        _updates['/${StringHelper.schools}/$serverId/SchoolData/Info/gm/si'] = null;
        _updates['/${StringHelper.schools}/$serverId/SchoolData/Info/gm/n'] = null;
        _updates['/${StringHelper.schools}/$serverId/SchoolData/Versions/SchoolInfo'] = databaseTime;
      });

      _schoolList.forEach((element) {
        _updates['/${StringHelper.schools}/${element.serverId}/SchoolData/Info/gm/si'] = widget.islemYapilacakKey ?? _superManagerData.superManagerServerId;
        _updates['/${StringHelper.schools}/${element.serverId}/SchoolData/Info/gm/n'] = _superManagerData.name;
        _updates['/${StringHelper.schools}/${element.serverId}/SchoolData/Versions/SchoolInfo'] = databaseTime;
        _updates['/SuperManagers/${widget.islemYapilacakKey ?? _superManagerData.superManagerServerId}'] = _superManagerData.toJson();
      });
      log(_updates);

      await AppVar.appBloc.database1.update(_updates)
          //  AppVar.appBloc.database11.set('SuperManagers/${widget.islemYapilacakKey ?? _superManagerData.superManagerServerId}', _superManagerData.mapForSave())
          .then((_) async {
        OverAlert.saveSuc();
        widget.resetPage!();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MyProgressIndicator(isCentered: true);
    }

    return MyForm(
      formKey: _formKey!,
      child: (widget.islemYapilacakKey == null && widget.sayfaTuru != 10)
          ? EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST)
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: <Widget>[
                  widget.sayfaTuru == 10
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)), color: Fav.design.primary),
                          child: Text(
                            "new".translate,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : const SizedBox(),
                  Group2Widget(
                    children: <Widget>[
                      MyTextFormField(
                        initialValue: _superManagerData.name ?? '',
                        labelText: 'Genel mudurluk adi',
                        iconData: MdiIcons.ninja,
                        validatorRules: ValidatorRules(req: true, minLength: 2),
                        onSaved: (value) {
                          _superManagerData.name = value;
                        },
                      ),
                      MyTextFormField(
                        initialValue: _superManagerData.username,
                        labelText: 'UserName',
                        iconData: MdiIcons.accountNetwork,
                        validatorRules: ValidatorRules(req: true, minLength: 6),
                        onSaved: (value) {
                          _superManagerData.username = value;
                        },
                      ),
                      MyTextFormField(
                        initialValue: _superManagerData.password,
                        labelText: 'PassWord',
                        iconData: MdiIcons.key,
                        validatorRules: ValidatorRules(req: true, minLength: 6),
                        onSaved: (value) {
                          _superManagerData.password = value;
                        },
                      ),
                      IgnorePointer(
                        ignoring: widget.islemYapilacakKey != null,
                        child: MyTextFormField(
                          initialValue: _superManagerData.superManagerServerId,
                          labelText: 'Super Manager Servar Id',
                          hintText: 'Must start: 739',
                          iconData: MdiIcons.keyPlus,
                          validatorRules: ValidatorRules(req: true, minLength: 6),
                          onSaved: (value) {
                            _superManagerData.superManagerServerId = value;
                          },
                        ),
                      ),
                      for (var i = 0; i < _schoolList.length; i++)
                        MyListedCard(
                          number: i + 1,
                          closePressed: () {
                            setState(() {
                              _formKey = GlobalKey<FormState>();
                              _schoolList.removeAt(i);
                            });
                          },
                          child: FormField(
                            initialValue: _schoolList[i],
                            builder: (FormFieldState<SuperManagerSchoolInfoModel> state) => Column(
                              children: <Widget>[
                                GroupWidget(
                                  children: <Widget>[
                                    MyTextFormField(
                                      labelText: "School Name",
                                      validatorRules: ValidatorRules(
                                        req: true,
                                        minLength: 6,
                                      ),
                                      initialValue: _schoolList[i].schoolName,
                                      onSaved: (value) {
                                        _schoolList[i].schoolName = value;
                                      },
                                    ),
                                    MyTextFormField(
                                      labelText: "School Server Id",
                                      validatorRules: ValidatorRules(
                                        req: true,
                                        minLength: 6,
                                      ),
                                      initialValue: _schoolList[i].serverId,
                                      onSaved: (value) {
                                        _schoolList[i].serverId = value;
                                      },
                                    ),
                                  ],
                                ),
                                6.heightBox,
                              ],
                            ),
                          ),
                        ),
                      MyProgressButton(
                        label: 'Add School',
                        onPressed: () {
                          _formKey!.currentState!.save();
                          setState(() {
                            _formKey = GlobalKey<FormState>();
                            _schoolList.add(SuperManagerSchoolInfoModel(schoolName: '', serverId: ''));
                          });
                          Future.delayed(const Duration(milliseconds: 100)).then((_) {
                            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.linear);
                          });
                        },
                      ),
                      MyTextFormField(
                        labelText: 'Save Password',
                        iconData: MdiIcons.key,
                        validatorRules: ValidatorRules(req: true, minLength: 5),
                        onSaved: (value) {
                          _islemSifresi = value;
                        },
                      ),
                      Align(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : MyRaisedButton(
                                  text: Words.save,
                                  iconData: Icons.save,
                                  onPressed: _submit,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
    );
  }
}
