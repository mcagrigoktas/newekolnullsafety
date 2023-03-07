import 'dart:convert';

import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:xml/xml.dart';

import '../../helper.dart';
import '../controller.dart';

class AscImportHelper {
  AscImportHelper._();
  static Future<void> import() async {
    final _file = await (FilePicker.pickFile(fileType: FileType.ANY, readAsString: true));
    final _document = XmlDocument.parse(utf8.decode(_file!.byteData));
    final _cardElements = _document.findAllElements('card');
    if (_cardElements.isEmpty) {
      OverAlert.show(message: 'norecords'.translate, type: AlertType.warning);
      return;
    }

    final _controller = Get.find<TimaTableEditController>();
    final _programData = _controller.programData;
    _programData.clear();
    _cardElements.forEach((element) {
      final _classKey = element.getAttribute('classids');
      final _lessonKey = element.getAttribute('subjectid');
      final _day = int.tryParse(element.getAttribute('day')!);
      final _period = int.tryParse(element.getAttribute('period')!);
      if (_classKey is String && _lessonKey is String && _day is int && _period is int) {
        if (_programData[_classKey] == null) _programData[_classKey] = {};
        _programData[_classKey]['${_day + 1}-$_period'] = _lessonKey;
      }
    });
    _controller.update();
    _controller.programData = ProgramHelper.makeProgramSturdy(_controller.programData, _controller.timesModel);

    OverAlert.saveSuc();
  }
}
