import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../appbloc/appvar.dart';
import '../../services/dataservice.dart';
import 'ekidrollcallstudent.dart';

class EkidRollCallManagerStudentReview extends StatefulWidget {
  EkidRollCallManagerStudentReview();

  @override
  _EkidRollCallManagerStudentReviewState createState() => _EkidRollCallManagerStudentReviewState();
}

class _EkidRollCallManagerStudentReviewState extends State<EkidRollCallManagerStudentReview> {
  @override
  void initState() {
    super.initState();
  }

  List<EkidRolCallStudentModel> dataList = [];
  String dropDownValue = '-';
  bool isLoading = false;
  void getData(studentKey) {
    setState(() {
      dropDownValue = studentKey;
      isLoading = true;
    });
    if (studentKey == null) {
      setState(() {
        dataList.clear();
        isLoading = false;
      });
    } else {
      RollCallService.dbEkidStudentGetRollCall(studentKey).once().then((snap) {
        setState(() {
          if (snap?.value != null) {
            (snap!.value as Map).forEach((key, value) {
              dataList.add(EkidRolCallStudentModel.fromJson(value, key));
            });
          }
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(
          title: 'rollcallstudentreview'.translate,
        ),
        child: AdvanceDropdown(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            initialValue: dropDownValue,
            name: 'studentlist'.translate,
            iconData: Icons.line_style,
            items: AppVar.appBloc.studentService!.dataList.map((student) => DropdownItem(name: student.name, value: student.key)).toList()
              ..insert(
                  0,
                  DropdownItem(
                    value: '-',
                    name: 'choosestudent'.translate,
                  )),
            onChanged: getData),
      ),
      body: isLoading
          ? Body.circularProgressIndicator()
          : Body.child(
              maxWidth: 540,
              child: dataList.isEmpty
                  ? EmptyState(imgWidth: 50)
                  : EkidRollCallStudentPage(
                      hasScaffold: false,
                      itemList: dataList,
                    ),
            ),
    );
  }
}
