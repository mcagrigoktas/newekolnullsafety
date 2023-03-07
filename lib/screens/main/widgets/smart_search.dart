import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/manager_authority_helper.dart';
import '../../../models/allmodel.dart';
import '../../accounting/route_management.dart';
import '../../managerscreens/programsettings/route_managament.dart';
import '../../managerscreens/registrymenu/classscreen/layout.dart';
import '../../managerscreens/registrymenu/managersscreen/layout.dart';
import '../../managerscreens/registrymenu/studentscreen/layout.dart';
import '../../managerscreens/registrymenu/teacherscreen/layout.dart';
import '../controller.dart';
import '../menu_list_helper.dart';
import '../tree_view/custom_node.dart';

class SmartSearch extends StatefulWidget {
  final GlobalKey renderKey;
  SmartSearch(this.renderKey) : super(key: renderKey);
  @override
  __SearchWidgetState createState() => __SearchWidgetState();
}

class __SearchWidgetState extends State<SmartSearch> {
  final _focusNode = FocusNode();
  late Function() _focusListenFunction;

  @override
  void initState() {
    _focusListenFunction = () {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
        final RenderBox renderObject = widget.renderKey.currentContext!.findRenderObject() as RenderBox;
        final double leftMargin = renderObject.localToGlobal(Offset.zero).dx;
        final double topMargin = renderObject.localToGlobal(Offset.zero).dy;

        Get.dialog(
            _SmartSearch(
              searchTextFieldLeftMargin: leftMargin,
              searchTextFieldTopMargin: topMargin,
            ),
            useSafeArea: false);
      }
    };
    _focusNode.addListener(_focusListenFunction);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListenFunction);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      focusNode: _focusNode,
      backgroundColor: Fav.design.primaryText.withAlpha(4),
    );
  }
}

class _SmartSearch extends StatefulWidget {
  final double? searchTextFieldLeftMargin;
  final double? searchTextFieldTopMargin;

  _SmartSearch({this.searchTextFieldLeftMargin, this.searchTextFieldTopMargin});

  @override
  _SmartSearchState createState() => _SmartSearchState();
}

class _SmartSearchState extends State<_SmartSearch> {
  final FocusNode _focusNode = FocusNode();

  final List<SearchModel> itemList = [];
  @override
  void initState() {
    super.initState();
    initializeItemList();
    _filteredList = filterItemList('');
    Future.microtask(_focusNode.requestFocus);
  }

  void _addMenuNodeItemChildren(SidebarNode node) {
    if (node.hasChildren == false) {
      itemList.add(SearchModel(
        type: Type.MENU,
        item: node,
        searchText: node.name?.toSearchCase(),
      ));
    } else {
      node.children!.forEach((element) {
        _addMenuNodeItemChildren(element as SidebarNode);
      });
    }
  }

  void initializeItemList() {
    final _mainController = Get.find<MainController>();

    _addMenuNodeItemChildren(_mainController.treeViewNodes!);

    if (AppVar.appBloc.hesapBilgileri.uid == 'Manager1') {
      AppVar.appBloc.managerService!.dataList.forEach((element) {
        itemList.add(SearchModel(type: Type.MANAGER, item: element, searchText: element.name.toSearchCase()));
      });
    }

    AppVar.appBloc.teacherService!.dataList.forEach((element) {
      itemList.add(SearchModel(type: Type.TEACHER, item: element, searchText: element.name.toSearchCase()));
    });
    AppVar.appBloc.classService!.dataList.forEach((element) {
      itemList.add(SearchModel(type: Type.CLASS, item: element, searchText: element.name.toSearchCase()));
    });
    AppVar.appBloc.studentService!.dataList.forEach((element) {
      itemList.add(SearchModel(type: Type.STUDENT, item: element, searchText: element.name.toSearchCase()));
    });
  }

  List<SearchModel> filterItemList(String filterValue) {
    return itemList.where((element) => element.searchText!.contains(filterValue)).toList();
  }

  List<SearchModel>? _filteredList;

