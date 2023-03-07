import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../supermanagerbloc.dart';

class SuperManagerReviewList extends StatefulWidget {
  final String? islemYapilacakKey;
  final Function? onTap;

  SuperManagerReviewList({this.islemYapilacakKey, this.onTap});

  @override
  SuperManagerReviewListState createState() {
    return SuperManagerReviewListState();
  }
}

class SuperManagerReviewListState extends State<SuperManagerReviewList> {
  final controller = Get.find<SuperManagerController>();

  @override
  Widget build(BuildContext context) {
    var islargeScreen = context.screenWidth > 600;
    final serverList = controller.serverList!;
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: islargeScreen ? 12.0 : 24.0),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: ShapeDecoration(color: Fav.design.customDesign4.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
            child: Text(
              "${serverList.length}",
              style: const TextStyle(color: Colors.white),
            )),
      ),
      serverList.isNotEmpty
          ? Expanded(
              flex: 1,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: islargeScreen ? 8.0 : 16.0),
                itemCount: serverList.length,
                itemBuilder: (context, index) {
                  var item = serverList[index];
                  return MyCupertinoListTile(
                    maxLines: 2,
                    onTap: () {
                      widget.onTap!(item.serverId);
                    },
                    title: item.schoolName,
                    isSelected: widget.islemYapilacakKey == item.serverId,
                  );
                },
              ),
            )
          : EmptyState(imgWidth: 50),
    ]);
  }
}
