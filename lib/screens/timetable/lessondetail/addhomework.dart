import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../../services/pushnotificationservice.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../homework_helper.dart';
import '../modelshw.dart';

///Ogretmen odev kaydi ekler
class AddHomeWork extends StatefulWidget {
  final Class? sinif;
  final Lesson? lesson;
  final int? tur;
  AddHomeWork({this.sinif, this.lesson, this.tur});

  @override
  _AddHomeWorkState createState() => _AddHomeWorkState();
}

class _AddHomeWorkState extends State<AddHomeWork> {
  final HomeWork _data = HomeWork();
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final headerController = TextEditingController(); //todo qr icin kondu isin bitince sil
  final contentController = TextEditingController(); //todo qr icin kondu isin bitince sil

  void submit() {
    setState(() {
      isLoading = true;
    });
    if (Fav.noConnection()) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (formKey.currentState!.validate()) {
      _data.imgList?.clear();
      _data.fileList?.clear();
      formKey.currentState!.save();

      if ((widget.tur == 1 || widget.tur == 2) && _data.checkDate! < DateTime.now().millisecondsSinceEpoch - 43200000) {
        setState(() {
          isLoading = false;
        });
        OverAlert.show(type: AlertType.danger, message: 'checkdateerr'.translate);
        return;
      }

      bool teacherHomeWorkSharing = UserPermissionList.hasTeacherHomeWorkSharing();
      if (widget.tur == 3) {
        teacherHomeWorkSharing = true;
      }

      if (AppVar.appBloc.hesapBilgileri.gtM) {
        _data.isPublish = true;
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        _data.isPublish = teacherHomeWorkSharing;
      }
      //_data.isPublish = teacherHomeWorkSharing;
      _data.timeStamp = databaseTime;

      if (AppVar.appBloc.hesapBilgileri.gtT) {
        _data.teacherKey = AppVar.appBloc.hesapBilgileri.uid;
      } else {
        _data.teacherKey = widget.lesson!.teacher;
        _data.savedBy = AppVar.appBloc.hesapBilgileri.uid;
      }

      if (_data.teacherKey.safeLength < 1) {
        throw ('T:pdf');
      }

      _data.lessonName = widget.lesson!.name;
      _data.className = widget.sinif!.name;
      _data.classKey = widget.sinif!.key;
      _data.lessonKey = widget.lesson!.key;
      _data.tur = widget.tur;

      List<String> contactlist = AppVar.appBloc.studentService!.dataList.where((student) => student.classKeyList.contains(widget.sinif!.key)).map((student) => student.key).toList();
      if (contactlist.isEmpty) {
        OverAlert.show(type: AlertType.danger, message: 'nostudent'.translate);
        return;
      }

      HomeWorkService.saveHomeWork(_data.mapForSave(), teacherHomeWorkSharing, widget.sinif!.key!, widget.lesson!.key, contactlist, _data.teacherKey!).then((a) async {
        if (teacherHomeWorkSharing) {
          EkolPushNotificationService.sendMultipleNotification(HomeWorkHelper.getNotificationHeader(widget.tur) + ': ' + _data.title!, _data.content, contactlist, NotificationArgs(tag: 'homework')).unawaited;
        }
        setState(() {
          isLoading = false;
        });
        AppVar.appBloc.tableProgramService!.refresh();
        Navigator.pop(context, true);
        OverAlert.saveSuc();
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

  String getAppBarName() {
    if (widget.tur == 1) return "addhomework".translate;
    if (widget.tur == 2) return "addexamtime".translate;
    if (widget.tur == 3) return "addlessonnote".translate;
    return '';
  }

  String getContent() {
    if (widget.tur == 1) return "hwcontent".translate;
    if (widget.tur == 2) return "excontent".translate;
    if (widget.tur == 3) return "content".translate;
    return '';
  }

  String getHeader() {
    if (widget.tur == 1) return "hwheader".translate;
    if (widget.tur == 2) return "exheader".translate;
    if (widget.tur == 3) return "header".translate;
    return '';
  }

  String getDateText() {
    if (widget.tur == 1) return "hwenddate".translate;
    if (widget.tur == 2) return "examdate".translate;
    if (widget.tur == 3) return "";

    return '';
  }

  @override
  Widget build(BuildContext mainContext) {
    return AppScaffold(
        topBar: TopBar(leadingTitle: widget.sinif!.name),
        topActions: TopActionsTitle(title: getAppBarName()),
        body: Body.singleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                if (widget.tur == 1 || widget.tur == 2 || widget.tur == 3)
                  MyTextFormField(
                    labelText: getHeader(),
                    controller: headerController,
                    iconData: MdiIcons.pen,
                    validatorRules: ValidatorRules(req: true, minLength: 3),
                    onSaved: (value) {
                      _data.title = value;
                    },
                    maxLines: null,
                  ),
                if (widget.tur == 1 || widget.tur == 2 || widget.tur == 3)
                  MyTextFormField(
                    labelText: getContent(),
                    controller: contentController,
                    iconData: MdiIcons.commentTextMultipleOutline,
                    validatorRules: ValidatorRules(req: true, minLength: 5),
                    onSaved: (value) {
                      _data.content = value;
                    },
                    maxLines: 3,
                  ),
                if (widget.tur == 1 || widget.tur == 2)
                  MyDatePicker(
                    initialValue: DateTime.now().millisecondsSinceEpoch,
                    title: getDateText(),
                    firstYear: DateTime.now().year,
                    lastYear: DateTime.now().year + 2,
                    onSaved: (value) {
                      _data.checkDate = value;
                    },
                  ),
                const Divider(),
                if (widget.tur == 1 || widget.tur == 3)
                  MyTextFormField(
                    labelText: "hwlink".translate,
                    iconData: MdiIcons.link,
                    onSaved: (value) {
                      _data.url = value;
                    },
                  ),
                GroupWidget(
                  children: <Widget>[
                    if (widget.tur == 1 || widget.tur == 2 || widget.tur == 3)
                      MyPhotoUploadWidget(
                        saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "HomeWorkFiles",
                        onSaved: (value) {
                          if (value != null) {
                            _data.imgList ??= [];
                            _data.imgList!.add(value);
                          }
                        },
                      ),
                    if (widget.tur == 1 || widget.tur == 2 || widget.tur == 3)
                      FileUploadWidget(
                        saveLocation: "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/HomeWorkFiles",
                        onSaved: (value) {
                          if (value != null) {
                            _data.fileList ??= [];
                            _data.fileList!.add(value.url);
                          }
                        },
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'hwhelpother'.translate,
                    style: TextStyle(color: Fav.design.primaryText.withAlpha(150), fontSize: 12),
                  ),
                ),
                16.heightBox,
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: MyProgressButton(
                      label: Words.save,
                      onPressed: submit,
                      isLoading: isLoading,
                    ),
                  ),
                ),
                if (widget.tur != 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: MyRaisedButton(
                      onPressed: qrcodeTap,
                      text: 'QR kod ile ödev ver',
                      iconData: MdiIcons.qrcode,
                      boldText: true,
                    ),
                  ),
              ],
            ),
          ),
        ));
  }

  //todo bunu qrkodu ile isin bitince sil
  void qrcodeTap() {
    Fav.to(ScanViewDemo(
      contentController: contentController,
      headerController: headerController,
    ));
  }
}

