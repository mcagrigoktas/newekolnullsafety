import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appbloc.dart';
import '../../appbloc/appvar.dart';
import '../../appbloc/token_notification_service.dart';
import '../../localization/localization.dart';
import '../../screens/loginscreen/loginscreen.dart';
import '../../screens/main/controller.dart';
import '../../screens/main/layout.dart';
import '../../screens/main/macos_dock/macos_dock.dart';
import '../../screens/transporterscreens/main.dart/controller.dart';
import '../../screens/transporterscreens/main.dart/layout.dart';
import '../../website/layout.dart';
import '../../widgets/errorwidget.dart';
import '../appconfig.dart';
import '../themelist/helper.dart';
import 'reviewtermscaffold.dart';

class AppEntry extends StatelessWidget {
  AppEntry();

  @override
  Widget build(BuildContext context) {
    PlatformDispatcher.instance.onError = (error, stack) {
      //todo burayi platformdan gelen datalar icin ayarla
      return false;
    };

    final _themeData = ThemeHelper.getThemeData();
    return GetMaterialApp(
      theme: _themeData,
      darkTheme: _themeData,
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
        },
      ),
      color: Fav.design.scaffold.background,
      localizationsDelegates: Lang.delegates,
      localeResolutionCallback: (deviceLocale, Iterable<Locale> supportedLocales) {
        Lang.setLocalization(deviceLocale);
        return deviceLocale;
      },
      supportedLocales: ['en', 'de', 'tr', 'ru', 'az'].map((locale) => Locale(locale, '')).toList(),
      title: Get.find<AppConfig>().appName,
      home: MyApp(),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return MyErrorWidget(errorDetails: errorDetails);
        };
        return Theme(
          data: ThemeHelper.getThemeData(),
          child: OverWidget(
            child: child!,
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatefulWidget {
  final Map? extraData;

  MyApp({this.extraData});

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  void _setAppRestartCode() {
    AppVar.appBloc.appConfig.ekolRestartApp = (bool restart, [Map? extraData]) async {
      await AppVar.appBloc.dispose();
      if (Get.isRegistered<AppBloc>()) await Get.delete<AppBloc>(force: true);
      if (Get.isRegistered<MainController>()) await Get.delete<MainController>(force: true);

      await Get.offAll(() => MyApp(extraData: extraData), transition: Transition.size, duration: 500.milliseconds);
    };
  }

  bool _appInited = false;

  Future<void> _appInit() async {
    var _auth = FirebaseAuth.instance;
    if (_auth.currentUser != null && _auth.currentUser!.email.safeLength > 4) {
      await FirebaseAuth.instance.signOut();
    }
    await Lang.initCompleter.future;

    await Get.createNewDeleteIfExist<MacOSDockController>(createFunction: () => MacOSDockController(itemList: []), permanent: true);

    final appBloc = AppBloc(restartExtraData: widget.extraData);
    Get.put<AppBloc>(appBloc, permanent: true);
    var _accountIsGood = await AppVar.appBloc.initAccount();
    if (_accountIsGood == true) {
      await AppVar.appBloc.init();
    }
    _setAppRestartCode();

    TokenAndNotificationListenerService.setUp();
    300.wait.then((value) {
      if (Get.theme.brightness.toString() != Fav.design.themeData.brightness.toString()) {
        Get.changeTheme(Fav.design.themeData);
      }
    }).unawaited;

    setState(() {
      _appInited = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _appInit();
  }

  @override
  Widget build(BuildContext context) {
    if (_appInited == false) return Container(color: Fav.design.scaffold.background);

    if (AppVar.appBloc.hesapBilgileri.isGood == false) {
      if (isDebugMode || (isWeb && AppVar.appConfig.flavorType == FlavorType.speedsis)) return WebSiteLayout();
      return EkolSignInPage();
    }

    if (AppVar.appBloc.hesapBilgileri.gtTransporter) {
      if (Get.isRegistered<TransporterMainController>()) Get.delete<TransporterMainController>();
      return TransporterMainPage();
    }

    Get.put<MainController>(MainController(), permanent: true);
    Widget _current = MainMenu();
    if (AppVar.appBloc.reviewTerm == true) _current = ReviewTermScaffold(child: _current);
    return _current;
  }
}
