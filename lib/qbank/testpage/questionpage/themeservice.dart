import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static TestPageThemeModel theme1 = TestPageThemeModel(
    isLight: false,
    fontSize: 16.0,
    backgroundColor: const Color(0xff2e3138),
    primaryGradient: const LinearGradient(colors: [Color(0xff373561), Color(0xff373561)], begin: Alignment.topLeft, end: Alignment.topRight),
    primaryTextColor: Colors.white,
    questionBgGradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
    questionTextColor: Colors.white,
    questionBgShadowColor: Colors.black.withAlpha(0),
    optionBgColor: Colors.white.withAlpha(25),
    optionTextColor: Colors.white,
    optionShadowColor: Colors.black.withAlpha(25),
    bottomNavigationBarColor: const Color(0x553D474F),
    bottomNavigationTextColor: Colors.white,
    activeQuestionBgColor: const Color(0xff373561),
    passiveQuestionBgColor: Colors.white.withAlpha(25),
    drawTextColor: Colors.white,
  );

  static TestPageThemeModel theme2 = TestPageThemeModel(
    isLight: true,
    fontSize: 16.0,
    backgroundColor: Colors.white,
    primaryGradient: const LinearGradient(colors: [Color(0xffffffff), Color(0xffE9EAED)], begin: Alignment.topLeft, end: Alignment.topRight),
    primaryTextColor: const Color(0xff1F314A),
    questionBgGradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
    questionTextColor: const Color(0xff1F314A),
    questionBgShadowColor: const Color(0xff648BBB).withAlpha(0),
    optionBgColor: const Color(0xffFFffff),
    optionTextColor: const Color(0xff636363),
    optionShadowColor: Colors.black.withAlpha(25),
    bottomNavigationTextColor: const Color(0xff1F314A),
    bottomNavigationBarColor: const Color(0xffFAFAFA),
    activeQuestionBgColor: const Color(0xffdddddd),
    passiveQuestionBgColor: const Color(0xffdddddd),
    drawTextColor: Colors.black,
  );
  static TestPageThemeModel theme6 = TestPageThemeModel(
    isLight: false,
    fontSize: 16.0,
    backgroundColor: const Color(0xffffffff),
    primaryGradient: const LinearGradient(colors: [Color(0xff373561), Color(0xff373561)], begin: Alignment.topLeft, end: Alignment.topRight),
    primaryTextColor: Colors.white,
    questionBgGradient: const LinearGradient(colors: [Colors.white, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
    questionTextColor: Colors.black,
    questionBgShadowColor: Colors.black.withAlpha(50),
    optionBgColor: Colors.white,
    optionTextColor: Colors.black,
    optionShadowColor: Colors.black.withAlpha(25),
    bottomNavigationTextColor: const Color(0xff5763F6),
    bottomNavigationBarColor: const Color(0xffFAFAFA),
    activeQuestionBgColor: const Color(0xff5763F6),
    passiveQuestionBgColor: const Color(0xffFAFAFA),
    drawTextColor: const Color(0xff636363),
  );

  static TestPageThemeModel theme5 = TestPageThemeModel(
    isLight: false,
    fontSize: 16.0,
    backgroundColor: Colors.white,
    primaryGradient: const LinearGradient(colors: [Color(0xffEC7163), Color(0xffDE5D63)], begin: Alignment.topLeft, end: Alignment.topRight),
    primaryTextColor: const Color(0xffffffff),
    questionBgGradient: const LinearGradient(colors: [Color(0xff648BBB), Color(0xff89B8DC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    questionTextColor: const Color(0xffffffff),
    questionBgShadowColor: const Color(0xff648BBB),
    optionBgColor: const Color(0xffFFffff),
    optionTextColor: const Color(0xff636363),
    optionShadowColor: Colors.black.withAlpha(25),
    bottomNavigationTextColor: const Color(0xffffffff),
    bottomNavigationBarColor: const Color(0xffFAFAFA),
    activeQuestionBgColor: const Color(0xffEC7163),
    passiveQuestionBgColor: const Color(0xffffffff),
    drawTextColor: const Color(0xff636363),
  );

  static TestPageThemeModel theme3 = TestPageThemeModel(
    isLight: false,
    fontSize: 16.0,
    backgroundColor: Colors.white,
    primaryGradient: const LinearGradient(colors: [Color(0xffffdbcf), Color(0xffffdbcf)], begin: Alignment.topLeft, end: Alignment.topRight),
    primaryTextColor: const Color(0xff442b2d),
    questionBgGradient: const LinearGradient(colors: [Color(0xffffdbcf), Color(0xffffdbcf)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    questionTextColor: const Color(0xff442b2d),
    questionBgShadowColor: const Color(0xffffdbcf),
    optionBgColor: const Color(0xffFFFBFA),
    optionTextColor: const Color(0xff442b2d),
    optionShadowColor: Colors.black.withAlpha(25),
    bottomNavigationTextColor: const Color(0xff442b2d),
    bottomNavigationBarColor: const Color(0xffFAFAFA),
    activeQuestionBgColor: const Color(0xffffdbcf),
    passiveQuestionBgColor: const Color(0xffffffff),
    drawTextColor: const Color(0xff636363),
  );

  static TestPageThemeModel theme4 = TestPageThemeModel(
    isLight: false,
    fontSize: 16.0,
    backgroundColor: const Color(0xffF1EFE8),
    primaryGradient: const LinearGradient(colors: [Color(0xff232323), Color(0xff232323)], begin: Alignment.topLeft, end: Alignment.topRight),
    primaryTextColor: const Color(0xffF1EFE8),
    questionBgGradient: const LinearGradient(colors: [Color(0xffF1EFE8), Color(0xffF1EFE8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    questionTextColor: const Color(0xff232323),
    questionBgShadowColor: const Color(0xffF1EFE8),
    optionBgColor: const Color(0xffF1EFE8),
    optionTextColor: const Color(0xff232323),
    optionShadowColor: Colors.black.withAlpha(25),
    bottomNavigationTextColor: const Color(0xffF1EFE8),
    bottomNavigationBarColor: const Color(0xffF1EFE8),
    activeQuestionBgColor: const Color(0xff232323),
    passiveQuestionBgColor: const Color(0xffF1EFE8),
    drawTextColor: const Color(0xff636363),
  );
}

class TestPageThemeModel {
  bool? isLight;
  Gradient primaryGradient;
  Color? primaryTextColor;
  Gradient? questionBgGradient;
  Color? questionTextColor;
  Color? optionBgColor;
  Color? optionTextColor;
  Color? backgroundColor;
  Color? bottomNavigationBarColor;
  Color? bottomNavigationTextColor;
  Color? activeQuestionBgColor;
  Color? primaryColor;
  Color? optionShadowColor;
  Color? passiveQuestionBgColor;
  double? fontSize;
  Color? drawTextColor;
  Color? questionBgShadowColor;
  Color? bookColor;

  TestPageThemeModel(
      {this.isLight,
      required this.primaryGradient,
      this.questionBgGradient,
      this.backgroundColor,
      this.optionBgColor,
      this.optionTextColor,
      this.questionTextColor,
      this.bottomNavigationBarColor,
      this.bottomNavigationTextColor,
      this.primaryTextColor,
      this.activeQuestionBgColor,
      this.optionShadowColor,
      this.passiveQuestionBgColor,
      this.fontSize,
      this.drawTextColor,
      this.questionBgShadowColor}) {
    primaryColor = primaryGradient.colors.first;
  }
}
