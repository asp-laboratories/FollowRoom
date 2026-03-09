import 'package:flutter/material.dart';
import 'package:followroom_flutter/components/card_reservacion.dart';

class TabAceptadosReservacion extends StatelessWidget {
  const TabAceptadosReservacion({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reservaciones = [
      {
        'nombre': 'Cumpleaños de María',
        'salon': 'Salón Imperial',
        'fecha': '15 de Marzo 2026',
        'hora': '14:00 - 18:00',
      },
      {
        'nombre': 'Reunión Corporate',
        'salon': 'Salón Ejecutivo',
        'fecha': '18 de Marzo 2026',
        'hora': '09:00 - 12:00',
      },
      {
        'nombre': 'Conferencia Tech',
        'salon': 'Salón Universal',
        'fecha': '20 de Marzo 2026',
        'hora': '10:00 - 14:00',
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
          estado: 'Aceptado',
          estadoColor: Colors.green,
          estadoIcono: Icons.check_circle,
        );
      },
    );
  }
}
