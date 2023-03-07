import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';

class SplashScreen extends StatefulWidget {
  final int duration;

  SplashScreen({required this.duration});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  MyFile? file;
  bool closeSplash = false;
  String? name;

  @override
  void initState() {
    super.initState();

    final schoolData = AppVar.appBloc.schoolInfoService?.singleData;
    String? logoUrl = schoolData?.logoUrl;
    name = schoolData?.name ?? '';

    Future.delayed(Duration(milliseconds: widget.duration - 333)).then((_) {
      if (mounted) {
        setState(() {
          closeSplash = true;
        });
      }
    });

    Future.microtask(() async {
      if (logoUrl.safeLength > 6) file = await DownloadManager.downloadThenCache(url: logoUrl!);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _current;

    if (closeSplash == true || file == null) {
      _current = const SizedBox();
    } else {
      _current = Material(
        color: Fav.design.scaffold.background,
        child: AnimatedBackground(
          behaviour: isWeb
              ? RandomParticleBehaviour(options: ParticleOptions(baseColor: Fav.design.primary, maxOpacity: 0.2, minOpacity: 0.05, particleCount: 30, spawnMaxSpeed: 70, spawnMinSpeed: 20))
              : RandomParticleBehaviour(options: ParticleOptions(image: Image.file(file!.file), particleCount: 15, spawnMaxSpeed: 140, spawnMinSpeed: 70, spawnMaxRadius: 30.0, maxOpacity: 0.65)),
          vsync: this,
          child: Center(
            child: Column(
              children: <Widget>[
                const Spacer(),
                isWeb ? Image.memory(file!.byteData, width: (context.screenWidth * 3 / 5).clamp(0.0, 300.0)) : Image.file(file!.file, width: (context.screenWidth * 3 / 5).clamp(0.0, 300.0)),
                32.heightBox,
                Padding(padding: const EdgeInsets.all(8.0), child: name.text.fontSize(22).bold.center.make()),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 332),
      child: _current,
    );
  }
}
