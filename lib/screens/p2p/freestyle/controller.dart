import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../services/dataservice.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../../managerscreens/programsettings/helper.dart';
import 'controllerhelper.dart';
import 'layout.timetable_widget.dart';
import 'model.dart';
import 'otherscreens/limitations/limitationhelper.dart';
import 'otherscreens/studentrequest/model.dart';

class P2PController extends GetxController {
  bool isLoading = false;
  double cellHeight = 64;

  bool classListContainsClassTypes = false;
  double? teacherStudentListWidth;
  double? studentRequestMenuWidth;

  // String filteredStudentClassKey;
  Set<String> selectedStudentList = {};
  String? teacherFilterText;
  String? selectedTeacher;
  int tableStartHour = 8;
  int tableEndHour = 20;

  bool isStudentRequestMenuOpen = false;
  TimeTableP2PEvent? selectedEvent;
  int? selectedDay;
  RxInt selectedHour = 0.obs;
  RxInt selectedMinute = 0.obs;
  RxInt selectedLessonDuration = 0.obs;
  TextEditingController noteController = TextEditingController();

  ///ilk deger mousein x pozisyon dgere
  ///ikinci deger mousun y pozisyonunun zaman degerine donusturulmus
  RxList<int> mouseOnTime = [0, 0].obs;

  DateTime selectedWeekTime = DateTime.now();
  //String filter1 = 'all';
  String filteredClass = 'all';
  late MiniFetcher<P2PLogs> logFetcher;

  Map<String?, Map<String, List<int?>>> teacherLimitations = <String, Map<String, List<int>>>{};
  List<TimeTableP2PEvent> teacherEventList = [];
  List<TimeTableP2PEvent> studentEventList = [];
  List<TimeTableP2PEvent> databaseEventList = [];
  final List<P2PModel> _databaseEvents = [];
  List<TimeTableP2PEvent> eventList = [];
  GlobalKey timePlannerKey = GlobalKey();

  ScrollController timaTableVerticalController = ScrollController();

  double get timaTableVerticalControllerPosition {
    if (timaTableVerticalController.hasClients) {
      return timaTableVerticalController.position.pixels;
    }
    return 0;
  }

  void pageUpdate() {
    timePlannerKey = GlobalKey();
    timaTableVerticalController = ScrollController();
    update();
  }

//? Breaking onceki degerleri 0 degil null du
  void resetScreenData() {
    selectedDay = null;
    selectedHour.value = 0;
    selectedMinute.value = 0;
    selectedLessonDuration.value = 0;
  }

  @override
  void onInit() {
    super.onInit();

    tableStartHour = (AppVar.appBloc.schoolTimesService!.dataList.last.schoolStartTime! - AppVar.appBloc.schoolTimesService!.dataList.last.schoolStartTime! % 60) ~/ 60;
    tableEndHour = (AppVar.appBloc.schoolTimesService!.dataList.last.schoolEndTime! - AppVar.appBloc.schoolTimesService!.dataList.last.schoolEndTime! % 60) ~/ 60 + (AppVar.appBloc.schoolTimesService!.dataList.last.schoolEndTime! % 60 == 0 ? 0 : 1);
    teacherStudentListWidth = Get.context!.screenWidth > 1000 ? 200 : 130;
    studentRequestMenuWidth = Get.context!.screenWidth > 1000 ? 250 : 175;

    _setUpBranchListItem();
    resetScreenData();
    Future.delayed(111.milliseconds).then((value) => getWeekEvent());

    RandomDataService.dbGetRandomLog('P2PTeacherLimitations').once().then((snap) {
      if (snap?.value != null) {
        teacherLimitations = LimitationHelper.parseData(snap!.value);
      }
    });

    logFetcher = MiniFetcher<P2PLogs>(
      '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}P2PLogs',
      FetchType.LISTEN,
      multipleData: true,
      jsonParse: (key, value) => P2PLogs.fromJson(value, key),
      lastUpdateKey: 'lastUpdate',
      sortFunction: (P2PLogs i1, P2PLogs i2) => i2.lastUpdate - i1.lastUpdate,
      removeFunction: (a) => a.studentKey == null,
      queryRef: P2PService.dbGetp2pLogs(),
    );
  }

  @override
  void onClose() {
    logFetcher.dispose();
    super.onClose();
  }

