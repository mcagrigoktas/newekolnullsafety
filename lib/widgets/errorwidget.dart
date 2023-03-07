import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../assets.dart';
import '../flavors/dbconfigs/other/init_helpers.dart';

class MyErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  MyErrorWidget({this.errorDetails});

  @override
  Widget build(BuildContext context) {
    Fav.timeGuardFunction('lasterrortime', 60.seconds, () async {
      final _firebaseDatabaseApp = await FirebaseInitHelper.getErrorApp();

      await Database(app: _firebaseDatabaseApp).push('ekolerrors/${DateTime.now().millisecondsSinceEpoch.dateFormat("d-MMM-yyyy")}/errors', {
        'e': errorDetails.toString(),
        'p': isWeb
            ? 'W'
            : isAndroid
                ? 'A'
                : isIOS
                    ? 'I'
                    : '?',
      });
    });

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: GestureDetector(
          onLongPress: () {
            OverAlert.show(message: errorDetails.toString(), autoClose: false, title: 'Mesaj', type: AlertType.danger);
          },
          child: RiveSimpeLoopAnimation.asset(
            animation: 'Fire',
            artboard: 'FIRE',
            url: Assets.rive.ekolRIV,
            width: 100,
          ),
        ),
      ),
    );
  }
}
