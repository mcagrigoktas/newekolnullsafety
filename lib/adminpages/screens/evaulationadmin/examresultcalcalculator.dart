import 'dart:convert';
import 'dart:typed_data';

import 'package:expressions/expressions.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import 'answerkeyspage/model.dart';
import 'exams/model.dart';
import 'examtypes/model.dart';
import 'opticformtypes/model.dart';

class ExamResultCalculator {
  ExamResultCalculator._();
  static late String errorText;

  /// {
  /// kurumId : {
  ///            studentKey : resultModel
  ///               }
  /// }

  static Future<String?> calcresult({
    //Cevap anahtari nerden alinacak

    required ExamType examType,

    ///seison no -> opticformmodell
    Map<String, OpticFormModel>? opticForms,
    required AnswerKeyModel answerEarningData,
    //kurumId ,seisonno-> datfileurlmap
    Map<String, Map<String, ExamFile?>>? allKurumDatFiles,
    required Map<String, List<Student>> allKurumStudents,
    required Map<String, List<Class>> allKurumClass,
    required String saveLocation,
    required Exam exam,
  }) async {
    errorText = '';
    log('Sinav sonucu hesaplanmaya basladi');
    if (_validateExam(exam, examType, opticForms, allKurumDatFiles) == false) return null;

    ///Sinvi online cozen ogrencilerin llistesini tutar
    ///kurumId->seisonNo->/studetnKeey /{answerData}/{lessonKey->answer}
    Map<String, Map<String, Map<String, Map<String, Map<String, String>>>>>? onlineExamStudentData = await _downloadOnlineStudentAnsweer(exam.key);

    ///cevap anahtari optic formdan alinacaksa cvap anahtarini saklar
    Map<String, Map<String, String>> answerKeyDataFromOpticFrom = {};

    ///Kazanim listesi  cok boyut  kapllamasin diye herbirisine key verilir.
    ///kazanim->kazanimkey
    _earningListKeyMap = {};

    /// {
    /// kurumId : {
    ///            studentKey : resultModel
    ///               }
    /// }
    final Map<String, Map<String, ResultModel?>> allKurumAllStudentResults = allKurumDatFiles!.map<String, Map<String, ResultModel>>((key, value) => MapEntry(key, {}));

    /// LessonKey
    ///      ▷      general [all socres]
    ///      ▷      school
    ///      ▷      class
    Map<String, Map<String, List<double?>>> allNetForAverege = {};

    /// LessonKey
    ///   ▷ Earnings
    ///      ▷      general
    ///      ▷      school
    ///      ▷      class
    ///      ///      ▷      d:1 , y:2, b:0
    Map<String, Map<String, Map<String, Map<String, int>>>> allEarningStatistics = {};

    _allKurumStudentNoKeyMap.clear();

    final isEarningsActive = answerEarningData.earningsIsActive;
    //  _allKurumStudentNoClassMap.clear();

    //  final datFilesEntries = allKurumDatFiles.entries.toList(); Sil
    log('Kurumlalarin cevapllari hesaplanmaya baslaniyor');
    for (var k = 0; k < exam.kurumIdList!.length; k++) {
      var kurumId = exam.kurumIdList![k];
      // var kurumId = datFilesEntries[k].key; Sil
      // var kurumDatFileUrlMap = datFilesEntries[k].value; Sil
      //{studentkey : resulltModel'}
      final Map<String, ResultModel> allStudentResults = {};

      for (var sN = 1; sN < examType.numberOfSeison! + 1; sN++) {
        log('$kurumId  kurumunun sezon $sN hesaplaniyor');
        OpticFormModel? opticForm;
        int studentNoLength;
        int studentIdLength;
        int nameSurnameLength;
        String? datText;
        List<String> rows;

        void calcStudentResult({
          required String studentKey,
          String? studentClass,
          String? studentName,
          String? studentNo,
          String? studentNameOnOpticForm,
          String? studentNoOnOpticForm,
          String? studentIdOnOpticForm,
          String? studentClassOnOpticForm,
          String? bookletType,
          String? studentSection,
          String? rowString, //Opticformdan okunacaksa bu gelmeli
          /// {lessonKey->lessonAnswer}
          Map<String, String>? onlineStudentAnswer, //Online sistemden okunacaksa bu gelmeli
        }) {
          ResultModel result;

          if (allStudentResults[studentKey] == null) {
            result = ResultModel()..lastSeisonNo = sN;
          } else {
            result = allStudentResults[studentKey]!;
            if (result.lastSeisonNo == sN) {
              //todo
              log('Ayni numartaya sahip ogrenci tekrar ediyor. Buraya guvenlik yaz');
            }
            result.lastSeisonNo = sN;
          }
          result.bookletTypes ??= [];
          result.bookletTypes!.add(bookletType);

          result.studentKey = studentKey;
          result.studentNameOnOpticForm = studentNameOnOpticForm;
          result.studentNoOnOpticForm = studentNoOnOpticForm;
          result.studentIdOnOpticForm = studentIdOnOpticForm;
          result.studentClassOnOpticForm = studentClassOnOpticForm;
          result.rSName = studentName;
          result.rSClass = studentClass;
          result.rSNo = studentNo;

          for (var j = 0; j < examType.lessons!.length; j++) {
            final lesson = examType.lessons![j];
            //   log('LessonKey: ' + lesson.key);

            if (examType.numberOfSeison! > 1 && lesson.seisonNo != sN) {
              //         log(lesson.mapForSave());
              continue;
            }

            //   if (r == 0)
            allNetForAverege[lesson.key!] ??= {'general': [], 'school': [], 'class': []};
            if (isEarningsActive!) allEarningStatistics[lesson.name!] ??= {};

            final testResult = TestResultModel(d: 0, y: 0, b: 0, wb: 0, wd: 0, wy: 0, earningResults: {}, wEarningResults: {});

            String? studentAnswers;
            if (rowString != null) {
              studentAnswers = rowString.safeSubString(opticForm!.lessonsData![lesson.key]!.start - 1, opticForm.lessonsData![lesson.key]!.end)!.toLowerCase();
            } else if (onlineStudentAnswer != null) {
              studentAnswers = onlineStudentAnswer[lesson.key!]?.toLowerCase();
            }
            studentAnswers ??= '';

            String realAnswers;
            late List<String> earningList;
            if (isEarningsActive) earningList = answerEarningData.lessonearnings('bookLet' + bookletType!, lesson.key!).split('\n');

            if (answerEarningData.answerKeyLocation == AnswerKeyLocation.menu) {
              realAnswers = answerEarningData.lessonanswers('bookLet' + bookletType!, lesson.key!).toLowerCase();
            } else {
              answerKeyDataFromOpticFrom['seison$sN']!['bookLet' + bookletType!] ??= '';
              realAnswers = answerKeyDataFromOpticFrom['seison$sN']!['bookLet' + bookletType].safeSubString(opticForm!.lessonsData![lesson.key]!.start - 1, opticForm.lessonsData![lesson.key]!.end)!.toLowerCase();
            }

            while (studentAnswers!.length < lesson.questionCount!) {
              studentAnswers += ' ';
            }

            while (realAnswers.length < lesson.questionCount!) {
              realAnswers += ' ';
            }

            if (isEarningsActive) {
              while (earningList.length < lesson.questionCount!) {
                earningList.add('-');
              }
            }

            if (isEarningsActive) compressEarningList(earningList);

            for (var qN = 0; qN < lesson.questionCount!; qN++) {
              if (isEarningsActive) {
                testResult.earningResults![_earningListKeyMap[earningList[qN]]] ??= {'d': 0, 'y': 0, 'b': 0};
                allEarningStatistics[lesson.name]![earningList[qN]] ??= {};
                allEarningStatistics[lesson.name]![earningList[qN]]!['general'] ??= {'d': 0, 'y': 0, 'b': 0};
                allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId] ??= {'d': 0, 'y': 0, 'b': 0};
                allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!] ??= {'d': 0, 'y': 0, 'b': 0};
              }

              String questionAnswerState = 'b';

              if (realAnswers[qN] == '#') {
                questionAnswerState = 'd';
              } else if (realAnswers[qN] == '&') {
                questionAnswerState = 'b';
              } else if (studentAnswers[qN] == ' ') {
                questionAnswerState = 'b';
              } else if (studentAnswers[qN] == realAnswers[qN] && realAnswers[qN] != ' ') {
                questionAnswerState = 'd';
              } else {
                questionAnswerState = 'y';
              }

              if (questionAnswerState == 'b') {
                testResult.b = testResult.b! + 1;
                if (isEarningsActive) {
                  testResult.earningResults![_earningListKeyMap[earningList[qN]]]!['b'] = testResult.earningResults![_earningListKeyMap[earningList[qN]]]!['b']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['general']!['b'] = allEarningStatistics[lesson.name]![earningList[qN]]!['general']!['b']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId]!['b'] = allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId]!['b']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!]!['b'] = allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!]!['b']! + 1;
                }
              } else if (questionAnswerState == 'd') {
                testResult.d = testResult.d! + 1;
                if (isEarningsActive) {
                  testResult.earningResults![_earningListKeyMap[earningList[qN]]]!['d'] = testResult.earningResults![_earningListKeyMap[earningList[qN]]]!['d']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['general']!['d'] = allEarningStatistics[lesson.name]![earningList[qN]]!['general']!['d']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId]!['d'] = allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId]!['d']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!]!['d'] = allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!]!['d']! + 1;
                }
              } else {
                testResult.y = testResult.y! + 1;
                if (isEarningsActive) {
                  testResult.earningResults![_earningListKeyMap[earningList[qN]]]!['y'] = testResult.earningResults![_earningListKeyMap[earningList[qN]]]!['y']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['general']!['y'] = allEarningStatistics[lesson.name]![earningList[qN]]!['general']!['y']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId]!['y'] = allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId]!['y']! + 1;
                  allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!]!['y'] = allEarningStatistics[lesson.name]![earningList[qN]]!['school' + kurumId + 'class' + result.rSClass!]!['y']! + 1;
                }
              }
            }
            if (lesson.rightWrongRate == 0) {
              testResult.n = testResult.d! - 0.0;
            } else {
              testResult.n = testResult.d! - testResult.y! / lesson.rightWrongRate!;
            }
            testResult.realAnswers = realAnswers;
            testResult.studentAnswers = studentAnswers;

            allNetForAverege[lesson.key]!['general']!.add(testResult.n);
            allNetForAverege[lesson.key]!['school' + kurumId] ??= [];
            allNetForAverege[lesson.key]!['school' + kurumId]!.add(testResult.n);
            allNetForAverege[lesson.key]!['school' + kurumId + 'class' + result.rSClass!] ??= [];
            allNetForAverege[lesson.key]!['school' + kurumId + 'class' + result.rSClass!]!.add(testResult.n);

            for (var m = 0; m < lesson.wQuestionCount!; m++) {
              String? wStudentAnswers;
              if (rowString != null) {
                wStudentAnswers = rowString.safeSubString(opticForm!.lessonsData![lesson.key! + '-w${m + 1}']!.start - 1, opticForm.lessonsData![lesson.key! + '-w${m + 1}']!.end);
              } else if (onlineStudentAnswer != null) {
                wStudentAnswers = onlineStudentAnswer[lesson.key! + '-w${m + 1}'];
              }
              wStudentAnswers ??= '';

              String? wRealAnswers;
              String? wEarning;
              if (isEarningsActive) wEarning = answerEarningData.lessonWQuestionEarning('bookLet' + bookletType, lesson.key!, m + 1);
              if (isEarningsActive) compressEarningList([wEarning]);
              if (answerEarningData.answerKeyLocation == AnswerKeyLocation.menu) {
                wRealAnswers = answerEarningData.lessonWQuestionAnswer('bookLet' + bookletType, lesson.key!, m + 1);
              } else {
                answerKeyDataFromOpticFrom['seison$sN']!['bookLet' + bookletType] ??= '';
                wRealAnswers = answerKeyDataFromOpticFrom['seison$sN']!['bookLet' + bookletType].safeSubString(opticForm!.lessonsData![lesson.key! + '-w${m + 1}']!.start - 1, opticForm.lessonsData![lesson.key! + '-w${m + 1}']!.end);
              }

              if (isEarningsActive) testResult.earningResults![_earningListKeyMap[wEarning]] ??= {'d': 0, 'y': 0, 'b': 0};
              if (isEarningsActive) {
                allEarningStatistics[lesson.name]![wEarning!] ??= {};
                allEarningStatistics[lesson.name]![wEarning]!['general'] ??= {'d': 0, 'y': 0, 'b': 0};
                allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId] ??= {'d': 0, 'y': 0, 'b': 0};
                allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!] ??= {'d': 0, 'y': 0, 'b': 0};
              }
              //todo burayi danis

              String wQuestionAnswerState = 'b';
              if (wRealAnswers!.trim() == '#') {
                wQuestionAnswerState = 'd';
              } else if (wRealAnswers.trim() == '&') {
                wQuestionAnswerState = 'b';
              } else if (wStudentAnswers.trim() == ' ') {
                wQuestionAnswerState = 'b';
              } else if (wStudentAnswers.trim() == wRealAnswers.trim()) {
                wQuestionAnswerState = 'd';
              } else {
                wQuestionAnswerState = 'y';
              }

              if (wQuestionAnswerState == 'b') {
                testResult.wb = testResult.wb! + 1;
                if (isEarningsActive) {
                  testResult.earningResults![_earningListKeyMap[wEarning]]!['b'] = testResult.earningResults![_earningListKeyMap[wEarning]]!['b']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['general']!['b'] = allEarningStatistics[lesson.name]![wEarning]!['general']!['b']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId]!['b'] = allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId]!['b']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!]!['b'] = allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!]!['b']! + 1;
                }
              } else if (wQuestionAnswerState == 'd') {
                testResult.wd = testResult.wd! + 1;
                if (isEarningsActive) {
                  testResult.earningResults![_earningListKeyMap[wEarning]]!['d'] = testResult.earningResults![_earningListKeyMap[wEarning]]!['d']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['general']!['d'] = allEarningStatistics[lesson.name]![wEarning]!['general']!['d']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId]!['d'] = allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId]!['d']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!]!['d'] = allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!]!['d']! + 1;
                }
              } else {
                testResult.wy = testResult.wy! + 1;
                if (isEarningsActive) {
                  testResult.earningResults![_earningListKeyMap[wEarning]]!['y'] = testResult.earningResults![_earningListKeyMap[wEarning]]!['y']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['general']!['y'] = allEarningStatistics[lesson.name]![wEarning]!['general']!['y']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId]!['y'] = allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId]!['y']! + 1;
                  allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!]!['y'] = allEarningStatistics[lesson.name]![wEarning]!['school' + kurumId + 'class' + result.rSClass!]!['y']! + 1;
                }
              }
            }

            result.testResults![lesson.key] = testResult;
          }

          allStudentResults[studentKey] = result;
        }

        if (exam.formType.isOpticFormActive) {
          opticForm = opticForms!['seison$sN'];
          studentNoLength = opticForm!.studentNumberData!.end - opticForm.studentNumberData!.start + 1;
          studentIdLength = opticForm.studentIdData!.end - opticForm.studentIdData!.start + 1;
          nameSurnameLength = opticForm.studentNameData!.end - opticForm.studentNameData!.start + 1;

          datText = await _downloadDatFile(kurumId, allKurumDatFiles[kurumId], sN);

          datText ??= '';
          rows = datText.split(RegExp("\r|\n"));
          if (answerEarningData.answerKeyLocation == AnswerKeyLocation.opticForm) {
            for (var r = 0; r < rows.length; r++) {
              final rowString = rows[r];
              final studentNoOnOpticForm = rowString.safeSubString(opticForm.studentNumberData!.start - 1, opticForm.studentNumberData!.end)!;
              if (int.tryParse(studentNoOnOpticForm) == 0) {
                final bookLetType = rowString.safeSubString(opticForm.bookletTypeData!.start - 1, opticForm.bookletTypeData!.end)!.trim();
                answerKeyDataFromOpticFrom['seison$sN'] ??= {};
                answerKeyDataFromOpticFrom['seison$sN']!['bookLet' + bookLetType] = rowString;
              }
            }
          }

          for (var r = 0; r < rows.length; r++) {
            final rowString = rows[r];

            if (rowString.safeLength < 10) continue;

            var studentNoOnOpticForm = rowString.safeSubString(opticForm.studentNumberData!.start - 1, opticForm.studentNumberData!.end)!;
            var studentIdOnOpticForm = rowString.safeSubString(opticForm.studentIdData!.start - 1, opticForm.studentIdData!.end);

            if (int.tryParse(studentNoOnOpticForm) == 0) continue;
            //  if (studentNoOnOpticForm.trim() == '' && studentIdOnOpticForm.trim() == '') continue;

            var studentNameOnOpticForm = rowString.safeSubString(opticForm.studentNameData!.start - 1, opticForm.studentNameData!.end);
            var studentClassOnOpticForm = rowString.safeSubString(opticForm.studentClassData!.start - 1, opticForm.studentClassData!.end)!;
            if (studentClassOnOpticForm.trim().isEmpty) {
              studentClassOnOpticForm = 'noclass';
            }
            if (studentNoOnOpticForm.trim().isEmpty) studentNoOnOpticForm = 'Row$r';
            //[studentkey,studentno,studentname,studentclass]
            List<String?> studentInfo = _getStudentInfo(kurumId, allKurumStudents[kurumId]!, studentNoOnOpticForm.trim(), studentNameOnOpticForm, studentClassOnOpticForm, allKurumClass[kurumId], studentNoLength, nameSurnameLength, studentIdOnOpticForm!.trim(), studentIdLength);

            final bookletType = rowString.safeSubString(opticForm.bookletTypeData!.start - 1, opticForm.bookletTypeData!.end)!.trim();
            var studentSection = rowString.safeSubString(opticForm.studentSectionData!.start - 1, opticForm.studentSectionData!.end);

            calcStudentResult(
              studentClass: studentInfo[3],
              studentKey: studentInfo[0]!,
              studentName: studentInfo[2],
              studentNo: studentInfo[1],
              studentClassOnOpticForm: studentClassOnOpticForm,
              studentNameOnOpticForm: studentNameOnOpticForm,
              studentNoOnOpticForm: studentNoOnOpticForm,
              studentIdOnOpticForm: studentIdOnOpticForm,
              bookletType: bookletType,
              studentSection: studentSection,
              rowString: rowString,
            );
          }
        }
        if (exam.formType.isOnlineFormActive && onlineExamStudentData != null && onlineExamStudentData[kurumId] != null) {
          ///kurumId->seisonNo->/studetnKeey /{answerData}/{lessonKey->answer}
          onlineExamStudentData[kurumId]!['seison$sN']?.forEach((studentKey, value) {
            if (value['answerData'] != null) {
              final studentInfo = _getStudentInfoFromKey(kurumId, allKurumStudents[kurumId]!, allKurumClass[kurumId]!, studentKey);

              if (studentInfo != null) {
                calcStudentResult(
                    studentClass: studentInfo[3],
                    studentKey: studentInfo[0]!,
                    studentName: studentInfo[2],
                    studentNo: studentInfo[1],
                    studentClassOnOpticForm: studentInfo[3],
                    studentNameOnOpticForm: studentInfo[2],
                    studentNoOnOpticForm: studentInfo[1],
                    studentIdOnOpticForm: studentInfo[4],
                    bookletType: 'A',
                    studentSection: '',
                    onlineStudentAnswer: value['answerData']);
              }
            }
          });
        }
      }

      allKurumAllStudentResults[kurumId] = allStudentResults;
    }

    return makeStatistics(examType, allKurumAllStudentResults, allKurumStudents, allNetForAverege, saveLocation, allEarningStatistics, answerEarningData);
  }

  static Future<String?> makeStatistics(
    ExamType examType,
    Map<String, Map<String, ResultModel?>> allKurumAllStudentResults,
    Map<String, List<Student>> allKurumStudent,
    Map<String, Map<String, List<double?>>> allNetForAverege,
    String saveLocation,
    Map<String, Map<String, Map<String, Map<String, int>>>> allEarningStatistics,
    AnswerKeyModel answerEarningData,
  ) async {
    log('Istatistik hesaplanmaya basladi');

    /// ScoreKey
    ///      ▷      general [all socres]
    ///      ▷      school
    ///      ▷      class
    Map<String, Map<String, List<double>>> allScoreForOrder = {};

    ///Burda puanlar hesaplaniyor
    final evaluator = ExpressionEvaluator();
    Map<String, String> formuleKeyCodeList = examType.lessons!.fold({}, (p, e) {
      p[e.key!] = e.formuleKey!;
      if (e.wFormuleKey.safeLength == 1) p[e.key! + '-w'] = e.wFormuleKey!;
      return p;
    });

    final allKurumAllStudentResultsEntries = allKurumAllStudentResults.entries.toList();
    for (var k = 0; k < allKurumAllStudentResultsEntries.length; k++) {
      final kurumId = allKurumAllStudentResultsEntries[k].key;
      final kurumEntries = allKurumAllStudentResultsEntries[k].value;

      final kurumStudentResultValues = kurumEntries.values.toList();

      for (var s = 0; s < examType.scoring!.length; s++) {
        final scoring = examType.scoring![s];

        allScoreForOrder[scoring.key!] ??= {'general': [], 'school': [], 'class': []};

        final expression = Expression.parse(scoring.formule!);

        for (var i = 0; i < kurumStudentResultValues.length; i++) {
          final studentresult = kurumStudentResultValues[i];

          var context = formuleKeyCodeList.map((lessonkey, code) {
            ///Bir ogrenci birinci oturuma katilmis ama ikinci otruma katilmamis olabillilr
            /// bu durumda ogrencinin ikinci oturumdaki derslerin netleri olmadigindan sistem hata verebilir
            ///bunun onune gecebillmek icin o derslere bos data yazdim
            if (studentresult!.testResults![lessonkey] == null) {
              studentresult.testResults![lessonkey] = TestResultModel(d: 0, b: 0, y: 0, wd: 0, wb: 0, wy: 0, n: 0);
            }

            if (lessonkey.endsWith('-w')) {
              return MapEntry(code, studentresult.testResults![lessonkey.replaceAll('-w', '')]!.wd);
            } else {
              return MapEntry(code, studentresult.testResults![lessonkey]!.n);
            }
          });

          var score = evaluator.eval(expression, context);

          if (score is num) {
            score = score.toDouble().decimalCrop(3);
            studentresult!.scoreResults![scoring.key] = ScorResultModel(name: scoring.name, scoreKey: scoring.key, groupKey: scoring.groupKey, score: score as double);

            ///siralama icin order kismina kaydediliyor
            allScoreForOrder[scoring.key]!['general']!.add(score);
            allScoreForOrder[scoring.key]!['school' + kurumId] ??= [];
            allScoreForOrder[scoring.key]!['school' + kurumId]!.add(score);
            allScoreForOrder[scoring.key]!['school' + kurumId + 'class' + studentresult.rSClass!] ??= [];
            allScoreForOrder[scoring.key]!['school' + kurumId + 'class' + studentresult.rSClass!]!.add(score);
          } else {
            log('score num degil $score');
          }
        }
      }
    }
    log('tum netlerinortalamalari hesaplaniyor');

    ///burda tum netlerinortalamalari hesaplaniyor
    Map lessonKeyNetAwarageList = {};

    allNetForAverege.forEach((lessonKey, lessonAvareage) {
      lessonKeyNetAwarageList[lessonKey] = {};
      lessonAvareage.forEach((awarageKey, value) {
        lessonKeyNetAwarageList[lessonKey][awarageKey] = value.isEmpty ? 0.0 : List<double>.from(value).average.decimalCrop(3);
      });
    });
    log('tum puanlarin ortalamalari hesaplaniyor');

    ///burda tum puanlarin ortalamalari hesaplaniyor
    Map scoreKeyAwarageList = {};
    allScoreForOrder.forEach((scoreKey, scoreAvareage) {
      scoreKeyAwarageList[scoreKey] = {};
      scoreAvareage.forEach((awarageKey, value) {
        allScoreForOrder[scoreKey]![awarageKey] = value..sort((b, a) => a.compareTo(b));
        scoreKeyAwarageList[scoreKey][awarageKey] = value.isEmpty ? 0.0 : value.average.decimalCrop(3);
      });
    });
    log('puanlarda kacinci oldugu ve net ortalamalari ogrenci result datasina yaziliyor');

    ///Burda puanlarda kacinci oldugu ve net ortalamalari ogrenci result datasina yaziliyor

    allKurumAllStudentResultsEntries.forEach((e1) {
      final kurumId = e1.key;
      e1.value.forEach((studentKey, studentResult) {
        examType.lessons!.forEach((lesson) {
          studentResult!.testResults![lesson.key]!.generalAwerage = lessonKeyNetAwarageList[lesson.key]['general'];
          studentResult.testResults![lesson.key]!.schoolAwerage = lessonKeyNetAwarageList[lesson.key]['school' + kurumId];
          studentResult.testResults![lesson.key]!.classAwerage = lessonKeyNetAwarageList[lesson.key]['school' + kurumId + 'class' + studentResult.rSClass!];
        });
        studentResult!.scoreResults!.forEach((scoreKey, scorResullt) {
          scorResullt.generalAwerage = scoreKeyAwarageList[scoreKey]['general'];
          scorResullt.schoolAwerage = scoreKeyAwarageList[scoreKey]['school' + kurumId];
          scorResullt.classAwerage = scoreKeyAwarageList[scoreKey]['school' + kurumId + 'class' + studentResult.rSClass!];
          scorResullt.generalOrder = allScoreForOrder[scoreKey]!['general']!.indexOf(scorResullt.score) + 1;
          scorResullt.schoolOrder = allScoreForOrder[scoreKey]!['school' + kurumId]!.indexOf(scorResullt.score) + 1;
          scorResullt.classOrder = allScoreForOrder[scoreKey]!['school' + kurumId + 'class' + studentResult.rSClass!]!.indexOf(scorResullt.score) + 1;
          scorResullt.generalStudentCount = allScoreForOrder[scoreKey]!['general']!.length;
          scorResullt.schoolStudentCount = allScoreForOrder[scoreKey]!['school' + kurumId]!.length;
          scorResullt.classStudentCount = allScoreForOrder[scoreKey]!['school' + kurumId + 'class' + studentResult.rSClass!]!.length;
        });
      });
    });
    log('Big data olusturuluyor');

    ///

    Map finalResult = (ExamResultBigData()
          ..examResult = allKurumAllStudentResults
          ..earningResult = allEarningStatistics
          ..earninKeyMap = _earningListKeyMap
          ..earningIsActive = answerEarningData.earningsIsActive)
        .mapForSave();

    // {
    //   'examResult': allKurumAllStudentResults.map((kurumId, value) => MapEntry(kurumId, value.map((studenkey, value) => MapEntry(studenkey, value.mapForSave())))),
    //   'earningResult': allEarningStatistics,
    //   'earninKeyMap': _earningListKeyMap,
    //   'earningIsActive': answerEarningData.earningsIsActive,
    // };
    log('Sinav sonucu hesaplama bitti');
    var uploadString = json.encode(finalResult);

    String fileName = 'res${8.makeKey}.txt';

    if (Fav.noConnection()) return null;
    final url = await Storage().uploadBytes(MyFile(name: fileName, byteData: Uint8List.fromList(utf8.encode(uploadString))), saveLocation, fileName, dataImportance: DataImportance.medium);

    return url;
  }

  static List<String?>? _getStudentInfoFromKey(String? kurumId, List<Student> studentList, List<Class> classList, String studentKey) {
    var student = studentList.firstWhereOrNull((element) => element.key == studentKey);
    if (student == null) return null;
    return [student.key, student.no, student.name, _getClassName(kurumId, classList, student.class0) ?? 'noclass', student.tc];
  }

  static List<String?> _getStudentInfo(
    String? kurumId,
    List<Student> studentList,
    String studentNoOnOpticForm,
    String? studentNameOnOpticForm,
    String studentClassOnOpticForm,
    List<Class>? classList,
    int studentNoLength,
    int nameSurnameLength,
    String studentIdOnOpticForm,
    int studentIdLength,
  ) {
    var student = _getStudentKeyFromNo(kurumId, studentList, studentNoOnOpticForm, studentNoLength);
    student ??= _getStudentKeyFromId(kurumId, studentList, studentIdOnOpticForm, studentIdLength);
    //! Id yerine tel numarasi girersede eslestirmesi icin ilerde gercekten tel yerine tel girilince caliscak sekildede yapabilir ekstradanda ekleyebilirsin
    student ??= _getStudentKeyFromPhone(kurumId, studentList, studentIdOnOpticForm, studentIdLength);
    student ??= _getStudentKeyFromName(kurumId, studentList, studentNameOnOpticForm, nameSurnameLength);

    // soru isaretleri degistirillemez
    if (student == null) return ['??' + 6.makeKey, '??' + studentNoOnOpticForm + 2.makeKey, studentNameOnOpticForm, studentClassOnOpticForm, studentIdOnOpticForm];

    return [student.key, student.no, student.name, _getClassName(kurumId, classList!, student.class0) ?? studentClassOnOpticForm, studentIdOnOpticForm];
  }

  ///Hizlandirmak icin ogrenci nosu verildiginde direk ogrenci keyi veren liste
