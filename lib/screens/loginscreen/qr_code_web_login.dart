import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../appbloc/appvar.dart';
import '../../services/dataservice.dart';

class QRCodeWebLogin extends StatelessWidget {
  QRCodeWebLogin();
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      body: Body.child(child: ScanViewDemo()),
      topActions: TopActionsTitle(title: 'webqrcodelogin'.translate),
    );
  }
}

class ScanViewDemo extends StatefulWidget {
  ScanViewDemo({Key? key}) : super(key: key);

  @override
  _ScanViewDemoState createState() => _ScanViewDemoState();
}

class _ScanViewDemoState extends State<ScanViewDemo> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 250,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      OverAlert.show(message: 'permissionerr'.translate, type: AlertType.danger);
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (Fav.isTimeGuardNotAllowed('qrcodedelay', duration: 5.seconds)) return;
      final _data = scanData.code!;
      if (!_data.startsWith('enc:')) {
        return OverAlert.show(message: 'qrcodeerr'.translate, type: AlertType.danger);
      }

      final _userData = {
        'u': AppVar.appBloc.hesapBilgileri.username,
        'p': AppVar.appBloc.hesapBilgileri.password,
        's': AppVar.appBloc.hesapBilgileri.kurumID,
      };
      final _stringData = jsonEncode(_userData);
      final _encStringData = _stringData.mix;
      OverLoading.show();
      SignInOutService.dbQrCodeLogin(_data.replaceFirst('enc:', '').unMix!).set(_encStringData).then((value) async {
        await OverLoading.close();
        Get.back();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
