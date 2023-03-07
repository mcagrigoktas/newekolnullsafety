import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import 'models.dart';

class SuperManagerList extends StatefulWidget {
  final String? islemYapilacakKey;
  final Function? onTap;

  final int? sayfaTuru;

  SuperManagerList({this.islemYapilacakKey, this.onTap, this.sayfaTuru});

  @override
  SuperManagerListState createState() {
    return SuperManagerListState();
  }
}

class SuperManagerListState extends State<SuperManagerList> {
  final List<SuperManagerModel> _serverList = [];
  SuperUserInfo get _superUser => Get.find<SuperUserInfo>();
  @override
  void initState() {
    AppVar.appBloc.database1.once('SuperManagers').then((snapshot) {
      _serverList.clear();
      if (snapshot?.value != null) {
        setState(() {
          (snapshot!.value as Map).forEach((k, v) {
            _serverList.add(SuperManagerModel.fromJson(v, k));
          });
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<SuperManagerModel> _filteredList = _serverList.where((item) => item.saver == _superUser.saver.name || _superUser.isDeveloper).toList();
    _filteredList.sort((a, b) => a.key!.compareTo(b.key!));

    var _islargeScreen = context.screenWidth > 600;
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: _islargeScreen ? 12.0 : 24.0),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: ShapeDecoration(color: Fav.design.customDesign4.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
            child: Text(
              "${_filteredList.length}",
              style: const TextStyle(color: Colors.white),
            )),
      ),
      _filteredList.isNotEmpty
          ? Expanded(
              flex: 1,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: _islargeScreen ? 8.0 : 16.0),
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  var item = _filteredList[index];
                  return MyCupertinoListTile(
                    maxLines: 2,
                    onTap: () {
                      widget.onTap!(item.key);
                    },
                    title: item.superManagerServerId,
                    isSelected: widget.islemYapilacakKey == item.key,
                  );
                },
              ),
            )
          : EmptyState(imgWidth: 50),
    ]);
  }
}
