import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class ReservacionesVisualScreen extends StatelessWidget {
  const ReservacionesVisualScreen({super.key});

  List<Map<String, dynamic>> get reservaciones => [
        {
          "nombre": "Reservación 1",
          "mobiliario": [
            {"nombre": "Silla", "cantidad": 5},
            {"nombre": "Mesa", "cantidad": 2},
          ],
          "equipamiento": [
            {"nombre": "Proyector", "cantidad": 1},
          ],
        },
        {
          "nombre": "Reservación 2",
          "mobiliario": [
            {"nombre": "Silla", "cantidad": 10},
          ],
          "equipamiento": [
            {"nombre": "Bocina", "cantidad": 2},
          ],
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservaciones.length,
        itemBuilder: (context, index) {
          final reservacion = reservaciones[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColores.backgroundComponent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservacion["nombre"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColores.foreground,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSeccion(
                    titulo: "Mobiliario",
                    lista: reservacion["mobiliario"],
                    icono: Icons.chair,
                  ),
                  const SizedBox(height: 10),
                  _buildSeccion(
                    titulo: "Equipamiento",
                    lista: reservacion["equipamiento"],
                    icono: Icons.devices,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required List lista,
    required IconData icono,
  }) {
    if (lista.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: AppColores.primary),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...lista.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item["nombre"]),
                Text(
                  "x${item["cantidad"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColores.primary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}