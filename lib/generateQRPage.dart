import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class GenerateQR extends StatefulWidget {
  @override
  _GenerateQRState createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  String qrData = "Hello from this QR";
  TextEditingController qrdataFeed = TextEditingController();
  GlobalKey globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    qrdataFeed.addListener(() {
      setState(() {
        qrData = qrdataFeed.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar having title
      appBar: AppBar(
        title: Center(child: Text("Generate QR Code")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _captureAndSharePng,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          //Scroll view given to Column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: qrData,
                  version: QrVersions.auto,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Generate QR Code",
                style: TextStyle(fontSize: 20),
              ),
              inputWidget(qrdataFeed, "Please Enter your QRCode", false,
                  "QRCode", 'QRCode', (value) {
                qrData = value;
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                //Button for generating QR code
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {
                      print(qrData);
                    });
                  },
                  //Title given on Button
                  child: Text(
                    "Generate QR Code",
                    style: TextStyle(
                      color: Colors.indigo[900],
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.indigo[900]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndSharePng() async {

    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    var image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    final tempDir = await getTemporaryDirectory();
    File file = await new File('${tempDir.path}/image.png').create();
    await file.writeAsBytes(pngBytes);
    Share.shareFiles(['${tempDir.path}/image.png'],
          subject: 'URL conversion + Share',
          text: 'Hey! Checkout the Share Files repo',
          sharePositionOrigin: boundary.localToGlobal(Offset.zero) & boundary.size);
  }

  Widget inputWidget(TextEditingController textEditingController,
      String validation, bool, String label, String hint, save) {
    return TextFormField(
      style: TextStyle(fontSize: 15.0, color: Color(0xff9FA0AD)),
      controller: textEditingController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xff1E1C24),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 15.0, color: Color(0xff9FA0AD)),
        labelStyle: TextStyle(fontSize: 15.0, color: Color(0xff9FA0AD)),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff41414A)),
            borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff41414A)),
            borderRadius: BorderRadius.circular(12.0)),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff41414A)),
            borderRadius: BorderRadius.circular(12.0)),
      ),
      obscureText: bool,
      validator: (value) => value.isEmpty ? validation : null,
      onSaved: save,
    );
  }
}
