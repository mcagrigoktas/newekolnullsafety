import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../appbloc/appvar.dart';
import '../../flavors/mainhelper.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../widgets/mycard.dart';
import '../../widgets/sticker_picker.dart';

class EditStickers extends StatefulWidget {
  final String? classKey;

  EditStickers({this.classKey});

  @override
  _EditStickersState createState() => _EditStickersState();
}

class _EditStickersState extends State<EditStickers> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Class sinif;
  bool isLoading = false;
  bool isLoadingAdd = false;
  List<Sticker> stickerList = [];
  StickerStatus? segmentStatus = StickerStatus.active;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sinif = AppVar.appBloc.classService!.dataList.singleWhere((sinif) => sinif.key == widget.classKey);
    stickerList = AppVar.appBloc.stickersProfileService!.dataList.where((sticker) => sticker.classKey == widget.classKey).toList();
  }

  Future<void> save() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (formKey.currentState!.validate() && stickerList.isNotEmpty) {
      final _sendAMessage = await Over.sure(message: 'stickerlistchangedh'.argsTranslate({'class': sinif.name}));

      setState(() {
        isLoading = true;
      });
      formKey.currentState!.save();
      await StickerService.dbSetStickerProfile(widget.classKey, stickerList, sendNotification: _sendAMessage).then((_) {
        OverAlert.saveSuc();
      }).catchError((_) {
        OverAlert.saveErr();
      });
      setState(() {
        isLoading = false;
      });
    } else {
      OverAlert.show(type: AlertType.danger, message: "errvalidation".translate);
    }
  }

  Future<void> optionPressed(Sticker item) async {
    final value = await OverBottomSheet.show(BottomSheetPanel.simpleList(
      title: item.title,
      subTitle: item.content ?? '',
      items: [
        ...[
          [0, 'activesticker'.translate],
          [1, 'deactivesticker'.translate],
          [2, 'erasedsticker'.translate],
        ].map((e) => BottomSheetItem(value: e.first, name: e.last as String)).toList(),
        BottomSheetItem.cancel(),
      ],
    ));

    if (value != null) {
      if (value == 0) {
        item.status = StickerStatus.active;
      } else if (value == 1) {
        item.status = StickerStatus.deactive;
      } else if (value == 2) {
        item.status = StickerStatus.past;
      }
    }
    setState(() {
      formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stickersWidgetList = [];
    List<Sticker> filteredList = stickerList.where((sticker) => sticker.status == segmentStatus).toList();
    for (int i = 0; i < filteredList.length; i++) {
      var sticker = filteredList[i];

      stickersWidgetList.add(MyListedCard(
        iconData: Icons.more_vert,
        number: i + 1,
        closePressed: () {
          optionPressed(sticker);
        },
        child: FormField(
          initialValue: sticker,
          builder: (FormFieldState<Sticker> state) => Column(
            children: <Widget>[
              GroupWidget(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 80,
                        height: 48,
                        child: LogoPicker(
                          initialValue: sticker.iconName,
                          onSaved: (value) {
                            sticker.iconName = value;
                          },
                          itemNames: Iterable.generate(AppConst.stickerCount).map((sayi) {
                            return "et${sayi + 1}" + "c.png";
                          }).toList(),
                        ),
                      ),
                      /*  SizedBox(width:80.0,height:32.0,child: MyDropDownField(
                        initialValue: sticker.iconName,
                        onSaved: (value){sticker.iconName = value;},
                        padding:EdgeInsets.only(left:16),
                        items: Iterable.generate(stickerCount).map((sayi)=>DropdownMenuItem(child: CachedNetworkImage(width:24.0,height:24.0,imageUrl: DailyReport(iconName: "et$sayi"+"c.png").iconUrl,cacheManager: AppVar.appBloc.cacheManager),value: "et$sayi"+"c.png",)).toList(),)
                      ),*/
                      Expanded(
                        child: MyTextFormField(
                          labelText: "header".translate,
                          validatorRules: ValidatorRules(
                            req: true,
                            minLength: 4,
                          ),
                          initialValue: sticker.title,
                          onSaved: (value) {
                            sticker.title = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  MyTextFormField(
                    maxLines: null,
                    labelText: "content".translate,
                    validatorRules: ValidatorRules(
                      req: true,
                      minLength: 4,
                    ),
                    initialValue: sticker.content,
                    onSaved: (value) {
                      sticker.content = value;
                    },
                  ),
                ],
              ),
              6.heightBox,
              Row(
                children: <Widget>[
                  Expanded(
                    child: MySegmentedControl(
                      padding: const EdgeInsets.all(0.0),
                      initialValue: sticker.isHome! ? 0 : 1,
                      name: "",
                      children: {0: Text('home'.translate), 1: Text('school'.translate)},
                      onSaved: (value) {
                        sticker.isHome = value == 0;
                      },
                    ),
                  ),
                  Expanded(
                    child: AdvanceDropdown<int>(
                      name: 'starscountlimit'.translate,
                      iconData: Icons.star_border,
                      initialValue: sticker.extraData,
                      onSaved: (value) {
                        sticker.extraData = value;
                      },
                      padding: const EdgeInsets.only(left: 16),
                      items: Iterable.generate(8, (e) => e)
                          .map((sayi) => DropdownItem(
                                name: (sayi + 3).toString(),
                                value: sayi + 3,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ));
    }

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: "stickersmenuname".translate,
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: "stickeredit".translate + ' (${sinif.name})'),
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl<StickerStatus>(
              onValueChanged: (value) {
                setState(() {
                  segmentStatus = value;
                  formKey = GlobalKey<FormState>();
                });
              },
              children: {
                StickerStatus.active: Text('activesticker'.translate),
                StickerStatus.deactive: Text('deactivesticker'.translate),
                StickerStatus.past: Text('erasedsticker'.translate),
              },
              groupValue: segmentStatus,
            ),
            4.heightBox,
            Text(
              segmentStatus == StickerStatus.active ? 'activestickerhint'.translate : (segmentStatus == StickerStatus.deactive ? 'deactivestickerhint'.translate : 'erasedstickerhint'.translate),
              textAlign: TextAlign.center,
              style: TextStyle(color: Fav.design.primaryText, fontSize: 12),
            )
          ],
        ),
      ),
      body: Body(
        scrollController: scrollController,
        singleChildScroll: Form(
          key: formKey,
          child: Column(
            children: stickersWidgetList,
          ),
        ),
      ),
      bottomBar: BottomBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MyProgressButton(
            isLoading: isLoadingAdd,
            label: 'addreward'.translate,
            onPressed: () {
              formKey.currentState!.save();
              setState(() {
                isLoadingAdd = true;

                stickerList.add(Sticker(
                  key: DateTime.now().millisecondsSinceEpoch.toString() + 1.makeKey,
                  title: '',
                  content: '',
                  classKey: widget.classKey,
                  isHome: true,
                  status: StickerStatus.active,
                  type: StickerTypes.reward,
                ));
                formKey = GlobalKey<FormState>();
              });
              Future.delayed(const Duration(milliseconds: 100)).then((_) {
                scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.linear);
              });
              Future.delayed(const Duration(milliseconds: 400)).then((_) {
                setState(() {
                  isLoadingAdd = false;
                  formKey = GlobalKey<FormState>();
                });
              });
            },
          ),
          MyProgressButton(
            isLoading: isLoading,
            label: Words.save,
            onPressed: save,
          ),
        ],
      )),
    );
  }
}
