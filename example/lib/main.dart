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

class Page extends StatefulWidget {
  const Page({
    Key key,
  }) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  num count = 0;
  String lastQRCode = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Flexible(
            child: QrCodeCameraWeb(
              qrCodeCallback: (qr) {
                setState(() {
                  count++;
                  lastQRCode = qr;
                  print('qrcode: $count  $qr');
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$count $lastQRCode',
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ],
      ),
    );
  }
}
