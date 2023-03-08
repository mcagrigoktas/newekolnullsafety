import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';

import '../adminpages/screens/supermanagerpages/models.dart';
import '../appbloc/appvar.dart';
import '../helpers/stringhelper.dart';
import '../localization/usefully_words.dart';
import '../models/allmodel.dart';
import '../models/enums.dart';
import '../widgets/targetlistwidget.dart';
import 'supermanagerbloc.dart';

class ShareSuperManagerAnnouncements extends StatefulWidget {
  final Announcement? existingAnnouncement;
  ShareSuperManagerAnnouncements({this.existingAnnouncement});
  @override
  _ShareSuperManagerAnnouncementsState createState() => _ShareSuperManagerAnnouncementsState();
}

class _ShareSuperManagerAnnouncementsState extends State<ShareSuperManagerAnnouncements> {
  late Announcement _data;
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List<String> schoolWillShare = [];
  bool sharedFinishid = false;
  final controller = Get.find<SuperManagerController>();

  @override
  void initState() {
    super.initState();
    _data = widget.existingAnnouncement ?? Announcement.create(Generator.keyWithTimeStamp());
  }

  late List<SuperManagerSchoolInfoModel> choosedServerList;
  void submit(BuildContext context) {
    if (Fav.noConnection()) return;

    setState(() {
      isLoading = true;
    });

    if (formKey.currentState!.checkAndSave()) {
      _data.isPublish = true;
      _data.timeStamp = databaseTime;
      _data.createTime = databaseTime;
      _data.senderKey = AppVar.appBloc.hesapBilgileri.kurumID;
      _data.senderName = 'supermanager'.translate;
      _data.aktif = true;

      choosedServerList = controller.serverList!.where((element) => schoolWillShare.contains('allschool') || schoolWillShare.contains(element.serverId)).toList();
      if (choosedServerList.isEmpty) return;
      Future.wait(choosedServerList.map((item) => AppVar.appBloc.database1.once('${StringHelper.schools}/${item.serverId}/SchoolData/Info/activeTerm')).toList()).then((results) {
        String pushKey = AppVar.appBloc.database2.pushKey('${StringHelper.schools}/${choosedServerList.first.serverId}/${results.first!.value}/Announcements');
        Map<String, dynamic> updates = {};

        for (var i = 0; i < choosedServerList.length; i++) {
          if (choosedServerList[i].serverId.safeLength > 4 && results[i] != null && (results[i]!.value as String?).safeLength > 3) {
            updates['/${StringHelper.schools}/${choosedServerList[i].serverId}/${results[i]!.value}/Announcements/$pushKey'] = _data.mapForSave(pushKey);
          }
        }

        AppVar.appBloc.database2.update(updates).then((_) {
          choosedServerList.forEach((element) {
            FirebaseFunctionService.sendTopicNotification(
              _data.title!,
              _data.content!,
              element.serverId! + (_data.targetList!.contains('alluser') ? 'pushnotification' : 'onlyteachers'),
            );
          });

          Map<String, dynamic> updatesVersion = {};
          for (var i = 0; i < choosedServerList.length; i++) {
            if (choosedServerList[i].serverId.safeLength > 4 && results[i] != null && (results[i]!.value as String?).safeLength > 3) {
              updatesVersion['/${StringHelper.schools}/${choosedServerList[i].serverId}/SchoolData/Versions/${results[i]!.value}/${VersionListEnum.announcements}'] = databaseTime;
            }
          }
          AppVar.appBloc.database1.update(updatesVersion);
          setState(() {
            sharedFinishid = true;
          });
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'back'.translate),
      topActions: TopActionsTitle(title: "shareannouncements".translate),
      body: Body.singleChildScrollView(
        child: MyForm(
          formKey: formKey,
          child: sharedFinishid == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    16.heightBox,
                    const Icon(Icons.check_circle, color: Colors.green, size: 96),
                    8.heightBox,
                    Text('savesuc'.translate, style: TextStyle(color: Fav.design.primaryText, fontSize: 32, fontWeight: FontWeight.bold)),
                    8.heightBox,
                    Text(_data.title!, style: TextStyle(color: Fav.design.primaryText)),
                    8.heightBox,
                    Text(_data.content!, style: TextStyle(color: Fav.design.primaryText)),
                    8.heightBox,
                    ...choosedServerList.map((e) => Text(e.schoolName!, style: TextStyle(color: Fav.design.primaryText.withAlpha(150), fontSize: 12))).toList(),
                  ],
                )
              : Column(
                  children: <Widget>[
                    SuperManagerTargetListWidget(
                      onSaved: (value) {
                        schoolWillShare = value!;
                      },
                    ),
                    MyDropDownField(
                      canvasColor: Fav.design.dropdown.canvas,
                      name: '',
                      iconData: Icons.supervised_user_circle,
                      color: Colors.pink,
                      initialValue: 0,
                      items: [
                        DropdownMenuItem(value: 0, child: Text('allusers'.translate, style: TextStyle(color: Fav.design.primaryText))),
                        DropdownMenuItem(value: 1, child: Text('onlyteachers'.translate, style: TextStyle(color: Fav.design.primaryText))),
                      ],
                      onSaved: (value) {
                        if (value == 0) {
                          _data.targetList = ['alluser'];
                        } else {
                          _data.targetList = ['onlyteachers'];
                        }
                      },
                    ),
                    AnimatedGroupWidget(
                      children: <Widget>[
                        MyTextFormField(
                          labelText: "header".translate,
                          iconData: MdiIcons.pen,
                          validatorRules: ValidatorRules(req: true, minLength: 3),
                          onSaved: (value) {
                            _data.title = value;
                          },
                        ),
                        MyTextFormField(
                          labelText: "content".translate,
                          iconData: MdiIcons.commentTextMultipleOutline,
                          validatorRules: ValidatorRules(req: true, minLength: 5),
                          onSaved: (value) {
                            _data.content = value;
                          },
                          maxLines: null,
                        ),
                        MyTextFormField(
                          labelText: "link".translate,
                          iconData: MdiIcons.link,
                          onSaved: (value) {
                            _data.url = value;
                          },
                          initialValue: _data.url,
                        ),
                        const SizedBox(),
                        MyPhotoUploadWidget(
                          saveLocation: 'GenelMudurPaylasimlari' + '/' + "AnnouncementsFiles",
                          onSaved: (value) {
                            if (value != null) {
                              _data.imgList ??= [];
                              _data.imgList!.add(value);
                            }
                          },
                        ),
                        FileUploadWidget(
                          saveLocation: 'GenelMudurPaylasimlari' + '/' + "AnnouncementsFiles",
                          onSaved: (value) {
                            if (value != null) {
                              _data.fileList ??= [];
                              _data.fileList!.add(value.url);
                            }
                          },
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: MySwitch(
                            name: "pinned".translate,
                            iconData: MdiIcons.mapMarker,
                            color: Colors.deepPurple,
                            onSaved: (value) {
                              _data.isPinned = value;
                            },
                          ),
                        ),
                        16.heightBox,
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: MyProgressButton(
                          label: Words.save,
                          onPressed: () {
                            submit(context);
                          },
                          isLoading: isLoading,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
