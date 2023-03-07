import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../appbloc/databaseconfig.dart';
import '../../appbloc/databaseconfig.model_helper.dart';

class OpenDemoSchoolInfoPage extends StatefulWidget {
  OpenDemoSchoolInfoPage();

  @override
  _OpenDemoSchoolInfoPageState createState() => _OpenDemoSchoolInfoPageState();
}

class _OpenDemoSchoolInfoPageState extends State<OpenDemoSchoolInfoPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  String? mail;
  String? password;
  String? islemSifresi;
  String? schoolType;
  bool isLoading = false;
  bool schoolSaved = false;

  SuperUserInfo get _superUser => Get.find<SuperUserInfo>();

  Future<void> submit(context) async {
    final appBloc = AppVar.appBloc;

    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      // if (DatabaseStarter.getSaver(widget.user.email) == null) {
      //   OverAlert.show(type: AlertType.danger, message: 'Authority problem(saver)');
      //   return;
      // }
      setState(() {
        isLoading = true;
      });

      var sp = await appBloc.database1.once('sp');
      if (sp == null || sp.value.toString() != islemSifresi) {
        OverAlert.show(type: AlertType.danger, message: 'Incorrect Save Password');
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (schoolType != 'ekid' && schoolType != 'ekol') {
        OverAlert.show(type: AlertType.danger, message: 'School type isnt correct');
        setState(() {
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> updates = {};

      final _demoInfo = DatabaseStarter.databaseConfig.demoInfo![_superUser.saver.name]![schoolType!]!;

      updates['/DemoPasswordList/${mail! + password!}/saver'] = _superUser.saver.name;
      updates['/DemoPasswordList/${mail! + password!}/username'] = _demoInfo['u'];
      updates['/DemoPasswordList/${mail! + password!}/password'] = _demoInfo['p'];
      updates['/DemoPasswordList/${mail! + password!}/serverId'] = _demoInfo['s'];
      updates['/DemoPasswordList/${mail! + password!}/schoolType'] = schoolType;
      updates['/DemoPasswordList/${mail! + password!}/startTime'] = databaseTime;

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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'back'.translate),
      topActions: TopActionsTitleWithChild(
          title: TopActionsTitle(title: 'Open Demo School'),
          child: Text(
            _superUser.username!.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText),
          )),
      body: schoolSaved
          ? Body.child(
              child: Center(
                child: Text(
                  'Demo Saved\n School username:$mail, password:$password',
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
                      labelText: 'Username',
                      iconData: MdiIcons.account,
                      onSaved: (value) {
                        mail = value;
                      },
                    ),
                    MyTextFormField(
                      validatorRules: ValidatorRules(firebaseSafe: true, noGap: true, minLength: 6, req: true),
                      labelText: 'Password',
                      iconData: MdiIcons.key,
                      obscureText: true,
                      onSaved: (value) {
                        password = value;
                      },
                    ),
                    MyTextFormField(
                      validatorRules: ValidatorRules(noGap: true, minLength: 3, req: true),
                      labelText: 'School Type',
                      iconData: MdiIcons.formatListBulletedType,
                      onSaved: (value) {
                        schoolType = value;
                      },
                      hintText: 'ekid-ekol',
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
