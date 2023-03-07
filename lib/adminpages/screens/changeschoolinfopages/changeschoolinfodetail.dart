import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import '../../../helpers/stringhelper.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../models/enums.dart';
import '../../../screens/main/menu_list_helper.dart';
import '../../../services/smssender.dart';
import 'helper.dart';

class ChangeSchoolInfoDetail extends StatefulWidget {
  final String? islemYapilacakKey;
  final GlobalKey<FormState>? formKey;
  final GlobalKey<FormState>? form2Key;
  final GlobalKey<FormState>? form3Key;
  final Function? resetPage;
  final String? saver;
  ChangeSchoolInfoDetail({this.islemYapilacakKey, this.formKey, this.form2Key, this.form3Key, this.resetPage, this.saver, key}) : super(key: key);

  @override
  ChangeSchoolInfoDetailState createState() {
    return ChangeSchoolInfoDetailState();
  }
}

class ChangeSchoolInfoDetailState extends State<ChangeSchoolInfoDetail> {
  static SuperUserInfo get _superUser => Get.find<SuperUserInfo>();

  bool obscurePassword = true;

  late Manager manager;
  Map? schoolData;
  late Map schoolDataForManager;
  bool isLoading = true;

  String? islemSifresi;

  String? saveSchoolname;
  String? saveSchoolSlogan;
  String? savelogoUrl;
  String? saveManagerName;
  String? saveManagerUserName;
  String? saveManagerPassword;
  String? saveManagerPhone;

  String? livedomainlist;
  String? appName;
  bool? saveAktif;
  List<String>? menuList;
  int studentCount = 10000;
  int lastUsableTime = DateTime.now().add(Duration(days: 1095)).millisecondsSinceEpoch;
  int videoDuration = 60;

  String? accountingNote1;
  String? accountingNote2;
  String? accountingNote3;
  String? accountingNote4;
  String? accountingNote5;