class ScanViewDemo extends StatefulWidget {
  final TextEditingController? headerController;
  final TextEditingController? contentController;
  ScanViewDemo({Key? key, this.contentController, this.headerController}) : super(key: key);

  @override
  _ScanViewDemoState createState() => _ScanViewDemoState();
}

class _ScanViewDemoState extends State<ScanViewDemo> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR2');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    ));
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      OverAlert.show(message: 'permissionerr'.translate, type: AlertType.danger);
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (Fav.isTimeGuardNotAllowed('qrcodedelay', duration: 3.seconds)) return;
      var data = scanData.code!;
      if (data.contains('egitimdijital') || data.length > 10) {
        data = 'c:' + data.substring(data.length - 9, data.length - 3);
      }

      HomeWorkService.dbGetHomeworkDataFromQRData(data).once().then((snap) {
        if (snap?.value == null) {
          Get.back();
          OverAlert.show(type: AlertType.danger, message: 'qrcodeerr'.translate);
          return;
        }
        if (!widget.headerController!.text.contains(snap!.value['k'])) {
          widget.headerController!.value = TextEditingValue(text: widget.headerController!.text + (widget.headerController!.text.length > 3 ? '\n-----\n' : '') + snap.value['k']);
        }

        widget.contentController!.value = TextEditingValue(text: widget.contentController!.text + (widget.contentController!.text.length > 3 ? '\n-----\n' : '') + snap.value['n']);
        Get.back();
        OverAlert.show(message: 'qrcodesuc'.translate);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