//{kurumId,{studentNo : student.key} }
  static final Map<String?, Map<String, String>> _allKurumClassNameKeyMap = {};
  static String? _getClassName(String? kurumId, List<Class> classList, String? classKey) {
    _allKurumClassNameKeyMap[kurumId] ??= classList.fold(<String, String>{}, (p, e) => p..[e.key!] = e.name!);

    return _allKurumClassNameKeyMap[kurumId]![classKey];
  }

  ///Hizlandirmak icin ogrenci nosu verildiginde direk ogrenci keyi veren liste
//{kurumId,{studentNo : student.key} }
  static final Map<String?, Map<String, Student>> _allKurumStudentNoKeyMap = {};
  static Student? _getStudentKeyFromNo(String? kurumId, List<Student> studentList, String no, int studentNoLength) {
    _allKurumStudentNoKeyMap[kurumId] ??= studentList.fold(<String, Student>{}, (p, e) {
      var studentNo = e.no!.trim();
      if (studentNo.safeLength < 1 || int.tryParse(studentNo) == 0) return p;

      while (studentNo.length < studentNoLength) {
        studentNo = '0' + studentNo;
      }
      return p..[studentNo] = e;
    });

    while (no.length < studentNoLength) {
      no = '0' + no;
    }

    return _allKurumStudentNoKeyMap[kurumId]![no];
  }

  ///Hizlandirmak icin ogrenci idsi verildiginde direk ogrenci keyi veren liste
