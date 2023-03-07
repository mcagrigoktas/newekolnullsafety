enum PreRegisterStatus { aktif, saved, cancelled }

class PreRegisterModel {
  String? key;
  PreRegisterStatus? status;
  String? name;
  String? tc;
  int? birthday;
  bool? gender;
  String? motherName;
  String? fatherName;
  String? motherPhone;
  String? fatherPhone;
  String? explanation;
  String? not1;
  String? not2;
  String? not3;

  PreRegisterModel();

  PreRegisterModel.fromJson(Map snapshot, this.key) {
    snapshot.forEach((key, value) {
      if (key == "status") {
        status = PreRegisterStatus.values[value];
      } else if (key == "name") {
        name = value;
      } else if (key == "tc") {
        tc = value;
      } else if (key == "birthday") {
        birthday = value;
      } else if (key == "gender") {
        gender = value;
      } else if (key == "motherName") {
        motherName = value;
      } else if (key == "fatherName") {
        fatherName = value;
      } else if (key == "motherPhone") {
        motherPhone = value;
      } else if (key == "fatherPhone") {
        fatherPhone = value;
      } else if (key == "explanation") {
        explanation = value;
      } else if (key == "not1") {
        not1 = value;
      } else if (key == "not2") {
        not2 = value;
      } else if (key == "not3") {
        not3 = value;
      }
    });
  }
  Map<String, dynamic> mapForSave() {
    return {
      "status": PreRegisterStatus.values.indexOf(status!),
      "name": name,
      "tc": tc,
      "birthday": birthday,
      "gender": gender,
      "motherName": motherName,
      "fatherName": fatherName,
      "motherPhone": motherPhone,
      "fatherPhone": fatherPhone,
      "explanation": explanation,
      "not1": not1,
      "not2": not2,
      "not3": not3,
    };
  }
}
