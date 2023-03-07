enum SurveyTypes { text, choosable, hasPicture, multiplechoosable, line }

class Survey {
  String? title;
  String? content;
  String? image;
  String? prepared;
  int? preparedtype;
  List<SurveyItem>? surveyitems;
  List<String>? targetList;

  Survey.create();

  Survey.fromJson(Map snapshot) {
    title = snapshot['title'];
    content = snapshot['content'];
    image = snapshot['image'];
    prepared = snapshot['prepared'];
    preparedtype = snapshot['preparedtype'];
    surveyitems = snapshot['surveyitems'] == null ? null : (snapshot['surveyitems'] as List).map((e) => SurveyItem.fromJson(e, (e as Map)['key'])).toList();
    targetList = snapshot['targetList'] == null ? null : List<String>.from(snapshot['targetList']);
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "image": image,
      "prepared": prepared,
      "preparedtype": preparedtype,
      "surveyitems": surveyitems?.map((e) => e.mapForSave()).toList(),
      "targetList": targetList,
    };
  }
}

class SurveyItem {
  String? key;
  String? content;
  String? imgUrl;
  SurveyTypes? type;
  bool? isRequired;
  dynamic extraData;

  SurveyItem({this.key, this.type, this.content, this.extraData});

  SurveyItem.fromJson(Map snapshot, this.key) {
    isRequired = snapshot['r'];
    extraData = snapshot['extraData'];
    content = snapshot['content'];
    imgUrl = snapshot['img'];
    type = snapshot['type'] == null ? null : SurveyTypes.values[snapshot['type']];
  }

  Map<String, dynamic> mapForSave() {
    return {
      "content": content,
      "img": imgUrl,
      "type": SurveyTypes.values.indexOf(type!),
      "extraData": extraData,
      'key': key,
      'r': isRequired,
    };
  }
}