  String? teacherBranchDropdownValue = '';
  List<DropdownItem> teacherBranchListItem = [];
  final Set<String> _allBranches = {};
  void _setUpBranchListItem() {
    AppVar.appBloc.teacherService!.dataList.forEach((_teacher) {
      _allBranches.addAll(_teacher.branches ?? []);
    });
    _allBranches.forEach((element) {
      teacherBranchListItem.add(DropdownItem(name: element, value: element));
    });
    teacherBranchListItem.insert(0, DropdownItem(name: 'all'.translate, value: ''));
  }

  Future<void> saveEvent() async {
    if (validate() && !isLoading) {
      if (Fav.noConnection()) return;

      final data = P2PModel()
        ..aktif = true
        ..key = 6.makeKey
        ..week = selectedWeekTime.weekOfYear
        ..day = selectedDay
        ..teacherKey = selectedTeacher
        ..studentList = selectedStudentList.toList()
        ..channel = 20.makeKey
        ..lastUpdate = databaseTime
        ..duration = selectedLessonDuration.value
        ..studentRequestKey = selectedRequest?.key
        ..note = noteController.text
        ..studentRequestLessonKey = selectedRequest?.lessonKey
        ..startTime = selectedHour.value * 60 + selectedMinute.value;

      // Fav.showLoading();
      isLoading = true;
      await P2PService.setP2PEvent(selectedWeekTime.weekOfYear, data).then((value) {
        noteController.text = '';
        Fav.preferences.setInt('p2pLastEventDuration', selectedLessonDuration.value);
        isLoading = false;
        //   Get.back();
        if (Get.isDialogOpen!) Get.back();
        OverAlert.saveSuc();
        _databaseEvents.add(data);
        setupEventList();
      }).catchError((err) {
        log(err);
        isLoading = false;
        //  Get.back();
        OverAlert.saveErr();
      });
    }
  }

  Future<void> deleteP2PEvent(TimeTableP2PEvent event) async {
    OverLoading.show();
    isLoading = true;
    final _event = _databaseEvents.singleWhereOrNull((element) => element.key == event.id);
    if (_event == null) return;
    await P2PService.setP2PEvent(selectedWeekTime.weekOfYear, _event..aktif = false).then((value) {
      isLoading = false;
      OverAlert.saveSuc();
      _databaseEvents.remove(_event);
      setupEventList();
    }).catchError((err) {
      isLoading = false;
      OverAlert.saveErr();
    });
    await OverLoading.close();
  }

  final _studentRequests = <int, List<P2PRequest>>{};
  P2PRequest? selectedRequest;

  List<P2PRequest> get studenRequests => _studentRequests[selectedWeekTime.weekOfYear] ?? [];

  bool isRequestOk(P2PRequest request) {
    return _databaseEvents.any((element) {
      if (element.studentRequestKey == request.key) return true;
      if (!element.studentList!.contains(request.studentKey)) return false;
      final _requestLesson = AppVar.appBloc.lessonService!.dataListItem(request.lessonKey!);
      if (_requestLesson == null) return false;
      if (_requestLesson.teacher == element.teacherKey) return true;

      final _elementTeacherBranches = AppVar.appBloc.teacherService!.dataListItem(element.teacherKey!)?.branches;
      if (_elementTeacherBranches == null) return false;
      final _lessonBranche = _requestLesson.branch;
      if (_lessonBranche.safeLength < 1) return false;
      return _elementTeacherBranches.contains(_lessonBranche);
    });
  }

  Future<void> getWeekEvent() async {
    OverLoading.show();
    isLoading = true;

    await P2PService.dbGetP2PEvent(selectedWeekTime.weekOfYear).once().then((snap) async {
      _databaseEvents.clear();
      if (snap?.value != null) {
        (snap!.value as Map).forEach((key, value) {
          _databaseEvents.add(P2PModel.fromJson(value, key));
        });
        _databaseEvents.removeWhere((element) => element.aktif == false);
      }
      isLoading = false;
      await OverLoading.close();
      setupEventList();
    });

    if (UserPermissionList.hasStudentCanP2PRequest() == true && _studentRequests[selectedWeekTime.weekOfYear] == null) {
      await P2PService.dbGetWeekStudentRequest(selectedWeekTime.weekOfYear).once().then((snap) {
        _studentRequests[selectedWeekTime.weekOfYear] = [];
        if (snap?.value != null) {
          (snap!.value as Map).forEach((key, value) {
            _studentRequests[selectedWeekTime.weekOfYear]!.add(P2PRequest.fromJson(value, key));
          });
        }
        update();
      });
    }
  }

