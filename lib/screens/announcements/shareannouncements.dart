import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../widgets/targetlistwidget.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import 'helper.dart';

class ShareAnnouncements extends StatefulWidget {
  final Announcement? existingAnnouncement;
  final String? previousPageTitle;
  ShareAnnouncements({this.existingAnnouncement, this.previousPageTitle});
  @override
  _ShareAnnouncementsState createState() => _ShareAnnouncementsState();
}

class _ShareAnnouncementsState extends State<ShareAnnouncements> with AppFunctions {
  late Announcement _data;
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _data = widget.existingAnnouncement ?? Announcement();
  }

  void submit() {
    if (Fav.noConnection()) return;

    if (AppFunctions2.isHourPermission() == false) return;

    setState(() {
      isLoading = true;
    });
    if (formKey.currentState!.validate()) {
      if (widget.existingAnnouncement == null) {
        _data.imgList?.clear();
        _data.fileList?.clear();
      }

      formKey.currentState!.save();

      if (AppVar.appBloc.hesapBilgileri.gtT && _data.isPinned == true) {
        final _pinnedAnnouncementList = AnnouncementHelper.getAllFilteredAnnouncement().where((element) => element.isPinned == true && element.aktif);
        final _thisTeacherPinnedList = _pinnedAnnouncementList.where((element) => element.senderKey == AppVar.appBloc.hesapBilgileri.uid);
        if (_thisTeacherPinnedList.length >= UserPermissionList.teacherMaxPinAnnouncementCount()) {
          OverAlert.show(message: 'teachermaxpincounthint'.argsTranslate({'count': UserPermissionList.teacherMaxPinAnnouncementCount()}), type: AlertType.warning);
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      if (AppVar.appBloc.hesapBilgileri.gtM) {
        _data.isPublish = true;
      }
      if (AppVar.appBloc.hesapBilgileri.gtT) {
        _data.isPublish = UserPermissionList.hasTeacherAnnouncementsSharing();
      }

      _data.timeStamp = databaseTime;
      _data.createTime = databaseTime;
      _data.senderKey = AppVar.appBloc.hesapBilgileri.uid;
      _data.senderName = AppVar.appBloc.hesapBilgileri.name;

      AnnouncementService.saveAnnouncement(_data, _data.key).then((a) async {
        setState(() {
          isLoading = false;
        });
        Get.back(result: true);
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    } else {
      setState(() {
        isLoading = false;
      });
      OverAlert.fillRequired();
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: widget.previousPageTitle ?? ''),
      topActions: TopActionsTitle(title: "shareannouncements".translate, color: const Color(0xffDA9B52)),
      body: Body.singleChildScrollView(
          maxWidth: 600,
          child: MyForm(
            formKey: formKey,
            child: SingleChildScrollView(
              child: AnimatedColumnWidget(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TargetListWidget(
                    onSaved: (value) {
                      _data.targetList = value;
                    },
                    initialValue: _data.targetList,
                  ),
                  MyTextFormField(
                    labelText: "header".translate,
                    iconData: MdiIcons.pen,
                    validatorRules: ValidatorRules(req: true, minLength: 3, maxLength: 30),
                    onSaved: (value) {
                      _data.title = value;
                    },
                    initialValue: _data.title,
                  ),
                  MyTextFormField(
                    labelText: "content".translate,
                    iconData: MdiIcons.commentTextMultipleOutline,
                    validatorRules: ValidatorRules(req: true, minLength: 5, maxLength: 2500),
                    onSaved: (value) {
                      _data.content = value;
                    },
                    maxLines: null,
                    initialValue: _data.content,
                  ),
                  if (AppVar.appBloc.hesapBilgileri.kurumID != 'demoapple' && AppVar.appBloc.hesapBilgileri.kurumID != 'demoaccount' && _data.examFileList == null)
                    MyTextFormField(
                      labelText: "link".translate,
                      iconData: MdiIcons.link,
                      onSaved: (value) {
                        _data.url = value;
                      },
                      initialValue: _data.url,
                    ),
                  const SizedBox(),
                  if (widget.existingAnnouncement == null)
                    MyMultiplePhotoUploadWidget(
                      saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "AnnouncementsFiles",
                      validatorRules: ValidatorRules(req: false),
                      onSaved: (value) {
                        if (value != null) {
                          _data.imgList = List<String>.from(value);
                        } else {
                          _data.imgList = null;
                        }
                      },
                    ),
                  if (widget.existingAnnouncement == null)
                    FileUploadWidget(
                      saveLocation: "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/AnnouncementsFiles",
                      onSaved: (value) {
                        if (value != null) {
                          _data.fileList ??= [];
                          _data.fileList!.add(value.url);
                        }
                      },
                    ),
                  if (widget.existingAnnouncement == null)
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: MyProgressButton(
                        color: GlassIcons.announcementIcon.color,
                        label: Words.save,
                        onPressed: submit,
                        isLoading: isLoading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
