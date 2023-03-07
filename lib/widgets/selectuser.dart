import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../appbloc/appvar.dart';
import '../helpers/appfunctions.dart';
import '../models/accountdata.dart';
import '../screens/main/widgets/user_profile_widget/user_image_helper.dart';

class SelectUserWidget extends StatefulWidget {
  final SelectUserMenuType type; //1 profil screen 2 login screen
  final Color? textColor;
  SelectUserWidget({this.type = SelectUserMenuType.ProfileImage, this.textColor});

  @override
  _SelectUserWidgetState createState() => _SelectUserWidgetState();
}

class _SelectUserWidgetState extends State<SelectUserWidget> with AppFunctions {
  final appBloc = AppVar.appBloc;
  late Widget _buildWidget;

  @override
  void initState() {
    final accountList = UserImageHelper.getAllUserForMenuType(widget.type);

    if (accountList.isEmpty) {
      _buildWidget = SizedBox();
    } else {
      _buildWidget = MyPopupMenuButton(
        toolTip: 'chooseuser'.translate,
        initialValue: appBloc.hesapBilgileri.uid,
        child: Column(children: [
          Container(
            decoration: ShapeDecoration(color: (widget.textColor ?? Colors.black).withAlpha(20), shape: StadiumBorder(side: BorderSide(color: (widget.textColor ?? Colors.black).withAlpha(120), width: 1))),
            padding: const EdgeInsets.all(8.0),
            child: Text('chooseuser'.translate, style: TextStyle(color: (widget.textColor ?? Colors.black), fontWeight: FontWeight.bold)),
          ),
          4.heightBox,
          Text('or'.translate, style: TextStyle(color: (widget.textColor ?? Colors.black)))
        ]),
        itemBuilder: (context) {
          return accountList
              .map<PopupMenuEntry>((hesap) => PopupMenuItem(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(width: 28, height: 28, child: CircularProfileAvatar(imageUrl: UserImageHelper.getUserImageUrl(hesap), radius: 28, elevation: 4, borderColor: Colors.white, borderWidth: 0.3)),
                        8.widthBox,
                        Text(hesap.name!, maxLines: 1, overflow: TextOverflow.ellipsis),
                        // hesap.uid == appBloc.hesapBilgileri.uid && hesap.kurumID == appBloc.hesapBilgileri.kurumID ? 12.width : 4.width,
                        // if (hesap.uid == appBloc.hesapBilgileri.uid && hesap.kurumID == appBloc.hesapBilgileri.kurumID) const Icon(Icons.settings)
                      ],
                    ),
                    value: hesap,
                  ))
              .toList();
        },
        onSelected: (hesap) {
          UserImageHelper.selectAccount(hesap as HesapBilgileri?, widget.type);
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget;
  }
}
