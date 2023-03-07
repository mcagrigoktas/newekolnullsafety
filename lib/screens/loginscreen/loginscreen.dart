import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:ntp/ntp.dart';

import '../../adminpages/errorlog.dart';
import '../../adminpages/route_managament.dart';
import '../../adminpages/screens/supermanagerpages/models.dart';
import '../../appbloc/appvar.dart';
import '../../appbloc/databaseconfig.dart';
import '../../appbloc/databaseconfig.model_helper.dart';
import '../../appbloc/jwt.dart';
import '../../constant_settings.dart';
import '../../flavors/appconfig.dart';
import '../../flavors/mainhelper.dart';
import '../../models/accountdata.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../supermanager/supermanagerbloc.dart';
import '../../supermanager/supermanagermain.dart';
import '../../widgets/selectuser.dart';
import '../main/menu_list_helper.dart';
import '../main/widgets/user_profile_widget/user_image_helper.dart';
import 'loginscreen.giris_turu_helper.dart';
import 'loginscreenhelper.dart';
import 'widgets/animated_background.dart';

class EkolSignInPage extends StatefulWidget {
  final String? username;
  final String? password;
  final String? serverId;

  EkolSignInPage({this.serverId, this.username, this.password});

  @override
  _EkolSignInPageState createState() => _EkolSignInPageState();
}

class _EkolSignInPageState extends State<EkolSignInPage> with TickerProviderStateMixin {
  String? _username, _password, _serverId;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  bool _isServerIdOn = true;
  double _liquidValue = 0.0;
  KVKKSettings? _kvkkSettings;
  bool? _kvkkButtonChecked = true;

  LoginScreenState? _loginScreenState;

  final String qrCode = 12.makeKey;

  @override
  void initState() {
    super.initState();
    _loginScreenState = !Fav.preferences.getBool('qrloginenable', false)! ? LoginScreenState.form : LoginScreenState.qr;

    if (AppVar.appBloc.appConfig.kvkkSettings?.isRequired == true) {
      _kvkkSettings = AppVar.appBloc.appConfig.kvkkSettings;
      _kvkkButtonChecked = false;
    }

    _username = widget.username;
    _password = widget.password;
    _serverId = widget.serverId;

    if (_username != null) {
      Future.delayed(Duration.zero, () {
        _validateData(withoutForm: true);
      });
    }

    if (AppVar.appBloc.appConfig.serverIdList != null && AppVar.appBloc.appConfig.serverIdList!.length == 1) {
      _serverId = AppVar.appBloc.appConfig.serverIdList!.first;
      _isServerIdOn = false;
    }

    _fillLoginInformationForDebug();
  }

  @override
  void dispose() {
    _qrCodeSubscription?.cancel();
    super.dispose();
  }

  void _signInError({text}) {
    if (mounted) {
      OverAlert.show(message: text ?? "signinerr".translate, type: AlertType.danger);
      setState(() {
        _signInTrying = false;
        _loginScreenState = LoginScreenState.form;
        _liquidValue = 0.1;
        _isLoading = false;
      });
    }
  }

  StreamSubscription? _qrCodeSubscription;
  void _startQrCodeListen() {
    if (_qrCodeSubscription != null) return;
    if (_loginScreenState != LoginScreenState.qr) return;

    _qrCodeSubscription = SignInOutService.dbQrCodeLogin(qrCode).onValue().listen((event) {
      if (event == null) return;
      if (event.value is! String) return;
      _qrCodeSubscription!.cancel();
      SignInOutService.dbQrCodeLogin(qrCode).remove();
      final _mixedString = event.value as String?;
      final _unMixedString = _mixedString.unMix!;
      final _data = jsonDecode(_unMixedString);
      _username = _data['u'];
      _password = _data['p'];
      _serverId = _data['s'];
      setState(() {
        _loginScreenState = LoginScreenState.existingLogin;
      });
      _validateData(withoutForm: true);
    });
  }

