import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner_web/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_qr_code_reader_web example'),
        ),
        body: Page(),
      ),
    );
  }
}

class Page extends StatelessWidget {
  const Page({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrCodeCameraWeb(
        qrCodeCallback: (qr) {
          print('qrcode: $qr');
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(qr),
          ));
        },
      ),
    );
  }
}
