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
