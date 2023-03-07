import 'package:animated_background/animated_background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/accountdata.dart';
import '../../../assets.dart';
import '../../models/models.dart';
import '../../qbankbloc/getdataservice.dart';
import '../../qbankbloc/setdataservice.dart';
import 'signup.dart';

class SignInPage extends StatefulWidget {
  SignInPage();

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool _isLoading = false;

  String? _username;
  String? _password1;

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
//     OverAlert.show(type: AlertType.danger, message:  'signinerr'));
//      return;
//    }
//    if (googleSignInAccount == null) {
//     OverAlert.show(type: AlertType.danger, message:  'signinerr'));
//      return;
//    }
//    String mail = googleSignInAccount.email;
//    setState(() {
//      isLoading = true;
//    });
//    username = mail;
//    password1 = 10.makeKey;
//    login(true);
//  }

  Future<void> _signInMail() async {
    if (_formKey.currentState!.validate()) {
      if (Fav.noConnection()) return;

      _formKey.currentState!.save();

      if (_username == 'sorubankasieditor@gmail.com' || _username!.contains('editor')) {
        await _editorSignIn();
        return;
      }

      if (!_username!.contains("@") || !_username!.contains(".") || _username!.length < 10) {
        OverAlert.show(message: 'emailhint'.translate);
        return;
      }

      if (_username!.contains("\$") || _username!.contains("[") || _username!.contains("]") || _username!.contains("#") || _username!.contains("/") || _username!.contains("\\")) {
        OverAlert.show(message: 'emailhint'.translate);
        return;
      }

      await _login(false);
    }
  }

  Future<void> _editorSignIn() async {
    setState(() {
      _isLoading = true;
    });
    if (_username != 'sorubankasieditor@gmail.com' && (_username!.length != 11 || int.tryParse(_username!.substring(6))! % 71 != 0)) {
      OverAlert.show(type: AlertType.danger, message: 'signinerr'.translate);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    var snap = await AppVar.qbankBloc.databaseSBB.once('sp');

    var password = snap?.value;

    if (_password1 == password.toString()) {
      QBankHesapBilgileri hesapBilgileri = QBankHesapBilgileri();
      hesapBilgileri.schoolType = 'qbank';
      hesapBilgileri.uid = _username;
      hesapBilgileri.girisYapildi = true;
      hesapBilgileri.name = 'Editor';
      hesapBilgileri.imgUrl = ''; //todo buraya guzel bir resim koy
      hesapBilgileri.girisTuru = _username == 'sorubankasieditor@gmail.com' ? 100 : 101;
      await Fav.preferences.setInt('lastqbankeditorlogintime', DateTime.now().millisecondsSinceEpoch);
      //    Fav.preferences.setString("qbankHesapBilgileri", hesapBilgileri.toString());
      await hesapBilgileri.savePreferences();
      AppVar.qbankBloc.appConfig.qbankRestartApp!(true);
    } else {
      OverAlert.show(type: AlertType.danger, message: 'signinerr'.translate);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login(bool isGoogle) async {
    setState(() {
      _isLoading = true;
    });

    String model = await DeviceManager.getDeviceModel();

    (isGoogle ? QBGetDataService.getGoogleLoginData(_username!) : QBGetDataService.getLoginData(_username!, _password1!)).then((snap) async {
      if (snap!.value == null) {
        setState(() {
          _isLoading = false;
        });
        OverAlert.show(type: AlertType.danger, message: 'signinerr'.translate);
        return;
      }
      List deviceList = List<String>.from(snap.value['deviceList'] ?? []);
      if (_username != 'apple@apple.com' && deviceList.length > 1 && !deviceList.contains(model)) {
        setState(() {
          _isLoading = false;
        });
        OverAlert.show(type: AlertType.danger, message: 'manydeviceloginerr'.translate);
        return;
      }
      if (!deviceList.contains(model)) {
        await QBSetDataService.addLoginDevice(snap.value['username'], snap.value['password'], deviceList..add(model));
      }

      QBGetDataService.getUserInfo(AppVar.qbankBloc.databaseSBB, snap.value['uid']).then((snapUserInfo) async {
        Map userInfo = snapUserInfo!.value ?? {};

        QBankHesapBilgileri hesapBilgileri = QBankHesapBilgileri()
          ..schoolType = 'qbank'
          ..username = snap.value['username']
          ..password = snap.value['password']
          ..uid = snap.value['uid']
          ..girisYapildi = true
          ..name = userInfo['name'] ?? ''
          ..imgUrl = userInfo['imgUrl'] ?? ''
          ..purchasedList = ((((userInfo['bookList'] ?? {}) as Map).values.map((item) => PurchasedBookData.fromJson(item)).toList())..removeWhere((item) => item.status != 10))
          ..girisTuru = 30;

        //  Fav.preferences.setString("qbankHesapBilgileri", hesapBilgileri.toString());
        await hesapBilgileri.savePreferences();
        AppVar.qbankBloc.appConfig.qbankRestartApp!(true);
      }).catchError((err) {
        setState(() {
          _isLoading = false;
        });
        OverAlert.show(type: AlertType.danger, message: 'manydeviceloginerr'.translate);
        return;
      }).unawaited;
    }).unawaited;
  }

  @override
  Widget build(BuildContext context) {
    Widget _imgWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Image.asset(
          Assets.images.loginilPNG,
        ));

    var _userNameTextfield = MyTextFormField(
      keyboardType: TextInputType.emailAddress,
      iconData: MdiIcons.at,
      hintText: 'emailhint'.translate,
      labelText: 'mailadress'.translate,
      onSaved: (value) {
        _username = value;
      },
      validatorRules: ValidatorRules(noGap: true, req: true),
      initialValue: !kReleaseMode ? 'sorubankasieditor@gmail.com' : '',
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
      initialValue: !kReleaseMode ? '887766' : '',
    );

    Widget _loginButton = Align(
        child: MyProgressButton(
      isLoading: _isLoading,
      onPressed: _signInMail,
      label: "signin".translate,
    ));

    Widget _signUpButton = Align(
        alignment: Alignment.center,
        ////tododanger
        child: OutlinedButton(
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Text(
            "signup".translate,
            style: TextStyle(color: Fav.secondaryDesign.primaryText),
          ),
          onPressed: () {
            Fav.to(SignUpPage());
          },
        ));

//    Widget googleButton = RaisedButton(
//      onPressed: signUpGoogle,
//      color: Colors.redAccent,
//      child: Text(
//         'gmailsignin'),
//        style: TextStyle(color: Colors.white),
//      ),
//    );

    return MyQBankScaffold(
      appBar: MyQBankAppBar(visibleBackButton: true, title: ''),
      body: AnimatedBackground(
        vsync: this,
        behaviour: RacingLinesBehaviour(
          numLines: 4,
        ),
        child: MyForm(
          formKey: _formKey,
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? Center(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    shrinkWrap: true,
                    children: <Widget>[
                      32.heightBox,
                      _imgWidget,
                      48.heightBox,
                      _userNameTextfield,
                      _password1Textfield,
                      16.heightBox,
                      _loginButton,
                      32.heightBox,
                      _signUpButton,
                      32.heightBox,
                    ],
                  ),
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: _imgWidget,
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
                          16.heightBox,
                          _loginButton,
                          32.heightBox,
                          _signUpButton,
                          16.heightBox,
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