  void _validateData({bool withoutForm = false}) {
    if (withoutForm || _formKey.currentState!.checkAndSave()) {
      if (_username.safeLength == 0 || _password.safeLength == 0 || _serverId.safeLength == 0) return;
      if (_username.safeLength < 6 || _password.safeLength < 6 || _serverId.safeLength < 3) return _signInError();

      if (_serverId == 'errorlogs') {
        Fav.to(ErrorLog());
        return;
      }

      if (_serverId!.startsWith('sa-')) {
        if (!isWeb && isReleaseMode && _username != 'cagri1') {
          OverAlert.show(message: 'Sadece webden giris yapabilirsiniz', type: AlertType.danger);
          return;
        }
        _superadminSignIn();
        return;
      }

      if (!withoutForm && _kvkkSettings != null && _kvkkButtonChecked == false) {
        OverAlert.show(message: _kvkkSettings!.errText_1, type: AlertType.danger);
        return;
      }

      if (_serverId!.startsWith('739')) {
        _superManagerSignIn();
      } else {
        _signIn();
      }
    }
  }

  Future<void> _superadminSignIn() async {
    if (Fav.noConnection()) return;

    setState(() {
      _isLoading = true;
    });

    final _superuser = DatabaseStarter.databaseConfig.superUserModels!.singleWhereOrNull((element) => element.username == _username && element.password == _password);
    if (_superuser == null) return _signInError();

    var sp = await AppVar.appBloc.database1.once('sp');
    if (sp == null || sp.value.toString() != _serverId!.replaceAll('sa-', '')) return _signInError();

    await FirebaseAuth.instance.signInWithEmailAndPassword(email: DatabaseStarter.databaseConfig.superAdminUserName!, password: DatabaseStarter.databaseConfig.superAdminPassword!).then((user) {
      if (user.user == null) return _signInError();
      if (Get.isRegistered<SuperUserInfo>()) Get.delete<SuperUserInfo>(force: true);
      Get.put<SuperUserInfo>(_superuser, permanent: true);

      AdminPagesMainRoutes.goAdminPageHome(_superuser, user.user);
    }).catchError((err) {
      _signInError();
    });
  }

  //Kurum genel mudurluk sayfasi
  void _superManagerSignIn() {
    if (Fav.noConnection()) return;

    setState(() {
      _isLoading = true;
    });

    AppVar.appBloc.database1.once('SuperManagers/$_serverId').then((snap) async {
      if (snap?.value == null) return _signInError();
      final _superManager = SuperManagerModel.fromJson(snap!.value, snap.key);

      if (_superManager.username != _username) return _signInError();
      if (_superManager.password != _password) return _signInError();
      if (_superManager.schoolDataList == null || _superManager.schoolDataList!.isEmpty) return _signInError();

      final _hesapBilgileri = HesapBilgileri();
      _hesapBilgileri.name = 'supermanager'.translate;
      _hesapBilgileri.girisTuru = 200;
      _hesapBilgileri.username = _username;
      _hesapBilgileri.password = _password;
      _hesapBilgileri.kurumID = _serverId;
      await Fav.securePreferences.addItemToMap(UserImageHelper.ekolAllUserPrefKey, _hesapBilgileri.kurumID! + 'SuperManager', _hesapBilgileri.toString());
      setState(() {
        _isLoading = false;
      });
      await Fav.to(SuperManagerHomePage(), binding: BindingsBuilder(() => Get.put<SuperManagerController>(SuperManagerController(_superManager.schoolDataList, _hesapBilgileri))));
    }).catchError((err) {
      _signInError();
    });
  }

  void _changeLiquidValue(double value, [bool? isLoading]) {
    setState(() {
      if (isLoading != null) _isLoading = isLoading;
      _liquidValue = value;
    });
  }

//* Bu degiskenler giris yapamadiginda tekrar denenebilmesi icin olustruldu
  bool _signInTrying = false;
  bool _signInFinished = false;
  Timer? _signinTimer;

