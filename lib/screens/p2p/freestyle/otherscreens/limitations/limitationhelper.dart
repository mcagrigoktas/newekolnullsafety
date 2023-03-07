class LimitationHelper {
  LimitationHelper._();

  static Map<String?, Map<String, List<int?>>> parseData(Map snap) {
    var data = <String?, Map<String, List<int?>>>{};
    (snap).forEach((teacherKey, value1) {
      (value1 as Map).forEach((day, times) {
        data[teacherKey] ??= {};
        data[teacherKey]![day] = List<int?>.from(times);
      });
    });
    return data;
  }
}
