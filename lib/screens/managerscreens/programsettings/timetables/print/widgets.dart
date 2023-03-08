import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../localization/usefully_words.dart';
import 'helper.dart';

class FullProgramPrint extends StatelessWidget {
  FullProgramPrint();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.heightBox,
        MyTextField(
          labelText: 'margins'.translate,
          iconData: Icons.margin,
          onChanged: (text) {
            Fav.preferences.setInt('printfullprogrammargin', int.tryParse(text) ?? 8);
          },
          initialValue: Fav.preferences.getInt('printfullprogrammargin', 8).toString(),
        ),
        MyRaisedButton(onPressed: TimeTablePrintHelper.printFullProgram, text: Words.print)
      ],
    );
  }
}

class TeacherProgramPrint extends StatelessWidget {
  TeacherProgramPrint();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.heightBox,
        MyTextField(
          labelText: 'margins'.translate,
          iconData: Icons.margin,
          onChanged: (text) {
            Fav.preferences.setInt('printfullprogrammargin', int.tryParse(text) ?? 8);
          },
          initialValue: Fav.preferences.getInt('printfullprogrammargin', 8).toString(),
        ),
        MyTextField(
          maxLines: null,
          labelText: 't_p_h1'.translate,
          iconData: Icons.school_rounded,
          onChanged: (text) {
            Fav.preferences.setString('t_p_h1', text);
          },
          initialValue: Fav.preferences.getString('t_p_h1', 'header'.translate),
        ),
        MyTextField(
          labelText: 'term'.translate,
          iconData: Icons.school_rounded,
          onChanged: (text) {
            Fav.preferences.setString('t_p_h3', text);
          },
          initialValue: Fav.preferences.getString('t_p_h3', AppVar.appBloc.hesapBilgileri.termKey),
        ),
        MyTextField(
          maxLines: null,
          labelText: 't_p_h2'.translate,
          iconData: Icons.person,
          onChanged: (text) {
            Fav.preferences.setString('t_p_h2', text);
          },
          initialValue: Fav.preferences.getString('t_p_h2', AppVar.appBloc.hesapBilgileri.name),
        ),
        MyTextField(
          labelText: 't_p_o'.translate,
          iconData: Icons.numbers,
          onChanged: (text) {
            Fav.preferences.setInt('t_p_o', int.tryParse(text) ?? 1);
          },
          initialValue: Fav.preferences.getInt('t_p_o', 1).toString(),
        ),
        MySwitch(
            name: 'onlyweekday'.translate,
            onChanged: (value) {
              Fav.preferences.setBool('onlyweekdayforprogram', value!);
            },
            initialValue: Fav.preferences.getBool('onlyweekdayforprogram', true)),
        MyMultiSelect(
            context: context,
            items: [
              ...AppVar.appBloc.teacherService!.dataList
                  .map(
                    (e) => MyMultiSelectItem(e.key, e.name),
                  )
                  .toList()
            ],
            onChanged: (value) {
              Fav.writeSeasonCache('t_p_o', value);
            },
            name: Words.teacherList,
            title: Words.teacherList,
            iconData: Icons.list),
        MyRaisedButton(
            onPressed: () {
              TimeTablePrintHelper.printTeacherProgram(Fav.readSeasonCache('t_p_o', []));
            },
            text: Words.print)
      ],
    );
  }
}

class ClassProgramPrint extends StatelessWidget {
  ClassProgramPrint();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.heightBox,
        MyTextField(
          labelText: 'margins'.translate,
          iconData: Icons.margin,
          onChanged: (text) {
            Fav.preferences.setInt('printfullprogrammargin', int.tryParse(text) ?? 8);
          },
          initialValue: Fav.preferences.getInt('printfullprogrammargin', 8).toString(),
        ),
        MyTextField(
          maxLines: null,
          labelText: 't_p_h1'.translate,
          iconData: Icons.school_rounded,
          onChanged: (text) {
            Fav.preferences.setString('t_p_h1', text);
          },
          initialValue: Fav.preferences.getString('t_p_h1', 'header'.translate),
        ),
        MyTextField(
          labelText: 'term'.translate,
          iconData: Icons.school_rounded,
          onChanged: (text) {
            Fav.preferences.setString('t_p_h3', text);
          },
          initialValue: Fav.preferences.getString('t_p_h3', AppVar.appBloc.hesapBilgileri.termKey),
        ),
        MyTextField(
          maxLines: null,
          labelText: 't_p_h2'.translate,
          iconData: Icons.person,
          onChanged: (text) {
            Fav.preferences.setString('t_p_h2', text);
          },
          initialValue: Fav.preferences.getString('t_p_h2', AppVar.appBloc.hesapBilgileri.name),
        ),
        MySwitch(
            name: 'onlyweekday'.translate,
            onChanged: (value) {
              Fav.preferences.setBool('onlyweekdayforprogram', value!);
            },
            initialValue: Fav.preferences.getBool('onlyweekdayforprogram', true)),
        MyMultiSelect(
            context: context,
            items: [
              ...AppVar.appBloc.classService!.dataList
                  .where((element) => element.classType == 0)
                  .map(
                    (e) => MyMultiSelectItem(e.key, e.name),
                  )
                  .toList()
            ],
            onChanged: (value) {
              Fav.writeSeasonCache('t_p_c1', value);
            },
            name: 'classlist'.translate,
            title: 'classlist'.translate,
            iconData: Icons.list),
        MyMultiSelect(
            context: context,
            items: [
              ...AppVar.appBloc.classService!.dataList
                  .where((element) => element.classType != 0)
                  .map(
                    (e) => MyMultiSelectItem(e.key, e.name),
                  )
                  .toList()
            ],
            onChanged: (value) {
              Fav.writeSeasonCache('t_p_c2', value);
            },
            name: 'other'.translate,
            title: 'other'.translate,
            iconData: Icons.list),
        MyRaisedButton(
            onPressed: () {
              TimeTablePrintHelper.printClassProgram([
                ...Fav.readSeasonCache<List<String>>('t_p_c1', [])!,
                ...Fav.readSeasonCache<List<String>>('t_p_c2', [])!,
              ]);
            },
            text: Words.print)
      ],
    );
  }
}
