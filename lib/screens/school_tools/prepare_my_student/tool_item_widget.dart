import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

class ToolItem extends StatelessWidget {
  final IconData? icon;
  final String? imgAsset;
  final String? imgUrl;

  final String? text;
  final VoidCallback? onTap;
  ToolItem({this.icon, this.text, this.onTap, this.imgAsset, this.imgUrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(color: Fav.design.primaryText.withAlpha(5), borderRadius: BorderRadius.circular(9), border: Border.all(width: 0.5, color: Fav.design.primaryText.withAlpha(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 30,
                child: imgAsset == null && imgUrl == null
                    ? icon!.icon.color(Fav.design.primaryText).make()
                    : imgUrl != null
                        ? MyCachedImage(
                            fit: BoxFit.contain,
                            imgUrl: imgUrl!,
                          )
                        : Image.asset(imgAsset!, height: 32),
              ),
              4.heightBox,
              Expanded(flex: 10, child: Center(child: text.text.autoSize.maxLines(2).center.make())),
            ],
          ).p8,
        ),
      ),
    );
  }
}
