import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/allmodel.dart';
import 'controller.dart';

class P2PStudentList extends StatefulWidget {
  P2PStudentList();

  @override
  State<P2PStudentList> createState() => _P2PStudentListState();
}

class _P2PStudentListState extends State<P2PStudentList> {
  final controller = Get.find<P2PController>();

  String? _studentFilterText;
  String _filteredStudentClassKey = 'all';

  final Map<String?, String?> _studentNameCaches = {};

  void _onFilterChanged(String text) {
    _studentFilterText = text.toSearchCase();
    _makeFilter();
  }

  void _onClassChange(String value) {
    _filteredStudentClassKey = value;
    _makeFilter();
  }

  late List<Student> _filteredList;
  void _makeFilter() {
    _filteredList = _studentFilterText.safeLength > 1 ? AppVar.appBloc.studentService!.dataList.where((item) => item.getSearchText().contains(_studentFilterText!)).toList() : AppVar.appBloc.studentService!.dataList;

    if (_filteredStudentClassKey == 'all') {
      //Birsey yapma
    } else {
      _filteredList = _filteredList.where((student) {
        if (_filteredStudentClassKey == 'noclass') {
          if (student.class0 == null) return true;
          if (student.class0 == '') return true;
          if (AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == student.class0) == null) return true;
          return false;
        }

        if (controller.classListContainsClassTypes) {
          return student.classKeyList.contains(_filteredStudentClassKey);
        } else {
          return _filteredStudentClassKey == student.class0;
        }
      }).toList();
    }

    setState(() {});
  }

  @override
  void initState() {
    _filteredList = AppVar.appBloc.studentService!.dataList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      12.heightBox,
      MySearchBar(
        onChanged: _onFilterChanged,
        resultCount: _filteredList.length,
      ).px4,
      Row(
        children: [
          Expanded(
            child: AdvanceDropdown(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
              nullValueText: 'chooseclass'.translate,
              searchbarEnableLength: 100,
              items: AppVar.appBloc.classService!.dataList
                  .where((element) {
                    if (controller.classListContainsClassTypes) return true;
                    return element.classType == 0;
                  })
                  .map((sinif) => DropdownItem(
                        name: sinif.name,
                        value: sinif.key,
                      ))
                  .toList()
                ..insert(0, DropdownItem(name: 'all'.translate, value: 'all'))
                ..add(DropdownItem(name: 'noclassstudent'.translate, value: 'noclass')),
              onChanged: _onClassChange,
              initialValue: _filteredStudentClassKey,
            ),
          ),
          if (['all', null, 'noclass'].every((element) => element != _filteredStudentClassKey))
            (controller.selectedStudentList.isEmpty ? Icons.select_all : Icons.deselect_outlined)
                .icon
                .onPressed(() {
                  if (controller.selectedStudentList.isEmpty) {
                    controller.selectedStudentList.addAll(AppVar.appBloc.studentService!.dataList.where((element) => element.classKeyList.contains(_filteredStudentClassKey)).map((e) => e.key).toList());
                  } else {
                    controller.selectedStudentList.clear();
                  }
                  controller.setupEventList();
                  setState(() {});
                })
                .color(Fav.design.primaryText)
                .make(),
        ],
      ),
      _filteredList.isNotEmpty
          ? Expanded(
              flex: 1,
              child: ListView.builder(
                key: const PageStorageKey('studentListp2p'),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  var item = _filteredList[index];

                  Widget current = MyCupertinoListTile(
                      // islargeScreen: true,
                      onTap: () async {
                        _studentNameCaches[item.key] = item.name;
                        await controller.selectStudent(item.key);
                        setState(() {});
                      },
                      title: item.name,
                      imgUrl: item.imgUrl,
                      isSelected: controller.selectedStudentList.contains(item.key));

                  current = Row(
                    children: [
                      Expanded(child: current),
                      QudsPopupButton(
                        key: ValueKey(item.key + 'p2p'),
                        backgroundColor: Fav.design.scaffold.background,
                        itemBuilder: (context) {
                          return [
                            QudsPopupMenuWidget(builder: (context) {
                              final _student = AppVar.appBloc.studentService!.dataListItem(item.key)!;
                              final _class = AppVar.appBloc.classService!.dataListItem(_student.class0!);

                              List<Widget> _eventList = [];

                              controller.logFetcher.dataList
                                  .where((e) => e.studentKey == item.key
                                      // && e.startTime > DateTime.now().millisecondsSinceEpoch - const Duration(days: 30).inMilliseconds
                                      )
                                  .forEach((e) {
                                final _text = (AppVar.appBloc.teacherService!.dataListItem(e.teacherKey!)?.name ?? '') + ' ' + '${"week".translate}:${e.week}' + ' ' + McgFunctions.getDayNameFromDayOfWeek(e.day ?? 1) + ' ';
                                final _textWidget = RichText(
                                    text: TextSpan(children: [
                                  TextSpan(text: _text),
                                  TextSpan(
                                      text: e.yoklama == true
                                          ? "(${'rollcall0'.translate})"
                                          : e.yoklama == false
                                              ? "(${'rollcall1'.translate})"
                                              : '',
                                      style: TextStyle(color: e.yoklama == true ? Colors.green : Colors.red)),
                                ], style: TextStyle(color: Fav.design.primaryText)));
                                _eventList.add(_textWidget);
                              });

                              if (_eventList.isEmpty) {
                                _eventList.add('norecords'.translate.text.center.color(Fav.design.primaryText).make());
                              }
                              Widget _current = Column(
                                children: _eventList,
                              );
                              _current = Column(
                                children: [
                                  8.heightBox,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _student.name.text.make(),
                                      if (_class != null) _class.name.text.make(),
                                    ],
                                  ),
                                  Divider(),
                                  'pastp2p'.translate.text.center.color(Fav.design.primary).center.bold.make(),
                                  Divider(),
                                  _current,
                                ],
                              );

                              return _current;
                            }),
                          ];
                        },
                        child: Icons.info_outline.icon.color(Fav.design.selectableListItem.unselectedText.withAlpha(170)).padding(2).size(18).make(),
                      ),
                    ],
                  );

                  return current;
                },
              ),
            )
          : EmptyState(imgWidth: 50),
      if (controller.selectedStudentList.isNotEmpty)
        Row(
          children: [
            Expanded(
              child: Wrap(
                children: controller.selectedStudentList
                    .map((e) => (_studentNameCaches.putIfAbsent(e, () => AppVar.appBloc.studentService!.dataListItem(e)!.name) ?? '').capitalLettersJoin(characterCount: 2, joinCharacter: '.').text.color(Colors.white).fontSize(10).make().rounded(background: Fav.design.primary, borderRadius: 2).p2)
                    .toList()
                  ..add(GestureDetector(
                      onTap: () {
                        controller.selectedStudentList.clear();
                        controller.setupEventList();
                        setState(() {});
                      },
                      child: 'clear'.translate.text.color(Colors.white).fontSize(10).make().rounded(background: Colors.red, borderRadius: 2).p2)),
              ),
            ),
          ],
        )
    ]);
  }
}
