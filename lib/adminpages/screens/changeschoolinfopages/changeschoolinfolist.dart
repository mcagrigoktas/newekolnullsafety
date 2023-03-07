import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import '../../models.dart';

class ChangeSchoolInfoList extends StatefulWidget {
  final String? islemYapilacakKey;
  final Function(String, String) onTap;

  ChangeSchoolInfoList({this.islemYapilacakKey, required this.onTap});

  @override
  ChangeSchoolInfoListState createState() {
    return ChangeSchoolInfoListState();
  }
}

class ChangeSchoolInfoListState extends State<ChangeSchoolInfoList> {
  List<ServerListItemModel> serverList = [];
  String filterText = "";
  String? selectedSaverName;

  void onFilterChanged(String text) {
    setState(() {
      filterText = text.toLowerCase();
    });
  }

  SuperUserInfo get _superUser => Get.find<SuperUserInfo>();
  @override
  void initState() {
    AppVar.appBloc.database1.once('ServerList').then((snapshot) {
      serverList.clear();
      if (mounted) {
        setState(() {
          (snapshot!.value as Map).forEach((k, v) {
            serverList.add(ServerListItemModel(v['saver'], k, v['timeStamp']));
          });
        });
      }
    });

    selectedSaverName = _superUser.isDeveloper ? Saver.elseif.name : _superUser.saver.name;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<ServerListItemModel> filteredList = serverList.where((item) {
      return item.key.contains(filterText) && (item.saver == selectedSaverName);
    }).toList();
    filteredList.sort((a, b) => a.key.compareTo(b.key));

    var islargeScreen = context.screenWidth > 600;
    return Column(children: [
      if (_superUser.isDeveloper)
        AdvanceDropdown<String>(
          items: [...Saver.values.map((e) => DropdownItem(name: e.name, value: e.name)).toList()],
          initialValue: selectedSaverName,
          onChanged: (value) {
            setState(() {
              selectedSaverName = value;
            });
          },
        ),
      MySearchBar(
        onChanged: onFilterChanged,
        resultCount: filteredList.length,
      ).px16,
      filteredList.isNotEmpty
          ? Expanded(
              flex: 1,
              child: ListView.builder(
                key: const PageStorageKey('changeschoolinfolist'),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: islargeScreen ? 8.0 : 16.0),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  var item = filteredList[index];
                  return MyCupertinoListTile(
                    onTap: () {
                      widget.onTap(item.key, item.saver!);
                    },
                    title: item.key + ' / ' + item.timeStamp!.dateFormat("d-MM-yy"),
                    isSelected: widget.islemYapilacakKey == item.key,
                  );
                },
              ),
            )
          : EmptyState(imgWidth: 50),
    ]);
  }
}
