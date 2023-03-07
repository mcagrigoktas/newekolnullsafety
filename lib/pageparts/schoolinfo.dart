import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../appbloc/appvar.dart';
import '../helpers/manager_authority_helper.dart';
import '../localization/usefully_words.dart';
import '../services/dataservice.dart';
import '../widgets/mycard.dart';

class SchoolInfoPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logoNameWidget = Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircularProfileAvatar(backgroundColor: Colors.white, imageUrl: AppVar.appBloc.schoolInfoService?.singleData?.logoUrl, radius: 35, borderWidth: 1, elevation: 2),
          16.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppVar.appBloc.schoolInfoService!.singleData?.name ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  AppVar.appBloc.schoolInfoService!.singleData?.slogan ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Fav.design.primaryText, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return logoNameWidget;
  }
}

class AdressBookPage extends StatefulWidget {
  @override
  _AdressBookPageState createState() => _AdressBookPageState();
}

class _AdressBookPageState extends State<AdressBookPage> {
  final _adressValue = <AdressBookModel>[];
  bool _isLoading = true;

  void fetchData() {
    SchoolDataService.dbAdressBook().once().then((value) {
      if (value?.value != null) {
        _adressValue.clear();
        (value!.value as List).forEach((value) {
          _adressValue.add(AdressBookModel.fromJson(value));
        });
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: 'adressbook'.translate), child: SchoolInfoPart(), childIsPinned: true),
      body: _isLoading
          ? Body.child(
              child: MyProgressIndicator(
              isCentered: true,
            ))
          : _adressValue.isEmpty
              ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
              : Body.listviewBuilder(
                  maxWidth: 540,
                  itemCount: _adressValue.length,
                  itemBuilder: (context, index) {
                    var snap = _adressValue[index];
                    Widget? trailing;
                    Function()? onTap;
                    if (snap.type == AdresBookType.tel) {
                      onTap = () {
                        snap.data.launch(LaunchType.call);
                      };
                      trailing = const Icon(
                        Icons.phone,
                        color: Colors.green,
                      );
                    } else if (snap.type == AdresBookType.mail) {
                      onTap = () {
                        snap.data.launch(LaunchType.mail);
                      };
                      trailing = const Icon(Icons.mail, color: Colors.blueAccent);
                    } else if (snap.type == AdresBookType.adres) {
                      if ((snap.latitude ?? '0').length > 3 && (snap.longitude ?? '0').length > 3) {
                        onTap = () {
                          '${snap.latitude}/${snap.longitude}'.launch(LaunchType.map);
                        };
                        trailing = const Icon(Icons.map, color: Colors.redAccent);
                      }
                    }

                    return ListTile(
                      onTap: onTap,
                      trailing: trailing,
                      title: Text(snap.name!, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                      subtitle: Text(snap.data!, style: TextStyle(color: Fav.design.primaryText)),
                    );
                  },
                ),
      floatingActionButton: AppVar.appBloc.hesapBilgileri.gtM
          ? FloatingActionButton(
              onPressed: () async {
                if (AuthorityHelper.hasYetki2(warning: true) == false) return;
                await Fav.to(AdressBookEdit());
                fetchData();
              },
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Fav.design.primary,
            )
          : null,
    );
  }
}

enum AdresBookType { tel, mail, adres }

class AdressBookModel {
  String? name;
  String? longitude;
  String? latitude;
  String? data;
  AdresBookType? type;

  AdressBookModel({this.data, this.name, this.type});

  AdressBookModel.fromJson(Map snapshot) {
    snapshot.forEach((key, value) {
      if (key == "name") {
        name = value;
      } else if (key == "longitude") {
        longitude = value;
      } else if (key == "latitude") {
        latitude = value;
      } else if (key == "type") {
        type = AdresBookType.values[value];
      } else if (key == "data") {
        data = value;
      }
    });
  }

