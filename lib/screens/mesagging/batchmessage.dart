import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_database/videopicker/myvideouploadwidget.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../services/smssender.dart';
import '../../widgets/targetlistwidget.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';

class BatchMessages extends StatefulWidget {
  @override
  BatchMessagesState createState() {
    return BatchMessagesState();
  }
}

class BatchMessagesState extends State<BatchMessages> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool? _isParent = false;
  late List _targetList;
  final _saveLocation = "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/MessageFiles";

  String? _message;
  List<String>? _imgList;
  String? _fileUrl;
  String? _videoUrl;
  String? _thumbnailUrl;
  int _index = 0;

  bool _teacherMessageManager = true;

  late bool _smsButtonIsEnabled;
  bool _smsButtonIsAcitve = false;

  @override
  void initState() {
    _smsButtonIsEnabled = AppVar.appBloc.schoolInfoService!.singleData!.smsConfig.isSturdy;
    _teacherMessageManager = UserPermissionList.hasTeacherMessageManager() == true;
    super.initState();
  }

  Future<void> sendMessage() async {
    if (_isLoading) return;
    _isLoading = true;
    setState(() {});
    if (_formKey.currentState!.checkAndSave()) {
      if (_message!.trim().isEmpty) return;
      if (Fav.noConnection()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (AppFunctions2.isHourPermission() == false) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, MesaggingPreview> _ownPreviewMap = {};
      List<String> _keyList = [];
      List<String> _phoneList = [];

      void _addManagerAndTeacherList() {
        _keyList.addAll(AppVar.appBloc.teacherService!.dataList.where((teacher) {
          if (AppVar.appBloc.hesapBilgileri.gtT && AppVar.appBloc.hesapBilgileri.uid == teacher.key) return false;
          return true;
        }).map((teacher) {
          _ownPreviewMap[teacher.key] = MesaggingPreview(senderName: teacher.name, senderImgUrl: teacher.imgUrl, senderKey: teacher.key, timeStamp: databaseTime, lastMessage: _message);
          if (teacher.phone.safeLength > 4) _phoneList.add(teacher.phone!);
          return teacher.key;
        }).toList());
        _keyList.addAll(AppVar.appBloc.managerService!.dataList.where((manager) {
          if (AppVar.appBloc.hesapBilgileri.gtM && AppVar.appBloc.hesapBilgileri.uid == manager.key) return false;
          return true;
        }).map((manager) {
          _ownPreviewMap[manager.key] = MesaggingPreview(senderName: manager.name, senderImgUrl: manager.imgUrl, senderKey: manager.key, timeStamp: databaseTime, lastMessage: _message);
          if (manager.phone.safeLength > 4) _phoneList.add(manager.phone!);
          return manager.key;
        }).toList());
      }

      if (_targetList.contains('onlyteachers')) {
        _addManagerAndTeacherList();
      } else {
        if (_targetList.contains("alluser")) _addManagerAndTeacherList();

        _keyList.addAll(AppVar.appBloc.studentService!.dataList.where((student) {
          if (_targetList.any((item) => [...student.classKeyList, student.key, "alluser"].contains(item))) {
            return true;
          }
          return false;
        }).map((student) {
          _ownPreviewMap[student.key] = MesaggingPreview(senderName: student.name, senderImgUrl: student.imgUrl, senderKey: student.key, timeStamp: databaseTime, lastMessage: _message);
          if (AppVar.appBloc.hesapBilgileri.isEkid) {
            if (student.motherPhone.safeLength > 4) _phoneList.add(student.motherPhone!);
            if (student.fatherPhone.safeLength > 4) _phoneList.add(student.fatherPhone!);
          } else {
            if (_isParent == true && student.motherPhone.safeLength > 4) _phoneList.add(student.motherPhone!);
            if (_isParent == true && student.fatherPhone.safeLength > 4) _phoneList.add(student.fatherPhone!);
            if (_isParent == false && student.studentPhone.safeLength > 4) _phoneList.add(student.studentPhone!);
          }

          return student.key;
        }).toList());
      }
      // if (!_targetList.contains('onlyteachers')) {
      //   keyList = AppVar.appBloc.studentService.dataList.where((student) {
      //     if (_targetList.any((item) => [...student.classKeyList, student.key, "alluser"].contains(item))) {
      //       return true;
      //     }
      //     return false;
      //   }).map((student) {
      //     _ownPreviewMap[student.key] = MesaggingPreview(senderName: student.name, senderImgUrl: student.imgUrl, senderKey: student.key, timeStamp: databaseTime, lastMessage: _message);
      //     return student.key;
      //   }).toList();
      // } else {
      //   keyList = AppVar.appBloc.teacherService.dataList.where((teacher) {
      //     return true;
      //   }).map((teacher) {
      //     _ownPreviewMap[teacher.key] = MesaggingPreview(senderName: teacher.name, senderImgUrl: teacher.imgUrl, senderKey: teacher.key, timeStamp: databaseTime, lastMessage: _message);
      //     return teacher.key;
      //   }).toList();
      // }

      if (_keyList.isEmpty) return;

      if (_smsButtonIsAcitve && _phoneList.isNotEmpty) {
        final _smsModel = SmsModel(message: _message, numbers: _phoneList);

        final _result = await SmsSender.sendSms([_smsModel], dataIsUserAccountInfo: false, mobilePhoneCanBeUsed: false, sureAlertVisible: true);

        if (_result == false) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      var _chatMessage = ChatModel()
        ..message = _message
        ..timeStamp = databaseTime
        ..imgList = _imgList
        ..fileUrl = _fileUrl
        ..videoUrl = _videoUrl
        ..thumbnailUrl = _thumbnailUrl
        ..withSms = _smsButtonIsAcitve == true ? true : null
        ..isParent = _isParent
        ..parentNo = _isParent == true ? 5 : null;
      await MessageService.sendMultipleMessage(
        _keyList,
        _chatMessage,
        _ownPreviewMap,
        MesaggingPreview(
          senderName: AppVar.appBloc.hesapBilgileri.name,
          senderImgUrl: AppVar.appBloc.hesapBilgileri.imgUrl,
          senderKey: AppVar.appBloc.hesapBilgileri.uid,
          timeStamp: databaseTime,
          lastMessage: _message,
          isParent: _isParent,
          parentNo: _isParent == true ? 5 : null,
        ),
        forParentMessageMenu: _isParent,
        parentVisibleCodeForNotification: _isParent == true ? '12' : null,
      ).then((_) {
        setState(() {
          _isLoading = false;
        });

//keyList.forEach((targetKey){
//   Fav.preferences.setInt('${AppVar.appBloc.hesapBilgileri.uid}$targetKey${AppVar.appBloc.hesapBilgileri.termKey}messageread', DateTime.now().millisecondsSinceEpoch+10000);
//});

        Get.back();
      }).catchError((_) {
        OverAlert.show(type: AlertType.danger, message: "messagesenterr".translate);
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _current = Column(
      children: <Widget>[
        //! Buradaki tum kullanicilar ogrenci ogretmen veli ve yoneticiyi kapsamakta
        TargetListWidget(
          onSaved: (value) {
            _targetList = value!;
          },
          onlyteachers: _teacherMessageManager,
        ),
        CupertinoTabWidget(
          initialPageValue: _index,
          onChanged: (value) {
            setState(() {
              _index = value;
            });
          },
          tabs: [
            TabMenu(
              value: 0,
              name: 'message'.translate,
              widget: MyTextFormField(
                labelText: "writemessage".translate,
                iconData: Icons.message,
                validatorRules: ValidatorRules(req: true, minLength: 6),
                onSaved: (value) {
                  _message = value;
                },
                maxLines: null,
              ),
            ),
            TabMenu(
                value: 1,
                name: 'photo'.translate,
                widget: MyMultiplePhotoUploadWidget(
                  saveLocation: _saveLocation,
                  validatorRules: ValidatorRules(req: true, minLength: 1),
                  onSaved: (value) {
                    if (value != null) {
                      _imgList = List<String>.from(value);
                      _message = 'picture'.translate;
                    }
                  },
                )),
            TabMenu(
                value: 2,
                name: 'file'.translate,
                widget: FileUploadWidget(
                  saveLocation: _saveLocation,
                  validatorRules: ValidatorRules(req: true, minLength: 1),
                  onSaved: (value) {
                    if (value != null) {
                      _fileUrl = value.url;
                      _message = value.name;
                    }
                  },
                )),
            if (Get.find<ServerSettings>().videoServerActive)
              TabMenu(
                  value: 3,
                  name: 'video'.translate,
                  widget: MyVideoUploadWidget(
                    saveLocation: _saveLocation,
                    onSaved: (value) {
                      if (value != null) {
                        _videoUrl = value.videoUrl;
                        _thumbnailUrl = value.thumbnailUrl;
                        _message = 'video'.translate;
                      }
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 10, noGap: true),
                  )),
          ],
        ).pt8,
        16.heightBox,
        if (!AppVar.appBloc.hesapBilgileri.isEkid)
          Align(
            alignment: Alignment.topLeft,
            child: MySwitch(
              initialValue: _isParent,
              name: "parentonly".translate,
              iconData: MdiIcons.eyeCheck,
              color: Colors.deepPurple,
              onSaved: (value) {
                _isParent = value;
              },
            ),
          ),
        16.heightBox,
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              _smsButtonIsEnabled
                  ? InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _smsButtonIsAcitve = !_smsButtonIsAcitve;
                          (_smsButtonIsAcitve ? 'smssendactive' : 'smssendpassive').translate.showAlert();
                        });
                      },
                      child: Column(
                        children: [
                          Icons.sms.icon.color(_smsButtonIsAcitve ? GlassIcons.messagesIcon.color! : Fav.design.primaryText.withAlpha(120)).padding(0).make(),
                          'SMS'.text.color(_smsButtonIsAcitve ? GlassIcons.messagesIcon.color! : Fav.design.primaryText.withAlpha(120)).fontSize(8).make(),
                        ],
                      ).pl16,
                    )
                  : SizedBox(),
              Spacer(),
              MyProgressButton(
                label: "send".translate,
                isLoading: _isLoading,
                onPressed: sendMessage,
                color: GlassIcons.messagesIcon.color,
              ),
            ],
          ),
        ),
        8.heightBox,
      ],
    );

    return Form(
      key: _formKey,
      child: AppScaffold(
        topBar: TopBar(
          leadingTitle: 'messages'.translate,
        ),
        topActions: TopActionsTitle(title: "batchmessages".translate, color: GlassIcons.messagesIcon.color),
        body: Body(singleChildScroll: _current, maxWidth: 540, withKeyboardCloserGesture: true),
      ),
    );
  }
}
