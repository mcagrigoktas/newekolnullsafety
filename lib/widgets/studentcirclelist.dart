import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/mycircularprofileavatar.dart';

import '../models/allmodel.dart';

class StudentCircleList extends StatelessWidget {
  final List<Student>? studentList;
  final bool isRow;
  final Function(String?)? onPressed;
  final String? selectedKey;
  final String? scrollKey;
  final Color borderColor;
  final Color? foregroundColor;
  StudentCircleList({this.studentList, this.isRow = false, this.onPressed, this.selectedKey, this.scrollKey, this.borderColor = Colors.black, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    if (isRow) {
      return SizedBox(
        height: 64,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          scrollDirection: Axis.horizontal,
          key: PageStorageKey(scrollKey),
          itemCount: studentList!.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 266),
              height: 64,
              width: selectedKey == studentList![index].key ? 100 : 50,
              padding: EdgeInsets.symmetric(vertical: selectedKey == studentList![index].key ? 3 : 6, horizontal: 3),
              child: CircularProfileAvatar(
                  imageUrl: studentList![index].imgUrl,
                  borderWidth: selectedKey == studentList![index].key ? 3 : 1,
                  //   elevation: kIsWeb ? 0 : 5,
                  showInitialTextAbovePicture: true,
                  borderColor: selectedKey == studentList![index].key ? (borderColor) : Fav.design.disablePrimary,
                  initialsText: studentList![index].name.text.center.autoSize.maxLines(2).fontSize(12).bold.color(Colors.white).make().p4,
                  foregroundColor: foregroundColor!.withAlpha(150),
                  onTap: () {
                    onPressed!(studentList![index].key);
                  }),
            );
          },
        ),
      );
    }

    int crossAxisCount = 4;

    if (context.screenWidth > 600) {
      crossAxisCount = 7;
    } else if (studentList!.length < 7) {
      crossAxisCount = 2;
    } else if (studentList!.length < 13) {
      crossAxisCount = 3;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "choosestudent".translate,
                  style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              )),
          Positioned.fill(
              child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
            padding: const EdgeInsets.only(top: 32),
            itemCount: studentList!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircularProfileAvatar(
                    //  imageUrl: (studentList[index].imgUrl ?? '') == '' ? 'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o/UygyulamaDosyalari%2Fekidemptyprofilephoto.png?alt=media&token=12cdc53f-3f87-484b-937c-a55d0ecad906' : (studentList[index].imgUrl ?? ''),
                    imageUrl: studentList![index].imgUrl,
                    borderWidth: 2,
                    //  radius: 32,
                    elevation: kIsWeb ? 0 : 5,
                    showInitialTextAbovePicture: true,
                    borderColor: Fav.design.primary.withAlpha(100),
                    initialsText: Text(
                      studentList![index].name!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    foregroundColor: Colors.black.withAlpha(80),
                    onTap: () {
                      onPressed!(studentList![index].key);
                    }),
              );
            },
          ))
        ],
      ),
    );
  }
}
