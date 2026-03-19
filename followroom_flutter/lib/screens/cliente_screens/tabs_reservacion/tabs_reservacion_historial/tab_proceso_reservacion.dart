import 'package:flutter/material.dart';
import 'package:followroom_flutter/components/card_reservacion.dart';
import 'package:followroom_flutter/screens/cliente_screens/historial/detalles_historial.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabProcesoReservacion extends StatelessWidget {
  const TabProcesoReservacion({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reservaciones = [
      {
        'id': '4',
        'nombre': 'Boda Rodríguez',
        'salon': 'Salón Premium',
        'fecha': '25 de Marzo 2026',
        'hora': '16:00 - 22:00',
        'precio': 25000,
      },
      {
        'id': '5',
        'nombre': 'Exposición Arte',
        'salon': 'Salón Imperial',
        'fecha': '28 de Marzo 2026',
        'hora': '08:00 - 17:00',
        'precio': 18000,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: reservaciones.length,
      itemBuilder: (context, index) {
        final r = reservaciones[index];
        return CardReservacion(
          nombreEvento: r['nombre'],
          salon: r['salon'],
          fecha: r['fecha'],
          hora: r['hora'],
          estado: 'En Proceso',
          estadoColor: Colors.orange,
          estadoIcono: Icons.hourglass_top,
          precio: r['precio'],
          cardColor: AppColores.backgroundComponent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallesHistorial(idReservacion: r['id']),
              ),
            );
          },
        );
      },
    );
  }
}