  Future<void> selectRequest(P2PRequest request) async {
    await studentBanControlOk(request.studentKey);
    selectedTeacher = AppVar.appBloc.teacherService!.dataListItem(AppVar.appBloc.lessonService!.dataListItem(request.lessonKey!)!.teacher!)?.key;
    // if (selectedTeacher == null) {
    //   'p2perrteacher'.translate.showAlert();
    //   return;
    // }
    selectedStudentList.clear();
    selectedStudentList.add(request.studentKey!);
    selectedRequest = request;

    final _lesson = AppVar.appBloc.lessonService!.dataListItem(request.lessonKey!);
    if (_lesson != null && _lesson.branch.safeLength < 1) {
      teacherBranchDropdownValue = '';
    } else {
      teacherBranchDropdownValue = _allBranches.contains(_lesson!.branch) ? _lesson.branch : '';
    }
    setupEventList();
  }

  var isRequestHourHideble = true;
  void toggleRequestClickable() {
    isRequestHourHideble = !isRequestHourHideble;
    setupEventList();
  }

  //var isStudentInfoTooltipActive = Fav.preferences.getBool('isStudentInfoTooltipActiveFprP2p', true);
  // void toggleStudentInfoTooltipActive() {
  //   isStudentInfoTooltipActive = !isStudentInfoTooltipActive;
  //   Fav.preferences.setBool('isStudentInfoTooltipActiveFprP2p', isStudentInfoTooltipActive);
  //   setupEventList();
  // }

  bool validate() {
    if (selectedTeacher == null) {
      'chooseteacher'.translate.showAlert();
      return false;
    }
    if (selectedStudentList.isEmpty) {
      'choosestudent'.translate.showAlert();
      return false;
    }
    if (selectedDay == null) {
      OverAlert.fillRequired();
      return false;
    }

    if (selectedEvent!.day != selectedDay || (selectedEvent!.startMinute > selectedHour * 60 + selectedMinute.value) || (selectedEvent!.endMinute < selectedHour * 60 + selectedMinute.value + selectedLessonDuration.value)) {
      'p2pnotimerange'.translate.showAlert();
      return false;
    }
    return true;
  }

  void nextWeek() {
    selectedWeekTime = selectedWeekTime.add(7.days);
    weekChange();
  }

  void previousWeek() {
    selectedWeekTime = selectedWeekTime.subtract(7.days);
    weekChange();
  }

  void weekChange() {
    selectedRequest = null;
    getWeekEvent();
  }

  void get clearSelectedStudentList => selectedStudentList.clear();
  Future<void> selectStudent(String? studentKey) async {
    selectedRequest = null;
    if (selectedStudentList.contains(studentKey)) {
      selectedStudentList.remove(studentKey);
    } else {
      await studentBanControlOk(studentKey);
      selectedStudentList.add(studentKey!);
    }
    setupEventList();
  }

  void selectTeacher(String? teacherKey) {
    selectedRequest = null;
    selectedTeacher = teacherKey;
    setupEventList();
  }

  void setupEventList() {
    resetScreenData();
    eventList.clear();
    _addTeacherProgramEvents();
    _addStudentProgramEvents();
    _addExistingP2PEvents();
    eventList.addAll(teacherEventList);
    eventList.addAll(studentEventList);
    eventList.addAll(databaseEventList);
    P2PControllerHelper.addEmptyEvents(tableStartHour, tableEndHour, teacherLimitations[selectedTeacher], eventList, selectedRequest, isRequestHourHideble);
    pageUpdate();
  }

  void selectEmptyEvent(TimeTableP2PEvent e, [TapDownDetails? details]) {
    if (selectedTeacher == null || selectedStudentList.isEmpty) {
      'selectteacherandstudent'.translate.showAlert();
      return;
    }

    selectedEvent = e;
    selectedDay = e.day;
    selectedHour.value = e.startMinute ~/ 60;
    selectedMinute.value = e.startMinute % 60;

    final eventDuration = (e.endMinute - e.startMinute) - (e.endMinute - e.startMinute) % 5;
    final lastEventDuration = Fav.preferences.getInt('p2pLastEventDuration', 60)!;
    selectedLessonDuration.value = [eventDuration, lastEventDuration].min;

    if (details != null && e.endMinute - e.startMinute > 20 && mouseOnTime.last >= e.startMinute && mouseOnTime.last <= e.endMinute) {
      selectedHour.value = mouseOnTime.last ~/ 60;
      selectedMinute.value = mouseOnTime.last % 60;
    }

    pageUpdate();

    noteController.text = selectedRequest?.note ?? '';
    Get.dialog(EventForm(), name: 'Event Form', barrierDismissible: false);
  }

