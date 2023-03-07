import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';
import 'package:mypackage/srcpages/photoview.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../../appbloc/appvar.dart';
import '../../../../../../models/allmodel.dart';
import '../../../../../../services/dataservice.dart';
import '../controller.dart';
import '../themes.dart';

class LiveLessonChatScreen extends StatelessWidget {
  final controller = Get.find<OnlineLessonController>();

  Widget _buildChild(BuildContext context, LiveLessonChatModel item, bool owner) {
    if (item.imageUrl != null) {
      return GestureDetector(
          onTap: () {
            Get.bottomSheet(PointerInterceptor(child: PhotoView(urlList: [item.imageUrl!])));
          },
          child: MyCachedImage(imgUrl: item.imageUrl!, width: 125, placeholder: true));
    } else if (item.fileUrl != null) {
      return GestureDetector(
        onTap: () {
          DocumentView.openWithGoogleDocument(item.fileUrl!, withBottomSheet: true);
        },
        child: owner
            ? Text(item.message!, style: TextStyle(color: Fav.design.accentText, fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.right)
            : Text(item.message!, style: TextStyle(color: Fav.design.accentText, fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.left),
      );
    } else {
      if (item.message!.contains('http') || item.message!.contains('www')) {
        return GestureDetector(
          onTap: () {
            item.message!.split(' ').forEach((element) {
              if (element.startsWithHttp || element.startsWith('www')) {
                element.launch(LaunchType.url);
                return;
              }
            });
          },
          child: owner ? Text(item.message!, style: TextStyle(color: Fav.design.accentText), textAlign: TextAlign.right) : Text(item.message!, style: TextStyle(color: Fav.design.accentText), textAlign: TextAlign.left),
        );
      }
      return owner ? SelectableText(item.message!, style: TextStyle(color: Fav.design.accentText), textAlign: TextAlign.right) : SelectableText(item.message!, style: TextStyle(color: Fav.design.accentText), textAlign: TextAlign.left);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 333.milliseconds,
      child: Column(
        children: <Widget>[
          ChatHeader(),
          1.heightBox,
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              color: Fav.design.card.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              child: ListView.builder(
                itemCount: controller.messageValue.length,
                controller: controller.messageScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemBuilder: (context, index) {
                  var item = controller.messageValue[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: item.senderKey == AppVar.appBloc.hesapBilgileri.uid
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ((item.senderName ?? '') + '   ' + (item.timeStampText)).text.fontSize(9).make().pr8,
                              2.heightBox,
                              ChatBubble(
                                alignment: Alignment.topRight,
                                clipper: ChatBubbleClipper3(type: BubbleType.sendBubble),
                                child: _buildChild(context, item, true),
                                backGroundColor: Fav.design.primary.withAlpha(100),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ((item.senderName ?? '') + '   ' + (item.timeStampText)).text.fontSize(9).make().pl8,
                              2.heightBox,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  if (item.senderImageUrl.safeLength > 3) CircleAvatar(backgroundImage: CacheHelper.imageProvider(imgUrl: item.senderImageUrl!), radius: 16).pr4,
                                  Flexible(
                                      flex: 1,
                                      child: ChatBubble(
                                        clipper: ChatBubbleClipper3(type: BubbleType.receiverBubble),
                                        child: _buildChild(context, item, false),
                                        backGroundColor: Fav.design.scaffold.background,
                                      )),
                                ],
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
          ChatTextfield(),
        ],
      ).p8,
    );
  }
}

class ChatHeader extends StatelessWidget {
  ChatHeader();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return Card(
      margin: EdgeInsets.zero,
      color: Fav.design.card.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Row(
        children: [
          GestureDetector(
              onTap: controller.closeOpenedPanel,
              child: Container(
                decoration: BoxDecoration(gradient: MeetTheme.gradient, borderRadius: BorderRadius.circular(6)),
                child: Icons.close.icon.color(Colors.white).size(16).padding(2).make(),
              )),
          6.widthBox,
          'chats'.translate.text.make(),
        ],
      ).p12,
    );
  }
}

class ChatTextfield extends StatelessWidget {
  ChatTextfield();
  final controller = Get.find<OnlineLessonController>();
  Future<void> sendMessage({imageUrl, fileUrl}) async {
    if ((controller.messageController.text.isEmpty && imageUrl == null && fileUrl == null) || (Fav.noConnection())) {
      return;
    }
    controller.messgeSending = true;
    controller.update();

    LiveLessonChatModel message = LiveLessonChatModel()
      ..senderKey = AppVar.appBloc.hesapBilgileri.uid
      ..senderGirisTuru = AppVar.appBloc.hesapBilgileri.girisTuru
      ..message = controller.messageController.text
      ..senderName = AppVar.appBloc.hesapBilgileri.name
      ..timeStamp = databaseTime;

    if (AppVar.appBloc.hesapBilgileri.imgUrl.safeLength > 2) {
      message.senderImageUrl = AppVar.appBloc.hesapBilgileri.imgUrl;
    }

    if (imageUrl != null) {
      message.imageUrl = imageUrl;
    }
    if (fileUrl != null) {
      message.fileUrl = fileUrl;
    }

    if (message.messageIsEmpty) return;
    await LiveBroadCastService.addVideoChatsMessage(controller.channelName, message.mapForSave()).then((_) {
      controller.messgeSending = false;
      controller.messageController.text = "";
      controller.update();
    }).catchError((_) {
      // FocusScope.of(context).requestFocus(FocusNode());
      OverAlert.show(type: AlertType.danger, message: "messagesenterr".translate);
    });
  }

  Future<void> addFile() async {
    if (Fav.noConnection()) return;

    final value = await OverBottomSheet.show(BottomSheetPanel.simpleList(title: 'chooseprocess'.translate, items: [
      BottomSheetItem(name: 'addfile'.translate, icon: Icons.insert_drive_file, value: 0),
      BottomSheetItem(name: 'addimage'.translate, icon: Icons.image, value: 1),
      BottomSheetItem.cancel(),
    ]));

    // final value = await showCupertinoModalPopup(
    //   context: context,
    //   builder: (context) {
    //     return PointerInterceptor(
    //       child: CupertinoActionSheet(
    //         actions: {
    //           0: [Icons.insert_drive_file, 'addfile'],
    //           1: [Icons.image, 'addimage'],
    //         }
    //             .entries
    //             .map((e) => CupertinoActionSheetAction(
    //                 onPressed: () => Navigator.pop(context, e.key),
    //                 child: Row(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: <Widget>[Icon(e.value.first, color: Fav.design.sheet.itemText), 16.widthBox, Text((e.value.last as String).translate, style: TextStyle(fontSize: 16.0, color: Fav.design.sheet.itemText))],
    //                 )))
    //             .toList(),
    //         cancelButton: CupertinoActionSheetAction(isDefaultAction: true, onPressed: Get.back, child: Text("cancel".translate)),
    //       ),
    //     );
    //   },
    // );

    if (value == 0) await sendFile();
    if (value == 1) await sendPhoto();
  }

  Future<void> sendPhoto() async {
    if (Fav.noConnection()) return;

    var request = await PhotoPicker.pickSinglePhotoAndUpload(
      saveLocation: "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/MessageImages",
    );

    if (request == null) return OverAlert.saveErr();

    controller.messageController.value = TextEditingValue(text: 'picture'.translate);
    await sendMessage(imageUrl: request);
  }

  Future<void> sendFile() async {
    if (Fav.noConnection()) return;

    MyFile? file = await FilePicker.pickFile(fileType: FileType.ANY);
    if (file == null) return debugPrint("Dosya boş");
    String fileName = file.fileName;
    if (!fileName.contains("doc") && !fileName.contains("xls") && !fileName.contains("ppt") && !fileName.contains("txt") && !fileName.contains("pdf")) {
      OverAlert.show(type: AlertType.danger, message: 'filenosupport'.translate);
      return;
    }
    OverLoading.show();
    var url = await Storage().uploadBytes(file, "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/MessageFiles", fileName, dataImportance: DataImportance.medium);
    await OverLoading.close();
    if (url == null) return OverAlert.saveErr();
    controller.messageController.value = TextEditingValue(text: fileName);
    await sendMessage(fileUrl: url);
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: controller.videoChatSettings.isChatDisable,
      child: Card(
        margin: EdgeInsets.zero,
        color: Fav.design.card.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12))),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Fav.design.scaffold.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              if (controller.videoChatSettings.isChatDisable) Icons.lock.icon.color(Fav.design.accentText).size(16).padding(4).make(),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: controller.messageController,
                      maxLines: 1,
                      style: TextStyle(color: Fav.design.primaryText),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white,
                        //  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), gapPadding: 2.0, borderSide: const BorderSide(color: Colors.white)),
                        labelText: controller.videoChatSettings.isChatDisable ? 'locked'.translate : "writemessage".translate,
                        labelStyle: TextStyle(color: Fav.design.accentText.withAlpha(150), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.transparent)),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          sendMessage();
                        }
                      },
                    ),
                  )),
              1.widthBox,
              Icons.attach_file.icon.color(Fav.design.accentText).size(16).padding(4).onPressed(() => addFile()).make(),
              4.widthBox,
              Container(
                  decoration: BoxDecoration(gradient: MeetTheme.gradient, borderRadius: BorderRadius.circular(6)),
                  child: controller.messgeSending ? const Center(child: SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)))) : Icons.send.icon.color(Colors.white).size(16).padding(4).onPressed(sendMessage).make()),
            ],
          ),
        ),
      ),
    );
  }
}