  Future<void> _signIn() async {
    _signinTimer?.cancel();
    _signInTrying = true;

    _signinTimer = Timer(Duration(seconds: 10), () {
      if (_signInTrying == true) _signInError(text: 'timeout'.translate);
    });

    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    List<Future<dynamic>> _futureList = [];
//* Demo Data Kontrol ediliyor
    _changeLiquidValue(0.0, true);

    _demoData = null;
    if (_serverId!.trim() == '000000') {
      final _result = await _setupDemoData();
      if (_result != true) return _signInError();
    }

//* Demo Data Kontrolu bitti

//* Okul bilgileri ve versiyon numaralari cekiliyor
    _changeLiquidValue(0.1);

    var _result = await Future.wait([
      SchoolDataService.dbSchoolInfoRef(_serverId).once(),
      SchoolDataService.dbSchoolVersions(_serverId).once(),
    ]);
    Map? _schoolInfo = _result[0]?.value;
    Map? _lastSchoolVersions = _result[1]?.value;

    if (_schoolInfo is! Map || _lastSchoolVersions is! Map || _schoolInfo['aktif'] != true) return _signInError();
    _schoolInfo['lastVersionNo'] = _lastSchoolVersions['SchoolInfo'];

    final String? _schoolLogoUrl = _schoolInfo['logoUrl'];

    if (_schoolLogoUrl.safeLength > 6) _fetchSchoolLogo(_schoolLogoUrl!);

//* Okul bilgileri ve versiyon numaralari cekimi bitti

//* Aktif donem cekimi basladi

    _changeLiquidValue(0.2);
    String? _termKey = (await SignInOutService.checkTerm(_serverId))!.value;
    if (_termKey.safeLength < 2) return _signInError();

//* Aktif donem cekimi bitti

//* Kullanici Varligi cekiliyor
    _changeLiquidValue(0.3);

    if ((_username! + _password!).contains('.')) return _signInError();

    await SignInOutService.checkUser(_username!, _password!, _serverId).then((snapshot) {
      bool _isParent = false;
      int _parentType = 1;

      final _userCheckValue = snapshot!.value;
      if (_userCheckValue == null) return _signInError();

      final String? _uid = _userCheckValue["UID"];
      final int? _girisTuru = _userCheckValue["GirisTuru"];
      final int? _parentNo = _userCheckValue["parentNo"];

      if (_girisTuru == 90 && isWeb) {
        return _signInError(text: 'onlymobilesignin'.translate);
      }

      String _girisTuruKey = LoginScreenGirisTuruHelper.girisTuruKey(_girisTuru);

      if (_girisTuru == 30 && _parentNo != null) {
        _isParent = true;
        _parentType = _parentNo;
      }
//* Kullanici Varligi cekimi bitti

//* Kullanici bilgileri cekiliyor
      _changeLiquidValue(0.4);

      UserInfoService.dbGetUserInfo(_serverId, _girisTuruKey, _uid, _termKey).once().then((snapshot) async {
        _changeLiquidValue(0.5);
        final _userData = snapshot?.value;
        if (_userData == null) return _signInError();
        final _hesapBilgileri = HesapBilgileri();
        _hesapBilgileri.userData = _userData;

        bool? _databaseUserAktif;

        if (_girisTuru == 10) {
          final _manager = Manager.fromJson(_userData, snapshot!.key);
          _databaseUserAktif = _manager.aktif;
          _hesapBilgileri.username = _manager.username;
          _hesapBilgileri.password = _manager.password;
          _hesapBilgileri.imgUrl = _manager.imgUrl;
          _hesapBilgileri.name = _manager.name;

          _hesapBilgileri.authorityList = List<String>.from(_manager.authorityList ?? []);
        } else if (_girisTuru == 20) {
          final _teacher = Teacher.fromJson(_userData, snapshot!.key);
          _databaseUserAktif = _teacher.aktif;
          _hesapBilgileri.username = _teacher.username;
          _hesapBilgileri.password = _teacher.password;
          _hesapBilgileri.imgUrl = _teacher.imgUrl;
          _hesapBilgileri.name = _teacher.name;

          _hesapBilgileri.teacherSeeAllClass = _teacher.seeAllClass ?? false;
        } else if (_girisTuru == 30) {
          final _student = Student.fromJson(_userData, snapshot!.key);
          _databaseUserAktif = _student.aktif;
          _hesapBilgileri.username = _student.username;

          if (_isParent) {
            if (_parentType == 1) {
              _hesapBilgileri.password = _student.parentPassword1;
            } else {
              _hesapBilgileri.password = _student.parentPassword2;
            }
          } else {
            _hesapBilgileri.password = _student.password;
          }

          _hesapBilgileri.imgUrl = _student.imgUrl;
          _hesapBilgileri.name = _student.name;

          _hesapBilgileri.parentState = _student.parentState;

          _hesapBilgileri.class0 = _student.class0 ?? "";
          _hesapBilgileri.groupList = Map<String, String>.from(_student.groupList);

          if (_userData["class1"] != null && !_hesapBilgileri.groupList.containsKey('t1')) {
            _hesapBilgileri.groupList['t1'] = _userData["class1"];
          }
        } else if (_girisTuru == 90) {
          final _transporter = Transporter.fromJson(_userData, snapshot!.key);
          _databaseUserAktif = _transporter.aktif;
          _hesapBilgileri.username = _transporter.username;
          _hesapBilgileri.password = _transporter.password;
          _hesapBilgileri.name = _transporter.driverName;
        } else {
          throw ('Taninmayan giris turu');
        }

        if ((_schoolInfo['limits'] ?? {})['deviceCount'] == 1 && _username != 'demoapple') {
          //todowrong

          if (_userCheckValue['deviceList'] is List && !(_userCheckValue['deviceList'] as List).contains(await DeviceManager.getDeviceModel())) return _signInError(text: 'manydevice'.translate);

          await AppVar.appBloc.database1.set('Okullar/$_serverId/CheckList/${_username! + _password!}/deviceList', [await DeviceManager.getDeviceModel()]);
        }
        _changeLiquidValue(0.6);

        if (_databaseUserAktif != true) return _signInError();
        if (_hesapBilgileri.username != _username || _hesapBilgileri.password != _password) return _signInError();

        _hesapBilgileri.genelMudurlukId = _schoolInfo['gm'] == null ? null : _schoolInfo['gm']['si'];
        _hesapBilgileri.genelMudurlukGroupList = _schoolInfo['gmgl'];
        _hesapBilgileri.termKey = _termKey;
        _hesapBilgileri.girisTuru = _girisTuru;
        _hesapBilgileri.uid = snapshot.key;
        _hesapBilgileri.girisYapildi = true;
        _hesapBilgileri.kurumID = _serverId;
        _hesapBilgileri.schoolType = _schoolInfo['schoolType'] ?? 'ekid';
        _hesapBilgileri.isParent = _isParent;

        if (_isParent) _hesapBilgileri.parentNo = _parentType;

        if (_demoData != null) _hesapBilgileri.demoTime = _demoData!['startTime'];

        if (_hesapBilgileri.isSturdy == false) return _signInError();

        _changeLiquidValue(0.7);
        //todo eger menu listsi ilk acildigind dogru gelmiyorsa burayi gucelle
        await Fav.securePreferences.setHiveMap("${_hesapBilgileri.kurumID}SchoolInfo" + AppConst.dataFetcherBoxVersion.toString(), _schoolInfo, clearExistingData: true);
        await Fav.securePreferences.setHiveMap(_hesapBilgileri.kurumID! + AppConst.versionListBoxVersion.toString(), _lastSchoolVersions, clearExistingData: true);

        _changeLiquidValue(0.8);

        var _newUserToken = Jwt.getUserAuthToken(
          kurumID: _hesapBilgileri.kurumID!,
          girisTuru: _hesapBilgileri.girisTuru,
          iM: _hesapBilgileri.gtM,
          iT: _hesapBilgileri.gtT,
          iS: _hesapBilgileri.gtS,
          uid: _hesapBilgileri.uid!,
        );
        _futureList.add(SignInOutService.firstLoginSuccess(_serverId, _termKey, _hesapBilgileri.uid, _kvkkSettings?.kvkkUrlVersion));

        _changeLiquidValue(0.9);

        await Future.wait(_futureList);
        var _resultToken = await Future.wait([_newUserToken]);
        _hesapBilgileri.signInToken = _resultToken.first;

        //await Fav.preferences.setString("hessapBilgileri", hesapBilgileri.toString());
        _hesapBilgileri.databaseVersion = Get.find<AppConfig>().databaseVersion;
        await _hesapBilgileri.savePreferences();
        await MenuList.savePreferences(kurumId: _serverId, menuList: _schoolInfo['menuList'] ?? []);

        _changeLiquidValue(1.0, false);

        await 100.wait;
        _signinTimer?.cancel();
        if (_signInFinished == false) AppVar.appBloc.appConfig.ekolRestartApp!(true);
        _signInFinished = true;
      }).catchError((error) {
        _signInError();
      });
    }).catchError((error) {
      _signInError();
    });
  }

//  googleSignin(context) async {
//    GoogleSignIn _googleSignIn = GoogleSignIn(
//      scopes: [
//        'email', /*'https://www.googleapis.com/auth/contacts.readonly',*/
//      ],
//    );
//
//    GoogleSignInAccount googleSignInAccount;
//    try {
//      googleSignInAccount = await _googleSignIn.signIn();
//    } catch (error) {
//      print(error);
//      signInError(text:   'errorgooglesignin'));
//    }
//    if (googleSignInAccount == null) {
//      signInError();
//      return;
//    }
//    String mail = googleSignInAccount.email;
//    mail = mail.replaceAll(".", ":");
//    setState(() {
//      isLoading = true;
//    });
//
//    var loginData = await GetDataService.dbGetMailData(mail);
//    if (loginData.value == null) return signInError();
//    var value = loginData.value;
//
//    username = value['username'];
//    password = value['password'];
//    serverId = value['kurumID'];
//
//    signIn(context);
//  }

//  Widget googleButton(context) {
//    return isGmailSignInOn
//        ? CircleAvatar(
//            backgroundColor: Colors.redAccent,
//            child: IconButton(
//                icon: Icon(MdiIcons.google, color: Colors.white),
//                onPressed: () {
//                  googleSignin(context);
//                }))
//        : SizedBox();
//  }