//{kurumId,{studentId : student.key} }
  static final Map<String?, Map<String, Student>> _allKurumStudentIdKeyMap = {};
  static Student? _getStudentKeyFromId(String? kurumId, List<Student> studentList, String id, int studentIdLength) {
    _allKurumStudentIdKeyMap[kurumId] ??= studentList.fold(<String, Student>{}, (p, e) {
      var studentId = e.tc!.trim();
      if (studentId.safeLength < 1 || int.tryParse(studentId) == 0) return p;

      while (studentId.length < studentIdLength) {
        studentId = '0' + studentId;
      }
      return p..[studentId] = e;
    });

    while (id.length < studentIdLength) {
      id = '0' + id;
    }

    return _allKurumStudentIdKeyMap[kurumId]![id];
  }

  ///Hizlandirmak icin ogrenci telefonu verildiginde direk ogrenci keyi veren liste
//{kurumId,{studentPhone : student.key} }
//! Buraya Simdilik telefon yerine Ogreni id si gonderiliyor
//! Bu su demek. Optic formda Ogrenci id si yerine telefon girildiginde ogrenciyi eslestirmeye calisir.
//! Eger telefonuda optic formda alinmak isterse student Id sinin alindigi gibi telde alinmali
//! Telefon numarasi eslestirilirken son 8 karakteri uyuyormu bakiliyor
  static final Map<String?, Map<String, Student>> _allKurumStudentPhoneKeyMap = {};
  static const _phoneMatchCount = 8;
  static Student? _getStudentKeyFromPhone(String? kurumId, List<Student> studentList, String? phone, int studentPhoneLength) {
    if (studentPhoneLength < _phoneMatchCount) return null;
    if (phone.safeLength < _phoneMatchCount) return null;
    _allKurumStudentPhoneKeyMap[kurumId] ??= studentList.fold(<String, Student>{}, (p, e) {
      var studentPhone = e.studentPhone!.trim();
      if (studentPhone.safeLength < _phoneMatchCount || int.tryParse(studentPhone) == 0) return p;
      studentPhone = studentPhone.lastXcharacter(_phoneMatchCount)!;
      return p..[studentPhone] = e;
    });

    phone = phone.lastXcharacter(_phoneMatchCount);

    return _allKurumStudentPhoneKeyMap[kurumId]![phone!];
  }

  static Student? _getStudentKeyFromName(String? kurumId, List<Student> studentList, String? studentNameOnOpticForm, int nameSurnameLength) {
    final list = studentList.where((element) => element.name.firstXcharacter(nameSurnameLength)!.toLowerCase() == studentNameOnOpticForm.firstXcharacter(nameSurnameLength)!.toLowerCase());
    if (list.length == 1) return list.first;
    return null;
  }

  // static final Map<String, Map<String, String>> _allKurumStudentNoClassMap = {};
  // static String _getStudentClassFromNo(String kurumId, List<Student> studentList, String no) {
  //   _allKurumStudentNoClassMap[kurumId] ??= studentList.fold(<String, String>{}, (p, e) => p..[e.no] = e.class0);
  //   if (_allKurumStudentNoClassMap[kurumId][no] == null) _allKurumStudentNoClassMap[kurumId][no] = 'mcg' + 6.makeKey;
  //   return _allKurumStudentNoClassMap[kurumId][no];
  // }

  /// sinav okuma yardimcilari
  static bool _validateExam(Exam exam, ExamType examType, Map<String, OpticFormModel>? opticForms, Map<String?, Map<String, ExamFile?>>? datFiles) {
    bool error = false;

    // datFiles.forEach((kurumId, kurumDatFileList) {
    //   for (var sn = 1; sn < examType.numberOfSeison + 1; sn++) {
    //     if (!kurumDatFileList.containsKey('seison$sn')) {
    //       OverAlert.show(message: 'examrescultcalculateerr1'.argTranslate([kurumId]));
    //       error = true;
    //     }
    //   }
    // });
    if (exam.formType.isOpticFormActive) {
      Iterable.generate(examType.numberOfSeison!).forEach((s) {
        if (opticForms == null || opticForms['seison' + (s + 1).toString()] == null) {
          OverAlert.show(message: 'examrescultcalculateerr3'.translate);
          error = true;
        }
      });
    }

    return !error;
  }

  ///seisonNo->/kurumId->/studetnKeey /{answerData}/{lessonKey->answer}
  static Future<Map<String, Map<String, Map<String, Map<String, Map<String, String>>>>>?> _downloadOnlineStudentAnsweer(String? examKey) async {
    log('Ogrenci onlline sinav cevap llistesi indiriliyor');

    Map? data = (await ExamService.dbGetOnlineExamAllStudentAnswer(examKey).once())?.value;
    if (data == null) return null;
    try {
      return data.map<String, Map<String, Map<String, Map<String, Map<String, String>>>>>((seisonNo, seisonData) => MapEntry<String, Map<String, Map<String, Map<String, Map<String, String>>>>>(
          seisonNo,
          (seisonData as Map).map<String, Map<String, Map<String, Map<String, String>>>>((kurumId, kurumData) => MapEntry<String, Map<String, Map<String, Map<String, String>>>>(
              kurumId,
              (kurumData as Map).map<String, Map<String, Map<String, String>>>((studentKey, studentData) => MapEntry<String, Map<String, Map<String, String>>>(
                  studentKey, (studentData as Map).map<String, Map<String, String>>((answerData, studentAnswerData) => MapEntry<String, Map<String, String>>(answerData, (studentAnswerData as Map).map<String, String>((lessonKey, answers) => MapEntry<String, String>(lessonKey, answers))))))))));
    } catch (err) {
      return null;
    }
  }

  static Future<String?> _downloadDatFile(
    String? kurumId,
    Map<String, ExamFile?>? kurumDatFiles,
    int seisonNo,
  ) async {
    if (kurumDatFiles == null || kurumDatFiles['seison$seisonNo'] == null) {
      errorText += 'examrescultcalculateerr1'.argTranslate(kurumId!);
      return null;
    }
    final datUrl = kurumDatFiles['seison$seisonNo']!.url!;

    var downloadedFile = await DownloadManager.downloadThenCache(url: datUrl);
    if (downloadedFile == null) {
      Get.back();
      OverAlert.show(message: 'filenotexist'.translate + '($kurumId) ($seisonNo)');
      return null;
    }

    try {
      //  String textFile = downloadedFile.byteData.convertText(allowInvalidCharacter: true, letterByLetter: true);
      // String textFile = downloadedFile.byteData.convertAdvanceText();
      String textFile = utf8.decode(downloadedFile.byteData, allowMalformed: true);
      //print('Yaz: $textFile');
      if (textFile.isEmpty) {
        Get.back();
        OverAlert.show(message: 'examrescultcalculateerr2'.translate + '($kurumId) ($seisonNo)');
        return null;
      }

      //! utf8 turkce karakterleri duzgun yapamayip yerine 2 soru isaretli garip simgeyi koyuyor
      //! buda uzunluk dizilimini bozuyor. surekli 2 karaktermi koyuyor bilmiyoruz.
      //! Simdilik gecic olarak bu iki karakteri normal soru isaretine donduren kod girildi
      //  textFile = textFile.replaceAll('��', '?');

      //! yanlissa kaldir
      return textFile;
    } catch (err) {
      log(err);
      Get.back();
      OverAlert.show(message: 'examrescultcalculateerr2'.translate + '($kurumId) ($seisonNo)');
      return null;
    }
  }

  ///Kazanimlar her ogrenciye yazildiginda cok buyuk boyutlu dosya olustugu icin 2 haneli  bir  numara  verme ihtiyaci dogdu

  static Map<String?, String> _earningListKeyMap = {};
  static void compressEarningList(List<String?> earningData) {
    for (String? earning in earningData) {
      if (_earningListKeyMap.containsKey(earning)) continue;

      String key = 2.makeKey;
      while (_earningListKeyMap.values.contains(key)) {
        key = 2.makeKey;
      }

      _earningListKeyMap[earning] = key;
    }
  }
}

