import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../services/dataservice.dart';

class SchoolInfoPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Map _data = {};

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (Fav.noConnection()) return;

      _data.clear();
      _formKey.currentState!.save();
      OverLoading.show();
      await SchoolDataService.saveSchoolInfo(_data).then((_) {
        OverAlert.saveSuc();
      }).catchError((_) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }

  SchoolInfoPage();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AppVar.appBloc.schoolInfoService!.stream,
        builder: (context, snapshot) {
          return MyForm(
            formKey: _formKey,
            child: Column(
              children: <Widget>[
                if (AppVar.appBloc.schoolInfoService!.singleData!.genelMudurlukName != null)
                  ListTile(
                    title: ('supermanageraccountname'.translate + ': ').text.bold.make(),
                    trailing: AppVar.appBloc.schoolInfoService!.singleData!.genelMudurlukName.text.make(),
                  ).rounded(background: Fav.design.primary.withAlpha(10)),
                MyTextFormField(
                  initialValue: AppVar.appBloc.schoolInfoService!.singleData?.name ?? "",
                  labelText: "name".translate,
                  iconData: MdiIcons.textBox,
                  validatorRules: ValidatorRules(
                    req: true,
                    minLength: 6,
                  ),
                  onSaved: (value) {
                    _data["name"] = value;
                  },
                ),
                MyTextFormField(
                  initialValue: AppVar.appBloc.schoolInfoService!.singleData?.slogan ?? "",
                  labelText: "slogan".translate,
                  iconData: MdiIcons.flag,
                  validatorRules: ValidatorRules(),
                  onSaved: (value) {
                    _data["slogan"] = value;
                  },
                ),
                MyDropDownField(
                  initialValue: AppVar.appBloc.schoolInfoService!.singleData?.eatMenuType,
                  items: [0, 1, 2]
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text('eatmenutype$item'.translate),
                          ))
                      .toList(),
                  name: "eatmenutype".translate,
                  iconData: MdiIcons.foodForkDrink,
                  color: Colors.lightBlueAccent,
                  validatorRules: ValidatorRules(),
                  onSaved: (value) {
                    _data["et"] = value;
                  },
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: MyPhotoUploadWidget(
                    dataImportance: DataImportance.veryHigh,
                    avatarImage: true,
                    validatorRules: ValidatorRules(req: true),
                    initialValue: AppVar.appBloc.schoolInfoService!.singleData?.logoUrl ?? "",
                    saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + "GenerallyFiles",
                    onSaved: (value) {
                      _data["logoUrl"] = value;
                    },
                  ),
                ),
                16.heightBox,
                MyRaisedButton(
                  iconData: Icons.save,
                  text: Words.save,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        });
  }
}
