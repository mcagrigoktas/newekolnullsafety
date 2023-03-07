import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../localization/usefully_words.dart';
import '../../services/dataservice.dart';

class EatFile extends StatefulWidget {
  EatFile();

  @override
  _EatFileState createState() => _EatFileState();
}

class _EatFileState extends State<EatFile> {
  String? urlController = '';
  GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  String? fileName;
  void save() {
    if (Fav.noConnection()) return;

    formKey.currentState!.save();
    if (urlController!.length < 6) return;

    setState(() {
      isLoading = true;
    });
    EatService.saveEatData(urlController).then((_) {
      Get.back();
      OverAlert.saveSuc();
      setState(() {
        isLoading = false;
      });
    }).catchError((_) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  @override
  void initState() {
    urlController = AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl;

    fileName = urlController!.split('?alt=').first.split('/').last;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: AppVar.appBloc.schoolInfoService!.stream,
        builder: (context, snapshot) {
          var _body = AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!.length > 6
              ? (kIsWeb
                  ? Center(
                      child: MyMiniRaisedButton(
                        text: "downloadfile".translate + '\n' + (fileName ?? "".translate),
                        onPressed: () {
                          DocumentView.openWithGoogleDocument(AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!);
                        },
                        color: Colors.orange.withAlpha(20),
                        iconData: MdiIcons.paperclip,
                        textColor: Colors.white,
                      ),
                    )
                  : GoogleDocumentView(
                      hasAppBar: false,
                      key: Key(AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!),
                      url: AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!,
                    ))
              : EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS);

          BottomBar? _bottomBar;
          if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki5(warning: false)) {
            _bottomBar = BottomBar(
                child: Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  16.widthBox,
                  Expanded(
                    child: FileUploadWidget(
                      saveLocation: "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/HomeWorkFiles",
                      validatorRules: ValidatorRules(req: true, minLength: 1),
                      onSaved: (value) {
                        if (value != null) {
                          urlController = value.url;
                        }
                      },
                    ),
                  ),
                  16.widthBox,
                  MyProgressButton(
                    isLoading: isLoading,
                    label: Words.save,
                    onPressed: save,
                  ),
                  16.widthBox,
                ],
              ),
            ));
          }

          return AppScaffold(
            topBar: TopBar(leadingTitle: 'menu1'.translate),
            topActions: TopActionsTitle(title: "eatlist".translate),
            body: Body(child: _body),
            bottomBar: _bottomBar,
          );
        });
  }
}