  void smashEvent(TimeTableP2PEvent e) {
    if (mouseOnTime.last == e.startMinute || mouseOnTime.last == e.endMinute) return;
    eventList.addAll([
      TimeTableP2PEvent(
        id: 'lesson${10.makeKey}',
        color: Fav.design.primaryText.withAlpha(50),
        title: '',
        day: e.day,
        startMinute: e.startMinute,
        endMinute: mouseOnTime.last,
        eventType: EventType.empty,
      ),
      TimeTableP2PEvent(
        id: 'lesson${10.makeKey}',
        color: Fav.design.primaryText.withAlpha(50),
        title: '',
        day: e.day,
        startMinute: mouseOnTime.last,
        endMinute: e.endMinute,
        eventType: EventType.empty,
      )
    ]);
    eventList.remove(e);
    pageUpdate();
  }

  void _addExistingP2PEvents() {
    databaseEventList.clear();
    _databaseEvents.forEach((model) {
      if (model.teacherKey == selectedTeacher) {
        databaseEventList.add(TimeTableP2PEvent(
          id: model.key!,
          eventType: EventType.p2p,
          color: Colors.green,
          day: model.day,
          startMinute: model.startTime!,
          endMinute: model.startTime! + model.duration!,
          title: model.studentList!.fold<String>('\n', (p, e) => p + (AppVar.appBloc.studentService!.dataListItem(e)?.name ?? '') + '\n'),
        ));
      } else if (model.studentList!.any((element) => selectedStudentList.contains(element))) {
        final _teacher = AppVar.appBloc.teacherService!.dataListItem(model.teacherKey!);
        String? branch;
        if (_teacher?.branches != null && _teacher!.branches!.isNotEmpty) branch = ' (' + _teacher.branches!.first.firstXcharacter(3)! + ')';
        databaseEventList.add(TimeTableP2PEvent(
          id: model.key!,
          eventType: EventType.studentP2POtherTeacher,
          color: Colors.orange,
          day: model.day,
          startMinute: model.startTime!,
          endMinute: model.startTime! + model.duration!,
          title: branch != null ? (_teacher!.name.capitalLettersJoin(characterCount: 3)! + branch) : (_teacher?.name ?? ''),
        ));
      }
    });
  }

  Map<String?, List<TimeTableP2PEvent>> teacherProgramEventCache = {};
  void _addTeacherProgramEvents() {
    teacherEventList.clear();
    if (selectedTeacher != null) {
      teacherProgramEventCache[selectedTeacher] ??= ProgramHelper.getTeacherEventListFromProgram(selectedTeacher);
      teacherEventList.addAll(teacherProgramEventCache[selectedTeacher]!);
    }
  }

  Map<String?, List<TimeTableP2PEvent>> studentProgramEventCache = {};
  void _addStudentProgramEvents() {
    studentEventList.clear();
    selectedStudentList.forEach((studentKey) {
      studentProgramEventCache[studentKey] ??= ProgramHelper.getStudentEventListFromProgram(studentKey);
      studentEventList.addAll(studentProgramEventCache[studentKey]!);
    });
  }

  Future<void> studentBanControlOk(String? studentKey) async {
    int? _checkTime;
    // bool status = true;
    final _now = DateTime.now();
    logFetcher.dataList.forEach((element) {
      if (element.studentKey == studentKey && element.yoklama == false) {
        final _itemTime = P2PTimeCalculateHelper.calculateTimeStamp(element.week, element.day, element.startTime, element.lastUpdate);
        if (_now.millisecondsSinceEpoch < _itemTime + Duration(days: UserPermissionList.howManyDaysBanStudentForP2P()).inMilliseconds) {
          if (_checkTime == null || _itemTime > _checkTime!) _checkTime = _itemTime;
          //   status = false;
        }
      }
    });

    if (_checkTime != null && (_checkTime! + Duration(days: UserPermissionList.howManyDaysBanStudentForP2P()).inMilliseconds) > _now.millisecondsSinceEpoch) {
      //final _result =
      await OverDialog.show(DialogPanel.defaultPanel(
        title: 'studentabsentthisp2perr'.argsTranslate({
          'date': _checkTime!.dateFormat('d-MMM-yyyy'),
          'time': (_checkTime! + Duration(days: UserPermissionList.howManyDaysBanStudentForP2P()).inMilliseconds).dateFormat('d-MMM-yyyy, HH:mm'),
        }),
        okButtonText: 'ok'.translate,
      ));
      // if (_result == true) status = true;
    }
    //return status;
  }
}
