import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../../services/dataservice.dart';

class PaymentNames extends StatefulWidget {
  PaymentNames({Key? key}) : super(key: key);

  @override
  _PaymentNamesState createState() => _PaymentNamesState();
}

class _PaymentNamesState extends State<PaymentNames> {
  final Map _data = {};
  void _save() {
    if (_formKey.currentState!.checkAndSave()) {
      setState(() {
        _isLoading = true;
      });

      AccountingService.saveAccountingPaymentNames(_data).then((value) {
        OverAlert.saveSuc();
        setState(() {
          _isLoading = false;
        });
      }).catchError((err) {
        OverAlert.saveErr();
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...Iterable.generate(5)
              .map((e) => MyTextFormField(
                    labelText: '${e + 1}',
                    onSaved: (value) {
                      _data['paymenttype${e + 1}'] = value;
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 5),
                    initialValue: AppVar.appBloc.schoolInfoService!.singleData!.paymentName('paymenttype${e + 1}'),
                  ))
              .toList(),
          MyProgressButton(
            isLoading: _isLoading,
            onPressed: _save,
            label: Words.save,
          ),
        ],
      ),
    );
  }
}
