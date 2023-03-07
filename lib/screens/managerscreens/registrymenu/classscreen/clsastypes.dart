import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../services/dataservice.dart';
import '../../../../widgets/mycard.dart';

class ClassTypes extends StatefulWidget {
  ClassTypes();
  @override
  _ClassTypesState createState() => _ClassTypesState();
}

class _ClassTypesState extends State<ClassTypes> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, String?>? _classTypes = <String, String?>{};
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingAdd = false;

  @override
  void initState() {
    super.initState();

    _classTypes = AppVar.appBloc.schoolInfoService!.singleData!.classTypes;

    if (_classTypes!.length < 2) {
      _classTypes = {'t0': 'classtype0'.translate, 't1': 'classtype1'.translate};
    }
  }

  String _getKey() {
    String key;
    do {
      key = 't' + Random().nextInt(1000).toString();
    } while (_classTypes!.containsKey(key));
    return key;
  }

  void _save(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (_formKey.currentState!.validate() && _classTypes!.keys.contains('t0') && _classTypes!.keys.contains('t1')) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      SchoolDataService.setClassTypes(_classTypes).then((_) {
        setState(() {
          _isLoading = false;
        });
        Get.back();
        OverAlert.saveSuc();
      }).catchError((_) {
        setState(() {
          _isLoading = false;
        });
        OverAlert.saveErr();
      });
    } else {
      OverAlert.show(type: AlertType.danger, message: "errvalidation".translate);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _classTypeWidgetList = [];
    final List classTypeKeys = _classTypes!.keys.toList();
    classTypeKeys.sort((a, b) => a == 't1' || a == 't0' ? -1 : 1);

    for (int i = 0; i < classTypeKeys.length; i++) {
      var classTypeName = _classTypes![classTypeKeys[i]];
      Widget _current = AbsorbPointer(
          absorbing: i < 2,
          child: MyListedCard(
              number: i + 1,
              closePressed: i < 2
                  ? null
                  : () {
                      setState(() {
                        _formKey = GlobalKey<FormState>();
                        _classTypes!.remove(classTypeKeys[i]);
                      });
                    },
              child: FormField(
                initialValue: classTypeName,
                builder: (FormFieldState state) => Column(
                  children: <Widget>[
                    MyTextFormField(
                      labelText: "name".translate,
                      validatorRules: ValidatorRules(
                        req: true,
                        minLength: 4,
                      ),
                      initialValue: classTypeName,
                      onSaved: (value) {
                        _classTypes![classTypeKeys[i]] = value;
                      },
                    ),
                  ],
                ),
              ))).px32;
      _classTypeWidgetList.add(_current);
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'classlist'.translate),
      topActions: TopActionsTitle(title: "classgroups".translate),
      bottomBar: BottomBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MyProgressButton(
                isLoading: _isLoadingAdd,
                label: 'add'.translate,
                onPressed: () {
                  //FocusScope.of(context).requestFocus(new FocusNode());
                  _formKey.currentState!.save();
                  setState(() {
                    _isLoadingAdd = true;
                    _formKey = GlobalKey<FormState>();
                    _classTypes![_getKey()] = '';
                  });
                  Future.delayed(const Duration(milliseconds: 100)).then((_) {
                    _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.linear);
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
                onPressed: () {
                  _save(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Body.singleChildScrollView(
        maxWidth: 720,
        scrollController: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            children: _classTypeWidgetList,
          ),
        ),
      ),
    );
  }
}
