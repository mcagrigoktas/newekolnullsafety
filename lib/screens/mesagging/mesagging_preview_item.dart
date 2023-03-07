import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/mycircularprofileavatar.dart';
import 'package:mypackage/srcwidgets/mypopupmenubutton.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../models/chatmodel.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import '../managerscreens/registrymenu/studentscreen/student.dart';
import 'helper.dart';

class MessagePreviewItem extends StatelessWidget {
  final MesaggingPreview? item;
  final bool ghost;
  final String? ghostUid;
  final bool forWidgetMenu;
  final Function()? afterBackChatDetail;
  MessagePreviewItem({this.item, this.ghost = false, this.ghostUid, this.forWidgetMenu = false, this.afterBackChatDetail});
  @override
  Widget build(BuildContext context) {
    Widget imageWidget = (item!.senderImgUrl ?? '') != '' ? CircularProfileAvatar(imageUrl: (item!.senderImgUrl ?? ''), borderColor: GlassIcons.messagesIcon.color!, borderWidth: 1, elevation: 3, radius: 20.0) : Icon(MdiIcons.accountCircle, color: GlassIcons.messagesIcon.color, size: 42);

    String _messageText = '';
    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      _messageText = item!.lastMessage ?? "-";
    } else {
      if (AppVar.appBloc.hesapBilgileri.isEkid) {
        if (AppVar.appBloc.hesapBilgileri.parentState != 2) {
          _messageText = item!.lastMessage ?? "-";
        } else if (AppVar.appBloc.hesapBilgileri.parentNo == 2 && item!.parentNo == 2) {
          _messageText = item!.lastMessage ?? "-";
        } else if (AppVar.appBloc.hesapBilgileri.parentNo != 2 && item!.parentNo == 2) {
          _messageText = "clickforchat".translate;
        } else if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
          _messageText = "clickforchat".translate;
        } else {
          _messageText = item!.lastMessage ?? "-";
        }
      } else {
        if (item!.isParent == false) {
          _messageText = item!.lastMessage ?? "-";
        } else if (!AppVar.appBloc.hesapBilgileri.isParent && item!.isParent == true) {
          _messageText = "clickforchat".translate;
        } else if (AppVar.appBloc.hesapBilgileri.parentNo != item!.parentNo) {
          _messageText = "clickforchat".translate;
        } else {
          _messageText = item!.lastMessage ?? "-";
        }
      }
    }
    return InkWell(
      onTap: () async {
        await MessagePreviewHelper.goChat(item, ghost, ghostUid);
        if (afterBackChatDetail != null) {
          await 333.wait;
          afterBackChatDetail!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            (item!.senderImgUrl ?? '').startsWithHttp ? Hero(tag: item!.senderKey!, child: imageWidget) : imageWidget,
            !forWidgetMenu && MessagePreviewHelper.isNewMessage(ghost, item) ? Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: CircleAvatar(backgroundColor: Fav.design.primary, radius: 6)) : 16.widthBox,
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(child: Text(item!.senderName!, maxLines: 1, style: TextStyle(color: forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.listTile.title, fontSize: 16.0, fontWeight: FontWeight.bold))),
                      if (!forWidgetMenu && item!.additionalInfo.safeLength > 0) item!.additionalInfo!.toUpperCase().text.color(Fav.design.scaffold.background).fontSize(8).make().rounded(background: Fav.design.primaryText, borderRadius: 3, padding: Inset.hv(3, 1)).pl8
                    ],
                  ),
                  2.heightBox,
                  Text(_messageText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.listTile.subTitle, fontSize: 12.0)),
                ],
              ),
            ),
            if (!forWidgetMenu && !ghost && AppVar.appBloc.hesapBilgileri.gtMT) _CallButton(senderKey: item!.senderKey),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String? senderKey;
  _CallButton({this.senderKey});
  @override
  Widget build(BuildContext context) {
    Student? student = AppVar.appBloc.studentService?.dataListItem(senderKey!);
    if (student == null) return const SizedBox();

    if ((student.fatherPhone.safeLength > 5) || student.motherPhone.safeLength > 5 || student.fatherMail.safeLength > 5 || student.motherMail.safeLength > 5 || student.studentPhone.safeLength > 5) {
      return Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: MyPopupMenuButton(
            child: Icon(
              Icons.contact_phone,
              color: Fav.design.primaryText.withAlpha(200),
            ),
            itemBuilder: (context) {
              List<List> items = [];

              if (student.studentPhone.safeLength > 5) items.add([Icons.phone, 'studentphonecall'.translate, 5]);
              if (student.fatherPhone.safeLength > 5) items.add([Icons.phone, 'fatherphonecall'.translate, 1, student.fatherName]);
              if (student.motherPhone.safeLength > 5) items.add([Icons.phone, 'motherphonecall'.translate, 2, student.motherName]);
              if (student.fatherMail.safeLength > 5) items.add([Icons.mail, 'fathesendmail'.translate, 3, student.fatherName]);
              if (student.motherMail.safeLength > 5) items.add([Icons.mail, 'mothersendmail'.translate, 4, student.motherName]);

              return items
                  .map((e) => PopupMenuItem(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Icon(e[0] as IconData?),
                        8.widthBox,
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e[1] as String),
                            if (e.length > 3 && (e[3] as String?).safeLength > 1)
                              Text(
                                e[3] as String,
                                style: TextStyle(fontSize: 10),
                              ),
                          ],
                        )
                      ]),
                      value: e[2] as int?))
                  .toList();
            },
            onSelected: (value) {
              if (value == 3 || value == 4) {
                if (AppVar.appBloc.hesapBilgileri.gtM || UserPermissionList.hasTeacherMailParent() == true) {
                  if (value == 3) student.fatherMail.launch(LaunchType.mail);
                  if (value == 4) student.motherMail.launch(LaunchType.mail);
                } else {
                  OverAlert.show(type: AlertType.danger, message: 'managerrestricted'.translate);
                }
              } else if (value == 1 || value == 2 || value == 5) {
                if (AppVar.appBloc.hesapBilgileri.gtM || UserPermissionList.hasTeacherCallParent() == true) {
                  String? _current;

                  if (value == 5) _current = student.studentPhone;
                  if (value == 1) _current = student.fatherPhone;
                  if (value == 2) _current = student.motherPhone;

                  _current.launch(LaunchType.call);
                } else {
                  OverAlert.show(type: AlertType.danger, message: 'managerrestricted'.translate);
                }
              }
            },
          ),
        );
      });
    }
    return const SizedBox();
  }
}
