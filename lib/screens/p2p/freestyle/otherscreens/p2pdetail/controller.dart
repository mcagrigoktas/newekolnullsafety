import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/mypopupmenubutton.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../services/dataservice.dart';
import '../../model.dart';

class P2PDetailController extends GetxController {
  P2PDetailController(this.model);

  final P2PModel? model;

  @override
  void onInit() {
    super.onInit();
  }

  Widget get timeText1 {
    return model!.startTime!.timeToString.text.fontSize(18).bold.make();
  }

  Widget get timeText2 {
    return ("${model!.duration} ${'minute'.translate}").text.fontSize(16).bold.make();
  }

  Widget get note {
    return (model!.note ?? '').text.fontSize(18).bold.make();
  }

  Widget get peopleText {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      final teacher = AppVar.appBloc.teacherService!.dataListItem(model!.teacherKey!);

      return (teacher?.name ?? '').text.fontSize(22).bold.make();
    } else {
      List<Widget> studentWidgets = [];
      model!.studentList!.forEach((studentKey) {
        final student = AppVar.appBloc.studentService!.dataListItem(studentKey!);
        if (student != null) {
          studentWidgets.add(Row(
            children: [
              Expanded(child: student.name.text.fontSize(20).color(Fav.design.primaryText).bold.make()),
              MyPopupMenuButton(
                  child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
                  onSelected: (value) async {
                    if (value is bool && Fav.hasConnection()) {
                      OverLoading.show();
                      await P2PService.setP2PRollCall1(student, model!, value).then((value) {
                        OverAlert.saveSuc();
                      }).catchError((_) {
                        OverAlert.saveErr();
                      });
                      await OverLoading.close();
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(value: false, child: Text('sendrollcall1'.translate, style: TextStyle(color: Fav.design.primaryText))),
                      PopupMenuItem(value: true, child: Text('sendrollcall0'.translate, style: TextStyle(color: Fav.design.primaryText))),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: -1, child: Text('sendrollcallhint'.translate, style: TextStyle(color: Fav.design.primaryText))),
                    ];
                  }),
            ],
          ).px32.py8);
        }
      });

      return Flexible(
        child: ListView(
          shrinkWrap: true,
          children: studentWidgets,
        ),
      );
    }
  }
}
