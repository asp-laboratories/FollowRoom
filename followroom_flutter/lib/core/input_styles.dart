import 'package:flutter/material.dart';

class InputStyles {
  static final input = InputDecoration(
    labelText: 'Default',
    hintText: 'predeterminado',
    prefixIcon: Icon(Icons.person),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(10)
    ),

    filled: true,
    fillColor: Colors.grey
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
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: const Color(0xFFFFFFFF), width: 2.0),
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
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

