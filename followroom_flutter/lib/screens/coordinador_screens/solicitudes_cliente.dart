import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class ReservacionesVisualScreen extends StatefulWidget {
  const ReservacionesVisualScreen({super.key});

  @override
  State<ReservacionesVisualScreen> createState() =>
      _ReservacionesVisualScreenState();
}

class _ReservacionesVisualScreenState extends State<ReservacionesVisualScreen> {
  List<Map<String, dynamic>> get reservaciones => [
    {
      "nombre": "Reservación 1",
      "fecha": "15 de Marzo 2026",
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
      "fecha": "18 de Marzo 2026",
      "mobiliario": [
        {"nombre": "Silla", "cantidad": 10},
      ],
      "equipamiento": [
        {"nombre": "Bocina", "cantidad": 2},
      ],
    },
    {
      "nombre": "Reservación 3",
      "fecha": "20 de Marzo 2026",
      "mobiliario": [
        {"nombre": "Mesa Redonda", "cantidad": 8},
        {"nombre": "Silla Tiffany", "cantidad": 80},
      ],
      "equipamiento": [],
    },
  ];

  final Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.background2,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservaciones.length,
        itemBuilder: (context, index) {
          final reservacion = reservaciones[index];
          final isExpanded = _expandedItems.contains(index);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColores.backgroundComponent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded ? AppColores.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedItems.remove(index);
                      } else {
                        _expandedItems.add(index);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reservacion["nombre"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.foreground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reservacion["fecha"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColores.foreground.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColores.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildSeccion(
                          titulo: "Mobiliario",
                          lista: reservacion["mobiliario"],
                          icono: Icons.chair,
                        ),
                        if (reservacion["mobiliario"].isNotEmpty &&
                            reservacion["equipamiento"].isNotEmpty)
                          const SizedBox(height: 12),
                        _buildSeccion(
                          titulo: "Equipamiento",
                          lista: reservacion["equipamiento"],
                          icono: Icons.devices,
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
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
                color: AppColores.foreground,
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
                Text(
                  item["nombre"],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColores.foreground.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  "x${item["cantidad"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColores.primary,
                    fontSize: 13,
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
