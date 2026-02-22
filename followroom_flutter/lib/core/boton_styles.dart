import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class BotonStyles {
  static final botonEstilos =  ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColores.primary,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                  )
                 );
}