  @override
  Widget build(BuildContext context) {
    //final _textColor = Color.fromARGB(255, 9, 55, 102);
    final _textColor = Color(0xff343434);

    _startQrCodeListen();

    Widget? _kvkkWidget = _kvkkSettings == null
        ? null
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 350),
            child: Theme(
              data: Theme.of(context).copyWith(unselectedWidgetColor: _textColor),
              child: CheckboxListTile(
                checkColor: Colors.white,
                activeColor: _textColor,
                controlAffinity: ListTileControlAffinity.leading,
                value: _kvkkButtonChecked,
                onChanged: (value) {
                  setState(() {
                    _kvkkButtonChecked = value;
                  });
                },
                secondary: InkWell(
                    onTap: () {
                      _kvkkSettings!.url_1.launch(LaunchType.url);
                    },
                    child: Icons.open_in_new.icon.color(_textColor).padding(0).size(16).make()),
                title: _kvkkSettings!.labalText_1.translate.text.fontSize(12).color(_textColor).make(),
              ),
            ),
          );

    Widget _userNameTextfield = LoginFormField(
        imageBackgroundColor: _textColor,
        initialValue: _username ?? '',
        hintText: "sixcharacter".translate,
        labelText: "username".translate,
        iconData: MdiIcons.at,
        onSubmitted: (c) {
          if (kIsWeb) _validateData();
        },
        onSaved: (value) {
          _username = value?.trim();
        });

    Widget _passwordTextfield = LoginFormField(
      imageBackgroundColor: _textColor,
      initialValue: _password ?? '',
      hintText: "sixcharacter".translate,
      labelText: "password".translate,
      iconData: MdiIcons.key,
      obscureText: true,
      onSaved: (value) {
        _password = value?.trim();
      },
      onSubmitted: (c) {
        if (kIsWeb) _validateData();
      },
    );
    Widget _serverIdtextfield = _isServerIdOn
        ? LoginFormField(
            imageBackgroundColor: _textColor,
            initialValue: _serverId ?? '',
            // hintText:   "sixcharacter"),
            labelText: "kurumid".translate,
            iconData: MdiIcons.school,
            onSaved: (value) {
              _serverId = value?.trim();
            },
            onSubmitted: (c) {
              if (kIsWeb) _validateData();
            },
          )
        : const SizedBox();

    final _indicator = AnimatedOpacity(
      duration: const Duration(milliseconds: 122),
      opacity: _isLoading ? 1.0 : 0.0,
      child: SizedBox(
        width: 250,
        height: 4,
        child: LiquidLinearProgressIndicator(
          value: _liquidValue,
          valueColor: const AlwaysStoppedAnimation(Colors.black),
          backgroundColor: Colors.black.withAlpha(50),
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 2.0,
          direction: Axis.horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
        ),
      ),
    );
    Widget _loginButton = Column(
      children: <Widget>[
        if (_kvkkWidget != null) _kvkkWidget,
        40.heightBox,
        _indicator,
        8.heightBox,
        MyProgressButton(
          isLoading: _isLoading,
          color: _textColor,
          textColor: Colors.white,
          fontWeight: FontWeight.bold,
          onPressed: () {
            _validateData();
          },
          label: "signin".translate,
        )
      ],
    );

    Widget _wellcomeText = 'wellcome'.translate.text.color(_textColor).center.fontWeight(FontWeight.w800).height(1.1).fontSize(60).make();
    Widget _hintText = 'loginhint'.translate.text.center.color(_textColor).make();

    final _formsWidget = Column(
      children: [
        Align(
            alignment: Alignment.center,
            child: SelectUserWidget(
              type: SelectUserMenuType.LoginScreen,
              textColor: _textColor,
            )),
        16.heightBox,
        _userNameTextfield,
        16.heightBox,
        _passwordTextfield,
        16.heightBox,
        _serverIdtextfield,
        16.heightBox,
        _loginButton,
        if (isWeb && context.screenWidth > 600)
          IconButton(
              onPressed: () {
                setState(() {
                  _loginScreenState = LoginScreenState.qr;
                  Fav.preferences.setBool('qrloginenable', true);
                });
              },
              icon: Icon(
                Icons.qr_code_rounded,
                color: _textColor,
              )).p16
      ],
    );

    final _activeWidgets = _loginScreenState == LoginScreenState.form
        ? _formsWidget
        : _loginScreenState == LoginScreenState.existingLogin
            ? _indicator
            : _loginScreenState == LoginScreenState.qr
                ? QRWidget('enc:${qrCode.mix}', () {
                    setState(() {
                      _loginScreenState = LoginScreenState.form;
                      Fav.preferences.setBool('qrloginenable', false);
                    });
                  }, _textColor)
                : SizedBox();

    Widget _current = MyForm(
      formKey: _formKey,
      child: SafeArea(
          child: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          shrinkWrap: true,
          children: <Widget>[
            24.heightBox,
            Center(child: _wellcomeText),
            16.heightBox,
            Center(child: _hintText),
            48.heightBox,
            _activeWidgets,
            24.heightBox,
          ],
        ),
      )),
    );

    _current = SignInBackground2(_current);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _current,
    );
  }

  void _fillLoginInformationForDebug() {
    if (isReleaseMode) return;
    if (_username == null) {
      if (autoFillIsSuperadmin) {
        _username = DatabaseStarter.databaseConfig.superUserModels!.first.username;
        _password = DatabaseStarter.databaseConfig.superUserModels!.first.password;
        _serverId = 'sa-132478';
      } else {
        String? _demoOkulText = 'lHoneokG1Rdmou'.unMix;
        _username = _demoOkulText;
        _password = _demoOkulText;
        _serverId = _demoOkulText;
      }
    }
  }

  Map? _demoData;
  Future<bool> _setupDemoData() async {
    _demoData = (await SignInOutService.getDemoInfo(_username!, _password!))?.value;
    if (_demoData == null) return false;
    //todo webden gercek saati bulmaui ekle
    var time = kIsWeb ? DateTime.now() : await NTP.now();
    if (_demoData!['startTime'] + const Duration(days: 7).inMilliseconds < time.millisecondsSinceEpoch) return false;
    _username = _demoData!['username'];
    _password = _demoData!['password'];
    _serverId = _demoData!['serverId'];
    return true;
  }

  void _fetchSchoolLogo(String url) {
    ///Acilisin hizlanmasi icin okul logosunu onceden ceker
    DownloadManager.downloadThenCache(url: url).unawaited;
  }
}
