import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/container_styles.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/detalles_historial.dart';

class TabCanceladosReservacion extends StatelessWidget {
  const TabCanceladosReservacion({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reservaciones = [
      {
        'id': '6',
        'nombre': 'Fiesta Privada',
        'salon': 'Salón Ejecutivo',
        'fecha': '10 de Marzo 2026',
        'hora': '20:00 - 00:00',
      },
      {
        'id': '7',
        'nombre': 'Taller de Cocina',
        'salon': 'Salón Universal',
        'fecha': '12 de Marzo 2026',
        'hora': '11:00 - 14:00',
      },
      {
        'id': '8',
        'nombre': 'Seminario',
        'salon': 'Salón Imperial',
        'fecha': '14 de Marzo 2026',
        'hora': '09:00 - 18:00',
      },
    ];

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppColores.background2),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          itemCount: reservaciones.length,
          itemBuilder: (context, index) {
            final r = reservaciones[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: ContainerStyles.sombreado,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetallesHistorial(idReservacion: r['id']),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                r['nombre'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColores.foreground,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Cancelado',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              r['salon'],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              r['fecha'],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              r['hora'],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
