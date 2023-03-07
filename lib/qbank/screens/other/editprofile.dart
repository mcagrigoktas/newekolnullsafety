import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../qbankbloc/setdataservice.dart';

class QbankEditProfilePage extends StatefulWidget {
  QbankEditProfilePage();

  @override
  _QbankEditProfilePageState createState() => _QbankEditProfilePageState();
}

class _QbankEditProfilePageState extends State<QbankEditProfilePage> {
  final GlobalKey<FormState> formKey = GlobalKey();

  String? name = '';
  String? imgUrl = '';

  bool isLoading = false;

  void saveInfo() {
    if (Fav.noConnection()) return;

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      QBSetDataService.setProfieInfo(AppVar.qbankBloc.hesapBilgileri.uid, imgUrl, name).then((result) {
        setState(() {
          isLoading = false;
        });

        AppVar.qbankBloc.hesapBilgileri.imgUrl = imgUrl;
        AppVar.qbankBloc.hesapBilgileri.name = name;
        //   Fav.preferences.setString("qbankHesapBilgileri", AppVar.qbankBloc.hesapBilgileri.toString());
        AppVar.qbankBloc.hesapBilgileri.savePreferences();
        Get.back();
        OverAlert.saveSuc();
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    }
  }

  @override
  void initState() {
    name = AppVar.qbankBloc.hesapBilgileri.name ?? '';
    imgUrl = AppVar.qbankBloc.hesapBilgileri.imgUrl ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyQBankScaffold(
      appBar: MyQBankAppBar(
        title: 'editprofile'.translate,
        visibleBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MyForm(
          formKey: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyTextFormField(
                labelText: 'name'.translate,
                iconData: Icons.person,
                validatorRules: ValidatorRules(
                  minLength: 5,
                  req: true,
                ),
                onSaved: (value) {
                  name = value;
                },
                initialValue: name,
              ),
              MyPhotoUploadWidget(
                saveLocation: 'SoruBankasi/ProfilePhotos',
                onSaved: (value) {
                  imgUrl = value;
                },
                //     validatorRules: ValidatorRules(required: true),
                avatarImage: true,
                initialValue: imgUrl,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: MyProgressButton(
                      onPressed: saveInfo,
                      label: Words.save,
                      isLoading: isLoading,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
