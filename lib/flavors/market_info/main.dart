import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../assets.dart';
import '../../localization/localization.dart';
import 'market_info_model.dart';

Future<void> main() async {
  // final _controller = AppController(mapEncKey: 32.makeKey, iVEncKey: 32.makeKey, commonEncryptKey: 32.makeKey)
  //   ..design = Design(
  //     appBar: AppBarDesign(),
  //     accent: Colors.white,
  //     accentText: Colors.white,
  //     primary: Colors.white,
  //     sheet: SheetDesign(),
  //     primaryText: Colors.white,
  //     brightness: Brightness.dark,
  //     bottomNavigationBar: BottomNavigationBarDesign(),
  //     progressIndicator: ProgressIndicatorDesign(),
  //     scaffold: ScaffoldDesign(),
  //     snackBar: SnackBarDesign(),
  //   );
  // Get.put<AppController>(_controller);
  // await _controller.init();

  runApp(Center());

  /// runApp(MarketInfoAppEntry());
}

class MarketInfoAppEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  final _adres = PlatformFunctions.getAdress();

    final _fakeConfig = MarketInfoModel(
      username: 'username',
      password: 'password',
      name: 'Heyyy',
      kurumId: 'Ohh',
      webUrl: 'www.google.com',
      schoolName: 'Okul Adi',
      schoolLogoUrl: 'https://unsplash.com/photos/vfNSWpGw2hQ/download?ixid=MnwxMjA3fDB8MXxzZWFyY2h8M3x8c3x8MHx8fHwxNjQ0MTgzNTc2&force=true&w=640',
    ).toJsonString();

    //  String _cryptedConfig = _adres.split('?d=').last;

    final _config = MarketInfoModel.fromJson(_fakeConfig);

    return GetMaterialApp(
      themeMode: ThemeMode.light,
      color: Colors.white,
      localizationsDelegates: Lang.delegates,
      localeResolutionCallback: (Locale? deviceLocale, Iterable<Locale> supportedLocales) {
        //   Lang.setLocalization(deviceLocale);
        return deviceLocale;
      },
      supportedLocales: ['en', 'de', 'tr', 'ru', 'az'].map((locale) => Locale(locale, '')).toList(),
      title: _config.name!,
      home: MarketInfo(_config),
      builder: (_, child) => child!,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MarketInfo extends StatefulWidget {
  final MarketInfoModel config;
  MarketInfo(this.config);

  @override
  State<MarketInfo> createState() => _MarketInfoState();
}

class _MarketInfoState extends State<MarketInfo> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final _gradient = MyPalette.getGradient(19);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _gradient),
        child: AnimatedBackground(
          vsync: this,
          behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
            baseColor: Colors.white,
            maxOpacity: 0.05,
            minOpacity: 0.001,
            particleCount: 30,
            spawnMaxSpeed: 70,
            spawnMinSpeed: 20,
          )),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.config.schoolLogoUrl != null)
                  ClipRRect(
                    child: MyCachedImage(
                      imgUrl: widget.config.schoolLogoUrl!,
                      width: 256,
                      height: 256,
                    ),
                  ),
                16.heightBox,
                widget.config.schoolName.text.center.color(Colors.white).fontSize(20).make(),
                16.heightBox,
                Row(
                  children: [
                    Image.asset(
                      Assets.images.googlePlayPNG,
                      width: 128,
                      height: 128,
                    ),
                    Image.asset(
                      Assets.images.appStorePNG,
                      width: 128,
                      height: 128,
                    ),
                  ],
                ),
                16.heightBox,
                Row(
                  children: [
                    'username'.text.color(Colors.white).bold.make(),
                    widget.config.username.text.color(Colors.white).bold.make(),
                  ],
                ),
                8.heightBox,
                Row(
                  children: [
                    'password'.text.color(Colors.white).bold.make(),
                    widget.config.password.text.color(Colors.white).bold.make(),
                  ],
                ),
                8.heightBox,
                if (widget.config.kurumId != null)
                  Row(
                    children: [
                      'kurumid'.text.color(Colors.white).bold.make(),
                      widget.config.kurumId.text.color(Colors.white).bold.make(),
                    ],
                  ),
                8.heightBox,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
