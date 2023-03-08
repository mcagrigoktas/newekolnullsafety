import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_database/videopicker/myvideouploadwidget.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/glassicons.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../../widgets/targetlistwidget.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../socialfunctions.dart';
import 'social_quality_helper.dart';

// enum SocialFileType { Photo, Video, YoutubeVideo }

class ShareSocial extends StatefulWidget {
  final List<SharedMediaFile>? intentList;
  final String? youtubeUrl;
  final String? previousPageTitle;
  ShareSocial({this.intentList, this.youtubeUrl, this.previousPageTitle});
  @override
  _ShareSocialState createState() => _ShareSocialState();
}

class _ShareSocialState extends State<ShareSocial> with SocialFunctions {
  SocialItem _data = SocialItem();
  final _formKey = GlobalKey<FormState>();
  //final _qualityValue = 1;
  int _typeIndex = 0;

  String get _uploadType => (_typeIndex == 0) ? "SocialNetwork" : "Video";
  String get _uploadTypeForSaveLocation => (_typeIndex == 0) ? "Img" : "Vid";
  String get _saveLocation => "aa_SF" + '/' + DateTime.now().dateFormat("yyyy-MM") + '/' + _uploadTypeForSaveLocation + '/' + AppVar.appBloc.hesapBilgileri.kurumID;

  @override
  void initState() {
    super.initState();

    if (widget.youtubeUrl != null) {
      _typeIndex = 1;
    }
  }

  void _submit() {
    _data = SocialItem();
    if (_formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      if (_typeIndex == 1 && _data.youtubeLink.getYoutubeIdFromUrl == null) {
        OverAlert.show(type: AlertType.danger, message: 'youtubelinkerr'.translate);
        return;
      }

      _data.isPublish = publishState();
      _data.timeStamp = databaseTime;
      _data.senderName = AppVar.appBloc.hesapBilgileri.name;
      _data.senderImgUrl = AppVar.appBloc.hesapBilgileri.imgUrl ?? '';
      _data.senderKey = AppVar.appBloc.hesapBilgileri.uid;

      ///Burda degisiklik yaparsan social functiondada yapman lazim
      //Butun yoneticiler burda listeye ekleniyor
      Set<String> managerList = AppVar.appBloc.managerService!.dataList.map((manager) => manager.key).toSet();

      Set<String> teacherList = {};
      // butun herkese gonderilecekse ogretmenlerin hepsi kaydediliyor
      if (_data.targetList!.contains("alluser")) teacherList = AppVar.appBloc.teacherService!.dataList.map((teacher) => teacher.key).toSet();

      // paylasimi yapan ogretmense kendi hesabina  kaydedilmesi icin ekleniyor
      if (AppVar.appBloc.hesapBilgileri.gtT) teacherList.add(AppVar.appBloc.hesapBilgileri.uid);

      // Ekidde Ogretmen paylasirken yardimici ogretmeni varsa onun hesabinada yazar yada idareci paylasirken her iki ogretmenede yazar
      if (AppVar.appBloc.hesapBilgileri.isEkid) {
        List<Class> sinifListesi = AppVar.appBloc.classService!.dataList.where((sinif) => _data.targetList!.contains(sinif.key)).toList();
        sinifListesi.forEach((sinif) {
          if (sinif.classTeacher != null) teacherList.add(sinif.classTeacher!);
          if (sinif.classTeacher2 != null) teacherList.add(sinif.classTeacher2!);
        });
      }

      // Gonderilecek ogrenciler ayarlaniyor
      List<String> studentList = AppVar.appBloc.studentService!.dataList.where((student) {
        if (_data.targetList!.contains("alluser")) return true;

        if (_data.targetList!.any((item) => [...student.classKeyList, student.key].contains(item))) return true;

        return false;
      }).map((student) {
        return student.key;
      }).toList();

      OverLoading.show();

      SocialService.saveSocialItem(_data, managerList.toList(), teacherList.toList(), studentList, _uploadType, _data.isPublish).then((a) async {
        await OverLoading.close(state: true);
        Get.back();
        //   OverAlert.show(message: 'savesuc'.translate, type: AlertType.successful);
      }).catchError((error) {
        OverLoading.close(state: false);
        //   OverAlert.saveErr();
      });
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: widget.previousPageTitle ?? '', trailingActions: [
        Icons.settings_outlined.icon.color(Fav.design.primaryText).onPressed(SocialQualityHelper.openQualityScreen).make(),
      ]),
      topActions: TopActionsTitle(title: "shareannouncements".translate, color: GlassIcons.social.color),
      body: Body.singleChildScrollView(
          maxWidth: 600,
          child: MyForm(
            formKey: _formKey,
            child: Column(
              children: <Widget>[
                TargetListWidget(
                  onlyteachers: false,
                  onSaved: (value) {
                    _data.targetList = value;
                  },
                ),
                MyTextFormField(
                  labelText: "comment".translate,
                  iconData: MdiIcons.commentTextMultipleOutline,
                  onSaved: (value) {
                    _data.content = value;
                  },
                  validatorRules: ValidatorRules(minLength: 0, maxLength: 2500),
                  maxLines: null,
                ),
                CupertinoTabWidget(
                  initialPageValue: _typeIndex,
                  onChanged: (value) {
                    _typeIndex = value;
                  },
                  tabs: [
                    TabMenu(
                        value: 0,
                        name: 'photo'.translate,
                        widget: Column(
                          children: [
                            MyMultiplePhotoUploadWidget(
                              dataImportance: DataImportance.veryLow,
                              saveLocation: _saveLocation,
                              maxPhotoCount: Get.find<PhotoVideoCompressSetting>().getPhotoMaxSelectableCount,
                              validatorRules: ValidatorRules(req: true, minLength: 1),
                              onSaved: (value) {
                                if (value != null) {
                                  _data.imgList = List<String>.from(value);
                                }
                              },
                            ),
                            'canmultiplechoose'.translate.text.fontSize(10).center.make(),
                          ],
                        )),
                    TabMenu(
                        value: 1,
                        name: 'youtubelink'.translate,
                        widget: MyTextFormField(
                          initialValue: widget.youtubeUrl ?? '',
                          labelText: "link".translate,
                          iconData: MdiIcons.youtube,
                          validatorRules: ValidatorRules(req: false, minLength: 10, noGap: true),
                          onSaved: (value) {
                            _data.youtubeLink = value;
                          },
                        )),
                    if (Get.find<ServerSettings>().videoServerActive)
                      TabMenu(
                          value: 2,
                          name: 'video'.translate,
                          widget: MyVideoUploadWidget(
                            saveLocation: _saveLocation,
                            onSaved: (value) {
                              _data.videoLink = value!.videoUrl;
                              _data.videoThumb = value.thumbnailUrl;
                            },
                            validatorRules: ValidatorRules(req: true, minLength: 10, noGap: true),
                          )),
                  ],
                ).pt16,
                16.heightBox,
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: MyRaisedButton(
                      color: GlassIcons.social.color,
                      text: Words.save,
                      iconData: Icons.save,
                      onPressed: _submit,
                    ),
                  ),
                ),
                16.heightBox,
                if (isWeb)
                  Text(
                    'videoonlyemobile'.translate,
                    style: TextStyle(color: Fav.design.disablePrimary),
                  ),
              ],
            ),
          )),
    );
  }

  bool publishState() {
    if (AppVar.appBloc.hesapBilgileri.gtM) return true;
    if (AppVar.appBloc.hesapBilgileri.gtT) return UserPermissionList.hasTeacherSocialSharing();
    return false;
  }
}