  @override
  void initState() {
    super.initState();

    if (widget.islemYapilacakKey != null) {
      Future.wait([
        AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/Managers/Manager1'),
        AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/SchoolData/Info'),
        AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/SchoolData/InfoForManager'),
      ]).then((results) {
        manager = Manager.fromJson(results[0]!.value, 'Manager1');
        schoolData = results[1]!.value;
        schoolDataForManager = results[2]?.value ?? {};
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _submit2() async {
    if (widget.form2Key!.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      OverLoading.show();

      var sp = await AppVar.appBloc.database1.once('sp');

      if (sp == null || sp.value.toString() != islemSifresi) {
        await OverLoading.close();
        OverAlert.show(type: AlertType.danger, message: 'Incorrect Save Password');
        return;
      }

      final serverId = widget.islemYapilacakKey;
      Map<String, dynamic> updates = {};
      updates['/Okullar/$serverId/SchoolData/InfoForManager/sC'] = studentCount;
      updates['/Okullar/$serverId/SchoolData/InfoForManager/lUT'] = lastUsableTime;
      updates['/Okullar/$serverId/SchoolData/InfoForManager/an1'] = accountingNote1;
      updates['/Okullar/$serverId/SchoolData/InfoForManager/an2'] = accountingNote2;
      updates['/Okullar/$serverId/SchoolData/InfoForManager/an3'] = accountingNote3;
      updates['/Okullar/$serverId/SchoolData/InfoForManager/an4'] = accountingNote4;
      updates['/Okullar/$serverId/SchoolData/InfoForManager/an5'] = accountingNote5;
      updates['/Okullar/$serverId/SchoolData/Versions/${VersionListEnum.schoolInfoForManager}'] = databaseTime;
      await AppVar.appBloc.database1.update(updates).then((_) async {
        OverAlert.saveSuc();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }

  Future<void> _submit3() async {
    if (widget.form3Key!.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      OverLoading.show();

      var sp = await AppVar.appBloc.database1.once('sp');

      if (sp == null || sp.value.toString() != islemSifresi) {
        await OverLoading.close();
        OverAlert.show(type: AlertType.danger, message: 'Incorrect Save Password');

        return;
      }

      final serverId = widget.islemYapilacakKey;
      Map<String, dynamic> updates = {};

      updates['/Okullar/$serverId/CheckList/${saveManagerUserName! + saveManagerPassword!}'] = {'GirisTuru': 10, 'UID': 'Manager1'};

      updates['/${StringHelper.schools}/$serverId/Managers/Manager1'] = (manager
            ..username = saveManagerUserName
            ..password = saveManagerPassword
            ..lastUpdate = databaseTime
            ..phone = saveManagerPhone
            ..name = saveManagerName)
          .mapForSave('Manager1');

      await AppVar.appBloc.database1.update(updates).then((_) async {
        final activeTermSnap = await AppVar.appBloc.database1.once('${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm');
        if (activeTermSnap?.value != null) await AppVar.appBloc.databaseVersions.set('${StringHelper.schools}/$serverId/${activeTermSnap!.value}/Manager1/UserInfoChangeService', databaseTime);
        OverAlert.saveSuc();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }

  Future<void> _submit() async {
    if (widget.formKey!.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      OverLoading.show();

      var sp = await AppVar.appBloc.database1.once('sp');

      if (sp == null || sp.value.toString() != islemSifresi) {
        await OverLoading.close();
        OverAlert.show(type: AlertType.danger, message: 'Incorrect Save Password');

        return;
      }

      final serverId = widget.islemYapilacakKey;
      Map<String, dynamic> updates = {};

      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/logoUrl'] = savelogoUrl;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/name'] = saveSchoolname;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/slogan'] = saveSchoolSlogan;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/aktif'] = saveAktif;

      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/livedomainlist'] = livedomainlist;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/appName'] = appName;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/menuList'] = menuList;

      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/limits/sC'] = studentCount;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/limits/vD'] = videoDuration;

      updates['/${StringHelper.schools}/$serverId/SchoolData/Versions/SchoolInfo'] = databaseTime;

      await AppVar.appBloc.database1.update(updates).then((_) async {
        OverAlert.saveSuc();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }

  Future<void> sendSMS() async {
    List<String> recipents = [];
    if ((manager.phone ?? '').length > 5) {
      recipents.add(manager.phone!);
    }

    List<UserAccountSmsModel> smsModelList = [];
    smsModelList.add(UserAccountSmsModel(
      username: manager.username,
      password: manager.password,
      numbers: recipents,
      kurumId: widget.islemYapilacakKey,
    ));

    if ((schoolData!['appName'] as String?).safeLength < 1) {
      OverAlert.show(message: 'Uygulama tipi belli degil');
      return;
    }

    await SmsSender.sendUserAccountWithSms(smsModelList, appName: schoolData!['appName']);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.islemYapilacakKey == null) return EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST);
    if (isLoading) return MyProgressIndicator(isCentered: true);

    String _loginTimeText = '';
    //todo 30 kasim 2022 de schooldatadan bakan kisimdan kaldir
    final int? _loginTime = schoolDataForManager['mLT'] ?? (schoolData!['limits'] ?? {})['mLT'];
    if (_loginTime != null) {
      final Duration _difference = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _loginTime);
      _loginTimeText = _difference.inDays < 7 ? 'Son bir hafta icinde giriş yapıldı' : 'En son ${_difference.inDays} gün önce giriş yapıldı';
    }

    return Column(
      children: [
        if (_loginTimeText.safeLength > 5) _loginTimeText.text.color(Colors.white).center.make().stadium(),
        8.heightBox,
        Expanded(
          child: FormStack(
            children: [
              FormStackItem(
                name: 'settings'.translate + ' 1',
                child: MyForm(
                  formKey: widget.formKey!,
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          GroupWidget(
                            children: <Widget>[
                              AdvanceDropdown<bool>(
                                initialValue: schoolData!['aktif'],
                                onSaved: (value) {
                                  saveAktif = value;
                                },
                                iconData: MdiIcons.bugle,
                                name: 'Active',
                                items: [
                                  DropdownItem(name: 'Active', value: true),
                                  DropdownItem(name: 'Passive', value: false),
                                ],
                              ),
                              MyTextFormField(
                                initialValue: schoolData!['name'],
                                labelText: 'School Name',
                                iconData: MdiIcons.account,
                                validatorRules: ValidatorRules(req: true, minLength: 6),
                                onSaved: (value) {
                                  saveSchoolname = value;
                                },
                              ),
                            ],
                          ),
                          GroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                initialValue: schoolData!['slogan'],
                                labelText: 'School Slogan',
                                iconData: MdiIcons.flag,
                                validatorRules: ValidatorRules(req: true, minLength: 1),
                                onSaved: (value) {
                                  saveSchoolSlogan = value;
                                },
                              ),
                            ],
                          ),
                          GroupWidget(
                            children: <Widget>[
                              AdvanceDropdown<String?>(
                                  initialValue: schoolData!['appName'],
                                  onSaved: (value) {
                                    appName = value;
                                  },
                                  iconData: MdiIcons.nail,
                                  name: 'Market App',
                                  items: DatabaseStarter.marketLinks.entries.where((element) => element.value.saver == widget.saver).map((e) => DropdownItem(name: e.value.name, value: e.key)).toList()..insert(0, DropdownItem(name: 'Choose app', value: null))),
                              MyTextFormField(
                                initialValue: schoolData!['livedomainlist'],
                                labelText: 'Live Server List',
                                iconData: MdiIcons.videoPlus,
                                onSaved: (value) {
                                  livedomainlist = value;
                                },
                              ),
                            ],
                          ),
                          GroupWidget(
                            children: <Widget>[
                              IgnorePointer(
                                child: MyTextFormField(
                                  initialValue: ((schoolData!['limits'] ?? {})['sC'] ?? studentCount).toString(),
                                  labelText: 'Max student Count',
                                  iconData: MdiIcons.ambulance,
                                  keyboardType: TextInputType.number,
                                  onSaved: (value) {
                                    studentCount = int.tryParse(value!) ?? 10000;
                                  },
                                ),
                              ),
                              MyTextFormField(
                                initialValue: ((schoolData!['limits'] ?? {})['vD'] ?? videoDuration).toString(),
                                labelText: 'Max Video Time (second)',
                                iconData: MdiIcons.ambulance,
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  videoDuration = int.tryParse(value!) ?? 60;
                                },
                              ),
                            ],
                          ),
                          MyMultiSelect(
                              iconData: MdiIcons.book,
                              initialValue: List<String>.from(schoolData!['menuList'] ?? []),
                              name: 'Menu List',
                              validatorRules: ValidatorRules(req: true, minLength: 1),
                              onSaved: (value) {
                                menuList = value;
                              },
                              context: context,
                              items: [
                                MyMultiSelectItem(MenuListItem.messages.name, 'Messages'),
                                MyMultiSelectItem(MenuListItem.socialnetwork.name, 'Social Network'),
                                MyMultiSelectItem(MenuListItem.preregistration.name, 'Pre Registration'),
                                MyMultiSelectItem(MenuListItem.transporter.name, 'Transporter List'),
                                MyMultiSelectItem(MenuListItem.accounting.name, 'Accounting'),
                                MyMultiSelectItem(MenuListItem.survey.name, 'Survey'),
                                MyMultiSelectItem(MenuListItem.birthdaylist.name, 'Birthday List'),
                                MyMultiSelectItem(MenuListItem.healthcare.name, 'Health Care'),
                                MyMultiSelectItem(MenuListItem.foodmenu.name, 'Food Menu'),
                                MyMultiSelectItem(MenuListItem.videolesson.name, 'Video Lesson'),
                                MyMultiSelectItem(MenuListItem.livebroadcast.name, 'Live Broadcast'),
                                MyMultiSelectItem(MenuListItem.evaulation.name, 'Evaulation'),
                                MyMultiSelectItem(MenuListItem.portfolio.name, 'Portfolyo'),
                                if (schoolData!['schoolType'] == 'ekid') MyMultiSelectItem(MenuListItem.dailyreport.name, 'Daily Report'),
                                if (schoolData!['schoolType'] == 'ekid') MyMultiSelectItem(MenuListItem.stickers.name, 'Stickers'),
                                MyMultiSelectItem(MenuListItem.timetable.name, 'TimeTable'),
                                if (schoolData!['schoolType'] == 'ekol' || schoolData!['schoolType'] == 'uni') MyMultiSelectItem(MenuListItem.qbank.name, 'Question Bank'),
                                if (schoolData!['schoolType'] == 'ekol' || schoolData!['schoolType'] == 'uni') MyMultiSelectItem(MenuListItem.p2ptype2.name, 'Birebir Tip 2'),
                              ],
                              title: 'Menu List'),
                          Align(
                            child: MyPhotoUploadWidget(
                              avatarImage: true,
                              validatorRules: ValidatorRules(req: true),
                              saveLocation: widget.islemYapilacakKey! + '/' + "GenerallyFiles",
                              initialValue: schoolData!['logoUrl'],
                              onSaved: (value) {
                                savelogoUrl = value;
                              },
                              dataImportance: DataImportance.veryHigh,
                            ),
                          ),
                          16.heightBox,
                          GroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                labelText: 'Save Password',
                                iconData: MdiIcons.key,
                                validatorRules: ValidatorRules(req: true, minLength: 5),
                                onSaved: (value) {
                                  islemSifresi = value;
                                },
                              ),
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: isLoading
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
                          if (_superUser.isDeveloper && schoolData!['aktif'] == false && (DateTime.now().millisecondsSinceEpoch - (_loginTime ?? DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch) > Duration(days: 15).inMilliseconds))
                            MyRaisedButton(
                              color: Colors.red,
                              text: "Okulu sil".translate,
                              iconData: Icons.delete,
                              onPressed: () async {
                                final result = await DeleteSchoolHelper.delete(widget.islemYapilacakKey!);
                                if (result == true) Get.back();
                              },
                            ).pt32
                        ],
                      )),
                ),
              ),
              FormStackItem(
                  name: 'settings'.translate + ' 2',
                  child: MyForm(
                    formKey: widget.form2Key!,
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: <Widget>[
                            GroupWidget(
                              children: <Widget>[
                                MyTextFormField(
                                  initialValue: (schoolDataForManager['sC'] ?? 10000).toString(),
                                  labelText: 'Max student Count',
                                  iconData: MdiIcons.ambulance,
                                  keyboardType: TextInputType.number,
                                  validatorRules: ValidatorRules(minValue: 10, mustNumber: true, req: true),
                                  onSaved: (value) {
                                    studentCount = int.tryParse(value!) ?? 10000;
                                  },
                                ),
                                MyDatePicker(
                                  initialValue: schoolDataForManager['lUT'] ?? lastUsableTime,
                                  title: 'Last Usable Time',
                                  onSaved: (value) {
                                    if (value != null) lastUsableTime = value;
                                  },
                                ),
                              ],
                            ),
                            Group2Widget(children: [
                              MyTextFormField(
                                initialValue: schoolDataForManager['an5'],
                                labelText: 'IrtibatNo',
                                iconData: MdiIcons.note,
                                maxLines: null,
                                validatorRules: ValidatorRules(),
                                onSaved: (value) {
                                  accountingNote5 = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: schoolDataForManager['an3'],
                                labelText: 'Irtibat isim',
                                iconData: MdiIcons.note,
                                maxLines: null,
                                validatorRules: ValidatorRules(),
                                onSaved: (value) {
                                  accountingNote3 = value;
                                },
                              ),
                            ]),
                            MyTextFormField(
                              initialValue: schoolDataForManager['an4'],
                              labelText: 'Tutar',
                              iconData: MdiIcons.note,
                              maxLines: null,
                              validatorRules: ValidatorRules(),
                              onSaved: (value) {
                                accountingNote4 = value;
                              },
                            ),
                            MyTextFormField(
                              initialValue: schoolDataForManager['an1'],
                              labelText: 'Note1',
                              iconData: MdiIcons.note,
                              maxLines: null,
                              validatorRules: ValidatorRules(),
                              onSaved: (value) {
                                accountingNote1 = value;
                              },
                            ),
                            MyTextFormField(
                              initialValue: schoolDataForManager['an2'],
                              labelText: 'Note2',
                              iconData: MdiIcons.note,
                              maxLines: null,
                              validatorRules: ValidatorRules(),
                              onSaved: (value) {
                                accountingNote2 = value;
                              },
                            ),
                            16.heightBox,
                            GroupWidget(
                              children: <Widget>[
                                MyTextFormField(
                                  labelText: 'Save Password',
                                  iconData: MdiIcons.key,
                                  validatorRules: ValidatorRules(req: true, minLength: 5),
                                  onSaved: (value) {
                                    islemSifresi = value;
                                  },
                                ),
                                Align(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: isLoading
                                        ? const CircularProgressIndicator()
                                        : MyRaisedButton(
                                            text: Words.save,
                                            iconData: Icons.save,
                                            onPressed: _submit2,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  )),
              FormStackItem(
                name: 'manager'.translate,
                child: MyForm(
                  formKey: widget.form3Key!,
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          GroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                initialValue: manager.name,
                                labelText: 'Manager Name',
                                iconData: MdiIcons.adjust,
                                validatorRules: ValidatorRules(req: true, minLength: 5),
                                onSaved: (value) {
                                  saveManagerName = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: manager.phone,
                                labelText: 'Tel: ',
                                iconData: MdiIcons.phone,
                                validatorRules: ValidatorRules(),
                                onSaved: (value) {
                                  saveManagerPhone = value;
                                },
                              ),
                            ],
                          ),
                          GroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                initialValue: manager.username,
                                labelText: 'Manager Username',
                                iconData: MdiIcons.accountNetwork,
                                validatorRules: ValidatorRules(req: true, minLength: 6),
                                onSaved: (value) {
                                  saveManagerUserName = value;
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: MyTextFormField(
                                      initialValue: manager.password,
                                      labelText: 'Manager Password',
                                      iconData: MdiIcons.key,
                                      validatorRules: ValidatorRules(req: true, minLength: 6),
                                      onSaved: (value) {
                                        saveManagerPassword = value;
                                      },
                                      obscureText: obscurePassword,
                                      suffixIcon: Icons.remove_red_eye.icon
                                          .onPressed(() {
                                            setState(() {
                                              obscurePassword = !obscurePassword;
                                            });
                                          })
                                          .color(Fav.design.primaryText)
                                          .make(),
                                    ),
                                  ),
                                  Icons.send.icon.onPressed(sendSMS).color(Fav.design.primaryText).make()
                                ],
                              ),
                            ],
                          ),
                          16.heightBox,
                          GroupWidget(
                            children: <Widget>[
                              MyTextFormField(
                                labelText: 'Save Password',
                                iconData: MdiIcons.key,
                                validatorRules: ValidatorRules(req: true, minLength: 5),
                                onSaved: (value) {
                                  islemSifresi = value;
                                },
                              ),
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: isLoading
                                      ? const CircularProgressIndicator()
                                      : MyRaisedButton(
                                          text: Words.save,
                                          iconData: Icons.save,
                                          onPressed: _submit3,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
