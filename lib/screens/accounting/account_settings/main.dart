import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'case_names.dart';
import 'student_payment_names.dart';

class AccountingSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffoldWithTabBar(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      title: TopActionsTitle(title: "accountingsettings".translate),
      tabs: [
        ScaffoldTabMenu(
            name: "casenames".translate,
            body: Body.singleChildScrollView(
                child: CaseNames(
              key: const Key('CaseNames'),
            )),
            value: 0),
        ScaffoldTabMenu(
            name: "paymentnames".translate,
            body: Body.singleChildScrollView(
                child: PaymentNames(
              key: const Key('PaymentNames'),
            )),
            value: 1),
        //todo  bu kismi kendi sozlesmesini yapmak isteyen okullar gelince ac
        // if (AppVar.appBloc.hesapBilgileri.kurumID.startsWith('demo'))
        //   ScaffoldTabMenu(
        //       name: "editstudentregistercontract".translate,
        //       body: Body.child(
        //           child: StudentContractEditor(
        //         key: const Key('editstudentregistercontract'),
        //       )),
        //       value: 2),
      ],
    );
  }
}
