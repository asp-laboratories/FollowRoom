import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class ContainerStyles {
  // Widget reutilizable para secciones de información
  static Widget seccionInformativa({
    required String titulo,
    required List<Widget> contenido,
    Widget? childAdicional,
    double paddingExterior = 16.0,
    double paddingInterno = 12.0,
    double fontSizeTitulo = 16,
    bool mostrarLabel = true,
  }) {
    return Padding(
      padding: EdgeInsets.all(paddingExterior),
      child: Container(
        width: double.infinity,
        decoration: ContainerStyles.sombreado,
        padding: EdgeInsets.all(paddingInterno),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSizeTitulo,
              ),
            ),
            SizedBox(height: 8),
            ...contenido,
            if (childAdicional != null) ...[
              SizedBox(height: 8),
              childAdicional,
            ],
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para filas de información (label: valor)
  static Widget filaInformacion(
    String label,
    String valor, {
    bool mostrarLabel = true,
  }) {
    if (mostrarLabel) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text("$label: $valor"),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(valor),
    );
  }

  // Card para pantallas de almacenista
  static BoxDecoration get cardAlmacenista => BoxDecoration(
    color: AppColores.backgroundComponent,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(
      color: AppColores.primary.withValues(alpha: 0.3),
      style: BorderStyle.solid,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColores.primary.withValues(alpha: 0.5),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  );

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

  // Card para selección (salón, servicios, equipamiento)
  static BoxDecoration cardSeleccion({required bool isSelected}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: isSelected
          ? AppColores.backgroundComponentSelected
          : AppColores.backgroundComponent,
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? AppColores.primary.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.1),
          blurRadius: isSelected ? 8 : 4,
          offset: Offset(0, isSelected ? 4 : 2),
        ),
      ],
      border: Border.all(
        color: isSelected
            ? AppColores.primary
            : AppColores.primary.withValues(alpha: 0.2),
        width: isSelected ? 2 : 1,
      ),
    );
  }

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

  static BoxDecoration get sombreadoCard => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: AppColores.backgroundComponent,
    border: Border.all(
      color: AppColores.primary.withValues(alpha: 0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get sombreadoCardSelected => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: AppColores.backgroundComponentSelected,
    boxShadow: [
      BoxShadow(
        color: AppColores.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
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
