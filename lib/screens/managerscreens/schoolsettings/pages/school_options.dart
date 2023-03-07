import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../flavors/appconfig.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../services/dataservice.dart';
import '../models/mutlu_cell.dart';

class SchoolOptions extends StatefulWidget {
  @override
  State<SchoolOptions> createState() => _SchoolOptionsState();
}

class _SchoolOptionsState extends State<SchoolOptions> {
  final mutluCellHeader = 'Mutlucell ayarları';

  final mutluCellHint = 'Mutlucell kullanıcı bilgilerinizi girerek, kullanıcılarınıza mesajları ve diğer birçok bilgilendirmeyi sms olarakta yapabilirsiniz.';

  final _mutluCellFormKey = GlobalKey<FormState>();
  bool _mutluCellIsLoading = false;

  MutluCellConfig? _mutluCellConfig;

  @override
  void initState() {
    super.initState();

    _mutluCellConfig = AppVar.appBloc.schoolInfoService!.singleData!.smsConfig.config<MutluCellConfig>();
  }

  Future<void> _saveMutluCellConfig() async {
    _mutluCellConfig ??= MutluCellConfig();
    if (_mutluCellFormKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      setState(() {
        _mutluCellIsLoading = true;
      });

      await SchoolDataService.saveSmsConfig(SmSConfig.fromData(_mutluCellConfig!.toJson())).then((_) {
        OverAlert.saveSuc();
      }).catchError((_) {
        OverAlert.saveErr();
      });
      setState(() {
        _mutluCellIsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AppVar.appBloc.schoolInfoService!.stream,
        builder: (context, snapshot) {
          return Column(children: <Widget>[
            if (AppVar.appConfig.smsCountry == Country.tr)
              Card(
                child: Form(
                  key: _mutluCellFormKey,
                  child: Column(
                    children: [
                      mutluCellHeader.text.bold.fontSize(20).make(),
                      8.heightBox,
                      MyTextFormField(
                        initialValue: _mutluCellConfig?.username ?? "",
                        labelText: "username".translate,
                        iconData: MdiIcons.account,
                        validatorRules: ValidatorRules(
                          req: true,
                          minLength: 3,
                        ),
                        obscureText: true,
                        onSaved: (value) {
                          _mutluCellConfig!.username = value;
                        },
                      ),
                      MyTextFormField(
                        initialValue: _mutluCellConfig?.password ?? "",
                        labelText: "password".translate,
                        iconData: MdiIcons.formTextboxPassword,
                        validatorRules: ValidatorRules(
                          req: true,
                          minLength: 3,
                        ),
                        obscureText: true,
                        onSaved: (value) {
                          _mutluCellConfig!.password = value;
                        },
                      ),
                      MyTextFormField(
                        initialValue: _mutluCellConfig?.originator ?? "",
                        labelText: "Originatör".translate,
                        iconData: MdiIcons.origin,
                        validatorRules: ValidatorRules(
                          req: false,
                          minLength: 0,
                        ),
                        onSaved: (value) {
                          _mutluCellConfig!.originator = value;
                        },
                        obscureText: true,
                      ),
                      mutluCellHint.text.fontSize(10).make().p8,
                      MyProgressButton(
                        onPressed: _saveMutluCellConfig,
                        label: Words.save,
                        mini: true,
                        isLoading: _mutluCellIsLoading,
                      ),
                      8.heightBox,
                    ],
                  ),
                ),
              )
          ]);
        });
  }
}
