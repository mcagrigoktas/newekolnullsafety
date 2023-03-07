import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../appbloc/appvar.dart';
import '../../appbloc/databaseconfig.model_helper.dart';
import '../../helpers/stringhelper.dart';
import '../../models/allmodel.dart';

class OpenSchoolInfoPage extends StatefulWidget {
  OpenSchoolInfoPage();

  @override
  _OpenSchoolInfoPageState createState() => _OpenSchoolInfoPageState();
}

class _OpenSchoolInfoPageState extends State<OpenSchoolInfoPage> {
  SuperUserInfo get _superUser => Get.find<SuperUserInfo>();
  GlobalKey<FormState> formKey = GlobalKey();
  String? mail;
  String? password;
  String? serverId;
  String? islemSifresi;
  String? schoolType;
  bool isLoading = false;
  bool schoolSaved = false;

  Future<void> submit(context) async {
    final appBloc = AppVar.appBloc;

    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      for (var i = 0; i < serverId!.length; i++) {
        if (!'abcdefghijklmnopqrstuvwxyz0123456789'.contains(serverId![i])) {
          OverAlert.show(type: AlertType.danger, message: 'School Id isnt correct');
          return;
        }
      }
      if (serverId!.startsWith('739')) {
        OverAlert.show(type: AlertType.danger, message: '739');
        return;
      }

      // if (_superUser == null) {
      //   OverAlert.show(type: AlertType.danger, message: 'Authority problem(saver)');
      //   return;
      // }
      setState(() {
        isLoading = true;
      });
      var existingServerId = await appBloc.database1.once('ServerList/$serverId');
      if (existingServerId?.value != null) {
        OverAlert.show(type: AlertType.danger, message: 'School Id is existing');
        setState(() {
          isLoading = false;
        });
        return;
      }
      var sp = await appBloc.database1.once('sp');
      if (sp == null || sp.value.toString() != islemSifresi) {
        OverAlert.show(type: AlertType.danger, message: 'Incorrect Save Password');
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (schoolType != 'ekid' && schoolType != 'ekol' && schoolType != 'uni') {
        OverAlert.show(type: AlertType.danger, message: 'School type isnt correct');
        setState(() {
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> updates = {};
      updates['/ServerList/$serverId/saver'] = _superUser.saver.name;
      updates['/ServerList/$serverId/timeStamp'] = DateTime.now().millisecondsSinceEpoch;
      updates['/ServerList/$serverId/schoolType'] = schoolType;

      updates['/${StringHelper.schools}/$serverId/CheckList/${mail! + password!}'] = {'GirisTuru': 10, 'UID': 'Manager1'};

      final manager = Manager()
        ..aktif = true
        ..username = mail
        ..password = password
        ..lastUpdate = databaseTime
        ..name = 'Manager Name';
      updates['/${StringHelper.schools}/$serverId/Managers/Manager1'] = manager.mapForSave('Manager1');

      // {
      //   'username': mail, 'password': password, 'aktif': true, 'name': 'Manager Name',
      //   //'imgUrl':'https://firebasestorage.googleapis.com/v0/b/elseifekid.appspot.com/o/appimages%2Fothers%2Fmanager.png?alt=media&token=9c5dc978-ac48-4832-931f-96b6cd2df909'
      // };

      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/aktif'] = true;
      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/schoolType'] = schoolType;

      // updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2019-2020'] = {'aktif': true, 'name': '2019-2020'};
      // updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2020-2021'] = {'aktif': true, 'name': '2020-2021'};
      updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2021-2022'] = {'aktif': true, 'name': '2021-2022'};
      updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2022-2023'] = {'aktif': true, 'name': '2022-2023'};
      updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2023-2024'] = {'aktif': true, 'name': '2023-2024'};
      updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2024-2025'] = {'aktif': true, 'name': '2024-2025'};
      updates['/${StringHelper.schools}/$serverId/SchoolData/Terms/2025-2026'] = {'aktif': true, 'name': '2025-2026'};

      updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2021-2022';
      // if (DateTime.now().millisecondsSinceEpoch < DateTime(2021, 6).millisecondsSinceEpoch) {
      //   updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2020-2021';
      // } else
      if (DateTime.now().millisecondsSinceEpoch < DateTime(2022, 6).millisecondsSinceEpoch) {
        updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2021-2022';
      } else if (DateTime.now().millisecondsSinceEpoch < DateTime(2023, 6).millisecondsSinceEpoch) {
        updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2022-2023';
      } else if (DateTime.now().millisecondsSinceEpoch < DateTime(2024, 6).millisecondsSinceEpoch) {
        updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2023-2024';
      } else if (DateTime.now().millisecondsSinceEpoch < DateTime(2025, 6).millisecondsSinceEpoch) {
        updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2024-2025';
      } else if (DateTime.now().millisecondsSinceEpoch < DateTime(2026, 6).millisecondsSinceEpoch) {
        updates['/${StringHelper.schools}/$serverId/SchoolData/Info/activeTerm'] = '2025-2026';
      }

      await appBloc.database1.update(updates).then((_) {
        setState(() {
          schoolSaved = true;
        });
      }).catchError((err) {
        OverAlert.show(type: AlertType.danger, message: err.toString());
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'back'.translate,
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: 'Register School'),
        child: Text(
          _superUser.username!.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText),
        ),
      ),
      body: schoolSaved
          ? Body.child(
              child: Center(
                child: Text(
                  'School Saved\n School Id:$serverId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            )
          : Body.singleChildScrollView(
              child: MyForm(
                formKey: formKey,
                child: Group2Widget(
                  children: <Widget>[
                    MyTextFormField(
                      validatorRules: ValidatorRules(firebaseSafe: true, noGap: true, minLength: 6, req: true),
                      labelText: 'Manager Username',
                      iconData: MdiIcons.account,
                      onSaved: (value) {
                        mail = value;
                      },
                    ),
                    MyTextFormField(
                      validatorRules: ValidatorRules(firebaseSafe: true, noGap: true, minLength: 6, req: true),
                      labelText: 'Manager Password',
                      iconData: MdiIcons.key,
                      obscureText: true,
                      onSaved: (value) {
                        password = value;
                      },
                    ),
                    MyTextFormField(
                      validatorRules: ValidatorRules(firebaseSafe: true, noGap: true, minLength: 6, req: true),
                      labelText: 'School Id',
                      iconData: MdiIcons.renameBox,
                      onSaved: (value) {
                        serverId = value;
                      },
                    ),
                    AdvanceDropdown<String?>(
                      validatorRules: ValidatorRules(req: true),
                      name: 'School Type',
                      iconData: MdiIcons.formatListBulletedType,
                      onSaved: (value) {
                        schoolType = value;
                      },
                      items: [
                        DropdownItem(name: 'anitemchoose'.translate, value: null),
                        DropdownItem(name: 'Kindergarden (Ekid)'.translate, value: 'ekid'),
                        DropdownItem(name: 'Middle-High School (Ekol)'.translate, value: 'ekol'),
                        DropdownItem(name: 'University'.translate, value: 'uni'),
                      ],
                    ),
                    MyTextFormField(
                      validatorRules: ValidatorRules(noGap: true, minLength: 5, req: true),
                      labelText: 'Save Password',
                      iconData: MdiIcons.adjust,
                      obscureText: true,
                      onSaved: (value) {
                        islemSifresi = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomBar: schoolSaved
          ? null
          : BottomBar.saveButton(
              onPressed: () {
                submit(context);
              },
              isLoading: isLoading),
    );
  }
}
