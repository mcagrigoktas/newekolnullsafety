import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/stringhelper.dart';
import '../../../models/enums.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import 'change_password.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _imgUrl;

  void _savePhoto() {
    if (_formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      setState(() {
        _isLoading = true;
      });

      final _kurumId = AppVar.appBloc.hesapBilgileri.kurumID;
      final _termKey = AppVar.appBloc.hesapBilgileri.termKey;
      final _uid = AppVar.appBloc.hesapBilgileri.uid;
      final _updates = <String, dynamic>{};

      if (AppVar.appBloc.hesapBilgileri.gtM) {
        _updates['/${StringHelper.schools}/$_kurumId/Managers/$_uid/imgUrl'] = _imgUrl;
        _updates['/${StringHelper.schools}/$_kurumId/Managers/$_uid/lastUpdate'] = databaseTime;
        _updates['/${StringHelper.schools}/$_kurumId/SchoolData/Versions/Managers'] = databaseTime;
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        _updates['/${StringHelper.schools}/$_kurumId/$_termKey/Teachers/$_uid/imgUrl'] = _imgUrl;
        _updates['/${StringHelper.schools}/$_kurumId/$_termKey/Teachers/$_uid/lastUpdate'] = databaseTime;
        _updates['/${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/Teachers'] = databaseTime;
      } else if (AppVar.appBloc.hesapBilgileri.gtS) {
        _updates['/${StringHelper.schools}/$_kurumId/$_termKey/Students/$_uid/imgUrl'] = _imgUrl;
        _updates['/${StringHelper.schools}/$_kurumId/$_termKey/Students/$_uid/lastUpdate'] = databaseTime;
        _updates['/${StringHelper.schools}/$_kurumId/SchoolData/Versions/$_termKey/Students'] = databaseTime;
      }

      AppVar.appBloc.database1.update(_updates).then((_) {
        //   AppVar.appBloc.databaseVersions.child("${StringHelper.schools}").child(kurumId).child(termKey).child(AppVar.appBloc.hesapBilgileri.uid).child("${VersionListEnum().UserInfoChangeService}").set(AppVar.appBloc.realTime);
        AppVar.appBloc.databaseVersions.set('${StringHelper.schools}/$_kurumId/$_termKey/${AppVar.appBloc.hesapBilgileri.uid}/${VersionListEnum.userInfoChangeService}', databaseTime);
        setState(() {
          _isLoading = false;
        });
        OverAlert.saveSuc();
        AppVar.appBloc.hesapBilgileri.imgUrl = _imgUrl; // Gereksiz olabilir
      }).catchError((err) {
        setState(() {
          _isLoading = false;
        });
        OverAlert.saveErr();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _imgUrl = AppVar.appBloc.hesapBilgileri.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget _photoUploadWidget = Align(
      child: MyPhotoUploadWidget(
        onSaved: (value) {
          _imgUrl = value;
        },
        saveLocation: AppVar.appBloc.hesapBilgileri.kurumID! + '/' + AppVar.appBloc.hesapBilgileri.termKey! + '/' + "UserProfileImages",
        avatarImage: true,
        initialValue: (_imgUrl?.startsWithHttp ?? false) ? _imgUrl : null,
      ),
      alignment: Alignment.topLeft,
    );
    if ((_imgUrl?.startsWithHttp ?? false)) {
      _photoUploadWidget = Hero(
        child: _photoUploadWidget,
        tag: 'profile' + _imgUrl!,
      );
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitle(title: 'editprofile'.translate),
      body: Body.singleChildScrollView(
        child: MyForm(
          formKey: _formKey,
          child: Column(
            children: <Widget>[
              if (UserPermissionList.hasStudentCanChangePhoto() || AppVar.appBloc.hesapBilgileri.gtMT) _photoUploadWidget,
              Divider(),
              ListTile(
                onTap: () {
                  Fav.to(ChangePasswordPage());
                },
                title: 'changepassword'.translate.text.make(),
                leading: MdiIcons.lockReset.icon.color(Fav.design.primary).make(),
              ),
            ],
          ),
        ),
      ),
      bottomBar: BottomBar.saveButton(isLoading: _isLoading, onPressed: _savePhoto),
    );
  }
}
