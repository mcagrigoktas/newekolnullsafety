import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/accountdata.dart';
import '../../../assets.dart';
import '../../qbankbloc/getdataservice.dart';
import '../../qbankbloc/setdataservice.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage();

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool _isLoading = false;

  String? _username;
  String? _password1;
  String? _password2;

//  signUpGoogle() async {
//    GoogleSignIn _googleSignIn = GoogleSignIn(
//      scopes: ['email'],
//    );
//
//    GoogleSignInAccount googleSignInAccount;
//    try {
//      googleSignInAccount = await _googleSignIn.signIn();
//    } catch (error) {
//      print(error);
//     OverAlert.show(type: AlertType.danger, message:  'signuperr'));
//      return;
//    }
//    if (googleSignInAccount == null) {
//     OverAlert.show(type: AlertType.danger, message:  'signuperr'));
//      return;
//    }
//    String mail = googleSignInAccount.email;
//    setState(() {
//      isLoading = true;
//    });
//    username = mail;
//    password1 = 10.makeKey;
//    password2 = password1;
//    signUpAndLogin(true);
//  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (Fav.noConnection()) return;

      _formKey.currentState!.save();

      if (!_username!.contains("@") || !_username!.contains(".") || _username!.length < 10) {
        OverAlert.show(message: 'emailhint'.translate);
        return;
      }

      if (_username!.contains("\$") || _username!.contains("[") || _username!.contains("]") || _username!.contains("#") || _username!.contains("/") || _username!.contains("\\")) {
        OverAlert.show(message: 'emailhint'.translate);
        return;
      }

      if (_password1 != _password2) {
        OverAlert.show(message: 'passwordmatcherr'.translate);
        return;
      }

      _signUpAndLogin(false).unawaited;
    }
  }

  Future<void> _signUpAndLogin(isGoogle) async {
    setState(() {
      _isLoading = true;
    });

    String model = await DeviceManager.getDeviceModel();

    var userData = {
      'username': _username,
      'password': _password1,
      'uid': 15.makeKey,
      'deviceList': [model],
    };

    QBSetDataService.saveUserForMail(_username!, _password1!, userData).then((_) {
      //bunun aynisi loginde de var ne guncelleyeceksen orayada yaz
      (isGoogle ? QBGetDataService.getGoogleLoginData(_username!) : QBGetDataService.getLoginData(_username!, _password1!)).then((snap) async {
        if (snap!.value == null) {
          OverAlert.show(type: AlertType.danger, message: 'signuperr'.translate);
          return;
        }
        List deviceList = snap.value['deviceList'] ?? [];
        if (deviceList.length > 1 && !deviceList.contains(model)) {
          OverAlert.show(type: AlertType.danger, message: 'manydeviceloginerr'.translate);
          return;
        }
        if (!deviceList.contains(model)) {
          await QBSetDataService.addLoginDevice(snap.value['username'], snap.value['password'], deviceList..add(model));
        }

        QBankHesapBilgileri hesapBilgileri = QBankHesapBilgileri();
        hesapBilgileri.schoolType = 'qbank';
        hesapBilgileri.username = snap.value['username'];
        hesapBilgileri.password = snap.value['password'];
        hesapBilgileri.uid = snap.value['uid'];
        hesapBilgileri.name = '';
        hesapBilgileri.imgUrl = '';
        hesapBilgileri.purchasedList = [];
        hesapBilgileri.girisYapildi = true;
        hesapBilgileri.girisTuru = 30;

        //     Fav.preferences.setString("qbankHesapBilgileri", hesapBilgileri.toString());
        await hesapBilgileri.savePreferences();
        AppVar.qbankBloc.appConfig.qbankRestartApp!(true);
      });
    }).catchError((err) {
      setState(() {
        _isLoading = false;
      });
      OverAlert.show(type: AlertType.danger, message: 'signuperr'.translate);
      return;
    }).unawaited;
  }

  @override
  Widget build(BuildContext context) {
    Widget imgWidget = Image.asset(Assets.images.loginilPNG, width: 200.0);

    var _userNameTextfield = MyTextFormField(
      iconData: MdiIcons.at,
      hintText: 'emailhint'.translate,
      labelText: 'mailadress'.translate,
      onSaved: (value) {
        _username = value;
      },
      validatorRules: ValidatorRules(noGap: true, req: true, mailAddress: true, minLength: 6),
      keyboardType: TextInputType.emailAddress,
    );
    var _password1Textfield = MyTextFormField(
      obscureText: true,
      iconData: MdiIcons.key,
      hintText: 'sixcharacter'.translate,
      labelText: 'password'.translate,
      onSaved: (value) {
        _password1 = value;
      },
      validatorRules: ValidatorRules(noGap: true, req: true, minLength: 6, firebaseSafe: true),
    );
    var _password2Textfield = MyTextFormField(
      obscureText: true,
      iconData: MdiIcons.key,
      hintText: 'sixcharacter'.translate,
      labelText: 'repassword'.translate,
      onSaved: (value) {
        _password2 = value;
      },
      validatorRules: ValidatorRules(noGap: true, req: true, minLength: 6, firebaseSafe: true),
    );
    Widget _loginButton = Align(
      child: MyProgressButton(
        isLoading: _isLoading,
        onPressed: _signUp,
        label: "signup".translate,
      ),
    );

//    Widget googleButton = RaisedButton(
//      onPressed: signUpGoogle,
//      color: Colors.redAccent,
//      child: Text(
//         'gmailsignup'),
//        style: TextStyle(color: Colors.white),
//      ),
//    );
    Widget _warningText = AppVar.qbankBloc.appConfig.appName.toLowerCase().contains('smat')
        ? GestureDetector(
            onTap: () {
              if (AppVar.qbankBloc.appConfig.appName.toLowerCase().contains('smat')) {
                DocumentView.openWithGoogleDocument(
                  'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o/Cagri%2FMembership%20Rights%20(SMAT%20Vault).docx?alt=media&token=290978e7-8a6c-4206-bfdf-0c9f7828ccec',
                );
              } else {
                DocumentView.openWithGoogleDocument(
                  'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o/Cagri%2FMembership%20Rights%20(SMAT%20Vault).docx?alt=media&token=290978e7-8a6c-4206-bfdf-0c9f7828ccec',
                );
              }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichText(
                  text: TextSpan(text: 'signuphint1'.translate + " ", style: TextStyle(fontSize: 9.0, color: Fav.secondaryDesign.primaryText), children: [
                    TextSpan(text: 'signuphint2'.translate, style: const TextStyle(fontSize: 10.0, color: Color(0xff6665FF), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    TextSpan(text: " " + 'signuphint3'.translate, style: TextStyle(fontSize: 9.0, color: Fav.secondaryDesign.primaryText))
                  ]),
                  textAlign: TextAlign.center,
                )))
        : const SizedBox();

    return MyQBankScaffold(
      appBar: MyQBankAppBar(visibleBackButton: true, title: ''),
      body: MyForm(
        formKey: _formKey,
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Center(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  shrinkWrap: true,
                  children: <Widget>[
                    32.heightBox,
                    imgWidget,
                    32.heightBox,
                    _userNameTextfield,
                    _password1Textfield,
                    _password2Textfield,
                    16.heightBox,
                    _loginButton,
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                      children: <Widget>[loginButton, googleButton],
//                    ),
                    32.heightBox,
                    _warningText,
                    16.heightBox,
                  ],
                ),
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: imgWidget,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      shrinkWrap: true,
                      children: <Widget>[
                        32.heightBox,
                        _userNameTextfield,
                        _password1Textfield,
                        _password2Textfield,
                        16.heightBox,
                        _loginButton,
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                          children: <Widget>[loginButton, googleButton],
//                        ),
                        32.heightBox,
                        _warningText,
                        16.heightBox,
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
