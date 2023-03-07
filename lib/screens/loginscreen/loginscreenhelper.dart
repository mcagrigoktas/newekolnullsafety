import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'qr_view.dart';

enum LoginScreenState {
  form,
  existingLogin,
  qr,
}

class QRWidget extends StatelessWidget {
  final String qrCode;
  final Function() backFunction;
  final Color color;
  QRWidget(this.qrCode, this.backFunction, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200,
              height: 200,
              child: QrView(
                data: qrCode,
                color: color,
              ),
            )),
        24.heightBox,
        'qrcodehint'.translate.text.center.fontSize(12).color(color).make(),
        MyRaisedButton(
          text: 'back'.translate,
          // iconData: Icons.arrow_back_ios,
          onPressed: backFunction,
          color: color,
          textColor: Colors.white,
        ).p16
      ],
    );
  }
}

class LoginFormField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String?)? onSaved;
  final Function(String)? onSubmitted;
  final int maxLines;
  final bool obscureText;
  final String hintText;
  final String? labelText;
  final IconData? iconData;
  final String? initialValue;
  final Color? imageBackgroundColor;

  LoginFormField({required this.onSaved, this.initialValue, this.controller, this.maxLines = 1, this.obscureText = false, this.hintText = "", this.labelText, this.iconData, this.onSubmitted, this.imageBackgroundColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: ShapeDecoration(color: Colors.white.withAlpha(20), shape: StadiumBorder(side: BorderSide(color: Colors.black.withAlpha(40), width: 1))),
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: TextFormField(
          maxLengthEnforcement: MaxLengthEnforcement.none,
          onSaved: onSaved,
          onFieldSubmitted: onSubmitted,
          initialValue: initialValue,
          obscureText: obscureText,
          maxLines: maxLines,
          controller: controller,
          autocorrect: false,
          cursorColor: Colors.black,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            hintText: labelText,
            alignLabelWithHint: false,

            hintStyle: TextStyle(fontSize: 16.0, color: (imageBackgroundColor ?? Colors.black).withAlpha(100), fontWeight: FontWeight.bold),
            //   labelText: labelText
          ),
          style: TextStyle(fontSize: 16.0, color: (imageBackgroundColor ?? Colors.black), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