  void onChanged(String value) {
    setState(() {
      _filteredList = filterItemList(value.toSearchCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Fav.design.scaffold.background.withAlpha(220),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: widget.searchTextFieldTopMargin,
              child: Icons.arrow_back.icon.onPressed(Get.back).color(Fav.design.primaryText).make(),
            ),
            Positioned(
              left: widget.searchTextFieldLeftMargin,
              top: widget.searchTextFieldTopMargin,
              width: 360,
              child: MySearchBar(
                onChanged: onChanged,
                focusNode: _focusNode,
                resultCount: _filteredList != null && _filteredList!.isNotEmpty ? _filteredList!.length : 0,
              ),
            ),
            if (_filteredList != null)
              Positioned(
                top: widget.searchTextFieldTopMargin! + 16 + 36,
                left: (widget.searchTextFieldLeftMargin! - 90).clamp(16.0, 5000.0),
                right: (context.screenWidth - widget.searchTextFieldLeftMargin! - 450).clamp(16.0, 5000.0),
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topLeft,
                    child: _filteredList!.isEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              Text('norecords'.translate, style: TextStyle(color: Fav.design.primaryText)),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemCount: _filteredList!.length,
                            itemBuilder: (context, index) {
                              var item = _filteredList![index];
                              return Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(color: itemColor(item), borderRadius: BorderRadius.circular(2)),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      //    tileColor: itemColor(item),
                                      leading: itemLeading(item),
                                      trailing: itemTrailing(item),
                                      title: Text(itemName(item)!, style: TextStyle(color: Fav.design.primaryText)),
                                      onTap: () {
                                        // Get.back();
                                        onItemTap(item);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
            if (context.screenWidth > 720 && _filteredList != null && _filteredList!.isNotEmpty)
              Positioned(
                  top: widget.searchTextFieldTopMargin! + 16 + 36,
                  right: 32,
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        'icons'.translate.text.color(Fav.design.primary).bold.make().center,
                        ...[
                          [Colors.teal, 'menu'],
                          [Colors.purple, 'manager'],
                          [Colors.indigoAccent, 'teacher'],
                          [Colors.deepOrangeAccent, 'class'],
                          [Colors.amber, 'student'],
                        ]
                            .map((e) => Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(color: e.first as Color?, borderRadius: BorderRadius.circular(2)),
                                    ),
                                    8.widthBox,
                                    (e.last as String).translate.text.make()
                                  ],
                                ).py4)
                            .toList(),
                        8.heightBox,
                        ...[
                          [Colors.green, 'accounting', Icons.attach_money],
                          [Colors.indigoAccent, 'timetables', Icons.view_comfortable],
                        ]
                            .map((e) => Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: e[0] as Color?,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {},
                                        icon: Icon(
                                          e[2] as IconData?,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    8.widthBox,
                                    (e[1] as String).translate.text.make()
                                  ],
                                ).py4)
                            .toList()
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  void onItemTap(SearchModel model) {
    if (model.type == Type.STUDENT) {
      goStudentInfo(model);
    } else if (model.type == Type.MANAGER) {
      goManagerInfo(model);
    } else if (model.type == Type.TEACHER) {
      goTeacherInfo(model);
    } else if (model.type == Type.CLASS) {
      goClassInfo(model);
    } else if (model.type == Type.MENU) {
      (model.item as SidebarNode).onTap!();
    }
  }

  Widget itemTrailing(SearchModel model) {
    List<Widget> widgetList = [];
    if (model.type == Type.STUDENT) {
      if (MenuList.hasAccounting()) {
        if (AuthorityHelper.hasYetki3(warning: false)) {
          widgetList.add(CircleAvatar(
            radius: 17,
            backgroundColor: Colors.green,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                AccountingMainRoutes.goStudentAccounting(selectedKey: (model.item as Student).key);
              },
              icon: const Icon(Icons.attach_money, color: Colors.white),
            ),
          ));
        }
      }
    }
    if (model.type == Type.TEACHER || model.type == Type.CLASS) {
      if (MenuList.hasTimeTable()) {
        widgetList.add(CircleAvatar(
          radius: 17,
          backgroundColor: Colors.indigoAccent,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (model.type == Type.TEACHER) TimeTablesMainRoutes.goTeacherProgram(initialItem: (model.item as Teacher?));
              if (model.type == Type.CLASS) TimeTablesMainRoutes.goClassProgram(initialItem: (model.item as Class?));
            },
            icon: const Icon(Icons.view_comfortable, color: Colors.white),
          ),
        ));
      }
    }

    return widgetList.isEmpty ? const SizedBox() : Row(mainAxisSize: MainAxisSize.min, children: widgetList);
  }

  String? itemName(SearchModel model) => model.type == Type.MANAGER
      ? (model.item as Manager).name
      : model.type == Type.TEACHER
          ? (model.item as Teacher).name
          : model.type == Type.CLASS
              ? (model.item as Class).name
              : model.type == Type.STUDENT
                  ? (model.item as Student).name
                  : model.type == Type.MENU
                      ? (model.item as SidebarNode).name
                      : '';
  Color itemColor(SearchModel model) => model.type == Type.MANAGER
      ? Colors.purple
      : model.type == Type.TEACHER
          ? Colors.indigoAccent
          : model.type == Type.CLASS
              ? Colors.deepOrangeAccent
              : model.type == Type.STUDENT
                  ? Colors.amber
                  : model.type == Type.MENU
                      ? Colors.teal
                      : Colors.white;
  Widget? itemLeading(SearchModel model) => model.type == Type.MANAGER
      ? profileImageWidget((model.item as Manager).imgUrl)
      : model.type == Type.TEACHER
          ? profileImageWidget((model.item as Teacher).imgUrl)
          : model.type == Type.CLASS
              ? profileImageWidget((model.item as Class).imgUrl)
              : model.type == Type.STUDENT
                  ? profileImageWidget((model.item as Student).imgUrl)
                  : model.type == Type.MENU
                      // ? Icon(Icons.dashboard, size: 36, color: Fav.design.primary)
                      ? null
                      : const SizedBox();

  Widget profileImageWidget(String? url) {
    return url.safeLength > 6 ? CircularProfileAvatar(imageUrl: url, borderColor: Fav.design.primary, borderWidth: 1, elevation: 3, radius: 14.0) : Icon(MdiIcons.accountCircle, color: Fav.design.primary, size: 36);
  }

  void goStudentInfo(SearchModel model) {
    if (AuthorityHelper.hasYetki1()) {
      Fav.guardTo(StudentList(initialItem: (model.item as Student?)));
    }
  }

  void goManagerInfo(SearchModel model) {
    Fav.guardTo(ManagerList(initialItem: (model.item as Manager?)));
  }

  void goTeacherInfo(SearchModel model) {
    Fav.guardTo(TeacherList(initialItem: (model.item as Teacher?)));
  }

  void goClassInfo(SearchModel model) {
    Fav.guardTo(ClassList(initialItem: (model.item as Class?)));
  }
}

class SearchModel {
  final Type? type;
  final dynamic item;
  final String? searchText;

  SearchModel({
    this.type,
    this.item,
    this.searchText,
  });
}

enum Type {
  STUDENT,
  TEACHER,
  CLASS,
  MANAGER,
  MENU,
}
