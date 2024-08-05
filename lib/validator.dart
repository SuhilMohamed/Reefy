// lib/validator.dart

class ValidationResult {
  final bool status;
  final String message;
  final String? birthday;
  final int? age;
  final String? gender;
  final GovInfo? govInfo;

  ValidationResult({
    required this.status,
    required this.message,
    this.birthday,
    this.age,
    this.gender,
    this.govInfo,
  });
}

class GovInfo {
  final String govCode;
  final String govId;
  final String govName;

  GovInfo({
    required this.govCode,
    required this.govId,
    required this.govName,
  });
}

ValidationResult validateNationalID(String id) {
  if (id.isEmpty) {
    return ValidationResult(status: false, message: "الرقم القومي غير صالح");
  }

  id = id.trim();
  if (id.length != 14) {
    return ValidationResult(
        status: false, message: "الرقم القومي يجب أن يساوي 14 رقم");
  }

  var centuryChar = id.substring(0, 1);
  var year = id.substring(1, 3);
  var month = id.substring(3, 5);
  var day = id.substring(5, 7);

  if (int.parse(centuryChar) == 2) {
    year = "19$year";
  } else if (int.parse(centuryChar) == 3) {
    year = "20$year";
  } else {
    return ValidationResult(status: false, message: "سنة غير صالحة");
  }

  DateTime? birthday;
  try {
    birthday = DateTime.parse("$year-$month-$day");
  } catch (e) {
    return ValidationResult(status: false, message: "خطأ في تاريخ الميلاد");
  }

  var govCode = id.substring(7, 9);
  var govInfo = getGovInfo(govCode);
  if (govInfo == null) {
    return ValidationResult(status: false, message: "خطأ في رقم الحكومة");
  }

  var age = DateTime.now().year - birthday.year;
  if (DateTime.now().month < birthday.month ||
      (DateTime.now().month == birthday.month &&
          DateTime.now().day < birthday.day)) {
    age--;
  }

  var genderChar = id.substring(12, 13);
  var gender = int.parse(genderChar) % 2 == 0 ? "2" : "1";

  var checksum = int.parse(id.substring(13, 14));
  var calculatedChecksum = calculateChecksum(id);

  if (checksum != calculatedChecksum) {
    return ValidationResult(status: false, message: "رقم غير صالح");
  }

  return ValidationResult(
    status: true,
    message: "الرقم الوطني صحيح",
    birthday: "$year-$month-$day",
    age: age,
    gender: gender,
    govInfo: govInfo,
  );
}

GovInfo? getGovInfo(String code) {
  switch (code) {
    case "01":
      return GovInfo(govCode: "01", govId: "1", govName: "القاهرة");
    case "02":
      return GovInfo(govCode: "02", govId: "2", govName: "الأسكندرية");
    case "08":
      return GovInfo(govCode: "03", govId: "3", govName: "بورسعيد");
    case "09":
      return GovInfo(govCode: "04", govId: "4", govName: "السويس");
    case "10":
      return GovInfo(govCode: "06", govId: "6", govName: "السادس من أكتوبر");
    case "11":
      return GovInfo(govCode: "11", govId: "11", govName: "دمياط");
    case "12":
      return GovInfo(govCode: "12", govId: "12", govName: "الدقهلية");
    case "13":
      return GovInfo(govCode: "13", govId: "13", govName: "الشرقية");
    case "14":
      return GovInfo(govCode: "14", govId: "14", govName: "القليوبيه");
    case "15":
      return GovInfo(govCode: "15", govId: "15", govName: "كفر الشيخ");
    case "16":
      return GovInfo(govCode: "16", govId: "16", govName: "الغربية");
    case "17":
      return GovInfo(govCode: "17", govId: "17", govName: "المنوفية");
    case "18":
      return GovInfo(govCode: "18", govId: "18", govName: "البحيرة");
    case "19":
      return GovInfo(govCode: "19", govId: "19", govName: "الإسماعيلية");
    case "21":
      return GovInfo(govCode: "21", govId: "21", govName: "الجيزة");
    case "22":
      return GovInfo(govCode: "22", govId: "22", govName: "بنى سويـف");
    case "23":
      return GovInfo(govCode: "23", govId: "23", govName: "الفيوم");
    case "24":
      return GovInfo(govCode: "24", govId: "24", govName: "المنيا");
    case "25":
      return GovInfo(govCode: "25", govId: "25", govName: "اسيوط");
    case "26":
      return GovInfo(govCode: "26", govId: "26", govName: "سوهاج");
    case "27":
      return GovInfo(govCode: "27", govId: "27", govName: "قنا");
    case "28":
      return GovInfo(govCode: "28", govId: "28", govName: "أسوان");
    case "29":
      return GovInfo(govCode: "29", govId: "29", govName: "الاقصر");
    case "31":
      return GovInfo(govCode: "31", govId: "31", govName: "البحر الاحمر");
    case "32":
      return GovInfo(govCode: "32", govId: "32", govName: "الوادى الجديد");
    case "33":
      return GovInfo(govCode: "33", govId: "33", govName: "مطروح");
    case "34":
      return GovInfo(govCode: "34", govId: "34", govName: "شمال سيناء");
    case "35":
      return GovInfo(govCode: "35", govId: "35", govName: "جنوب سيناء");
    default:
      return null;
  }
}

int calculateChecksum(String id) {
  var n = id.substring(0, 13);
  var sum = 0;
  var multiplier = 2;
  for (var i = n.length - 1; i >= 0; i--) {
    if (multiplier > 7) multiplier = 2;
    sum += int.parse(n[i]) * multiplier;
    multiplier++;
  }
  var remainder = sum % 11;
  var checksum = 11 - remainder;
  return checksum > 9 ? checksum - 10 : checksum;
}
