import 'package:flutter/material.dart';

import '../../../../appbloc/appvar.dart';
import 'student.dart';

class StudentDataExtra {
  StudentDataExtra._();

  static List<Widget> widgetList(Student? _data) {
    List<Widget> _widgetList = [];

    if (AppVar.appConfig.appName == 'AppAdi') {
      _data!.flavorad ??= {};
      _widgetList.addAll([
        //? Ornek app adi
        //  MyTextFormField(
        //     initialValue: _data.flavorad['derssaati'],
        //     labelText: "Ders Saati".translate,
        //     iconData: MdiIcons.texture,
        //     validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
        //     onSaved: (value) {
        //       _data.flavorad['derssaati'] = value;
        //     },
        //   ),
      ]);
    }

    return _widgetList;
  }
}
