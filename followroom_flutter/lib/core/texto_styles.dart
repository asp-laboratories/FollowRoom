import 'package:flutter/material.dart';

class TextEstilos {
  static const encabezados = TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static final encabezados1 = TextStyle(
    color: Color.fromARGB(255, 255, 255, 255),
    fontSize: 24,
    fontWeight: FontWeight.bold,
    // shadows: [
    //   Shadow(
    //     color: Colors.black.withValues(alpha: 0.9),
    //     offset: const Offset(2, 2.5),
    //     blurRadius: 9,
    //   ),
    // ],
  );
  static const subtitulos = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const indicador = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
