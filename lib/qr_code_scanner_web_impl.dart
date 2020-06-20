// Note: only work over https or localhost
//
// thanks:
// - https://medium.com/@mk.pyts/how-to-access-webcam-video-stream-in-flutter-for-web-1bdc74f2e9c7
// - https://kevinwilliams.dev/blog/taking-photos-with-flutter-web
// - https://github.com/cozmo/jsQR
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js' as js;
import 'package:flutter/widgets.dart';

/**
 * call global function jsQR
 * import https://github.com/cozmo/jsQR/blob/master/dist/jsQR.js on your index.html at web folder
 */
dynamic _jsQR(d, w, h, o) {
  return js.context.callMethod('jsQR', [d, w, h, o]);
}

class QrCodeCameraWebImpl extends StatefulWidget {
  final void Function(String qrValue) qrCodeCallback;
  final Widget child;
  final BoxFit fit;
  final Widget Function(BuildContext context, Object error) onError;

  QrCodeCameraWebImpl({
    Key key,
    @required this.qrCodeCallback,
    this.child,
    this.fit = BoxFit.cover,
    this.onError,
  })  : assert(qrCodeCallback != null),
        super(key: key);

  @override
  _QrCodeCameraWebImplState createState() => _QrCodeCameraWebImplState();
}

class _QrCodeCameraWebImplState extends State<QrCodeCameraWebImpl> {
  double _width= 768;
  double _height = 1280;
  String _unique_key = UniqueKey().toString();

  //see https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/readyState
  final _HAVE_ENOUGH_DATA = 4;

  // Webcam widget to insert into the tree
  Widget _videoWidget;

  // VideoElement
  html.VideoElement _video;
  Timer _timer;
  html.CanvasElement _canvasElement;
  html.CanvasRenderingContext2D _canvas;
  html.MediaStream _stream;

  @override
  void initState() {
    super.initState();

    // Create a video element which will be provided with stream source
    _video = html.VideoElement();
    // Register an webcam
    ui.platformViewRegistry.registerViewFactory(
        'webcamVideoElement$_unique_key', (int viewId) => _video);
    // Create video widget
    _videoWidget = HtmlElementView(
        key: UniqueKey(), viewType: 'webcamVideoElement$_unique_key');

    // Access the webcam stream
    html.window.navigator.getUserMedia(video: {'facingMode': 'environment'})

//    mediaDevices.getUserMedia({
//      'video': {
//        'facingMode': {'exact': 'environment'}
//      }
//    })

        .then((html.MediaStream stream) {
      _stream = stream;
      _video.srcObject = stream;
      _video.setAttribute('playsinline',
          'true'); // required to tell iOS safari we don't want fullscreen
      _video.play();
    });
    _canvasElement = html.CanvasElement();
    _canvas = _canvasElement.getContext("2d");
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      tick();
    });
  }

  tick() {
    if (_video.readyState == _HAVE_ENOUGH_DATA) {
      _canvasElement.width = _width.toInt();
      _canvasElement.height = _height.toInt();
      _canvas.drawImage(_video, 0, 0);
      var imageData = _canvas.getImageData(
          0, 0, _canvasElement.width, _canvasElement.height);
      js.JsObject code =
          _jsQR(imageData.data, imageData.width, imageData.height, {
        'inversionAttempts': 'dontInvert',
      });
      if (code != null) {
        String value = code['data'];
        this.widget.qrCodeCallback(value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    var bw = 768.0 / 2;
    var bh = (bw / 4) * 3;

    return Container(
      height: double.infinity,
      width: double.infinity,
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: bw,
          height: bh,
          child: _videoWidget,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _video.pause();

    Future.delayed(Duration(seconds: 2), () {

      try {
        _stream?.getTracks()?.forEach((mt) {
                mt.stop();
              });
      } catch (e) {
        print('error on dispose qrcode: $e');
      }

    });
    super.dispose();
  }
}
