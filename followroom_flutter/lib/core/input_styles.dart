import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class InputStyles {
  static final input = InputDecoration(
    labelText: 'Default',
    hintText: 'predeterminado',
    prefixIcon: Icon(Icons.person),

    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0     ), borderSide: BorderSide(color: AppColores.primary, width: 1.0)),

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColores.primary, width: 1.0),
      borderRadius: BorderRadius.circular(10),
    ),

    filled: true,
    fillColor: const Color.fromARGB(255, 0, 0, 0),
  );

  static final input2 = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    hintText: "Escribe aquí...",
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    filled: true,
    fillColor: Colors.white,
  );
}

InputDecoration createAppDecoration({
  String? labelText,
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    errorText: errorText,

    // Estilos fijos que quieres reutilizar
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: AppColores.primary, width: 1.0)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColores.primary, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange, width: 2.0),
      borderRadius: BorderRadius.circular(10.0),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    labelStyle: const TextStyle(color: AppColores.primary),
    // Color cuando el usuario hace clic (Focus)
    floatingLabelStyle: const TextStyle(
      color: AppColores.primary,
      fontWeight: FontWeight.bold,
    ),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
    // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