  Map<String, dynamic> mapForSave() {
    return {
      "name": name,
      "type": AdresBookType.values.indexOf(type!),
      "data": data,
      "longitude": longitude,
      "latitude": latitude,
    };
  }
}

class AdressBookEdit extends StatefulWidget {
  @override
  _AdressBookEditState createState() => _AdressBookEditState();
}

class _AdressBookEditState extends State<AdressBookEdit> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingAdd = false;
  List<AdressBookModel>? _adressBookList;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchoolDataService.dbAdressBook().once().then((snap) {
      setState(() {
        if (snap?.value == null) {
          _adressBookList = [];
        } else {
          _adressBookList = (snap!.value as List).map((data) => AdressBookModel.fromJson(data)).toList();
        }
      });
    });
  }

  void _save() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (_formKey.currentState!.validate() && _adressBookList!.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      SchoolDataService.dbSetAdressBook(_adressBookList!.map((adres) => adres.mapForSave()).toList()).then((_) {
        setState(() {
          _isLoading = false;
        });
        Get.back();
        OverAlert.saveSuc();
      }).catchError((_) {
        OverAlert.saveErr();
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      OverAlert.show(type: AlertType.danger, message: "errvalidation".translate);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> adressBookWidgetList = [];

    if (_adressBookList != null) {
      for (int i = 0; i < _adressBookList!.length; i++) {
        var adress = _adressBookList![i];
        adressBookWidgetList.add(MyListedCard(
          number: i + 1,
          closePressed: () {
            setState(() {
              _formKey = GlobalKey<FormState>();
              _adressBookList!.removeAt(i);
            });
          },
          tapPressed: i == 0
              ? null
              : () {
                  setState(() {
                    _formKey = GlobalKey<FormState>();
                    var item = _adressBookList![i];
                    _adressBookList!.removeAt(i);
                    _adressBookList!.insert(i - 1, item);
                  });
                },
          downPressed: i + 1 == _adressBookList!.length
              ? null
              : () {
                  setState(() {
                    _formKey = GlobalKey<FormState>();
                    var item = _adressBookList![i];
                    _adressBookList!.removeAt(i);
                    _adressBookList!.insert(i + 1, item);
                  });
                },
          child: FormField(
            initialValue: adress,
            builder: (FormFieldState<AdressBookModel> state) => Column(
              children: <Widget>[
                MySegmentedControl(
                  onChanged: (value) {
                    state.didChange(AdressBookModel(data: state.value!.data, name: state.value!.name, type: value));
                  },
                  padding: const EdgeInsets.only(top: 8.0),
                  initialValue: adress.type,
                  name: "",
                  children: {AdresBookType.tel: Text('tel2'.translate), AdresBookType.mail: Text('mail'.translate), AdresBookType.adres: Text('adress'.translate)},
                  onSaved: (value) {
                    _adressBookList![i].type = value;
                  },
                ),
                GroupWidget(
                  children: <Widget>[
                    MyTextFormField(
                      labelText: "name".translate,
                      validatorRules: ValidatorRules(req: true, minLength: 4),
                      initialValue: adress.name,
                      onSaved: (value) {
                        _adressBookList![i].name = value;
                      },
                    ),
                    MyTextFormField(
                      iconData: state.value!.type == AdresBookType.mail ? Icons.alternate_email : (state.value!.type == AdresBookType.adres ? Icons.map : Icons.phone),
                      labelText: '',
                      validatorRules: ValidatorRules(req: true, minLength: 4),
                      initialValue: adress.data,
                      onSaved: (String? value) {
                        _adressBookList![i].data = value!.trim();
                      },
                    ),
                  ],
                ),
                state.value!.type == AdresBookType.adres
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextFormField(
                              labelText: "latitude".translate,
                              initialValue: adress.latitude,
                              onSaved: (value) {
                                _adressBookList![i].latitude = value;
                              },
                            ),
                          ),
                          Expanded(
                            child: MyTextFormField(
                              labelText: "longitude".translate,
                              initialValue: adress.longitude,
                              onSaved: (value) {
                                _adressBookList![i].longitude = value;
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                6.heightBox,
              ],
            ),
          ),
        ));
      }
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'adressbook'.translate),
      topActions: TopActionsTitle(title: 'adressbookedit'.translate),
      body: _adressBookList == null
          ? Body.child(
              child: MyProgressIndicator(isCentered: true),
            )
          : Body.singleChildScrollView(
              maxWidth: 720,
              scrollController: _scrollController,
              child: Form(key: _formKey, child: Column(children: adressBookWidgetList)),
            ),
      bottomBar: _adressBookList == null
          ? null
          : BottomBar(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                MyProgressButton(
                  isLoading: _isLoadingAdd,
                  label: 'add'.translate,
                  onPressed: () {
                    _formKey.currentState!.save();
                    setState(() {
                      _isLoadingAdd = true;
                      _formKey = GlobalKey<FormState>();
                      _adressBookList!.add(AdressBookModel(type: AdresBookType.tel, data: '', name: ''));
                    });
                    Future.delayed(const Duration(milliseconds: 100)).then((_) {
                      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.linear);
                    });
                    Future.delayed(const Duration(milliseconds: 400)).then((_) {
                      setState(() {
                        _isLoadingAdd = false;
                      });
                    });
                  },
                ),
                MyProgressButton(
                  isLoading: _isLoading,
                  label: Words.save,
                  onPressed: _save,
                ),
              ],
            ).px16),
    );
  }
}
