import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';

class ReviewTermScaffold extends StatelessWidget {
  final Widget child;
  ReviewTermScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          child: GestureDetector(
            onTap: () {
              AppVar.appBloc.appConfig.ekolRestartApp!(true);
            },
            child: Container(
              color: Colors.green,
              alignment: Alignment.center,
              child: Text('reviewtermhint'.translate, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
