import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../models/allmodel.dart';
import '../../models/notification.dart';
import '../../services/dataservice.dart';
import '../../widgets/mycard.dart';

class AddedMedicineList extends StatelessWidget with AppFunctions {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AppVar.appBloc.medicineProfileService!.stream,
        builder: (context, snapshot) {
          List<MedicineProfile> filteredList = AppVar.appBloc.medicineProfileService!.dataList
              .where((item) {
                return item.studentKey == AppVar.appBloc.hesapBilgileri.uid || !AppVar.appBloc.hesapBilgileri.gtS;
              })
              .where((item) => item.aktif == true)
              .toList();
          filteredList.sort((a, b) => b.endDate! - a.endDate!);
          return AppScaffold(
            topBar: TopBar(leadingTitle: 'menu1'.translate),
            topActions: TopActionsTitleWithChild(
                title: TopActionsTitle(title: 'medicineprofilelist'.translate),
                child: AppVar.appBloc.hesapBilgileri.gtS
                    ? MyRaisedButton(
                        onPressed: () {
                          Fav.to(AddMedicina());
                        },
                        text: 'addmedicinaprofile'.translate)
                    : SizedBox()),
            body: filteredList.isEmpty
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
                : Body.listviewBuilder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      String content = filteredList[index].content!;
                      return ListTile(
                        onTap: () {
                          Fav.to(MedicineDetails(
                            medicineProfile: filteredList[index],
                          ));
                        },
                        title: Text(
                          ('profil'.translate + ' ${index + 1}' + ': ' + (AppVar.appBloc.hesapBilgileri.gtS ? '' : (AppFunctions2.whatIsThisName(filteredList[index].studentKey, onlyStudent: true) ?? ''))),
                          style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(content.length > 100 ? content.substring(0, 99) : content),
                        trailing: Container(
                          decoration: BoxDecoration(color: filteredList[index].endDate! + const Duration(days: 1).inMilliseconds < DateTime.now().millisecondsSinceEpoch ? Colors.redAccent : Colors.greenAccent, shape: BoxShape.circle),
                          width: 15,
                          height: 15,
                        ),
                      );
                    },
                  ),
            bottomBar: BottomBar(
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  Text('active'.translate),
                  8.widthBox,
                  Container(
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                    width: 15,
                    height: 15,
                  ),
                  const Spacer(),
                  Text('passive'.translate),
                  8.widthBox,
                  Container(
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    width: 15,
                    height: 15,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        });
  }
}

class AddMedicina extends StatefulWidget {
  @override
  _AddMedicinaState createState() => _AddMedicinaState();
}

class _AddMedicinaState extends State<AddMedicina> with AppFunctions {
  var formKey = GlobalKey<FormState>();
  final Map _data = {};

  int medicineCount = 1;

  Future<void> sendNotification() async {
    var list = whomStudentClassTeacher(AppVar.appBloc.hesapBilgileri.uid!);

    await InAppNotificationService.sendSameInAppNotificationMultipleTarget(
        InAppNotification(
          title: AppVar.appBloc.hesapBilgileri.name,
          content: 'medicinenotify2'.translate,
          key: 'MedNotify${AppVar.appBloc.hesapBilgileri.uid}',
          type: NotificationType.medicine,
          pageName: PageName.med,
        ),
        list);
  }

