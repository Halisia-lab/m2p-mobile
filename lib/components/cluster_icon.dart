import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/map.dart';

Future<BitmapDescriptor> clusterIcon(int size, double freePlacesPercentages,
    {String? text}) async {
  if (kIsWeb) size = (size).floor();

  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final Paint paint1 = Paint()
    ..color = MapService.getCircleColor(
        freePlacesPercentages); //null while there are no signalements
  final Paint paint2 = Paint()..color = Colors.white;

  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2.3, paint1);

  if (text != null) {
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
          fontSize: size / 5, color: Colors.white, fontWeight: FontWeight.bold),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );
  }

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  return BitmapDescriptor.fromBytes(
    data.buffer.asUint8List(),
  );
}
