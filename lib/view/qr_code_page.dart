import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:life_balancing/services/auth.dart';
import 'package:life_balancing/view/HomePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({Key key}) : super(key: key);

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  Barcode result;
  QRViewController controller;
  bool isLoading = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void qrCode(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((event) async {
      result = event;

      if (result.code != null) {
        controller.pauseCamera();
        SharedPreferences.getInstance().then((prefs) async {
          String token = (prefs.getString('token') ?? null);
          var res = await createVisitActivity("api/activities/visit-company", result.code, token);
          isLoading = true;
          if (res.statusCode == 200) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomePage(),
                ));
          } else {
            Toast.show(
              json.decode(res.body)['message'],
              context,
              backgroundColor: Colors.red,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
            );
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomePage(),
                ));
          }
        });
      }
      setState(() {});
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 300.0;
    return Scaffold(
        backgroundColor: Colors.transparent,
        //CashHelper.getData(key: ChangeTheme) ? AppColor.lightModePrim : AppColor.darkModePrim,
        body: result == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      color: Colors.transparent,
                      height: 600,
                      width: 600,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: qrCode,
                        overlay: QrScannerOverlayShape(
                            borderColor: Colors.white,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: scanArea),
                        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Center(
                      child: Text(
                    result != null ? '${result.code}' : 'scan a code',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                  ))
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
