import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../localization/localization.dart';
import '../../qbank/qbankbloc/openningprocess.dart';
import '../../qbank/qbankbloc/qbankbloc.dart';
import '../../qbank/screens/homepage.dart';
import '../../widgets/errorwidget.dart';
import '../appconfig.dart';

class QbankAppEntry extends StatelessWidget {
  QbankAppEntry();

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return MyErrorWidget(errorDetails: errorDetails);
    };

    return GetMaterialApp(
      theme: Fav.design.themeData,
      darkTheme: Fav.design.themeData,
      color: Fav.design.scaffold.background,
      localizationsDelegates: Lang.delegates,
      localeResolutionCallback: (Locale? deviceLocale, Iterable<Locale> supportedLocales) {
        Lang.setLocalization(deviceLocale);
        return deviceLocale;
      },
      supportedLocales: ['en', 'de', 'tr'].map((locale) => Locale(locale, '')).toList(),
      title: Get.find<AppConfig>().appName,
      home: MyApp(),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return MyErrorWidget(errorDetails: errorDetails);
        };

        return child!;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> with OpeningProcess {
  void _setAppRestartCode() {
    AppVar.qbankBloc.appConfig.qbankRestartApp = (bool? restart) async {
      await AppVar.qbankBloc.dispose();
      if (Get.isRegistered<QbankAppBloc>()) await Get.delete<QbankAppBloc>(force: true);

      Get.offAll(() => MyApp(), transition: Transition.size, duration: 500.milliseconds)!.unawaited;
    };
  }

  bool _appInited = false;
  Future<void> _appInit() async {
    await FirebaseAuth.instance.signOut();
    final qbankBloc = QbankAppBloc();

    Get.put<QbankAppBloc>(qbankBloc, permanent: true);
    AppVar.qbankBloc.init();

    _setAppRestartCode();
    await Lang.initCompleter.future;

    openingProcess();

    SystemChrome.setSystemUIOverlayStyle(Fav.secondaryDesign.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    300.wait.then((value) {
      if (Get.theme.brightness.toString() != Fav.design.themeData.brightness.toString()) {
        log('Tema degistiriliyor');

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
    return HomePage();
  }
}
