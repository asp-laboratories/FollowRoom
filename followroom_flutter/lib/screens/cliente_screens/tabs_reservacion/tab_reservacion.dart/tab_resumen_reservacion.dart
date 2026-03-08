import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabResumen extends StatefulWidget {
  final Map<String, String> datosReservacion;
  final String? montajeSeleccionado;

  const TabResumen({
    super.key,
    required this.datosReservacion,
    required this.montajeSeleccionado,
  });

  @override
  State<TabResumen> createState() => _TabResumenState();
}

class _TabResumenState extends State<TabResumen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColores.secundary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Datos de la Reservación",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Nombre del evento: ${widget.datosReservacion['nombre'] ?? 'No definido'}",
                ),
                Text(
                  "Fecha: ${widget.datosReservacion['fecha'] ?? 'No definida'}",
                ),
                Text(
                  "Horario: ${widget.datosReservacion['horario'] ?? 'No definido'}",
                ),
                Text(
                  "Tipo de evento: ${widget.datosReservacion['tipo'] ?? 'No seleccionado'}",
                ),
                Text(
                  "Asistentes: ${widget.datosReservacion['asistentes'] ?? '0'}",
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColores.secundary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Montaje Seleccionado",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  widget.montajeSeleccionado ?? "Ningún montaje seleccionado",
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(color: AppColores.secundary),
          ),
          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: AppColores.secundary),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: AppColores.secundary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
