import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../services/dataservice.dart';

class ContractHelper {
  ContractHelper._();
  static Future<bool> openLabelSettingsDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _existingData = AppVar.appBloc.schoolInfoForManagerService!.singleData!.contractLabelInfoList();
    Map _newData = {};
    final colorsColumn = Iterable.generate(15)
        .map((e) => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 20,
                height: 16,
                decoration: BoxDecoration(
                  color: MyPalette.getBaseColor(e),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: MyTextFormField(
                  initialValue: _existingData.firstWhereOrNull((element) => element.key == 'c$e')?.value,
                  onSaved: (value) {
                    _newData['c$e'] = value;
                  },
                  validatorRules: e == 0 ? ValidatorRules(minLength: 1, req: true) : ValidatorRules.none(),
                ),
              )
            ]))
        .toList();
    await QuickPage.openFullPage(
      child: MyForm(
        formKey: _formKey,
        child: Column(
          children: colorsColumn,
        ),
      ),
      onSave: () async {
        if (_formKey.currentState!.checkAndSave()) {
          await AccountingService.saveContractLabelSettings(_newData).then((value) {
            OverAlert.saveSuc();
          }).catchError((_) {
            OverAlert.saveErr();
          });
          await 1000.wait;
        }
      },
      title: 'labels'.translate,
      maxWidth: 540,
    );
    return true;
  }
}
