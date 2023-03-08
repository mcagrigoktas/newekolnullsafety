import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../adminpages/screens/supermanagerpages/models.dart';
import '../../../appbloc/appvar.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../../supermanager/supermanagerbloc.dart';

class ChangePasswordPage extends StatefulWidget {
  final bool accountIsSuperManager;
  ChangePasswordPage({this.accountIsSuperManager = false});
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _oldPasword;
  String? _newPasword;
  String? _newPasword2;

  void _changeLoading(bool state) {
    setState(() {
      _isLoading = state;
    });
  }

  void _changePassword() {
    if (widget.accountIsSuperManager) {
      _changePasswordSuperManager();
    } else {
      _changePasswordUser();
    }
  }

  void _changePasswordSuperManager() {
    FocusScope.of(context).unfocus();
    if (Fav.noConnection()) return;
    if (_formKey.currentState!.checkAndSave()) {
      if (_newPasword != _newPasword2) {
        'passwordmatcherr'.translate.showAlert();
        return;
      }
      final _superManagerBloc = Get.find<SuperManagerController>();
      final _hesapBilgileri = _superManagerBloc.hesapBilgileri;

      _changeLoading(true);

      AppVar.appBloc.database1.once('SuperManagers/${_hesapBilgileri.kurumID}').then((snapshot) async {
        final _userData = snapshot?.value;
        if (_userData == null) {
          _changeLoading(false);
          OverAlert.saveErr();
        }
        final _superManager = SuperManagerModel.fromJson(snapshot!.value, snapshot.key);

        if (_superManager.password != _oldPasword) {
          _changeLoading(false);
          'oldpassworderr'.translate.showAlert(AlertType.danger);
          return;
        }

        _superManager.password = _newPasword;
        _superManager.passwordChangedByUser = true;

        Map<String, dynamic> _updates = {};
        _updates['/SuperManagers/${_hesapBilgileri.kurumID}'] = _superManager.toJson();

        await AppVar.appBloc.database1.update(_updates).then((_) async {
          _changeLoading(false);
          Get.back();
          OverAlert.show(message: 'passwordchangesuc'.translate, autoClose: false, type: AlertType.successful);
        }).catchError((err) {
          _changeLoading(false);
          OverAlert.saveErr();
        });
      }).catchError((err) {
        _changeLoading(false);
        OverAlert.saveErr();
      });
    }
  }

