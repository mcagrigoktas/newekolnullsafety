import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/youtube_player/youtube_player_shared.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/stringhelper.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/enums.dart';

class ZoomSettingsPage extends StatefulWidget {
  @override
  _ZoomSettingsPageState createState() => _ZoomSettingsPageState();
}

class _ZoomSettingsPageState extends State<ZoomSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _apiKey;
  String? _apiSecret;

  void _save() {
    if (_formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      setState(() {
        _isLoading = true;
      });

      final kurumId = AppVar.appBloc.hesapBilgileri.kurumID;
      final termKey = AppVar.appBloc.hesapBilgileri.termKey;
      final uid = AppVar.appBloc.hesapBilgileri.uid;
      Map<String, dynamic> updates = {};

      if (AppVar.appBloc.hesapBilgileri.gtM) {
        updates['/${StringHelper.schools}/$kurumId/Managers/$uid/otherData/zak'] = _apiKey.mix;
        updates['/${StringHelper.schools}/$kurumId/Managers/$uid/otherData/zas'] = _apiSecret.mix;
        updates['/${StringHelper.schools}/$kurumId/Managers/$uid/lastUpdate'] = databaseTime;
        updates['/${StringHelper.schools}/$kurumId/SchoolData/Versions/Managers'] = databaseTime;
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        updates['/${StringHelper.schools}/$kurumId/$termKey/Teachers/$uid/otherData/zak'] = _apiKey.mix;
        updates['/${StringHelper.schools}/$kurumId/$termKey/Teachers/$uid/otherData/zas'] = _apiSecret.mix;
        updates['/${StringHelper.schools}/$kurumId/$termKey/Teachers/$uid/lastUpdate'] = databaseTime;
        updates['/Okullar/$kurumId/SchoolData/Versions/$termKey/Teachers'] = databaseTime;
      }

      AppVar.appBloc.database1.update(updates).then((_) {
        AppVar.appBloc.hesapBilgileri.otherData['zoomApiKey'] = _apiKey;
        AppVar.appBloc.hesapBilgileri.otherData['zoomApiSecret'] = _apiSecret;
        AppVar.appBloc.databaseVersions.set('Okullar/$kurumId/$termKey/${AppVar.appBloc.hesapBilgileri.uid}/${VersionListEnum.userInfoChangeService}', databaseTime);
        setState(() {
          _isLoading = false;
        });
        Get.back();
        OverAlert.saveSuc();
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
    _apiKey = AppVar.appBloc.hesapBilgileri.zoomApiKey;
    _apiSecret = AppVar.appBloc.hesapBilgileri.zoomApiSecret;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: '  '.translate),
      topActions: TopActionsTitle(
        title: 'zoomsettings'.translate,
      ),
      body: Body.singleChildScrollView(
        maxWidth: 720,
        child: MyForm(
          formKey: _formKey,
          child: Column(
            children: <Widget>[
              8.heightBox,
              Group2Widget(
                children: [
                  MyTextFormField(
                    initialValue: _apiKey,
                    labelText: "Api Key".translate,
                    iconData: MdiIcons.account,
                    validatorRules: ValidatorRules(req: true, minLength: 6),
                    onSaved: (value) {
                      _apiKey = value;
                    },
                  ),
                  MyTextFormField(
                    initialValue: _apiSecret,
                    labelText: "Api Secret".translate,
                    iconData: MdiIcons.account,
                    validatorRules: ValidatorRules(req: true, minLength: 6),
                    onSaved: (value) {
                      _apiSecret = value;
                    },
                  ),
                ],
              ),
              16.heightBox,
              RichText(
                text: TextSpan(style: TextStyle(color: Fav.design.primaryText), children: [
                  TextSpan(
                      text: 'https://marketplace.zoom.us',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          'https://marketplace.zoom.us'.launch(LaunchType.url);
                        }),
                ]),
              ),
              16.heightBox,
              if ('lang'.translate == 'tr')
                Column(
                  children: [
                    Text(
                      'helpvideo'.translate.toUpperCase(),
                      style: TextStyle(color: Fav.design.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    16.heightBox,
                    SizedBox(
                      width: 400,
                      height: 400 * 9 / 16,
                      child: MyYoutubeWidget('https://youtu.be/Plt9lu6H1D4'
                          //Onceki  'https://youtu.be/8HHNDvFcQnA'
                          ),
                    ),
                  ],
                ),
              16.heightBox,
              MyProgressButton(
                onPressed: _save,
                label: Words.save,
                isLoading: _isLoading,
              ),
              8.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}