  Future<void> submit() async {
    if (Fav.noConnection()) return;

    if (formKey.currentState!.validate()) {
      _data.clear();
      _data['medicinelist'] = [...Iterable.generate(medicineCount).map((i) => {})];
      formKey.currentState!.save();

      final int startDate = _data['startDate'];
      final int endDate = _data['endDate'];
      if (startDate > endDate + 500000 || endDate < DateTime.now().millisecondsSinceEpoch || startDate + 500000 < DateTime.now().millisecondsSinceEpoch) {
        OverAlert.show(message: "dateerr".translate, type: AlertType.danger);
        return;
      }
      _data['studentKey'] = AppVar.appBloc.hesapBilgileri.uid;
      _data['timeStamp'] = databaseTime;
      _data['aktif'] = true;

      OverLoading.show();
      await MedicineService.addMedicineProfile(_data).then((a) {
        sendNotification();
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
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'medicineprofilelist'.translate),
      topActions: TopActionsTitle(
        title: 'addmedicine'.translate,
      ),
      body: Body.singleChildScrollView(
        child: MyForm(
          formKey: formKey,
          child: Column(
            children: <Widget>[
              8.heightBox,
              MyDatePicker(
                title: 'medicinestartdate'.translate,
                onSaved: (value) {
                  _data['startDate'] = value;
                },
              ),
              MyDatePicker(
                title: 'medicineenddate'.translate,
                onSaved: (value) {
                  _data['endDate'] = value;
                },
              ),
              MyTextFormField(
                labelText: "contentmedicine".translate,
                iconData: MdiIcons.commentTextMultipleOutline,
                validatorRules: ValidatorRules(req: true, minLength: 5),
                onSaved: (value) {
                  _data['content'] = value;
                },
                maxLines: 3,
              ),
              Column(
                children: Iterable.generate(medicineCount).map((i) {
                  return MyListedCard(
                    number: i + 1,
                    closePressed: i + 1 == medicineCount && medicineCount > 1
                        ? () {
                            setState(() {
                              medicineCount--;
                            });
                          }
                        : null,
                    child: GroupWidget(
                      children: <Widget>[
                        MyTextFormField(
                          labelText: "medicinename".translate,
                          iconData: MdiIcons.textBox,
                          validatorRules: ValidatorRules(req: true, minLength: 2),
                          onSaved: (value) {
                            _data['medicinelist'][i]['name'] = value;
                          },
                        ),
                        MyTextFormField(
                          labelText: "aciklama".translate,
                          iconData: MdiIcons.comment,
                          validatorRules: ValidatorRules(req: true, minLength: 2),
                          onSaved: (value) {
                            _data['medicinelist'][i]['content'] = value;
                          },
                          maxLines: null,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              16.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  MyMiniRaisedButton(
                      onPressed: () {
                        setState(() {
                          medicineCount += 1;
                        });
                      },
                      text: 'addanothermedicine'.translate),
                ],
              )
            ],
          ),
        ),
      ),
      bottomBar: BottomBar.saveButton(onPressed: submit, isLoading: false),
    );
  }
}

class MedicineDetails extends StatefulWidget {
  final MedicineProfile? medicineProfile;

  MedicineDetails({this.medicineProfile});
  @override
  _MedicineDetailsState createState() => _MedicineDetailsState();
}

class _MedicineDetailsState extends State<MedicineDetails> with AppFunctions {
  bool isPast = false;

  @override
  void initState() {
    super.initState();

    if (widget.medicineProfile!.endDate! + const Duration(days: 1).inMilliseconds < DateTime.now().millisecondsSinceEpoch) {
      isPast = true;
    }
  }

  Future<void> sendNotification(MedicineProfile? profile) async {
    if (Fav.noConnection()) return;

    if (AppVar.appBloc.hesapBilgileri.gtS) {
      var list = whomStudentClassTeacher(AppVar.appBloc.hesapBilgileri.uid!);
      if (list.isEmpty) {
        OverAlert.show(type: AlertType.danger, message: 'medicinenotifiyerr'.translate);
        return;
      }
      OverLoading.show();
      await InAppNotificationService.sendSameInAppNotificationMultipleTarget(
          InAppNotification(
            title: AppVar.appBloc.hesapBilgileri.name,
            content: 'medicinenotify'.translate,
            key: 'MedNotify${widget.medicineProfile!.key}',
            type: NotificationType.medicine,
            pageName: PageName.med,
          ),
          list);
      await OverLoading.close();
      //   EkolPushNotificationService.sendMultipleNotification(AppVar.appBloc.hesapBilgileri.name, 'medicinenotify'.translate, list);
      OverAlert.show(message: 'sendnotificationsuc'.translate);
    } else {
      var time = AppVar.appBloc.realTime;
      //? Bu kodu silme bu cihazin saati hataliysa soyleyen kod
      // if (time.dateFormat("d-MM-yyyy") != DateTime.now().dateFormat("d-MM-yyyy")) {
      //   OverAlert.show(message: "errtimedevice".translate, type: AlertType.danger);
      //   return;
      // }

      if ((time < profile!.endDate! && time > profile.startDate!) || time.dateFormat("d-MM-yyyy") == profile.startDate!.dateFormat("d-MM-yyyy") || time.dateFormat("d-MM-yyyy") == profile.endDate!.dateFormat("d-MM-yyyy")) {
        OverLoading.show();
        await MedicineService.gaveMedicine(profile.key, time.dateFormat("d-MM-yyyy")).then((_) {
          OverAlert.saveSuc();
          InAppNotificationService.sendInAppNotification(
              InAppNotification(
                title: AppVar.appBloc.hesapBilgileri.name,
                content: 'medicinenotify3'.translate,
                key: 'MedNotify${widget.medicineProfile!.key}',
                type: NotificationType.medicine,
                pageName: PageName.med,
              ),
              widget.medicineProfile!.studentKey);
        }).catchError((err) {
          OverAlert.saveErr();
        });

        await OverLoading.close();
      } else {
        OverAlert.show(type: AlertType.danger, message: 'healthtimeerr'.translate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> days = [];
    int? startTime = widget.medicineProfile!.startDate;

    while (true) {
      days.add(startTime!.dateFormat("d-MM-yyyy"));
      if (startTime.dateFormat("d-MM-yyyy") == widget.medicineProfile!.endDate!.dateFormat("d-MM-yyyy")) {
        break;
      }
      startTime += 86400000;
    }

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'medicineprofilelist'.translate,
        trailingActions: AppVar.appBloc.hesapBilgileri.gtS || AppVar.appBloc.hesapBilgileri.gtM
            ? <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Fav.design.appBar.text,
                  ),
                  onPressed: () async {
                    var sure = await Over.sure();
                    if (sure) {
                      await MedicineService.deleteMedicineProfile(widget.medicineProfile!.key).then((_) {
                        Get.back();
                        OverAlert.deleteSuc();
                      }).catchError((_) {
                        OverAlert.deleteErr();
                      });
                    }
                  },
                )
              ]
            : null,
      ),
      topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: 'medicineprofiledatail'.translate), child: 'medicineprofiledatailhint'.translate.text.make()),
      body: Body.singleChildScrollView(
        child: Column(
          children: <Widget>[
            8.heightBox,
            isPast
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'medicinepast'.translate,
                      style: const TextStyle(fontSize: 14),
                    ))
                : const SizedBox(),
            AppVar.appBloc.hesapBilgileri.gtMT
                ? Text(
                    AppFunctions2.whatIsThisName(widget.medicineProfile!.studentKey, onlyStudent: true) ?? '',
                    style: TextStyle(color: Fav.design.customColors2[0], fontSize: 28, fontWeight: FontWeight.bold),
                  )
                : const SizedBox(),
            const Divider(),
            MyKeyValueText(
              textKey: 'aciklama'.translate + ':',
              value: widget.medicineProfile!.content!,
              fontSize: 16,
            ),
            8.heightBox,
            MyKeyValueText(
              textKey: 'medicinestartdate'.translate + ':',
              value: widget.medicineProfile!.startDate!.dateFormat("d-MMM-yyyy"),
              fontSize: 16,
            ),
            8.heightBox,
            MyKeyValueText(
              textKey: 'medicineenddate'.translate + ':',
              value: widget.medicineProfile!.endDate!.dateFormat("d-MMM-yyyy"),
              fontSize: 16,
            ),
            const Divider(),
            Column(
              children: widget.medicineProfile!.medicineList
                  .map((med) => ListTile(
                        leading: const Icon(MdiIcons.pill, color: Colors.red),
                        title: Text(med.name!, style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText)),
                        subtitle: Text(med.content!),
                      ))
                  .toList(),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Column(
              children: days
                  .map(
                    (day) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              day,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText),
                            ),
                          ),
                          Icon(
                            (widget.medicineProfile!.medicineReport ?? {})[day] == true ? MdiIcons.check : MdiIcons.close,
                            color: (widget.medicineProfile!.medicineReport ?? {})[day] == true ? Colors.green : Colors.red,
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
          ],
        ),
      ),
      bottomBar: isPast
          ? null
          : BottomBar(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: MyRaisedButton(
                    onPressed: () {
                      sendNotification(widget.medicineProfile);
                    },
                    text: (AppVar.appBloc.hesapBilgileri.gtMT ? "medicinealert2" : 'medicinealert').translate,
                  ),
                )
              ],
            )),
    );
  }
}
