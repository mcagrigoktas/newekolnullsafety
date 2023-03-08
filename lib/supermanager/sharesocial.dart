import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_database/videopicker/myvideouploadwidget.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../appbloc/appvar.dart';
import '../localization/usefully_words.dart';
import '../models/allmodel.dart';
import '../screens/managerscreens/othersettings/user_permission/user_permission.dart';
import '../screens/social/socialfunctions.dart';
import '../services/dataservice.dart';
import '../widgets/targetlistwidget.dart';

enum SocialFileType { Photo, Video, YoutubeVideo }

class ShareSocial extends StatefulWidget {
  final List<SharedMediaFile>? intentList;
  final String? youtubeUrl;
  ShareSocial({this.intentList, this.youtubeUrl});
  @override
  _ShareSocialState createState() => _ShareSocialState();
}

class _ShareSocialState extends State<ShareSocial> with SocialFunctions {
  SocialItem _data = SocialItem();
  var formKey = GlobalKey<FormState>();
  int qualityValue = 1;

  SocialFileType? tur = SocialFileType.Photo;
  String saveLocation = "SocialFile";

  String get uploadType => (tur == SocialFileType.Photo) ? "SocialNetwork" : "Video";

  @override
  void initState() {
    super.initState();

    saveLocation = AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + saveLocation + "/" + DateTime.now().dateFormat("yyyy-MM");
    if (widget.youtubeUrl != null) {
      tur = SocialFileType.YoutubeVideo;
    }
  }

  void onSegmentChange(value) {
    setState(() {
      tur = value;
    });
  }

  Future<void> submit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (Fav.noConnection()) return;

      _data = SocialItem();
      formKey.currentState!.save();

      if (tur == SocialFileType.YoutubeVideo && _data.youtubeLink.getYoutubeIdFromUrl == null) {
        OverAlert.show(type: AlertType.danger, message: 'youtubelinkerr'.translate);
        return;
      }

      if (AppVar.appBloc.hesapBilgileri.gtM) _data.isPublish = true;

      if (AppVar.appBloc.hesapBilgileri.gtT) _data.isPublish = UserPermissionList.hasTeacherSocialSharing();

      _data.timeStamp = databaseTime;
      _data.senderName = AppVar.appBloc.hesapBilgileri.name;

      _data.senderImgUrl = AppVar.appBloc.hesapBilgileri.imgUrl ?? '';

      _data.senderKey = AppVar.appBloc.hesapBilgileri.uid;

      ///Burda degisiklik yaparsan social functiondada yapman lazim
      //Butun yoneticiler burda listeye ekleniyor
      List<String> managerList = AppVar.appBloc.managerService!.dataList.map((manager) => manager.key!).toList();

      List<String> teacherList = [];
      // butun herkese gonderilecekse ogretmenlerin hepsi kaydediliyor
      if (_data.targetList!.contains("alluser")) teacherList = AppVar.appBloc.teacherService!.dataList.map((teacher) => teacher.key!).toList();

      // paylasimi yapan ogretmense kendi hesabina  kaydedilmesi icin ekleniyor
      if (AppVar.appBloc.hesapBilgileri.gtT && !teacherList.contains(AppVar.appBloc.hesapBilgileri.uid)) teacherList.add(AppVar.appBloc.hesapBilgileri.uid);

      // Ekidde Ogretmen paylasirken yardimici ogretmeni varsa onun hesabinada yazar yada idareci paylasirken her iki ogretmenede yazar
      if (AppVar.appBloc.hesapBilgileri.isEkid) {
        List<Class> sinifListesi = AppVar.appBloc.classService!.dataList.where((sinif) => _data.targetList!.contains(sinif.key)).toList();
        sinifListesi.forEach((sinif) {
          if (sinif.classTeacher != null && !teacherList.contains(sinif.classTeacher)) {
            teacherList.add(sinif.classTeacher!);
          }
          if (sinif.classTeacher2 != null && !teacherList.contains(sinif.classTeacher2)) {
            teacherList.add(sinif.classTeacher2!);
          }
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
      await SocialService.saveSocialItem(_data, managerList, teacherList, studentList, uploadType, _data.isPublish).then((a) {
        Get.back();
        OverAlert.saveSuc();
      }).catchError((error) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    } else {
      OverAlert.fillRequired();
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
                  maxLines: null,
                ),
                MySegmentedControl(
                  children: {SocialFileType.Photo: Text('photo'.translate), SocialFileType.YoutubeVideo: Text('youtubelink'.translate), if (Get.find<ServerSettings>().videoServerActive) SocialFileType.Video: Text('video'.translate)},
                  color: Colors.blue,
                  name: "".translate,
                  iconData: MdiIcons.shareVariant,
                  onChanged: onSegmentChange,
                  initialValue: tur,
                ),
                if (tur == SocialFileType.YoutubeVideo)
                  MyTextFormField(
                    initialValue: widget.youtubeUrl ?? '',
                    labelText: "link".translate,
                    iconData: MdiIcons.youtube,
                    validatorRules: ValidatorRules(req: false, minLength: 10, noGap: true),
                    onSaved: (value) {
                      _data.youtubeLink = value;
                    },
                  ),
                if (tur == SocialFileType.Photo)
                  Align(
                      alignment: Alignment.topLeft,
                      child: MyMultiplePhotoUploadWidget(
                        saveLocation: saveLocation,
                        validatorRules: ValidatorRules(req: true, minLength: 1),
                        onSaved: (value) {
                          if (value != null) {
                            _data.imgList = List<String>.from(value);
                          }
                        },
                      )),
                if (tur == SocialFileType.Video)
                  MyVideoUploadWidget(
                    saveLocation: saveLocation,
                    onSaved: (value) {
                      _data.videoLink = value!.videoUrl;
                      _data.videoThumb = value.thumbnailUrl;
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 10, noGap: true),
                  ),
                16.heightBox,
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: MyRaisedButton(
                      text: Words.save,
                      iconData: Icons.save,
                      onPressed: () {
                        submit(context);
                      },
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
          ),
        ));
  }
}
