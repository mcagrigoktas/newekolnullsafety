import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../../services/dataservice.dart';

//?Istedigin kadar arttirabilisin ama azaltamazsin
const maxCaseNumber = 15;

class CaseNames extends StatefulWidget {
  CaseNames({Key? key}) : super(key: key);

  @override
  _CaseNamesState createState() => _CaseNamesState();
}

class _CaseNamesState extends State<CaseNames> {
  List<String?> data = Iterable.generate(maxCaseNumber).map((e) => '${e + 1}').toList();

  void _save() {
    if (_formKey.currentState!.checkAndSave()) {
      setState(() {
        isLoading = true;
      });

      AccountingService.saveAccountingCaseNames(data).then((value) {
        OverAlert.saveSuc();
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        OverAlert.saveErr();
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...Iterable.generate(maxCaseNumber)
              .map((e) => MyTextFormField(
                    labelText: '${e + 1}',
                    onSaved: (value) {
                      data[e] = value;
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 1),
                    initialValue: AppVar.appBloc.schoolInfoService!.singleData!.caseName(e + 1),
                  ))
              .toList(),
          MyProgressButton(
            isLoading: isLoading,
            onPressed: _save,
            label: Words.save,
          ),
        ],
      ),
    );
  }
}