class ExamResultBigData {
  Map<String?, Map<String?, ResultModel?>?>? examResult;
  Map<String?, Map<String?, Map<String, Map<String, int>>>>? earningResult;
  Map<String?, String>? earninKeyMap;
  bool? earningIsActive;
  ExamResultBigData();

  ExamResultBigData.fromJson(Map snapshot) {
    examResult = snapshot['examResult'] == null
        ? null
        : (snapshot['examResult'] as Map).map<String, Map<String, ResultModel>?>((kurumId, value) => MapEntry<String, Map<String, ResultModel>?>(kurumId, value.map<String, ResultModel>((studenkey, value) => MapEntry<String, ResultModel>(studenkey, ResultModel.fromJson(value)))));
    earningResult = snapshot['earningResult'] == null
        ? null
        : (snapshot['earningResult'] as Map).map<String, Map<String, Map<String, Map<String, int>>>>((lessonKey, value1) => MapEntry<String, Map<String, Map<String, Map<String, int>>>>(lessonKey,
            (value1 as Map).map<String, Map<String, Map<String, int>>>((earningName, value2) => MapEntry<String, Map<String, Map<String, int>>>(earningName, (value2 as Map).map<String, Map<String, int>>((populasyonKey, value3) => MapEntry(populasyonKey, Map<String, int>.from(value3)))))));
    earninKeyMap = snapshot['earninKeyMap'] == null ? null : Map<String, String>.from(snapshot['earninKeyMap']);
    earningIsActive = snapshot['earningIsActive'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      'examResult': examResult!.map((kurumId, value) => MapEntry(kurumId, value!.map((studenkey, value) => MapEntry(studenkey, value!.mapForSave())))),
      'earningResult': earningResult,
      'earninKeyMap': earninKeyMap,
      'earningIsActive': earningIsActive,
    };
  }
}
