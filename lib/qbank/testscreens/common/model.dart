import 'package:mcg_extension/extensions/intextension.dart';

class AnswerKeyModel {
  ///{'s1':answerKeyItem}
  Map<String, AnswerKeyItem>? answerKeyItems;
  //* Normalde database icin orjinal testkey kullaniliyor fakat bunun orjinal testKeyi  pdftestpage oldugu icin bu kullaniliyor
  String? testKey;
  int? optionCount;

  AnswerKeyModel({this.optionCount, this.answerKeyItems});

  AnswerKeyModel.fromJson(Map snapshot) {
    optionCount = snapshot['optionCount'] ?? 5;
    testKey = snapshot['testKey'] ?? 6.makeKey;
    answerKeyItems = (snapshot['answerKeyItems'] == null ? [] : (snapshot['answerKeyItems'] as Map).map((key, value) => MapEntry(key, AnswerKeyItem.fromJson(value)))) as Map<String, AnswerKeyItem>?;
  }

  Map<String, dynamic> toJson() {
    return {
      'optionCount': optionCount,
      'testKey': testKey,
      'answerKeyItems': answerKeyItems!.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class AnswerKeyItem {
  /// 0 coktan  secmeli 1 bosluk doldurma
  int? type;
  String? answer;

  AnswerKeyItem({this.type, this.answer});

  AnswerKeyItem.fromJson(Map snapshot) {
    type = snapshot['t'];
    answer = snapshot['a'];
  }

  Map<String, dynamic> toJson() {
    return {
      't': type,
      'a': answer,
    };
  }
}
