import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/print/otherprint.dart';
import '../../../library_helper/excel/eager.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../../services/smssender.dart';
import '../registrymenu/studentscreen/controller.dart';

class FirstLoginList extends StatefulWidget {
  @override
  _FirstLoginListState createState() => _FirstLoginListState();
}

class _FirstLoginListState extends State<FirstLoginList> {
  Map? _loginData;
  late List<Student> _studentList;
  int _loginCount = 0;
  @override
  void initState() {
    super.initState();

    _studentList = AppVar.appBloc.studentService!.dataList;
    SignInOutService.getLoginList().then((snap) {
      _loginData = snap!.value;
      final List _loginDataKeys = _loginData!.keys.toList();

      _studentList.forEach((student) {
        if (_loginDataKeys.contains(student.key)) _loginCount++;
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'menu1'.translate,
      ),
      topActions: _loginData == null
          ? TopActionsTitle(title: 'firstloginlist'.translate)
          : TopActionsTitleWithChild(
              title: TopActionsTitle(title: 'firstloginlist'.translate),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_loginCount/${_studentList.length}',
                    style: TextStyle(color: Fav.design.appBar.text, fontWeight: FontWeight.bold),
                  ),
                  16.widthBox,
                  MyMiniRaisedButton(
                    text: Words.print,
                    onPressed: () {
                      OtherPrint.printFirstLoginList(_loginData);
                    },
                    iconData: Icons.print,
                  ),
                  16.widthBox,
                  MyMiniRaisedButton(
                    text: 'exportexcell'.translate,
                    onPressed: () {
                      ExcelLibraryHelper.export([
                        ['name'.translate, 'state'.translate],
                        ...AppVar.appBloc.studentService!.dataList.map((e) => [e.name, _loginData![e.key] == true ? 'yes'.translate : 'no'.translate]).toList()
                      ], 'firstloginlist'.translate);
                    },
                    iconData: Icons.table_chart,
                  ),
                  16.widthBox,
                  if (kIsWeb)
                    MyMiniRaisedButton(
                      text: 'sendsmsallusertounsignuser'.translate,
                      onPressed: () async {
                        final List _loginDataKeys = _loginData!.keys.toList();
                        List<UserAccountSmsModel> _smsModelList = [];
                        _studentList.forEach((student) {
                          if (_loginDataKeys.contains(student.key) == false) {
                            var list = StudentSmsPrepare.prepare(student);
                            _smsModelList.addAll(list);
                          }
                        });
                        final lastSendTime = await RandomDataService.dbGetRandomLog('sendsmsallusertounsignuser').once();
                        if (DateTime.now().millisecondsSinceEpoch - (lastSendTime?.value ?? 0) > const Duration(days: 1).inMilliseconds) {
                          final result = await SmsSender.sendUserAccountWithSms(_smsModelList);
                          if (result == true) await RandomDataService.setRandomLog('sendsmsallusertounsignuser', DateTime.now().millisecondsSinceEpoch);
                        } else {
                          'sendsmsallusertounsignuserdelay'.translate.showAlert();
                        }
                      },
                      iconData: Icons.sms,
                    ),
                ],
              )),
      body: _loginData == null
          ? Body.child(child: MyProgressIndicator(isCentered: true))
          : Body.listviewBuilder(
              maxWidth: 540,
              itemCount: _studentList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _studentList[index].name!,
                    style: TextStyle(color: Fav.design.primaryText),
                  ),
                  trailing: Icon(
                    _loginData![_studentList[index].key] == true ? Icons.done_all : Icons.remove,
                    color: _loginData![_studentList[index].key] == true ? Colors.green : Fav.design.primaryText.withAlpha(125),
                  ),
                );
              }),
    );
  }
}