  void _changePasswordUser() {
    FocusScope.of(context).unfocus();
    if (Fav.noConnection()) return;
    if (_formKey.currentState!.checkAndSave()) {
      if (_newPasword != _newPasword2) {
        'passwordmatcherr'.translate.showAlert();
        return;
      }
      final _hesapBilgileri = AppVar.appBloc.hesapBilgileri;
      assert(_hesapBilgileri.gtT || _hesapBilgileri.gtS || _hesapBilgileri.gtM);

      String _girisTuruKey = "Managers";
      if (_hesapBilgileri.gtT) _girisTuruKey = "Teachers";
      if (_hesapBilgileri.gtS) _girisTuruKey = "Students";

      _changeLoading(true);
      UserInfoService.dbGetUserInfo(_hesapBilgileri.kurumID, _girisTuruKey, _hesapBilgileri.uid, _hesapBilgileri.termKey).once().then((snapshot) {
        final _userData = snapshot!.value;
        if (_userData == null) {
          _changeLoading(false);
          OverAlert.saveErr();
        }

        if (_hesapBilgileri.gtM) {
          final _manager = Manager.fromJson(_userData, snapshot.key);
          if (_manager.password != _oldPasword) {
            _changeLoading(false);
            'oldpassworderr'.translate.showAlert(AlertType.danger);
            return;
          }

          _manager.password = _newPasword;
          _manager.passwordChangedByUser = true;
          ManagerService.saveManager(_manager, _manager.key).then((value) {
            _changeLoading(false);
            Get.back();
            OverAlert.show(message: 'passwordchangesuc'.translate, autoClose: false, type: AlertType.successful);
          }).catchError((err) {
            _changeLoading(false);
            OverAlert.saveErr();
          });
        } else if (_hesapBilgileri.gtT) {
          final _teacher = Teacher.fromJson(_userData, snapshot.key);
          if (_teacher.password != _oldPasword) {
            _changeLoading(false);
            'oldpassworderr'.translate.showAlert(AlertType.danger);
            return;
          }
          _teacher.password = _newPasword;
          _teacher.passwordChangedByUser = true;
          TeacherService.saveTeacher(_teacher, _teacher.key!).then((value) {
            _changeLoading(false);
            Get.back();
            OverAlert.show(message: 'passwordchangesuc'.translate, autoClose: false, type: AlertType.successful);
          }).catchError((err) {
            _changeLoading(false);
            OverAlert.saveErr();
          });
        } else if (_hesapBilgileri.gtS) {
          final _student = Student.fromJson(_userData, snapshot.key);

          if (!_hesapBilgileri.isParent) {
            if (_student.password != _oldPasword) {
              _changeLoading(false);
              'oldpassworderr'.translate.showAlert(AlertType.danger);
              return;
            }
            _student.password = _newPasword;
            _student.passwordChangedByUser = true;
            if (_newPasword == _student.parentPassword1 || _newPasword == _student.parentPassword2) {
              _changeLoading(false);
              return OverAlert.saveErr();
            }
          } else if (_hesapBilgileri.parentNo == 1) {
            if (_student.parentPassword1 != _oldPasword) {
              _changeLoading(false);
              'oldpassworderr'.translate.showAlert(AlertType.danger);
              return;
            }

            _student.parentPassword1 = _newPasword;
            _student.parent1PasswordChangedByUser = true;
            if (_newPasword == _student.password || _newPasword == _student.parentPassword2) {
              _changeLoading(false);
              return OverAlert.saveErr();
            }
          } else {
            if (_student.parentPassword2 != _oldPasword) {
              _changeLoading(false);
              'oldpassworderr'.translate.showAlert(AlertType.danger);
              return;
            }
            if (_newPasword == _student.password || _newPasword == _student.parentPassword1) {
              _changeLoading(false);
              return OverAlert.saveErr();
            }
            _student.parentPassword2 = _newPasword;
            _student.parent2PasswordChangedByUser = true;
          }
          StudentService.saveStudent(_student, _student.key!).then((value) {
            _changeLoading(false);
            Get.back();
            OverAlert.show(message: 'passwordchangesuc'.translate, autoClose: false, type: AlertType.successful);
          }).catchError((err) {
            _changeLoading(false);
            OverAlert.saveErr();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: widget.accountIsSuperManager ? 'back'.translate : 'editprofile'.translate),
      topActions: TopActionsTitle(title: 'changepassword'.translate),
      body: Body.child(
          child: MyForm(
        formKey: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextFormField(
              iconColor: Colors.redAccent,
              initialValue: _oldPasword,
              hintText: "sixcharacter".translate,
              labelText: "oldpassword".translate,
              iconData: MdiIcons.formTextboxPassword,
              validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
              onSaved: (value) {
                _oldPasword = value;
              },
            ),
            MyTextFormField(
              iconColor: Colors.greenAccent,
              initialValue: _newPasword,
              hintText: "sixcharacter".translate,
              labelText: "newpassword".translate,
              iconData: MdiIcons.formTextboxPassword,
              validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
              onSaved: (value) {
                _newPasword = value;
              },
            ),
            MyTextFormField(
              iconColor: Colors.greenAccent,
              initialValue: _newPasword2,
              hintText: "sixcharacter".translate,
              labelText: "newpassword2".translate,
              iconData: MdiIcons.formTextboxPassword,
              validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
              onSaved: (value) {
                _newPasword2 = value;
              },
            )
          ],
        ),
      )),
      bottomBar: BottomBar.saveButton(onPressed: _changePassword, isLoading: _isLoading),
    );
  }
}
