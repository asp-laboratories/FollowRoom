import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class ContainerStyles {
  // Decoraciones básicas
  static final decoracionNormal = BoxDecoration(
    color: AppColores.primary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColores.primary),
  );


  // Card de reservación
  static BoxDecoration get cardReservacion => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.20),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

    static BoxDecoration get sombreado => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: AppColores.backgroundComponentSelected,
    boxShadow: [
      BoxShadow(
        color: AppColores.primary.withValues(alpha: 1),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Estados de reservación
  static BoxDecoration get estadoAceptado => BoxDecoration(
    color: Colors.green.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get estadoProceso => BoxDecoration(
    color: Colors.orange.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get estadoCancelado => BoxDecoration(
    color: Colors.red.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get estadoOcupado => BoxDecoration(
    color: Colors.red.shade100,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration get estadoLibre => BoxDecoration(
    color: Colors.green.shade100,
    borderRadius: BorderRadius.circular(12),
  );

  // Textos
  static TextStyle get tituloCard => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColores.foreground,
  );

  static TextStyle get subtituloCard => TextStyle(color: Colors.grey.shade700);

  static TextStyle get textoChico =>
      TextStyle(fontSize: 14, color: Colors.grey);

  static TextStyle get textoEstado =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  // Padding y Margin
  static EdgeInsets get paddingCard => EdgeInsets.all(16);
  static EdgeInsets get marginCardBottom => EdgeInsets.only(bottom: 12);
  static EdgeInsets get paddingIcon => EdgeInsets.only(right: 6);

  // Iconos
  static Icon iconCard(IconData dato) =>
      Icon(dato, size: 16, color: Colors.grey);
}
