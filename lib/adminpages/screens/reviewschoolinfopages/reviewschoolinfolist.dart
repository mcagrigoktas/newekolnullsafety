import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import '../../models.dart';

class ReviewSchoolInfoList extends StatefulWidget {
  final String? islemYapilacakKey;
  final Function? onTap;

  ReviewSchoolInfoList({this.islemYapilacakKey, this.onTap});

  @override
  ReviewSchoolInfoListState createState() {
    return ReviewSchoolInfoListState();
  }
}

class ReviewSchoolInfoListState extends State<ReviewSchoolInfoList> {
  List<ServerListItemModel> serverList = [];
  String filterText = "";

  void onFilterChanged(String text) {
    setState(() {
      filterText = text.toLowerCase();
    });
  }

  @override
  void initState() {
    AppVar.appBloc.database1.once('ServerList').then((snapshot) {
      serverList.clear();
      setState(() {
        (snapshot!.value as Map).forEach((k, v) {
          serverList.add(ServerListItemModel(v['saver'], k, v['timeStamp']));
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _superUser = Get.find<SuperUserInfo>();
    final List<ServerListItemModel> filteredList = serverList.where((item) {
      return item.key.contains(filterText) && (item.saver == _superUser.saver.name || _superUser.isDeveloper);
    }).toList();
    filteredList.sort((a, b) => a.key.compareTo(b.key));

    var islargeScreen = context.screenWidth > 600;
    return Column(children: [
      12.heightBox,
      MySearchBar(
        onChanged: onFilterChanged,
        resultCount: filteredList.length,
      ).px16,
      filteredList.isNotEmpty
          ? Expanded(
              flex: 1,
              child: ListView.builder(
                key: const PageStorageKey('reviewschoolinfolist'),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: islargeScreen ? 8.0 : 16.0),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  var item = filteredList[index];
                  return MyCupertinoListTile(
                    maxLines: 2,
                    onTap: () {
                      widget.onTap!(item.key);
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
