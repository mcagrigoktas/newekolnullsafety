import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../localization/usefully_words.dart';
import '../../../../services/dataservice.dart';

class AccountingNote extends StatefulWidget {
  final String studentKey;
  AccountingNote(this.studentKey);

  @override
  _AccountingNoteState createState() => _AccountingNoteState();
}

class _AccountingNoteState extends State<AccountingNote> {
  GlobalKey<FormState> formkey = GlobalKey();

  var isLoading = true;
  List<String> data = [];
  @override
  void initState() {
    super.initState();

    AccountingService.dbAccountingNote(widget.studentKey).once().then((snap) {
      if (snap?.value != null) data = List<String>.from(snap!.value);
      setState(() {
        isLoading = false;
        formkey = GlobalKey();
      });
    });
  }

  void save() {
    if (Fav.noConnection()) return;
    data.clear();
    formkey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    AccountingService.addAccountingNot(widget.studentKey, data).then((value) {
      OverDialog.closeDialog();
      OverAlert.saveSuc();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyForm(
        formKey: formkey,
        child: Column(
          children: [
            Text(
              'accountingmote'.translate.toUpperCase(),
              style: TextStyle(color: Fav.design.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            16.heightBox,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < 5; i++)
                      MyTextFormField(
                        enableInteractiveSelection: false,
                        maxLines: null,
                        labelText: 'note'.translate + ' ${i + 1}:',
                        onSaved: (value) {
                          data.add(value);
                        },
                        initialValue: data.length > i ? data[i] : '',
                      ),
                    16.heightBox,
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyFlatButton(
                  text: 'cancel'.translate,
                  onPressed: () {
                    if (!isLoading) OverDialog.closeDialog();
                  },
                ),
                16.widthBox,
                MyProgressButton(
                  label: Words.save,
                  isLoading: isLoading,
                  onPressed: save,
                ),
                16.widthBox,
              ],
            ),
            8.heightBox,
          ],
        ));
  }
}
