import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

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

  static final encabezadosBlancos = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: AppColores.primary.withValues(alpha: 0.9),
        offset: const Offset(2, 2.5),
        blurRadius: 9,
      ),
    ],
  );

  static const indicador = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const labelCard = TextStyle(
    color: AppColores.foreground,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const valorCard = TextStyle(
    color: AppColores.foreground,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
